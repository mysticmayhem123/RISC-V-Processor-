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
