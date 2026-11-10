module wb_stage(
    input  logic [31:0] mem_out,
    input  logic [31:0] alu_out,
    input  logic [31:0] return_addr,
    input  logic [31:0] imm_out,
    input  logic [31:0] pc_signed_offset,
    input  logic [1:0]  memtoreg,
    input  logic [6:0]  opcode_out_d,
    output logic [31:0] wb_data
);
always_comb begin
    wb_data = alu_out;
    case (memtoreg)
        2'b01: wb_data = mem_out;
        2'b10: begin
            case (opcode_out_d)
                7'h6f, 7'h67: wb_data = return_addr;
                7'h37: wb_data = imm_out;
                7'h17: wb_data = pc_signed_offset;
                default: begin end
            endcase
        end
        default: begin end
    endcase
end
endmodule
