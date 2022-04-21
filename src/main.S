

.equ RCC_BASE,              0x40023800
.equ AHB1ENR_OFFSET,        0x30

.equ RCC_AHB1ENR,           (RCC_BASE + AHB1ENR_OFFSET)      

.equ GPIOA_BASE,            0x40020000
.equ GPIOG_BASE,            0x40021800

.equ APB2ENR_OFFSET,        0x44
.equ RCC_APB2ENR,           (RCC_BASE + APB2ENR_OFFSET)

.equ USART_BRR_OFFSET,      0x08

.equ USART1_BASE,           0x40011000
.equ USART1_BRR,            (USART1_BASE + USART_BRR_OFFSET)

.equ USART_CR1_OFFSET,      0x0C
.equ USART1_CR1,            (USART1_BASE + USART_CR1_OFFSET)
.equ USART1_CR1_TE,         0x8 /* Enable TX, 8-bit data */
.equ USART1_CR1_EN,         (1<<13)

.equ USART_CR2_OFFSET,      0x10
.equ USART1_CR2,            (USART1_BASE + USART_CR2_OFFSET)
.equ USART1_CR2_ADD,        0x0000 /* 1 Stop bit */

.equ USART_CR3_OFFSET,      0x14
.equ USART1_CR3,            (USART1_BASE + USART_CR3_OFFSET)
.equ USART1_CR3_EIE,        0x0000  /* No flow control */

.equ USART_SR_OFFSET,       0x00
.equ USART1_SR,             (USART1_BASE + USART_SR_OFFSET)
.equ USART1_SR_TXE,         (1<<7)

.equ USART_DR_OFFSET,       0x04
.equ USART1_DR,             (USART1_BASE + USART_DR_OFFSET)

.equ USART1_EN,             (1<<4)

.equ GPIOA_EN,              (1<<0)
.equ GPIOG_EN,              (1<<6)

//.equ UART1_PA9_TX
//.equ UART1_PA10_RX


.equ GPIO_MODER_OFFSET,     0x00
.equ GPIOG_MODER,           (GPIOG_BASE + GPIO_MODER_OFFSET)

.equ GPIO_BSRR_OFFSET,      0x18
.equ GPIO_BSRR,             (GPIOG_BASE + GPIO_BSRR_OFFSET)

.equ GPIOA_MODER,           (GPIOA_BASE + GPIO_MODER_OFFSET)

.equ MODER9_ALT_FUNC,       (1<<19)
.equ MODER10_ALT_FUNC,      (1<<21)

.equ GPIO_AFRH_OFFSET,      0x24   
.equ GPIOA_AFRL,            (GPIOA_BASE + GPIO_AFRH_OFFSET) 

.equ GPIO9_AFRH_F7,         0x70

.equ BAUDRATE_CFG,          0x683   //0x683 = 1667, to set 9600 baudrate with clock of @16Mhz (16Mhz/1667)

.equ MODER13_OUT,           (1<<26)

.equ BSRR_13_SET,           (1<<13)
.equ BSRR_13_RESET,         (1<<29)




            .syntax unified
            .cpu    cortex-m4
            .fpu    softvfp
            .thumb
            .section    .text
            .globl  __main

__main:
            bl  uart_init

loop:
            /* Test send a single Character */
            mov r0,#'Y'
            bl  uart_outchar

            mov r0,#'E'
            bl  uart_outchar

            mov r0,#'S'
            bl  uart_outchar

            b   loop

uart_init:
            /* 1 - Enable clock access to UART GPIO pins */
            ldr r0,=RCC_AHB1ENR
            ldr r1,[r0]
            orr r1,#GPIOA_EN
            str r1,[r0]

            /* 2 - Set UART gpio pin mode to alternative functions */
            ldr r0,=GPIOA_MODER
            ldr r1,[r0]
            bic r1,#0xC0000 // Bit clear
            str r1,[r0]

            ldr r0,=GPIOA_MODER
            ldr r1,[r0]
            orr r1,#MODER9_ALT_FUNC // Bit set
            str r1,[r0]

            /* 3 - Set UART gpio pin alternative function type to UART */
            ldr r0,=GPIOA_AFRL
            ldr r1,[r0]
            bic r1,#0xF0 // Clear bit
            str r1,[r0]

            ldr r0,=GPIOA_AFRL
            ldr r1,[r0]
            orr r1,#GPIO9_AFRH_F7 // Set bit
            str r1,[r0]

            /* 4 - Enable clock access to USART1 module */
            ldr r0,=RCC_APB2ENR
            ldr r1,[r0]
            orr r1,#USART1_EN
            str r1,[r0]

            /* 5 - Set UART baudrate */
            ldr r0,=USART1_BRR
            mov r1,#BAUDRATE_CFG
            str r1,[r0]

            /* 6 - Configure control register 1 */
            ldr r0,=USART1_CR1
            mov r1,#USART1_CR1_TE
            str r1,[r0]

            /* 7 - Configure control register 2 */
            ldr r0,=USART1_CR2
            mov r1,#USART1_CR2_ADD
            str r1,[r0]

            /* 8 - Configure control register 3 */
            ldr r0,=USART1_CR3
            mov r1,#USART1_CR3_EIE
            str r1,[r0]

            /* 9 - Enable UART module */
            ldr r0,=USART1_CR1
            ldr r1,[r0]
            orr r1,#USART1_CR1_EN
            str r1,[r0]

            bx  lr

uart_outchar:
            /* 1 - Make sure UART transmit fifo is not full */
            ldr r1,=USART1_SR

lp2:
            ldr r2,[r1]
            and r2,#USART1_SR_TXE
            cmp r2,#0x00
            beq lp2

            /* 2 - Write data into uart data register */
            mov r1,r0   /* Character to be sent is placed in r0 */
            ldr r2,=USART1_DR
            str r1,[r2]
            bx  lr
            
            .align
            .end

 // ************************************ele usa pa2 e pa3

/* The N, V, Z and C flags:
 N -> For checking for negative result

 V -> For indicating a signed overflow. Overflow occurs when: Addtion,
 subtraction or compare result is greater than 2^31 or less than -2^31

 Z -> For checking for zero result

 C -> For checking for result greater than 2^32 
 */