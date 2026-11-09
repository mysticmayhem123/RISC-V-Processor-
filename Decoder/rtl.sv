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
