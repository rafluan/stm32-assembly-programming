


.equ RCC_BASE,              0x40023800
.equ AHB1ENR_OFFSET,        0x30

.equ RCC_AHB1ENR,           (RCC_BASE + AHB1ENR_OFFSET)      
.equ GPIOG_BASE,            0x40021800

.equ GPIO_MODER_OFFSET,     0x00
.equ GPIOG_MODER,           (GPIOG_BASE + GPIO_MODER_OFFSET)

.equ GPIOG_ODR_OFFSET,      0x14
.equ GPIOG_ODR,             (GPIOG_BASE + GPIOG_ODR_OFFSET)

.equ GPIOG_EN,              (1<<6)
.equ MODER13_OUT,           (1<<26)
.equ LED_ON,                (1U<<13)
.equ LED_OFF,               (1<<0)
.equ ONESEC,                5333333

            .syntax unified
            .cpu    cortex-m4
            .fpu    softvfp
            .thumb
            .section    .text
            .globl  __main

__main:
            // load address of RCC_AHB1ENR to r0
            ldr r0,=RCC_AHB1ENR

            // load value at address found in r0 into r1
            ldr r1,[r0]
            orr r1,#GPIOG_EN

            // store content in r1 at address found in r0
            str r1,[r0]

            // set PG13 as output
            ldr r0,=GPIOG_MODER
            ldr r1,[r0]
            orr r1,#MODER13_OUT
            str r1,[r0]

            mov r1,#0
            ldr r2,=GPIOG_ODR

Blink:
            mov r1,#LED_ON
            str r1,[r2]
            ldr r3,=ONESEC
            bl  Delay

            mov r1,#LED_OFF
            str r1,[r2]
            ldr r3,=ONESEC
            bl  Delay

            b Blink

Delay:
            subs r3,r3,#1
            //branch if z flag is not equal to zero
            bne Delay
            bx  lr


            .align
            .end

/* The N, V, Z and C flags:
 N -> For checking for negative result

 V -> For indicating a signed overflow. Overflow occurs when: Addtion,
 subtraction or compare result is greater than 2^31 or less than -2^31

 Z -> For checking for zero result

 C -> For checking for result greater than 2^32 
 */