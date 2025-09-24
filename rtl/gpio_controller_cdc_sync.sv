module gpio_controller_cdc_sync #(
	parameter WIDTH = 1
) (
	input logic				 clk,
	input logic				 rst_n,
	input logic [WIDTH-1:0]	 in,
	output logic [WIDTH-1:0] out);

	logic [WIDTH-1:0] stage;

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			stage <= '0;
			out <= '0;
		end else begin
			stage <= in;
			out <= stage;
		end
	end

endmodule // gpio_controller_cdc_sync
