//todo__comments: El reloj es de 50MHz == 50 millones de flancos de subida por segundo.
//todo__comments: Un flanco cada 20ns o 1000 flancos por 20 microsegundos --> 50 flancos por microsegundo.

module semaforo_inteligente (
    input  logic       clk,
    input  logic       rst,
    input  logic       start,             // Esta señal es para iniciar el ciclo
    input  logic       sensor_vehiculo,   // extender el tiempo --> "VERDE"
    output logic [1:0] luz                // 00: Rojo, 01: Amarillo, 10: Verde

);

    // Aqui se definen los estados (6 en total)
    typedef enum logic [2:0] {
        INACTIVO        = 3'd0,
        VERDE           = 3'd1,
        AMARILLO_ON_1   = 3'd2,
        AMARILLO_OFF    = 3'd3,
        AMARILLO_ON_2   = 3'd4,
        ROJO            = 3'd5
    } estado_t;

    estado_t estado_actual, estado_siguiente;

    int tiempo_limite;
    
    logic [3:0] contador; // Hasta 15 ciclos es suficiente

    // ------------------ LÓGICA SECUENCIAL ------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            estado_actual <= VERDE; // Aqui se inicia en "VERDE"
            contador <= 0;
        end else begin
            if (estado_actual != estado_siguiente) begin
                estado_actual <= estado_siguiente;
                contador <= 1; // reinicia contador al cambiar de estado
            end else if (start == 1) begin
                contador <= contador + 1;
            end
        end
    end

    // ------------------ LÓGICA COMBINACIONAL ------------------
    always_comb begin
        estado_siguiente = estado_actual;
		  tiempo_limite = 10;

        case (estado_actual)
            INACTIVO: begin
                if (start)
                    estado_siguiente = VERDE;
            end

            VERDE: begin
                if (contador == 10)
                    estado_siguiente = AMARILLO_ON_1;
            end

            //this extra condition for "sensor_vehiculo"
            VERDE: begin
                if (sensor_vehiculo)
                    tiempo_limite = 12;  // 2 ciclos más, por ejemplo
                else
                    tiempo_limite = 10;

                 if (contador == tiempo_limite)
                    estado_siguiente = AMARILLO_ON_1;
            end
            //this extra condition for "sensor_vehiculo"

            AMARILLO_ON_1: begin
                if (contador == 2)
                    estado_siguiente = AMARILLO_OFF;
            end

            AMARILLO_OFF: begin
                if (contador == 2)
                    estado_siguiente = AMARILLO_ON_2;
            end

            AMARILLO_ON_2: begin
                if (contador == 2)
                    estado_siguiente = ROJO;
            end

            ROJO: begin
                if (contador == 15)
                    estado_siguiente = INACTIVO;
            end

            default: estado_siguiente = INACTIVO;
        endcase
    end

    // ------------------ SALIDA LUZ ------------------
    always_comb begin
        case (estado_actual)
            VERDE:          luz = 2'b10;
            AMARILLO_ON_1,               //without condition "yellow" == "luz contador" doens't have duty cycles.
            AMARILLO_ON_2:  luz = 2'b01;
            AMARILLO_OFF,
            ROJO,
            INACTIVO:       luz = 2'b00;
            default:        luz = 2'b00;
        endcase
    end

endmodule
