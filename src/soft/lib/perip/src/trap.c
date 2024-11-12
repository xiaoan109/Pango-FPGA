#include "trap.h"


/*********************************************************************
 * @fn      trap_global_ctrl
 *
 * @brief   全局中断使能设置
 *
 * @param   en - 状态选择位
 *            ENABLE - 打开全局中断
 *            DISABLE - 屏蔽全局中断
 *
 * @return  0 - 设置失败
 *          1 - 设置成功
 */
uint8_t trap_global_ctrl(uint8_t en)
{
    if(en==ENABLE)
    {
        __asm__ __volatile__ (
        "csrrsi x0, mstatus, 0b01000");
    }
    else
    {
        __asm__ __volatile__ (
        "csrrci x0, mstatus, 0b01000");
    }
    return 1;
}
/*********************************************************************
 * @fn      trap_en_ctrl
 *
 * @brief   3种中断使能设置
 *
 * @param   sel - 选择设置对象
 *            TRAP_SOFT - 软件中断
 *            TRAP_TCMP - 定时器中断
 *            TRAP_EXTI - 外部中断
 * @param   en - 状态选择位
 *            ENABLE - 中断可以被响应
 *            DISABLE - 中断被屏蔽
 *
 * @return  0 - 设置失败
 *          1 - 设置成功
 */
uint8_t trap_en_ctrl(uint8_t sel, uint8_t en)
{
    uint32_t bit_tmp = 1;//搞一个1
    bit_tmp = bit_tmp << sel;//搞左移到对应位
    if(en==ENABLE)//配置
    {
        set_csr(mie, bit_tmp);
    }
    else
    {
        clear_csr(mie, bit_tmp);
    }
    return 1;
}

/*********************************************************************
 * @fn      trap_mip_state
 *
 * @brief   中断等待状态查询
 *
 * @param   sel - 选择查询对象
 *            TRAP_SOFT - 软件中断
 *            TRAP_TCMP - 定时器中断
 *            TRAP_EXTI - 外部中断
 *
 * @return  0 - 没有需要响应的中断
 *          1 - 当前中断等待响应
 */
uint32_t trap_mip_state(uint8_t sel)
{
    uint32_t tmp;
    tmp = read_csr(mip);//读取mip
    tmp = tmp >> sel;//对应位右移到第一位
    tmp = tmp & 1;//屏蔽高位
    return tmp;
}
