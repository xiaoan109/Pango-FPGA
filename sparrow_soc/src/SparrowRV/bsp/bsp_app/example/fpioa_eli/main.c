#include "system.h"
uint8_t cnt;
uint32_t tmp;
//测试
int main()
{
    init_uart0_printf(115200,0);//设置波特率
    printf("%s", "ELI CH0-4 lian jie dao FPIOA[0]\n");
    printf("%s", "--------------\n");
    fpioa_perips_in_set(ELI_CH0, 0);
    fpioa_perips_in_set(ELI_CH1, 0);
    fpioa_perips_in_set(ELI_CH2, 0);
    fpioa_perips_in_set(ELI_CH3, 0);
    fpioa_eli_mode_set(ELI_CH0_SEL, ELI_TRIG_HL, ENABLE);//高电平触发
    fpioa_eli_mode_set(ELI_CH1_SEL, ELI_TRIG_PE | ELI_TRIG_NE, ENABLE);//上升、下降沿触发
    fpioa_eli_mode_set(ELI_CH2_SEL, ELI_TRIG_LL, ENABLE);//低电平触发
    fpioa_eli_mode_set(ELI_CH3_SEL, ELI_TRIG_PE | ELI_TRIG_HL, ENABLE);//上升沿、高电平触发
    while(1)
    {
        delay_mtime_us(10);
    }
}
