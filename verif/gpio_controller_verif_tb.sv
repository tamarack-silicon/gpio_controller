module gpio_controller_verif_tb;

	logic clk;

	rst_if i_rst_if();
	apb_if i_apb_if(.clk(clk));
	gpio_if i_gpio_if(.clk(clk));

	gpio_ctrl_top u_dut (
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
		.gpio_in_data(i_gpio_if.dut.gpio_in_data),
		.gpio_out_data(i_gpio_if.dut.gpio_out_data),
		.gpio_out_enable(i_gpio_if.dut.gpio_out_enable)
	);

	initial begin
		uvm_pkg::uvm_config_db#(virtual rst_if)::set(null, "uvm_test_top", "rst_vif", i_rst_if);
		uvm_pkg::uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top", "apb_vif", i_apb_if);
		uvm_pkg::uvm_config_db#(virtual gpio_if)::set(null, "uvm_test_top", "gpio_vif", i_gpio_if);
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
        $dumpfile("gpio_controller_verif_tb.vcd");
        $dumpvars;
    end

endmodule // gpio_controller_verif_tb
