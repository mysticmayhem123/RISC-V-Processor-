module ex_stage (
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] imm_out,
    input  logic [31:0] address,
    input  logic        branch,
    input  logic        alu_src,
    input  logic        fn7_5,
    input  logic        mux_inp,
    input  logic [2:0]  fn3,
    input  logic [6:0]  imm11_5,
    input  logic [2:0]  aluop,
    input  logic [6:0]  opcode,
    output logic        and_out_ex,
    output logic [31:0] alu_out,
    output logic [31:0] pc_ex_out
);
logic [31:0] operand_b;
logic [4:0] control;
logic zero;
assign operand_b = alu_src ? imm_out : rs2_data;
alu_control control_unit (.alu_op(aluop), .fn3(fn3), .imm11_5(imm11_5), .fn7_5(fn7_5), .control_out(control));
alu arithmetic_unit (.alu_control(control), .rs1_data(rs1_data), .rs2_data(operand_b), .alu_out(alu_out), .zero(zero));
assign pc_ex_out = mux_inp ? {alu_out[31:1], 1'b0} : address + imm_out;
assign and_out_ex = (branch && zero) || opcode == 7'h6f || opcode == 7'h67;
endmodule

module alu #(parameter int DATA_WIDTH = 32)(
    input  logic [4:0]            alu_control,
    input  logic [DATA_WIDTH-1:0] rs1_data,
    input  logic [DATA_WIDTH-1:0] rs2_data,
    output logic [DATA_WIDTH-1:0] alu_out,
    output logic                  zero
);
always_comb begin
    alu_out = 0;
    zero = 0;
    case (alu_control)
        5'd0: alu_out = rs1_data + rs2_data;
        5'd1: alu_out = rs1_data - rs2_data;
        5'd2: alu_out = rs1_data ^ rs2_data;
        5'd3: alu_out = rs1_data | rs2_data;
        5'd4: alu_out = rs1_data & rs2_data;
        5'd5: alu_out = rs1_data << rs2_data[4:0];
        5'd6: alu_out = rs1_data >> rs2_data[4:0];
        5'd7: alu_out = $signed(rs1_data) >>> rs2_data[4:0];
        5'd8: alu_out = {{(DATA_WIDTH-1){1'b0}}, ($signed(rs1_data) < $signed(rs2_data))};
        5'd9: alu_out = {{(DATA_WIDTH-1){1'b0}}, (rs1_data < rs2_data)};
        5'd10: zero = rs1_data == rs2_data;
        5'd11: zero = rs1_data != rs2_data;
        5'd12: zero = $signed(rs1_data) < $signed(rs2_data);
        5'd13: zero = $signed(rs1_data) >= $signed(rs2_data);
        5'd14: zero = rs1_data < rs2_data;
        5'd15: zero = rs1_data >= rs2_data;
        default: begin end
    endcase
end
endmodule

module alu_control (
    input  logic [2:0] alu_op,
    input  logic [2:0] fn3,
    input  logic [6:0] imm11_5,
    input  logic       fn7_5,
    output logic [4:0] control_out
);
always_comb begin
    control_out = 0;
    case (alu_op)
        3'b000, 3'b001: begin
            case (fn3)
                3'b000: control_out = alu_op == 0 && fn7_5 ? 5'd1 : 5'd0;
                3'b001: control_out = 5'd5;
                3'b010: control_out = 5'd8;
                3'b011: control_out = 5'd9;
                3'b100: control_out = 5'd2;
                3'b101: begin
                    if ((alu_op == 0 && fn7_5) || (alu_op == 1 && imm11_5 == 7'h20)) control_out = 5'd7;
                    else control_out = 5'd6;
                end
                3'b110: control_out = 5'd3;
                3'b111: control_out = 5'd4;
                default: begin end
            endcase
        end
        3'b100: begin
            case (fn3)
                3'b000: control_out = 5'd10;
                3'b001: control_out = 5'd11;
                3'b100: control_out = 5'd12;
                3'b101: control_out = 5'd13;
                3'b110: control_out = 5'd14;
                3'b111: control_out = 5'd15;
                default: begin end
            endcase
        end
        default: begin end
    endcase
end
endmodule
