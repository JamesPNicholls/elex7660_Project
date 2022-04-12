module lfsr (output logic [3:0]out, 
				input logic clk, reset_n);

	wire feedback;

	assign feedback = ~(out[3] ^ out[2]);

	always_ff@(posedge clk) begin
	if (~reset_n)
		out <= 4'b0;
	else
		out <= {out[2:0],feedback};
	end
endmodule