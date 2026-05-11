`ifndef CFG_NUM_BANKS
	`define CFG_NUM_BANKS 8
`endif

module gpio_controller_verif_tb;

	localparam integer CFG_NUM_BANKS = `CFG_NUM_BANKS;
	localparam integer WIDTH = CFG_NUM_BANKS * 32;

	logic clk;

	rst_if i_rst_if();
	apb_if i_apb_if(.clk(clk));

	wire [WIDTH-1:0]   bus;

	tamarack_gpio_if#(.WIDTH(WIDTH)) gpio_if_dut();
	tamarack_gpio_if#(.WIDTH(WIDTH)) gpio_if_tb();

	generate
		for(genvar i = 0; i < WIDTH; i++) begin : tri_state_buf_gen
			assign bus[i] = gpio_if_dut.gpio_out_enable[i] ? gpio_if_dut.gpio_out_data[i] : 1'bz;
			assign gpio_if_dut.gpio_in_data[i] = bus[i];
			assign bus[i] = gpio_if_tb.gpio_out_enable[i] ? gpio_if_tb.gpio_out_data[i] : 1'bz;
			assign gpio_if_tb.gpio_in_data[i] = bus[i];
		end
	endgenerate


	gpio_ctrl_top #(
		.NUM_BANKS(`CFG_NUM_BANKS)
	) u_dut (
		.clk(clk),
		.rst_n(i_rst_if.dut.rst_n),
		.paddr(i_apb_if.completer.paddr),
		.pwrite(i_apb_if.completer.pwrite),
		.psel(i_apb_if.completer.psel),
		.penable(i_apb_if.completer.penable),
		.pstrb(i_apb_if.completer.pstrb),
		.pwdata(i_apb_if.completer.pwdata),
		.prdata(i_apb_if.completer.prdata),
		.pready(i_apb_if.completer.pready),
		.pslverr(i_apb_if.completer.pslverr),
		.interrupt(),
		.gpio_in_data(gpio_if_dut.gpio_in_data),
		.gpio_out_data(gpio_if_dut.gpio_out_data),
		.gpio_out_enable(gpio_if_dut.gpio_out_enable)
	);

	initial begin
		uvm_pkg::uvm_config_db#(virtual rst_if)::set(null, "uvm_test_top", "rst_vif", i_rst_if);
		uvm_pkg::uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top", "apb_vif", i_apb_if);
		uvm_pkg::uvm_config_db#(virtual tamarack_gpio_if#(.WIDTH(WIDTH)))::set(null, "uvm_test_top.m_env.m_gpio_agent", "gpio_vif", gpio_if_tb);
		uvm_pkg::run_test();
	end

    initial begin
        clk = 1'b0;
        forever begin
            #1;
            clk = ~clk;
        end
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars;
    end

endmodule // gpio_controller_verif_tb
