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

    // Control signals
    logic mux_pc_signal;
    logic mux_imm_signal;
    logic mux_writedata_register;
    logic mux_jalr;
    logic write_mem;
    logic read_mem;
    logic write_register;

    // Instantiate modules
    inst_mem #(WIDTH, DEPTH) inst_memory (
        .clk(clk),
        .rst(rst),
        .addr(pc[DEPTH-1:2]),
        .data_in(0), // No need to write to instruction memory
        .wr(1'b0), // No write operation        
        .rd(1'b1),
        .data_out(instr)
    );

    imm_gen #(WIDTH) imm_generator (
        .instr(instr),
        .data_out(imm_data)
    );
//completar 
    alu #(WIDTH) alu_unit (
        .rs1(),
        .rs2(),
        .pc(pc),
        .func3()
        .func7(),
        .opcode(instr[6:0]),
        .alu_result(alu_result),
        .pc_plus_4(),
        .jump_target(),
        .zero(),
        .branch_taken()
    );
//revisar entradas
    data_memory #(WIDTH, DEPTH) data_memory_unit (
        .clk(clk),
        .rst(rst),
        .data_in(),
        .addr(alu_result[DEPTH-1:2]),
        .wr(write_mem),
        .rd(read_mem),
        .data_out(data_mem_out)
    );

    control_signal control_unit (
        .opcode(instr[6:0]),
        .comparison(alu_result[0]), // Example comparison signal
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
        .write_data(),
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
    //Mux del pc
    mux_2_1 #(WIDTH) mux_pc (
        .A(pc_plus_4), // Default to next instruction
        .B(pc_plus_imm), // Jump targe
        .sel(),
        .out(mux_pc)
    );
    //Antes de la alu
    mux_2_1 #(WIDTH) mux_prealu(
        .A(rs2_data), // Default to next instruction
        .B(imm_data), // Jump targe
        .sel(),
        .out(rs2)//entrada alu
    );
    //Alu despues de la alu
    mux_2_1 #(WIDTH) mux_postalu(
        .A(read_data), // Default to next instruction
        .B(alu_result), // Jump targe
        .sel(),
        .out(mux_writedata_register)//entrada alu
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
    assign pc_out = pc;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 0; // Reset PC to 0
        end else begin
            pc <= mux_pc_signal ? alu_result : (pc + 4); // Increment PC or jump
        end
    end 
endmodule
    