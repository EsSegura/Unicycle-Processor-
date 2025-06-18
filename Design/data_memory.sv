module data_mem #(parameter WIDTH=32, parameter DEPTH=20) (
	
  input logic  	    	   clk,
  input logic              rst,
  input logic  [WIDTH-1:0] data_in,
  input logic  [DEPTH-1:0] addr,
  input logic              wr,
  input logic              rd,
  input logic              one_byte, //for sb, lb, lbu
  input logic              two_byte, //for sh, lh, lhu
  input logic              four_bytes, //for sw, lw
  
  
  output logic [WIDTH-1:0] data_out

);
  
  logic [7:0] memory [2^^DEPTH];
  
  always_ff @(negedge clk) begin
    if (rst) begin
      for(int i=1; i<2^^DEPTH;i++) begin
        memory[i] <= 0;
      end
    end
    else begin
      if (wr) begin
        if (one_byte) begin
          memory[addr]   <= data_in[7:0];
        end
        if (two_bytes) begin
          memory[addr]   <= data_in[7:0];
          memory[addr+1] <= data_in[16:8];
        end
        if (four_bytes) begin
          memory[addr]   <= data_in[7:0];
          memory[addr+1] <= data_in[15:8];
          memory[addr+2] <= data_in[23:16];
          memory[addr+3] <= data_in[31:24];
        end
      end
      if (rd) begin
        if (one_byte) begin
          data_out <= {24'b0,memory[addr]};
        end
        if (two_bytes) begin
          data_out <= {16'b0,memory[addr+1],memory[addr]};
        end
        if (four_bytes) begin
          data_out <= {memory[addr+3],memory[addr+2],memory[addr+1],memory[addr]};
        end
      end
    end
  end
  
endmodule