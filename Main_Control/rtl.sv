module main_control (
    input  logic [6:0] opcode,
    input  logic [2:0] fn3,
    output logic [1:0] memtoreg,
    output logic       branch,
    output logic       mux_inp,
    output logic       memread,
    output logic       memwrite,
    output logic       alusrc,
    output logic       reg_write,
    output logic [2:0] aluop
);
always_comb begin
    memtoreg = 0;
    branch = 0;
    mux_inp = 0;
    memread = 0;
    memwrite = 0;
    alusrc = 0;
    reg_write = 0;
    aluop = 0;
    case (opcode)
        7'h33: reg_write = 1;
        7'h13: begin alusrc = 1; reg_write = 1; aluop = 3'b001; end
        7'h03: begin memtoreg = 1; memread = 1; alusrc = 1; reg_write = 1; aluop = 3'b010; end
        7'h23: begin memtoreg = 3; memwrite = 1; alusrc = 1; aluop = 3'b011; end
        7'h63: begin branch = 1; aluop = 3'b100; end
        7'h6f, 7'h37: begin memtoreg = 2; alusrc = 1; reg_write = 1; aluop = 3'b110; end
        7'h67: begin memtoreg = 2; mux_inp = 1; alusrc = 1; reg_write = 1; aluop = 3'b001; end
        7'h17: begin memtoreg = 2; alusrc = 1; reg_write = 1; end
        default: begin end
    endcase
end
endmodule
