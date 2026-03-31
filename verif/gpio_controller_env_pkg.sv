package gpio_controller_env_pkg;

	`include "uvm_macros.svh"

	import uvm_pkg::*;
	import apb_agent_pkg::*;
	import gpio_agent_pkg::*;
	import gpio_ctrl_csr_ral_pkg::*;
	import gpio_controller_reg_env_pkg::*;

	class gpio_controller_env extends uvm_env;

		`uvm_component_utils(gpio_controller_env)

		apb_agent m_apb_agent;
		gpio_agent m_gpio_agent;
		gpio_controller_reg_env m_reg_env;

		function new(string name = "gpio_controller_env", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			m_apb_agent = apb_agent::type_id::create("m_apb_agent", this);
			m_gpio_agent = gpio_agent::type_id::create("m_gpio_agent", this);
			m_reg_env = gpio_controller_reg_env::type_id::create("m_reg_env", this);
			uvm_reg::include_coverage("*", UVM_CVR_ALL);
		endfunction // build_phase

		virtual function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);

			m_apb_agent.m_monitor.mon_analysis_port.connect(m_reg_env.m_apb2reg_predictor.bus_in);
			m_reg_env.m_ral_model.default_map.set_sequencer(m_apb_agent.m_sequencer, m_reg_env.m_reg2apb);
			m_reg_env.m_ral_model.default_map.set_auto_predict(1);
		endfunction // connect_phase

	endclass // gpio_controller_env

endpackage
