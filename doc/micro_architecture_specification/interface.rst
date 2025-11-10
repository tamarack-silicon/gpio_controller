**********
Interfaces
**********

Clock and reset
===============

.. list-table:: Module Ports
   :widths: 15 20 20 35 10
   :class: longtable
   :header-rows: 1

   * - Port Name
     - Port Direction
     - Port Width/Type
     - Port Description
     - Clock
   * - clk
     - Input
     - 1
     - Input Clock
     - Clock
   * - rst_n
     - Input
     - 1
     - Active-low async reset
     - Async

APB Interface
=============

.. list-table:: Module Ports
   :widths: 15 20 20 35 10
   :class: longtable
   :header-rows: 1

   * - Port Name
     - Port Direction
     - Port Width/Type
     - Port Description
     - Clock
   * - paddr
     - Input
     - 16
     - APB PADDR
     - clk
   * - pwrite
     - Input
     - 1
     - APB PWRITE
     - clk
   * - psel
     - Input
     - 1
     - APB PSEL
     - clk
   * - penable
     - Input
     - 1
     - APB PENABLE
     - clk
   * - pwdata
     - Input
     - 32
     - APB PWDATA
     - clk
   * - pstrb
     - Input
     - 4
     - APB PSTRB
     - clk
   * - prdata
     - Output
     - 32
     - APB PRDATA
     - clk
   * - pready
     - Output
     - 1
     - APB PREADY
     - clk
   * - slverr
     - Output
     - 1
     - APB SLVERR
     - clk
   * - interrupt
     - Output
     - 1
     - Active high level interrupt signal
     - async

Interrupt Interface
===================

.. list-table:: Module Ports
   :widths: 15 20 20 35 10
   :class: longtable
   :header-rows: 1

   * - Port Name
     - Port Direction
     - Port Width/Type
     - Port Description
     - Clock
   * - interrupt
     - Output
     - 1
     - Active high level interrupt signal
     - async

GPIO Interface
==============

.. list-table:: Module Ports
   :widths: 15 20 20 35 10
   :class: longtable
   :header-rows: 1

   * - Port Name
     - Port Direction
     - Port Width/Type
     - Port Description
     - Clock
   * - gpio_in_data
     - Input
     - 32 * NUM_BANKS
     - GPIO Input, note the signal is synced internally
     - async
   * - gpio_out_data
     - Output
     - 32 * NUM_BANKS
     - GPIO data output
     - clk
   * - gpio_out_enable
     - Output
     - 32 * NUM_BANKS
     - GPIO output enable control, connect to "Output Enable" signal of tri-state buffer
     - clk
