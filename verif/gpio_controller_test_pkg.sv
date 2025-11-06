package gpio_controller_test_pkg;

	`include "uvm_macros.svh"

	import uvm_pkg::*;
	import apb_agent_pkg::*;
	import gpio_agent_pkg::*;

	class gpio_controller_env extends uvm_env;

		`uvm_component_utils(gpio_controller_env)

		function new(string name = "gpio_controller_env", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

	endclass // gpio_controller_env

	class gpio_controller_test extends uvm_test;

		`uvm_component_utils(gpio_controller_test)

		gpio_controller_env env;

		virtual rst_if rst_vif;
		virtual	apb_if apb_vif;

		function new(string name = "gpio_controller_test", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			env = gpio_controller_env::type_id::create("env", this);

			if(!uvm_config_db#(virtual rst_if)::get(this, "", "rst_vif", rst_vif)) begin
				`uvm_fatal("TEST", "Can not get rst_vif virtual interface")
			end

			if(!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif)) begin
				`uvm_fatal("TEST", "Cannot get apb_vif virtual interface")
			end
		endfunction // build_phase

		virtual task run_phase(uvm_phase phase);
			phase.raise_objection(phase);

			`uvm_info("TEST", $sformatf("begin reset"), UVM_HIGH)
			rst_vif.rst_n = 1'b0; // FIXME modport
			#1000;
			`uvm_info("TEST", $sformatf("release from reset"), UVM_HIGH)
			rst_vif.rst_n = 1'b1; // FIXME modport
			#100;

			@(apb_vif.requester_cb);
			apb_vif.requester_cb.paddr <= '0;
			apb_vif.requester_cb.pwrite <= 1'b1;
			apb_vif.requester_cb.psel <= 1'b1;
			apb_vif.requester_cb.penable <= 1'b0;
			apb_vif.requester_cb.pstrb <= 4'b1111;
			apb_vif.requester_cb.pwdata <= 'h12345678;
			@(apb_vif.requester_cb);
			apb_vif.requester_cb.penable <= 1'b1;
			@(apb_vif.requester_cb);
			for(integer i = 0; i < 64; i++) begin // Timeout 64 cycles
				if(apb_vif.requester_cb.pready) begin
					apb_vif.requester_cb.psel <= 1'b0;
					apb_vif.requester_cb.penable <= 1'b0;
					break;
				end else begin
					@(apb_vif.requester_cb);
				end
			end

			#100;

			phase.drop_objection(phase);

			$finish; // FIXME
		endtask // run_phase

	endclass

endpackage // gpio_controller_test_pkg
