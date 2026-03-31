package gpio_controller_reg_test_pkg;

	`include "uvm_macros.svh"

	import uvm_pkg::*;
	import gpio_controller_env_pkg::*;

	class gpio_controller_reg_test extends uvm_test;

		`uvm_component_utils(gpio_controller_reg_test)

		gpio_controller_env m_env;

		virtual rst_if rst_vif;

		uvm_reg_hw_reset_seq m_reg_hw_reset_seq;

		function new(string name = "gpio_controller_reg_test", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			m_env = gpio_controller_env::type_id::create("m_env", this);

			m_reg_hw_reset_seq = uvm_reg_hw_reset_seq::type_id::create("m_reg_hw_reset_seq", this);

			if(!uvm_config_db#(virtual rst_if)::get(null, "uvm_test_top", "rst_vif", rst_vif)) begin
				`uvm_fatal("TEST", "Can not get rst_vif virtual interface")
			end
		endfunction // build_phase

		virtual task run_phase(uvm_phase phase);
			phase.raise_objection(phase);

			`uvm_info("TEST", $sformatf("begin reset"), UVM_HIGH)
			rst_vif.rst_n = 1'b0; // FIXME modport
			#20;
			`uvm_info("TEST", $sformatf("release from reset"), UVM_HIGH)
			rst_vif.rst_n = 1'b1; // FIXME modport
			#20;

			m_env.m_reg_env.m_ral_model.print();

			m_reg_hw_reset_seq = uvm_reg_hw_reset_seq::type_id::create("m_reg_hw_reset_seq");
			m_reg_hw_reset_seq.model = m_env.m_reg_env.m_ral_model;
			m_reg_hw_reset_seq.start(m_env.m_apb_agent.m_sequencer);

			phase.drop_objection(phase);
		endtask // run_phase

	endclass

endpackage // gpio_controller_reg_test_pkg
