`timescale 1ns/1ps

// 本文件由 tools/tst2tb.py 自动生成，请勿手工编辑。
// 对应官方测试：ref/01/DMux8Way.tst / ref/01/DMux8Way.cmp
module DMux8Way_tb;

    reg  [0:0] in = 1'h0;
    reg  [2:0] sel = 3'h0;
    wire [0:0] a;
    wire [0:0] b;
    wire [0:0] c;
    wire [0:0] d;
    wire [0:0] e;
    wire [0:0] f;
    wire [0:0] g;
    wire [0:0] h;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_dmux8way dut(
        .in(in),
        .sel(sel),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .h(h)
    );

    task tst_check;
        input [0:0] in;
        input [0:0] exp_in;
        input [2:0] sel;
        input [2:0] exp_sel;
        input [0:0] a;
        input [0:0] exp_a;
        input [0:0] b;
        input [0:0] exp_b;
        input [0:0] c;
        input [0:0] exp_c;
        input [0:0] d;
        input [0:0] exp_d;
        input [0:0] e;
        input [0:0] exp_e;
        input [0:0] f;
        input [0:0] exp_f;
        input [0:0] g;
        input [0:0] exp_g;
        input [0:0] h;
        input [0:0] exp_h;
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
            if (exp_sel === {3{1'bx}}) begin
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
            if (exp_c === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (c !== exp_c) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "c", c, exp_c);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_d === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (d !== exp_d) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "d", d, exp_d);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_e === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (e !== exp_e) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "e", e, exp_e);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_f === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (f !== exp_f) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "f", f, exp_f);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_g === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (g !== exp_g) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "g", g, exp_g);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_h === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (h !== exp_h) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "h", h, exp_h);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("sim/DMux8Way_tb.vcd");
        $dumpvars(0, dut);
    end
`endif

    initial begin
        $display("=== DMux8Way ===");
    in = 1'h0;
    sel = 3'h0;
    #10;
    tst_check(in, 1'h0, sel, 3'h0, a, 1'h0, b, 1'h0, c, 1'h0, d, 1'h0, e, 1'h0, f, 1'h0, g, 1'h0, h, 1'h0);
    step = step + 1;
    sel = 3'h1;
    #10;
    tst_check(in, 1'h0, sel, 3'h1, a, 1'h0, b, 1'h0, c, 1'h0, d, 1'h0, e, 1'h0, f, 1'h0, g, 1'h0, h, 1'h0);
    step = step + 1;
    sel = 3'h2;
    #10;
    tst_check(in, 1'h0, sel, 3'h2, a, 1'h0, b, 1'h0, c, 1'h0, d, 1'h0, e, 1'h0, f, 1'h0, g, 1'h0, h, 1'h0);
    step = step + 1;
    sel = 3'h3;
    #10;
    tst_check(in, 1'h0, sel, 3'h3, a, 1'h0, b, 1'h0, c, 1'h0, d, 1'h0, e, 1'h0, f, 1'h0, g, 1'h0, h, 1'h0);
    step = step + 1;
    sel = 3'h4;
    #10;
    tst_check(in, 1'h0, sel, 3'h4, a, 1'h0, b, 1'h0, c, 1'h0, d, 1'h0, e, 1'h0, f, 1'h0, g, 1'h0, h, 1'h0);
    step = step + 1;
    sel = 3'h5;
    #10;
    tst_check(in, 1'h0, sel, 3'h5, a, 1'h0, b, 1'h0, c, 1'h0, d, 1'h0, e, 1'h0, f, 1'h0, g, 1'h0, h, 1'h0);
    step = step + 1;
    sel = 3'h6;
    #10;
    tst_check(in, 1'h0, sel, 3'h6, a, 1'h0, b, 1'h0, c, 1'h0, d, 1'h0, e, 1'h0, f, 1'h0, g, 1'h0, h, 1'h0);
    step = step + 1;
    sel = 3'h7;
    #10;
    tst_check(in, 1'h0, sel, 3'h7, a, 1'h0, b, 1'h0, c, 1'h0, d, 1'h0, e, 1'h0, f, 1'h0, g, 1'h0, h, 1'h0);
    step = step + 1;
    in = 1'h1;
    sel = 3'h0;
    #10;
    tst_check(in, 1'h1, sel, 3'h0, a, 1'h1, b, 1'h0, c, 1'h0, d, 1'h0, e, 1'h0, f, 1'h0, g, 1'h0, h, 1'h0);
    step = step + 1;
    sel = 3'h1;
    #10;
    tst_check(in, 1'h1, sel, 3'h1, a, 1'h0, b, 1'h1, c, 1'h0, d, 1'h0, e, 1'h0, f, 1'h0, g, 1'h0, h, 1'h0);
    step = step + 1;
    sel = 3'h2;
    #10;
    tst_check(in, 1'h1, sel, 3'h2, a, 1'h0, b, 1'h0, c, 1'h1, d, 1'h0, e, 1'h0, f, 1'h0, g, 1'h0, h, 1'h0);
    step = step + 1;
    sel = 3'h3;
    #10;
    tst_check(in, 1'h1, sel, 3'h3, a, 1'h0, b, 1'h0, c, 1'h0, d, 1'h1, e, 1'h0, f, 1'h0, g, 1'h0, h, 1'h0);
    step = step + 1;
    sel = 3'h4;
    #10;
    tst_check(in, 1'h1, sel, 3'h4, a, 1'h0, b, 1'h0, c, 1'h0, d, 1'h0, e, 1'h1, f, 1'h0, g, 1'h0, h, 1'h0);
    step = step + 1;
    sel = 3'h5;
    #10;
    tst_check(in, 1'h1, sel, 3'h5, a, 1'h0, b, 1'h0, c, 1'h0, d, 1'h0, e, 1'h0, f, 1'h1, g, 1'h0, h, 1'h0);
    step = step + 1;
    sel = 3'h6;
    #10;
    tst_check(in, 1'h1, sel, 3'h6, a, 1'h0, b, 1'h0, c, 1'h0, d, 1'h0, e, 1'h0, f, 1'h0, g, 1'h1, h, 1'h0);
    step = step + 1;
    sel = 3'h7;
    #10;
    tst_check(in, 1'h1, sel, 3'h7, a, 1'h0, b, 1'h0, c, 1'h0, d, 1'h0, e, 1'h0, f, 1'h0, g, 1'h0, h, 1'h1);
    step = step + 1;

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule