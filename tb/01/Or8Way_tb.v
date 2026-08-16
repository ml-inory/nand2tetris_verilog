`timescale 1ns/1ps

// 本文件由 tools/tst2tb.py 自动生成，请勿手工编辑。
// 对应官方测试：ref/01/Or8Way.tst / ref/01/Or8Way.cmp
module Or8Way_tb;

    reg  [7:0] in = 8'h0;
    wire [0:0] out;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_or8way dut(
        .in(in),
        .out(out)
    );

    task tst_check;
        input [7:0] in;
        input [7:0] exp_in;
        input [0:0] out;
        input [0:0] exp_out;
        begin
            if (exp_in === {8{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (in !== exp_in) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "in", in, exp_in, $sformatf("in=%h exp=%h out=%h exp=%h", in, exp_in, out, exp_out));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_out === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (out !== exp_out) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "out", out, exp_out, $sformatf("in=%h exp=%h out=%h exp=%h", in, exp_in, out, exp_out));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("sim/Or8Way_tb.vcd");
        $dumpvars(0, dut);
    end
`endif

    initial begin
        $display("=== Or8Way ===");
    in = 8'h0;
    #10;
    tst_check(in, 8'h0, out, 1'h0);
    step = step + 1;
    in = 8'hff;
    #10;
    tst_check(in, 8'hff, out, 1'h1);
    step = step + 1;
    in = 8'h10;
    #10;
    tst_check(in, 8'h10, out, 1'h1);
    step = step + 1;
    in = 8'h1;
    #10;
    tst_check(in, 8'h1, out, 1'h1);
    step = step + 1;
    in = 8'h26;
    #10;
    tst_check(in, 8'h26, out, 1'h1);
    step = step + 1;

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule