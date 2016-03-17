`timescale 1ns / 1ps

// Shift register to store and rotate coarse acquisition code.
module rotating_shift_register(RESET, CLK, CODE_IN, CODE_OUT, PHASE);
	input RESET;
	input CLK;
	input CODE_IN;          // Gold/coarse acquisition code
	output CODE_OUT;
	output [9:0] PHASE;

	reg [9:0] PHASE = 0;
	reg [9:0] index = 1;    // "index" selects a single chip
	reg [1:1023] chips = 0; // "chips" stores CODE input

	assign CODE_OUT = (PHASE == 0) ? CODE_IN : chips[index];

	always @(posedge CLK or posedge RESET) begin
		if (RESET == 1) begin
			PHASE <= 0;
			index <= 1;
			chips <= 0;
		end else begin
			if (PHASE == 0) begin
				chips[index] <= CODE_IN;
			end
			if (index < 1023) begin
				index <= index + 1;
			end else begin // index == 1023
				chips[1:1022] <= chips[2:1023]; // Shift all chips left,
				chips[1023] <= chips[1]; // moving the first chip to the end.
				index <= 1;
				if (PHASE < 1022) begin
					PHASE <= PHASE + 1;
				end else begin // PHASE == 1022
					PHASE <= 0;
				end
			end
		end
	end

endmodule