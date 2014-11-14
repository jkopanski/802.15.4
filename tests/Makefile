TOPLEVEL = sample_module

PWD=$(shell pwd)

VERILOG_SOURCES=$(PWD)/../core/sample_module.v
MODULE=test_phy
# TESTCASE = TestPHY

include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim

nose:
	nosetests
