

.equ RCC_BASE,              0x40023800
.equ AHB1ENR_OFFSET,        0x30
.equ APB2ENR_OFFSET,        0x44

.equ RCC_AHB1ENR,           (RCC_BASE + AHB1ENR_OFFSET)
.equ GPIOG_BASE,            0x40021800

.equ RCC_APB2ENR,           (RCC_BASE + APB2ENR_OFFSET)

// ADC registers
.equ ADC1_BASE,             0x40012000

.equ ADC1_CR2_OFFSET,       0x08
.equ ADC1_CR2,              (ADC1_BASE + ADC1_CR2_OFFSET)
.equ ADC1_CR2_ON,           (1<<0)
.equ ADC1_CR2_SWSTART,      (1<<30)

.equ ADC1_SQR3_OFFSET,      0x34
.equ ADC1_SQR3,             (ADC1_BASE + ADC1_SQR3_OFFSET)
.equ SQR3_CNF,              1   // Conversion sequence starts at ch1

.equ ADC1_SQR1_OFFSET,      0x2C
.equ ADC1_SQR1,             (ADC1_BASE + ADC1_SQR1_OFFSET)
.equ SQR1_CNF,              0   // Conversion sequence length to ch1

.equ ADC1_SR_OFFSET,        0x00
.equ ADC1_SR,               (ADC1_BASE + ADC1_SR_OFFSET)
.equ ADC1_SR_EOC,           (1<<1)

.equ ADC1_DR_OFFSET,        0x4C
.equ ADC1_DR,               (ADC1_BASE + ADC1_DR_OFFSET)

.equ GPIO_MODER_OFFSET,     0x00
.equ GPIOG_MODER,           (GPIOG_BASE + GPIO_MODER_OFFSET)

.equ GPIO_BSRR_OFFSET,      0x18
.equ GPIO_BSRR,             (GPIOG_BASE + GPIO_BSRR_OFFSET)

.equ GPIOA_BASE,            0x40020000
.equ GPIOA_MODER,           (GPIOA_BASE + GPIO_MODER_OFFSET)

.equ IDR_OFFSET,            0x10
.equ GPIOA_IDR,             (GPIOA_BASE + IDR_OFFSET)

.equ GPIOA_EN,              (1<<0)
.equ GPIOA_MODER_ADC,       0xC //0xC=1100

.equ ADC1_EN,               (1<<8)

.equ GPIOG_EN,              (1<<6)
.equ MODER13_OUT,           (1<<26)

.equ BSRR_13_SET,           (1<<13)
.equ BSRR_13_RESET,         (1<<29)

.equ ONESEC,                5333333

.equ SENS_THRESH,           3000

// Active low switch
.equ BTN_ON,                0x0000
.equ BTN_OFF,               0x0001
.equ BTN_PIN_0,             0x0001



            .syntax unified
            .cpu    cortex-m4
            .fpu    softvfp
            .thumb
            .section    .text
            .globl  adc_init
            .globl  adc_read
            .globl  led_init
            .globl  turn_led_on
            .globl  turn_led_off
            .globl  led_control

adc_init:
            /*  1 - Enable clock access to ADC pin's GPIO port */
            ldr r0,=RCC_AHB1ENR
            ldr r1,[r0]
            orr r1,#GPIOA_EN
            str r1,[r0]

            /*  2 - Set ADC pin, PA1 as analog pin */
            ldr r0,=GPIOA_MODER
            ldr r1,[r0]
            orr r1,#GPIOA_MODER_ADC
            str r1,[r0]

            /*  3 - Enable clock to ADC123_1 */
            ldr r0,=RCC_APB2ENR
            ldr r1,[r0]
            orr r1,#ADC1_EN
            str r1,[r0]

            /*  4 - Select software trigger */
            ldr r0,=ADC1_CR2
            ldr r1,=0x00000000
            str r1,[r0]

            /*  5 - Set conversion sequence starting channel */
            /*  ADC->SQR3 = 1*/
            ldr r0,=ADC1_SQR3
            ldr r1,=#SQR3_CNF
            str r1,[r0]

            /*  6 - Set conversion sequence length */
            /* ADC1->SQR1 = 0 */
            ldr r0,=ADC1_SQR1
            ldr r1,=#SQR1_CNF
            str r1,[r0]

            /*  7 - Enable adc module */
            /*  ADC1->CR2 |= (1<<0) */
            ldr r0,=ADC1_CR2
            ldr r1,[r0]
            orr r1,#ADC1_CR2_ON
            str r1,[r0]  

adc_read:
            /*  1 - Start conversion */
            /*  ADC1->CR2 |= (1<<30) */
            ldr r0,=ADC1_CR2
            ldr r1,[r0]
            orr r1,#ADC1_CR2_SWSTART
            str r1,[r0]

            /*  2 - Wait for conversion to be complete */
lp1:
            ldr r0,=ADC1_SR
            ldr r1,[r0]
            and r1,#ADC1_SR_EOC
            cmp r1,#0x00
            beq lp1

            /*  3 - Read content of ADC data register  */
            ldr r2,=ADC1_DR
            ldr r0,[r2]
            bx  lr

led_init:
            /* Enable clock to GPIOG */
            ldr r0,=RCC_AHB1ENR
            ldr r1,[r0]
            orr r1,#GPIOG_EN
            str r1,[r0]

            /* Set GPIOG as output pin */
            ldr r0,=GPIOG_MODER
            ldr r1,[r0]
            orr r1,#MODER13_OUT
            str r1,[r0]
            bx  lr

led_control:
            ldr r1,=SENS_THRESH
            cmp r0,r1
            bgt turn_led_on
            blt turn_led_off
            bx lr

turn_led_on:
            ldr r5,=GPIO_BSRR
            mov r1,#BSRR_13_SET
            str r1,[r5]
            bx  lr

turn_led_off:
            ldr r5,=GPIO_BSRR
            mov r1,#BSRR_13_RESET
            str r1,[r5]
            bx  lr

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