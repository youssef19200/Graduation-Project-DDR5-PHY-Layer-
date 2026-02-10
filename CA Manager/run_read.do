vlib work
vlog CA_manager_read.v CA_tb2.sv
vsim -voptargs=+acc work.tb_ddr5_phy_command_address_read
add wave *
run -all
#quit -sim