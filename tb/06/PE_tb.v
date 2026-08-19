`timescale 1ns/1ps

// PE 单元测试：验证权重装载与乘累加语义。
module PE_tb;

    localparam A_W = 8;
    localparam W_W = 8;
    localparam P_W = 32;

    reg clk = 1'b0;
    reg rst = 1'b1;
    reg w_load = 1'b0;
    reg signed [W_W-1:0] w_in = 8'sd0;
    reg signed [A_W-1:0] a_in = 8'sd0;
    reg signed [P_W-1:0] psum_in = 32'sd0;
    wire signed [W_W-1:0] w_out;
    wire signed [A_W-1:0] a_out;
    wire signed [P_W-1:0] psum_out;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_pe #(
        .A_W(A_W),
        .W_W(W_W),
        .P_W(P_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .w_load(w_load),
        .w_in(w_in),
        .a_in(a_in),
        .psum_in(psum_in),
        .w_out(w_out),
        .a_out(a_out),
        .psum_out(psum_out)
    );

    always #5 clk = ~clk;

    task tst_check;
        input signed [P_W-1:0] got;
        input signed [P_W-1:0] exp;
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

`ifdef DUMP_VCD
    initial begin
        $dumpfile("sim/PE_tb.vcd");
        $dumpvars(0, dut);
    end
`endif

    initial begin
        $display("=== PE ===");

        // 复位
        repeat (2) @(negedge clk);
        rst = 1'b0;
        #1;

        // 装载权重 w = 5
        w_load = 1'b1;
        w_in = 8'sd5;
        a_in = 8'sd0;
        psum_in = 32'sd0;
        @(negedge clk);
        #1;
        w_load = 1'b0;

        // 第一个乘累加：psum_out = 0 + 7 * 5 = 35
        a_in = 8'sd7;
        @(negedge clk);
        #1;
        tst_check(psum_out, 32'sd35, "psum after 7*5");
        tst_check(a_out, 32'sd7, "a_out after first MAC");
        tst_check(w_out, 32'sd5, "w_out after load");

        // 第二个乘累加：psum_out = 35 + (-3) * 5 = 20
        a_in = -8'sd3;
        psum_in = 32'sd35;
        @(negedge clk);
        #1;
        tst_check(psum_out, 32'sd20, "psum after 35 + (-3)*5");
        tst_check(a_out, -32'sd3, "a_out after second MAC");

        // 复位清零
        rst = 1'b1;
        @(negedge clk);
        #1;
        tst_check(psum_out, 32'sd0, "psum reset");

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule
