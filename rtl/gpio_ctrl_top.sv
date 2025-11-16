module gpio_ctrl_top #(
	parameter NUM_BANKS = 8
) (
    // Clock and resets
    input logic						clk,
    input logic						rst_n,
    // APB Interface
	input logic [9:0]				paddr,
    input logic						pwrite,
    input logic						psel,
    input logic						penable,
    input logic [3:0]				pstrb,
    input logic [31:0]				pwdata,
    output logic [31:0]				prdata,
    output logic					pready,
    output logic					pslverr,
	// Interrupt signal
	output logic					interrupt,
    // GPIO interface
	input logic [NUM_BANKS*32-1:0]	gpio_in_data,
    output logic [NUM_BANKS*32-1:0]	gpio_out_data,
	output logic [NUM_BANKS*32-1:0]	gpio_out_enable
);

    logic [NUM_BANKS-1:0] [3:0]	 bank_paddr;
    logic [NUM_BANKS-1:0]		 bank_pwrite;
    logic [NUM_BANKS-1:0]		 bank_psel;
    logic [NUM_BANKS-1:0]		 bank_penable;
    logic [NUM_BANKS-1:0] [3:0]	 bank_pstrb;
    logic [NUM_BANKS-1:0] [31:0] bank_pwdata;
    logic [NUM_BANKS-1:0] [31:0] bank_prdata;
    logic [NUM_BANKS-1:0]		 bank_pready;
	logic [NUM_BANKS-1:0]		 bank_pslverr;

    logic		 intr_status_pwrite;
    logic		 intr_status_psel;
    logic		 intr_status_penable;
    logic [3:0]	 intr_status_pstrb;
    logic [31:0] intr_status_pwdata;
    logic [31:0] intr_status_prdata;
    logic		 intr_status_pready;
	logic		 intr_status_pslverr;

	logic [NUM_BANKS-1:0] edge_detected;
	logic [NUM_BANKS-1:0] per_bank_interrupt;

	// APB bridge
	gpio_ctrl_apb_bridge #(
		.NUM_BANKS(NUM_BANKS)
	) u_apb_bridge (
		// Clock and reset
		.clk(clk),
		.rst_n(rst_n),
		// Upstream APB Interface
		.upstream_paddr(paddr),
		.upstream_pwrite(pwrite),
		.upstream_psel(psel),
		.upstream_penable(penable),
		.upstream_pstrb(pstrb),
		.upstream_pwdata(pwdata),
		.upstream_prdata(prdata),
		.upstream_pready(pready),
		.upstream_pslverr(pslverr),
		// Downstream Bank CSR APB Interface
		.downstream_bank_paddr(bank_paddr),
		.downstream_bank_pwrite(bank_pwrite),
		.downstream_bank_psel(bank_psel),
		.downstream_bank_penable(bank_penable),
		.downstream_bank_pstrb(bank_pstrb),
		.downstream_bank_pwdata(bank_pwdata),
		.downstream_bank_prdata(bank_prdata),
		.downstream_bank_pready(bank_pready),
		.downstream_bank_pslverr(bank_pslverr),
		// Downstream Interrupt Status CSR APB Interface
		.downstream_intr_status_pwrite(intr_status_pwrite),
		.downstream_intr_status_psel(intr_status_psel),
		.downstream_intr_status_penable(intr_status_penable),
		.downstream_intr_status_pstrb(intr_status_pstrb),
		.downstream_intr_status_pwdata(intr_status_pwdata),
		.downstream_intr_status_prdata(intr_status_prdata),
		.downstream_intr_status_pready(intr_status_pready),
		.downstream_intr_status_pslverr(intr_status_pslverr)
	);

	// Interrupt status CSR
	gpio_ctrl_intr_status_csr #(
		.NUM_BANKS(NUM_BANKS)
	) u_intr_status_csr (
		// Clock and reset
		.clk(clk),
		.rst_n(rst_n),
		// APB interface
		.pwrite(intr_status_pwrite),
		.psel(intr_status_psel),
		.penable(intr_status_penable),
		.pstrb(intr_status_pstrb),
		.pwdata(intr_status_pwdata),
		.prdata(intr_status_prdata),
		.pready(intr_status_pready),
		.pslverr(intr_status_pslverr),
		// Pulse input from edge detector
		.edge_detected(edge_detected),
		// Per-bank interrupt signal
		.interrupt(per_bank_interrupt)
	);

	assign interrupt = |per_bank_interrupt;

	for(genvar i = 0; i < NUM_BANKS; i++) begin : per_bank_gen

		logic [31:0] gpio_in_data_synced;

		gpio_ctrl_cdc_sync #(
			.WIDTH(32)
		) u_sync (
			.clk(clk),
			.rst_n(rst_n),
			.in(gpio_in_data[i*32 +: 32]),
			.out(gpio_in_data_synced)
		);

		gpio_ctrl_edge_detect u_edge_detect (
			.clk(clk),
			.rst_n(rst_n),
			.gpio_in_data(gpio_in_data_synced),
			.intr_enable(32'hffffffff),
			.intr_status_set(edge_detected[i])
		);

	end

endmodule // gpio_ctrl_top
