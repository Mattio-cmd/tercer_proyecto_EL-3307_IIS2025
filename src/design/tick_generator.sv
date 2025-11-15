module tick_generator #(parameter MAX_COUNT = 27000) ( //modulo encargado de genera un pulso cada milisegundo
    input  logic clk,            // Reloj de entrada
    input  logic rst,            // Reset activo bajo (asumo)
    output logic tick            // Pulso de tick
);
    // Calcular ancho de contador automáticamente
    localparam COUNT_WIDTH = $clog2(MAX_COUNT);
    logic [COUNT_WIDTH-1:0] count;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            count <= '0;           // Reset explícito a 0
            tick  <= 1'b0;         // Reset también la señal de tick
        end
        else begin
            if (count == MAX_COUNT - 1) begin
                count <= '0;
                tick  <= 1'b1;     // e activa el tick una vez el contador alcanza el maximo 
            end
            else begin
                count <= count + 1;
                tick  <= 1'b0;     // Mantener tick bajo
            end
        end
    end

    endmodule

