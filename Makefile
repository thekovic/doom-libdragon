# Copy your IWAD to the IWAD_DIR folder and select corresponding prefix here
IWAD_DIR ?= iwads
# Options: doom1 doomr doom doom2 plutonia tnt
IWAD ?= doom1

SOURCE_DIR = src
BUILD_DIR = build

include $(N64_INST)/include/n64.mk

N64_ROM_TITLE = $(IWAD)

# Uncomment to compile with various safety checks throughout the code
# CFLAGS += -DRANGECHECK

# Uncomment to compile without visible FPS counter
# CFLAGS += -DNO_FPS_COUNTER

all: wad_reset $(IWAD).z64

wad_reset:
	@echo "    Cleaning ROM filesystem..."
	@rm -rf filesystem/*.wad $(FS_IWAD_IDENTIFIER)

ASSETS_MENULUMPS = $(wildcard assets/menulumps/*.bin)
ASSETS_MIDI_INSTRUMENTS = assets/MIDI_Instruments.bin
ASSETS_IWAD = $(IWAD_DIR)/$(IWAD).wad

FS_MENULUMPS = $(addprefix filesystem/menulumps/, $(notdir $(ASSETS_MENULUMPS:%.bin=%.bin)))
FS_MIDI_INSTRUMENTS = $(subst assets/, filesystem/, $(ASSETS_MIDI_INSTRUMENTS))
FS_IWAD = $(subst $(IWAD_DIR)/, filesystem/, $(ASSETS_IWAD))
FS_IWAD_IDENTIFIER = filesystem/iwad_identifier.txt

filesystem/menulumps/%.bin: assets/menulumps/%.bin
	@mkdir -p $(dir $@)
	@echo "    [ASSET] $@"
	@cp "$<" "$(dir $@)"

$(FS_MIDI_INSTRUMENTS): $(ASSETS_MIDI_INSTRUMENTS)
	@mkdir -p $(dir $@)
	@echo "    [ASSET] $@"
	@cp "$<" "$(dir $@)"

$(FS_IWAD): $(ASSETS_IWAD)
	@mkdir -p $(dir $@)
	@echo "    [ASSET] $@"
	@cp "$<" "$(dir $@)"

$(FS_IWAD_IDENTIFIER):
	@echo $(IWAD).WAD > $(FS_IWAD_IDENTIFIER)

filesystem/: $(FS_MENULUMPS) $(FS_MIDI_INSTRUMENTS) $(FS_IWAD) $(FS_IWAD_IDENTIFIER)

$(BUILD_DIR)/$(IWAD).dfs: filesystem/ $(FS_MENULUMPS) $(FS_MIDI_INSTRUMENTS) $(FS_IWAD) $(FS_IWAD_IDENTIFIER)

SOURCE_FILES := $(shell find $(SOURCE_DIR)/ -type f -name '*.c' | sort)
OBJECT_FILES := $(SOURCE_FILES:$(SOURCE_DIR)/%.c=$(BUILD_DIR)/%.o)

$(BUILD_DIR)/$(IWAD).elf: $(OBJECT_FILES)

$(IWAD).z64: $(BUILD_DIR)/$(IWAD).dfs

clean:
	rm -rf $(BUILD_DIR) filesystem/ $(IWAD).z64

-include $(wildcard $(BUILD_DIR)/*.d)

.PHONY: all clean
