module multiplexer (
    input logic         DINout,
    input logic         Gout,
    input logic [7:0]   Rout,
    input logic [8:0]   DIN,
    input logic [8:0]   G_data,
    input logic [8:0]   R0,
    input logic [8:0]   R1,
    input logic [8:0]   R2,
    input logic [8:0]   R3,
    input logic [8:0]   R4,
    input logic [8:0]   R5,
    input logic [8:0]   R6,
    input logic [8:0]   R7,
    output logic [8:0]  Bus
);

	always_comb begin
		if (Gout) 
			Bus = G_data;
		else if (DINout)
			Bus = DIN;
		else begin
			case (Rout)
                8'b0000_0001: Bus = R0;
                8'b0000_0010: Bus = R1;
                8'b0000_0100: Bus = R2;
                8'b0000_1000: Bus = R3;
                8'b0001_0000: Bus = R4;
                8'b0010_0000: Bus = R5;
                8'b0100_0000: Bus = R6;
                8'b1000_0000: Bus = R7;
                default:      Bus = 9'b0;
            endcase
		end 
	end

endmodule

