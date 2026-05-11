interface rst_if;

	logic rst_n;

	modport dut (
		input rst_n
	);

	modport tb (
		output rst_n
	);

endinterface
