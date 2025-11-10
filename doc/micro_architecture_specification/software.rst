******************
Software Interface
******************

Address Space
=============

The register space of this GPIO controller IP is accessable through APB interface. It consumes 512 bytes of address space. The address space is organized as 16 blocks of 32 bytes. Each 32 byte is assigned to an IO bank. Thus the base address of an IO bank can be calculated with `32*b`.

Control and Status Register
===========================

Each IO bank contains 6 registers, refer to SystemRDL file for more info.

Interrupts
==========

This IP provide one active-high async level interrupt signal.

DMA
===

None

Virtualization
==============

None
