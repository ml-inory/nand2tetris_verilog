`timescale 1ns/1ps

// 本文件由 tools/tst2tb.py 自动生成，请勿手工编辑。
// 对应官方测试：ref/01/Mux4Way16.tst / ref/01/Mux4Way16.cmp
module Mux4Way16_tb;

    reg  [15:0] a = 16'h0;
    reg  [15:0] b = 16'h0;
    reg  [15:0] c = 16'h0;
    reg  [15:0] d = 16'h0;
    reg  [1:0] sel = 2'h0;
    wire [15:0] out;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_mux4way16 dut(
        .a(a),
        .b(b),
        .c(c),
        .d(d),
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
        input [1:0] sel;
        input [1:0] exp_sel;
        input [15:0] out;
        input [15:0] exp_out;
        begin
            if (exp_a === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (a !== exp_a) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "a", a, exp_a, $sformatf("a=%h exp=%h b=%h exp=%h c=%h exp=%h d=%h exp=%h sel=%h exp=%h out=%h exp=%h", a, exp_a, b, exp_b, c, exp_c, d, exp_d, sel, exp_sel, out, exp_out));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_b === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (b !== exp_b) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "b", b, exp_b, $sformatf("a=%h exp=%h b=%h exp=%h c=%h exp=%h d=%h exp=%h sel=%h exp=%h out=%h exp=%h", a, exp_a, b, exp_b, c, exp_c, d, exp_d, sel, exp_sel, out, exp_out));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_c === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (c !== exp_c) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "c", c, exp_c, $sformatf("a=%h exp=%h b=%h exp=%h c=%h exp=%h d=%h exp=%h sel=%h exp=%h out=%h exp=%h", a, exp_a, b, exp_b, c, exp_c, d, exp_d, sel, exp_sel, out, exp_out));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_d === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (d !== exp_d) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "d", d, exp_d, $sformatf("a=%h exp=%h b=%h exp=%h c=%h exp=%h d=%h exp=%h sel=%h exp=%h out=%h exp=%h", a, exp_a, b, exp_b, c, exp_c, d, exp_d, sel, exp_sel, out, exp_out));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_sel === {2{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (sel !== exp_sel) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "sel", sel, exp_sel, $sformatf("a=%h exp=%h b=%h exp=%h c=%h exp=%h d=%h exp=%h sel=%h exp=%h out=%h exp=%h", a, exp_a, b, exp_b, c, exp_c, d, exp_d, sel, exp_sel, out, exp_out));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_out === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (out !== exp_out) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "out", out, exp_out, $sformatf("a=%h exp=%h b=%h exp=%h c=%h exp=%h d=%h exp=%h sel=%h exp=%h out=%h exp=%h", a, exp_a, b, exp_b, c, exp_c, d, exp_d, sel, exp_sel, out, exp_out));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("sim/Mux4Way16_tb.vcd");
        $dumpvars(0, dut);
    end
`endif

    initial begin
        $display("=== Mux4Way16 ===");
    a = 16'h0;
    b = 16'h0;
    c = 16'h0;
    d = 16'h0;
    sel = 2'h0;
    #10;
    tst_check(a, 16'h0, b, 16'h0, c, 16'h0, d, 16'h0, sel, 2'h0, out, 16'h0);
    step = step + 1;
    sel = 2'h1;
    #10;
    tst_check(a, 16'h0, b, 16'h0, c, 16'h0, d, 16'h0, sel, 2'h1, out, 16'h0);
    step = step + 1;
    sel = 2'h2;
    #10;
    tst_check(a, 16'h0, b, 16'h0, c, 16'h0, d, 16'h0, sel, 2'h2, out, 16'h0);
    step = step + 1;
    sel = 2'h3;
    #10;
    tst_check(a, 16'h0, b, 16'h0, c, 16'h0, d, 16'h0, sel, 2'h3, out, 16'h0);
    step = step + 1;
    a = 16'h1234;
    b = 16'h9876;
    c = 16'haaaa;
    d = 16'h5555;
    sel = 2'h0;
    #10;
    tst_check(a, 16'h1234, b, 16'h9876, c, 16'haaaa, d, 16'h5555, sel, 2'h0, out, 16'h1234);
    step = step + 1;
    sel = 2'h1;
    #10;
    tst_check(a, 16'h1234, b, 16'h9876, c, 16'haaaa, d, 16'h5555, sel, 2'h1, out, 16'h9876);
    step = step + 1;
    sel = 2'h2;
    #10;
    tst_check(a, 16'h1234, b, 16'h9876, c, 16'haaaa, d, 16'h5555, sel, 2'h2, out, 16'haaaa);
    step = step + 1;
    sel = 2'h3;
    #10;
    tst_check(a, 16'h1234, b, 16'h9876, c, 16'haaaa, d, 16'h5555, sel, 2'h3, out, 16'h5555);
    step = step + 1;

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule