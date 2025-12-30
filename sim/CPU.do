add wave clk
add wave reset
add wave zero
add wave overflow
add wave -unsigned pc_sig
add wave -unsigned rs_sig
add wave -unsigned rt_sig

add wave -unsigned /U_DATAPATH/U_REGFILE/registers

radix hex

force reset 1
force clk 0
run 4ns

force reset 0
run 3ns

force -repeat 10ns clk 0 0ns, 1 3ns
run 310ns