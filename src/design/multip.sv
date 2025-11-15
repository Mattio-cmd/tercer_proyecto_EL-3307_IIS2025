module BoothMul(
    input clk,                      // Señal de reloj
    input rst,                      // Señal de reinicio (activa bajo)
    input start,                    // Señal para iniciar la multiplicación
    input logic [7:0] A,           // Operando A (máximo 99)
    input logic [7:0] B,           // Operando B (máximo 99)
    output logic [15:0] Y,     // Resultado (máximo 9999)
    output logic valid                // Señal de validación de resultado
);

    // Registros internos
    reg signed [15:0] Y_temp, next_Y_temp;        // Registro temporal para el cálculo
    reg [7:0] multiplicand, next_multiplicand;    // Operando multiplicador (B)
    reg [3:0] count, next_count;                  // Contador de iteraciones (máximo 8)
    reg [1:0] booth_code, next_booth_code;        // Código Booth (2 bits)
    reg next_valid;                               // Señal de validación para la salida
    reg state, next_state;                        // Estados de la FSM

    // Estados de la máquina de estados finitos (FSM)
    parameter IDLE = 1'b0;      // Estado inactivo (esperando para empezar)
    parameter START = 1'b1;     // Estado de cálculo

    // Bloque secuencial: actualización de registros
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reinicio de los registros internos
            Y <= 16'd0;
            valid <= 1'b0;
            Y_temp <= 16'd0;
            multiplicand <= 8'd0;
            count <= 4'd0;
            booth_code <= 2'd0;
            state <= IDLE;
        end else begin
            // Actualización de los registros con los valores próximos
            Y <= Y_temp;
            valid <= next_valid;
            Y_temp <= next_Y_temp;
            multiplicand <= next_multiplicand;
            count <= next_count;
            booth_code <= next_booth_code;
            state <= next_state;
        end
    end

    // Lógica combinacional: implementación del algoritmo de Booth
    always @(*) begin
        // Valores predeterminados
        next_Y_temp = Y_temp;
        next_multiplicand = multiplicand;
        next_count = count;
        next_booth_code = booth_code;
        next_valid = 1'b0;
        next_state = state;

        case (state)
            IDLE: begin
                // Configuración inicial
                if (start) begin
                    // Inicializar Y_temp con A en los bits menos significativos (considerar signo)
                    next_Y_temp = {8'd0, A};  // Para manejar el signo de A adecuadamente
                    next_multiplicand = B;    // Cargar el multiplicador B
                    next_booth_code = {A[0], 1'b0};  // Inicializar el código Booth con el bit menos significativo de A y un bit extra
                    next_count = 4'd0;         // Reiniciar el contador de iteraciones
                    next_state = START;       // Cambiar al estado START para comenzar el cálculo
                end
            end

            START: begin
                // Operaciones de Booth según el código Booth
                case (booth_code)
                    2'b10: next_Y_temp = {Y_temp[15:8] - multiplicand, Y_temp[7:0]}; // Restar multiplicador B
                    2'b01: next_Y_temp = {Y_temp[15:8] + multiplicand, Y_temp[7:0]}; // Sumar multiplicador B
                    default: next_Y_temp = Y_temp; // No hacer nada (cuando booth_code es 00 o 11)
                endcase

                // Desplazamiento aritmético a la derecha (considerando el signo)
                next_Y_temp = next_Y_temp >>> 1;

                // Actualización del código Booth y contador
                next_booth_code = {Y_temp[1], Y_temp[0]};  // Nueva evaluación del código Booth con los 2 bits menos significativos de Y_temp
                next_count = count + 1'b1;                   // Incrementar el contador de iteraciones

                // Verificar si la multiplicación ha terminado (8 iteraciones)
                if (next_count == 4'd8) begin
                    next_valid = 1'b1;   // Señal de resultado válido
                    next_state = IDLE;   // Volver al estado IDLE para esperar una nueva operación
                end else begin
                    next_state = START; // Continuar en el estado START
                end
            end
        endcase
        //Y = A + B;
    end
endmodule