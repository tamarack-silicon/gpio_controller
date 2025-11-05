interface gpio_if (
	input logic clk
);

	logic [255:0] gpio_in_data;
	logic [255:0] gpio_out_data;
	logic [255:0] gpio_out_enable;

	clocking dut_cb @(posedge clk);
		input gpio_in_data;
		output gpio_out_data, gpio_out_enable;
	endclocking

	clocking tb_cb @(posedge clk);
		input gpio_out_data, gpio_out_enable;
		output gpio_in_data;
	endclocking

	modport dut (
		input gpio_in_data,
		output gpio_out_data, gpio_out_enable
	);

	modport tb (
		input gpio_out_data, gpio_out_enable,
		output gpio_in_data
	);

endinterface // gpio_if
