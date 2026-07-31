`timescale 1ns/1ps

// 波形演示激励（tools/gen_wave.py 生成）：只驱动端口、只 dump 端口。
module ComputerMax_wave_tb;

    reg clk = 1'b0;
    reg  [0:0] reset = 1'h0;
    wire [15:0] outM;
    wire [0:0] writeM;
    wire [14:0] addressM;
    wire [14:0] pc;
    reg  [0:0] dbg_we = 1'h0;
    reg  [13:0] dbg_addr = 14'h0;
    reg  [15:0] dbg_wdata = 16'h0;

    n2t_computer #(.ROM_INIT_FILE("programs/Max.hack"), .RAM_INIT_FILE("")) u_comp(
        .clk(clk),
        .reset(reset),
        .outM(outM),
        .writeM(writeM),
        .addressM(addressM),
        .pc(pc),
        .dbg_we(dbg_we),
        .dbg_addr(dbg_addr),
        .dbg_wdata(dbg_wdata)
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
        $dumpvars(0, clk, reset, outM, writeM, addressM, pc, dbg_we, dbg_addr, dbg_wdata);

        backdoor_write(14'd0, 16'h3);
        backdoor_write(14'd1, 16'h5);
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        #1; clk = 1'b1; #10;
        clk = 1'b0; #10;
        #10;
        $finish;
    end
endmodule