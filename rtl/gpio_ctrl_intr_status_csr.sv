module gpio_ctrl_intr_status_csr #(
	parameter NUM_BANKS = 4
) (
    // Clock and reset
    input logic					 clk,
    input logic					 rst_n,
    // APB Interface (no PADDR as this is the only register)
    input logic					 pwrite,
    input logic					 psel,
    input logic					 penable,
    input logic [3:0]			 pstrb,
    input logic [31:0]			 pwdata,
    output logic [31:0]			 prdata,
    output logic				 pready,
    output logic				 pslverr,
    // Pulse input from edge detector
	input logic [NUM_BANKS-1:0]	 edge_detected,
    // Per-bank interrupt signal
    output logic [NUM_BANKS-1:0] interrupt
);

	logic [NUM_BANKS-1:0] intr_status;

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			intr_status <= '0;
			pready <= 1'b0;
		end else begin
			pready <= 1'b0;

			if(psel) begin
				if(pwrite) begin // Write 1 to clear
					intr_status <= intr_status & ~pwdata[NUM_BANKS-1:0];
				end
				pready <= 1'b1;
			end

			intr_status <= intr_status | edge_detected;
		end
	end

	assign prdata = {{(32-NUM_BANKS){1'b0}}, intr_status};
	assign pslverr = 1'b0;
	assign interrupt = intr_status;

endmodule // gpio_ctrl_intr_status_csr
