# run.do
# DO file for QuestaSim simulation of data_manager

# Quit any existing simulation
catch {quit -sim}

# Delete and recreate work library
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# Compile all design files
echo "Compiling design files..."
vlog -work work count_calc.v
vlog -work work valid_counter.v
vlog -work work setting_generator.v
vlog -work work pattern_detector.v
vlog -work work gap_counter.v
vlog -work work data_manager.v

# Compile testbench
echo "Compiling testbench..."
vlog -sv -work work data_manager_tb.sv

# Start simulation with more options
echo "Starting simulation..."
vsim -voptargs=+acc -t 1ps work.data_manager_tb

# Add waves
echo "Adding waves..."

# Delete any existing waves
quietly delete wave *

# Add top level signals
add wave -divider "Clock and Reset"
add wave -radix binary /data_manager_tb/clk_i
add wave -radix binary /data_manager_tb/reset_n_i
add wave -radix binary /data_manager_tb/en_i

add wave -divider "Control Inputs"
add wave -radix binary /data_manager_tb/pre_amble_sett_i
add wave -radix binary /data_manager_tb/bl_i
add wave -radix binary /data_manager_tb/post_amble_sett_i
add wave -radix binary /data_manager_tb/read_crc_enable_i
add wave -radix binary /data_manager_tb/phy_crc_mode_i

add wave -divider "Data Interface"
add wave -radix binary /data_manager_tb/dfi_rddata_en
add wave -radix binary /data_manager_tb/DQS_AD
add wave -radix hexadecimal /data_manager_tb/DQ_AD

add wave -divider "Outputs"
add wave -radix binary /data_manager_tb/dfi_rddata_valid
add wave -radix hexadecimal /data_manager_tb/dfi_rddata
add wave -radix binary /data_manager_tb/OVF

add wave -divider "Saved Configurations"
add wave -radix binary /data_manager_tb/saved_pre_amble_o
add wave -radix binary /data_manager_tb/saved_bl_o
add wave -radix binary /data_manager_tb/saved_post_amble_o
add wave -radix binary /data_manager_tb/saved_read_crc_enable_o
add wave -radix binary /data_manager_tb/saved_phy_crc_mode_o

# Add some internal signals from DUT
add wave -divider "Internal DUT Signals"
add wave -radix binary /data_manager_tb/dut/gap_valid
add wave -radix unsigned /data_manager_tb/dut/gap_count
add wave -radix binary /data_manager_tb/dut/fifo_write
add wave -radix binary /data_manager_tb/dut/pattern_detected

# Configure wave window
configure wave -namecolwidth 300
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

# Run simulation
echo "Running simulation..."
run 3000ns

# Zoom to show activity
wave zoom range 0ns 3000ns

echo ""
echo "========================================="
echo "Simulation completed!"
echo "Check the waveform window for results"
echo "========================================="



