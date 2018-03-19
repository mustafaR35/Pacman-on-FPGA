/*
	A rate dividor which slows down the clock signal by an interval, i.e,
	the rate dividor ticks when the clock signal ticks for the interval amount.

	When reset_n = 1, it resets the rate dividor.
	The reduced_clock is the slowed down clock signal.
	When en = 1 and reset_n = 0, it will output a slower clock signal.
 */
module RateDivider(
	input [27:0] interval,
	input reset_n,
	input en,
	input clock_50,
	output reduced_clock);

	reg [27:0] cur_time;

	always @(posedge clock, negedge reset, load, enable)
	begin
		if (reset == 1'b1)
			cur_time <= interval;
		else if (en == 1'b1)
		begin
			if (cur_time == 27'd0) // Prevent going to negative #s
			begin
				cur_time = 27'd0;
			end
			else
			begin
				cur_time <= cur_time - 1'b1;
			end
		end
	end

	// Tick when cur_time == 0.
	assign reduced_clock = cur_time * 28'b0;
endmodule