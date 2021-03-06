.section .exc_table

.macro save_all_registers
    msr spsel,  #0  /* use SP_EL0 always */
    dsb nsh
    isb

    stp x0,     x1,     [sp, #-288]!
    stp x2,     x3,     [sp, #16]
    stp x4,     x5,     [sp, #32]
    stp x6,     x7,     [sp, #48]
    stp x8,     x9,     [sp, #64]
    stp x10,    x11,    [sp, #80]
    stp x12,    x13,    [sp, #96]
    stp x14,    x15,    [sp, #112]
    stp x16,    x17,    [sp, #128]
    stp x18,    x19,    [sp, #144]
    stp x20,    x21,    [sp, #160]
    stp x22,    x23,    [sp, #176]
    stp x24,    x25,    [sp, #192]
    stp x26,    x27,    [sp, #208]
    stp x28,    x29,    [sp, #224]
    str x30,            [sp, #240]
.endm

.macro restore_all_registers
    ldp x2,     x3,     [sp, #16]
    ldp x4,     x5,     [sp, #32]
    ldp x6,     x7,     [sp, #48]
    ldp x8,     x9,     [sp, #64]
    ldp x10,    x11,    [sp, #80]
    ldp x12,    x13,    [sp, #96]
    ldp x14,    x15,    [sp, #112]
    ldp x16,    x17,    [sp, #128]
    ldp x18,    x19,    [sp, #144]
    ldp x20,    x21,    [sp, #160]
    ldp x22,    x23,    [sp, #176]
    ldp x24,    x25,    [sp, #192]
    ldp x26,    x27,    [sp, #208]
    ldp x28,    x29,    [sp, #224]
    ldr x30,            [sp, #240]
    ldp x0,     x1,     [sp], #288
.endm

.macro handler, name, vec
\name:
    save_all_registers

    mov x0, #\vec
    mrs x1, ESR_EL1
    mov x2, sp
    bl handle_exception

    restore_all_registers
    eret
.endm

.macro restore_other_registers
    ldp x8,     x9,     [sp, #64]
    ldp x10,    x11,    [sp, #80]
    ldp x12,    x13,    [sp, #96]
    ldp x14,    x15,    [sp, #112]
    ldp x16,    x17,    [sp, #128]
    ldp x18,    x19,    [sp, #144]
    ldp x20,    x21,    [sp, #160]
    ldp x22,    x23,    [sp, #176]
    ldp x24,    x25,    [sp, #192]
    ldp x26,    x27,    [sp, #208]
    ldp x28,    x29,    [sp, #224]
    ldr x30,            [sp, #240]
    add sp, sp, #288
.endm

.macro synchandler, name, vec
\name:
    save_all_registers

    mov x0, #\vec
    mrs x1, ESR_EL1
    mov x2, sp
    bl handle_exception

    /* dont restore x0..x7 for sync exceptions */
    restore_all_registers
    eret
.endm

synchandler el1_sp0_sync,       0
handler el1_sp0_irq,            1
handler el1_sp0_fiq,            2
handler el1_sp0_serror,         3

synchandler el1_spx_sync,       4
handler el1_spx_irq,            5
handler el1_spx_fiq,            6
handler el1_spx_serror,         7

synchandler el0_64_sync,        8
handler el0_64_irq,             9
handler el0_64_fiq,            10
handler el0_64_serror,         11

synchandler el0_32_sync,       12
handler el0_32_irq,            13
handler el0_32_fiq,            14
handler el0_32_serror,         15

.macro vectorjmp, name
.align 7
b \name
.endm

.global el1_exception_vector_table
.align 11
el1_exception_vector_table:
    vectorjmp el1_sp0_sync
    vectorjmp el1_sp0_irq
    vectorjmp el1_sp0_fiq
    vectorjmp el1_sp0_serror

    vectorjmp el1_spx_sync
    vectorjmp el1_spx_irq
    vectorjmp el1_spx_fiq
    vectorjmp el1_spx_serror

    vectorjmp el0_64_sync
    vectorjmp el0_64_irq
    vectorjmp el0_64_fiq
    vectorjmp el0_64_serror

    vectorjmp el0_32_sync
    vectorjmp el0_32_irq
    vectorjmp el0_32_fiq
    vectorjmp el0_32_serror

/* set the vector table and return a pointer to the old one */
.global set_vector_table
set_vector_table:
    mov x1, x0
    mrs x0, vbar_el1
    msr vbar_el1, x1
    isb
    ret
