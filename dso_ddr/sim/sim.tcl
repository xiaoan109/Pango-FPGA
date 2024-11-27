if {[file exists work]} {
  file delete -force work  
}
vlib work
vmap work work

set LIB_DIR  D:/Tools/pango/PDS_2022.1/ip/system_ip/ipsxb_hmic_s/ipsxb_hmic_eval/ipsxb_hmic_s/../../../../../arch/vendor/pango/verilog/simulation

vlib work
vlog -sv -work work -mfcu -incr -f sim_file_list.f -y $LIB_DIR +libext+.v +incdir+../bench/mem/ 
vsim -voptargs="+acc" -suppress 3486,3680,3781 +nowarn1 -c -sva -lib work tb_top_ddr
log -r /*
run 800us

