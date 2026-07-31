`timescale 1ns/1ps

// 本文件由 tools/tst2tb.py 自动生成，请勿手工编辑。
// 对应官方测试：ref/02/ALU.tst / ref/02/ALU.cmp
module ALU_tb;

    reg  [15:0] x = 16'h0;
    reg  [15:0] y = 16'h0;
    reg  [0:0] zx = 1'h0;
    reg  [0:0] nx = 1'h0;
    reg  [0:0] zy = 1'h0;
    reg  [0:0] ny = 1'h0;
    reg  [0:0] f = 1'h0;
    reg  [0:0] no = 1'h0;
    wire [15:0] out;
    wire [0:0] zr;
    wire [0:0] ng;

    integer step = 0;
    integer npass = 0, nfail = 0;

    n2t_alu dut(
        .x(x),
        .y(y),
        .zx(zx),
        .nx(nx),
        .zy(zy),
        .ny(ny),
        .f(f),
        .no(no),
        .out(out),
        .zr(zr),
        .ng(ng)
    );

    task tst_check;
        input [15:0] x;
        input [15:0] exp_x;
        input [15:0] y;
        input [15:0] exp_y;
        input [0:0] zx;
        input [0:0] exp_zx;
        input [0:0] nx;
        input [0:0] exp_nx;
        input [0:0] zy;
        input [0:0] exp_zy;
        input [0:0] ny;
        input [0:0] exp_ny;
        input [0:0] f;
        input [0:0] exp_f;
        input [0:0] no;
        input [0:0] exp_no;
        input [15:0] out;
        input [15:0] exp_out;
        input [0:0] zr;
        input [0:0] exp_zr;
        input [0:0] ng;
        input [0:0] exp_ng;
        begin
            if (exp_x === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (x !== exp_x) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "x", x, exp_x);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_y === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (y !== exp_y) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "y", y, exp_y);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_zx === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (zx !== exp_zx) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "zx", zx, exp_zx);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_nx === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (nx !== exp_nx) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "nx", nx, exp_nx);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_zy === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (zy !== exp_zy) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "zy", zy, exp_zy);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_ny === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (ny !== exp_ny) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "ny", ny, exp_ny);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_f === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (f !== exp_f) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "f", f, exp_f);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_no === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (no !== exp_no) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "no", no, exp_no);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_out === {16{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (out !== exp_out) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "out", out, exp_out);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_zr === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (zr !== exp_zr) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "zr", zr, exp_zr);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
            if (exp_ng === {1{1'bx}}) begin
                npass = npass + 1;
            end else begin
                if (ng !== exp_ng) begin
                    $display("FAIL [step %0d] %s: got %h exp %h", step, "ng", ng, exp_ng);
                    nfail = nfail + 1;
                end else begin
                    npass = npass + 1;
                end
            end
        end
    endtask

`ifdef DUMP_VCD
    initial begin
        $dumpfile("sim/ALU_tb.vcd");
        $dumpvars(0, dut);
    end
`endif

    initial begin
        $display("=== ALU ===");
    x = 16'h0;
    y = 16'hffff;
    zx = 1'h1;
    nx = 1'h0;
    zy = 1'h1;
    ny = 1'h0;
    f = 1'h1;
    no = 1'h0;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h1, nx, 1'h0, zy, 1'h1, ny, 1'h0, f, 1'h1, no, 1'h0, out, 16'h0, zr, 1'h1, ng, 1'h0);
    step = step + 1;
    zx = 1'h1;
    nx = 1'h1;
    zy = 1'h1;
    ny = 1'h1;
    f = 1'h1;
    no = 1'h1;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h1, nx, 1'h1, zy, 1'h1, ny, 1'h1, f, 1'h1, no, 1'h1, out, 16'h1, zr, 1'h0, ng, 1'h0);
    step = step + 1;
    zx = 1'h1;
    nx = 1'h1;
    zy = 1'h1;
    ny = 1'h0;
    f = 1'h1;
    no = 1'h0;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h1, nx, 1'h1, zy, 1'h1, ny, 1'h0, f, 1'h1, no, 1'h0, out, 16'hffff, zr, 1'h0, ng, 1'h1);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h0;
    zy = 1'h1;
    ny = 1'h1;
    f = 1'h0;
    no = 1'h0;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h0, nx, 1'h0, zy, 1'h1, ny, 1'h1, f, 1'h0, no, 1'h0, out, 16'h0, zr, 1'h1, ng, 1'h0);
    step = step + 1;
    zx = 1'h1;
    nx = 1'h1;
    zy = 1'h0;
    ny = 1'h0;
    f = 1'h0;
    no = 1'h0;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h1, nx, 1'h1, zy, 1'h0, ny, 1'h0, f, 1'h0, no, 1'h0, out, 16'hffff, zr, 1'h0, ng, 1'h1);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h0;
    zy = 1'h1;
    ny = 1'h1;
    f = 1'h0;
    no = 1'h1;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h0, nx, 1'h0, zy, 1'h1, ny, 1'h1, f, 1'h0, no, 1'h1, out, 16'hffff, zr, 1'h0, ng, 1'h1);
    step = step + 1;
    zx = 1'h1;
    nx = 1'h1;
    zy = 1'h0;
    ny = 1'h0;
    f = 1'h0;
    no = 1'h1;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h1, nx, 1'h1, zy, 1'h0, ny, 1'h0, f, 1'h0, no, 1'h1, out, 16'h0, zr, 1'h1, ng, 1'h0);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h0;
    zy = 1'h1;
    ny = 1'h1;
    f = 1'h1;
    no = 1'h1;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h0, nx, 1'h0, zy, 1'h1, ny, 1'h1, f, 1'h1, no, 1'h1, out, 16'h0, zr, 1'h1, ng, 1'h0);
    step = step + 1;
    zx = 1'h1;
    nx = 1'h1;
    zy = 1'h0;
    ny = 1'h0;
    f = 1'h1;
    no = 1'h1;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h1, nx, 1'h1, zy, 1'h0, ny, 1'h0, f, 1'h1, no, 1'h1, out, 16'h1, zr, 1'h0, ng, 1'h0);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h1;
    zy = 1'h1;
    ny = 1'h1;
    f = 1'h1;
    no = 1'h1;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h0, nx, 1'h1, zy, 1'h1, ny, 1'h1, f, 1'h1, no, 1'h1, out, 16'h1, zr, 1'h0, ng, 1'h0);
    step = step + 1;
    zx = 1'h1;
    nx = 1'h1;
    zy = 1'h0;
    ny = 1'h1;
    f = 1'h1;
    no = 1'h1;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h1, nx, 1'h1, zy, 1'h0, ny, 1'h1, f, 1'h1, no, 1'h1, out, 16'h0, zr, 1'h1, ng, 1'h0);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h0;
    zy = 1'h1;
    ny = 1'h1;
    f = 1'h1;
    no = 1'h0;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h0, nx, 1'h0, zy, 1'h1, ny, 1'h1, f, 1'h1, no, 1'h0, out, 16'hffff, zr, 1'h0, ng, 1'h1);
    step = step + 1;
    zx = 1'h1;
    nx = 1'h1;
    zy = 1'h0;
    ny = 1'h0;
    f = 1'h1;
    no = 1'h0;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h1, nx, 1'h1, zy, 1'h0, ny, 1'h0, f, 1'h1, no, 1'h0, out, 16'hfffe, zr, 1'h0, ng, 1'h1);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h0;
    zy = 1'h0;
    ny = 1'h0;
    f = 1'h1;
    no = 1'h0;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h0, nx, 1'h0, zy, 1'h0, ny, 1'h0, f, 1'h1, no, 1'h0, out, 16'hffff, zr, 1'h0, ng, 1'h1);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h1;
    zy = 1'h0;
    ny = 1'h0;
    f = 1'h1;
    no = 1'h1;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h0, nx, 1'h1, zy, 1'h0, ny, 1'h0, f, 1'h1, no, 1'h1, out, 16'h1, zr, 1'h0, ng, 1'h0);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h0;
    zy = 1'h0;
    ny = 1'h1;
    f = 1'h1;
    no = 1'h1;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h0, nx, 1'h0, zy, 1'h0, ny, 1'h1, f, 1'h1, no, 1'h1, out, 16'hffff, zr, 1'h0, ng, 1'h1);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h0;
    zy = 1'h0;
    ny = 1'h0;
    f = 1'h0;
    no = 1'h0;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h0, nx, 1'h0, zy, 1'h0, ny, 1'h0, f, 1'h0, no, 1'h0, out, 16'h0, zr, 1'h1, ng, 1'h0);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h1;
    zy = 1'h0;
    ny = 1'h1;
    f = 1'h0;
    no = 1'h1;
    #10;
    tst_check(x, 16'h0, y, 16'hffff, zx, 1'h0, nx, 1'h1, zy, 1'h0, ny, 1'h1, f, 1'h0, no, 1'h1, out, 16'hffff, zr, 1'h0, ng, 1'h1);
    step = step + 1;
    x = 16'h11;
    y = 16'h3;
    zx = 1'h1;
    nx = 1'h0;
    zy = 1'h1;
    ny = 1'h0;
    f = 1'h1;
    no = 1'h0;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h1, nx, 1'h0, zy, 1'h1, ny, 1'h0, f, 1'h1, no, 1'h0, out, 16'h0, zr, 1'h1, ng, 1'h0);
    step = step + 1;
    zx = 1'h1;
    nx = 1'h1;
    zy = 1'h1;
    ny = 1'h1;
    f = 1'h1;
    no = 1'h1;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h1, nx, 1'h1, zy, 1'h1, ny, 1'h1, f, 1'h1, no, 1'h1, out, 16'h1, zr, 1'h0, ng, 1'h0);
    step = step + 1;
    zx = 1'h1;
    nx = 1'h1;
    zy = 1'h1;
    ny = 1'h0;
    f = 1'h1;
    no = 1'h0;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h1, nx, 1'h1, zy, 1'h1, ny, 1'h0, f, 1'h1, no, 1'h0, out, 16'hffff, zr, 1'h0, ng, 1'h1);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h0;
    zy = 1'h1;
    ny = 1'h1;
    f = 1'h0;
    no = 1'h0;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h0, nx, 1'h0, zy, 1'h1, ny, 1'h1, f, 1'h0, no, 1'h0, out, 16'h11, zr, 1'h0, ng, 1'h0);
    step = step + 1;
    zx = 1'h1;
    nx = 1'h1;
    zy = 1'h0;
    ny = 1'h0;
    f = 1'h0;
    no = 1'h0;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h1, nx, 1'h1, zy, 1'h0, ny, 1'h0, f, 1'h0, no, 1'h0, out, 16'h3, zr, 1'h0, ng, 1'h0);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h0;
    zy = 1'h1;
    ny = 1'h1;
    f = 1'h0;
    no = 1'h1;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h0, nx, 1'h0, zy, 1'h1, ny, 1'h1, f, 1'h0, no, 1'h1, out, 16'hffee, zr, 1'h0, ng, 1'h1);
    step = step + 1;
    zx = 1'h1;
    nx = 1'h1;
    zy = 1'h0;
    ny = 1'h0;
    f = 1'h0;
    no = 1'h1;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h1, nx, 1'h1, zy, 1'h0, ny, 1'h0, f, 1'h0, no, 1'h1, out, 16'hfffc, zr, 1'h0, ng, 1'h1);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h0;
    zy = 1'h1;
    ny = 1'h1;
    f = 1'h1;
    no = 1'h1;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h0, nx, 1'h0, zy, 1'h1, ny, 1'h1, f, 1'h1, no, 1'h1, out, 16'hffef, zr, 1'h0, ng, 1'h1);
    step = step + 1;
    zx = 1'h1;
    nx = 1'h1;
    zy = 1'h0;
    ny = 1'h0;
    f = 1'h1;
    no = 1'h1;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h1, nx, 1'h1, zy, 1'h0, ny, 1'h0, f, 1'h1, no, 1'h1, out, 16'hfffd, zr, 1'h0, ng, 1'h1);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h1;
    zy = 1'h1;
    ny = 1'h1;
    f = 1'h1;
    no = 1'h1;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h0, nx, 1'h1, zy, 1'h1, ny, 1'h1, f, 1'h1, no, 1'h1, out, 16'h12, zr, 1'h0, ng, 1'h0);
    step = step + 1;
    zx = 1'h1;
    nx = 1'h1;
    zy = 1'h0;
    ny = 1'h1;
    f = 1'h1;
    no = 1'h1;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h1, nx, 1'h1, zy, 1'h0, ny, 1'h1, f, 1'h1, no, 1'h1, out, 16'h4, zr, 1'h0, ng, 1'h0);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h0;
    zy = 1'h1;
    ny = 1'h1;
    f = 1'h1;
    no = 1'h0;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h0, nx, 1'h0, zy, 1'h1, ny, 1'h1, f, 1'h1, no, 1'h0, out, 16'h10, zr, 1'h0, ng, 1'h0);
    step = step + 1;
    zx = 1'h1;
    nx = 1'h1;
    zy = 1'h0;
    ny = 1'h0;
    f = 1'h1;
    no = 1'h0;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h1, nx, 1'h1, zy, 1'h0, ny, 1'h0, f, 1'h1, no, 1'h0, out, 16'h2, zr, 1'h0, ng, 1'h0);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h0;
    zy = 1'h0;
    ny = 1'h0;
    f = 1'h1;
    no = 1'h0;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h0, nx, 1'h0, zy, 1'h0, ny, 1'h0, f, 1'h1, no, 1'h0, out, 16'h14, zr, 1'h0, ng, 1'h0);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h1;
    zy = 1'h0;
    ny = 1'h0;
    f = 1'h1;
    no = 1'h1;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h0, nx, 1'h1, zy, 1'h0, ny, 1'h0, f, 1'h1, no, 1'h1, out, 16'he, zr, 1'h0, ng, 1'h0);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h0;
    zy = 1'h0;
    ny = 1'h1;
    f = 1'h1;
    no = 1'h1;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h0, nx, 1'h0, zy, 1'h0, ny, 1'h1, f, 1'h1, no, 1'h1, out, 16'hfff2, zr, 1'h0, ng, 1'h1);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h0;
    zy = 1'h0;
    ny = 1'h0;
    f = 1'h0;
    no = 1'h0;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h0, nx, 1'h0, zy, 1'h0, ny, 1'h0, f, 1'h0, no, 1'h0, out, 16'h1, zr, 1'h0, ng, 1'h0);
    step = step + 1;
    zx = 1'h0;
    nx = 1'h1;
    zy = 1'h0;
    ny = 1'h1;
    f = 1'h0;
    no = 1'h1;
    #10;
    tst_check(x, 16'h11, y, 16'h3, zx, 1'h0, nx, 1'h1, zy, 1'h0, ny, 1'h1, f, 1'h0, no, 1'h1, out, 16'h13, zr, 1'h0, ng, 1'h0);
    step = step + 1;

        if (nfail == 0)
            $display("PASS: all checks ok (total %0d)", npass);
        else
            $display("FAIL: %0d errors out of %0d checks", nfail, npass + nfail);
        $finish;
    end
endmodule