#include "system.h"

uint8_t tmp;
uint32_t cnt;
uint8_t *str_buffer;
uint8_t *sd_unknow="Unknow";
uint8_t *sd_sdv1="SDv1";
uint8_t *sd_sdv2="SDv2";
uint8_t *sd_sdhc="SDHC";
//读取SD、TF卡的第0，第1扇区
int main()
{
    init_uart0_printf(115200,0);//设置波特率
    printf("%s", "Hello world SparrowRV\n");
    printf("%s", "--------------\n");
    while(sdrd_busy_chk());//等待启动完成
    tmp = sdrd_init_state_read();
    printf("SDRD state:0x%x \n", tmp);
    tmp = sdrd_busy_chk();
    printf("SDRD busy:0x%x \n", tmp);
    //读取扇区0
    sdrd_sector_set(0);
    delay_mtime_us(1);
    while(sdrd_busy_chk());
    printf("sector0 data:\n");
    cnt=0;
    for (cnt = 0; cnt < 512; ++cnt) {
        printf("%x ", sdrd_buffer_read(cnt));
    }
    printf("\n");
    //读取扇区1
    sdrd_sector_set(1);
    delay_mtime_us(1);
    while(sdrd_busy_chk());
    printf("sector1 0=%x\n", sdrd_buffer_read(0));
    printf("sector1 1=%x\n", sdrd_buffer_read(1));
    printf("sector1 5=%x\n", sdrd_buffer_read(5));

}
