module control(
    input  logic clk,
    input  logic rst,
    input  logic BW, BR, PW, PR, S,
    output logic [1:0] status
);

    // Estados
    parameter MODIFIED  = 2'd0;
    parameter EXCLUSIVE = 2'd1;
    parameter SHARED    = 2'd2;
    parameter INVALID   = 2'd3;

    logic [1:0] c_state, n_state;

    // Registro de estado actual
    always_ff @(posedge clk) begin
        if (rst) begin
            c_state <= INVALID;
        end else begin 
            c_state <= n_state;
        end
    end

    // Lógica de transición de estado
    always_comb @(state, bw) begin
        n_state = c_state;  // Por defecto, mantener estado

        case (c_state)
            MODIFIED: begin
                if (BW)      n_state = INVALID;
                else if (BR) n_state = SHARED;
                else if (PR || PW) n_state = MODIFIED;
            end

            EXCLUSIVE: begin
                if (PW)      n_state = MODIFIED;
                else if (BR) n_state = SHARED;
                else if (PR) n_state = EXCLUSIVE;
                else if (BW) n_state = INVALID;
            end

            SHARED: begin
                if (BW)      n_state = INVALID;
                else if (PW) n_state = EXCLUSIVE;
                else if (PR || BR) n_state = SHARED;
            end

            INVALID: begin
                if (PW && ~S) n_state = MODIFIED;
                else if (PR && S)  n_state = SHARED;
                else if ((PR && ~S) || (PW && S)) n_state = EXCLUSIVE;
                else if (BW || BR) n_state = INVALID;
            end
        endcase
    end

    // Asignación de estado de salida
    always_comb begin
        case (c_state)
            MODIFIED  : status = MODIFIED;
            EXCLUSIVE : status = EXCLUSIVE;
            SHARED    : status = SHARED;
            INVALID   : status = INVALID;
            default   : status = INVALID;
        endcase
    end

endmodule
