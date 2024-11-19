#include "system.h"

//测试软件中断
int main()
{
    init_uart0_printf(115200,0);//设置printf波特率
    printf("%s", "Hello world SparrowRV\n");
    trap_global_ctrl(ENABLE);//打开全局中断
    trap_en_ctrl(TRAP_SOFT, ENABLE);//打开软件中断
    delay_mtime_us(1);//等待1us
    core_soft_interrupt();//触发软件中断
    delay_mtime_us(10);//等待10us
    printf("soft_trap=%lu\n",trap_mip_state(TRAP_SOFT));//软件已经响应了，返回0
}

