`timescale 1ns/1ps

// ShiftRegister 单元测试：DEPTH=4 的延迟与使能/复位行为。
module ShiftRegister_tb;

    localparam W = 8;
    localparam DEPTH = 4;

    reg clk = 1'b0;
    reg arst = 1'b1;
    reg en = 1'b1;
    reg [W-1:0] in = 8'h0;
    wire [W-1:0] out;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_shift_register #(
        .W(W),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .arst(arst),
        .en(en),
        .in(in),
        .out(out)
    );

    always #5 clk = ~clk;

    task tst_check;
        input [W-1:0] got;
        input [W-1:0] exp;
        input [255:0] name;
        begin
            step = step + 1;
            if (got !== exp) begin
                $display("FAIL [step %0d] %s: got %0d exp %0d", step, name, got, exp);
                nfail = nfail + 1;
            end else begin
                npass = npass + 1;
            end
        end
    endtask

    initial begin
        $display("=== ShiftRegister ===");

        // 复位后输出 0
        repeat (2) @(posedge clk);
        arst = 1'b0;
        #1;
        tst_check(out, 8'h00, "reset");

        // 依次送入 1,2,3,4，第 4 拍后 out 才出现 1
        in = 8'h01;
        @(posedge clk); #1;
        tst_check(out, 8'h00, "after 1st");

        in = 8'h02;
        @(posedge clk); #1;
        tst_check(out, 8'h00, "after 2nd");

        in = 8'h03;
        @(posedge clk); #1;
        tst_check(out, 8'h00, "after 3rd");

        in = 8'h04;
        @(posedge clk); #1;
        tst_check(out, 8'h01, "after 4th");

        in = 8'h05;
        @(posedge clk); #1;
        tst_check(out, 8'h02, "after 5th");

        // en=0 时保持不动
        en = 1'b0;
        in = 8'hff;
        @(posedge clk); #1;
        tst_check(out, 8'h02, "en hold");
        en = 1'b1;

        // 异步复位清零
        arst = 1'b1;
        @(posedge clk); #1;
        tst_check(out, 8'h00, "async reset");

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule
