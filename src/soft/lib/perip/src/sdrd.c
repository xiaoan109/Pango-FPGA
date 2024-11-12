#include "sdrd.h"


/*********************************************************************
 * @fn      sdrd_init_state_read
 *
 * @brief   读取SDRD的SD卡类型和初始化状态
 *
 * @return  [3:0]SD卡初始化状态，[5:4]SD卡类型，0=UNKNOWN, 1=SDv1, 2=SDv2, 3=SDHCv2
 */
uint8_t sdrd_init_state_read()
{
    return SYS_RWMEM_B(SDRD_BASE + 2);
}

/*********************************************************************
 * @fn      sdrd_busy_chk
 *
 * @brief   检查SDRD是否繁忙
 *
 * @return  1:繁忙，0:扇区访问结束
 */
uint8_t sdrd_busy_chk()
{
    return SYS_RWMEM_B(SDRD_BASE + 3);
}

/*********************************************************************
 * @fn      sdrd_buffer_read
 *
 * @brief   读取扇区数据缓冲区
 *
 * @param   addr - 缓冲区地址，有效区间[0,511]
 *
 * @return  缓冲区相应的字节
 */
uint8_t sdrd_buffer_read(uint32_t addr)
{
    return SYS_RWMEM_B(SDRD_BASE + (addr<<2));
}

/*********************************************************************
 * @fn      sdrd_sector_set
 *
 * @brief   设置当前访问的扇区，并将数据写入缓冲区
 *
 * @param   sector_number - 访问的扇区号
 *
 * @return  无
 */
void sdrd_sector_set(uint32_t sector_number)
{
    SYS_RWMEM_W(SDRD_BASE) = sector_number;
}
