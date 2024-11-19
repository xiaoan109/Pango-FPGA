#include "system.h"
/*
在FPIOA[4]输出串口UART1，让FPIOA_ELI、UART0/1_RX接收，SPI收发一次，定时器溢出一次，产生中断信号
建议在仿真环境下观察
*/
uint32_t tmp;

int main()
{
    init_uart0_printf(115200,0);//设置波特率
    printf("%s", "Hello world SparrowRV\n");
    printf("%s", "--------------\n");
    //布置硬件
    fpioa_perips_out_set(UART1_TX, 4);//FPIOA[4]是UART1_TX端口
    fpioa_perips_in_set(ELI_CH0, 4);
    fpioa_perips_in_set(ELI_CH1, 4);
    fpioa_perips_in_set(ELI_CH2, 4);
    fpioa_perips_in_set(ELI_CH3, 4);
    fpioa_perips_in_set(UART1_RX, 4);
    fpioa_perips_in_set(UART0_RX, 4);
    //打开每个外设的中断
    timer_of_irq_ctrl(ENABLE);//使能定时器溢出中断
    uart_irq_ctrl(UART0, UART_IRQ_RX, ENABLE);//使能UART0接收数据中断
    uart_irq_ctrl(UART1, UART_IRQ_TX, ENABLE);//使能UART1发送完成中断
    uart_irq_ctrl(UART1, UART_IRQ_RX, ENABLE);//使能UART1接收数据中断
    spi_irq_ctrl(SPI0, ENABLE);//使能SPI中断
    fpioa_eli_mode_set(ELI_CH0_SEL, ELI_TRIG_NE, ENABLE);//ELI_CH0，高电平触发
    fpioa_eli_mode_set(ELI_CH1_SEL, ELI_TRIG_LL, ENABLE);//ELI_CH1，低电平触发
    fpioa_eli_mode_set(ELI_CH2_SEL, ELI_TRIG_PE, ENABLE);//ELI_CH2，上升沿触发
    fpioa_eli_mode_set(ELI_CH3_SEL, ELI_TRIG_NE | ELI_TRIG_PE, ENABLE);//ELI_CH3，双边沿触发
    //配置PLIC
    //plic_ie_set(PLIC1_FPIOA_ELI0_ID, ENABLE);
    SYS_RWMEM_W(PLIC_IE) = 0xFFFFFFFF;//PLIC使能所有中断源
    plic_source_priority_set(PLIC1_FPIOA_ELI0_ID, 1);
    plic_source_priority_set(PLIC2_FPIOA_ELI1_ID, 0);
    plic_source_priority_set(PLIC3_FPIOA_ELI2_ID, 1);
    plic_source_priority_set(PLIC4_FPIOA_ELI3_ID, 1);
    plic_source_priority_set(PLIC5_UART0_TX_ID, 1);
    plic_source_priority_set(PLIC6_UART0_RX_ID, 1);
    plic_source_priority_set(PLIC7_UART1_TX_ID, 1);
    plic_source_priority_set(PLIC8_UART1_RX_ID, 3);
    plic_source_priority_set(PLIC9_TIMER0_OF_ID, 1);
    plic_source_priority_set(PLIC10_SPI0_END_ID, 2);
    //产生中断
    timer_div_set(0);//定时器分频0
    timer_overflow_set(10);//溢出值10
    timer_en_ctrl(ENABLE);//启动定时器
    spi_sclk_div(SPI0, 0);//SPI0分频0
    spi_cp_model(SPI0, SPI_CP_MODEL_0);//SPI0相位模式0
    uart_band_ctrl(UART1, 25000000);
    uart_enable_ctrl(UART1, ENABLE);
    uart_send_date(UART1, 0x80);
    delay_mtime_us(100);
    spi_sdrv_byte(SPI0, 56);//SPI发一次
    timer_en_ctrl(DISABLE);//关闭定时器
    delay_mtime_us(1);
    plic_ith_set(0);
    trap_global_ctrl(ENABLE);//打开全局中断
    trap_en_ctrl(TRAP_EXTI, ENABLE);//打开软件中断
    delay_mtime_us(500);
}
