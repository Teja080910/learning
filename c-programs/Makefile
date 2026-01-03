CC = gcc
CFLAGS = -Wall -Wextra

.PHONY: ALWAYS

# Exclude Makefile from pattern matching
Makefile:;

%: ALWAYS
	@if [ -d "$@" ] && [ -f "$@/$@.c" ]; then \
		$(CC) $(CFLAGS) $@/$@.c -o $@/$@; \
		./$@/$@; \
	else \
		echo "Error: Cannot find $@/$@.c"; \
		exit 1; \
	fi