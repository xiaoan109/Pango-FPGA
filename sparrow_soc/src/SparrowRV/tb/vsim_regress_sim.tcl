 # 退出之前仿真
quit -sim

# #建立新的工程库
#vlib work
#
# # 映射逻辑库到物理目录
#vmap work work
#
# # 编译文件
#vlog +incdir+./../rtl/  +define+MODELSIM +define+ISA_TEST ./tb_soc.sv
#vlog +incdir+./../rtl/  ./../rtl/core/*.v
#vlog +incdir+./../rtl/  ./../rtl/soc/sys_perip/*.v
#vlog +incdir+./../rtl/  ./../rtl/soc/sdrd/*.v
#vlog +incdir+./../rtl/  ./../rtl/jtag/*.v
#vlog +incdir+./../rtl/  ./../rtl/*.v

vsim -voptargs=+acc work.tb_soc
run -all
exit
