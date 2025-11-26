module teclado_decimal_input (
    input logic clk,
    input logic rst,
    input logic key_pressed,
    input logic [3:0] key_value,
    output logic [7:0] decimal_out1,
    output logic [7:0] decimal_out2,
    output logic listo,
    output logic showA,
    output logic showB,
    output logic show_mult,
    output logic multi,
    output logic [15:0] suma_out
);

    // Registros para almacenar los números ingresados
    logic [7:0] acumulador1;
    logic [7:0] acumulador2;
    logic key_pressed_prev;
    logic key_valid;

    // Máquina de estados
    enum logic [2:0] {
        IDLE,
        CAPTURA_PRIMERO,
        CAPTURA_SEGUNDO,
        NUMEROS_LISTOS,
        OPERAR
    } estado;

    // Detección de flanco positivo de key_pressed
    always_ff @(posedge clk) begin
        if (!rst) begin
            key_pressed_prev <= 0;
        end else begin
            key_pressed_prev <= key_pressed;
        end
    end

    assign key_valid = key_pressed && !key_pressed_prev;

    // Lógica principal de captura
    always_ff @(posedge clk) begin
        if (!rst) begin
            acumulador1 <= 0;
            acumulador2 <= 0;
            estado <= CAPTURA_PRIMERO;
            listo <= 0;
        end else begin
            listo <= 0;  // Resetear señal 'listo' cada ciclo
            multi <= 0;

            if (key_valid) begin
                case (key_value)
                    // Dígitos del 0 al 9
                    4'd0, 4'd1, 4'd2, 4'd3, 4'd4,
                    4'd5, 4'd6, 4'd7, 4'd8, 4'd9: begin
                        case (estado)
                            CAPTURA_PRIMERO: begin
                                if (acumulador1 < 9999) begin
                                    acumulador1 <= acumulador1 * 10 + key_value;
                                    showA <= 1'b1;
                                    showB <= 1'b0;
                                    show_mult <= 1'b0;
                                end
                            end
                            CAPTURA_SEGUNDO: begin
                                if (acumulador2 < 9999) begin
                                    acumulador2 <= acumulador2 * 10 + key_value;
                                    showA <= 1'b0;
                                    showB <= 1'b1;
                                    show_mult <= 1'b0;
                                end
                            end
                            default: ; // No hacer nada en otros estados
                        endcase
                    end

                    // Tecla 'A' (Confirmar)
                    4'hA: begin
                        case (estado)
                            CAPTURA_PRIMERO: estado <= CAPTURA_SEGUNDO;
                            CAPTURA_SEGUNDO: begin
                                listo <= 1;
                                estado <= NUMEROS_LISTOS;

                            end
                            NUMEROS_LISTOS: begin
                            estado <= OPERAR;

                            end
                        endcase
                    end

                    // Tecla 'B' (Borrar)
                    4'hB: begin
                        case (estado)
                            CAPTURA_PRIMERO: acumulador1 <= 0;
                            CAPTURA_SEGUNDO: acumulador2 <= 0;
                        endcase
                    end

                    // Tecla 'C' (Reset total)
                    4'hC: begin
                        estado <= CAPTURA_PRIMERO;
                        acumulador1 <= 0;
                        acumulador2 <= 0;
                    end


                    4'hD: begin
                        if (estado == OPERAR)
                        show_mult <= 1;
                        showA <= 0;
                        showB <= 0;
                        multi <= 1;
                    end




                    default: ; // Ignorar otras teclas
                endcase
            end
        end
    end

    // Asignación directa de las salidas (combinacional)
    assign decimal_out1 = acumulador1;
    assign decimal_out2 = acumulador2;
    assign suma_out = decimal_out1 + decimal_out2;

endmodule
