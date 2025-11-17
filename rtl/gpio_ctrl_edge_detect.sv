module gpio_ctrl_edge_detect (
	input logic		   clk,
	input logic		   rst_n,
	input logic [31:0] gpio_in_data,
	input logic [31:0] intr_enable,
	output logic	   intr_status_set
);

	logic [31:0] gpio_in_data_prev;
	logic [31:0] edge_detected;

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			gpio_in_data_prev <= 32'h0;
		end else begin
			gpio_in_data_prev <= gpio_in_data;
		end
	end

	always_comb begin
		edge_detected = (gpio_in_data_prev ^ gpio_in_data) & intr_enable;
		intr_status_set = |edge_detected;
	end

`ifdef FORMAL

	// If an interrupt is disabled then the edge detected signal shall always be deasserted
	always_comb begin
		for(integer i=0; i<32; i++) begin
			if(intr_enable[i] == 1'b0) assert(edge_detected[i] == 1'b0);
		end
	end

`endif

endmodule // gpio_ctrl_edge_detect
