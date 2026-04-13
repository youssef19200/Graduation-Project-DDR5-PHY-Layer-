onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Inputs
add wave -noupdate /ddr5_phy_crc_check_tb/clk_i
add wave -noupdate /ddr5_phy_crc_check_tb/rst_n_i
add wave -noupdate /ddr5_phy_crc_check_tb/crc_en_i
add wave -noupdate /ddr5_phy_crc_check_tb/pre_rddata_valid_i
add wave -noupdate /ddr5_phy_crc_check_tb/dfi_rddata_i
add wave -noupdate -divider Outputs
add wave -noupdate -color Cyan /ddr5_phy_crc_check_tb/dfi_alert_n_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {26 ns} {45 ns}
