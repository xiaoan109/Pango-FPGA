vlib work
#vmap work
vlog -f file_list.f -l vlog.log
vsim -voptargs="+acc" -suppress 3486,3680,3781  -c top_tb -L work -l sim.log
do wave.do
run -all
