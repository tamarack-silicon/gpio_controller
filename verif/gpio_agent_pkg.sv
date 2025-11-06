package gpio_agent_pkg;

	`include "uvm_macros.svh"

	import uvm_pkg::*;

	class gpio_item extends uvm_sequence_item;

		function new(string name = "gpio_item");
			super.new(name);
		endfunction // new

		rand bit [255:0] gpio_in_data;
		bit [255:0]		 gpio_out_data;
		bit [255:0]		 gpio_out_enable;

		`uvm_object_utils_begin(gpio_item)
			`uvm_field_int(gpio_in_data, UVM_DEFAULT)
			`uvm_field_int(gpio_out_data, UVM_DEFAULT)
			`uvm_field_int(gpio_out_enable, UVM_DEFAULT)
		`uvm_object_utils_end

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

	class gpio_monitor extends uvm_monitor;

		`uvm_component_utils(gpio_monitor)

		function new(string name = "gpio_monitor", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		uvm_analysis_port #(gpio_item) mon_analysis_port;
		virtual gpio_if gpio_vif;

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			if(!uvm_config_db#(virtual gpio_if)::get(this, "", "gpio_vif", gpio_vif)) begin
				`uvm_fatal("GPIO_MON", "Could not get vif")
			end

			mon_analysis_port = new("mon_analysis_port", this);
		endfunction // build_phase

		virtual task run_task(uvm_phase phase);
			automatic gpio_item m_item = gpio_item::type_id::create("gpio_item");

			super.run_phase(phase);

			forever begin

				@(gpio_vif.tb_cb); // FIXME make sure DUT is out of reset
				m_item.gpio_out_enable = gpio_vif.tb_cb.gpio_out_enable;
				m_item.gpio_out_data = gpio_vif.tb_cb.gpio_out_data;
				// FIXME capture gpio_in_data

				m_item.print();
				mon_analysis_port.write(m_item);

			end
		endtask // run_task

	endclass

	class gpio_agent extends uvm_agent;

		`uvm_component_utils(gpio_agent)

		gpio_driver driver;
		gpio_monitor monitor;
		uvm_sequencer#(gpio_item) sequencer;

		function new(string name = "gpio_agent", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			sequencer = uvm_sequencer#(gpio_item)::type_id::create("gpio_sequencer", this);
			driver = gpio_driver::type_id::create("gpio_driver", this);
			monitor = gpio_monitor::type_id::create("gpio_monitor", this);
		endfunction // build_phase

		virtual function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			driver.seq_item_port.connect(sequencer.seq_item_export);
		endfunction // connect_phase
		
	endclass // gpio_agent

endpackage
