module inst_mem #(parameter WIDTH=32, parameter DEPTH=16) (
	
  input logic  	    	   clk,
  input logic              rst,
  input logic  [WIDTH-1:0] data_in,
  input logic  [DEPTH-1:0] addr,
  input logic              wr,
  input logic              rd,
  
  output logic [WIDTH-1:0] data_out

);
  
  logic [WIDTH-1:0] memory [0:(1 << DEPTH)-1];
  
  initial $readmemh("program.mem", memory);
  
  always_ff @(posedge clk) begin
    if (wr) begin
    memory[addr] <= data_in; //Si wr es 1, se escribe data_in en la dirección addr de memoria
    end
    if (rd) begin
    data_out <= memory[addr]; //Si rd es 1, se lee la dirección addr de memoria y se asigna a data_out
    end
  end
  
endmodule