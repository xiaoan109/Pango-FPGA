#include "system.h"
volatile uint32_t cnt;
uint32_t tmp;

//测试
int main()
{
    init_uart0_printf(115200,0);//设置printf波特率
    printf("SparrowRV SPI Flash\n");

    uint8_t nor25_id_data[3];
    fpioa_perips_in_set(SPI0_MISO, 4);//配置Flash必要引脚
    fpioa_perips_out_set(SPI0_MOSI, 5);
    fpioa_perips_out_set(SPI0_SCK, 6);
    fpioa_perips_out_set(SPI0_CS, 7);
    n25q_init(SPI0, 1);//初始化
    n25q_read_id(nor25_id_data, 3);//读取JEDEC ID

    while(1)
    {
        printf("Flash JEDEC ID = %x %x %x\n", nor25_id_data[0], nor25_id_data[1], nor25_id_data[2]);
    }
}
