package gpio_controller_base_test_pkg;

	`include "uvm_macros.svh"

	import uvm_pkg::*;
	import gpio_controller_env_pkg::*;

	class gpio_controller_base_test extends uvm_test;

		`uvm_component_utils(gpio_controller_base_test)

		gpio_controller_env m_env;

		virtual rst_if rst_vif;

		function new(string name = "gpio_controller_base_test", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			m_env = gpio_controller_env::type_id::create("m_env", this);

			if(!uvm_config_db#(virtual rst_if)::get(null, "uvm_test_top", "rst_vif", rst_vif)) begin
				`uvm_fatal("TEST", "Can not get rst_vif virtual interface")
			end
		endfunction // build_phase

		task apply_reset();
			`uvm_info("TEST", $sformatf("begin reset"), UVM_HIGH)
			rst_vif.rst_n = 1'b0; // FIXME modport
			#20;
			`uvm_info("TEST", $sformatf("release from reset"), UVM_HIGH)
			rst_vif.rst_n = 1'b1; // FIXME modport
			#20;
		endtask // apply_reset

		virtual task run_phase(uvm_phase phase);
			phase.raise_objection(phase);

			apply_reset();

			phase.drop_objection(phase);
		endtask // run_phase

	endclass

endpackage // gpio_controller_base_test_pkg
