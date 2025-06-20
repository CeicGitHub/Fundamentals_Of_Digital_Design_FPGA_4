
`timescale 1ns/1ps

module tb_semaforo_inteligente;

  // Señales
  logic clk;
  logic rst;
  logic start;
  logic sensor_vehiculo;
  logic [1:0] luz;
  logic [2:0] estado_debug;
  logic clk_lento_debug;

  // Instancia del DUT
  semaforo_inteligente dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .sensor_vehiculo(sensor_vehiculo),
    .luz(luz),
    .estado_debug(estado_debug),
    .clk_lento_debug(clk_lento_debug)
  );

  // Generador de reloj de 50 MHz (20 ns periodo)
  always #10 clk = ~clk;

  // Tarea para esperar por N ciclos de clk_lento
  task automatic wait_n_slow_cycles(int n);
    automatic int count = 0;
    logic prev_clk_lento;
    prev_clk_lento = clk_lento_debug;
    while (count < n) begin
      @(posedge clk);
      if (clk_lento_debug && !prev_clk_lento) count++;
      prev_clk_lento = clk_lento_debug;
    end
  endtask

  // Inicialización
  initial begin
    $display("=========== Iniciando simulación del semáforo ===========");
    $dumpfile("semaforo_tb.vcd");
    $dumpvars(0, tb_semaforo_inteligente);

    // Inicialización de señales
    clk = 0;
    rst = 0;
    start = 0;
    sensor_vehiculo = 0;

    // Reset activo
    #50 rst = 1;
    $display("Reset liberado");

    // Esperar 2 ciclos lentos y activar start
    wait_n_slow_cycles(2);
    start = 1;
    $display("Start activado");

    // Verificar VERDE
    wait_n_slow_cycles(10);
    $display("Verde: luz = %b, estado = %d", luz, estado_debug);

    // AMARILLO ON 1
    wait_n_slow_cycles(2);
    $display("Amarillo ON 1: luz = %b, estado = %d", luz, estado_debug);

    // AMARILLO OFF
    wait_n_slow_cycles(2);
    $display("Amarillo OFF: luz = %b, estado = %d", luz, estado_debug);

    // AMARILLO ON 2
    wait_n_slow_cycles(2);
    $display("Amarillo ON 2: luz = %b, estado = %d", luz, estado_debug);

    // ROJO
    wait_n_slow_cycles(15);
    $display("Rojo: luz = %b, estado = %d", luz, estado_debug);

    // INACTIVO (esperando nuevo start)
    start = 0;
    wait_n_slow_cycles(2);
    $display("Inactivo: luz = %b, estado = %d", luz, estado_debug);

    // Fin de la simulación
    $display("=========== Fin del testbench ===========");
    $finish;
  end

endmodule

