`timescale 1ns/1ps

// RAM16K：16K x 16 主内存
// 课程里由 4 个 RAM4K 拼成；这里用扁平存储阵列实现，
// 更接近真实 RTL（综合工具会把它推断为 Block RAM），
// 并通过参数 INIT_FILE / 背板写口支持测试预置。
// 对应 nand2tetris Project 3 的 RAM16K.hdl
module n2t_ram16k #(
    parameter INIT_FILE = ""   // 十六进制初始化文件（可选，仅仿真用）
) (
    input         clk,
    input  [15:0] in,
    input         load,
    input  [14:0] address,     // 与课程一致：address[14] 未使用
    // 测试背板写口（仅仿真，综合时忽略）
    input         dbg_we,
    input  [13:0] dbg_addr,
    input  [15:0] dbg_wdata,
    output [15:0] out
);
    // 测试台按层级路径读取 u_comp.u_mem.u_ram.mem[i]，
    // 存储数组必须命名为 mem（对应课程内置 RAM16K）。
    reg [15:0] mem [0:16383];

    // ==================== 作业：请补全本模块实现 ====================
    // 提示：参考 nand2tetris 对应 Project 的 HDL 描述。
    // 可以例化更小的 n2t_* 模块（结构式写法），也可以用行为式写法；
    // 完成后执行 `make sim-0X RTLDIR=assignment` 验证（0X 为项目号）。

endmodule
