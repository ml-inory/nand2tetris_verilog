`timescale 1ns/1ps

// 本文件由 tools/tst2tb.py 自动生成，请勿手工编辑。
// 对应官方测试：ref/01/Mux8Way16.tst / ref/01/Mux8Way16.cmp
module Mux8Way16_tb;

    reg  [15:0] a = 16'h0;
    reg  [15:0] b = 16'h0;
    reg  [15:0] c = 16'h0;
    reg  [15:0] d = 16'h0;
    reg  [15:0] e = 16'h0;
    reg  [15:0] f = 16'h0;
    reg  [15:0] g = 16'h0;
    reg  [15:0] h = 16'h0;
    reg  [2:0] sel = 3'h0;
    wire [15:0] out;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_mux8way16 dut(
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .h(h),
        .sel(sel),
        .out(out)
    );

    task tst_check;
        input [15:0] a;
        input [15:0] exp_a;
        input [15:0] b;
        input [15:0] exp_b;
        input [15:0] c;
        input [15:0] exp_c;
        input [15:0] d;
        input [15:0] exp_d;
        input [15:0] e;
        input [15:0] exp_e;
        input [15:0] f;
        input [15:0] exp_f;
        input [15:0] g;
        input [15:0] exp_g;
        input [15:0] h;
        input [15:0] exp_h;
        input [2:0] sel;
        input [2:0] exp_sel;
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
            if (exp_c === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (c !== exp_c) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "c", c, exp_c);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_d === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (d !== exp_d) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "d", d, exp_d);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_e === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (e !== exp_e) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "e", e, exp_e);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_f === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (f !== exp_f) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "f", f, exp_f);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_g === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (g !== exp_g) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "g", g, exp_g);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_h === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (h !== exp_h) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "h", h, exp_h);
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
        $dumpfile("sim/Mux8Way16_tb.vcd");
        $dumpvars(0, dut);
    end
`endif

    initial begin
        $display("=== Mux8Way16 ===");
    a = 16'h0;
    b = 16'h0;
    c = 16'h0;
    d = 16'h0;
    e = 16'h0;
    f = 16'h0;
    g = 16'h0;
    h = 16'h0;
    sel = 3'h0;
    #10;
    tst_check(a, 16'h0, b, 16'h0, c, 16'h0, d, 16'h0, e, 16'h0, f, 16'h0, g, 16'h0, h, 16'h0, sel, 3'h0, out, 16'h0);
    step = step + 1;
    sel = 3'h1;
    #10;
    tst_check(a, 16'h0, b, 16'h0, c, 16'h0, d, 16'h0, e, 16'h0, f, 16'h0, g, 16'h0, h, 16'h0, sel, 3'h1, out, 16'h0);
    step = step + 1;
    sel = 3'h2;
    #10;
    tst_check(a, 16'h0, b, 16'h0, c, 16'h0, d, 16'h0, e, 16'h0, f, 16'h0, g, 16'h0, h, 16'h0, sel, 3'h2, out, 16'h0);
    step = step + 1;
    sel = 3'h3;
    #10;
    tst_check(a, 16'h0, b, 16'h0, c, 16'h0, d, 16'h0, e, 16'h0, f, 16'h0, g, 16'h0, h, 16'h0, sel, 3'h3, out, 16'h0);
    step = step + 1;
    sel = 3'h4;
    #10;
    tst_check(a, 16'h0, b, 16'h0, c, 16'h0, d, 16'h0, e, 16'h0, f, 16'h0, g, 16'h0, h, 16'h0, sel, 3'h4, out, 16'h0);
    step = step + 1;
    sel = 3'h5;
    #10;
    tst_check(a, 16'h0, b, 16'h0, c, 16'h0, d, 16'h0, e, 16'h0, f, 16'h0, g, 16'h0, h, 16'h0, sel, 3'h5, out, 16'h0);
    step = step + 1;
    sel = 3'h6;
    #10;
    tst_check(a, 16'h0, b, 16'h0, c, 16'h0, d, 16'h0, e, 16'h0, f, 16'h0, g, 16'h0, h, 16'h0, sel, 3'h6, out, 16'h0);
    step = step + 1;
    sel = 3'h7;
    #10;
    tst_check(a, 16'h0, b, 16'h0, c, 16'h0, d, 16'h0, e, 16'h0, f, 16'h0, g, 16'h0, h, 16'h0, sel, 3'h7, out, 16'h0);
    step = step + 1;
    a = 16'h1234;
    b = 16'h2345;
    c = 16'h3456;
    d = 16'h4567;
    e = 16'h5678;
    f = 16'h6789;
    g = 16'h789a;
    h = 16'h89ab;
    sel = 3'h0;
    #10;
    tst_check(a, 16'h1234, b, 16'h2345, c, 16'h3456, d, 16'h4567, e, 16'h5678, f, 16'h6789, g, 16'h789a, h, 16'h89ab, sel, 3'h0, out, 16'h1234);
    step = step + 1;
    sel = 3'h1;
    #10;
    tst_check(a, 16'h1234, b, 16'h2345, c, 16'h3456, d, 16'h4567, e, 16'h5678, f, 16'h6789, g, 16'h789a, h, 16'h89ab, sel, 3'h1, out, 16'h2345);
    step = step + 1;
    sel = 3'h2;
    #10;
    tst_check(a, 16'h1234, b, 16'h2345, c, 16'h3456, d, 16'h4567, e, 16'h5678, f, 16'h6789, g, 16'h789a, h, 16'h89ab, sel, 3'h2, out, 16'h3456);
    step = step + 1;
    sel = 3'h3;
    #10;
    tst_check(a, 16'h1234, b, 16'h2345, c, 16'h3456, d, 16'h4567, e, 16'h5678, f, 16'h6789, g, 16'h789a, h, 16'h89ab, sel, 3'h3, out, 16'h4567);
    step = step + 1;
    sel = 3'h4;
    #10;
    tst_check(a, 16'h1234, b, 16'h2345, c, 16'h3456, d, 16'h4567, e, 16'h5678, f, 16'h6789, g, 16'h789a, h, 16'h89ab, sel, 3'h4, out, 16'h5678);
    step = step + 1;
    sel = 3'h5;
    #10;
    tst_check(a, 16'h1234, b, 16'h2345, c, 16'h3456, d, 16'h4567, e, 16'h5678, f, 16'h6789, g, 16'h789a, h, 16'h89ab, sel, 3'h5, out, 16'h6789);
    step = step + 1;
    sel = 3'h6;
    #10;
    tst_check(a, 16'h1234, b, 16'h2345, c, 16'h3456, d, 16'h4567, e, 16'h5678, f, 16'h6789, g, 16'h789a, h, 16'h89ab, sel, 3'h6, out, 16'h789a);
    step = step + 1;
    sel = 3'h7;
    #10;
    tst_check(a, 16'h1234, b, 16'h2345, c, 16'h3456, d, 16'h4567, e, 16'h5678, f, 16'h6789, g, 16'h789a, h, 16'h89ab, sel, 3'h7, out, 16'h89ab);
    step = step + 1;

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule