module module_top_keyboard (
    input logic clk,
    input logic rst,
    input logic [3:0] filas,
    output logic [3:0] columnas,
    output logic [3:0] led,
    output logic [3:0] anodo,
    output logic [15:0] suma_out, // ya no se usa como suma (se mantiene por compatibilidad)
    output logic a, b, c, d, e, f, g
);

    logic slow_clk;
    logic pulse_out;
    logic [3:0] filas_clean;
    logic key_detected;
    logic [1:0] column_index;
    logic [3:0] key;
    logic [7:0] decimal_out1;
    logic [7:0] decimal_out2;
    logic listo;
    logic multi;                    // se puede usar como "start division" desde teclado
    logic [3:0] bcd_thousands, bcd_hundreds, bcd_tens, bcd_ones;
    logic showA, showB, show_mult;  // show_mult ahora sirve para mostrar DIV (mantengo nombre para compat)
    logic [6:0] seg;

    // --- Señales de división ---
    logic [7:0] div_Q;   // cociente (Q)
    logic [7:0] div_R;   // resto (R)
    logic div_valid;      // Inicia la división
    logic div_done;       // División completada
    logic div_error;      // Error (división por cero)

    logic [15:0] display_value;

    // Instancias
    tick_generator #(.MAX_COUNT(27000)) refresh_gen (
        .clk(clk),
        .rst(rst),
        .tick(pulse_out)
    );

    freq_divider freq_divider_inst (
        .clk(clk),
        .rst(rst),
        .slow_clk(slow_clk)
    );

    deb debounce_1_inst (.clk(clk), .reset(rst), .button_in(filas[0]), .button_out(filas_clean[0]));
    deb debounce_2_inst (.clk(clk), .reset(rst), .button_in(filas[1]), .button_out(filas_clean[1]));
    deb debounce_3_inst (.clk(clk), .reset(rst), .button_in(filas[2]), .button_out(filas_clean[2]));
    deb debounce_4_inst (.clk(clk), .reset(rst), .button_in(filas[3]), .button_out(filas_clean[3]));

    scanner scanner_inst (
        .slow_clk(slow_clk),
        .rst(rst),
        .key_pressed(key_detected),
        .col_shift_reg(columnas),
        .column_index(column_index)
    );

    decoder decoder_inst (
        .slow_clk(slow_clk),
        .rst(rst),
        .col_shift_reg(columnas),
        .row_in(filas_clean),
        .key_value(key),
        .key_pressed(key_detected)
    );

    teclado_decimal_input teclado_decimal_inst (
        .clk(clk),
        .rst(rst),
        .key_pressed(key_detected),
        .key_value(key),
        .decimal_out1(decimal_out1),
        .decimal_out2(decimal_out2),
        .showA(showA),
        .showB(showB),
        .show_mult(show_mult), // señal reutilizada para "mostrar resultado de DIV"
        .multi(multi),         // señal usada para indicar inicio de la operación desde el teclado
        .suma_out(suma_out),   // no usada pero mantenida
        .listo(listo)
    );

    // NUEVO: Instancia del divisor secuencial
    divisor_secuencial #(.N(8)) divisor_seq_inst (
        .clk(clk),
        .rst(rst),
        .valid(div_valid),
        .A(decimal_out1[7:0]),
        .B(decimal_out2[7:0]),
        .Q(div_Q),
        .R(div_R),
        .done(div_done),
        .error(div_error)
    );

    // Control de inicio de división (genera pulso de valid)
    logic multi_prev;
    always_ff @(posedge clk) begin
        if (!rst) begin
            multi_prev <= 1'b0;
            div_valid <= 1'b0;
        end
        else begin
            multi_prev <= multi;
            // Detectar flanco positivo de 'multi' (tecla D presionada)
            div_valid <= multi && !multi_prev;
        end
    end

    // Actualización del display_value (registro) según señales de control
    always_ff @(posedge clk) begin
        if (!rst)
            display_value <= 16'd0;
        else if (show_mult)               // ahora interpreta show_mult como "mostrar DIV"
            display_value <= {8'd0, div_Q}; // mostramos el cociente en los 16 bits bajos (o altos según preferencia)
        else if (showA)
            display_value <= {8'd0, decimal_out1};
        else if (showB)
            display_value <= {8'd0, decimal_out2};
    end

    // Conversor binario a BCD
    bin_to_bcd bcd_converter (
        .bin_in(display_value),
        .bcd_thousands(bcd_thousands),
        .bcd_hundreds(bcd_hundreds),
        .bcd_tens(bcd_tens),
        .bcd_ones(bcd_ones)
    );

    // Controlador de display
    display_controller disp_ctrl (
        .clk(clk),
        .rst(rst),
        .refresh_tick(pulse_out),
        .bcd_thousands(bcd_thousands),
        .bcd_hundreds(bcd_hundreds),
        .bcd_tens(bcd_tens),
        .bcd_ones(bcd_ones),
        .seg(seg),
        .an(anodo)
    );

    assign {a, b, c, d, e, f, g} = seg;
    assign led = (div_error) ? 4'b1010 : key;

endmodule
