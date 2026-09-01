`timescale 1ns/1ps

// MaxPool 2x2 单元测试：典型窗口（含负数、平局、边界值）。
module MaxPool_tb;
    reg [7:0] in0, in1, in2, in3;
    wire [7:0] out;
    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_maxpool dut(
        .in0(in0), .in1(in1), .in2(in2), .in3(in3),
        .out(out)
    );

    task tst_check;
        input [7:0] a, b, c, d;
        input [7:0] exp;
        begin
            in0 = a; in1 = b; in2 = c; in3 = d;
            #1;
            step = step + 1;
            if (out !== exp) begin
                $display("FAIL [step %0d] max(%0d,%0d,%0d,%0d): got %0d exp %0d",
                         step, $signed(a), $signed(b), $signed(c), $signed(d),
                         $signed(out), $signed(exp));
                nfail = nfail + 1;
            end else begin
                npass = npass + 1;
            end
        end
    endtask

    initial begin
        $display("=== MaxPool ===");
        tst_check(8'sd1, 8'sd2, 8'sd3, 8'sd4, 8'sd4);
        tst_check(8'sd4, 8'sd3, 8'sd2, 8'sd1, 8'sd4);
        tst_check(-8'sd5, -8'sd1, -8'sd9, 8'sd0, 8'sd0);
        tst_check(-8'sd1, -8'sd2, -8'sd3, -8'sd4, -8'sd1);
        tst_check(8'sd0, 8'sd0, 8'sd0, 8'sd0, 8'sd0);
        tst_check(8'sd127, -8'sd128, 8'sd55, -8'sd100, 8'sd127);
        tst_check(-8'sd128, -8'sd128, -8'sd128, -8'sd128, -8'sd128);
        tst_check(8'sd7, -8'sd7, 8'sd6, -8'sd6, 8'sd7);
        tst_check(-8'sd50, -8'sd49, -8'sd48, -8'sd47, -8'sd47);
        tst_check(8'sd12, 8'sd12, 8'sd11, 8'sd11, 8'sd12);
        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule
