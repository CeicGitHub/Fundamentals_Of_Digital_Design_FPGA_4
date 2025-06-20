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

    // Aserciones
    // 1. El semáforo debe iniciar en estado INACTIVO
    assert (estado_debug === 3'd0)
        else $error("Error: El sistema no inició en estado INACTIVO");

    // 2. Durante estado VERDE, la luz debe ser 10
    wait_n_slow_cycles(1);
    if (estado_debug == 3'd1)
        assert (luz == 2'b10)
        else $error("Error: La luz no es VERDE en estado VERDE");

    // 3. En AMARILLO_ON_1, la luz debe ser 01
    wait_n_slow_cycles(10); // llegar a AMARILLO_ON_1
    if (estado_debug == 3'd2)
        assert (luz == 2'b01)
        else $error("Error: Luz incorrecta en AMARILLO_ON_1");

    // 4. En AMARILLO_OFF, la luz debe estar apagada (00)
    wait_n_slow_cycles(2); // llegar a AMARILLO_OFF
    if (estado_debug == 3'd3)
        assert (luz == 2'b00)
        else $error("Error: Luz no está apagada en AMARILLO_OFF");

    // 5. En ROJO, la luz debe ser 11
    wait_n_slow_cycles(4); // avanzar hasta ROJO
    if (estado_debug == 3'd5)
        assert (luz == 2'b11)
        else $error("Error: Luz incorrecta en ROJO");

    // Fin de la simulación
    $display("=========== Fin del testbench ===========");
    //$finish;
  end

endmodule

