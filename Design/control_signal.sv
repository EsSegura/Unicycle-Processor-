module control_signal #(parameter WIDTH = 32)(
  input logic [WIDTH-1:0] instruction, //La instruccion de entrada
  input logic              comparison, //La comparacion de los condicionales proveniente de la ALU
  
  output logic          mux_pc_signal, // 0 = PC+4, 1 = Pc + imm
  output logic         mux_imm_signal, // Entrada 2 ALU: 0 = rs2, 1 = immediato
  output logic mux_writedata_register, // Dato registro destino: 0 = ALU, 1 = Memoria
  output logic               mux_jalr, // Direccion de salto para PC: 0 = jal y branches, 1 = jalr
  output logic              write_mem, // Guardar memoria sw, sh, sb
  output logic               read_mem, // Leer memoria lw, lh, lb
  output logic          write_register // Guardar en registros add, addi, jal, jalr, etc
);
  //Tipo de instrucciones segun el opcode
  parameter TipoR            = 7'b011_0011; //Aritmeticas
  parameter TipoI_Load       = 7'b000_0011; //Lectura en memoria
  parameter TipoI_aritmetico = 7'b001_0011; //Aritmeticas con inmediato
  parameter TipoI_jalr       = 7'b110_0111; //Jump and link register
  parameter TipoS            = 7'b010_0011; //Guardado en memoria
  parameter TipoSB           = 7'b110_0011; //Saltos condicionales branches
  parameter TipoU_Lui        = 7'b011_0111; //Load upper immediate
  parameter TipoUJ_jal       = 7'b110_1111; //Jump and link
  
  logic [6:0] opcode;
  assign opcode = instruction[6:0];
  
  always_comb begin
    case(opcode)
      TipoR: begin // Guardar en registros
        mux_pc_signal          = 0;
        mux_imm_signal         = 0;
        mux_writedata_register = 0;
        mux_jalr               = 0;
        write_mem              = 0;
        read_mem               = 0;
        write_register         = 1;
      end
      TipoI_Load: begin //Usar immediato, leer memoria, extraer de memoria, guardar registro
        mux_pc_signal          = 0;
        mux_imm_signal         = 1;
        mux_writedata_register = 1;
        mux_jalr               = 0;
        write_mem              = 0;
        read_mem               = 1;
        write_register         = 1;
      end
      TipoI_aritmetico: begin //Usar immediato, guardar registro
        mux_pc_signal          = 0;
        mux_imm_signal         = 1;
        mux_writedata_register = 0;
        mux_jalr               = 0;
        write_mem              = 0;
        read_mem               = 0;
        write_register         = 1;
      end
      TipoI_jalr: begin // Usar immediato, salto de PC, guardar en registros, salto sin referencia
        mux_pc_signal          = 1;
        mux_imm_signal         = 1;
        mux_writedata_register = 0;
        mux_jalr               = 1;
        write_mem              = 0;
        read_mem               = 0;
        write_register         = 1;
      end
      TipoS: begin // Usar immediato, guardar memoria
        mux_pc_signal          = 0;
        mux_imm_signal         = 1;
        mux_writedata_register = 0;
        mux_jalr               = 0;
        write_mem              = 1;
        read_mem               = 0;
        write_register         = 0;
      end
      TipoSB: begin //Salto de PC quizas si quizas no
        mux_imm_signal               = 0;
        mux_writedata_register       = 0;
        mux_jalr                     = 0;
        write_mem                    = 0;
        read_mem                     = 0;
        write_register               = 0;
        if(comparison) mux_pc_signal = 1;
        else mux_pc_signal           = 0;
      end
      TipoU_Lui: begin // usar immediato, guardar registro
        mux_pc_signal          = 0;
        mux_imm_signal         = 1;
        mux_writedata_register = 0;
        mux_jalr               = 0;
        write_mem              = 0;
        read_mem               = 0;
        write_register         = 1;
      end
      TipoUJ_jal: begin //Salto PC, Salto con referencia de PC, guardar regustro
        mux_pc_signal          = 1;
        mux_imm_signal         = 0;
        mux_writedata_register = 0;
        mux_jalr               = 0;
        write_mem              = 0;
        read_mem               = 0;
        write_register         = 1;
      end
    endcase
  end
endmodule