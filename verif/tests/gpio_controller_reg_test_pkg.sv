package gpio_controller_reg_test_pkg;

	`include "uvm_macros.svh"

	import uvm_pkg::*;
	import gpio_controller_env_pkg::*;
	import gpio_controller_base_test_pkg::*;

	class gpio_controller_reg_test extends gpio_controller_base_test;

		`uvm_component_utils(gpio_controller_reg_test)

		uvm_reg_hw_reset_seq m_reg_hw_reset_seq;
		uvm_reg_bit_bash_seq m_reg_bit_bash_seq;

		function new(string name = "gpio_controller_reg_test", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			m_reg_hw_reset_seq = uvm_reg_hw_reset_seq::type_id::create("m_reg_hw_reset_seq", this);
			m_reg_bit_bash_seq = uvm_reg_bit_bash_seq::type_id::create("m_reg_bit_bash_seq", this);
		endfunction // build_phase

		virtual task run_phase(uvm_phase phase);
			phase.raise_objection(phase);

			apply_reset();

			m_env.m_reg_env.m_ral_model.print();

			m_reg_hw_reset_seq.model = m_env.m_reg_env.m_ral_model;
			m_reg_hw_reset_seq.start(m_env.m_apb_agent.sequencer);

			m_reg_bit_bash_seq.model = m_env.m_reg_env.m_ral_model;
			m_reg_bit_bash_seq.start(m_env.m_apb_agent.sequencer);

			phase.drop_objection(phase);
		endtask // run_phase

	endclass

endpackage // gpio_controller_reg_test_pkg
