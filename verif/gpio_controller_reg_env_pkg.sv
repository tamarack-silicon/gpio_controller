package gpio_controller_reg_env_pkg;

	`include "uvm_macros.svh"

	import uvm_pkg::*;
	import gpio_ctrl_csr_ral_pkg::*;
	import apb_agent_pkg::*;

	class reg2apb_adapter extends uvm_reg_adapter;

		`uvm_object_utils(reg2apb_adapter)

		function new(string name = "reg2apb_adapter");
			super.new(name);
		endfunction // new

		virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
			apb_item m_item = apb_item::type_id::create("apb_item");
			m_item.paddr = rw.addr;
			m_item.pwrite = (rw.kind == UVM_WRITE) ? 1'b1 : 1'b0;
			m_item.pstrb = rw.byte_en;
			m_item.pwdata = rw.data;

			return m_item;
		endfunction // reg2bus

		virtual function bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
			apb_item m_item;
			if(!$cast(m_item, bus_item)) begin
				`uvm_fatal("reg2apb_adapter", "failed cast")
			end

			rw.kind = m_item.pwrite ? UVM_WRITE : UVM_READ;
			rw.addr = m_item.paddr;
			rw.data = m_item.pwrite ? m_item.pwdata : m_item.prdata;
		endfunction // bus2reg

	endclass // reg2apb_adapter

	class gpio_controller_reg_env extends uvm_env;

		`uvm_component_utils(gpio_controller_reg_env)

		function new(string name = "gpio_controller_reg_env", uvm_component parent);
			super.new(name, parent);
		endfunction // new

		gpio_ctrl_csr m_ral_model;
		reg2apb_adapter m_reg2apb;
		uvm_reg_predictor#(apb_item) m_apb2reg_predictor;

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			m_ral_model = gpio_ctrl_csr::type_id::create("m_ral_model", this);
			m_reg2apb = reg2apb_adapter::type_id::create("m_reg2apb");
			m_apb2reg_predictor = uvm_reg_predictor#(apb_item)::type_id::create("m_reg2apb_predictor", this);

			m_ral_model.build();
			m_ral_model.lock_model();

			uvm_config_db#(gpio_ctrl_csr)::set(null, "uvm_test_top", "m_ral_model", m_ral_model);
		endfunction // build_phase

		virtual function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);

			m_apb2reg_predictor.map = m_ral_model.default_map;
			m_apb2reg_predictor.adapter = m_reg2apb;
		endfunction // connect_phase

	endclass // gpio_controller_reg_env

endpackage // gpio_controller_reg_env_pkg
