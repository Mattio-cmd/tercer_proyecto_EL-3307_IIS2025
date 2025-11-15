module decoder ( //decodifica las teclas del teclado
    input logic slow_clk,
    input logic rst,
    input logic [3:0] col_shift_reg,
    input logic [3:0] row_in,
    output logic [3:0] key_value,
    output logic key_pressed
);

    always_comb begin
        // Inicializacion de variables
        key_value = 4'b0000;
        key_pressed = 0;
            // Posibles combinaciones
            case (col_shift_reg)
                4'b0001 :  case (row_in) // cuarta columna activa
                                4'b1000 : key_value = 4'b0001;  // "1"
                                4'b0100 : key_value = 4'b0100;  // "4"
                                4'b0010 : key_value = 4'b0111;  // "7"
                                4'b0001 : key_value = 4'b0000;  // "*"
                            endcase
                4'b0010 :  case (row_in) // tercera columna activa
                                4'b1000 : key_value = 4'b0010;  // "2"
                                4'b0100 : key_value = 4'b0101;  // "5"
                                4'b0010 : key_value = 4'b1000;  // "8"
                                4'b0001 : key_value = 4'b0000;  // "0"
                            endcase
                4'b0100 :  case (row_in) // segunda columna activa
                                4'b1000 : key_value = 4'b0011;  // "3"
                                4'b0100 : key_value = 4'b0110;  // "6"
                                4'b0010 : key_value = 4'b1001;  // "9"
                                4'b0001 : key_value = 4'b0000;  // "#"
                            endcase
                4'b1000 :  case (row_in) // primera columna activa
                                4'b1000 : key_value = 4'b1010;  // "A"
                                4'b0100 : key_value = 4'b1011;  // "B"
                                4'b0010 : key_value = 4'b1100;  // "C"
                                4'b0001 : key_value = 4'b1101;  // "D"
                            endcase
            endcase
            if (row_in != 4'b0000) begin //señal que detecta cuando hay una tecla activa
                key_pressed = 1;
            end  
        end
    
endmodule
