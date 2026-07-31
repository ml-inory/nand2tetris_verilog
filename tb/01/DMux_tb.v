`timescale 1ns/1ps

// 本文件由 tools/tst2tb.py 自动生成，请勿手工编辑。
// 对应官方测试：ref/01/DMux.tst / ref/01/DMux.cmp
module DMux_tb;

    reg  [0:0] in = 1'h0;
    reg  [0:0] sel = 1'h0;
    wire [0:0] a;
    wire [0:0] b;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_dmux dut(
        .in(in),
        .sel(sel),
        .a(a),
        .b(b)
    );

    task tst_check;
        input [0:0] in;
        input [0:0] exp_in;
        input [0:0] sel;
        input [0:0] exp_sel;
        input [0:0] a;
        input [0:0] exp_a;
        input [0:0] b;
        input [0:0] exp_b;
        begin
            if (exp_in === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (in !== exp_in) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "in", in, exp_in);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_sel === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (sel !== exp_sel) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "sel", sel, exp_sel);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
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
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("sim/DMux_tb.vcd");
        $dumpvars(0, dut);
    end
`endif

    initial begin
        $display("=== DMux ===");
    in = 1'h0;
    sel = 1'h0;
    #10;
    tst_check(in, 1'h0, sel, 1'h0, a, 1'h0, b, 1'h0);
    step = step + 1;
    sel = 1'h1;
    #10;
    tst_check(in, 1'h0, sel, 1'h1, a, 1'h0, b, 1'h0);
    step = step + 1;
    in = 1'h1;
    sel = 1'h0;
    #10;
    tst_check(in, 1'h1, sel, 1'h0, a, 1'h1, b, 1'h0);
    step = step + 1;
    sel = 1'h1;
    #10;
    tst_check(in, 1'h1, sel, 1'h1, a, 1'h0, b, 1'h1);
    step = step + 1;

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule