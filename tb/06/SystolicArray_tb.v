`timescale 1ns/1ps

// SystolicArray 单元测试：N x N 的 int8 矩阵乘。
// 验证 C[k][col] = sum_row A[row][k] * W[row][col]。
module SystolicArray_tb;

    localparam N   = 8;
    localparam A_W = 8;
    localparam W_W = 8;
    localparam P_W = 32;

    reg clk = 1'b0;
    reg rst = 1'b1;
    reg w_load = 1'b0;
    reg [N*N*W_W-1:0] w_data = 0;
    reg [N*A_W-1:0] a_data = 0;
    wire [N*P_W-1:0] psum_out;

    reg signed [A_W-1:0] A_mat [0:N-1][0:N-1];
    reg signed [W_W-1:0] W_mat [0:N-1][0:N-1];
    integer exp_mat [0:N-1][0:N-1];

    integer i, j, k, r;
    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_systolic_array #(
        .N(N),
        .A_W(A_W),
        .W_W(W_W),
        .P_W(P_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .w_load(w_load),
        .w_data(w_data),
        .a_data(a_data),
        .psum_out(psum_out)
    );

    always #5 clk = ~clk;

    task tst_check;
        input integer row_k;
        input integer col;
        input signed [P_W-1:0] got;
        input signed [P_W-1:0] exp;
        begin
            step = step + 1;
            if (got !== exp) begin
                $display("FAIL [step %0d] C[%0d][%0d]: got %0d exp %0d",
                         step, row_k, col, got, exp);
                nfail = nfail + 1;
            end else begin
                npass = npass + 1;
            end
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("sim/SystolicArray_tb.vcd");
        $dumpvars(0, dut);
    end
`endif

    initial begin
        $display("=== SystolicArray ===");

        // 构造测试矩阵：A[row][k]，W[row][col]，保证结果不溢出 int32
        for (r = 0; r < N; r = r + 1) begin
            for (k = 0; k < N; k = k + 1) begin
                A_mat[r][k] = $signed(r*3 - k*2 + 1);
            end
            for (j = 0; j < N; j = j + 1) begin
                W_mat[r][j] = $signed(r + j*2 - 5);
            end
        end

        // 软件期望：C[k][col] = sum_row A[row][k] * W[row][col]
        for (k = 0; k < N; k = k + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                exp_mat[k][j] = 0;
                for (r = 0; r < N; r = r + 1) begin
                    exp_mat[k][j] = exp_mat[k][j] + A_mat[r][k] * W_mat[r][j];
                end
            end
        end

        // 复位
        repeat (2) @(posedge clk);
        rst = 1'b0;
        #1;

        // 批量装载权重
        w_load = 1'b1;
        for (r = 0; r < N; r = r + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                w_data[(r*N + j)*W_W +: W_W] = W_mat[r][j];
            end
        end
        @(posedge clk);
        #1;
        w_load = 1'b0;

        // 逐拍送入 A 的 k 列向量（k = 0..N-1）
        for (k = 0; k < N; k = k + 1) begin
            for (r = 0; r < N; r = r + 1) begin
                a_data[r*A_W +: A_W] = A_mat[r][k];
            end
            @(posedge clk);
            #1;
        end

        // 保持最后一拍输入让流水排空；
        // 输出对齐后，第一个完整结果在最后一个输入送入后再等 N-1 拍出现。
        repeat (N-1) @(posedge clk);
        #1;
        for (k = 0; k < N; k = k + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                tst_check(k, j,
                          $signed(psum_out[j*P_W +: P_W]),
                          exp_mat[k][j]);
            end
            @(posedge clk);
            #1;
        end

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule
