add wave clk
add wave reset
add wave zero
add wave overflow
add wave -unsigned pc_out
add wave -unsigned rs_out
add wave -unsigned rt_out

radix hex

force reset 1
force clk 0
run 2

force reset 0
run 2

force -repeat 10ns clk 0 0ns, 1 3ns
run 310ns