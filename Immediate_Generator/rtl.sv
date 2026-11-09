module imm_generator(
    input  logic [11:0] imm_input,
    input  logic [2:0]  fn3,
    input  logic [6:0]  opcode,
    input  logic [19:0] imm_input_uj,
    output logic [31:0] imm_output
);
always_comb begin
    imm_output = {{20{imm_input[11]}}, imm_input};
    case (opcode)
        7'h63: imm_output = {{19{imm_input[11]}}, imm_input, 1'b0};
        7'h6f: imm_output = {{11{imm_input_uj[19]}}, imm_input_uj, 1'b0};
        7'h37, 7'h17: imm_output = {imm_input_uj, 12'b0};
        7'h13: begin
            if (fn3 == 3'b001 || fn3 == 3'b101)
                imm_output = {27'b0, imm_input[4:0]};
        end
        default: begin end
    endcase
end
endmodule
