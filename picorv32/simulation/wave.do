onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/uut/clk_50m
add wave -noupdate /top_tb/uut/resetn
add wave -noupdate /top_tb/uut/irq_5
add wave -noupdate /top_tb/uut/irq_6
add wave -noupdate /top_tb/uut/irq_7
add wave -noupdate /top_tb/uut/ser_tx
add wave -noupdate /top_tb/uut/ser_rx
add wave -noupdate /top_tb/uut/led
add wave -noupdate /top_tb/uut/spi_clk
add wave -noupdate /top_tb/uut/spi_mosi
add wave -noupdate /top_tb/uut/spi_miso
add wave -noupdate /top_tb/uut/spi_cs
add wave -noupdate /top_tb/uut/mem_valid
add wave -noupdate /top_tb/uut/mem_instr
add wave -noupdate /top_tb/uut/mem_ready
add wave -noupdate /top_tb/uut/mem_addr
add wave -noupdate /top_tb/uut/mem_wdata
add wave -noupdate /top_tb/uut/mem_wstrb
add wave -noupdate /top_tb/uut/mem_rdata
add wave -noupdate /top_tb/uut/sys_clk
add wave -noupdate /top_tb/uut/pll_lock
add wave -noupdate /top_tb/uut/reset_n0
add wave -noupdate /top_tb/uut/reset_n
add wave -noupdate /top_tb/uut/reset_cnt
add wave -noupdate /top_tb/uut/resetn0
add wave -noupdate /top_tb/uut/irq
add wave -noupdate /top_tb/uut/ram_ready
add wave -noupdate /top_tb/uut/ram_rdata
add wave -noupdate /top_tb/uut/ram_en
add wave -noupdate /top_tb/uut/simpleuart_reg_div_sel
add wave -noupdate /top_tb/uut/simpleuart_reg_div_do
add wave -noupdate /top_tb/uut/simpleuart_reg_dat_sel
add wave -noupdate /top_tb/uut/simpleuart_reg_dat_do
add wave -noupdate /top_tb/uut/simpleuart_reg_dat_wait
add wave -noupdate /top_tb/uut/gpio_out_sel
add wave -noupdate /top_tb/uut/gpio_out_data
add wave -noupdate /top_tb/uut/gpio_in_sel
add wave -noupdate /top_tb/uut/gpio_in_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits fs
update
WaveRestoreZoom {0 fs} {347111520 ps}
