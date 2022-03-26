

count       .req    r0
max         .req    r1
pointer     .req    r2
next        .req    r3


mydata:     .word   69,87,86,45,75


            .syntax unified
            .cpu    cortex-m4
            .fpu    softvfp
            .thumb
            .section    .text
            .globl  __main

__main:
            

            mov count,#5
            mov max,#0

            // load mem address of mydata into r2
            ldr pointer,= mydata;

again:
            // load value at mem address found in r2 into r3
            ldr next,[pointer]

            // compare max with r3 and update conditional flags
            cmp max,next 

            // branch to ctnu if max is equal or greater than r3 
            bhs ctnu
            mov max,next

ctnu:
            // add 4 bytes to pointer and store results in pointer
            add pointer,pointer,#4

            // subtract 1 from count, store result into count and
            // update the conditional flags

            subs count,count,#1

            // branch if results is not equal to zero
            bne again

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
