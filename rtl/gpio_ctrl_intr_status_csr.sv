module gpio_ctrl_intr_status_csr #(
	parameter NUM_BANKS = 8
) (
    // Clock and reset
    input logic					clk,
    input logic					rst_n,
    // APB Interface (no PADDR as this is the only register)
    input logic					pwrite,
    input logic					psel,
    input logic					penable,
    input logic [3:0]			pstrb,
    input logic [31:0]			pwdata,
    output logic [31:0]			prdata,
    output logic				pready,
    output logic				pslverr,
    // Pulse input from edge detector
	input logic [NUM_BANKS-1:0]	edge_detected,
    // Interrupt signal
	output logic				interrupt
);

	logic [31:0] intr_status;
	logic [31:0] edge_detected_expanded;

	logic		 first_cycle;

	always_comb edge_detected_expanded = {{(32-NUM_BANKS){1'b0}}, edge_detected};

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			intr_status <= '0;
			pready <= 1'b0;
		end else begin
			pready <= 1'b0;

			if(psel && first_cycle) begin
				for(integer i = 0; i < 4; i++) begin
					if(pwrite && pstrb[i]) begin
						intr_status[i*8 +: 8] <= (intr_status[i*8 +: 8] & ~pwdata[i*8 +: 8]) | edge_detected_expanded[i*8 +: 8];
					end
				end
				first_cycle <= 1'b0;
				pready <= 1'b1;
			end else if(~psel) begin
				first_cycle <= 1'b1;
				intr_status <= intr_status | edge_detected_expanded;
			end else begin
				intr_status <= intr_status | edge_detected_expanded;
			end
		end
	end

	assign prdata = intr_status;
	assign pslverr = 1'b0;
	assign interrupt = |intr_status;

endmodule // gpio_ctrl_intr_status_csr
