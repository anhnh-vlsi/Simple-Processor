
module system_top (
    input  logic        CLOCK_50,
    input  logic [9:0]  SW,
    input  logic [1:0]  KEY,
    output logic [8:0]  LEDR
);

    // --------------------------------
    // Internal signals
    // --------------------------------

    logic Resetn;
    logic Run_sync;

    logic [8:0] DIN;
    logic [8:0] ADDR;
    logic [8:0] DOUT;

    logic W;
    logic Done;

    logic Mem_W;
    logic LED_W;

    logic [8:0] LED_data;

    // --------------------------------
    // Input signals
    // --------------------------------

    assign Resetn = KEY[0];

    // Synchronize asynchronous Run input
    logic Run_meta;

    always_ff @(posedge CLOCK_50 or negedge Resetn) begin
        if (!Resetn) begin
            Run_meta <= 1'b0;
            Run_sync <= 1'b0;
        end
        else begin
            Run_meta <= SW[9];
            Run_sync <= Run_meta;
        end
    end

    // --------------------------------
    // Processor
    // --------------------------------

    proc u_proc (
        .DIN     (DIN),
        .Resetn  (Resetn),
        .Clock   (CLOCK_50),
        .Run     (Run_sync),
        .ADDR    (ADDR),
        .DOUT    (DOUT),
        .W       (W),
        .Done    (Done)
    );

    // --------------------------------
    // Address Decoder
    // --------------------------------
	 
	 assign Mem_W = W & ~ADDR[8] & ~ADDR[7];
	 assign LED_W = W & ~ADDR[8] & ADDR[7];

    // --------------------------------
    // RAM IP: 128 x 9
    // --------------------------------

    ram_128x9 u_ram (
        .address (ADDR[6:0]),
        .clock   (CLOCK_50),
        .data    (DOUT),
        .wren    (Mem_W),
        .q       (DIN)
    );

    // --------------------------------
    // LED Register: 9 bits
    // --------------------------------

    always_ff @(posedge CLOCK_50 or negedge Resetn) begin
        if (!Resetn)
            LED_data <= 9'b0;
        else if (LED_W)
            LED_data <= DOUT;
    end

    assign LEDR = LED_data;

endmodule
