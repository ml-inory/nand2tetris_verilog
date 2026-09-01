`timescale 1ns/1ps

// ReLU 单元测试：遍历全部 int8 输入，验证 out = max(in, 0)。
module ReLU_tb;
    reg [7:0] in;
    wire [7:0] out;
    integer i;
    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_relu dut(
        .in(in),
        .out(out)
    );

    initial begin
        $display("=== ReLU ===");
        for (i = -128; i <= 127; i = i + 1) begin
            in = i[7:0];
            #1;
            step = step + 1;
            if ($signed(out) !== (i < 0 ? 0 : i)) begin
                $display("FAIL [step %0d] in=%0d got=%0d exp=%0d",
                         step, i, $signed(out), (i < 0 ? 0 : i));
                nfail = nfail + 1;
            end else begin
                npass = npass + 1;
            end
        end
        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule
