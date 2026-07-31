`timescale 1ns/1ps

// Memory：Hack 完整地址空间（RAM16K + Screen + Keyboard）
// 对应 nand2tetris Project 5 的 Memory.hdl
//   address 0x0000-0x3FFF -> RAM16K
//   address 0x4000-0x5FFF -> Screen（8K 字）
//   address 0x6000        -> Keyboard（只读）
module n2t_memory #(
    parameter RAM_INIT_FILE = ""   // RAM 初始化文件（可选，仅仿真用）
) (
    input         clk,
    input  [15:0] in,
    input         load,
    input  [14:0] address,
    input  [15:0] keyboard_in,     // 键盘映射输入（真实 SoC 中来自键盘控制器）
    // 测试背板写口（透传给 RAM16K）
    input         dbg_we,
    input  [13:0] dbg_addr,
    input  [15:0] dbg_wdata,
    output [15:0] out
);
    // 测试台按层级路径读取 u_mem.u_ram.mem[i]，RAM16K 例化名必须为 u_ram。
    // 请补全：地址译码（load_ram）、Screen/Keyboard 映射与输出选择。
    wire        load_ram;
    wire [15:0] ram_out;

    n2t_ram16k #(.INIT_FILE(RAM_INIT_FILE)) u_ram(
        .clk(clk), .in(in), .load(load_ram), .address(address),
        .dbg_we(dbg_we), .dbg_addr(dbg_addr), .dbg_wdata(dbg_wdata),
        .out(ram_out)
    );

    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
