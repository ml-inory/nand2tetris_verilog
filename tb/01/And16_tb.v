`timescale 1ns/1ps

// 本文件由 tools/tst2tb.py 自动生成，请勿手工编辑。
// 对应官方测试：ref/01/And16.tst / ref/01/And16.cmp
module And16_tb;

    reg  [15:0] a = 16'h0;
    reg  [15:0] b = 16'h0;
    wire [15:0] out;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_and16 dut(
        .a(a),
        .b(b),
        .out(out)
    );

    task tst_check;
        input [15:0] a;
        input [15:0] exp_a;
        input [15:0] b;
        input [15:0] exp_b;
        input [15:0] out;
        input [15:0] exp_out;
        begin
            if (exp_a === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (a !== exp_a) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "a", a, exp_a);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_b === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (b !== exp_b) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "b", b, exp_b);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_out === {16{1'bx}}) begin
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
        $dumpfile("sim/And16_tb.vcd");
        $dumpvars(0, dut);
    end
`endif

    initial begin
        $display("=== And16 ===");
    a = 16'h0;
    b = 16'h0;
    #10;
    tst_check(a, 16'h0, b, 16'h0, out, 16'h0);
    step = step + 1;
    a = 16'h0;
    b = 16'hffff;
    #10;
    tst_check(a, 16'h0, b, 16'hffff, out, 16'h0);
    step = step + 1;
    a = 16'hffff;
    b = 16'hffff;
    #10;
    tst_check(a, 16'hffff, b, 16'hffff, out, 16'hffff);
    step = step + 1;
    a = 16'haaaa;
    b = 16'h5555;
    #10;
    tst_check(a, 16'haaaa, b, 16'h5555, out, 16'h0);
    step = step + 1;
    a = 16'h3cc3;
    b = 16'hff0;
    #10;
    tst_check(a, 16'h3cc3, b, 16'hff0, out, 16'hcc0);
    step = step + 1;
    a = 16'h1234;
    b = 16'h9876;
    #10;
    tst_check(a, 16'h1234, b, 16'h9876, out, 16'h1034);
    step = step + 1;

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule