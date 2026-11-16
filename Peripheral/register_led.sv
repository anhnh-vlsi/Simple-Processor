module register_led (
    input  logic       	Clk,
    input  logic      	Load,
    input  logic [8:0] 	Data,
    output logic [8:0] 	LED 
);

	always_ff @(posedge Clk) begin
		if (Load)
			LED <= Data;
	end

endmodule
