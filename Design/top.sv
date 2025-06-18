`include "mux_2_1.sv"
`include "adder.sv"
`include "imm_gen.sv"
`include "alu.sv"   
`include "data_memory.sv"
`include "control_signal.sv"    
`include "register_file.sv"
`include "register.sv"
`include "inst_memory.sv"

module top #(parameter WIDTH=32, parameter DEPTH=16) (
    input  logic clk,
    input  logic rst,
    output logic [WIDTH-1:0] pc_out
);

    // Signals
    logic [WIDTH-1:0] pc;
    logic [WIDTH-1:0] pc_plus_4;
    logic [WIDTH-1:0] pc_plus_imm;
    logic [WIDTH-1:0] instr;
    logic [WIDTH-1:0] imm_data;
    logic [WIDTH-1:0] alu_result;
    logic [WIDTH-1:0] data_mem_out;
    logic [WIDTH-1:0] reg_data_out;
    logic [WIDTH-1:0] inst_out
    wire [WIDTH-1:0] rs1_data;
    wire [WIDTH-1:0] rs2_data;
    wire [WIDTH-1:0] rs3_data; 
    wire [WIDTH-1:0] write_data;

    // Control signals
    logic mux_pc_signal;
    logic mux_imm_signal;
    logic mux_writedata_register;
    logic mux_jalr;
    logic write_mem;
    logic read_mem;
    logic write_register;
    logic zero:
    logic branch_taken;
    logic one_byte; two_byte; four_bytes;

    // Instantiate modules
    inst_mem #(WIDTH, DEPTH) inst_memory (
        .clk(clk),
        .rst(rst),
        .addr(pc_out),
        .data_in(0), // No need to write to instruction memory
        .wr(1'b0), // No write operation        
        .rd(1'b1),
        .data_out(instr)
    );

    imm_gen #(WIDTH) imm_generator (
        .instr(instr),
        .data_out(imm_data)
    );

    alu #(WIDTH) alu_unit (
        .rs1(rs1_data),
        .rs2(rs2_data),
        .pc(pc),
        .func3(instr[14:12]),
        .func7(instr[31:25]),
        .opcode(instr[6:0]),
        .alu_result(alu_result),
        .pc_plus_4(pc_plus_4),
        .jump_target(rs3_data),
        .zero(zero),
        .branch_taken(branch_taken)
    );
//revisar entradas
    data_memory #(WIDTH, DEPTH) data_memory_unit (
        .clk(clk),
        .rst(rst),
        .data_in(rs2_data),
        .one_byte(one_byte),
        .two_byte(two_byte),
        .four_bytes(four_bytes),
        .addr(alu_result[DEPTH-1:2]),
        .wr(write_mem),
        .rd(read_mem),
        .data_out(data_mem_out)
    );

    control_signal control_unit (
        .instruction(instr[6:0]),
        .comparison(branch_taken), // Example comparison signal
        .mux_pc_signal(mux_pc_signal),
        .mux_imm_signal(mux_imm_signal),
        .mux_writedata_register(mux_writedata_register),
        .mux_jalr(mux_jalr),
        .write_mem(write_mem),
        .read_mem(read_mem),
        .write_register(write_register)
    );

    register_file #(WIDTH) reg_file (
        .clk(clk),
        .rst(rst),
        .write_data(write_data),
        .write_register(instr[11:7]), // rd field
        .write(write_register),
        .read_register_1(instr[19:15]),
        .read_register_2(instr[24:20]),
        .read(1'b1),    
        .read_data_1(rs1_data),
        .read_data_2(rs2_data)  
    );

    register #(WIDTH) pc_register (
        .clk(clk),
        .rst(rst),
        .write(1'b1), // Always write to PC
        .data_in(mux_pc_signal),
        .data_out(pc)
    );

    mux_2_1 #(WIDTH) mux_jalr (
        .A(pc_plus_imm), // Default to next instruction
        .B(alu_result), // Jump targe
        .sel(mux_jalr),
        .out(inst_out) 
    );

    mux_2_1 #(WIDTH) mux_pc (
        .A(pc_plus_4), // Default to next instruction
        .B(inst_out), // Jump targe
        .sel(mux_pc_signal),
        .out(mux_pc)
    );
//este 
    mux_2_1 #(WIDTH) mux_prealu(
        .A(rs2_data), // Default to next instruction
        .B(imm_data), // Jump targe
        .sel(mux_imm_signal),
        .out(rs2_data)//entrada alu
    );

    mux_2_1 #(WIDTH) mux_postalu(
        .A(read_data), // Default to next instruction
        .B(alu_result), // Jump targe
        .sel(mux_writedata_register),
        .out(write_data)
    );
    //Despues del pc
    adder #(WIDTH) adder_unit_1 (
        .A(32'd4),
        .B(pc),
        .sum(pc_plus_4)
    );
    //Despues del pc y adder
    adder #(WIDTH) adder_unit_2 (
        .A(pc_out),
        .B(imm_data),
        .sum(pc_plus_imm) // Jump target
    );
    
endmodule
    