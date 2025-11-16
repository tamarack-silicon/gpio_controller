module gpio_ctrl_apb_bridge #(
	parameter NUM_BANKS = 4
) (
    // Clock and reset
    input logic							clk,
    input logic							rst_n,
    // Upstream APB Interface
	input logic [9:0]					upstream_paddr,
    input logic							upstream_pwrite,
    input logic							upstream_psel,
    input logic							upstream_penable,
    input logic [3:0]					upstream_pstrb,
    input logic [31:0]					upstream_pwdata,
    output logic [31:0]					upstream_prdata,
    output logic						upstream_pready,
	output logic						upstream_pslverr,
    // Downstream Bank CSR APB Interface
   	output logic [NUM_BANKS-1:0] [3:0]	downstream_bank_paddr,
    output logic [NUM_BANKS-1:0]		downstream_bank_pwrite,
    output logic [NUM_BANKS-1:0]		downstream_bank_psel,
    output logic [NUM_BANKS-1:0]		downstream_bank_penable,
    output logic [NUM_BANKS-1:0] [3:0]	downstream_bank_pstrb,
    output logic [NUM_BANKS-1:0] [31:0]	downstream_bank_pwdata,
    input logic [NUM_BANKS-1:0] [31:0]	downstream_bank_prdata,
    input logic [NUM_BANKS-1:0]			downstream_bank_pready,
	input logic [NUM_BANKS-1:0]			downstream_bank_pslverr,
    // Downstream Interrupt Status CSR APB Interface
    output logic						downstream_intr_status_pwrite,
    output logic						downstream_intr_status_psel,
    output logic						downstream_intr_status_penable,
    output logic [3:0]					downstream_intr_status_pstrb,
    output logic [31:0]					downstream_intr_status_pwdata,
    input logic [31:0]					downstream_intr_status_prdata,
    input logic							downstream_intr_status_pready,
	input logic							downstream_intr_status_pslverr
);

	assign downstream_intr_status_pwrite = upstream_pwrite;
	assign downstream_intr_status_psel = upstream_psel & (upstream_paddr == 'h200);
	assign downstream_intr_status_penable = upstream_penable;
	assign downstream_intr_status_pstrb = upstream_pstrb;
	assign downstream_intr_status_pwdata = upstream_pwdata;
	assign upstream_prdata = downstream_intr_status_prdata;
	assign upstream_pready = downstream_intr_status_pready;
	assign upstream_pslverr = downstream_intr_status_pslverr;

endmodule // gpio_ctrl_apb_bridge
