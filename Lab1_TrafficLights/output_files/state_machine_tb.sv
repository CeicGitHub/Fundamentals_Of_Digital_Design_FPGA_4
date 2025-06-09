`timescale 1ns/1ps

module state_machine_tb;

    reg clk;
    reg reset;
    reg a;
    reg b;
    wire [2:0] out;

    // Instanciamos el módulo bajo prueba
    state_machine uut (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .out(out)
    );

    // Generador de reloj: periodo 10ns
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Inicialización
        reset = 1;
        a = 0;
        b = 0;

        // Liberar reset
        #15 reset = 0;

        // Estado 0: a=0, debe quedarse en 0
        #10 a = 0; b = 0;

        // Estado 0: activar 'a' para pasar a estado 1
        #10 a = 1;

        // Estado 1 a 2 (no importa a ni b)
        #10 a = 0; b = 0;

        // Estado 2 a 3: b=1 para avanzar
        #10 b = 1;

        // Estado 3 a 4 (sin condición)
        #10 b = 0;

        // Estado 4 a 5: b=1 para quedarse, b=0 para reset
        #20 b = 1;

        // Ahora b=0 para resetear
        #10 b = 0;

        // Esperar un poco y terminar simulación
        #20 $finish;
    end

    initial begin
        $monitor("Time=%0t | reset=%b a=%b b=%b | state_machine out=%b",
                 $time, reset, a, b, out);
    end

endmodule