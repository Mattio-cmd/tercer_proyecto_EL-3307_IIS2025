module scanner ( //barrido de columnas
    input logic slow_clk,          // Entrada del reloj lento (1 KHz)
    input logic rst,               // Señal de reinicio
    input logic key_pressed,
    output logic [3:0] col_shift_reg, // Registro de desplazamiento de columnas
    output logic [1:0] column_index  // Índice de la columna activa
);

    always_ff @(posedge slow_clk) begin
        if (!rst) begin
            col_shift_reg <= 4'b0001;    // Inicializar activando la primera columna
            column_index <= 2'b0;        // Inicializar el índice de columna
        end else if (!key_pressed) begin      
            // Desplazar el bit activo hacia la siguiente columna
            col_shift_reg <= {col_shift_reg[2:0], col_shift_reg[3]};
            column_index <= column_index + 1;  // Incrementar el índice de columna
        end
    end
endmodule