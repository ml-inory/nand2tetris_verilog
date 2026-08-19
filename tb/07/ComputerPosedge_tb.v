`timescale 1ns/1ps

// Computer（posedge 版）功能测试：
// 运行官方 Add.hack / Max.hack，检查最终 RAM 结果。
// 官方 .tst 仍由 solution/05 的 negedge 版本负责回归，
// 这里验证的是给 NPU 使用的 posedge 版本能正确执行 Hack 程序。
module ComputerPosedge_tb;

    reg clk = 1'b0;
    reg reset = 1'b1;

    reg dbg_we_a = 1'b0;
    reg [13:0] dbg_addr_a = 14'd0;
    reg [15:0] dbg_wdata_a = 16'd0;

    reg dbg_we_m = 1'b0;
    reg [13:0] dbg_addr_m = 14'd0;
    reg [15:0] dbg_wdata_m = 16'd0;

    wire [15:0] outM_a, outM_m;
    wire writeM_a, writeM_m;
    wire [14:0] addressM_a, addressM_m;
    wire [14:0] pc_a, pc_m;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_computer_posedge #(
        .ROM_INIT_FILE("programs/Add.hack")
    ) u_add (
        .clk(clk), .reset(reset),
        .outM(outM_a), .writeM(writeM_a), .addressM(addressM_a), .pc(pc_a),
        .dbg_we(dbg_we_a), .dbg_addr(dbg_addr_a), .dbg_wdata(dbg_wdata_a)
    );

    n2t_computer_posedge #(
        .ROM_INIT_FILE("programs/Max.hack")
    ) u_max (
        .clk(clk), .reset(reset),
        .outM(outM_m), .writeM(writeM_m), .addressM(addressM_m), .pc(pc_m),
        .dbg_we(dbg_we_m), .dbg_addr(dbg_addr_m), .dbg_wdata(dbg_wdata_m)
    );

    always #5 clk = ~clk;

    task run_cycles;
        input integer n;
        begin
            repeat (n) @(posedge clk);
            #1;
        end
    endtask

    task dbg_write_a;
        input [13:0] a;
        input [15:0] d;
        begin
            dbg_we_a = 1'b1; dbg_addr_a = a; dbg_wdata_a = d; #1;
            dbg_we_a = 1'b0; #1;
        end
    endtask

    task dbg_write_m;
        input [13:0] a;
        input [15:0] d;
        begin
            dbg_we_m = 1'b1; dbg_addr_m = a; dbg_wdata_m = d; #1;
            dbg_we_m = 1'b0; #1;
        end
    endtask

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

`ifdef DUMP_VCD
    initial begin
        $dumpfile("sim/ComputerPosedge_tb.vcd");
        $dumpvars(0, u_add, u_max);
    end
`endif

    initial begin
        $display("=== ComputerPosedge ===");

        // ---- Add: RAM[0] = 2 + 3 = 5 ----
        reset = 1'b1;
        run_cycles(2);
        reset = 1'b0;
        run_cycles(12);
        tst_check(u_add.u_mem.u_ram.mem[0], 16'd5, "Add RAM[0]");

        // ---- Max 用例 1：max(3, 7) = 7 ----
        reset = 1'b1;
        run_cycles(2);
        reset = 1'b0;
        dbg_write_m(14'd0, 16'd3);
        dbg_write_m(14'd1, 16'd7);
        run_cycles(30);
        tst_check(u_max.u_mem.u_ram.mem[2], 16'd7, "Max RAM[2] (3,7)");

        // ---- Max 用例 2：max(10, 4) = 10 ----
        reset = 1'b1;
        run_cycles(2);
        reset = 1'b0;
        dbg_write_m(14'd0, 16'd10);
        dbg_write_m(14'd1, 16'd4);
        run_cycles(30);
        tst_check(u_max.u_mem.u_ram.mem[2], 16'd10, "Max RAM[2] (10,4)");

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule
