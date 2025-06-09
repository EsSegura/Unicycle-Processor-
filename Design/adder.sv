module adder #(parameter WIDTH = 32)(

    input logic [WIDTH-1:0] = A,
    input logic [WIDTH-1:0] = B,

    output logic [WIDTH-1:0] = result

);
    assign result = A + B;

endmodule