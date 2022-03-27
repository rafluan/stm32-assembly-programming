

            .syntax unified
            .cpu    cortex-m4
            .fpu    softvfp
            .thumb
            .section    .text
            .globl  __main

__main:

            mov     r0,#25
            mov     r1,#19

            //r0 = A +8B
            add     r0,r0,r1,lsl #3

            mov     r1,#99
            mov     r2,#7

            //Add 7C to R0 and put result in R0 (R0 = (R1*R2)+R0)
            mla     r0,r1,r2,r0
            sub     r0,r0,#27

            //Divide the total by 4
            mov     r0,r0,asr #2

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