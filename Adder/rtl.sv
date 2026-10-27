`timescale 1ns/1ps
module adder (
    input  logic [31:0] a, b,
    output logic [31:0] y
);
    // RV32 addition wraps modulo 2**32; no carry port is required.
    assign y = a + b;
endmodule
