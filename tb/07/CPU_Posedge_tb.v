`timescale 1ns/1ps

// CPU（posedge 版）单元测试：A/D/PC 上升沿提交、outM 组合输出。
module CPU_Posedge_tb;

    reg clk = 1'b0;
    reg reset = 1'b1;
    reg [15:0] inM = 16'h0;
    reg [15:0] instruction = 16'h0;
    wire [15:0] outM;
    wire writeM;
    wire [14:0] addressM;
    wire [14:0] pc;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_cpu_posedge dut(
        .clk(clk), .inM(inM), .instruction(instruction), .reset(reset),
        .outM(outM), .writeM(writeM), .addressM(addressM), .pc(pc)
    );

    always #5 clk = ~clk;

    task tst_check;
        input [15:0] got;
        input [15:0] exp;
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
        $display("=== CPU_Posedge ===");

        reset = 1'b1;
        repeat (2) @(posedge clk);
        reset = 1'b0;
        #1;

        // @5：A=5, pc -> 1
        instruction = 16'b0000000000000101;
        @(posedge clk); #1;
        tst_check(addressM, 16'd5, "A after @5");
        tst_check(pc, 16'd1, "pc after @5");

        // D=A
        instruction = 16'b1110110000010000;
        @(posedge clk); #1;
        tst_check(outM, 16'd5, "outM after D=A");
        tst_check(pc, 16'd2, "pc after D=A");

        // D=D+A -> D 更新为 10；上升沿后 outM 是“tock 值”= 新D + A = 15
        instruction = 16'b1110000010010000;
        @(posedge clk); #1;
        tst_check(outM, 16'd15, "outM after D=D+A (tock)");
        tst_check(pc, 16'd3, "pc after D=D+A");

        // M=D：writeM=1，outM 仍为 10
        instruction = 16'b1110001100001000;
        @(posedge clk); #1;
        tst_check(writeM, 16'd1, "writeM after M=D");
        // M=D：writeM=1；comp=D，tock 值 = D = 10
        tst_check(outM, 16'd10, "outM after M=D (tock)");

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule
