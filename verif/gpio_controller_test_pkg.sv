package gpio_controller_test_pkg;

	`include "uvm_macros.svh"

	import uvm_pkg::*;
	import apb_agent_pkg::*;
	import gpio_ctrl_csr_ral_pkg::*;
	import gpio_controller_reg_env_pkg::*;

	class gpio_controller_env extends uvm_env;

		`uvm_component_utils(gpio_controller_env)

		apb_agent m_agent;
		gpio_controller_reg_env m_reg_env;

		function new(string name = "gpio_controller_env", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			m_agent = apb_agent::type_id::create("m_agent", this);
			m_reg_env = gpio_controller_reg_env::type_id::create("m_reg_env", this);
		endfunction // build_phase

		virtual function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			m_reg_env.m_agent = m_agent;
			m_agent.m_monitor.mon_analysis_port.connect(m_reg_env.m_apb2reg_predictor.bus_in);
			m_reg_env.m_ral_model.default_map.set_sequencer(m_agent.m_sequencer, m_reg_env.m_reg2apb);
		endfunction // connect_phase

	endclass // gpio_controller_env

	class gpio_controller_test extends uvm_test;

		`uvm_component_utils(gpio_controller_test)

		gpio_controller_env m_env;

		virtual rst_if rst_vif;

		function new(string name = "gpio_controller_test", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			m_env = gpio_controller_env::type_id::create("m_env", this);

			if(!uvm_config_db#(virtual rst_if)::get(this, "uvm_test_top", "rst_vif", rst_vif)) begin
				`uvm_fatal("TEST", "Can not get rst_vif virtual interface")
			end
		endfunction // build_phase

		virtual task reset_phase(uvm_phase phase);
			phase.raise_objection(phase);

			`uvm_info("TEST", $sformatf("begin reset"), UVM_HIGH)
			rst_vif.rst_n = 1'b0; // FIXME modport
			#100;
			`uvm_info("TEST", $sformatf("release from reset"), UVM_HIGH)
			rst_vif.rst_n = 1'b1; // FIXME modport
			#100;

			phase.drop_objection(phase);
		endtask // reset_phase

		virtual task main_phase(uvm_phase phase);
			gpio_ctrl_csr m_ral_model;
			uvm_status_e status;

			phase.raise_objection(phase);

			m_env.m_reg_env.set_report_verbosity_level(UVM_HIGH);

			uvm_config_db#(gpio_ctrl_csr)::get(null, "uvm_test_top", "m_ral_model", m_ral_model);

			m_ral_model.output_data[1].odata.write(status, 32'h12345678);

			#100;
			phase.drop_objection(phase);
		endtask // main_phase

	endclass

endpackage // gpio_controller_test_pkg
