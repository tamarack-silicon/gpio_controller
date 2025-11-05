package gpio_agent_pkg;

	`include "uvm_macros.svh"

	import uvm_pkg::*;

	class gpio_item extends uvm_sequence_item;

		`uvm_object_utils(gpio_item)

		function new(string name = "gpio_item");
			super.new(name);
		endfunction // new

		rand bit [255:0] gpio_in_data;
		bit [255:0]		 gpio_out_data;
		bit [255:0]		 gpio_out_enable;

	endclass // gpio_item

	class gpio_driver extends uvm_driver#(gpio_item);

		`uvm_component_utils(gpio_driver)

		virtual gpio_if gpio_vif;

		function new(string name = "gpio_driver", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			if(!uvm_config_db #(virtual gpio_if)::get(this, "", "gpio_vif", gpio_vif)) begin
				`uvm_fatal("GPIO_DRV", "Cannot get virtual interface")
			end
		endfunction // build_phase

		virtual task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				gpio_item m_item;
				`uvm_info("GPIO_DRV", $sformatf("Waiting for item"), UVM_HIGH)
				seq_item_port.get_next_item(m_item);
				drive_item(m_item);
				seq_item_port.item_done();
			end
		endtask // run_phase

		virtual task drive_item(gpio_item m_item);
			@(gpio_vif.tb_cb);
			gpio_vif.tb_cb.gpio_in_data <= m_item.gpio_in_data;
		endtask // drive_item

	endclass // gpio_driver

	class gpio_agent extends uvm_agent;

		`uvm_component_utils(gpio_agent)

		gpio_driver driver;
		uvm_sequencer#(gpio_item) sequencer;

		function new(string name = "gpio_agent", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			sequencer = uvm_sequencer#(gpio_item)::type_id::create("sequencer", this);
			driver = gpio_driver::type_id::create("driver", this);
		endfunction // build_phase
		
	endclass // gpio_agent

endpackage
