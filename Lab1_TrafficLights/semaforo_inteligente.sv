/*This module is the first code eraser for show the implementation for lab1
	traffic ligths, here we define the requeriments of the time and some values*/

module semaforo_inteligente (
    input  logic       clk,
    input  logic       rst,
    input  logic       sensor_vehiculo,  //Aqui se extiende el tiempo en "Verde" si está activo
    output logic [1:0] luz               // 00: Rojo, 01: Amarillo, 10: Verde
);

    // Este typedef es para definir cada uno de los estados
    typedef enum logic [1:0] {
        ROJO      = 2'b00,
        AMARILLO  = 2'b01,
        VERDE     = 2'b10
    } estado_t;

    estado_t estado_actual, estado_siguiente;

    // Definicion de tiempos en microsegundos
    parameter int MICROSEGUNDOS_VERDE_BASE   = 1_000_000; // 1 segundo
    parameter int MICROSEGUNDOS_AMARILLO     =   200_000; // 0.2 segundos
    parameter int MICROSEGUNDOS_ROJO         = 1_000_000; // 1 segundo

    //TODO -- El reloj es de 50MHz == 50 millones de flancos de subida por segundo --> un flanco cada 20ns o 1000 flancos por 20 microsegundos
    //TODO -- esto equivale a 50 flancos por microsegundo.
    parameter int FRECUENCIA_RELOJ_MHZ       = 50;        // 50 MHz

    // Calculo de ciclos de reloj
    localparam int TIEMPO_VERDE_BASE   = MICROSEGUNDOS_VERDE_BASE   * FRECUENCIA_RELOJ_MHZ;
    localparam int TIEMPO_VERDE_EXTRA  =   250_000 * FRECUENCIA_RELOJ_MHZ; // 0.25 seg extra si hay carro
    localparam int TIEMPO_AMARILLO     = MICROSEGUNDOS_AMARILLO     * FRECUENCIA_RELOJ_MHZ;
    localparam int TIEMPO_ROJO         = MICROSEGUNDOS_ROJO         * FRECUENCIA_RELOJ_MHZ;

    // Tamano optimo del contador
    logic [$clog2(TIEMPO_VERDE_BASE + TIEMPO_VERDE_EXTRA):0] contador;
    int tiempo_limite;

    // Logica secuencial: actualización de estado y contador
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            estado_actual <= ROJO;
            contador <= 0;
        end else begin
            if (estado_actual != estado_siguiente) begin
                estado_actual <= estado_siguiente;
                contador <= 0;
            end else begin
                contador <= contador + 1;
            end
        end
    end

    // Logica combinacional: transición de estados y cálculo de tiempos
    always_comb begin
        estado_siguiente = estado_actual;

        case (estado_actual)
            ROJO: begin
                tiempo_limite = TIEMPO_ROJO;
                if (contador == tiempo_limite) //because counter never will be more that limit time.
                    estado_siguiente = VERDE;
            end

            VERDE: begin
                tiempo_limite = sensor_vehiculo ? (TIEMPO_VERDE_BASE + TIEMPO_VERDE_EXTRA)
                                                : TIEMPO_VERDE_BASE;
                if (contador >= tiempo_limite)
                    estado_siguiente = AMARILLO;
            end

            AMARILLO: begin
                tiempo_limite = TIEMPO_AMARILLO;
                if (contador >= tiempo_limite)
                    estado_siguiente = ROJO;
            end
        endcase
    end

    // Logica de salida
    always_comb begin
        case (estado_actual)
            ROJO:     luz = 2'b00;
            AMARILLO: luz = contador<25_000_000 || contador>75_000_000 ?  2'b01 : 2'b00; //blink condintion for yellow
            VERDE:    luz = 2'b10;
            default:  luz = 2'b00;
        endcase
    end

endmodule



