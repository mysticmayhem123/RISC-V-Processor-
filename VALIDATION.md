# Five-block implementation

This submission implements only the blocks selected in the supplied image:

| Block | Source | Interface |
| --- | --- | --- |
| 2:1 multiplexer | `2to1_Multiplexer/rtl.sv` | `mux2`, WIDTH defaults to 8 |
| 3:1 multiplexer | `3to1_Multiplexer/rtl.sv` | `mux3`, WIDTH defaults to 8 |
| Adder | `Adder/rtl.sv` | 32-bit `adder` |
| ALU | `ALU/rtl.sv` | 32-bit `alu`, signed SLT |
| ALU decoder | `ALU_Decoder/rtl.sv` | `aludec` |

Module, port and parameter names match the repository specifications, so the
existing five `source_files` entries in `rnr-stage.yaml` need no name mappings.
No other processor blocks are implemented.

## Defined behavior

ALU controls are ADD=000, SUB=001, AND=010, OR=011 and signed SLT=101.
Arithmetic wraps to 32 bits. SLT returns either 0 or 1 in a 32-bit result.
The decoder uses ALUOp=00 for addition, 01 for subtraction, and 10 for
instruction-field decoding. SUB requires both opcode bit 5 and funct7 bit 5;
ADDI therefore stays addition even when immediate bit 30 is set.

For encodings outside the specified baseline, the implementation chooses
deterministic defaults: mux3 select 11 returns zero, unsupported ALU controls
return zero, and unsupported decoder encodings select ADD. These defaults
do not extend the supported instruction set.

## Reproduce in AMD Vivado

From the repository root in PowerShell (adjust the installation path if needed):

```powershell
& 'C:/Xilinx/2025.1/Vivado/bin/vivado.bat' -mode batch -nojournal -nolog -source scripts/validate.tcl
```

The script uses Vivado's xvlog, xelab and XSim to run a self-checking
SystemVerilog testbench, then synthesizes each of the five modules separately.
It checks that synthesis contains no latches and writes utilization reports
and checkpoints to the ignored `build/` directory. The default synthesis part
is `xc7a35tcpg236-1`; this is a verification target, not a board assignment.
To select another installed part, append `-tclargs <part>`.

The simulation requires 23,356 passing checks: 100 directed operand pairs,
1,000 reproducible pseudorandom operand sets, all ALU selectors, all mux
selectors at widths 8 and 32, all 128 decoder input combinations, and
decoder-to-ALU checks. Directed pairs include signed extremes, equal values,
wraparound, and alternating-bit patterns.

Testbench files are separate from CI RTL source lists. No board constraints,
bitstream or hardware programming are included because no target board was
specified.

## Course CI scope

The assignment's stages are cumulative. The earliest stage (`fetch`) also
requires `flopr`, `flopenr` and `imem`, which are outside the selected image.
ALU decoder belongs to `decode_control`; ALU and mux3 belong to `execute`.
There is no documented five-block-only stage. Consequently `stage: fetch`
is retained, the other template mappings remain for future work, and a full
course stage pass cannot be claimed for this limited submission.

The assignment also requires the repository owner to install the
[RISC-n-Roll-CI GitHub app](https://github.com/apps/risc-n-roll-ci/installations/new)
for this repository and submit its URL through the course Google Form.
Those account/course actions are separate from local Vivado validation.

## Recorded local result

On 27 October 2026, AMD Vivado 2025.1 completed the validation script:

- XSim: PASS, 23,356 checks.
- Synthesis: PASS for mux2, mux3, adder, alu and aludec.
- No inferred latches, synthesis errors or critical warnings.
- The only synthesis warning was Synth 8-7080 (parallel synthesis criteria
  not met), which does not indicate an RTL behavior problem.

The local transcript is `build/validation.log`; generated reports and
checkpoints are in `build/` and are intentionally excluded from Git.
