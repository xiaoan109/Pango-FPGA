#include <stdint.h>
#include "core.h"

/*********************************************************************
 * @fn      mtime_value_get
 *
 * @brief   XXX
 *
 * @param   us - YYY
 *
 * @return  无
 */
uint64_t mtime_value_get()
{
    uint64_t temp;
    mtime_en_ctr(DISABLE);
    temp = read_csr(mtime);
    temp += (uint64_t)(read_csr(mtimeh)) << 32;
    mtime_en_ctr(ENABLE);
    return temp;
}

void mtime_value_set(uint64_t value64b)
{
    uint32_t temp;
    temp = value64b;
    write_csr(mtime, temp);
    temp = value64b>>32;
    write_csr(mtimeh, temp);
}

void mtime_en_ctr(uint8_t mtime_en)
{
    if(mtime_en == ENABLE)
        set_csr(mcctr, 0b00100);
    else
        clear_csr(mcctr, 0b00100);

}

void mtimecmp_value_set(uint64_t value64b)
{
    uint32_t temp;
    temp = value64b;
    write_csr(mtimecmp, temp);
    temp = value64b>>32;
    write_csr(mtimecmph, temp);
}



//使用mtime，会关闭定时器中断
void delay_mtime_us(uint32_t us)
{
    uint64_t count;
    mtime_en_ctr(DISABLE);//暂停定时器
    trap_en_ctrl(TRAP_TCMP, DISABLE);//关闭定时器中断
    count = us * system_cpu_freqM;//计算计数值
    mtimecmp_value_set(count);//设置比较值
    mtime_value_set(0);//设置定时器值
    mtime_en_ctr(ENABLE);//启动定时器
    while (!trap_mip_state(TRAP_TCMP));
}



void csr_msprint_string(uint8_t *str)
{
    while (*str)//检测字符串结束标志
    {
        write_csr(msprint, *str++);//msprint打印当前字符
    }
}
