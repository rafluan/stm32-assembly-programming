#include <stdio.h>

extern void uart_init(void);
extern void uart_outchar(int ch);

int _write(int file, char *ptr, int len)
{
    int i = 0;
    for(i=0; i<len; i++)
        uart_outchar((*ptr++));
    return len;
}

int main()
{
    uart_init();

    while (1)
    {
     //   uart_outchar('1');
       printf("Hello from STM32 UART Driver \n\r");
    }
}