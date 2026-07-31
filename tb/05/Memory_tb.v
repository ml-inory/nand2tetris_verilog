`timescale 1ns/1ps

// Memory 芯片测试台（手工编写）
// 覆盖 RAM16K / Screen / Keyboard 三个地址区间与写使能隔离：
//   0x0000-0x3FFF -> RAM16K
//   0x4000-0x5FFF -> Screen
//   0x6000        -> Keyboard（只读）
// 交互式部分（官方 Memory.tst 里的键盘按键等待）无法自动化，这里跳过。
module Memory_tb;
    reg clk = 1'b0;
    reg [15:0] in = 16'h0000;
    reg load = 1'b0;
    reg [14:0] address = 15'd0;
    reg [15:0] keyboard_in = 16'h0000;
    reg dbg_we = 1'b0;
    reg [13:0] dbg_addr = 14'd0;
    reg [15:0] dbg_wdata = 16'h0000;
    wire [15:0] out;

    integer npass = 0, nfail = 0;

    n2t_memory dut(
        .clk(clk), .in(in), .load(load), .address(address),
        .keyboard_in(keyboard_in),
        .dbg_we(dbg_we), .dbg_addr(dbg_addr), .dbg_wdata(dbg_wdata),
        .out(out)
    );

    task chk;
        input [15:0] exp;
        input [255:0] msg;
        begin
            if (out !== exp) begin
                $display("FAIL [addr=%0d] %s: got %h exp %h", address, msg, out, exp);
                nfail = nfail + 1;
            end else begin
                npass = npass + 1;
            end
        end
    endtask

    task tick;
        begin #1; clk = 1'b1; #10; end
    endtask

    task tock;
        begin clk = 1'b0; #10; end
    endtask

    initial begin
        $display("=== Memory ===");

        // 1) RAM[0] = -1
        address = 15'd0; in = 16'hFFFF; load = 1'b1;
        tick; chk(16'h0000, "pre-write RAM[0]");
        tock; chk(16'hFFFF, "write RAM[0]");

        // 2) RAM[0] 保持
        in = 16'h270F; load = 1'b0;
        tick; chk(16'hFFFF, "hold RAM[0]");
        tock; chk(16'hFFFF, "hold RAM[0]");

        // 3) 未写到上层 RAM 或 Screen
        address = 15'h2000; #1; chk(16'h0000, "RAM[0x2000] empty");
        address = 15'h4000; #1; chk(16'h0000, "Screen empty");

        // 4) RAM[0x2000] = 2222
        in = 16'd2222; load = 1'b1; address = 15'h2000;
        tick; chk(16'h0000, "pre-write RAM[0x2000]");
        tock; chk(16'd2222, "write RAM[0x2000]");
        in = 16'h270F; load = 1'b0;
        address = 15'd0;   #1; chk(16'hFFFF, "RAM[0] unchanged");
        address = 15'h4000; #1; chk(16'h0000, "Screen unchanged");

        // 5) 低地址位独立：RAM[0x1234] = 1234
        in = 16'd1234; load = 1'b1; address = 15'h1234;
        tick; chk(16'h0000, "pre-write RAM[0x1234]");
        tock; chk(16'd1234, "write RAM[0x1234]");
        load = 1'b0;
        address = 15'h2234; #1; chk(16'h0000, "upper RAM not written");
        address = 15'h6234; #1; chk(16'h0000, "kbd region not written");
        address = 15'h0345; #1; chk(16'h0000, "lower RAM not written");

        // 6) Screen：写 0x4FCF，隔离检查
        in = 16'hFFFF; load = 1'b1; address = 15'h4FCF;
        tick; chk(16'h0000, "pre-write screen");
        tock; chk(16'hFFFF, "write screen");
        load = 1'b0;
        address = 15'h504F; #1; chk(16'h0000, "adjacent screen word not written");
        address = 15'h0FCF; #1; chk(16'h0000, "lower RAM not written");
        address = 15'h2FCF; #1; chk(16'h0000, "upper RAM not written");

        // 7) Keyboard：只读映射
        keyboard_in = 16'h004B;  // 'K'
        address = 15'h6000; load = 1'b0; #1;
        chk(16'h004B, "kbd read");
        in = 16'hFFFF; load = 1'b1;
        tick; chk(16'h004B, "kbd write ignored (tick)");
        tock; chk(16'h004B, "kbd write ignored (tock)");
        load = 1'b0;
        address = 15'd0; #1; chk(16'hFFFF, "RAM[0] unchanged");

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule
