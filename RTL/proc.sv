
module proc (
    input  logic [8:0] DIN,
    input  logic       Resetn,
    input  logic       Clock,
    input  logic       Run,

    output logic [8:0] ADDR,
    output logic [8:0] DOUT,
    output logic       W,
    output logic       Done,

    output logic [8:0] BusWires
);

    // ============================================================
    // Internal datapath signals
    // ============================================================

    logic [8:0] IR;

    logic [8:0] R0;
    logic [8:0] R1;
    logic [8:0] R2;
    logic [8:0] R3;
    logic [8:0] R4;
    logic [8:0] R5;
    logic [8:0] R6;

    logic [8:0] PC;
    logic [8:0] A_data;
    logic [8:0] G_data;
    logic [8:0] Alu_result;

    // ============================================================
    // Control signals
    // ============================================================

    logic        IRin;
    logic        Ain;
    logic        Gin;
    logic        AddSub;
    logic        Gout;
    logic        DINout;

    logic [6:0]  Rin;
    logic [6:0]  Rout;

    logic        PCout;
    logic        PCin;
    logic        Incr_pc;

    logic        ADDRin;
    logic        DOUTin;
    logic        W_D;

    // ============================================================
    // Control Unit
    // ============================================================

    control_unit u_control_unit (
        .Clk     (Clock),
        .Resetn  (Resetn),
        .Run     (Run),
        .IR      (IR),
        .G_data  (G_data),

        .IRin    (IRin),
        .Ain     (Ain),
        .Gin     (Gin),
        .Addsub  (AddSub),
        .Gout    (Gout),
        .DINout  (DINout),
        .Done    (Done),

        .Rin     (Rin),
        .Rout    (Rout),

        .PCout   (PCout),
        .PCin    (PCin),
        .Incr_pc (Incr_pc),

        .ADDRin  (ADDRin),
        .DOUTin  (DOUTin),
        .W_D     (W_D)
    );

    // ============================================================
    // Instruction Register
    // ============================================================

    register_instruction u_instruction_register (
        .IRin (IRin),
        .Clk  (Clock),
        .DIN  (DIN),
        .IR   (IR)
    );

    // ============================================================
    // Register File: R0 - R6
    // ============================================================

    register_file u_register_file (
        .Clk  (Clock),
        .Rin  (Rin),
        .Bus  (BusWires),

        .R0   (R0),
        .R1   (R1),
        .R2   (R2),
        .R3   (R3),
        .R4   (R4),
        .R5   (R5),
        .R6   (R6)
    );

    // ============================================================
    // Program Counter
    // ============================================================

    program_counter u_program_counter (
        .Clk     (Clock),
        .Resetn  (Resetn),
        .PCin    (PCin),
        .Incr_pc (Incr_pc),
        .Bus     (BusWires),
        .PC      (PC)
    );

    // ============================================================
    // Shared Bus Multiplexer
    // ============================================================

    multiplexer u_multiplexer (
        .DINout (DINout),
        .Gout   (Gout),
        .Rout   (Rout),
        .PCout  (PCout),

        .DIN    (DIN),
        .G_data (G_data),

        .R0     (R0),
        .R1     (R1),
        .R2     (R2),
        .R3     (R3),
        .R4     (R4),
        .R5     (R5),
        .R6     (R6),

        .PC     (PC),
        .Bus    (BusWires)
    );

    // ============================================================
    // A Register
    // ============================================================

    register_A u_register_A (
        .Bus    (BusWires),
        .Ain    (Ain),
        .Clk    (Clock),
        .A_data (A_data)
    );

    // ============================================================
    // ALU
    // ============================================================

    alu u_alu (
        .A_data     (A_data),
        .Bus        (BusWires),
        .Addsub     (AddSub),
        .Alu_result (Alu_result)
    );

    // ============================================================
    // G Register
    // ============================================================

    register_G u_register_G (
        .Gin        (Gin),
        .Clk        (Clock),
        .Alu_result (Alu_result),
        .G_data     (G_data)
    );

    // ============================================================
    // ADDR Register
    // ============================================================

    register_ADDR u_register_ADDR (
        .Clk    (Clock),
        .ADDRin (ADDRin),
        .Bus    (BusWires),
        .ADDR   (ADDR)
    );

    // ============================================================
    // DOUT Register
    // ============================================================

    register_DOUT u_register_DOUT (
        .Clk    (Clock),
        .DOUTin (DOUTin),
        .Bus    (BusWires),
        .DOUT   (DOUT)
    );

    // ============================================================
    // W Register
    // ============================================================

    register_W u_register_W (
        .Clk  (Clock),
        .W_D  (W_D),
        .W    (W)
    );

endmodule
