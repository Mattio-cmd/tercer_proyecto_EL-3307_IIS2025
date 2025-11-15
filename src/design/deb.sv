module deb ( //Debouncer
    input  logic clk,           // Reloj del sistema de 27 MHz
    input  logic reset,         // Reset activo en bajo (activo cuando es 0)
    input  logic button_in,     // Señal de entrada del botón (con rebotes)
    output logic button_out     // Señal de salida del botón ya "filtrada", sin rebotes
);

    // Parámetro que define cuántos ciclos se necesita que la señal se mantenga estable
    // Se usa 3.7ms a 27MHz (100,000 ciclos)
    localparam DEBOUNCE_COUNT = 17'd100000;

    // Registros: contador para medir estabilidad, dos flip-flops para sincronización, y una señal que mantiene el valor estable (filtrado) del botón
    logic [16:0] counter;    // Contador de 17 bits
    logic [1:0] sync_ff;    // Flip-flops para sincronizar la señal a la frecuencia del sistema
    logic stable;           // Valor estable actual del botón


    // Sincronización de la señal del botón al dominio del reloj para evitar metastabilidad
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            sync_ff <= 2'b00;   // Reset: ambos flip-flops a 0
        end else begin
            sync_ff <= {sync_ff[0], button_in};     // Desplazamos la señal de entrada a través de dos flip-flops
        end
    end

    // Lógica de debounce:
    // Solo si la señal sincronizada se mantiene distinta al valor "estable" por más de DEBOUNCE_COUNT ciclos, se considera un cambio válido.
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            counter <= 17'd0; 
            stable <= 1'b0;   
        end else begin
            if (sync_ff[1] != stable) begin
                // Si la señal actual no coincide con la estable, empezamos a contar
                if (counter >= DEBOUNCE_COUNT) begin
                    // Si se mantiene por suficiente tiempo, aceptamos el nuevo valor
                    counter <= 17'd0;
                    stable <= sync_ff[1]; // Actualizamos la salida estable
                end else begin
                    // Aún no alcanza el conteo requerido, se suma
                    counter <= counter + 17'd1;
                end
            end else begin
                // Si la señal es igual al valor estable, reiniciamos el contador
                counter <= 17'd0;
            end
        end
    end

    // Asignamos la señal estable como salida del módulo
    assign button_out = stable;

endmodule