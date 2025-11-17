module gpio_ctrl_apb_bridge #(
	parameter NUM_BANKS = 8
) (
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

	always_comb begin
		for(integer i = 0; i < NUM_BANKS; i++) begin
			downstream_bank_paddr[i] = upstream_paddr[3:0];
			downstream_bank_pwrite[i] = upstream_pwrite;
			downstream_bank_psel[i] = 1'b0;

			if(upstream_paddr[9] == 1'b0) begin // paddr < 'h200
				downstream_bank_psel[upstream_paddr[$clog2(NUM_BANKS)+3:4]] = upstream_psel;
			end

			downstream_bank_penable[i] = upstream_penable;
			downstream_bank_pstrb[i] = upstream_pstrb;
			downstream_bank_pwdata[i] = upstream_pwdata;
		end

		downstream_intr_status_pwrite = upstream_pwrite;
		downstream_intr_status_psel = upstream_psel & (upstream_paddr == 'h200);
		downstream_intr_status_penable = upstream_penable;
		downstream_intr_status_pstrb = upstream_pstrb;
		downstream_intr_status_pwdata = upstream_pwdata;
	end

	always_comb begin
		upstream_prdata = 32'h0;
		upstream_pready = 1'b0;
		upstream_pslverr = 1'b0;

		if(upstream_paddr == 10'h200) begin
			upstream_prdata = downstream_intr_status_prdata;
			upstream_pready = downstream_intr_status_pready;
			upstream_pslverr = downstream_intr_status_pslverr;
		end else if(upstream_paddr[9] == 1'b0) begin
			upstream_prdata = downstream_bank_prdata[upstream_paddr[$clog2(NUM_BANKS)+3:4]];
			upstream_pready = downstream_bank_pready[upstream_paddr[$clog2(NUM_BANKS)+3:4]];
			upstream_pslverr = downstream_bank_pslverr[upstream_paddr[$clog2(NUM_BANKS)+3:4]];
		end
	end

endmodule // gpio_ctrl_apb_bridge
