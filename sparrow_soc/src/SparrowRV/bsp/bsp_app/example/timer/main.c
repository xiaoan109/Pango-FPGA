#include "system.h"
uint8_t cnt;
uint32_t tmp;
//启动定时器的比较输出和输入捕获
int main()
{
    init_uart0_printf(115200,0);//设置波特率
    printf("%s", "Timer cmp out and capture in\n");
    printf("%s", "--------------\n");
    fpioa_perips_out_set(TIMER0_CMPO_N, 10);
    fpioa_perips_out_set(TIMER0_CMPO_P, 11);
    fpioa_perips_in_set(TIMER0_CAPI, 1);
    timer_div_set(0);
    timer_cmpol_ctrl(1);
    timer_cmpval_set(10, 15);
    timer_overflow_set(20);
    timer_en_ctrl(ENABLE);
    timer_capi_trig(0, TIMER_TRIG_N);
    timer_capi_trig(1, TIMER_TRIG_D);
    delay_mtime_us(100);
    tmp = timer_cap_val_read();
    printf("capi0 = %u, capi1 = %u\n",(tmp&0x0000FFFF),(tmp>>16));
    tmp = timer_cnt_val_read();
    printf("timer cnt = %u\n",tmp);
    timer_en_ctrl(DISABLE);
}
