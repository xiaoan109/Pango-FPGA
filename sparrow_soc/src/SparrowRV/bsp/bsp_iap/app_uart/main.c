#include "system.h"
/*
IAP - 从UART启动
IAP程序在iram低地址，上电后首先执行，通过串口以Xmodem协议传入文件。
默认115200波特率
FPIOA[0]-UART0_Tx
FPIOA[1]-UART0_Rx
仅支持Xmodem 128字节包 累加和校验
3秒超时

参考资料
https://zhuanlan.zhihu.com/p/349921713
https://www.23bei.com/tool/8.html
*/
#define UART0_BAND 115200   //uart0波特率
#define APP_BASE_ADDR (1 * 1024)
//#define IAP_DBG_MODE 1 //debug模式
#define SDRD_DATA(baddr)  SYS_RWMEM_B(sdrd_base_addr + ((baddr)*4))//直接访问SDRD

//全局变量
uint32_t sdrd_base_addr = SDRD_BASE;//SDRD外设基地址
uint32_t uart0_band_val;//uart0波特率分频系数
uint32_t app_base_addr = APP_BASE_ADDR;//程序指针

//MBR
#define MBR_PTE_Sector4 454 //小端存储的分区起始扇区号位置
#define MBR_Sector_NUM4 458 //小端存储的分区的扇区数
uint32_t fat_base_sector;//第一个fat分区起始扇区号
uint32_t fat_sector_number;//第一个fat分区的扇区数，容量(字节)=扇区数*512
uint32_t fat_byte_length;//第一个fat分区的大小(字节)
//fat分区起始
#define FATH_BPS2 11//每扇区的字节数
#define FATH_SPC1 13//每簇的扇区数
#define FATH_FSS2 14//FAT保留扇区数
#define FATH_FTN1 16//FAT表个数
#define FATH_FUS4 28//FAT分区前已使用的扇区数
#define FATH_FTS4 36//每个FAT表的扇区数
uint32_t byte_per_sec;//每扇区的字节数
uint32_t sec_per_clus;//每簇的扇区数
uint32_t fat_save_sector;//FAT保留扇区数
uint32_t fat_tab_number;//FAT表个数
uint32_t fat_used_sector;//FAT分区前已使用的扇区数
uint32_t fat_tab_sector;//每个FAT表的扇区数
uint32_t fat_data_sector;//fat数据区的起始扇区号 = FAT分区前已使用的扇区数 + FAT保留扇区数 + FAT表个数 * 每个FAT表的扇区数
//fat数据区的目录项偏移
#define FATD_FBC_0 26//文件起始簇号[0]
#define FATD_FBC_1 27//文件起始簇号[1]
#define FATD_FBC_2 20//文件起始簇号[2]
#define FATD_FBC_3 21//文件起始簇号[3]
#define FATD_FLB4 28//文件大小(字节)
uint32_t file_FDT_base=0;//FAT32目录项基地址
uint32_t file_base_clus;//文件起始簇号
uint32_t file_length_byte;//文件大小(字节)
uint32_t file_base_sector;//文件起始扇区号 = 数据区的起始扇区号 + (文件起始簇号-2)*每簇的扇区数


uint32_t i,j;
uint8_t u8tmp0,u8tmp1;

void set_sdrd_sector(uint32_t sector_num);
uint32_t read_mem_4byte(uint32_t start_addr);

