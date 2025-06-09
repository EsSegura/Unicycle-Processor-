module imm_gen #(parameter WIDTH=32,) (
	
  input logic  [WIDTH-1:0] instr,
  
  output logic [WIDTH-1:0] data_out

);
  
  parameter ALI_OP    = 0010011;
  parameter MEM_WR_OP = 0100011;
  parameter MEM_RD_OP = 0000011;
  parameter BR_OP     = 1100011;
  parameter JALR      = 1100111;
  parameter JAL       = 1101111;
  parameter LUI       = 0110111;
  
  logic [6:0] opcode;
  
  assign opcode = instr[6:0];
  
  always_comb begin
    case(opcode)
      ALI_OP: begin
        if   (func3 != (001 || 101)) data_out = {19{inst[31]},inst[31:20]};
        else                         data_out = {27'b0,inst[24:20]};
      end
      MEM_WR_OP: begin
        data_out = {19{inst[31]},inst[31:25],inst[11:7]};
      end
      MEM_RD_OP: begin
        data_out = {19{inst[31]},inst[31:20]};
      end
      BR_OP: begin
        data_out = {18{inst[31]},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
      end
      JALR: begin
        data_out = {19{inst[31]},inst[31:20]};
      end
      JAL: begin
        data_out = {12{inst[31]},inst[31],inst[19:12],inst[20],inst[30:21],1'b0};
      end
      LUI: begin
        data_out = {inst[31:12],12'b0};
      end
      default: data_out = 0;
    endcase
  end
  
endmodule