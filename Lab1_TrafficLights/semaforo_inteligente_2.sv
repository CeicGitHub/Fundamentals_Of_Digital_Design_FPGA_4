//??EN ESTE PROGRAMA LOS "LEDG1" y "LEDG5" PERMANENCEN PRENDIDOS Y AL PONER 
//?? START EN ALTO Y DEJAR PRESIONADO RST SE ENCIENDEN LEDG7, LEDG6, LEDG5, LEDG1 Y LEDG0


module semaforo_inteligente_2(
    input  logic       clk,             //!! CLK --> PINY2 (50 MHZ CLOCK)
    input  logic       rst,             //!! rst --> KEY0
    input  logic       start,           //!! start --> SW1
    input  logic       sensor_vehiculo, //!! sensorvehiculo --> SW0
    output logic [1:0] luz,             //!! 00: rojo, 01: amarillo, 10: verde && luz[0] --> LEDG0; luz[1] --> LEDG1   
	 output logic [2:0] estado_debug    //!! estado debug[0] --> LEDG5;  estado debug[1] --> LEDG6; estado debug[2] --> LEDG7
 
);
 
//Divisor De Frecuencia Para Generar "clk_lento" //
logic [25:0] divisor;  // 26 bits para dividir hasta 0.5s (aprox)
logic clk_lento;
 

     always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            divisor <= 0;
            clk_lento <= 0;
        end else begin
            if (divisor == 25_000_000) begin  // 0.5s a 50MHz
                clk_lento <= ~clk_lento;
                divisor <= 0;
            end else begin
                divisor <= divisor + 1;
            end
        end
    end
 
	 
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
	 assign estado_debug = estado_actual;  // Salida de monitoreo

 
    // ------------------ LÓGICA SECUENCIAL ------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            estado_actual <= VERDE; // Aqui se inicia en "VERDE"
            contador <= 0;
        end else begin
		      contador <= contador + 1;
            if (start == 1 && estado_actual != estado_siguiente) begin
					estado_actual <= estado_siguiente;
					contador <= 1;
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
 
            //this extra condition for "sensor_vehiculo"
            VERDE: begin
                if (sensor_vehiculo)
                    tiempo_limite = 12;
                else
                    tiempo_limite = 10;
 
                 if (contador == tiempo_limite)
                    estado_siguiente = AMARILLO_ON_1;
            end
            //this extra condition for "sensor_vehiculo"
 
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
                if (contador ==  tiempo_limite)
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