int main()
{
    uint32_t tmp;
#ifdef IAP_DBG_MODE
    init_uart0_printf(115200,0);//设置波特率
#endif
    tmp = read_csr(mimpid);
    uart0_band_val = ((tmp & 0x00007FFF) * 10000) / UART0_BAND;//计算波特率分频系数
    tmp = UART_BASE;
    SYS_RWMEM_W(tmp) = 0b0011;//开启UART0
    SYS_RWMEM_W(tmp + 0x08) = uart0_band_val;//设置波特率分频系数
    SYS_RWMEM_B(FPIOA_OT_BASE + 0) = UART0_TX;//UART0_TX->FPIOA0

    //等待初始化
    uart_send_string(UART0, "IAP Wait SD Init...  ");
    while(SYS_RWMEM_B(SDRD_BASE+3) == (uint8_t)0x01);//等待启动完成，等效于while(sdrd_busy_chk());
#ifdef IAP_DBG_MODE
    tmp = sdrd_init_state_read();
    printf("SDRD state:0x%x \n", tmp);//SD卡版本
#endif

    //读取MBR
    set_sdrd_sector(0);//扇区0
    fat_base_sector = read_mem_4byte(MBR_PTE_Sector4);//第一个fat分区的起始扇区
#ifdef IAP_DBG_MODE
    fat_sector_number = SDRD_DATA(MBR_Sector_NUM4+0)\
            + (SDRD_DATA(MBR_Sector_NUM4+1)<<8)\
            + (SDRD_DATA(MBR_Sector_NUM4+2)<<16)\
            + (SDRD_DATA(MBR_Sector_NUM4+3)<<24);//分区的扇区数
    fat_byte_length = fat_sector_number/2048;//第一个fat分区的大小(字节)
    printf("fat_base_sector:%lu\n", fat_base_sector);//第一个fat分区的起始扇区
    printf("fat_byte_length:%lu MiB\n", fat_byte_length);//分区的大小(字节)
#endif

    //读取FAT分区的起始扇区
    set_sdrd_sector(fat_base_sector);//访问扇区，FAT起始
    byte_per_sec = SDRD_DATA(FATH_BPS2)+(SDRD_DATA(FATH_BPS2+1)<<8);//每扇区的字节数
    sec_per_clus = SDRD_DATA(FATH_SPC1);//每簇的扇区数
    fat_save_sector = SDRD_DATA(FATH_FSS2)+(SDRD_DATA(FATH_FSS2+1)<<8);//FAT保留扇区数
    fat_tab_number = SDRD_DATA(FATH_FTN1);//FAT表个数
    fat_used_sector = read_mem_4byte(FATH_FUS4);//FAT分区前已使用的扇区数
    fat_tab_sector = read_mem_4byte(FATH_FTS4);//每个FAT表的扇区数
    fat_data_sector = fat_used_sector + fat_save_sector + fat_tab_number*fat_tab_sector;//fat数据区的起始扇区号 = FAT分区前已使用的扇区数 + FAT保留扇区数 + FAT表个数 * 每个FAT表的扇区数
#ifdef IAP_DBG_MODE
    printf("fat_data_sector:%lu\n", fat_data_sector);//fat数据区的起始扇区
#endif

    //FAT数据区
    set_sdrd_sector(fat_data_sector);//访问扇区，FAT数据区
    //32字节一个表项，offset[0x00]!=0xE5且offset[0x0B]==0x20，是有效文件，一个个检索
    while (file_FDT_base < 512)
    {
        file_FDT_base = file_FDT_base +32;//跳到下一目录项
        u8tmp0 = SDRD_DATA(file_FDT_base);//读offset[0x00]
        u8tmp1 = SDRD_DATA(file_FDT_base+0x0B);//读offset[0x0B]
        if (u8tmp0!=0xE5 && u8tmp1==0x20)//当前目录项有效且为文件
        {
            break;
        }
    }
    if(file_FDT_base>=512)//没有找到文件
    {
        uart_send_string(UART0, "Can't Find File in SD\n");
        while(1);
    }
    file_base_clus = SDRD_DATA(file_FDT_base+FATD_FBC_0)\
            +(SDRD_DATA(file_FDT_base+FATD_FBC_1)<<8)\
            +(SDRD_DATA(file_FDT_base+FATD_FBC_2)<<16)\
            +(SDRD_DATA(file_FDT_base+FATD_FBC_3)<<24);//文件起始簇号
    file_length_byte = read_mem_4byte(file_FDT_base+FATD_FLB4);//文件大小(字节)
    file_base_sector = fat_data_sector + (file_base_clus-2)*sec_per_clus;//文件起始扇区号 = 数据区的起始扇区号 + (文件起始簇号-2)*每簇的扇区数
#ifdef IAP_DBG_MODE
    printf("file_base_clus:%lu\n", file_base_clus);
    printf("sec_per_clus:%lu\n", sec_per_clus);
    printf("file_base_sector:%lu\n", file_base_sector);//文件的起始扇区
    printf("file_length_byte:%lu\n", file_length_byte);//文件的长度
#endif

    //文件区
    i = file_length_byte / 512;
    i++;//i为APP占据的扇区数
    while(i)
    {
        set_sdrd_sector(file_base_sector);//访问扇区
        file_base_sector++;//扇区+1
        i--;
        for(j=0; j<512; ++j)//读出数据
        {
            SYS_RWMEM_B(app_base_addr) = SDRD_DATA(j);
            app_base_addr++;
        }
    }
#ifdef IAP_DBG_MODE
    printf("inst 1024:0x%x\n", SYS_RWMEM_W(1024));
    printf("inst 1024+4:0x%x\n", SYS_RWMEM_W(1024+4));
#endif
    //跳转到APP
    uart_send_string(UART0, "Load APP Success\n");
    asm volatile (
        "jr %[app_sa]"
        :
        :[app_sa]"rm"(APP_BASE_ADDR)
    );
}

//设置当前访问的扇区
void set_sdrd_sector(uint32_t sector_num)
{
    SYS_RWMEM_W(SDRD_BASE) = sector_num;//访问扇区
    while(SYS_RWMEM_B(SDRD_BASE+3) == (uint8_t)0x01);//等待结束访问，等效于while(sdrd_busy_chk());
}

//访问SDRD连续4个字节，小端读取为32bit数
uint32_t read_mem_4byte(uint32_t start_addr)
{
    uint32_t tmp;
    tmp = SDRD_DATA(start_addr)+(SDRD_DATA(start_addr+1)<<8)+(SDRD_DATA(start_addr+2)<<16)+(SDRD_DATA(start_addr+3)<<24);
    return tmp;
}
