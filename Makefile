BASENAME := libnthink
VERSION := 0.1.0
MAJOR_VERSION := $(word 1,$(subst ., ,$(VERSION)))

CC := gcc
CFLAGS := -Wall -Wextra -Werror -pedantic -std=c17

# Installation directory (~/.local by default)
DESTDIR ?= ~/.local
BUILD_DIR ?= build
LIB_DIR ?= lib
OBJECT_DIR ?= obj
EXAMPLE_DIR := examples
SOURCE_DIR := src
INCLUDE_DIR := include

UNAME_S := $(shell uname -s)

# Linux
ifeq ($(UNAME_S),Linux)
	LIB_BASE := $(BASENAME).so
	LIB_MAJOR := $(BASENAME).so.$(MAJOR_VERSION)
	LIB_VERSION := $(BASENAME).so.$(VERSION)
	LDFLAGS := -Wl,-soname,$(LIB_MAJOR)
# Darwin
else ifeq ($(UNAME_S),Darwin)
	LIB_BASE := $(BASENAME).dylib
	LIB_MAJOR := $(BASENAME)-$(MAJOR_VERSION).dylib
	LIB_VERSION := $(BASENAME)-$(VERSION).dylib
	LDFLAGS := -Wl,-install_name,$(LIB_VERSION)
endif

ifndef UNAME_S
$(error Unable to identify OS)
endif

LIB_STATIC := $(BASENAME).a
LIBS := $(addprefix $(BUILD_DIR)/$(LIB_DIR)/,$(LIB_BASE) $(LIB_MAJOR) $(LIB_VERSION))
SOURCES := $(shell find $(SOURCE_DIR) -type f)
INCLUDES := $(shell find $(INCLUDE_DIR) -type f)
OBJECTS := $(patsubst $(SOURCE_DIR)/%.c,$(BUILD_DIR)/$(OBJECT_DIR)/%.o,$(SOURCES))


.PHONY: all
all: config lib_static lib_dynamic


.PHONY: lib_dynamic
lib_dynamic: $(SOURCES) $(INCLUDES)
	$(CC) $(CFLAGS) -fPIC -shared $(LDFLAGS) -o $(BUILD_DIR)/$(LIB_DIR)/$(LIB_VERSION) $(SOURCES)
	ln -sf $(LIB_VERSION) $(BUILD_DIR)/$(LIB_DIR)/$(LIB_BASE)
	ln -sf $(LIB_VERSION) $(BUILD_DIR)/$(LIB_DIR)/$(LIB_MAJOR)


.PHONY: lib_static
lib_static: $(SOURCES) $(INCLUDES)
	$(CC) $(CFLAGS) -o $(OBJECTS) -c $(SOURCES)
	ar rcs $(BUILD_DIR)/$(LIB_DIR)/$(LIB_STATIC) $(OBJECTS)
	chmod 644 $(BUILD_DIR)/$(LIB_DIR)/$(LIB_STATIC)


.PHONY: config
config:
	@mkdir -p $(addprefix $(BUILD_DIR)/,$(SOURCE_DIR) $(INCLUDE_DIR) $(LIB_DIR) $(OBJECT_DIR))
	@install -m 644 $(SOURCES) $(BUILD_DIR)/$(SOURCE_DIR)
	@install -m 644 $(INCLUDES) $(BUILD_DIR)/$(INCLUDE_DIR)


.PHONY: examples
examples:
	$(MAKE) -C $(EXAMPLE_DIR)


.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/*
	$(MAKE) -C $(EXAMPLE_DIR) clean


.PHONY: install
install: all
	mkdir -p $(addprefix $(DESTDIR)/,$(LIB_DIR) $(SOURCE_DIR) $(INCLUDE_DIR))
	cp -R $(filter-out $(BUILD_DIR)/obj,$(wildcard $(BUILD_DIR)/*)) $(DESTDIR)


.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)/$(INCLUDES)
	rm -f $(DESTDIR)/$(SOURCES)
	rm -f $(addprefix $(DESTDIR)/$(LIB_DIR)/,$(LIB_BASE) $(LIB_MAJOR) $(LIB_VERSION) $(LIB_STATIC))


.PHONY: version
version:
	@echo $(VERSION)
