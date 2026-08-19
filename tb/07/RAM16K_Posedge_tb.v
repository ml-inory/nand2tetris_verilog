`timescale 1ns/1ps

// RAM16K（posedge 版）单元测试：上升沿写入、组合读、背板预置。
module RAM16K_Posedge_tb;

    reg clk = 1'b0;
    reg load = 1'b0;
    reg [15:0] in = 16'h0;
    reg [14:0] address = 15'd0;
    reg dbg_we = 1'b0;
    reg [13:0] dbg_addr = 14'd0;
    reg [15:0] dbg_wdata = 16'h0;
    wire [15:0] out;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_ram16k_posedge dut(
        .clk(clk), .in(in), .load(load), .address(address),
        .dbg_we(dbg_we), .dbg_addr(dbg_addr), .dbg_wdata(dbg_wdata),
        .out(out)
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
        $display("=== RAM16K_Posedge ===");

        // 上升沿写入 12345 到地址 10
        in = 16'd12345;
        load = 1'b1;
        address = 15'd10;
        @(posedge clk); #1;
        load = 1'b0;
        tst_check(out, 16'd12345, "RAM write/read");

        // 覆盖写入 7
        in = 16'd7;
        load = 1'b1;
        @(posedge clk); #1;
        load = 1'b0;
        tst_check(out, 16'd7, "RAM overwrite");

        // 背板预置 RAM[0] = 99
        dbg_we = 1'b1;
        dbg_addr = 14'd0;
        dbg_wdata = 16'd99;
        #1;
        dbg_we = 1'b0;
        #1;
        address = 15'd0;
        #1;
        tst_check(out, 16'd99, "dbg write");

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule
