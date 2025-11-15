
module mult_with_no_sm #(
    parameter N = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic  [N-1:0] a,
    input  logic  [N-1:0] b,
    output logic  [2*N-1:0] y,
    output logic done
);

    // === Estados como parámetros compatibles con Yosys ===
    localparam IDLE     = 3'd0;
    localparam LOAD     = 3'd1;
    localparam EXECUTE  = 3'd2;
    localparam SHIFT    = 3'd3;
    localparam DONE     = 3'd4;

    logic [2:0] state, next_state;

    logic [1:0] q_lsb;
    logic signed [N-1:0] m, adder_sub_out;
    logic signed [2*N:0] shift;
    logic signed [N-1:0] hq, lq;
    logic q_1;
    logic add_sub;
    logic [3:0] count;

    // Estado actual
    always_ff @(posedge clk) begin
        if (!rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Transición de estados sin casting
    always_comb begin
        case (state)
            IDLE:     next_state = start ? LOAD : IDLE;
            LOAD:     next_state = EXECUTE;
            EXECUTE:  next_state = SHIFT;
            SHIFT:    next_state = (count == N-1) ? DONE : EXECUTE;
            DONE:     next_state = IDLE;
            default:  next_state = IDLE;
        endcase
    end

    // Contador de iteraciones
    always_ff @(posedge clk) begin
        if (!rst)
            count <= 0;
        else if (state == SHIFT)
            count <= count + 1;
        else if (state == IDLE)
            count <= 0;
    end

    // Registro del multiplicando M
    always_ff @(posedge clk) begin
        if (!rst)
            m <= '0;
        else if (state == LOAD)
            m <= a;
    end

    // Registro de desplazamiento
    always_ff @(posedge clk ) begin
        if (!rst) begin
            shift <= '0;
        end else begin
            case (state)
                LOAD: begin
                    shift <= {{(N+1){1'b0}}, b, 1'b0};
                end
                EXECUTE: begin
                    if (q_lsb == 2'b01 || q_lsb == 2'b10)
                        shift[2*N:N+1] <= adder_sub_out;
                end
                SHIFT: begin
                    shift <= $signed(shift) >>> 1;
                end
                default: ;
            endcase
        end
    end

    // Extracción HQ, LQ, Q-1 y lógica de Booth
    always_comb begin
        hq = shift[2*N:N+1];
        lq = shift[N:1];
        q_1 = shift[0];
        q_lsb = {lq[0], q_1};

        if (q_lsb == 2'b10)
            add_sub = 0;  // HQ - M
        else if (q_lsb == 2'b01)
            add_sub = 1;  // HQ + M
        else
            add_sub = 0;  // No operación

        adder_sub_out = add_sub ? (hq + m) : (hq - m);
    end

    // Salida y done solo en estado DONE
    always_ff @(posedge clk) begin
        if (!rst) begin
            y <= '0;
            done <= 0;
        end else if (state == DONE) begin
            y <= {hq, lq};
            done <= 1;
        end else begin
            done <= 0;
        end
    end

endmodule


