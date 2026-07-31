`timescale 1ns/1ps

// CPU：Hack CPU，包含 A/D 寄存器、ALU 与程序计数器 PC
// 对应 nand2tetris Project 5 的 CPU.hdl
//
// 时序模型与官方硬件模拟器逐拍一致（参考 nand2tetris 官方实现）：
//   tick（上升沿）：
//     - D 寄存器采样 ALU 结果（用更新前的 D/A 计算）
//     - outM 更新为 tick 时刻的 ALU 结果；writeM 为组合输出
//     - 暂存 tick 时刻的 ALU 结果与标志位（供 tock 使用）
//   tock（下降沿）：
//     - A 寄存器、PC 提交
//     - outM 用“更新后的 D + 新 A”重算并提交（与官方一致）
//   DRegister[] 探针读到的是 tick 时刻采样的 D 值（与官方测试一致）
module n2t_cpu (
    input         clk,
    input  [15:0] inM,
    input  [15:0] instruction,
    input         reset,
    output reg [15:0] outM,
    output        writeM,
    output [14:0] addressM,
    output [14:0] pc
);
    reg [15:0] a_reg;      // A 寄存器（tock 提交）
    reg [15:0] d_reg;      // D 寄存器（tick 采样，测试探针读取）
    reg [14:0] pc_reg;     // PC（tock 提交）
    reg [15:0] alu_tick;   // tick 时刻的 ALU 结果（供 tock 的 A 更新使用）
    reg [1:0]  flags_tick; // tick 时刻的 {ng, zr}（供 tock 的跳转判定使用）

    initial begin
        a_reg = 16'h0000; d_reg = 16'h0000; pc_reg = 15'd0;
        alu_tick = 16'h0000; flags_tick = 2'b00; outM = 16'h0000;
    end

    wire is_a_inst = ~instruction[15];

    // ---- 控制信号（C 指令的各个位，A 指令时全部为 0）----
    wire zx = instruction[15] & instruction[11];
    wire nx = instruction[15] & instruction[10];
    wire zy = instruction[15] & instruction[9];
    wire ny = instruction[15] & instruction[8];
    wire f  = instruction[15] & instruction[7];
    wire no = instruction[15] & instruction[6];
    wire am = instruction[15] & instruction[12];  // y 选择 M（而不是 A）
    wire load_a = is_a_inst | (instruction[15] & instruction[5]); // 写入 A
    wire load_d = instruction[15] & instruction[4];               // 写入 D
    assign writeM = instruction[15] & instruction[3];             // 写内存

    // ---- tick 时刻的 ALU：x = D，y = A 或 M（用当前 D/A）----
    wire [15:0] alu_tick_out, alu_tock_out;
    wire zr_t, ng_t, zr_c, ng_c;

    n2t_alu u_alu_tick(
        .x(d_reg),
        .y(am ? inM : a_reg),
        .zx(zx), .nx(nx), .zy(zy), .ny(ny), .f(f), .no(no),
        .out(alu_tick_out), .zr(zr_t), .ng(ng_t)
    );

    // ---- tock 重算的 ALU：x = D（已更新），y = 新 A 或 M ----
    wire [15:0] next_a =
        is_a_inst                      ? instruction :
        (instruction[15] & instruction[5]) ? alu_tick : a_reg;

    n2t_alu u_alu_tock(
        .x(d_reg),
        .y(am ? inM : next_a),
        .zx(zx), .nx(nx), .zy(zy), .ny(ny), .f(f), .no(no),
        .out(alu_tock_out), .zr(zr_c), .ng(ng_c)
    );

    assign addressM = a_reg[14:0];

    // ---- tick：D 采样、暂存 ALU/标志位、outM 更新 ----
    always @(posedge clk) begin
        alu_tick   <= alu_tick_out;
        flags_tick <= {ng_t, zr_t};
        if (load_d) d_reg <= alu_tick_out;
        outM       <= alu_tick_out;
    end

    // ---- 跳转条件（基于 tick 时刻的标志位）----
    wire jlt = instruction[15] & instruction[2] & flags_tick[1];
    wire jeq = instruction[15] & instruction[1] & flags_tick[0];
    wire jgt = instruction[15] & instruction[0] & ~(flags_tick[0] | flags_tick[1]);
    wire do_jump = jlt | jeq | jgt;

    // ---- tock：A / PC / outM 提交 ----
    always @(negedge clk) begin
        a_reg <= next_a;

        if (reset)        pc_reg <= 15'd0;
        else if (do_jump) pc_reg <= a_reg[14:0];
        else              pc_reg <= pc_reg + 15'd1;

        outM <= alu_tock_out;
    end

    assign pc = pc_reg;
endmodule
