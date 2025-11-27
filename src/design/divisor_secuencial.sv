module divisor_secuencial #(
    parameter N = 8
) (
    input  logic             clk,
    input  logic             rst,
    input  logic             valid,
    input  logic [N-1:0]     A,
    input  logic [N-1:0]     B,
    output logic [N-1:0]     Q,
    output logic [N-1:0]     R,
    output logic             done,
    output logic             error
);

    // Registros internos
    logic [N-1:0]   divisor_reg;
    logic [2*N-1:0] acumulador;   // [resto | cociente]
    logic [N:0]     contador;
    logic           div_by_zero;

    typedef enum logic [1:0] {IDLE, SHIFT, SUB, DONE_STATE} state_t;
    state_t state, next_state;

    // Detectar división por cero
    assign div_by_zero = (B == '0);

    // Salidas
    assign Q     = acumulador[N-1:0];
    assign R     = acumulador[2*N-1:N];
    assign done  = (state == DONE_STATE);
    assign error = div_by_zero && done;

    // Lógica de siguiente estado
    always_comb begin
        next_state = state;
        case (state)
            IDLE:       if (valid)               next_state = div_by_zero ? DONE_STATE : SHIFT;
            SHIFT:                                 next_state = SUB;
            SUB:        if (contador == N)       next_state = DONE_STATE;
                        else                     next_state = SHIFT;
            DONE_STATE:                            next_state = IDLE;
            default:                               next_state = IDLE;
        endcase
    end

    // Secuencial
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            acumulador  <= '0;
            divisor_reg <= '0;
            contador    <= '0;
        end else begin
            state <= next_state;

            if (state == IDLE && valid && !div_by_zero) begin
                acumulador  <= { {N{1'b0}}, A };   // resto=0, cociente=A
                divisor_reg <= B;
                contador    <= '0;
            end
            else if (state == SHIFT) begin
                acumulador <= acumulador << 1;
                contador   <= contador + 1;
            end
            else if (state == SUB) begin
                if (acumulador[2*N-1:N] >= divisor_reg) begin
                    acumulador[2*N-1:N] <= acumulador[2*N-1:N] - divisor_reg;
                    acumulador[0]       <= 1'b1;
                end else begin
                    acumulador[0] <= 1'b0;
                end
            end
        end
    end

endmodule