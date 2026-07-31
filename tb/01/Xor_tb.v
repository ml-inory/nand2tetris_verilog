`timescale 1ns/1ps

// 本文件由 tools/tst2tb.py 自动生成，请勿手工编辑。
// 对应官方测试：ref/01/Xor.tst / ref/01/Xor.cmp
module Xor_tb;

    reg  [0:0] a = 1'h0;
    reg  [0:0] b = 1'h0;
    wire [0:0] out;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_xor dut(
        .a(a),
        .b(b),
        .out(out)
    );

    task tst_check;
        input [0:0] a;
        input [0:0] exp_a;
        input [0:0] b;
        input [0:0] exp_b;
        input [0:0] out;
        input [0:0] exp_out;
        begin
            if (exp_a === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (a !== exp_a) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "a", a, exp_a);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_b === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (b !== exp_b) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "b", b, exp_b);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_out === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (out !== exp_out) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "out", out, exp_out);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("sim/Xor_tb.vcd");
        $dumpvars(0, dut);
    end
`endif

    initial begin
        $display("=== Xor ===");
    a = 1'h0;
    b = 1'h0;
    #10;
    tst_check(a, 1'h0, b, 1'h0, out, 1'h0);
    step = step + 1;
    a = 1'h0;
    b = 1'h1;
    #10;
    tst_check(a, 1'h0, b, 1'h1, out, 1'h1);
    step = step + 1;
    a = 1'h1;
    b = 1'h0;
    #10;
    tst_check(a, 1'h1, b, 1'h0, out, 1'h1);
    step = step + 1;
    a = 1'h1;
    b = 1'h1;
    #10;
    tst_check(a, 1'h1, b, 1'h1, out, 1'h0);
    step = step + 1;

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule