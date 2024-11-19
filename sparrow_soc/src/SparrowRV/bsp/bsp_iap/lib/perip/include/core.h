
#ifndef _CORE_H_
#define _CORE_H_
#include "system.h"

#define cpu_nop ({asm volatile( "nop");})

//读取指定CSR
#define __read_csr(reg) ({ unsigned long __tmp; \
  asm volatile ("csrr %0, " #reg : "=r"(__tmp)); \
  __tmp; })

//写入指定CSR
#define __write_csr(reg, val) ({ \
  if (__builtin_constant_p(val) && (unsigned long)(val) < 32) \
    asm volatile ("csrw " #reg ", %0" :: "i"(val)); \
  else \
    asm volatile ("csrw " #reg ", %0" :: "r"(val)); })

//指定CSR的部分位置1
#define __set_csr(reg, val) ({ \
  if (__builtin_constant_p(val) && (unsigned long)(val) < 32) \
    asm volatile ("csrs " #reg ", %0" :: "i"(val)); \
  else \
    asm volatile ("csrs " #reg ", %0" :: "r"(val)); })

//指定CSR的部分位清0
#define __clear_csr(reg, val) ({ \
  if (__builtin_constant_p(val) && (unsigned long)(val) < 32) \
    asm volatile ("csrc " #reg ", %0" :: "i"(val)); \
  else \
    asm volatile ("csrc " #reg ", %0" :: "r"(val)); })

#define read_csr(reg)        __read_csr(reg)       //读取CSR
#define write_csr(reg, val)  __write_csr(reg, val) //写入CSR
#define set_csr(reg, val)    __set_csr(reg, val)   //CSR置1
#define clear_csr(reg, val)  __clear_csr(reg, val) //CSR清0

uint64_t mtime_value_get();
void mtime_value_set(uint64_t value64b);
void mtime_en_ctr(uint8_t mtime_en);
void mtimecmp_value_set(uint64_t value64b);

void delay_mtime_us(uint32_t us);

void csr_msprint_string(uint8_t *str);



#endif
