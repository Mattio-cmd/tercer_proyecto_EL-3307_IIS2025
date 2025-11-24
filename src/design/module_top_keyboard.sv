    module module_top_keyboard (
    input logic clk,
    input logic rst,
    input logic [3:0] filas,
    output logic [3:0] columnas,
    output logic [3:0] led,
    output logic [3:0] anodo,
    output logic [15:0] suma_out, // ya no se usa como suma
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
    logic multi;
    logic [3:0] bcd_thousands, bcd_hundreds, bcd_tens, bcd_ones;
    logic showA, showB, show_mult;
    logic [6:0] seg;


    logic  [15:0] mult_result;
    logic  [15:0] y;
    logic valid_mult;
    logic  [15:0] abs_result;
    logic done;


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
        .show_mult(show_mult),
        .multi(multi),
        .suma_out(suma_out), // no se usa pero se deja por compatibilidad
        .listo(listo)
    );

    // BoothMul instanciado
    /*BoothMul booth_inst (   
        .clk(clk),
        .rst(rst),
        .start(multi),
        .A(decimal_out1[7:0]),
        .B(decimal_out2[7:0]),
        .Y(mult_result),
        .valid(valid_mult)
    );*/

    mult_with_no_sm ult_with_no_sm_inst (
        .clk(clk),
        .rst(rst),
        .start(multi),
        .a(decimal_out1[7:0]),
        .b(decimal_out2[7:0]),
        .done(done),
        .y(y)

    );




    always_ff @(posedge clk) begin
        if (!rst)
            display_value <= 16'd0;
        else if (show_mult)
            display_value <= y;
        else if (showA)
            display_value <= decimal_out1;
        else if (showB)
            display_value <= decimal_out2;
    end

    // Conversor binario a BCD
    bin_to_bcd bcd_converter (
        .bin_in(display_value),
        .bcd_thousands(bcd_thousands),
        .bcd_hundreds(bcd_hundreds),
        .bcd_tens(bcd_tens),
        .bcd_ones(bcd_ones)
    );

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
    assign led = key;

endmodule