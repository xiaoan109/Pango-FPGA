# ==========================================================================
# ==   清空软件残留信息
# ==========================================================================

# 退出之前仿真
quit -sim

# 清空信息
.main clear

# ==========================================================================
# ==   建立工程并仿真
# ==========================================================================

# 建立新的工程库
vlib work

# 映射逻辑库到物理目录
vmap work work

# 编译文件
vlog +incdir+./../rtl/  +define+MODELSIM +define+HDL_SIM  ./tb_soc.sv
vlog +incdir+./../rtl/                                    ./sd_fake.sv
vlog +incdir+./../rtl/  +define+HDL_SIM     ./../rtl/core/*.v
vlog +incdir+./../rtl/                      ./../rtl/soc/*.v
vlog +incdir+./../rtl/                      ./../rtl/soc/sys_perip/*.v
vlog +incdir+./../rtl/  +define+HDL_SIM     ./../rtl/soc/sdrd/*.v
vlog +incdir+./../rtl/                      ./../rtl/jtag/*.v
vlog +incdir+./../rtl/                      ./../rtl/*.v

#
vsim -voptargs=+acc work.tb_soc
#vsim -novopt work.tb_soc


# ==========================================================================
# ==   加载波形
# ==========================================================================

# 添加波形，高度30，以unsigned格式显示                        *** 请修改路径名 ***

