# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./D_FF.sv"
vlog "./D_FF_en.sv"
vlog "./mux2_1.sv"
vlog "./mux2_1X.sv"
vlog "./mux4_1.sv"
vlog "./mux4_1_64.sv"
vlog "./mux8_1.sv"
vlog "./mux16_1.sv"
vlog "./mux32_1.sv"
vlog "./mux64x32_1.sv"
vlog "./reg_X.sv"
vlog "./reg_64x32.sv"
vlog "./deco2x4.sv"
vlog "./deco3x8.sv"
vlog "./deco5x32.sv"
vlog "./regfile.sv"
vlog "./fullAdder.sv"
vlog "./fullAdder_64.sv"
vlog "./ALU_slice.sv"
vlog "./nor16.sv"
vlog "./nor64.sv"
vlog "./regfile.sv"
vlog "./LSL.sv"
vlog "./SE.sv"
vlog "./ZE.sv"
vlog "./instructmem.sv"
vlog "./datamem.sv"
vlog "./PC.sv"
vlog "./datapath.sv"
vlog "./cpu_controls.sv"
vlog "./cpusim.sv"
vlog "./cpu.sv"
Vlog "./ForwardingUnit.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work cpusim

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do runlab_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
