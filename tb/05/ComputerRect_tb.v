`timescale 1ns/1ps

// 本文件由 tools/tst2tb.py 自动生成，请勿手工编辑。
// 对应官方测试：ref/05/ComputerRect.tst / ref/05/ComputerRect.cmp
module ComputerRect_tb;

    reg clk = 1'b0;
    reg  [0:0] reset = 1'h0;
    wire [15:0] outM;
    wire [0:0] writeM;
    wire [14:0] addressM;
    wire [14:0] pc;
    reg  [0:0] dbg_we = 1'h0;
    reg  [13:0] dbg_addr = 14'h0;
    reg  [15:0] dbg_wdata = 16'h0;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_computer #(.ROM_INIT_FILE("programs/Rect.hack"), .RAM_INIT_FILE("")) u_comp(
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

    task tst_check;
        input [15:0] ARegister_;
        input [15:0] exp_ARegister_;
        input [15:0] DRegister_;
        input [15:0] exp_DRegister_;
        input [14:0] PC_;
        input [14:0] exp_PC_;
        input [15:0] RAM16K_0;
        input [15:0] exp_RAM16K_0;
        input [15:0] RAM16K_1;
        input [15:0] exp_RAM16K_1;
        input [15:0] RAM16K_2;
        input [15:0] exp_RAM16K_2;
        begin
            if (exp_ARegister_ === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (ARegister_ !== exp_ARegister_) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "ARegister[]", ARegister_, exp_ARegister_);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_DRegister_ === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (DRegister_ !== exp_DRegister_) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "DRegister[]", DRegister_, exp_DRegister_);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_PC_ === {15{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (PC_ !== exp_PC_) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "PC[]", PC_, exp_PC_);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_RAM16K_0 === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (RAM16K_0 !== exp_RAM16K_0) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "RAM16K[0]", RAM16K_0, exp_RAM16K_0);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_RAM16K_1 === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (RAM16K_1 !== exp_RAM16K_1) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "RAM16K[1]", RAM16K_1, exp_RAM16K_1);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_RAM16K_2 === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (RAM16K_2 !== exp_RAM16K_2) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "RAM16K[2]", RAM16K_2, exp_RAM16K_2);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("sim/ComputerRect_tb.vcd");
        $dumpvars(0, u_comp);
    end
`endif

    initial begin
        $display("=== ComputerRect ===");
    backdoor_write(14'd0, 16'h4);
    tst_check(u_comp.u_cpu.a_reg, 16'h0, u_comp.u_cpu.d_reg, 16'h0, u_comp.u_cpu.pc_reg, 15'h0, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h0, u_comp.u_cpu.d_reg, 16'h0, u_comp.u_cpu.pc_reg, 15'h1, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h0, u_comp.u_cpu.d_reg, 16'h4, u_comp.u_cpu.pc_reg, 15'h2, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h17, u_comp.u_cpu.d_reg, 16'h4, u_comp.u_cpu.pc_reg, 15'h3, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h17, u_comp.u_cpu.d_reg, 16'h4, u_comp.u_cpu.pc_reg, 15'h4, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h10, u_comp.u_cpu.d_reg, 16'h4, u_comp.u_cpu.pc_reg, 15'h5, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h10, u_comp.u_cpu.d_reg, 16'h4, u_comp.u_cpu.pc_reg, 15'h6, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h4000, u_comp.u_cpu.d_reg, 16'h4, u_comp.u_cpu.pc_reg, 15'h7, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h4000, u_comp.u_cpu.d_reg, 16'h4000, u_comp.u_cpu.pc_reg, 15'h8, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4000, u_comp.u_cpu.pc_reg, 15'h9, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4000, u_comp.u_cpu.pc_reg, 15'ha, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4000, u_comp.u_cpu.pc_reg, 15'hb, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h4000, u_comp.u_cpu.d_reg, 16'h4000, u_comp.u_cpu.pc_reg, 15'hc, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h4000, u_comp.u_cpu.d_reg, 16'h4000, u_comp.u_cpu.pc_reg, 15'hd, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4000, u_comp.u_cpu.pc_reg, 15'he, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4000, u_comp.u_cpu.pc_reg, 15'hf, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h20, u_comp.u_cpu.d_reg, 16'h4000, u_comp.u_cpu.pc_reg, 15'h10, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h20, u_comp.u_cpu.d_reg, 16'h4020, u_comp.u_cpu.pc_reg, 15'h11, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4020, u_comp.u_cpu.pc_reg, 15'h12, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4020, u_comp.u_cpu.pc_reg, 15'h13, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h10, u_comp.u_cpu.d_reg, 16'h4020, u_comp.u_cpu.pc_reg, 15'h14, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h10, u_comp.u_cpu.d_reg, 16'h3, u_comp.u_cpu.pc_reg, 15'h15, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'ha, u_comp.u_cpu.d_reg, 16'h3, u_comp.u_cpu.pc_reg, 15'h16, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'ha, u_comp.u_cpu.d_reg, 16'h3, u_comp.u_cpu.pc_reg, 15'ha, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h3, u_comp.u_cpu.pc_reg, 15'hb, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h4020, u_comp.u_cpu.d_reg, 16'h3, u_comp.u_cpu.pc_reg, 15'hc, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h4020, u_comp.u_cpu.d_reg, 16'h3, u_comp.u_cpu.pc_reg, 15'hd, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h3, u_comp.u_cpu.pc_reg, 15'he, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4020, u_comp.u_cpu.pc_reg, 15'hf, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h20, u_comp.u_cpu.d_reg, 16'h4020, u_comp.u_cpu.pc_reg, 15'h10, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h20, u_comp.u_cpu.d_reg, 16'h4040, u_comp.u_cpu.pc_reg, 15'h11, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4040, u_comp.u_cpu.pc_reg, 15'h12, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4040, u_comp.u_cpu.pc_reg, 15'h13, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h10, u_comp.u_cpu.d_reg, 16'h4040, u_comp.u_cpu.pc_reg, 15'h14, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h10, u_comp.u_cpu.d_reg, 16'h2, u_comp.u_cpu.pc_reg, 15'h15, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'ha, u_comp.u_cpu.d_reg, 16'h2, u_comp.u_cpu.pc_reg, 15'h16, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'ha, u_comp.u_cpu.d_reg, 16'h2, u_comp.u_cpu.pc_reg, 15'ha, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h2, u_comp.u_cpu.pc_reg, 15'hb, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h4040, u_comp.u_cpu.d_reg, 16'h2, u_comp.u_cpu.pc_reg, 15'hc, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h4040, u_comp.u_cpu.d_reg, 16'h2, u_comp.u_cpu.pc_reg, 15'hd, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h2, u_comp.u_cpu.pc_reg, 15'he, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4040, u_comp.u_cpu.pc_reg, 15'hf, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h20, u_comp.u_cpu.d_reg, 16'h4040, u_comp.u_cpu.pc_reg, 15'h10, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h20, u_comp.u_cpu.d_reg, 16'h4060, u_comp.u_cpu.pc_reg, 15'h11, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4060, u_comp.u_cpu.pc_reg, 15'h12, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4060, u_comp.u_cpu.pc_reg, 15'h13, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h10, u_comp.u_cpu.d_reg, 16'h4060, u_comp.u_cpu.pc_reg, 15'h14, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h10, u_comp.u_cpu.d_reg, 16'h1, u_comp.u_cpu.pc_reg, 15'h15, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'ha, u_comp.u_cpu.d_reg, 16'h1, u_comp.u_cpu.pc_reg, 15'h16, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'ha, u_comp.u_cpu.d_reg, 16'h1, u_comp.u_cpu.pc_reg, 15'ha, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h1, u_comp.u_cpu.pc_reg, 15'hb, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h4060, u_comp.u_cpu.d_reg, 16'h1, u_comp.u_cpu.pc_reg, 15'hc, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h4060, u_comp.u_cpu.d_reg, 16'h1, u_comp.u_cpu.pc_reg, 15'hd, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h1, u_comp.u_cpu.pc_reg, 15'he, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4060, u_comp.u_cpu.pc_reg, 15'hf, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h20, u_comp.u_cpu.d_reg, 16'h4060, u_comp.u_cpu.pc_reg, 15'h10, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h20, u_comp.u_cpu.d_reg, 16'h4080, u_comp.u_cpu.pc_reg, 15'h11, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4080, u_comp.u_cpu.pc_reg, 15'h12, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h11, u_comp.u_cpu.d_reg, 16'h4080, u_comp.u_cpu.pc_reg, 15'h13, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h10, u_comp.u_cpu.d_reg, 16'h4080, u_comp.u_cpu.pc_reg, 15'h14, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h10, u_comp.u_cpu.d_reg, 16'h0, u_comp.u_cpu.pc_reg, 15'h15, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'ha, u_comp.u_cpu.d_reg, 16'h0, u_comp.u_cpu.pc_reg, 15'h16, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'ha, u_comp.u_cpu.d_reg, 16'h0, u_comp.u_cpu.pc_reg, 15'h17, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;
    #1; clk = 1'b1; #10;
    clk = 1'b0; #10;
    tst_check(u_comp.u_cpu.a_reg, 16'h17, u_comp.u_cpu.d_reg, 16'h0, u_comp.u_cpu.pc_reg, 15'h18, u_comp.u_mem.u_ram.mem[0], 16'h4, u_comp.u_mem.u_ram.mem[1], 16'h0, u_comp.u_mem.u_ram.mem[2], 16'h0);
    step = step + 1;

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule