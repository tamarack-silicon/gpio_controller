package gpio_controller_output_test_pkg;

	`include "uvm_macros.svh"

	import uvm_pkg::*;
	import gpio_controller_env_pkg::*;
	import gpio_controller_base_test_pkg::*;

	class gpio_controller_output_test extends gpio_controller_base_test;

		`uvm_component_utils(gpio_controller_output_test)

		function new(string name = "gpio_controller_output_test", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);
		endfunction // build_phase

		virtual task run_phase(uvm_phase phase);
			automatic uvm_status_e status;
			automatic logic [31:0] output_data;

			phase.raise_objection(phase);

			apply_reset();

			m_env.m_reg_env.m_ral_model.bank_csr[0].output_enable.write(status, 32'hffffffff, UVM_FRONTDOOR);

			repeat(10000) begin
				std::randomize(output_data);
				m_env.m_reg_env.m_ral_model.bank_csr[0].output_data.write(status, output_data, UVM_FRONTDOOR);
			end

			phase.drop_objection(phase);
		endtask // run_phase

	endclass

endpackage // gpio_controller_output_test_pkg
