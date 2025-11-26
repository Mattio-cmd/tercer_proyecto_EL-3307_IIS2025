module display_controller (
    input  logic        clk,
    input  logic        rst,
    input  logic        refresh_tick,
    input  logic [3:0]  bcd_thousands,
    input  logic [3:0]  bcd_hundreds,
    input  logic [3:0]  bcd_tens,
    input  logic [3:0]  bcd_ones,
    output logic [6:0]  seg,
    output logic [3:0]  an
);

    // Registros para el multiplexado de dígitos
    logic [1:0] digit_index;
    logic [3:0] current_digit;
    logic [3:0] safe_digit;

    // Señales de segmentos individuales (activación en bajo para display ánodo común)
    logic a, b, c, d, e, f, g;

    // Lógica de refresco para multiplexar los displays
    always_ff @(posedge clk) begin
        if (!rst)
            digit_index <= 2'd0;
        else if (refresh_tick)
            digit_index <= digit_index + 1;
    end

    // Selección del dígito actual según digit_index
    always_comb begin
        case (digit_index)
            2'd0: current_digit = bcd_ones;      // Unidades
            2'd1: current_digit = bcd_tens;      // Decenas
            2'd2: current_digit = bcd_hundreds;  // Centenas
            2'd3: current_digit = bcd_thousands; // Millares
            default: current_digit = 4'd0;
        endcase
    end

    // Filtro robusto para dígitos BCD (0-9)
    always_comb begin
        case (current_digit)
            4'd0: safe_digit = 4'd0;  // 0
            4'd1: safe_digit = 4'd1;  // 1
            4'd2: safe_digit = 4'd2;  // 2
            4'd3: safe_digit = 4'd3;  // 3
            4'd4: safe_digit = 4'd4;  // 4
            4'd5: safe_digit = 4'd5;  // 5
            4'd6: safe_digit = 4'd6;  // 6
            4'd7: safe_digit = 4'd7;  // 7
            4'd8: safe_digit = 4'd8;  // 8
            4'd9: safe_digit = 4'd9;  // 9
            default: safe_digit = 4'd0;  // Valor inválido → 0
        endcase
    end

    // Activación de ánodos (activación en bajo)
    always_comb begin
        an = 4'b0000;  // Todos apagados por defecto
        an[digit_index] = 1'b1;  // Activa solo el dígito actual
    end

    // Decodificador BCD a 7 segmentos
    bcd bcd_decoder (
        .bcd(safe_digit),
        .seg({a, b, c, d, e, f, g})
    );

    // Asignación de salidas (segmentos activos en bajo)
    assign seg = {a, b, c, d, e, f, g};

endmodule
