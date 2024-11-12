#include "plic.h"


/*********************************************************************
 * @fn      plic_source_priority_set
 *
 * @brief   设置中断源的优先级
 *
 * @param   source_id - 中断源ID，具体见plic.h->source_id
 * @param   priority  - 优先级，有效区间[0,3]
 *
 * @return  无
 */
void plic_source_priority_set(uint32_t source_id, uint32_t priority)
{
    SYS_RWMEM_W(PLIC_PRT(source_id)) = priority;
}

/*********************************************************************
 * @fn      plic_source_priority_read
 *
 * @brief   读取中断源的优先级
 *
 * @param   source_id - 中断源ID，具体见plic.h->source_id
 *
 * @return  此中断源的优先级
 */
uint32_t plic_source_priority_read(uint32_t source_id)
{
    return SYS_RWMEM_W(PLIC_PRT(source_id));
}

/*********************************************************************
 * @fn      plic_source_ip_read
 *
 * @brief   读取中断待定位(IP)
 *
 * @param   source_id - 中断源ID，具体见plic.h->source_id
 *
 * @return  返回1则表示此中断源ID对应的中断待定位有效
 */
uint32_t plic_source_ip_read(uint32_t source_id)
{
    uint32_t tmp;
    tmp = SYS_RWMEM_W(PLIC_IP);
    tmp = tmp >> source_id;
    tmp = tmp & 0x01;
    return tmp;
}

/*********************************************************************
 * @fn      plic_ie_set
 *
 * @brief   设置中断使能寄存器(IE)
 *
 * @param   source_id - 中断源ID，具体见plic.h->source_id
 * @param   sel - 关闭或使能相应的中断源
 *            ENABLE  - 使能
 *            DISABLE - 关闭
 *
 * @return  无
 */
void plic_ie_set(uint32_t source_id, uint32_t sel)
{
    uint32_t tmp,tmp1;
    tmp = SYS_RWMEM_W(PLIC_IE);
    tmp1 = (1 << source_id);
    if (sel)
    {
        tmp = tmp | tmp1;
    }
    else
    {
        tmp = tmp & (~tmp1);
    }
    SYS_RWMEM_W(PLIC_IE) = tmp;
}

/*********************************************************************
 * @fn      plic_ie_read
 *
 * @brief   读取中断使能寄存器(IE)
 *
 * @param   source_id - 中断源的ID，具体见plic.h->source_id
 *
 * @return  返回1则表示此中断源已使能
 */
uint32_t plic_ie_read(uint32_t source_id)
{
    uint32_t tmp;
    tmp = SYS_RWMEM_W(PLIC_IE);
    tmp = tmp >> source_id;
    tmp = tmp & 0x01;
    return tmp;
}

/*********************************************************************
 * @fn      plic_ith_set
 *
 * @brief   设置中断硬件上下文0(hart context0)的中断阈值
 *
 * @param   ith - 中断阈值，有效区间[0,3]
 *
 * @return  无
 */
void plic_ith_set(uint32_t ith)
{
    SYS_RWMEM_W(PLIC_ITH) = ith;
}

/*********************************************************************
 * @fn      plic_eip_id_read
 *
 * @brief   读取中断声明的ID
 *
 * @param   无
 *
 * @return  当前中断声明的ID
 */
uint32_t plic_eip_id_read()
{
    return SYS_RWMEM_W(PLIC_CPC);
}