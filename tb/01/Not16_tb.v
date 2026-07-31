`timescale 1ns/1ps

// 本文件由 tools/tst2tb.py 自动生成，请勿手工编辑。
// 对应官方测试：ref/01/Not16.tst / ref/01/Not16.cmp
module Not16_tb;

    reg  [15:0] in = 16'h0;
    wire [15:0] out;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_not16 dut(
        .in(in),
        .out(out)
    );

    task tst_check;
        input [15:0] in;
        input [15:0] exp_in;
        input [15:0] out;
        input [15:0] exp_out;
        begin
            if (exp_in === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (in !== exp_in) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "in", in, exp_in);
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
        $dumpfile("sim/Not16_tb.vcd");
        $dumpvars(0, dut);
    end
`endif

    initial begin
        $display("=== Not16 ===");
    in = 16'h0;
    #10;
    tst_check(in, 16'h0, out, 16'hffff);
    step = step + 1;
    in = 16'hffff;
    #10;
    tst_check(in, 16'hffff, out, 16'h0);
    step = step + 1;
    in = 16'haaaa;
    #10;
    tst_check(in, 16'haaaa, out, 16'h5555);
    step = step + 1;
    in = 16'h3cc3;
    #10;
    tst_check(in, 16'h3cc3, out, 16'hc33c);
    step = step + 1;
    in = 16'h1234;
    #10;
    tst_check(in, 16'h1234, out, 16'hedcb);
    step = step + 1;

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule