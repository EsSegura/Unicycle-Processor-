module register #(parameter WIDTH=32)
(

    input logic clk,
    input logic rst,
    input logic write,
    input logic enable,
    input logic [WIDTH-1:0] data_in,
    
    output logic [WIDTH-1:0] data_out

);

    logic [WIDTH-1:0] reg_data;

    always_ff @( posedge clk ) begin //negedge para flancos negativos
        if (rst == 1) reg_data <= 0;

        else begin
            if (write) 
                reg_data <= data_in;
            else
                reg_data <= reg_data;

            if (enable)
                data_out <= reg_data;
            else
                data_out <= 'hz;

        end


        
    end

endmodule