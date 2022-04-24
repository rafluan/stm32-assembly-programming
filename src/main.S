

.equ RCC_BASE,              0x40023800
.equ AHB1ENR_OFFSET,        0x30

.equ RCC_AHB1ENR,           (RCC_BASE + AHB1ENR_OFFSET)      
.equ GPIOG_BASE,            0x40021800

.equ GPIO_MODER_OFFSET,     0x00
.equ GPIOG_MODER,           (GPIOG_BASE + GPIO_MODER_OFFSET)

.equ GPIO_BSRR_OFFSET,      0x18
.equ GPIO_BSRR,             (GPIOG_BASE + GPIO_BSRR_OFFSET)

.equ GPIOG_EN,              (1<<6)
.equ MODER13_OUT,           (1<<26)

.equ BSRR_13_SET,           (1<<13)
.equ BSRR_13_RESET,         (1<<29)

// Timer 1 settings
.equ APB2ENR_OFFSET,        0x44
.equ RCC_APB2ENR,           (RCC_BASE + APB2ENR_OFFSET)
.equ TIM1_EN,               (1<<0)

.equ TIM1_BASE,             0x40010000

.equ TIM_CR1_OFFSET,        0x00
.equ TIM1_CR1,              (TIM1_BASE + TIM_CR1_OFFSET)
.equ TIM1_COUNTER_EN,       (1<<0)

.equ TIM_SR_OFFSET,         (0x10)
.equ TIM1_SR,               (TIM1_BASE + TIM_SR_OFFSET)
.equ TIM1_SR_UID,           (1<<0)

.equ TIM_PSC_OFFSET,        0x28
.equ TIM1_PSC,              (TIM1_BASE + TIM_PSC_OFFSET)

.equ TIM_ARR_OFFSET,        0x2C
.equ TIM1_ARR,              (TIM1_BASE + TIM_ARR_OFFSET)

.equ TIM_CNT_OFFSET,        0x24
.equ TIM1_CNT,              (TIM1_BASE + TIM_CNT_OFFSET)


            .syntax unified
            .cpu    cortex-m4
            .fpu    softvfp
            .thumb
            .section    .text
            .globl  __main

__main:
            bl  gpio_init
            bl  tim1_1hz_init

            bl  led_blink

tim1_1hz_init: 

            /* 1 - Enable clock access to TIM1 */
            ldr r0,=RCC_APB2ENR
            ldr r1,[r0]
            orr r1,#TIM1_EN
            str r1,[r0]

            /* 2 - Set prescaler value */
            ldr r0,=TIM1_PSC
            mov r1,#(1600-1) /* Divide 16.000.000 by 1.600 = 10.000 */
            str r1,[r0]

            /* 3 - Set the auto-reload value */
            ldr r0,=TIM1_ARR
            mov r1,#(10000-1) /* Divide 10.000 by 10.000 */
            str r1,[r0]

            /* 4 - Clear time counter */
            ldr r0,=TIM1_CNT
            mov r1,#0
            str r1,[r0]

            /* 5 - Enable timer */
            ldr r0,=TIM1_CR1
            mov r1,#TIM1_COUNTER_EN
            str r1,[r0]
            bx  lr

__wait:
            /* Wait for UIF flag to be set */
            ldr r1,=TIM1_SR

lp1:
            ldr r2,[r1] /* while(!(TIM1->SR & (1u<<0))){}*/
            and r2,#TIM1_SR_UID
            cmp r2,#0x00
            beq lp1

            /* Clear UIF*/
            ldr r3,[r1]
            bic r3,r3,#TIM1_SR_UID
            str r3,[r1]

            bx lr

led_blink:
            ldr r4,=GPIO_BSRR
            mov r1,#BSRR_13_SET
            str r1,[r4]
            bl  __wait

            ldr r4,=GPIO_BSRR
            mov r1,#BSRR_13_RESET
            str r1,[r4]
            bl  __wait

            bl led_blink

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

            bx lr

            .align
            .end

/* The N, V, Z and C flags:
 N -> For checking for negative result

 V -> For indicating a signed overflow. Overflow occurs when: Addtion,
 subtraction or compare result is greater than 2^31 or less than -2^31

 Z -> For checking for zero result

 C -> For checking for result greater than 2^32 
 */