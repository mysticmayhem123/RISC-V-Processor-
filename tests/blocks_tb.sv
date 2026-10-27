`timescale 1ns/1ps
module blocks_tb;
    logic [31:0] a, b, c;
    logic s2;
    logic [1:0] s3, aluop;
    logic [2:0] control, funct3;
    logic opb5, funct7b5;
    wire [31:0] sum, result, mux2_32, mux3_32;
    wire [7:0] mux2_8, mux3_8;
    wire [2:0] decoded;
    integer checks = 0;
    integer i, j, k, f, o, t;
    logic [31:0] values [0:9];
    logic [31:0] expected;
    logic [2:0] expected_decode;
    logic [31:0] random_state = 32'h12345678;

    adder u_add(a, b, sum);
    alu u_alu(a, b, control, result);
    mux2 u_mux2_8(a[7:0], b[7:0], s2, mux2_8);
    mux2 #(.WIDTH(32)) u_mux2_32(a, b, s2, mux2_32);
    mux3 u_mux3_8(a[7:0], b[7:0], c[7:0], s3, mux3_8);
    mux3 #(.WIDTH(32)) u_mux3_32(a, b, c, s3, mux3_32);
    aludec u_decode(opb5, funct3, funct7b5, aluop, decoded);

    task automatic check(input logic ok, input string label_text);
        checks = checks + 1;
        if (ok !== 1'b1)
            $fatal(1, "FAIL %s a=%h b=%h control=%b", label_text, a, b, control);
    endtask

    task automatic exercise_operands;
        #1;
        check(sum === (a + b), "adder");
        for (integer sel = 0; sel < 2; sel = sel + 1) begin
            s2 = sel;
            expected = sel ? b : a;
            #1;
            check(mux2_8 === expected[7:0], "mux2 WIDTH=8");
            check(mux2_32 === expected, "mux2 WIDTH=32");
        end
        for (integer sel = 0; sel < 4; sel = sel + 1) begin
            s3 = sel;
            case (sel)
                0: expected = a;
                1: expected = b;
                2: expected = c;
                default: expected = 0;
            endcase
            #1;
            check(mux3_8 === expected[7:0], "mux3 WIDTH=8");
            check(mux3_32 === expected, "mux3 WIDTH=32");
        end
        for (integer operation = 0; operation < 8; operation = operation + 1) begin
            control = operation;
            case (operation)
                0: expected = a + b;
                1: expected = a - b;
                2: expected = a & b;
                3: expected = a | b;
                5: expected = (a[31] != b[31]) ? {31'b0, a[31]} : {31'b0, (a < b)};
                default: expected = 0;
            endcase
            #1;
            check(result === expected, "ALU");
        end
    endtask

    function automatic [31:0] next_random(input [31:0] state);
        logic [31:0] x;
        begin
            x = state ^ (state << 13);
            x = x ^ (x >> 17);
            next_random = x ^ (x << 5);
        end
    endfunction

    initial begin
        a = 0; b = 0; c = 0; s2 = 0; s3 = 0; control = 0;
        aluop = 0; opb5 = 0; funct3 = 0; funct7b5 = 0;
        values[0] = 0; values[1] = 1; values[2] = 32'hffffffff;
        values[3] = 32'h80000000; values[4] = 32'h7fffffff;
        values[5] = 32'haaaaaaaa; values[6] = 32'h55555555;
        values[7] = 32'hfffffffe; values[8] = 32'h80000001;
        values[9] = 32'h12345678;
        for (i = 0; i < 10; i = i + 1)
            for (j = 0; j < 10; j = j + 1) begin
                a = values[i]; b = values[j]; c = ~values[i];
                exercise_operands();
            end
        for (i = 0; i < 1000; i = i + 1) begin
            random_state = next_random(random_state); a = random_state;
            random_state = next_random(random_state); b = random_state;
            random_state = next_random(random_state); c = random_state;
            exercise_operands();
        end
        for (k = 0; k < 4; k = k + 1)
            for (f = 0; f < 8; f = f + 1)
                for (o = 0; o < 2; o = o + 1)
                    for (t = 0; t < 2; t = t + 1) begin
                        aluop = k; funct3 = f; opb5 = o; funct7b5 = t;
                        expected_decode = 0;
                        if (k == 1) expected_decode = 1;
                        if (k == 2) begin
                            if (f == 0 && o == 1 && t == 1) expected_decode = 1;
                            if (f == 2) expected_decode = 5;
                            if (f == 6) expected_decode = 3;
                            if (f == 7) expected_decode = 2;
                        end
                        #1;
                        check(decoded === expected_decode, "ALU decoder");
                        control = decoded;
                        a = 32'h80000000; b = 1;
                        #1;
                        case (expected_decode)
                            0: expected = 32'h80000001;
                            1: expected = 32'h7fffffff;
                            2: expected = 0;
                            3: expected = 32'h80000001;
                            5: expected = 1;
                        endcase
                        check(result === expected, "decoder to ALU integration");
                    end
        $display("PASS: %0d checks across all five blocks", checks);
        $finish;
    end
endmodule
