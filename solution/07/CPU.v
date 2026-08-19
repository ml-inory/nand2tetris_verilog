`timescale 1ns/1ps

// CPU（posedge 版）：与官方 Hack CPU 功能等价的单边沿实现。
//
// 设计说明：
//   - D / A / PC 全部在 clk 上升沿提交；
//   - outM / writeM / addressM 为组合输出；
//   - 上升沿到来前，outM 是“tick 值”（用旧 D/A 计算），
//     上升沿之后自动变成“tock 值”（用新 D/A 计算）；
//   - Memory 在同一上升沿写入时看到的是上升沿前的 outM，
//     因此内存写入语义与官方版本一致（M 写入 tick 时刻的 ALU 结果）。
//
// 官方 Hack 测试版本（solution/05）保持 negedge 不变，以对齐 .tst/.cmp；
// 本模块供 NPU 集成使用，时钟与 NPU 统一为 posedge。
module n2t_cpu_posedge (
    input         clk,
    input  [15:0] inM,
    input  [15:0] instruction,
    input         reset,
    output [15:0] outM,
    output        writeM,
    output [14:0] addressM,
    output [14:0] pc
);
    reg [15:0] a_reg;
    reg [15:0] d_reg;
    reg [14:0] pc_reg;

    initial begin
        a_reg = 16'h0000;
        d_reg = 16'h0000;
        pc_reg = 15'd0;
    end

    wire is_a_inst = ~instruction[15];

    wire zx = instruction[15] & instruction[11];
    wire nx = instruction[15] & instruction[10];
    wire zy = instruction[15] & instruction[9];
    wire ny = instruction[15] & instruction[8];
    wire f  = instruction[15] & instruction[7];
    wire no = instruction[15] & instruction[6];
    wire am = instruction[15] & instruction[12];
    wire load_a = is_a_inst | (instruction[15] & instruction[5]);
    wire load_d = instruction[15] & instruction[4];
    assign writeM = instruction[15] & instruction[3];

    wire [15:0] alu_out;
    wire zr, ng;

    n2t_alu u_alu(
        .x(d_reg),
        .y(am ? inM : a_reg),
        .zx(zx), .nx(nx), .zy(zy), .ny(ny), .f(f), .no(no),
        .out(alu_out), .zr(zr), .ng(ng)
    );

    // 组合输出：上升沿前是旧 D/A 的结果（tick），
    // 上升沿后自动变为新 D/A 的结果（tock）。
    assign outM = alu_out;
    assign addressM = a_reg[14:0];
    assign pc = pc_reg;

    wire [15:0] next_a =
        is_a_inst                  ? instruction :
        (instruction[15] & instruction[5]) ? alu_out : a_reg;

    wire jlt = instruction[15] & instruction[2] & ng;
    wire jeq = instruction[15] & instruction[1] & zr;
    wire jgt = instruction[15] & instruction[0] & ~(zr | ng);
    wire do_jump = jlt | jeq | jgt;

    always @(posedge clk) begin
        if (reset)
            pc_reg <= 15'd0;
        else if (do_jump)
            pc_reg <= a_reg[14:0];
        else
            pc_reg <= pc_reg + 15'd1;

        if (load_a) a_reg <= next_a;
        if (load_d) d_reg <= alu_out;
    end
endmodule
