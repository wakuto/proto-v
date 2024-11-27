`default_nettype none
`timescale 1ns / 1ps

module tb_template();
    logic clk;
    logic rst;

    logic tx; // <- cpu
    logic rx; // -> cpu
    logic [31:0] gpio_out; // <- cpu
    logic [31:0] gpio_in;  // -> cpu


    cpu cpu (.*);

    initial begin
        rx = 0;
        gpio_in = 0;

        rst = 1;
        clk = 0;

        @(posedge clk);
        @(posedge clk);

        rst = 0;

        // write your testbench here!
        // you can access any signals: cpu.top.core.pc_f

        $finish;
    end

    always #(5) begin
        clk = ~clk;
    end

endmodule
`default_nettype wire

