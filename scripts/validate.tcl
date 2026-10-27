# Run from any directory: vivado -mode batch -source scripts/validate.tcl
# Optional: -tclargs <installed FPGA part>
set root [file normalize [file join [file dirname [info script]] ..]]
set build [file join $root build]
file mkdir $build
cd $build
set part xc7a35tcpg236-1
if {$argc > 0} { set part [lindex $argv 0] }
set sources [list \
    [file join $root 2to1_Multiplexer rtl.sv] \
    [file join $root 3to1_Multiplexer rtl.sv] \
    [file join $root Adder rtl.sv] \
    [file join $root ALU rtl.sv] \
    [file join $root ALU_Decoder rtl.sv]]

# Standalone XSim flow avoids modifying the project and propagates failures.
set bin [file dirname [info nameofexecutable]]
if {![file exists [file join $bin xvlog.bat]]} {
    set bin [file normalize [file join $::env(XILINX_VIVADO) bin]]
}
proc run_tool {args} {
    puts "Running: $args"
    if {[catch {exec {*}$args 2>@1} output]} {
        puts $output
        error "Vivado tool failed"
    }
    puts $output
    return $output
}
run_tool [file join $bin xvlog.bat] --sv {*}$sources [file join $root tests blocks_tb.sv]
run_tool [file join $bin xelab.bat] blocks_tb -s blocks_sim --debug typical
set sim_output [run_tool [file join $bin xsim.bat] blocks_sim -runall]
if {![string match {*PASS: 23356 checks*} $sim_output]} {
    error "Simulation did not reach the expected PASS marker"
}

foreach top {mux2 mux3 adder alu aludec} {
    create_project -in_memory -part $part
    read_verilog -sv $sources
    synth_design -top $top -part $part
    set latches [get_cells -quiet -hier -filter {REF_NAME =~ LD*}]
    if {[llength $latches] != 0} { error "Unexpected latch in $top: $latches" }
    report_utilization -file [file join $build ${top}_utilization.rpt]
    write_checkpoint -force [file join $build ${top}.dcp]
    close_project
}
puts "PASS: simulation and synthesis of all five requested blocks"
