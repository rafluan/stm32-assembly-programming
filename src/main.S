

            .section .data
    
SIGN_DATA:  .byte +13,-10,+9,+14,-18,-9,+12,-19,+16


            .syntax unified
            .cpu    cortex-m4
            .fpu    softvfp
            .thumb
            .section    .text
            .globl  __main

__main:

            //load the address of SIGN_DATA into r0
            ldr r0,=SIGN_DATA
            mov r3,#9

begin:
            //load a signed byte from mem address found in r0 into r2
            ldrsb   r2,[r0]
            add     r0,r0,#1

            //load a signed byte from mem address found in r0 into r1
            ldrsb   r1,[r0]
            cmp     r1,r2

            //branch to next if r1 is greater than or equal to r2
            bge     next
            mov     r1,r2

next:

            add     r0,r0,#1
            subs    r3,r3,#1

            //branch to begin if result is not equal to zero
            bne     begin


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