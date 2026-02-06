# ======================
# User configurable
# ======================
TBNAME	    ?=
TESTNAME    ?=	$(TBNAME)
RADIX	    ?=	hexadecimal

# ======================
# Directory structure
# ======================
FILELIST_DIR	:=  filelist
LOG_DIR		:=  logs
WAVE_DIR	:=  waves

# ======================
# Default target
# ======================
all: build run

# ======================
# Build / Compile
# ======================
build:
	vlib work
	vmap work work
	vlog -f $(FILELIST_DIR)/$(TBNAME).f | tee $(LOG_DIR)/compile_$(TBNAME).log

# ======================
# Run simulation
# ======================
run:
	vsim -voptargs=+acc -debugDB -c $(TBNAME) -l $(LOG_DIR)/$(TESTNAME).log -do "log -r /*; run -all; quit"

# ======================
# Open waveform
# ======================
wave:
	vsim -i -view vsim.wlf -do "add wave -r /*; radix -$(RADIX)" &

# ======================
# Clean
# ======================
clean:
	rm -rf work
	rm -rf vsim.dbg
	rm -rf *.ini
	rm -rf $(LOG_DIR)/*
	rm -rf *.wlf
	rm -rf transcript

# ======================
# Help
# ======================
help:
	@echo ""
	@echo "****************************************"
	@echo "** make build                         : compile RTL + TB"
	@echo "** make run TBNAME=tb_x TESTNAME=x  : run specific test"
	@echo "** make all                          : build + run"
	@echo "** make wave TESTNAME=x              : open waveform"
	@echo "** make clean                        : clean sim outputs"
	@echo "****************************************"
	@echo ""
