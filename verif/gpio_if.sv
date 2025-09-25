interface gpio_if;

	logic [255:0] gpio_in_data;
	logic [255:0] gpio_out_data;
	logic [255:0] gpio_out_enable;

	modport dut (
		input gpio_in_data,
		output gpio_out_data, gpio_out_enable
	);

	modport tb (
		input gpio_out_data, gpio_out_enable,
		output gpio_in_data
	);

endinterface // gpio_if
