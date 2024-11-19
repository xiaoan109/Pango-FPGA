#include "system.h"


//测试
void main()
{
    uint32_t tmp;
    init_uart0_printf(115200,0);//设置printf波特率

    //通过NIO，让fpioa[2]输出1，fpioa[3]输出0
    printf("fpioa[3:2]set as push-pull mode\n");
    fpioa_perips_in_set(NIO, 2);
    fpioa_perips_in_set(NIO, 3);
    printf("fpioa[2] set as High, fpioa[3] set as Low\n");
    fpioa_nio_mode_write(NIO_2 | NIO_3, NIO_MODE_OE_PP);
    fpioa_nio_dout_write(0x4);

    //读取fpioa的输入
    printf("read all fpioa input value\n");
    tmp = fpioa_nio_din_read();
    printf("fpioa input value = %lb\n",tmp);
}
