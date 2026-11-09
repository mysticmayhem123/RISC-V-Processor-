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
