module control_unit (
    input logic         Clk,
    input logic         Resetn,
    input logic         Run,
    input logic [8:0]   IR,
    input logic [8:0]	G_data,
    output logic        IRin,
    output logic        Ain,
    output logic        Gin,
    output logic        Addsub,
    output logic        Gout,
    output logic        DINout,
    output logic        Done,
    output logic [6:0]  Rin,
    output logic [6:0]  Rout,
    output logic 		PCout,
    output logic		PCin,
    output logic		Incr_pc,
    output logic 		ADDRin,
    output logic		DOUTin,
    output logic		W_D
);

/*
    Resetn = 0: waiting for instructions
    Run = 1: instructions start to flow to control_unit otherwise waiting
    IRin = 1: allow DIN to flow to IR
    Ain = 1: allow Bus data to flow to register_A
    Gin = 1: allow Alu_result to flow to register_G
    Addsub = 0: + otherwise - of 2 operands
    Gout, DINout, Rout: select data from G, DIN or Register file to Bus
    Done = 1: when complete executing current IR
    Rin: allow which register in register_file to write bus data
*/

	// states: 
	localparam T0 = 3'b000;
	localparam T1 = 3'b001;
	localparam T2 = 3'b010;
	localparam T3 = 3'b011;
	localparam T4 = 3'b100;
	localparam T5 = 3'b101;

	// OPcodes:
	localparam OP_MV = 3'b000;
	localparam OP_MVI = 3'b001;
	localparam OP_ADD = 3'b010;
	localparam OP_SUB = 3'b011;
	localparam OP_LD = 3'b100;
	localparam OP_ST = 3'b101;
	localparam OP_MVNZ = 3'b110;

	logic [2:0] current_state, next_state;
	logic [2:0] opcode, rx_addr, ry_addr;
	logic [7:0] Xreg, Yreg;

	assign opcode = IR[8:6];
	assign rx_addr = IR[5:3];
	assign ry_addr = IR[2:0];

	// decode X and Y reg:
	decoder3to8 X_reg_decode (
		.EN(1'b1),
		.din(rx_addr),
		.dout(Xreg)
	);

	decoder3to8 Y_reg_decode (
		.EN(1'b1),
		.din(ry_addr),
		.dout(Yreg)
	);
	
	always_ff @(posedge Clk or negedge Resetn) begin
		if (!Resetn) current_state <= T0;
		else current_state <= next_state;
	end

	always_comb begin
		case(current_state) 
			T0: begin
				if (Run) next_state = T1;
				else next_state = T0;
			end
			T1: begin
				next_state = T2;
			end
			T2: begin
				next_state = T3;
			end
			T3: begin
    			case(opcode) 
					OP_MV, OP_MVNZ: next_state = T0;
					OP_MVI, OP_ADD, OP_SUB, OP_LD, OP_ST: next_state = T4;
					default: next_state = T0;
    			endcase
			end
			T4: begin
				next_state = T5;
			end
			T5: begin
				next_state = T0;
			end
			default: next_state = T0;
		endcase
	end

	always_comb begin
		IRin = 1'b0;
		Ain = 1'b0;
		Gin = 1'b0;
		Addsub = 1'b0;
		Gout = 1'b0;
		DINout = 1'b0;
		Done = 1'b0;
		Rin = 7'b0000000;
		Rout = 7'b0000000;
		PCin = 1'b0;
		PCout = 1'b0;
		Incr_pc = 1'b0;
		ADDRin = 1'b0;
		DOUTin = 1'b0;
		W_D = 1'b0;
		
		case(current_state) 
			T0: begin
				if (Run) begin
					PCout = 1'b1;
					ADDRin = 1'b1;
					Incr_pc = 1'b1;
				end
			end
			T1: begin
				;
			end
			T2: begin
				IRin = 1'b1;
			end
			T3: begin
				case(opcode) 
					OP_MV: begin
						{PCout, Rout} = Yreg;
						{PCin, Rin} = Xreg;
						Done = 1'b1;
					end
					OP_MVI: begin
						PCout = 1'b1;
						ADDRin = 1'b1; 
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
						if (G_data != 0) begin
							{PCout, Rout} = Yreg;
							{PCin, Rin} = Xreg;
						end
						Done = 1'b1;
					end
					default: ;
				endcase    			
			end
			T4: begin
				case(opcode) 
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
						W_D	= 1'b1;
					end
					default: ;
				endcase
			end
			T5: begin
				case(opcode)
					OP_MVI, OP_LD: begin
						DINout = 1'b1;
						{PCin, Rin} = Xreg;
						Done = 1'b1;
					end
					OP_ADD, OP_SUB: begin
						Gout = 1'b1;
						{PCin, Rin} = Xreg;
						Done = 1'b1;
					end
					OP_ST: Done = 1'b1;
					default: ;
				endcase
			end
		endcase
	end
endmodule
