

            .syntax unified
            .cpu    cortex-m4
            .fpu    softvfp
            .thumb
            .section    .text
            .globl  __main

__main:

            ldr     r0,=60
            mov     r1,#10
            mov     r2,#0

            cmp     r0,r1

again:
            //branch to stop if r0 is lower than r1
            blo     stop
            sub     r0,r0,r1
            add     r2,r2,#1
            b       again


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