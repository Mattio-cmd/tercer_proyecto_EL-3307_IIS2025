`timescale 1ns/1ps

module display_controller_tb;

    // Entradas
    logic clk;
    logic rst;
    logic refresh_tick;
    logic [3:0] bcd_thousands, bcd_hundreds, bcd_tens, bcd_ones;

    // Salidas
    logic [6:0] seg;
    logic [3:0] an;

    // Instancia del módulo bajo prueba (UUT)
    display_controller uut (
        .clk(clk),
        .rst(rst),
        .refresh_tick(refresh_tick),
        .bcd_thousands(bcd_thousands),
        .bcd_hundreds(bcd_hundreds),
        .bcd_tens(bcd_tens),
        .bcd_ones(bcd_ones),
        .seg(seg),
        .an(an)
    );

    // Generar reloj de 10 ns (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Variables internas
    integer i;

    initial begin
        // Inicialización
        rst = 0;
        refresh_tick = 0;
        bcd_thousands = 4'd1;
        bcd_hundreds  = 4'd2;
        bcd_tens      = 4'd3;
        bcd_ones      = 4'd4;

        // Reset corto
        #20;
        rst = 1;

        // Simular refresh ticks cada 1us
        for (i = 0; i < 20; i = i + 1) begin
            refresh_tick = 1;
            #10;
            refresh_tick = 0;
            #990; // Espera hasta 1us total
        end

        $finish;
    end

    // Mostrar valores cada cambio
    always @(posedge clk) begin
        $display("Time: %0t | An: %b | Seg: %b", $time, an, seg);
    end

        initial begin
      $dumpfile("display_controller_tb.vcd");  // For waveform viewing
      $dumpvars(0, display_controller_tb);
    end

endmodule
