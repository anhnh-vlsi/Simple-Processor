module multiplexer (
    input  logic       DINout,
    input  logic [1:0] Gout,
    input  logic [6:0] Rout,
    input  logic       PCout,

    input  logic [8:0] DIN,
    input  logic [8:0] G_data,
    input  logic [8:0] GF_data,
    input  logic [8:0] R0,
    input  logic [8:0] R1,
    input  logic [8:0] R2,
    input  logic [8:0] R3,
    input  logic [8:0] R4,
    input  logic [8:0] R5,
    input  logic [8:0] R6,
    input  logic [8:0] PC,
    output logic [8:0] Bus
);

    always_comb begin
        case (Gout)
            2'b10: Bus = G_data;
            2'b01: Bus = GF_data;
            default: begin
                if (DINout)
                    Bus = DIN;
                else if (PCout)
                    Bus = PC;
                else begin
                    case (Rout)
                        7'b0000001: Bus = R0;
                        7'b0000010: Bus = R1;
                        7'b0000100: Bus = R2;
                        7'b0001000: Bus = R3;
                        7'b0010000: Bus = R4;
                        7'b0100000: Bus = R5;
                        7'b1000000: Bus = R6;
                        default:    Bus = 9'b0;
                    endcase
                end
            end
        endcase
    end

endmodule
