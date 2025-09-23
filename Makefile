# Name of the IP block
IP_NAME := gpio_controller

# CSR Block Name
CSR_BLOCK_NAME := gpio_ctrl_csr

# Design IP dependency in 'ip' folder
RTL_IP_DEP := 

# Design IP dependency in same folder as current ip
RTL_REPO_DEP := 

# Verification IP dependency in 'ip' folder
VERIF_IP_DEP := 

# Verification IP dependency in same folder as current ip
VERIF_REPO_DEP := 

# RTL top level module name
RTL_TOP_NAME := gpio_controller

# Testbench top level module name
VERIF_TOP_NAME := gpio_controller_verif_tb

# Default testbench name
TB_NAME := gpio_controller_tb

# Default UVM test name
TEST := gpio_controller_test

include ip/flows/digital-ip.mk
