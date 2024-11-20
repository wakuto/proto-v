`default_nettype none

module sram#(
  parameter hex_file = "",
  parameter width = 8,
  parameter depth = 512
)(
  input wire CLK,
  input wire CEN,
  input wire GWEN,
  input wire [width-1:0] WEN,
  input wire [$clog2(depth)-1:0] A,
  input wire [width-1:0] D,
  output wire [width-1:0] Q
);

  logic [width-1:0] mem [0:depth-1];

  logic [width-1:0] read_data;

  initial begin
    if (hex_file != "") begin
      $display("SRAM initialization using %s.", hex_file);
      $readmemh(hex_file, mem);
    end
  end

  assign Q = read_data;

  always_ff @(posedge CLK) begin
    if (!CEN) begin
      read_data <= mem[A];

      if (!GWEN) begin
        mem[A] <= ~WEN & D;
      end
    end
  end
endmodule

`default_nettype wire
