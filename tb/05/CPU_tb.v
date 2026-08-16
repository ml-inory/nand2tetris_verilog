`timescale 1ns/1ps

// 本文件由 tools/tst2tb.py 自动生成，请勿手工编辑。
// 对应官方测试：ref/05/CPU.tst / ref/05/CPU.cmp
module CPU_tb;

    reg clk = 1'b0;
    reg  [15:0] inM = 16'h0;
    reg  [15:0] instruction = 16'h0;
    reg  [0:0] reset = 1'h0;
    wire [15:0] outM;
    wire [0:0] writeM;
    wire [14:0] addressM;
    wire [14:0] pc;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_cpu cpu(
        .clk(clk),
        .inM(inM),
        .instruction(instruction),
        .reset(reset),
        .outM(outM),
        .writeM(writeM),
        .addressM(addressM),
        .pc(pc)
    );

    task tst_check;
        input [15:0] inM;
        input [15:0] exp_inM;
        input [15:0] instruction;
        input [15:0] exp_instruction;
        input [0:0] reset;
        input [0:0] exp_reset;
        input [15:0] outM;
        input [15:0] exp_outM;
        input [0:0] writeM;
        input [0:0] exp_writeM;
        input [14:0] addressM;
        input [14:0] exp_addressM;
        input [14:0] pc;
        input [14:0] exp_pc;
        input [15:0] DRegister_;
        input [15:0] exp_DRegister_;
        begin
            if (exp_inM === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (inM !== exp_inM) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "inM", inM, exp_inM, $sformatf("inM=%h exp=%h instruction=%h exp=%h reset=%h exp=%h outM=%h exp=%h writeM=%h exp=%h addressM=%h exp=%h pc=%h exp=%h DRegister[]=%h exp=%h", inM, exp_inM, instruction, exp_instruction, reset, exp_reset, outM, exp_outM, writeM, exp_writeM, addressM, exp_addressM, pc, exp_pc, DRegister_, exp_DRegister_));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_instruction === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (instruction !== exp_instruction) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "instruction", instruction, exp_instruction, $sformatf("inM=%h exp=%h instruction=%h exp=%h reset=%h exp=%h outM=%h exp=%h writeM=%h exp=%h addressM=%h exp=%h pc=%h exp=%h DRegister[]=%h exp=%h", inM, exp_inM, instruction, exp_instruction, reset, exp_reset, outM, exp_outM, writeM, exp_writeM, addressM, exp_addressM, pc, exp_pc, DRegister_, exp_DRegister_));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_reset === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (reset !== exp_reset) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "reset", reset, exp_reset, $sformatf("inM=%h exp=%h instruction=%h exp=%h reset=%h exp=%h outM=%h exp=%h writeM=%h exp=%h addressM=%h exp=%h pc=%h exp=%h DRegister[]=%h exp=%h", inM, exp_inM, instruction, exp_instruction, reset, exp_reset, outM, exp_outM, writeM, exp_writeM, addressM, exp_addressM, pc, exp_pc, DRegister_, exp_DRegister_));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_outM === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (outM !== exp_outM) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "outM", outM, exp_outM, $sformatf("inM=%h exp=%h instruction=%h exp=%h reset=%h exp=%h outM=%h exp=%h writeM=%h exp=%h addressM=%h exp=%h pc=%h exp=%h DRegister[]=%h exp=%h", inM, exp_inM, instruction, exp_instruction, reset, exp_reset, outM, exp_outM, writeM, exp_writeM, addressM, exp_addressM, pc, exp_pc, DRegister_, exp_DRegister_));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_writeM === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (writeM !== exp_writeM) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "writeM", writeM, exp_writeM, $sformatf("inM=%h exp=%h instruction=%h exp=%h reset=%h exp=%h outM=%h exp=%h writeM=%h exp=%h addressM=%h exp=%h pc=%h exp=%h DRegister[]=%h exp=%h", inM, exp_inM, instruction, exp_instruction, reset, exp_reset, outM, exp_outM, writeM, exp_writeM, addressM, exp_addressM, pc, exp_pc, DRegister_, exp_DRegister_));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_addressM === {15{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (addressM !== exp_addressM) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "addressM", addressM, exp_addressM, $sformatf("inM=%h exp=%h instruction=%h exp=%h reset=%h exp=%h outM=%h exp=%h writeM=%h exp=%h addressM=%h exp=%h pc=%h exp=%h DRegister[]=%h exp=%h", inM, exp_inM, instruction, exp_instruction, reset, exp_reset, outM, exp_outM, writeM, exp_writeM, addressM, exp_addressM, pc, exp_pc, DRegister_, exp_DRegister_));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_pc === {15{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (pc !== exp_pc) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "pc", pc, exp_pc, $sformatf("inM=%h exp=%h instruction=%h exp=%h reset=%h exp=%h outM=%h exp=%h writeM=%h exp=%h addressM=%h exp=%h pc=%h exp=%h DRegister[]=%h exp=%h", inM, exp_inM, instruction, exp_instruction, reset, exp_reset, outM, exp_outM, writeM, exp_writeM, addressM, exp_addressM, pc, exp_pc, DRegister_, exp_DRegister_));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_DRegister_ === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (DRegister_ !== exp_DRegister_) begin
                    $display("FAIL [step %0d] %s: got %h exp %h    [%s]", step, "DRegister[]", DRegister_, exp_DRegister_, $sformatf("inM=%h exp=%h instruction=%h exp=%h reset=%h exp=%h outM=%h exp=%h writeM=%h exp=%h addressM=%h exp=%h pc=%h exp=%h DRegister[]=%h exp=%h", inM, exp_inM, instruction, exp_instruction, reset, exp_reset, outM, exp_outM, writeM, exp_writeM, addressM, exp_addressM, pc, exp_pc, DRegister_, exp_DRegister_));
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("sim/CPU_tb.vcd");
        $dumpvars(0, cpu);
    end
`endif

    initial begin
        $display("=== CPU ===");
    instruction = 16'h3039;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h0, instruction, 16'h3039, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h0, pc, 15'h0, cpu.d_reg, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h0, instruction, 16'h3039, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3039, pc, 15'h1, cpu.d_reg, 16'h0);
    step = step + 1;
    instruction = 16'hec10;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h0, instruction, 16'hec10, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3039, pc, 15'h1, cpu.d_reg, 16'h3039);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h0, instruction, 16'hec10, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3039, pc, 15'h2, cpu.d_reg, 16'h3039);
    step = step + 1;
    instruction = 16'h5ba0;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h0, instruction, 16'h5ba0, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3039, pc, 15'h2, cpu.d_reg, 16'h3039);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h0, instruction, 16'h5ba0, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h5ba0, pc, 15'h3, cpu.d_reg, 16'h3039);
    step = step + 1;
    instruction = 16'he1d0;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h0, instruction, 16'he1d0, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h5ba0, pc, 15'h3, cpu.d_reg, 16'h2b67);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h0, instruction, 16'he1d0, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h5ba0, pc, 15'h4, cpu.d_reg, 16'h2b67);
    step = step + 1;
    instruction = 16'h3e8;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h0, instruction, 16'h3e8, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h5ba0, pc, 15'h4, cpu.d_reg, 16'h2b67);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h0, instruction, 16'h3e8, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h5, cpu.d_reg, 16'h2b67);
    step = step + 1;
    instruction = 16'he308;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h0, instruction, 16'he308, reset, 1'h0, outM, 16'h2b67, writeM, 1'h1, addressM, 15'h3e8, pc, 15'h5, cpu.d_reg, 16'h2b67);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h0, instruction, 16'he308, reset, 1'h0, outM, 16'h2b67, writeM, 1'h1, addressM, 15'h3e8, pc, 15'h6, cpu.d_reg, 16'h2b67);
    step = step + 1;
    instruction = 16'h3e9;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h0, instruction, 16'h3e9, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h6, cpu.d_reg, 16'h2b67);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h0, instruction, 16'h3e9, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e9, pc, 15'h7, cpu.d_reg, 16'h2b67);
    step = step + 1;
    instruction = 16'he398;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h0, instruction, 16'he398, reset, 1'h0, outM, 16'h2b66, writeM, 1'h1, addressM, 15'h3e9, pc, 15'h7, cpu.d_reg, 16'h2b66);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h0, instruction, 16'he398, reset, 1'h0, outM, 16'h2b65, writeM, 1'h1, addressM, 15'h3e9, pc, 15'h8, cpu.d_reg, 16'h2b66);
    step = step + 1;
    instruction = 16'h3e8;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h0, instruction, 16'h3e8, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e9, pc, 15'h8, cpu.d_reg, 16'h2b66);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h0, instruction, 16'h3e8, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h9, cpu.d_reg, 16'h2b66);
    step = step + 1;
    instruction = 16'hf4d0;
    inM = 16'h2b67;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'hf4d0, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h9, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'hf4d0, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'ha, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'he;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'ha, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'he, pc, 15'hb, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'he304;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he304, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'he, pc, 15'hb, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he304, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'he, pc, 15'he, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'h3e7;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'h3e7, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'he, pc, 15'he, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'h3e7, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e7, pc, 15'hf, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'hede0;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'hede0, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e7, pc, 15'hf, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'hede0, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h10, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'he308;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he308, reset, 1'h0, outM, 16'hffff, writeM, 1'h1, addressM, 15'h3e8, pc, 15'h10, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he308, reset, 1'h0, outM, 16'hffff, writeM, 1'h1, addressM, 15'h3e8, pc, 15'h11, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'h15;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'h15, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h11, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'h15, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h15, pc, 15'h12, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'he7c2;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he7c2, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h15, pc, 15'h12, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he7c2, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h15, pc, 15'h15, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'h2;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'h2, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h15, pc, 15'h15, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'h2, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h2, pc, 15'h16, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'he090;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he090, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h2, pc, 15'h16, cpu.d_reg, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he090, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h2, pc, 15'h17, cpu.d_reg, 16'h1);
    step = step + 1;
    instruction = 16'h3e8;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'h3e8, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h2, pc, 15'h17, cpu.d_reg, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'h3e8, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h18, cpu.d_reg, 16'h1);
    step = step + 1;
    instruction = 16'hee90;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'hee90, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h18, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'hee90, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h19, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'he301;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he301, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h19, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he301, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h1a, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'he302;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he302, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h1a, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he302, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h1b, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'he303;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he303, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h1b, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he303, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h1c, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'he304;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he304, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h1c, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he304, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'he305;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he305, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he305, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'he306;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he306, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he306, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'he307;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he307, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'hffff);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he307, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'hffff);
    step = step + 1;
    instruction = 16'hea90;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'hea90, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'hea90, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e9, cpu.d_reg, 16'h0);
    step = step + 1;
    instruction = 16'he301;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he301, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e9, cpu.d_reg, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he301, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3ea, cpu.d_reg, 16'h0);
    step = step + 1;
    instruction = 16'he302;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he302, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3ea, cpu.d_reg, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he302, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h0);
    step = step + 1;
    instruction = 16'he303;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he303, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he303, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h0);
    step = step + 1;
    instruction = 16'he304;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he304, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he304, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e9, cpu.d_reg, 16'h0);
    step = step + 1;
    instruction = 16'he305;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he305, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e9, cpu.d_reg, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he305, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3ea, cpu.d_reg, 16'h0);
    step = step + 1;
    instruction = 16'he306;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he306, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3ea, cpu.d_reg, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he306, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h0);
    step = step + 1;
    instruction = 16'he307;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he307, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h0);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he307, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h0);
    step = step + 1;
    instruction = 16'hefd0;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'hefd0, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'hefd0, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e9, cpu.d_reg, 16'h1);
    step = step + 1;
    instruction = 16'he301;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he301, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e9, cpu.d_reg, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he301, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h1);
    step = step + 1;
    instruction = 16'he302;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he302, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he302, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e9, cpu.d_reg, 16'h1);
    step = step + 1;
    instruction = 16'he303;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he303, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e9, cpu.d_reg, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he303, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h1);
    step = step + 1;
    instruction = 16'he304;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he304, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he304, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e9, cpu.d_reg, 16'h1);
    step = step + 1;
    instruction = 16'he305;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he305, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e9, cpu.d_reg, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he305, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h1);
    step = step + 1;
    instruction = 16'he306;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he306, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he306, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e9, cpu.d_reg, 16'h1);
    step = step + 1;
    instruction = 16'he307;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he307, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e9, cpu.d_reg, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he307, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h1);
    step = step + 1;
    reset = 1'h1;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he307, reset, 1'h1, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h3e8, cpu.d_reg, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'he307, reset, 1'h1, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h0, cpu.d_reg, 16'h1);
    step = step + 1;
    instruction = 16'h7fff;
    reset = 1'h0;
    #1; clk = 1'b1; #10;
    tst_check(inM, 16'h2b67, instruction, 16'h7fff, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h3e8, pc, 15'h0, cpu.d_reg, 16'h1);
    step = step + 1;
    clk = 1'b0; #10;
    tst_check(inM, 16'h2b67, instruction, 16'h7fff, reset, 1'h0, outM, {16{1'bx}}, writeM, 1'h0, addressM, 15'h7fff, pc, 15'h1, cpu.d_reg, 16'h1);
    step = step + 1;

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule