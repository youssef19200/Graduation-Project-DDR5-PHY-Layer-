vlib work
vlog ddr5_phy_crc_x4.v ddr5_phy_crc_generation.v ddr5_phy_crc_checking.v ddr5_phy_crc_gen_TB.v ddr5_phy_crc_check_TB.v

#vsim -voptargs=+acc work.ddr5_phy_crc_gen_tb
#do wave_gen.do

vsim -voptargs=+acc work.ddr5_phy_crc_check_tb
do wave_check.do

run -all
#quit -sim