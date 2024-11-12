#include "uart.h"


/*********************************************************************
 * @fn      uart_enable_ctrl
 *
 * @brief   串口使能控制
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 * @param   uart_en - 串口使能选择位
 *            ENABLE  - 使能
 *            DISABLE - 关闭
 *
 * @return  无
 */
void uart_enable_ctrl(uint32_t UARTx, uint32_t uart_en)
{
    uint32_t tmp;
    tmp = SYS_RWMEM_W(UART_CTRL(UARTx));
    if(uart_en == ENABLE)
    {
        SYS_RWMEM_W(UART_CTRL(UARTx)) = tmp | 0b0011;
    }
    else
    {
        SYS_RWMEM_W(UART_CTRL(UARTx)) = tmp & 0b1100;
    }
}


/*********************************************************************
 * @fn      uart_band_ctrl
 *
 * @brief   串口波特率控制
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 * @param   uart_band - 写入所需的波特率值
 *
 * @return  无
 */
void uart_band_ctrl(uint32_t UARTx, uint32_t uart_band)
{
    SYS_RWMEM_W(UART_BAUD(UARTx)) = system_cpu_freq / uart_band ; //计算出分频器的值
}


/*********************************************************************
 * @fn      uart_send_date
 *
 * @brief   串口发送数据
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 * @param   uart_send - 需要发送的数据
 *
 * @return  无
 */
void uart_send_date(uint32_t UARTx, uint8_t uart_send)
{
    while (SYS_RWMEM_W(UART_STATUS(UARTx)) & 0x1); //等待上一个操作结束
    SYS_RWMEM_W(UART_TXDATA(UARTx)) = uart_send;
}

/*********************************************************************
 * @fn      uart_send_string
 *
 * @brief   串口发送数组
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 * @param   *str  - 指针指向数组首地址，0x00结束
 *
 * @return  无
 */
void uart_send_string(uint32_t UARTx, uint8_t *str)
{
    while (*str)//检测字符串结束标志
    {
        uart_send_date(UARTx, *str++);//发送当前字符
    }
}

/*********************************************************************
 * @fn      uart_recv_date
 *
 * @brief   串口接收数据
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 *
 * @return  返回接收到的数据
 */
uint8_t uart_recv_date(uint32_t UARTx)
{
    SYS_RWMEM_W(UART_STATUS(UARTx)) &= ~0x2;//清除接收标志
    return (SYS_RWMEM_W(UART_RXDATA(UARTx)) & 0xff);//返回串口接收到的数据
}


/*********************************************************************
 * @fn      uart_recv_flg
 *
 * @brief   串口接收状态查询
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 *
 * @return  如果接收缓冲区有数据，返回1；没有为0
 */
uint8_t uart_recv_flg(uint32_t UARTx)
{
    if (SYS_RWMEM_W(UART_STATUS(UARTx)) & 0x2)//有数据
    {
        return 1;
    }
    else//没有数据
    {
        return 0;
    }
}

/*********************************************************************
 * @fn      uart_irq_ctrl
 *
 * @brief   串口中断使能控制
 *
 * @param   UARTx - x可以为0,1 ，选择操作的串口，如UART0
 * @param   uart_irq_tr - 选择操作哪个中断使能
 *             UART_IRQ_TX - 操作发送完成中断使能
 *             UART_IRQ_RX - 操作接收数据中断使能
 * @param   uart_irq_en - 中断使能选择位
 *                 ENABLE  - 使能
 *                 DISABLE - 关闭
 *
 * @return  无
 */
void uart_irq_ctrl(uint32_t UARTx, uint32_t uart_irq_tr, uint32_t uart_irq_en)
{
    uint32_t tmp;
    tmp = SYS_RWMEM_W(UART_CTRL(UARTx));
    if(uart_irq_en == ENABLE)
    {
        tmp = tmp | (1 << uart_irq_tr);
    }
    else
    {
        tmp = tmp & (~(1 << uart_irq_tr));
    }
    SYS_RWMEM_W(UART_CTRL(UARTx)) = tmp;
}
