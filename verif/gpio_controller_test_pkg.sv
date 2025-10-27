package gpio_controller_test_pkg;

	import uvm_pkg::*;
	import apb_agent_pkg::*;

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

		function new(string name = "gpio_controller_test", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			env = gpio_controller_env::type_id::create("env", this);

			if(!uvm_config_db#(virtual rst_if)::get(this, "", "rst_vif", rst_vif)) begin
				`uvm_fatal("TEST", "Can not get virtual interface")
			end
		endfunction // build_phase

		virtual task run_phase(uvm_phase phase);
			phase.raise_objection(phase);

			rst_vif.rst_n = 1'b0; // FIXME modport
			#100;
			rst_vif.rst_n = 1'b1; // FIXME modport
			#100;

			phase.drop_objection(phase);

			$finish;
		endtask // run_phase

	endclass

endpackage // gpio_controller_test_pkg
