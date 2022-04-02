

            .syntax unified
            .cpu    cortex-m4
            .fpu    softvfp
            .thumb
            .section    .text
            .globl  __main

__main:

            mov r6,#4
            mov r7,#1

loop:
            cmp r6,#0

            // if r6 is greater than zero than
            // execute the next three instructions

            ittt    GT
            mulgt  r7,r6,r7    // multipy if r6 is greater than 0
            subgt   r6,r6,#1    // subtract one from r6 if r6 is greater than 0
            bgt     loop        // branch if r6 is greater than 0

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