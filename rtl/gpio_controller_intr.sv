module gpio_controller_intr (
	input logic			 clk,
	input logic			 rst_n,
	input logic [255:0]	 gpio_in_data,
	input logic [255:0]	 posedge_intr_enable,
	input logic [255:0]	 negedge_intr_enable,
	output logic [7:0] posedge_intr_status_set,
	output logic [7:0] negedge_intr_status_set
);

	logic [255:0] gpio_in_data_prev;
	logic [255:0] posedge_detected;
	logic [255:0] negedge_detected;

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			gpio_in_data_prev <= 256'h0;
		end else begin
			gpio_in_data_prev <= gpio_in_data;
		end
	end

	always_comb begin
		posedge_detected = (~gpio_in_data_prev) & gpio_in_data & posedge_intr_enable;
		negedge_detected = gpio_in_data_prev & (~gpio_in_data) & negedge_intr_enable;

		for(integer i = 0; i < 8; i++) begin
			posedge_intr_status_set[i] = |posedge_detected[i*32+:32];
			negedge_intr_status_set[i] = |negedge_detected[i*32+:32];
		end
	end

endmodule // gpio_controller_intr
