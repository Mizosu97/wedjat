#include <stdio.h>
#include <atdlib.h>

int main(int argc, char **argv) {
	char *buffer;
	long fileSize;
	FILE file = fopen(argv[1], "r");
	if (!file) {
		fprintf(stderr, "%s%s%s", "Error: File \"", argv[1], "\" not found.")
	}
}
