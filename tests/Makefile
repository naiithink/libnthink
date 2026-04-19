CC = gcc
CFLAGS = -I../build/include -L../build/lib
LDFLAGS = -lnthink

SOURCES := $(shell find . -type f -regex '.*\.c')
TARGETS := $(patsubst %.c,%.out,$(SOURCES))


.PHONY: all
all: $(TARGETS)


%.out: %.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<


.PHONY: clean
clean:
	rm -rf $(TARGETS)
