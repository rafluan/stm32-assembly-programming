

.equ RCC_BASE,              0x40023800
.equ AHB1ENR_OFFSET,        0x30

.equ RCC_AHB1ENR,           (RCC_BASE + AHB1ENR_OFFSET)      
.equ GPIOG_BASE,            0x40021800

.equ GPIO_MODER_OFFSET,     0x00
.equ GPIOG_MODER,           (GPIOG_BASE + GPIO_MODER_OFFSET)

.equ GPIO_BSRR_OFFSET,      0x18
.equ GPIO_BSRR,             (GPIOG_BASE + GPIO_BSRR_OFFSET)

.equ GPIOA_BASE,            0x40020000
.equ GPIOA_MODER,           (GPIOA_BASE + GPIO_MODER_OFFSET)

.equ IDR_OFFSET,            0x10
.equ GPIOA_IDR,             (GPIOA_BASE + IDR_OFFSET)

.equ GPIOA_EN,              (1<<0)

.equ GPIOG_EN,              (1<<6)
.equ MODER13_OUT,           (1<<26)

.equ BSRR_13_SET,           (1<<13)
.equ BSRR_13_RESET,         (1<<29)

.equ ONESEC,                5333333

// Active low switch
.equ BTN_ON,                0x0000
.equ BTN_OFF,               0x0001
.equ BTN_PIN_0,             0x0001


            .syntax unified
            .cpu    cortex-m4
            .fpu    softvfp
            .thumb
            .section    .text
            .globl  __main

__main:
            bl  gpio_init

loop:
            bl get_input
            cmp r0,#BTN_ON
            beq turn_led_on
            cmp r0,#BTN_OFF
            beq turn_led_off
            b   loop

turn_led_on:
            mov r1,#0
            ldr r2,=GPIO_BSRR
            mov r1,#BSRR_13_SET
            str r1,[r2]
            b   loop

turn_led_off:
            mov r1,#0
            ldr r2,=GPIO_BSRR
            mov r1,#BSRR_13_RESET
            str r1,[r2]
            b   loop

get_input:
            ldr r1,=GPIOA_IDR
            ldr r0,[r1]
            and r0,r0,#BTN_PIN_0
            bx  lr

gpio_init:
            /* Set PG13 as output pin */
            
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

            /* Set PA0 as input pin */

            // load address of RCC_AHB1ENR to r0
            ldr r0,=RCC_AHB1ENR

            // load value at address found in r0 into r1
            ldr r1,[r0]
            orr r1,#GPIOA_EN

            // store content in r1 at address found in r0
            str r1,[r0]
            bx lr
stop:
            b   stop
            .align
            .end

/* The N, V, Z and C flags:
 N -> For checking for negative result

 V -> For indicating a signed overflow. Overflow occurs when: Addtion,
 subtraction or compare result is greater than 2^31 or less than -2^31

 Z -> For checking for zero result

 C -> For checking for result greater than 2^32 
 */