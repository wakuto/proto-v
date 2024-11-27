`default_nettype none
`timescale 1ns / 1ps

module riscv_test();
    logic clk;
    logic rst;

    logic tx; // <- cpu
    logic rx; // -> cpu
    logic [31:0] gpio_out; // <- cpu
    logic [31:0] gpio_in;  // -> cpu


    cpu cpu (.*);

	string inst_hex_pattern;
	string log_dump;
	int log_file;
    initial begin
        rx = 0;
        gpio_in = 0;

        rst = 1;
        clk = 0;

        @(posedge clk);
        @(posedge clk);

        rst = 0;

        // 十分な時間待つ
        #10000

		// テスト結果の出力設定
        if (!$value$plusargs("log=%s", log_dump)) begin
          log_dump = "result.log";
        end
        if ($value$plusargs("inst=%s", inst_hex_pattern)) begin
			log_file = $fopen(log_dump, "a");
			if (cpu.top.core.reg_file.regfile[3] == 1) begin
				$fdisplay(log_file, "[     OK     ]   %s", inst_hex_pattern);
			end else begin
				$fdisplay(log_file, "[FAILED (%3d)]   %s", int'(cpu.top.core.reg_file.regfile[3]), inst_hex_pattern);
			end
			$fclose(log_file);
        end else begin
            $display("plusargs failed");
        end

        $finish;
    end

    always #(5) begin
        clk = ~clk;
    end

endmodule
`default_nettype wire

