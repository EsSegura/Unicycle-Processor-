module imm_gen #(parameter WIDTH=32,) 
(
	
  input logic  [WIDTH-1:0] instr,
  
  output logic [WIDTH-1:0] data_out

);
  
  parameter ALI_OP    = 7'b0010011;
  parameter MEM_WR_OP = 7'b0100011;
  parameter MEM_RD_OP = 7'b0000011;
  parameter BR_OP     = 7'b1100011;
  parameter JALR      = 7'b1100111;
  parameter JAL       = 7'b1101111;
  parameter LUI       = 7'b0110111;
  
  logic [6:0] opcode;
  logic [2:0] func3
  
  assign opcode = instr[6:0];
  assign func3 = instr[14:12];
  
  always_comb begin
    case(opcode)
      ALI_OP: begin
        if   (func3 != 3'b001 && func3 != 3'b101) 
          data_out = {{20{inst[31]}},inst[31:20]};
        else                         
          data_out = {{27{1'b0}},inst[24:20]};
      end
      MEM_WR_OP: begin
        data_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
      end
      MEM_RD_OP: begin
        data_out = {{20{instr[31]}}, instr[31:20]};
      end
      BR_OP: begin
        data_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
      end
      JALR: begin
        data_out = {{20{instr[31]}}, instr[31:20]};
      end
      JAL: begin
        data_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
      end
      LUI: begin
        data_out = {instr[31:12], 12'b0};
      end
      default: data_out = 0;
    endcase
  end
  
endmodule