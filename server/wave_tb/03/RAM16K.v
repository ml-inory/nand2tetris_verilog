`timescale 1ns/1ps

// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。
module RAM16K_wave_tb;

    reg clk = 1'b0;
    reg  [15:0] in = 16'h0;
    reg  [0:0] load = 1'h0;
    reg  [14:0] address = 15'h0;
    reg  [0:0] dbg_we = 1'h0;
    reg  [13:0] dbg_addr = 14'h0;
    reg  [15:0] dbg_wdata = 16'h0;
    wire [15:0] out;

    n2t_ram16k #(.INIT_FILE("")) dut(
        .clk(clk),
        .in(in),
        .load(load),
        .address(address),
        .dbg_we(dbg_we),
        .dbg_addr(dbg_addr),
        .dbg_wdata(dbg_wdata),
        .out(out)
    );

    task backdoor_write;
        input [13:0] a;
        input [15:0] d;
        begin
            dbg_we = 1'b1; dbg_addr = a; dbg_wdata = d; #1;
            dbg_we = 1'b0;
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, in, load, address, dbg_we, dbg_addr, dbg_wdata, out);

        in = 16'h0;
        load = 1'h0;
        address = 15'h0;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        load = 1'h1;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        in = 16'h10e1;
        load = 1'h0;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        load = 1'h1;
        address = 15'h10e1;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        #10;
        $finish;
    end
endmodule