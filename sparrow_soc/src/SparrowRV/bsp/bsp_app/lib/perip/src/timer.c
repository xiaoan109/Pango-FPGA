#include "timer.h"

/*********************************************************************
 * @fn      timer_en_ctrl
 *
 * @brief   定时器使能控制
 *
 * @param   timer_state - 是否使能，ENABLE/DISABLE
 *
 * @return  无
 */
void timer_en_ctrl(uint32_t timer_state)
{
    uint32_t tmp;
    tmp = SYS_RWMEM_W(TIMER_CTRL);
    if(timer_state == ENABLE)
        SYS_RWMEM_W(TIMER_CTRL) = tmp | 0x00000001;
    else
        SYS_RWMEM_W(TIMER_CTRL) = tmp & (~0x00000001);
}

/*********************************************************************
 * @fn      timer_cmpol_ctrl
 *
 * @brief   比较输出的初始极性设置
 *
 * @param   cmpol - 初始极性，0或1
 *
 * @return  无
 */
void timer_cmpol_ctrl(uint32_t cmpol)
{
    uint32_t tmp;
    tmp = SYS_RWMEM_W(TIMER_CTRL);
    if(cmpol == 1)
        SYS_RWMEM_W(TIMER_CTRL) = tmp | 0x00000002;
    else
        SYS_RWMEM_W(TIMER_CTRL) = tmp & (~0x00000002);
}

/*********************************************************************
 * @fn      timer_div_set
 *
 * @brief   设置预分频系数
 *
 * @param   div_data - 预分频系数
 *
 * @return  无
 */
void timer_div_set(uint32_t diver)
{
    uint32_t tmp;
    tmp = SYS_RWMEM_W(TIMER_CTRL);
    tmp = tmp & 0x0000FFFF;
    tmp = tmp | (diver<<16);
    SYS_RWMEM_W(TIMER_CTRL) = tmp;
}

/*********************************************************************
 * @fn      timer_overflow_set
 *
 * @brief   设置溢出值
 *
 * @param   overflow - 溢出值
 *
 * @return  无
 */
void timer_overflow_set(uint32_t overflow)
{
    SYS_RWMEM_W(TIMER_TCOF) = overflow<<16;
}

/*********************************************************************
 * @fn      timer_cmpval_set
 *
 * @brief   设置比较寄存器的值
 *
 * @param   cmp0val - 比较寄存器0
 * @param   cmp1val - 比较寄存器1
 *
 * @return  无
 */
void timer_cmpval_set(uint32_t cmp0val, uint32_t cmp1val)
{
    SYS_RWMEM_W(TIMER_CMPO) = cmp1val<<16 | cmp0val;
}

/*********************************************************************
 * @fn      timer_cnt_val_read
 *
 * @brief   读取计数器当前值
 *
 * @return  计数器当前值
 */
uint32_t timer_cnt_val_read()
{
    uint32_t tmp;
    tmp = SYS_RWMEM_W(TIMER_TCOF);
    tmp = tmp & 0x0000FFFF;
    return tmp;
}

/*********************************************************************
 * @fn      timer_capi_trig_set
 *
 * @brief   捕获输入触发方式控制
 *
 * @param   capi_sel - 参数值为0或1，设置捕获0/1的触发方式
 * @param   trig_mode - 触发方式
 *            TIMER_TRIG_Z - 不触发
 *            TIMER_TRIG_P - 上升沿触发
 *            TIMER_TRIG_N - 下降沿触发
 *            TIMER_TRIG_D - 双沿触发
 *
 * @return  无
 */
void timer_capi_trig_set(uint32_t capi_sel, uint32_t trig_mode)
{
    uint32_t tmp;
    tmp = SYS_RWMEM_W(TIMER_CTRL);
    if(capi_sel == 0)
    {
        tmp = tmp & (~0x0000000c);
        tmp = tmp | (trig_mode<<2);
    }
    else
    {
        tmp = tmp & (~0x00000030);
        tmp = tmp | (trig_mode<<4);
    }
    SYS_RWMEM_W(TIMER_CTRL) = tmp;
}

/*********************************************************************
 * @fn      timer_capi_trig_read
 *
 * @param   capi_sel - 参数值为0或1，读取捕获0/1的触发方式
 *
 * @return  返回捕获0/1的触发方式
 */
uint32_t timer_capi_trig_read(uint32_t capi_sel)
{
    uint32_t tmp;
    tmp = SYS_RWMEM_W(TIMER_CTRL);
    if(capi_sel == 0)
    {
        tmp = tmp >> 2;
    }
    else
    {
        tmp = tmp >> 4;
    }
    tmp = tmp & 0b0011;
    return tmp;
}

/*********************************************************************
 * @fn      timer_cap_val_read
 *
 * @brief   读取捕获寄存器当前值
 *
 * @return  [15:0]捕获寄存器0, [31:16]捕获寄存器1
 */
uint32_t timer_cap_val_read()
{
    return SYS_RWMEM_W(TIMER_CAPI);
}

/*********************************************************************
 * @fn      timer_of_irq_ctrl
 *
 * @brief    定时器溢出中断使能控制
 *
 * @param   timer_of_irq_en - 中断使能选择位
 *                 ENABLE  - 使能
 *                 DISABLE - 关闭
 *
 * @return  无
 */
void timer_of_irq_ctrl(uint32_t timer_of_irq_en)
{
    uint32_t tmp0, tmp1;
    tmp0 = SYS_RWMEM_W(TIMER_CTRL);
    tmp1 = 1 << TIMER_OF_IRQ;
    if(timer_of_irq_en == ENABLE)
    {
        tmp0 = tmp0 | tmp1;
    }
    else
    {
        tmp0 = tmp0 & (~tmp1);
    }
    SYS_RWMEM_W(TIMER_CTRL) = tmp0;
}
