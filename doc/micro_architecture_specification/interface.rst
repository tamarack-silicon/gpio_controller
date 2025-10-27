**********
Interfaces
**********

APB Interface
=============

.. list-table:: Module Ports
   :widths: 15 20 15 40 10
   :class: longtable
   :header-rows: 1

   * - Port Name
     - Port Direction
     - Port Width/Type
     - Port Description
     - Clock
   * - apb_clk
     - Input
     - 1
     - APB Clock
     - Clock
   * - rst_n
     - Input
     - 1
     - Active-low async reset
     - Async
   * - apb_paddr
     - Input
     - 16
     - APB PADDR
     - apb_clk
   * - apb_pwrite
     - Input
     - 1
     - APB PWRITE
     - apb_clk
   * - apb_psel
     - Input
     - 1
     - APB PSEL
     - apb_clk
   * - apb_penable
     - Input
     - 1
     - APB PENABLE
     - apb_clk
   * - apb_pwdata
     - Input
     - 32
     - APB PWDATA
     - apb_clk
   * - apb_pstrb
     - Input
     - 4
     - APB PSTRB
     - apb_clk
   * - apb_prdata
     - Output
     - 32
     - APB PRDATA
     - apb_clk
   * - apb_pready
     - Output
     - 1
     - APB PREADY
     - apb_clk
   * - apb_slverr
     - Output
     - 1
     - APB SLVERR
     - apb_clk
