`timescale 1ns/1ps

// 本文件由 tools/tst2tb.py 自动生成，请勿手工编辑。
// 对应官方测试：ref/02/FullAdder.tst / ref/02/FullAdder.cmp
module FullAdder_tb;

    reg  [0:0] a = 1'h0;
    reg  [0:0] b = 1'h0;
    reg  [0:0] c = 1'h0;
    wire [0:0] sum;
    wire [0:0] carry;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_full_adder dut(
        .a(a),
        .b(b),
        .c(c),
        .sum(sum),
        .carry(carry)
    );

    task tst_check;
        input [0:0] a;
        input [0:0] exp_a;
        input [0:0] b;
        input [0:0] exp_b;
        input [0:0] c;
        input [0:0] exp_c;
        input [0:0] sum;
        input [0:0] exp_sum;
        input [0:0] carry;
        input [0:0] exp_carry;
        begin
            if (exp_a === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (a !== exp_a) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "a", a, exp_a, $sformatf("a=%h exp=%h b=%h exp=%h c=%h exp=%h sum=%h exp=%h carry=%h exp=%h", a, exp_a, b, exp_b, c, exp_c, sum, exp_sum, carry, exp_carry));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_b === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (b !== exp_b) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "b", b, exp_b, $sformatf("a=%h exp=%h b=%h exp=%h c=%h exp=%h sum=%h exp=%h carry=%h exp=%h", a, exp_a, b, exp_b, c, exp_c, sum, exp_sum, carry, exp_carry));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_c === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (c !== exp_c) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "c", c, exp_c, $sformatf("a=%h exp=%h b=%h exp=%h c=%h exp=%h sum=%h exp=%h carry=%h exp=%h", a, exp_a, b, exp_b, c, exp_c, sum, exp_sum, carry, exp_carry));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_sum === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (sum !== exp_sum) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "sum", sum, exp_sum, $sformatf("a=%h exp=%h b=%h exp=%h c=%h exp=%h sum=%h exp=%h carry=%h exp=%h", a, exp_a, b, exp_b, c, exp_c, sum, exp_sum, carry, exp_carry));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_carry === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (carry !== exp_carry) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "carry", carry, exp_carry, $sformatf("a=%h exp=%h b=%h exp=%h c=%h exp=%h sum=%h exp=%h carry=%h exp=%h", a, exp_a, b, exp_b, c, exp_c, sum, exp_sum, carry, exp_carry));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("sim/FullAdder_tb.vcd");
        $dumpvars(0, dut);
    end
`endif

    initial begin
        $display("=== FullAdder ===");
    a = 1'h0;
    b = 1'h0;
    c = 1'h0;
    #10;
    tst_check(a, 1'h0, b, 1'h0, c, 1'h0, sum, 1'h0, carry, 1'h0);
    step = step + 1;
    c = 1'h1;
    #10;
    tst_check(a, 1'h0, b, 1'h0, c, 1'h1, sum, 1'h1, carry, 1'h0);
    step = step + 1;
    b = 1'h1;
    c = 1'h0;
    #10;
    tst_check(a, 1'h0, b, 1'h1, c, 1'h0, sum, 1'h1, carry, 1'h0);
    step = step + 1;
    c = 1'h1;
    #10;
    tst_check(a, 1'h0, b, 1'h1, c, 1'h1, sum, 1'h0, carry, 1'h1);
    step = step + 1;
    a = 1'h1;
    b = 1'h0;
    c = 1'h0;
    #10;
    tst_check(a, 1'h1, b, 1'h0, c, 1'h0, sum, 1'h1, carry, 1'h0);
    step = step + 1;
    c = 1'h1;
    #10;
    tst_check(a, 1'h1, b, 1'h0, c, 1'h1, sum, 1'h0, carry, 1'h1);
    step = step + 1;
    b = 1'h1;
    c = 1'h0;
    #10;
    tst_check(a, 1'h1, b, 1'h1, c, 1'h0, sum, 1'h0, carry, 1'h1);
    step = step + 1;
    c = 1'h1;
    #10;
    tst_check(a, 1'h1, b, 1'h1, c, 1'h1, sum, 1'h1, carry, 1'h1);
    step = step + 1;

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule