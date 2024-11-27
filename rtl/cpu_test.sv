`default_nettype none
`timescale 1ns / 1ps

module cpu_test();
    reg clk;
    logic rst;
    logic imem_rst;
    logic tx;

    logic CEN_dmem [0:3];
    logic GWEN_dmem [0:3];
    logic [7:0] WEN_dmem [0:3];
    logic [8:0] A_dmem [0:3];
    logic [7:0] D_dmem [0:3];
    logic [7:0] Q_dmem [0:3];

    wire CEN_dmem_cpu [0:3];
    wire GWEN_dmem_cpu [0:3];
    wire [7:0] WEN_dmem_cpu [0:3];
    wire [8:0] A_dmem_cpu [0:3];
    wire [7:0] D_dmem_cpu [0:3];

    logic CEN_dmem_init [0:3];
    logic GWEN_dmem_init [0:3];
    logic [7:0] WEN_dmem_init [0:3];
    logic [8:0] A_dmem_init [0:3];
    logic [7:0] D_dmem_init [0:3];

    logic CEN_imem [0:3];
    logic GWEN_imem [0:3];
    logic [7:0] WEN_imem [0:3];
    logic [8:0] A_imem [0:3];
    logic [7:0] D_imem [0:3];
    logic [7:0] Q_imem [0:3];

    wire CEN_imem_cpu [0:3];
    wire GWEN_imem_cpu [0:3];
    wire [7:0] WEN_imem_cpu [0:3];
    wire [8:0] A_imem_cpu [0:3];
    wire [7:0] D_imem_cpu [0:3];

    logic CEN_imem_init [0:3];
    logic GWEN_imem_init [0:3];
    logic [7:0] WEN_imem_init [0:3];
    logic [8:0] A_imem_init [0:3];
    logic [7:0] D_imem_init [0:3];

    Top top(
        .clk(clk),
        .rst(rst),
        .tx(tx),
        .rx(tx),
        .CEN_dmem(CEN_dmem_cpu),
        .GWEN_dmem(GWEN_dmem_cpu),
        .WEN_dmem(WEN_dmem_cpu),
        .A_dmem(A_dmem_cpu),
        .D_dmem(D_dmem_cpu),
        .Q_dmem(Q_dmem),
        .CEN_imem(CEN_imem_cpu),
        .GWEN_imem(GWEN_imem_cpu),
        .WEN_imem(WEN_imem_cpu),
        .A_imem(A_imem_cpu),
        .D_imem(D_imem_cpu),
        .Q_imem(Q_imem),
        .gpio_in(32'h87654321)
        );

    localparam mem_size = 4096;
    logic [7:0] imem_buff [0:mem_size-1];
    logic [7:0] dmem_buff [0:mem_size-1];
    string imem_hex, dmem_hex, log_dump, vcd_dump;
    int log_file, imem_file, dmem_file;
    initial begin
        if (!$value$plusargs("inst=%s", imem_hex) || !$value$plusargs("data=%s", dmem_hex)) begin
            $display("Please specify a hex file.");
            $display("Usage: ./obj_dir/Vcpu_test +inst=[path/to/inst] +data=[path/to/data.hex");
            $finish;
        end

        imem_file = $fopen(imem_hex, "r");
        dmem_file = $fopen(dmem_hex, "r");
        if (imem_file == 0) begin
          $display("File not found: %s", imem_hex);
          $finish;
        end
        if (dmem_file == 0) begin
          $display("File not found: %s", dmem_hex);
        end

        if (!$value$plusargs("vcd=%s", vcd_dump)) begin
          vcd_dump = "cpu.vcd";
        end
        $dumpfile(vcd_dump);
        $dumpvars(0);
        for (int i = 0; i < 32; i++) begin
            $dumpvars(0, top.core.reg_file.regfile[i]);
        end
        for (int i = 0; i < 4; i++) begin
            $dumpvars(0, top.instruction_memory.CEN[i]);
            $dumpvars(0, CEN_imem_cpu[i]);
            $dumpvars(0, CEN_dmem_cpu[i]);
            $dumpvars(0, top.CEN_imem[i]);
            $dumpvars(0, top.CEN_dmem[i]);
        end
        // 命令・データメモリの初期化
        $readmemh(imem_hex, imem_buff, 0, mem_size-1);
        $readmemh(dmem_hex, dmem_buff, 0, mem_size-1);
        $fclose(imem_file);
        $fclose(dmem_file);
        // 最初のサイクルではCENをhighにする
        clk = 0;
        rst = 1;
        for(int i=0; i<4; i++) CEN_imem_init[i] = 1;
        for(int i=0; i<4; i++) CEN_dmem_init[i] = 1;
        @(posedge clk)
        @(posedge clk)
        for(int pc=0; pc < 512; pc++) begin
            @(posedge clk)
            for(int i=0;i<4;i++) begin
                CEN_imem_init[i] = 0;
                GWEN_imem_init[i] = 0;
                WEN_imem_init[i]  = 8'b0;
                A_imem_init[i] = pc;
                D_imem_init[i] = imem_buff[pc*4+i];

                CEN_dmem_init[i] = 0;
                GWEN_dmem_init[i] = 0;
                WEN_dmem_init[i]  = 8'b0;
                A_dmem_init[i] = pc;
                D_dmem_init[i] = dmem_buff[pc*4+i];
            end
        end
        rst = 0;

        //リセット
        clk = 0;
        rst = 1;
        @(posedge clk)
        @(posedge clk)
        rst = 0;
        @(posedge clk)
        #1000000

        // テスト結果の出力設定
        if (!$value$plusargs("log=%s", log_dump)) begin
          log_dump = "result.log";
        end
        log_file = $fopen(log_dump, "a");
        if (top.core.reg_file.regfile[3] == 1) begin
            $fdisplay(log_file, "[     OK     ]   %s", imem_hex);
        end else begin
            $fdisplay(log_file, "[FAILED (%3d)]   %s", int'(top.core.reg_file.regfile[3]), imem_hex);
        end
        $fclose(log_file);
        $finish;
    end
    always #(500) begin
        clk <= ~clk;
    end

    always_comb begin
        for(int i=0;i<4;i++) begin
            CEN_imem[i] = rst ? CEN_imem_init[i] : CEN_imem_cpu[i];
            GWEN_imem[i] = rst ? GWEN_imem_init[i] : GWEN_imem_cpu[i];
            WEN_imem[i]  = rst ? WEN_imem_init[i]  : WEN_imem_cpu[i];
            A_imem[i]    = rst ? A_imem_init[i]    : A_imem_cpu[i];
            D_imem[i]    = rst ? D_imem_init[i]    : D_imem_cpu[i];

            CEN_dmem[i] = rst ? CEN_dmem_init[i] : CEN_dmem_cpu[i];
            GWEN_dmem[i] = rst ? GWEN_dmem_init[i] : GWEN_dmem_cpu[i];
            WEN_dmem[i]  = rst ? WEN_dmem_init[i]  : WEN_dmem_cpu[i];
            A_dmem[i]    = rst ? A_dmem_init[i]    : A_dmem_cpu[i];
            D_dmem[i]    = rst ? D_dmem_init[i]    : D_dmem_cpu[i];
        end
    end

    sram dmem_0(
        .CLK(clk),
        .CEN(CEN_dmem[0]),
        .GWEN(GWEN_dmem[0]),
        .WEN(WEN_dmem[0]),
        .A(A_dmem[0]),
        .D(D_dmem[0]),
        .Q(Q_dmem[0])
    );
    sram dmem_1(
        .CLK(clk),
        .CEN(CEN_dmem[1]),
        .GWEN(GWEN_dmem[1]),
        .WEN(WEN_dmem[1]),
        .A(A_dmem[1]),
        .D(D_dmem[1]),
        .Q(Q_dmem[1])
    );
    sram dmem_2(
        .CLK(clk),
        .CEN(CEN_dmem[2]),
        .GWEN(GWEN_dmem[2]),
        .WEN(WEN_dmem[2]),
        .A(A_dmem[2]),
        .D(D_dmem[2]),
        .Q(Q_dmem[2])
    );
    sram dmem_3(
        .CLK(clk),
        .CEN(CEN_dmem[3]),
        .GWEN(GWEN_dmem[3]),
        .WEN(WEN_dmem[3]),
        .A(A_dmem[3]),
        .D(D_dmem[3]),
        .Q(Q_dmem[3])
    );

    sram imem_0(
        .CLK(clk),
        .CEN(CEN_imem[0]),
        .GWEN(GWEN_imem[0]),
        .WEN(WEN_imem[0]),
        .A(A_imem[0]),
        .D(D_imem[0]),
        .Q(Q_imem[0])
    );
    sram imem_1(
        .CLK(clk),
        .CEN(CEN_imem[1]),
        .GWEN(GWEN_imem[1]),
        .WEN(WEN_imem[1]),
        .A(A_imem[1]),
        .D(D_imem[1]),
        .Q(Q_imem[1])
    );
    sram imem_2(
        .CLK(clk),
        .CEN(CEN_imem[2]),
        .GWEN(GWEN_imem[2]),
        .WEN(WEN_imem[2]),
        .A(A_imem[2]),
        .D(D_imem[2]),
        .Q(Q_imem[2])
    );
    sram imem_3(
        .CLK(clk),
        .CEN(CEN_imem[3]),
        .GWEN(GWEN_imem[3]),
        .WEN(WEN_imem[3]),
        .A(A_imem[3]),
        .D(D_imem[3]),
        .Q(Q_imem[3])
    );
endmodule
`default_nettype wire
