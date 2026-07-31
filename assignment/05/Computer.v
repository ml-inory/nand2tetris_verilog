`timescale 1ns/1ps

// Computer：Hack 整机 = ROM32K + CPU + Memory
// 对应 nand2tetris Project 5 的 Computer.hdl
// 接口在课程版本（仅 reset 输入）基础上增加了 outM/writeM/addressM/pc
// 输出（当前教材版本即如此），以及测试背板写口。
module n2t_computer #(
    parameter ROM_INIT_FILE = "",   // 机器码 .hack 文件
    parameter RAM_INIT_FILE = ""    // RAM 初始化文件（可选）
) (
    input  clk,
    input  reset,
    output [15:0] outM,
    output        writeM,
    output [14:0] addressM,
    output [14:0] pc,
    // 测试背板写口（仅仿真）
    input         dbg_we,
    input  [13:0] dbg_addr,
    input  [15:0] dbg_wdata
);
    // Computer 就是把 ROM / CPU / Memory 三块部件接起来（接线本身也是作业，
    // 但必须保留例化名 u_rom / u_cpu / u_mem：测试台按层级路径读取内部寄存器与内存）。
    wire [15:0] instr, inM;

    n2t_rom32k #(.INIT_FILE(ROM_INIT_FILE)) u_rom(
        .address(pc), .out(instr)
    );

    n2t_cpu u_cpu(
        .clk(clk), .inM(inM), .instruction(instr), .reset(reset),
        .outM(outM), .writeM(writeM), .addressM(addressM), .pc(pc)
    );

    n2t_memory #(.RAM_INIT_FILE(RAM_INIT_FILE)) u_mem(
        .clk(clk), .in(outM), .load(writeM), .address(addressM),
        .keyboard_in(16'h0000),
        .dbg_we(dbg_we), .dbg_addr(dbg_addr), .dbg_wdata(dbg_wdata),
        .out(inM)
    );

    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
