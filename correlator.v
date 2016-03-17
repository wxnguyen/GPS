`timescale 1ns / 1ps

// Correlator to determine if coarse acquisition code is present in GPS signal.
// GPS signal is superposition of two C/A codes, where each code is 1 or -1.
module correlator(RESET, CLK, CODE, PHASE_IN, RX, FOUND, PHASE);
	input RESET;
	input CLK;
	input CODE;                // Gold/coarse acquisition code
	input [9:0] PHASE_IN;
	input [1:0] RX;            // GPS signal
	output FOUND;
	output [9:0] PHASE;

	reg FOUND = 0;             // Indicates matching coarse acquisition code
	reg [9:0] PHASE = 0;
	reg [9:0] chip = 1;        // Counts chip correlations
	reg signed [10:0] sum = 0; // Accumulates correlation results

	always @(posedge CLK or posedge RESET) begin
		if (RESET == 1) begin
			FOUND = 0;
			PHASE = 0;
			chip = 1;
			sum = 0;
		end else begin
			if (CODE == 0) begin // CODE == -1, correlating with RX == -2
				case (RX)
					2'b01: sum = sum - 1; // RX == 2
					2'b11: sum = sum + 1; // RX == -2
				endcase
			end else begin // CODE == 1, correlating with RX == 2
				case (RX)
					2'b01: sum = sum + 1; // RX == 2
					2'b11: sum = sum - 1; // RX == -2
				endcase
			end
			if (chip < 1023) begin
				chip = chip + 1;
			end else begin // chip == 1023
				if (sum > 300) begin	// Threshold of 300 to determine
					FOUND = 1;			// presence of the satellite for
					PHASE = PHASE_IN;	// which CODE is being generated.
				end
				chip = 1;
				sum = 0;
			end
		end
	end

endmodule