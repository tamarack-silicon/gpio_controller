module gpio_controller_verif_tb;

	initial begin
		uvm_pkg::run_test();
	end

    initial begin
        $dumpfile("gpio_controller_verif_tb.vcd");
        $dumpvars;
    end

endmodule // gpio_controller_verif_tb
