module system_top (
    input  logic        CLOCK_50,
    input  logic [9:0]  SW,
    input  logic [1:0]  KEY,
    output logic [8:0]  LEDR
);

    logic Resetn;
    logic Run_meta;
    logic Run_sync;

    logic [8:0] DIN;
    logic [8:0] ADDR;
    logic [8:0] DOUT;
    logic [8:0] BusWires;

    logic W;
    logic Done;
    logic LED_en;
    logic Mem_en;

    // KEY0 is active-low on the DE-series board.
    assign Resetn = KEY[0];

    // Synchronize the asynchronous Run switch to CLOCK_50.
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

    // Enhanced processor with Lab 6 FPU integrated internally.
    proc u_proc (
        .DIN     (DIN),
        .Resetn  (Resetn),
        .Clock   (CLOCK_50),
        .Run     (Run_sync),
        .ADDR    (ADDR),
        .DOUT    (DOUT),
        .W       (W),
        .Done    (Done),
        .BusWires(BusWires)
    );

    // Decode writes to RAM (ADDR[8:7] = 2'b00)
    // and the LED peripheral (ADDR[8:7] = 2'b01).
    address_decoder u_address_decoder (
        .ADDR   (ADDR),
        .W      (W),
        .LED_en (LED_en),
        .Mem_en (Mem_en)
    );

    // 128 x 9 on-chip RAM IP. Its output is unregistered.
    // The IP variation must be named ram_128x9 and expose these ports.
    ram_128x9 u_ram (
        .address (ADDR[6:0]),
        .clock   (CLOCK_50),
        .data    (DOUT),
        .wren    (Mem_en),
        .q       (DIN)
    );

    // Memory-mapped 9-bit LED peripheral.
    register_led u_led_register (
        .Clk  (CLOCK_50),
        .Load (LED_en),
        .Data (DOUT),
        .LED  (LEDR)
    );

endmodule
