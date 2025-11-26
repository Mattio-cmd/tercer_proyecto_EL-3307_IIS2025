module freq_divider (
   input logic clk,         // Entrada del reloj (27 MHz)
    input logic rst,         // Señal de reinicio
    output logic slow_clk    // Salida del reloj lento
);
    // Contador que se usa para dividir el reloj
    logic [32:0] clk_divider_counter;

    // Inicialización de slow_clk
    initial begin
        slow_clk = 1'b0; // Inicializa slow_clk en 0
    end

    always_ff @(posedge clk) begin
        if (!rst) begin
            clk_divider_counter <= 33'd0; // Reiniciar el contador al resetear
            slow_clk <= 1'b0;             // Inicializar el reloj lento
        end else begin
            // Contador para dividir el reloj
            if (clk_divider_counter == 33'd27000 - 1) begin // 270000 para obtener 10 ms
                slow_clk <= ~slow_clk;        // Invertir el valor del reloj lento
                clk_divider_counter <= 33'd0; // Reiniciar el contador
            end else begin
                clk_divider_counter <= clk_divider_counter + 1; // Incrementar el contador
            end
        end
    end
endmodule
