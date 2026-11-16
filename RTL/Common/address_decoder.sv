module address_decoder (
	input logic [8:0] 	ADDR,
	input logic			W,
	output logic 		LED_en,
	output logic		Mem_en
);

	always_comb begin
		Mem_en = 1'b0;
		LED_en = 1'b0;

		case(ADDR[8:7])
			2'b00: Mem_en = W;
			2'b01: LED_en = W;
			default: begin
				Mem_en = 1'b0;
				LED_en = 1'b0;
			end
		endcase
	end

endmodule
