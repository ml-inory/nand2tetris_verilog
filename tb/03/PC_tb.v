`timescale 1ns/1ps

// 本文件由 tools/tst2tb.py 自动生成，请勿手工编辑。
// 对应官方测试：ref/03/a/PC.tst / ref/03/a/PC.cmp
module PC_tb;

    reg clk = 1'b0;
    reg  [15:0] in = 16'h0;
    reg  [0:0] load = 1'h0;
    reg  [0:0] inc = 1'h0;
    reg  [0:0] reset = 1'h0;
    wire [15:0] out;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_pc dut(
        .clk(clk),
        .in(in),
        .load(load),
        .inc(inc),
        .reset(reset),
        .out(out)
    );

    task tst_check;
        input [15:0] in;
        input [15:0] exp_in;
        input [0:0] reset;
        input [0:0] exp_reset;
        input [0:0] load;
        input [0:0] exp_load;
        input [0:0] inc;
        input [0:0] exp_inc;
        input [15:0] out;
        input [15:0] exp_out;
        begin
            if (exp_in === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (in !== exp_in) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "in", in, exp_in, $sformatf("in=%h exp=%h reset=%h exp=%h load=%h exp=%h inc=%h exp=%h out=%h exp=%h", in, exp_in, reset, exp_reset, load, exp_load, inc, exp_inc, out, exp_out));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_reset === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (reset !== exp_reset) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "reset", reset, exp_reset, $sformatf("in=%h exp=%h reset=%h exp=%h load=%h exp=%h inc=%h exp=%h out=%h exp=%h", in, exp_in, reset, exp_reset, load, exp_load, inc, exp_inc, out, exp_out));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_load === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (load !== exp_load) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "load", load, exp_load, $sformatf("in=%h exp=%h reset=%h exp=%h load=%h exp=%h inc=%h exp=%h out=%h exp=%h", in, exp_in, reset, exp_reset, load, exp_load, inc, exp_inc, out, exp_out));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_inc === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (inc !== exp_inc) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "inc", inc, exp_inc, $sformatf("in=%h exp=%h reset=%h exp=%h load=%h exp=%h inc=%h exp=%h out=%h exp=%h", in, exp_in, reset, exp_reset, load, exp_load, inc, exp_inc, out, exp_out));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_out === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (out !== exp_out) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "out", out, exp_out, $sformatf("in=%h exp=%h reset=%h exp=%h load=%h exp=%h inc=%h exp=%h out=%h exp=%h", in, exp_in, reset, exp_reset, load, exp_load, inc, exp_inc, out, exp_out));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("sim/PC_tb.vcd");
        $dumpvars(0, dut);
    end
`endif

    initial begin
        $display("=== PC ===");
    in = 16'h0;
    reset = 1'h0;
    load = 1'h0;
    inc = 1'h0;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h0, reset, 1'h0, load, 1'h0, inc, 1'h0, out, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h0, reset, 1'h0, load, 1'h0, inc, 1'h0, out, 16'h0);
    step = step + 1;
    inc = 1'h1;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h0, reset, 1'h0, load, 1'h0, inc, 1'h1, out, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h0, reset, 1'h0, load, 1'h0, inc, 1'h1, out, 16'h1);
    step = step + 1;
    in = 16'h8285;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h8285, reset, 1'h0, load, 1'h0, inc, 1'h1, out, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h8285, reset, 1'h0, load, 1'h0, inc, 1'h1, out, 16'h2);
    step = step + 1;
    load = 1'h1;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h8285, reset, 1'h0, load, 1'h1, inc, 1'h1, out, 16'h2);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h8285, reset, 1'h0, load, 1'h1, inc, 1'h1, out, 16'h8285);
    step = step + 1;
    load = 1'h0;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h8285, reset, 1'h0, load, 1'h0, inc, 1'h1, out, 16'h8285);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h8285, reset, 1'h0, load, 1'h0, inc, 1'h1, out, 16'h8286);
    step = step + 1;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h8285, reset, 1'h0, load, 1'h0, inc, 1'h1, out, 16'h8286);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h8285, reset, 1'h0, load, 1'h0, inc, 1'h1, out, 16'h8287);
    step = step + 1;
    in = 16'h3039;
    load = 1'h1;
    inc = 1'h0;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h3039, reset, 1'h0, load, 1'h1, inc, 1'h0, out, 16'h8287);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h3039, reset, 1'h0, load, 1'h1, inc, 1'h0, out, 16'h3039);
    step = step + 1;
    reset = 1'h1;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h3039, reset, 1'h1, load, 1'h1, inc, 1'h0, out, 16'h3039);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h3039, reset, 1'h1, load, 1'h1, inc, 1'h0, out, 16'h0);
    step = step + 1;
    reset = 1'h0;
    inc = 1'h1;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h3039, reset, 1'h0, load, 1'h1, inc, 1'h1, out, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h3039, reset, 1'h0, load, 1'h1, inc, 1'h1, out, 16'h3039);
    step = step + 1;
    reset = 1'h1;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h3039, reset, 1'h1, load, 1'h1, inc, 1'h1, out, 16'h3039);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h3039, reset, 1'h1, load, 1'h1, inc, 1'h1, out, 16'h0);
    step = step + 1;
    reset = 1'h0;
    load = 1'h0;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h3039, reset, 1'h0, load, 1'h0, inc, 1'h1, out, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h3039, reset, 1'h0, load, 1'h0, inc, 1'h1, out, 16'h1);
    step = step + 1;
    reset = 1'h1;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h3039, reset, 1'h1, load, 1'h0, inc, 1'h1, out, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h3039, reset, 1'h1, load, 1'h0, inc, 1'h1, out, 16'h0);
    step = step + 1;
    in = 16'h0;
    reset = 1'h0;
    load = 1'h1;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h0, reset, 1'h0, load, 1'h1, inc, 1'h1, out, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h0, reset, 1'h0, load, 1'h1, inc, 1'h1, out, 16'h0);
    step = step + 1;
    load = 1'h0;
    inc = 1'h1;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h0, reset, 1'h0, load, 1'h0, inc, 1'h1, out, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h0, reset, 1'h0, load, 1'h0, inc, 1'h1, out, 16'h1);
    step = step + 1;
    in = 16'h56ce;
    reset = 1'h1;
    inc = 1'h0;
    #1; clk = 1'b1; #10;
    tst_check(in, 16'h56ce, reset, 1'h1, load, 1'h0, inc, 1'h0, out, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(in, 16'h56ce, reset, 1'h1, load, 1'h0, inc, 1'h0, out, 16'h0);
    step = step + 1;

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule