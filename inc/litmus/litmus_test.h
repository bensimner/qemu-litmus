#include <stdint.h>

/* global configuration */
uint64_t NUMBER_OF_RUNS;

/* test data */
typedef struct {
    uint64_t counter;
    uint64_t values[];
} test_result_t;

typedef struct {
    int allocated;
    int limit;
    test_result_t** lut;
    test_result_t* results[];
} test_hist_t;

/* Each thread is a functon that takes pointers to a slice of heap variables and output registers */
typedef struct test_ctx test_ctx_t;
typedef void th_f(test_ctx_t* ctx, int i, uint64_t** heap_vars, uint64_t** ptes, uint64_t* pas, uint64_t** out_regs);

struct test_ctx {
  uint64_t no_threads;
  th_f** thread_fns;             /* pointer to each thread function */
  uint64_t** heap_vars;         /* set of heap variables: x, y, z etc */
  const char** heap_var_names;
  uint64_t no_heap_vars;
  uint64_t** out_regs;          /* set of output register values: P1:x1,  P2:x3 etc */
  const char** out_reg_names;
  uint64_t no_out_regs;
  int volatile* start_barriers;
  int volatile* end_barriers;
  int volatile* cleanup_barriers;
  int volatile* final_barrier;
  uint64_t* shuffled_ixs;
  uint64_t no_runs;
  const char* test_name;
  test_hist_t* hist;
  uint64_t* ptable;
  uint64_t current_run;
  int* start_els;
  uint64_t current_EL;
  uint64_t privileged_harness;  /* require harness to run at EL1 between runs ? */
};

typedef enum {
  TYPE_HEAP,
  TYPE_PTE,
} init_type_t;

typedef struct {
  const char* varname;
  init_type_t type;
  uint64_t value;
} init_varstate_t;

/* passed as argument to run_test() to configure extra options */
typedef struct {
  uint64_t* interesting_result;   /* interesting (relaxed) result to highlight */
  int* thread_ELs;                /* EL for each thread to start at */

  int no_init_states;
  init_varstate_t* init_states;   /* initial state array */
} test_config_t;

/* entry point for tests */
void run_test(const char* name, 
              int no_threads, th_f** funcs, 
              int no_heap_vars, const char** heap_var_names,
              int no_regs, const char** reg_names,
              test_config_t cfg);

void init_test_ctx(test_ctx_t* ctx, const char* test_name, int no_threads, th_f** funcs, int no_heap_vars, int no_out_regs, int no_runs);
void free_test_ctx(test_ctx_t* ctx);

/* helper functions */
uint64_t idx_from_varname(test_ctx_t* ctx, const char* varname);
void set_init_pte(test_ctx_t* ctx, const char* varname, uint64_t pte);
void set_init_heap(test_ctx_t* ctx, const char* varname, uint64_t value);


/* print the collected results out */
void print_results(test_hist_t* results, test_ctx_t* ctx, const char** out_reg_names, uint64_t* interesting_results);

/* call at the start and end of each run  */
void start_of_run(test_ctx_t* ctx, int thread, int i);
void end_of_run(test_ctx_t* ctx, int thread, int i);

/* call at the start and end of each thread */
void start_of_thread(test_ctx_t* ctx, int cpu);
void end_of_thread(test_ctx_t* ctx, int cpu);

/* call at the beginning and end of each test */
void start_of_test(test_ctx_t* ctx, const char* name, int no_threads, th_f** funcs, int no_heap_vars, int no_regs, int no_runs);
void end_of_test(test_ctx_t* ctx, const char** out_reg_names, uint64_t* interesting_result);
