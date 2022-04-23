

/* To understand about this registers, see Cortex-M4 generic manual */
.equ NVIC_ST_CTRL_R,        0xE000E010
.equ NVIC_ST_RELOAD_R,      0xE000E014
.equ NVIC_ST_CURRENT_R,     0xE000E018

.equ SYSTICK_24BIT_MAX,     0x00FFFFFF
.equ ST_CTRL_EN,            (1<<0)
.equ ST_CTRL_CLKSRC,        (1<<2)
.equ ST_CTRL_COUNTFLAG,     (1<<16)

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

.equ DELAY1MS,               16000   
/* Default frequency = 16Mhz => 16.000.000 cycles/seconds 
   1 millisecond = 16 000
*/

            .syntax unified
            .cpu    cortex-m4
            .fpu    softvfp
            .thumb
            .section    .text
            .globl  __main

__main:
            bl  gpio_init
            bl  systick_init
loop:
            bl  gpio_blink
            b   loop

gpio_init:
            // Load address of RCC_AHB1ENR to r0
            ldr r0,=RCC_AHB1ENR
            ldr r1,[r0]
            orr r1,#GPIOG_EN
            str r1,[r0]

            // Set PG13 as output
            ldr r0,=GPIOG_MODER
            ldr r1,[r0]
            orr r1,#MODER13_OUT
            str r1,[r0]

            mov r1,#0
            ldr r2,=GPIO_BSRR

systick_init:
            /* Disable systick before configuration */
            ldr r1,=NVIC_ST_CTRL_R
            mov r0,#0
            str r0,[r1]

            /* Load maximum value into systick */
            ldr r1,=NVIC_ST_RELOAD_R
            ldr r0,=SYSTICK_24BIT_MAX
            str r0,[r1]

            /* Clear SYSTICK CURRENT VALUE register
            by writing any value into it */
            ldr r1,=NVIC_ST_CURRENT_R
            mov r0,#0
            str r0,[r1]

            /* Select internal clock source and enable Systick */
            ldr r0,=NVIC_ST_CTRL_R
            ldr r1,[r0]
            orr r1,#ST_CTRL_CLKSRC
            orr r1,#ST_CTRL_EN
            str r1,[r0]

            bx  lr

/* Takes number clock cycles to delay as argument r0 is argument register */
systick_delay:
            ldr r1,=NVIC_ST_RELOAD_R
            sub r0,#1
            str r0,[r1]
lp1:
            /* Check if timeout has occured */
            ldr r1,=NVIC_ST_CTRL_R
            ldr r3,[r1]
            ands    r3,r3,#ST_CTRL_COUNTFLAG
            beq lp1
            bx  lr 

systick_delay_ms:
            push    {r4, lr} /* Save current value of r4 and lr */
            movs    r4,r0
            beq     cmplt

lp2:
            ldr r0,=DELAY1MS
            bl  systick_delay
            subs    r4,r4,#1
            bhi lp2 /* if r4>0 delay another 1ms */

cmplt:
            pop     {r4,lr} /* Restore previous values of r4 and lr */
            bx      lr

gpio_blink:
            mov r1,#0
            ldr r2,=GPIO_BSRR
            mov r1,#BSRR_13_SET
            str r1,[r2]

            ldr r0,=500
            bl  systick_delay_ms

            mov r1,#0
            ldr r2,=GPIO_BSRR
            mov r1,#BSRR_13_RESET
            str r1,[r2]

            ldr r0,=500
            bl  systick_delay_ms

            b   gpio_blink


            .align
            .end


/* The N, V, Z and C flags:
 N -> For checking for negative result

 V -> For indicating a signed overflow. Overflow occurs when: Addtion,
 subtraction or compare result is greater than 2^31 or less than -2^31

 Z -> For checking for zero result

 C -> For checking for result greater than 2^32 
 */