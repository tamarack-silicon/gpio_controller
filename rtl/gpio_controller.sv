module gpio_controller (
    // Clock and resets
    input logic         sys_clk,
    input logic         rst_n,
    // APB Interface
    input logic [15:0]  paddr,
    input logic         pwrite,
    input logic         psel,
    input logic         penable,
    input logic [3:0]   pstrb,
    input logic [31:0]  pwdata,
    output logic [31:0] prdata,
    output logic        pready,
    output logic        pslverr,
    // GPIO interface
    input logic [31:0]  gpio_in_data,
    output logic [31:0] gpio_out_data,
	output logic [31:0] gpio_out_enable
);

    gpio_ctrl_csr_pkg::gpio_ctrl_csr__in_t csr_in;
    gpio_ctrl_csr_pkg::gpio_ctrl_csr__out_t csr_out;

    gpio_ctrl_csr u_gpio_ctrl_csr (
        .clk(sys_clk),
        .arst_n(rst_n),
        .s_apb_psel(psel),
        .s_apb_penable(penable),
        .s_apb_pwrite(pwrite),
        .s_apb_pprot('0),
        .s_apb_paddr(paddr[3:0]),
        .s_apb_pwdata(pwdata),
        .s_apb_pstrb(pstrb),
        .s_apb_pready(pready),
        .s_apb_prdata(prdata),
        .s_apb_pslverr(pslverr),
        .hwif_in(csr_in),
        .hwif_out(csr_out)
    );

    logic [1:0] [31:0] sync_flops;

    always_ff @(posedge sys_clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            sync_flops <= 'h0;
        end else begin
            sync_flops[0] <= gpio_in_data;
            sync_flops[1] <= sync_flops[0];
        end
    end

    assign gpio_out_data = csr_out.output_data[0].odata.value;
	assign gpio_out_enable = csr_out.output_enable[0].oenable.value;
    assign csr_in.input_data[0].idata.next = sync_flops[1];

endmodule // gpio_controller
