//** Team9: Lab1_TrafficLights ; Module4
//** This program corresponds to the main logic of the "stable" version. 
//** The behavior simulates a state machine for traffic light signals, such that through defined execution times and truth states in transition, each of these elements is represented.

module semaforo_inteligente (
    input  logic       clk,               //!! CLK --> PINY2 (50 MHZ CLOCK)
    input  logic       rst,               //!! rst --> KEY0
    input  logic       start,             //!! start --> SW1
    input  logic       sensor_vehiculo,   //!! sensorvehiculo --> SW0
    output logic [1:0] luz,               //!! 00: rojo, 01: amarillo, 10: verde && luz[0] --> LEDG0; luz[1] --> LEDG1
    output logic [2:0] estado_debug,      //!! estado debug[0] --> LEDG5;  estado debug[1] --> LEDG6; estado debug[2] --> LEDG7
    output logic       clk_lento_debug    //!! clk_lento_debug --> LEDG8
);

    // ---------- Divisor de frecuencia ----------
    logic [25:0] divisor = 0;
    logic clk_lento = 0;

    assign clk_lento_debug = clk_lento;

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
        divisor <= 0;
        clk_lento <= 0;
        end else begin
            if (divisor == 5) begin  // 0.5 segundos //25_000_000
            clk_lento <= ~clk_lento;
            divisor <= 0;
            end else begin
            divisor <= divisor + 1;
            end
        end
    end

    // ---------- Estados ----------
    typedef enum logic [2:0] {
        INACTIVO        = 3'd0,
        VERDE           = 3'd1,
        AMARILLO_ON_1   = 3'd2,
        AMARILLO_OFF    = 3'd3,
        AMARILLO_ON_2   = 3'd4,
        ROJO            = 3'd5
    } estado_t;

    estado_t estado_actual, estado_siguiente;
    logic [3:0] contador;
    int tiempo_limite;

    assign estado_debug = estado_actual;

    // ---------- FSM SECUENCIAL ----------
    always_ff @(posedge clk_lento or negedge rst) begin
        if (~rst) begin
            estado_actual <= INACTIVO;
            contador <= 0;
        end else if (start) begin
            if (contador == tiempo_limite) begin
                estado_actual <= estado_siguiente;
                contador <= 1;
            end else begin
                contador <= contador + 1;
            end
        end else begin
            // Si start == 0, no se avanza ni cuenta
            estado_actual <= estado_actual;
            contador <= contador;
        end
    end

    // ---------- FSM COMBINACIONAL ----------
    always_comb begin
        estado_siguiente = estado_actual;
        tiempo_limite = 10;

        case (estado_actual)
            INACTIVO: begin
                if (start)
                    estado_siguiente = VERDE;
            end

            VERDE: begin
                tiempo_limite = sensor_vehiculo ? 12 : 10;
                if (contador == tiempo_limite)
                    estado_siguiente = AMARILLO_ON_1;
            end

            AMARILLO_ON_1: begin
                tiempo_limite = 2;
                if (contador == tiempo_limite)
                    estado_siguiente = AMARILLO_OFF;
            end

            AMARILLO_OFF: begin
                tiempo_limite = 2;
                if (contador == tiempo_limite)
                    estado_siguiente = AMARILLO_ON_2;
            end

            AMARILLO_ON_2: begin
                tiempo_limite = 2;
                if (contador == tiempo_limite)
                    estado_siguiente = ROJO;
            end

            ROJO: begin
                tiempo_limite = 15;
                if (contador == tiempo_limite)
                    estado_siguiente = INACTIVO;
            end

            default: estado_siguiente = INACTIVO;
        endcase
    end

    // ---------- SALIDA DE LUCES ----------
    always_comb begin
        case (estado_actual)
            VERDE:          luz = 2'b10;
            AMARILLO_ON_1:  luz = 2'b01;
            AMARILLO_ON_2:  luz = 2'b01;
            AMARILLO_OFF:   luz = 2'b00;
            ROJO:           luz = 2'b11;
            INACTIVO:       luz = 2'b00;
            default:        luz = 2'b00;
        endcase
    end

endmodule

