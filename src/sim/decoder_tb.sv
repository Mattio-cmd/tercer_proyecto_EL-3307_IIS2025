`timescale 1 ns / 100 ps

module decoder_tb; 
  // Señales
  logic [3:0] columnas;
  logic [3:0] filas;
  logic [3:0] key;

  
  decoder uut (
    .columnas(columnas),
    .filas(filas),
    .key(key)
  );

  // Procedimiento de prueba
  initial begin
    $display("Time\tColumnas\tFilas\t|\tKey");
    $display("---------------------------------------------");

    // Test de todas las combinaciones válidas
    test_key(4'b0001, 4'b1110, 4'b0001); // 1
    test_key(4'b0001, 4'b1101, 4'b0010); // 2
    test_key(4'b0001, 4'b1011, 4'b0011); // 3
    test_key(4'b0001, 4'b0111, 4'b1010); // A
    
    test_key(4'b0010, 4'b1110, 4'b0100); // 4
    test_key(4'b0010, 4'b1101, 4'b0101); // 5
    test_key(4'b0010, 4'b1011, 4'b0110); // 6
    test_key(4'b0010, 4'b0111, 4'b1011); // B
    
    test_key(4'b0100, 4'b1110, 4'b0111); // 7
    test_key(4'b0100, 4'b1101, 4'b1000); // 8
    test_key(4'b0100, 4'b1011, 4'b1001); // 9
    test_key(4'b0100, 4'b0111, 4'b1100); // C
    
    test_key(4'b1000, 4'b1110, 4'b1110); // *
    test_key(4'b1000, 4'b1101, 4'b0000); // 0
    test_key(4'b1000, 4'b1011, 4'b1111); // #
    test_key(4'b1000, 4'b0111, 4'b1101); // D

    // Test de combinación inválida
    test_key(4'b1111, 4'b1111, 4'b0000); // No presionada

    $finish;
  end

  // Tarea para evitar repetir código
  task test_key(input logic [3:0] col, input logic [3:0] fil, input logic [3:0] expected_key);
    begin
      columnas = col;
      filas = fil;
      #5; // pequeño delay para simular
      $display("%0t\t%b\t%b\t|\t%b", $time, columnas, filas, key);
      if (key !== expected_key)
        $error("Error: Esperado %b, pero obtenido %b", expected_key, key);
    end
  endtask

  
    initial begin
        $dumpfile("decoder_tb.vcd");  // For waveform viewing
        $dumpvars(0, decoder_tb);
    end

endmodule


