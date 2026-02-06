vlib work
vlog CA_manager.v CA_tb3.sv
vsim -voptargs=+acc work.tb_ddr5_phy_command_address
add wave *
add wave -position insertpoint  \
sim:/tb_ddr5_phy_command_address/Dut/command_1st_flag \
sim:/tb_ddr5_phy_command_address/Dut/command_2nd_flag \
sim:/tb_ddr5_phy_command_address/Dut/write_read_flag \
sim:/tb_ddr5_phy_command_address/Dut/mode_register \
sim:/tb_ddr5_phy_command_address/Dut/operation \
sim:/tb_ddr5_phy_command_address/Dut/default_sel
run -all
#quit -sim