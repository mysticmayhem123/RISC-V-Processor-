`timescale 1ns/1ps
module aludec (
    input  logic       opb5,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic [1:0] ALUOp,
    output logic [2:0] ALUControl
);
    always_comb begin
        ALUControl = 3'b000;
        case (ALUOp)
            2'b00: ALUControl = 3'b000; // LW/SW address addition
            2'b01: ALUControl = 3'b001; // BEQ subtraction
            2'b10: begin
                case (funct3)
                    // Immediate bit 30 must not turn ADDI into SUB.
                    3'b000: ALUControl = (opb5 & funct7b5) ? 3'b001 : 3'b000;
                    3'b010: ALUControl = 3'b101; // SLT/SLTI
                    3'b110: ALUControl = 3'b011; // OR/ORI
                    3'b111: ALUControl = 3'b010; // AND/ANDI
                    default: ALUControl = 3'b000;
                endcase
            end
            default: ALUControl = 3'b000;
        endcase
    end
endmodule
