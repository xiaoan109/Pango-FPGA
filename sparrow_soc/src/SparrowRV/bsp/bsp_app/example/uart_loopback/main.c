#include "system.h"

//串口环回
int main()
{
    init_uart0_printf(115200,0);//设置printf波特率，FPIOA[1]为RX
    printf("SparrowRV uart loopback\n");
    fpioa_perips_in_set(UART0_RX, 0);//FPIOA[0]为RX
    while(1)
    {
        if(uart_recv_flg(UART0))
            uart_send_date(UART0, uart_recv_date(UART0));
    }
}
