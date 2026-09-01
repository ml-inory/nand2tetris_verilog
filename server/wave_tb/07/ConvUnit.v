`timescale 1ns/1ps

// 波形演示激励：小规模卷积（H=W=4，C_IN=C_OUT=4，stride=1，pad=0），
// 装载特征图 -> 装载权重 -> start -> 观察 out_valid/done。
module ConvUnit_wave_tb;
    localparam H = 4, W = 4, C_IN = 4, C_OUT = 4, K = 3;
    reg clk = 1'b0;
    reg arst = 1'b1;
    reg wr_ifmap = 1'b0;
    reg [C_IN*8-1:0] ifmap_in = 0;
    reg [C_OUT*C_IN*K*K*8-1:0] w_data = 0;
    reg start = 1'b0;
    wire [C_OUT*8-1:0] out_data;
    wire out_valid, done;
    integer p, i, ic, oc, ky, kx;

    n2t_conv_unit #(.H(H), .W(W), .C_IN(C_IN), .C_OUT(C_OUT), .K(K),
                    .STRIDE(1), .PAD(0)) dut (
        .clk(clk), .arst(arst), .wr_ifmap(wr_ifmap), .ifmap_in(ifmap_in),
        .w_data(w_data), .start(start),
        .out_data(out_data), .out_valid(out_valid), .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clk, arst, wr_ifmap, ifmap_in, w_data, start,
                  out_data, out_valid, done);
        repeat (2) @(posedge clk);
        arst = 0; #1;
        wr_ifmap = 1;
        for (p = 0; p < H*W; p = p + 1) begin
            for (ic = 0; ic < C_IN; ic = ic + 1)
                ifmap_in[ic*8 +: 8] = $signed((p*3 + ic*5) % 17 - 8);
            @(posedge clk); #1;
        end
        wr_ifmap = 0;
        for (oc = 0; oc < C_OUT; oc = oc + 1)
            for (ic = 0; ic < C_IN; ic = ic + 1)
                for (ky = 0; ky < K; ky = ky + 1)
                    for (kx = 0; kx < K; kx = kx + 1)
                        w_data[((oc*C_IN + ic)*K*K + ky*K + kx)*8 +: 8] =
                            $signed(((oc+1)*(ic+2) + ky*3 + kx) % 15 - 7);
        start = 1; @(posedge clk); #1;
        start = 0;
        // 跑完整个推理
        for (i = 0; i < 200; i = i + 1) begin
            if (done) $finish;
            @(posedge clk); #1;
        end
        $finish;
    end
endmodule
