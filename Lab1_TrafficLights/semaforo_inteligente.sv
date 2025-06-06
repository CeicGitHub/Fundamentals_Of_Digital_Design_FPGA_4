/*This module is the first code eraser for show the implementation for lab1
	traffic ligths, here we define the requeriments of the time and some values*/

module semaforo_inteligente (
    input wire clk,
    input wire rst,
    input wire sensor_vehiculo,  //esta pensando para control de extensión o reducción de tiempos.
    output reg [1:0] luz 			// 00: Rojo, 01: Amarillo, 10: Verde
);

    //State definitions
    typedef enum reg [1:0] {
        ROJO = 2'b00,
        AMARILLO = 2'b01,
        VERDE = 2'b10
    } estado_t;

    estado_t estado_actual, estado_siguiente;

    // Temporizadores
    // Systemfucntion $clog2
    reg [31:0] contador;

    // Parámetros de tiempo (en ciclos de reloj)
    //TODO find how we can do this in microseconds time
    //TODO find how many posedge are neccesary for "50 MHZ"
    //FIXME 
    parameter TIEMPO_VERDE = 32'd5000_0000;    // 1 segundo a 50 MHz
    parameter TIEMPO_AMARILLO = 32'd1000_0000; // 0.2 segundos
    parameter TIEMPO_ROJO = 32'd5000_0000;     // 1 segundo

    // Lógica de transición de estados
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            estado_actual <= ROJO;
            contador <= 0;
        end else begin
            estado_actual <= estado_siguiente;
            if (estado_actual != estado_siguiente)
                contador <= 0;
            else
                contador <= contador + 1;
        end
    end

    // Lógica de siguiente estado
    always @(*) begin
        estado_siguiente = estado_actual;
        case (estado_actual)
            ROJO: if (contador >= TIEMPO_ROJO) estado_siguiente = VERDE;
            VERDE: if (contador >= TIEMPO_VERDE) estado_siguiente = AMARILLO;
            AMARILLO: if (contador >= TIEMPO_AMARILLO) estado_siguiente = ROJO;
        endcase
    end

    // Salida de luces
    always @(*) begin
        case (estado_actual)
            ROJO: luz = 2'b00;
            AMARILLO: luz = 2'b01;
            VERDE: luz = 2'b10;
            default: luz = 2'b00;
        endcase
    end

endmodule




