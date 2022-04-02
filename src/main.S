

            .syntax unified
            .cpu    cortex-m4
            .fpu    softvfp
            .thumb
            .section    .text
            .globl  __main

__main:

            ldr r3,=0xDEADBEEF
            ldr r4,=0xBABEFACE

            push {r3}
            push {r4}

            pop  {r5}
            pop  {r6}

stop:
            b       stop

            .align
            .end

/* The N, V, Z and C flags:
 N -> For checking for negative result

 V -> For indicating a signed overflow. Overflow occurs when: Addtion,
 subtraction or compare result is greater than 2^31 or less than -2^31

 Z -> For checking for zero result

 C -> For checking for result greater than 2^32 
 */