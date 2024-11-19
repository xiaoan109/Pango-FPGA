OUTPUT_ARCH( "riscv" )
ENTRY(_start) /*定义程序入口，_start来自启动文件*/

/*可修改*/
_use_sd_iap = 0; /*使用SD IAP程序启动，改为 1 */
_cpu_iram_size = 32K; /*iram指令存储器大小*/
_cpu_sram_size = 16K; /*sram数据存储器大小*/
_cpu_stack_size = 4K; /*堆栈区大小*/
/*可修改*/

_iap_prog_size = _use_sd_iap ? 1024 : 0;/*IAP程序大小*/
_app_base_addr = _iap_prog_size; /*APP基地址*/
_sram_base_addr = 0x20000000; /*sram存储器基地址*/
_app_prog_size = _cpu_iram_size - _iap_prog_size; /*实际APP可用空间*/

MEMORY
{
  iram (rx) : ORIGIN = _app_base_addr, LENGTH = _app_prog_size /*APP基地址，大小，可读可执行*/
  sram (rw) : ORIGIN = _sram_base_addr, LENGTH = _cpu_sram_size /*sram存储器基地址，大小，可读可写*/
}
/*r只读 w可写 x可执行 a可分配 i已初始化段 l类似于i !反转其后面的所有属性*/

SECTIONS
{
   __stack_size = DEFINED(__stack_size) ? __stack_size : _cpu_stack_size; /*堆栈区大小*/

  .init           :
  {
    KEEP (*(SORT_NONE(.init)))
  } >iram AT>iram 

  .text           :
  {
    *(.text.unlikely .text.unlikely.*)
    *(.text.startup .text.startup.*)
    *(.text .text.*)
    *(.gnu.linkonce.t.*)
  } >iram AT>iram 

  . = ALIGN(4);

  PROVIDE (__etext = .);
  PROVIDE (_etext = .);
  PROVIDE (etext = .);

  .preinit_array  :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >iram AT>iram 

  .init_array     :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
    KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >iram AT>iram 

  .fini_array     :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
    KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >iram AT>iram 

  .ctors          :
  {
    /* gcc uses crtbegin.o to find the start of
       the constructors, so we make sure it is
       first.  Because this is a wildcard, it
       doesn't matter if the user does not
       actually link against crtbegin.o; the
       linker won't look for a file to match a
       wildcard.  The wildcard also means that it
       doesn't matter which directory crtbegin.o
       is in.  */
    KEEP (*crtbegin.o(.ctors))
    KEEP (*crtbegin?.o(.ctors))
    /* We don't want to include the .ctor section from
       the crtend.o file until after the sorted ctors.
       The .ctor section from the crtend file contains the
       end of ctors marker and it must be last */
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))
  } >iram AT>iram 

  .dtors          :
  {
    KEEP (*crtbegin.o(.dtors))
    KEEP (*crtbegin?.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))
  } >iram AT>iram 

  .lalign         :
  {
    . = ALIGN(4);
    PROVIDE( _data_lma = . );
  } >iram AT>iram 

  .dalign         :
  {
    . = ALIGN(4);
    PROVIDE( _data = . );
  } >sram AT>iram 

  .data          :
  {
    *(.rdata)
    *(.rodata .rodata.*)
    *(.gnu.linkonce.r.*)
    *(.data .data.*)
    *(.gnu.linkonce.d.*)
    . = ALIGN(8);
    PROVIDE( __global_pointer$ = . + 0x800 );
    *(.sdata .sdata.*)
    *(.gnu.linkonce.s.*)
    . = ALIGN(8);
    *(.srodata.cst16)
    *(.srodata.cst8)
    *(.srodata.cst4)
    *(.srodata.cst2)
    *(.srodata .srodata.*)
  } >sram AT>iram 

  . = ALIGN(4);
  PROVIDE( _edata = . );
  PROVIDE( edata = . );

  PROVIDE( _fbss = . );
  PROVIDE( __bss_start = . );
  .bss            :
  {
    *(.sbss*)
    *(.gnu.linkonce.sb.*)
    *(.bss .bss.*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
    . = ALIGN(4);
  } >sram AT>sram 

  . = ALIGN(8);
  PROVIDE( _end = . );
  PROVIDE( end = . );

  .stack ORIGIN(sram) + LENGTH(sram) - __stack_size :
  {
    PROVIDE( _heap_end = . );
    . = __stack_size;
    PROVIDE( _sp = . );
  } >sram AT>sram

}
