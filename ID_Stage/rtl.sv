module id_stage(
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,
    input  logic [31:0] wb_data,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] imm_out,
    output logic [6:0]  opcode_out_d,
    output logic [6:0]  imm11_5,
    output logic [2:0]  fn3_out_d,
    output logic        fn7_5,
    output logic [2:0]  aluop,
    output logic [1:0]  memtoreg,
    output logic        branch,
    output logic        mem_write,
    output logic        mem_read,
    output logic        alu_src,
    output logic        mux_inp
);
logic [4:0] rs1, rs2, rd;
logic [11:0] imm;
logic [19:0] imm_uj;
logic reg_write;
decoder decode_unit (.instruction(instruction), .rs1(rs1), .rs2(rs2), .rd(rd), .opcode(opcode_out_d), .imm11_5(imm11_5), .fn3(fn3_out_d), .imm(imm), .imm_uj(imm_uj), .fn7_5(fn7_5));
imm_generator immediate_unit (.imm_input(imm), .fn3(fn3_out_d), .opcode(opcode_out_d), .imm_input_uj(imm_uj), .imm_output(imm_out));
register_file registers (.rs1_sel(rs1), .rs2_sel(rs2), .reg_write(reg_write && !stall), .clk(clk), .reset(reset), .wb_data(wb_data), .rd_sel(rd), .rs1_data(rs1_data), .rs2_data(rs2_data));
main_control control_unit (.opcode(opcode_out_d), .fn3(fn3_out_d), .memtoreg(memtoreg), .branch(branch), .mux_inp(mux_inp), .memread(mem_read), .memwrite(mem_write), .alusrc(alu_src), .reg_write(reg_write), .aluop(aluop));
endmodule

module decoder(
    input  logic [31:0] instruction,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output logic [6:0]  opcode,
    output logic [6:0]  imm11_5,
    output logic [2:0]  fn3,
    output logic [11:0] imm,
    output logic [19:0] imm_uj,
    output logic        fn7_5
);
always_comb begin
    opcode = instruction[6:0];
    rs1 = 0;
    rs2 = 0;
    rd = 0;
    imm11_5 = 0;
    fn3 = 0;
    imm = 0;
    imm_uj = 0;
    fn7_5 = 0;
    case (opcode)
        7'h33: begin
            rd = instruction[11:7];
            fn3 = instruction[14:12];
            rs1 = instruction[19:15];
            rs2 = instruction[24:20];
            fn7_5 = instruction[30];
        end
        7'h13, 7'h03, 7'h67: begin
            rd = instruction[11:7];
            fn3 = instruction[14:12];
            rs1 = instruction[19:15];
            imm = instruction[31:20];
            if (opcode == 7'h13) imm11_5 = instruction[31:25];
        end
        7'h23, 7'h63: begin
            fn3 = instruction[14:12];
            rs1 = instruction[19:15];
            rs2 = instruction[24:20];
            if (opcode == 7'h23) imm = {instruction[31:25], instruction[11:7]};
            else imm = {instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
        end
        7'h6f: begin
            rd = instruction[11:7];
            imm_uj = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};
        end
        7'h37, 7'h17: begin
            rd = instruction[11:7];
            imm_uj = instruction[31:12];
        end
        default: begin end
    endcase
end
endmodule

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

module register_file(
    input  logic [4:0]  rs1_sel, rs2_sel,
    input  logic        reg_write,
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] wb_data,
    input  logic [4:0]  rd_sel,
    output logic [31:0] rs1_data, rs2_data
);
logic [31:0] registers [0:31];
integer i;
assign rs1_data = rs1_sel == 0 ? 32'b0 : registers[rs1_sel];
assign rs2_data = rs2_sel == 0 ? 32'b0 : registers[rs2_sel];
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 32; i = i + 1) registers[i] <= 32'b0;
    end else if (reg_write && rd_sel != 0) registers[rd_sel] <= wb_data;
end
endmodule

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
