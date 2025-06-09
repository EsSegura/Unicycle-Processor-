module reg_file #(parameter WIDHT = 32, parameter DEPTH = 5)(

    input logic clk,
    input logic rst,
    input logic [WIDTH-1:0] write_data,
    input logic [DEPTH-1:0] write_register, 
    input logic write,
    input logic [DEPTH-1:0] read_register_1,
    input logic [DEPTH-1:0] read_register_2,
    input logic read,

    output logic [WIDTH-1:0] read_data_1,
    output logic [WIDTH-1:0] read_data_2

);

    logic [WIDTH-1:0] registers [DEPTH],
    logic [WIDTH-1:0] reg_zero,

    assign reg_zero = 0,

    always_ff @( posedge clk ) begin 
        if (rst) begin 
            for (int i=1; i<DEPTH; i++)begin 
                registers[i] <= 0;
            end
        end
        else begin 
            if ((write) && (write_register != 0))
                registers [write_register] <= write_data;
            if(read) begin 
                if (read_register_1 == 0)
                    read_data_1 <= reg_zero;
                else 
                    read_data_1 <= registers[read_register_1];
                if (read_register_2 == 0)
                    read_data_2 <= reg_zero;
                else 
                    read_data_2 <= registers[read_register_2];  
            end
        end
    end

endmodule