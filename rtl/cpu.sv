`default_nettype none
`timescale 1ns / 1ps

module cpu(
    input  wire        clk,
    input  wire        rst,

    output wire        tx,
    input  wire        rx,
    output wire [31:0] gpio_out,
    input  wire [31:0] gpio_in
);
    logic CEN_dmem [0:3];
    logic GWEN_dmem [0:3];
    logic [7:0] WEN_dmem [0:3];
    logic [8:0] A_dmem [0:3];
    logic [7:0] D_dmem [0:3];
    logic [7:0] Q_dmem [0:3];

    logic CEN_imem [0:3];
    logic GWEN_imem [0:3];
    logic [7:0] WEN_imem [0:3];
    logic [8:0] A_imem [0:3];
    logic [7:0] D_imem [0:3];
    logic [7:0] Q_imem [0:3];

    Top top(.*);

    string inst_hex_pattern, data_hex_pattern;
    string inst_hexfiles [3:0];
    string data_hexfiles [3:0];
    string vcd_logfile;

    function string replace_atmark(string orig, string ch);
        int i;
        begin
            i = 0;
            while (i != orig.len() && orig[i] != "@") begin
                i++;
            end

            if (i == orig.len()) begin
                $display("The pattern must contain \"@\".");
                $display("When you want to use test.inst.bank[0-3].hex: +inst=test.inst.bank@.hex");
                $finish;
            end

            // orig[i] = ch は暗黙の型変換で弾かれる
            orig = {orig.substr(0, i-1), ch, orig.substr(i+1, orig.len()-1)};
            return orig;
        end
    endfunction

    int i;
    string tmp;
    initial begin
        if (!$value$plusargs("inst=%s", inst_hex_pattern)) begin
            $display("Please specify the file name pattern to be used in initializing the instruction memory.");
            $display("Usage: ./Vcpu_test +inst=/path/to/hexfile.inst.bank@.hex +data=/path/to/hexfile.data.bank@.hex");
            $finish;
        end
        if (!$value$plusargs("data=%s", data_hex_pattern)) begin
            $display("Please specify the file name pattern to be used in initializing the data memory.");
            $display("Usage: ./Vcpu_test +inst=/path/to/hexfile.inst.bank@.hex +data=/path/to/hexfile.data.bank@.hex");
            $finish;
        end
        if (!$value$plusargs("vcd=%s", vcd_logfile)) begin
            vcd_logfile = "cpu.vcd";
        end

        // hexファイルの名前パターンが引数で指定されるので、各ファイル名を生成する
        // "@" をバンク番号に置き換えればOK
        i = 0;
        while(i < 4) begin
            tmp.itoa(i);
            inst_hexfiles[i] = replace_atmark(inst_hex_pattern, tmp);
            data_hexfiles[i] = replace_atmark(data_hex_pattern, tmp);
            i++;
        end
        // readmemh の第2引数は定数である必要があるため、 GEN_SRAM[i].imem.mem のような指定はできない
        $readmemh(inst_hexfiles[0], GEN_SRAM[0].imem.mem);
        $readmemh(inst_hexfiles[1], GEN_SRAM[1].imem.mem);
        $readmemh(inst_hexfiles[2], GEN_SRAM[2].imem.mem);
        $readmemh(inst_hexfiles[3], GEN_SRAM[3].imem.mem);
        $readmemh(data_hexfiles[0], GEN_SRAM[0].dmem.mem);
        $readmemh(data_hexfiles[1], GEN_SRAM[1].dmem.mem);
        $readmemh(data_hexfiles[2], GEN_SRAM[2].dmem.mem);
        $readmemh(data_hexfiles[3], GEN_SRAM[3].dmem.mem);

        $dumpfile(vcd_logfile);
        $dumpvars(0);
        for (int i = 0; i < 32; i++) begin
            $dumpvars(0, top.core.reg_file.regfile[i]);
        end
        for (int i = 0; i < 4; i++) begin
            $dumpvars(0, top.instruction_memory.CEN[i]);
            $dumpvars(0, CEN_imem[i]);
            $dumpvars(0, CEN_dmem[i]);
            $dumpvars(0, top.CEN_imem[i]);
            $dumpvars(0, top.CEN_dmem[i]);
        end
    end

    generate
    genvar bank_num;
    for(bank_num = 0; bank_num < 4; bank_num++) begin: GEN_SRAM
        sram imem(
            .CLK(clk),
            .CEN(CEN_imem[bank_num]),
            .GWEN(GWEN_imem[bank_num]),
            .WEN(WEN_imem[bank_num]),
            .A(A_imem[bank_num]),
            .D(D_imem[bank_num]),
            .Q(Q_imem[bank_num])
        );
        sram dmem(
            .CLK(clk),
            .CEN(CEN_dmem[bank_num]),
            .GWEN(GWEN_dmem[bank_num]),
            .WEN(WEN_dmem[bank_num]),
            .A(A_dmem[bank_num]),
            .D(D_dmem[bank_num]),
            .Q(Q_dmem[bank_num])
        );
    end
    endgenerate

endmodule
`default_nettype wire

