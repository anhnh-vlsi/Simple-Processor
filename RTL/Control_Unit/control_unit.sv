module control_unit (
    input  logic       Clk,
    input  logic       Resetn,
    input  logic       Run,
    input  logic [8:0] IR,
    input  logic [8:0] G_data,

    output logic       IRin,
    output logic       Ain,
    output logic       Gin,
    output logic       Addsub,
    output logic [1:0] Gout,
    output logic       DINout,
    output logic       AFin,
    output logic       GFin,
    output logic       AddSubF,
    output logic       Done,
    output logic [6:0] Rin,
    output logic [6:0] Rout,
    output logic       PCout,
    output logic       PCin,
    output logic       Incr_pc,
    output logic       ADDRin,
    output logic       DOUTin,
    output logic       W_D
);

    localparam logic [2:0] T0 = 3'b000;
    localparam logic [2:0] T1 = 3'b001;
    localparam logic [2:0] T2 = 3'b010;
    localparam logic [2:0] T3 = 3'b011;
    localparam logic [2:0] T4 = 3'b100;
    localparam logic [2:0] T5 = 3'b101;

    localparam logic [2:0] OP_MV   = 3'b000;
    localparam logic [2:0] OP_MVI  = 3'b001;
    localparam logic [2:0] OP_ADD  = 3'b010;
    localparam logic [2:0] OP_SUB  = 3'b011;
    localparam logic [2:0] OP_LD   = 3'b100;
    localparam logic [2:0] OP_ST   = 3'b101;
    localparam logic [2:0] OP_MVNZ = 3'b110;
    localparam logic [2:0] OP_ADDF = 3'b111;

    logic [2:0] current_state;
    logic [2:0] next_state;
    logic [2:0] opcode;
    logic [2:0] rx_addr;
    logic [2:0] ry_addr;
    logic [7:0] Xreg;
    logic [7:0] Yreg;

    assign opcode = IR[8:6];
    assign rx_addr = IR[5:3];
    assign ry_addr = IR[2:0];

    decoder3to8 X_reg_decode (
        .EN   (1'b1),
        .din  (rx_addr),
        .dout (Xreg)
    );

    decoder3to8 Y_reg_decode (
        .EN   (1'b1),
        .din  (ry_addr),
        .dout (Yreg)
    );

    always_ff @(posedge Clk or negedge Resetn) begin
        if (!Resetn)
            current_state <= T0;
        else
            current_state <= next_state;
    end

    always_comb begin
        next_state = T0;
        case (current_state)
            T0: begin
                if (Run)
                    next_state = T1;
                else
                    next_state = T0;
            end
            T1: next_state = T2;
            T2: next_state = T3;
            T3: begin
                case (opcode)
                    OP_MV, OP_MVNZ: next_state = T0;
                    OP_MVI, OP_ADD, OP_SUB, OP_LD, OP_ST, OP_ADDF: next_state = T4;
                    default: next_state = T0;
                endcase
            end
            T4: next_state = T5;
            T5: next_state = T0;
            default: next_state = T0;
        endcase
    end

    always_comb begin
        IRin     = 1'b0;
        Ain      = 1'b0;
        Gin      = 1'b0;
        Addsub   = 1'b0;
        Gout     = 2'b00;
        DINout   = 1'b0;
        AFin     = 1'b0;
        GFin     = 1'b0;
        AddSubF  = 1'b0;
        Done     = 1'b0;
        Rin      = 7'b0000000;
        Rout     = 7'b0000000;
        PCin     = 1'b0;
        PCout    = 1'b0;
        Incr_pc  = 1'b0;
        ADDRin   = 1'b0;
        DOUTin   = 1'b0;
        W_D      = 1'b0;

        case (current_state)
            T0: begin
                if (Run) begin
                    PCout   = 1'b1;
                    ADDRin  = 1'b1;
                    Incr_pc = 1'b1;
                end
            end

            T1: begin
            end

            T2: begin
                IRin = 1'b1;
            end

            T3: begin
                case (opcode)
                    OP_MV: begin
                        {PCout, Rout} = Yreg;
                        {PCin, Rin} = Xreg;
                        Done = 1'b1;
                    end
                    OP_MVI: begin
                        PCout   = 1'b1;
                        ADDRin  = 1'b1;
                        Incr_pc = 1'b1;
                    end
                    OP_ADD, OP_SUB: begin
                        {PCout, Rout} = Xreg;
                        Ain = 1'b1;
                    end
                    OP_LD, OP_ST: begin
                        {PCout, Rout} = Yreg;
                        ADDRin = 1'b1;
                    end
                    OP_MVNZ: begin
                        if (G_data != 9'b0) begin
                            {PCout, Rout} = Yreg;
                            {PCin, Rin} = Xreg;
                        end
                        Done = 1'b1;
                    end
                    OP_ADDF: begin
                        {PCout, Rout} = Xreg;
                        AFin = 1'b1;
                    end
                    default: begin
                    end
                endcase
            end

            T4: begin
                case (opcode)
                    OP_ADD: begin
                        {PCout, Rout} = Yreg;
                        Gin = 1'b1;
                    end
                    OP_SUB: begin
                        {PCout, Rout} = Yreg;
                        Gin = 1'b1;
                        Addsub = 1'b1;
                    end
                    OP_ST: begin
                        {PCout, Rout} = Xreg;
                        DOUTin = 1'b1;
                        W_D = 1'b1;
                    end
                    OP_ADDF: begin
                        {PCout, Rout} = Yreg;
                        GFin = 1'b1;
                        AddSubF = 1'b0;
                    end
                    default: begin
                    end
                endcase
            end

            T5: begin
                case (opcode)
                    OP_MVI, OP_LD: begin
                        DINout = 1'b1;
                        {PCin, Rin} = Xreg;
                        Done = 1'b1;
                    end
                    OP_ADD, OP_SUB: begin
                        Gout = 2'b10;
                        {PCin, Rin} = Xreg;
                        Done = 1'b1;
                    end
                    OP_ADDF: begin
                        Gout = 2'b01;
                        {PCin, Rin} = Xreg;
                        Done = 1'b1;
                    end
                    OP_ST: Done = 1'b1;
                    default: begin
                    end
                endcase
            end

            default: begin
            end
        endcase
    end

endmodule
