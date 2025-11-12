module gpio_ctrl_top (
    // Clock and resets
    input logic			 clk,
    input logic			 rst_n,
    // APB Interface
	input logic [10:0]	 paddr,
    input logic			 pwrite,
    input logic			 psel,
    input logic			 penable,
    input logic [3:0]	 pstrb,
    input logic [31:0]	 pwdata,
    output logic [31:0]	 prdata,
    output logic		 pready,
    output logic		 pslverr,
	// Interrupt signal
	output logic		 interrupt,
    // GPIO interface
    input logic [255:0]	 gpio_in_data,
    output logic [255:0] gpio_out_data,
	output logic [255:0] gpio_out_enable
);

    gpio_ctrl_csr_pkg::gpio_ctrl_csr__in_t csr_in;
    gpio_ctrl_csr_pkg::gpio_ctrl_csr__out_t csr_out;

    gpio_ctrl_csr u_gpio_ctrl_csr (
        .clk(clk),
        .arst_n(rst_n),
        .s_apb_psel(psel),
        .s_apb_penable(penable),
        .s_apb_pwrite(pwrite),
        .s_apb_pprot('0),
        .s_apb_paddr(paddr[10:0]),
        .s_apb_pwdata(pwdata),
        .s_apb_pstrb(pstrb),
        .s_apb_pready(pready),
        .s_apb_prdata(prdata),
        .s_apb_pslverr(pslverr),
        .hwif_in(csr_in),
        .hwif_out(csr_out)
    );

    logic [255:0] gpio_in_data_synced;

	gpio_ctrl_cdc_sync #(
		.WIDTH(256)
	) u_sync (
		.clk(clk),
		.rst_n(rst_n),
		.in(gpio_in_data),
		.out(gpio_in_data_synced)
	);

	logic [255:0] posedge_intr_enable;
	logic [255:0] negedge_intr_enable;
	logic [7:0] posedge_intr_status_set;
	logic [7:0] negedge_intr_status_set;

	gpio_ctrl_intr u_intr (
		.clk(clk),
		.rst_n(rst_n),
		.gpio_in_data(gpio_in_data_synced),
		.posedge_intr_enable(posedge_intr_enable),
		.negedge_intr_enable(negedge_intr_enable),
		.posedge_intr_status_set(posedge_intr_status_set),
		.negedge_intr_status_set(negedge_intr_status_set)
	);

    assign gpio_out_data = {csr_out.output_data[7].odata.value,
							csr_out.output_data[6].odata.value,
							csr_out.output_data[5].odata.value,
							csr_out.output_data[4].odata.value,
							csr_out.output_data[3].odata.value,
							csr_out.output_data[2].odata.value,
							csr_out.output_data[1].odata.value,
							csr_out.output_data[0].odata.value};

	assign gpio_out_enable = {csr_out.output_enable[7].oenable.value,
							  csr_out.output_enable[6].oenable.value,
							  csr_out.output_enable[5].oenable.value,
							  csr_out.output_enable[4].oenable.value,
							  csr_out.output_enable[3].oenable.value,
							  csr_out.output_enable[2].oenable.value,
							  csr_out.output_enable[1].oenable.value,
							  csr_out.output_enable[0].oenable.value};

    assign csr_in.input_data[0].idata.next = gpio_in_data_synced[32*0+:32];
	assign csr_in.input_data[1].idata.next = gpio_in_data_synced[32*1+:32];
    assign csr_in.input_data[2].idata.next = gpio_in_data_synced[32*2+:32];
	assign csr_in.input_data[3].idata.next = gpio_in_data_synced[32*3+:32];
    assign csr_in.input_data[4].idata.next = gpio_in_data_synced[32*4+:32];
	assign csr_in.input_data[5].idata.next = gpio_in_data_synced[32*5+:32];
    assign csr_in.input_data[6].idata.next = gpio_in_data_synced[32*6+:32];
	assign csr_in.input_data[7].idata.next = gpio_in_data_synced[32*7+:32];

	assign posedge_intr_enable = {csr_out.posedge_intr_enable[7].intr_enable.value,
								  csr_out.posedge_intr_enable[6].intr_enable.value,
								  csr_out.posedge_intr_enable[5].intr_enable.value,
								  csr_out.posedge_intr_enable[4].intr_enable.value,
								  csr_out.posedge_intr_enable[3].intr_enable.value,
								  csr_out.posedge_intr_enable[2].intr_enable.value,
								  csr_out.posedge_intr_enable[1].intr_enable.value,
								  csr_out.posedge_intr_enable[0].intr_enable.value};

	assign negedge_intr_enable = {csr_out.negedge_intr_enable[7].intr_enable.value,
								  csr_out.negedge_intr_enable[6].intr_enable.value,
								  csr_out.negedge_intr_enable[5].intr_enable.value,
								  csr_out.negedge_intr_enable[4].intr_enable.value,
								  csr_out.negedge_intr_enable[3].intr_enable.value,
								  csr_out.negedge_intr_enable[2].intr_enable.value,
								  csr_out.negedge_intr_enable[1].intr_enable.value,
								  csr_out.negedge_intr_enable[0].intr_enable.value};

	assign csr_in.intr_status.posedge_0.hwset = posedge_intr_status_set[0];
	assign csr_in.intr_status.posedge_1.hwset = posedge_intr_status_set[1];
	assign csr_in.intr_status.posedge_2.hwset = posedge_intr_status_set[2];
	assign csr_in.intr_status.posedge_3.hwset = posedge_intr_status_set[3];
	assign csr_in.intr_status.posedge_4.hwset = posedge_intr_status_set[4];
	assign csr_in.intr_status.posedge_5.hwset = posedge_intr_status_set[5];
	assign csr_in.intr_status.posedge_6.hwset = posedge_intr_status_set[6];
	assign csr_in.intr_status.posedge_7.hwset = posedge_intr_status_set[7];

	assign csr_in.intr_status.negedge_0.hwset = negedge_intr_status_set[0];
	assign csr_in.intr_status.negedge_1.hwset = negedge_intr_status_set[1];
	assign csr_in.intr_status.negedge_2.hwset = negedge_intr_status_set[2];
	assign csr_in.intr_status.negedge_3.hwset = negedge_intr_status_set[3];
	assign csr_in.intr_status.negedge_4.hwset = negedge_intr_status_set[4];
	assign csr_in.intr_status.negedge_5.hwset = negedge_intr_status_set[5];
	assign csr_in.intr_status.negedge_6.hwset = negedge_intr_status_set[6];
	assign csr_in.intr_status.negedge_7.hwset = negedge_intr_status_set[7];

	assign interrupt = |{csr_out.intr_status.posedge_0.value,
						 csr_out.intr_status.posedge_1.value,
						 csr_out.intr_status.posedge_2.value,
						 csr_out.intr_status.posedge_3.value,
						 csr_out.intr_status.posedge_4.value,
						 csr_out.intr_status.posedge_5.value,
						 csr_out.intr_status.posedge_6.value,
						 csr_out.intr_status.posedge_7.value,
						 csr_out.intr_status.negedge_0.value,
						 csr_out.intr_status.negedge_1.value,
						 csr_out.intr_status.negedge_2.value,
						 csr_out.intr_status.negedge_3.value,
						 csr_out.intr_status.negedge_4.value,
						 csr_out.intr_status.negedge_5.value,
						 csr_out.intr_status.negedge_6.value,
						 csr_out.intr_status.negedge_7.value};

endmodule // gpio_ctrl_top
