vlib work
vlog write_manager.sv write_fsm.sv write_shift.sv write_counter.sv test_bench.sv
vsim -voptargs=+acc work.test_bench
add wave *
run -all
#quit -sim