module inst_mem #(parameter WIDTH=32, parameter DEPTH=32) (
  input logic              clk,
  input logic              rst,
  input logic [WIDTH-1:0]  data_in,
  input logic [DEPTH-1:0]  addr,
  input logic              wr,
  input logic              rd,
  output logic [WIDTH-1:0] data_out
);
  
  logic [WIDTH-1:0] memory [0:DEPTH-1];
  
  initial begin
    $readmemb("program.mem", memory);
  end
  
  // Escritura síncrona
  always_ff @(posedge clk) begin
    if (wr) begin
      memory[addr] <= data_in;
    end
  end
  
  // Lectura asíncrona (combinacional)
  assign data_out = (rd) ? memory[addr] : 'x;
  
endmodule