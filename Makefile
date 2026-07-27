# For zsh users with custom aliases in .zshrc
#SHELL := /bin/zsh
#.SHELLFLAGS := -ic

MAKEFLAGS += --no-print-directory

.PHONY: uvm sim clean 

TOP  := cpu_tb
VLOG := $(wildcard rtl/*.sv  tb/sim/*.sv)
VHDL := $(wildcard rtl/*.vhd tb/*.vhd)
UVM  := $(wildcard tb/uvm/*.sv)

OK   := $(patsubst %, build/%.ok, $(VLOG) $(VHDL) )
DIRS := $(sort $(dir $(OK)))

uvm: build/tb/uvm/simv
	cd build && ./tb/uvm/simv -no_save -q \
	+UVM_NO_RELNOTES        \
	+UVM_VERBOSITY=UVM_HIGH \
	+UVM_TESTNAME=myTest	\
	+UVM_TIMEOUT=1000000,YES

sim: build/simv
	cd build && ./simv -no_save -q

sim_syn: syn/mapped.1.v
	cd build && vcs -full64 -sverilog \
	../tb/syn/cpu_tb.sv \
	../syn/mapped.1.v \
	/opt/synopsys/saed/32-edk/lib/stdcell_rvt/verilog/saed32nm.v \
	-override_timescale=1ns/1ns \
	-R

waveform: 
	cd build && verdi -sv \
	../rtl/*.sv           \
	../tb/uvm/0.pkg.sv    \
	../tb/uvm/A.uvm_tb.sv \
	-ssf novas.fsdb
	
clean: 
	rm -rf build
	rm -rf syn/*
	rm -rf report/*

syn/mapped.%.v: $(DIRS)
	cd build && fc_shell -batch -f ../scripts/run.tcl -x "set T $*"

build/simv: $(OK)
	cd build && vcs -full64 -q -sverilog -debug_access+all $(TOP)

build/tb/uvm/simv: $(UVM) $(VLOG)
	mkdir -p build/tb/uvm
	cd build && vcs -full64 -q -sverilog -debug_access+all \
		-ntb_opts uvm-ieee-2020-3.1 \
		+incdir+../tb/uvm           \
		-o tb/uvm/simv              \
		../rtl/*.sv                 \
		../tb/uvm/0.pkg.sv          \
		../tb/uvm/A.uvm_tb.sv

build/%.sv.ok  : %.sv  | $(DIRS)
	cd build && vlogan -full64 -q -sverilog ../$<
	@touch $@

build/%.vhd.ok : %.vhd | $(DIRS)
	cd build && vhdlan -full64 -q ../$<
	@touch $@

$(DIRS):
	mkdir -p $@
