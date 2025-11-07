package gpio_controller_test_pkg;

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

	class gpio_controller_test extends uvm_test;

		`uvm_component_utils(gpio_controller_test)

		gpio_controller_env m_env;

		virtual rst_if rst_vif;

		uvm_reg_access_seq m_reg_access_seq;
		uvm_reg_hw_reset_seq m_reg_hw_reset_seq;

		function new(string name = "gpio_controller_test", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			m_env = gpio_controller_env::type_id::create("m_env", this);
			m_reg_access_seq = uvm_reg_access_seq::type_id::create("m_reg_access_seq", this);
			m_reg_hw_reset_seq = uvm_reg_hw_reset_seq::type_id::create("m_reg_hw_reset_seq", this);

			if(!uvm_config_db#(virtual rst_if)::get(null, "uvm_test_top", "rst_vif", rst_vif)) begin
				`uvm_fatal("TEST", "Can not get rst_vif virtual interface")
			end
		endfunction // build_phase

		virtual task run_phase(uvm_phase phase);
			gpio_ctrl_csr m_ral_model;
			uvm_status_e status;

			logic [31:0] read_value;

			uvm_config_db#(gpio_ctrl_csr)::get(null, "uvm_test_top", "m_ral_model", m_ral_model);

			phase.raise_objection(phase);

			`uvm_info("TEST", $sformatf("begin reset"), UVM_HIGH)
			rst_vif.rst_n = 1'b0; // FIXME modport
			#20;
			`uvm_info("TEST", $sformatf("release from reset"), UVM_HIGH)
			rst_vif.rst_n = 1'b1; // FIXME modport
			#20;

			m_env.m_reg_env.set_report_verbosity_level(UVM_HIGH);

			/*
			m_reg_hw_reset_seq.model = m_env.m_reg_env.m_ral_model;
			m_reg_hw_reset_seq.start(m_reg_hw_reset_seq.model.default_map.get_sequencer());

			m_reg_access_seq.model = m_env.m_reg_env.m_ral_model; // FIXME backdoor access
			m_reg_access_seq.start(m_reg_access_seq.model.default_map.get_sequencer());
			*/

			m_ral_model.output_data[0].odata.write(status, 32'h12345678);
			m_ral_model.output_data[1].odata.write(status, 32'h90abcdef);
			m_ral_model.output_data[2].odata.write(status, 32'h1a2b3c4d);
			m_ral_model.output_data[3].odata.write(status, 32'haabbccdd);
			m_ral_model.output_data[4].odata.write(status, 32'h11223344);
			m_ral_model.output_data[5].odata.write(status, 32'h55667788);
			m_ral_model.output_data[6].odata.write(status, 32'h1c2d3e4f);
			m_ral_model.output_data[7].odata.write(status, 32'h6a7b8c9d);

			for(int i=0; i<8; i++) begin
				m_ral_model.output_data[i].odata.read(status, read_value);
			end

			for(int i=0; i<8; i++) begin
				m_ral_model.input_data[i].idata.read(status, read_value);
			end

			#20;

			phase.drop_objection(phase);

			`uvm_fatal("TEST", "end of test")
		endtask // run_phase

	endclass

endpackage // gpio_controller_test_pkg
