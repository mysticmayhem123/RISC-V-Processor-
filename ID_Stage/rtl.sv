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
