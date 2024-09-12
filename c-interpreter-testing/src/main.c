#include <stdio.h>
#include <stdlib.h>
#include "utility.h"
#include "cleaner.h"

int main(int argc, char **argv)
{
	FILE *srcf = fopen(argv[1], "r");
	if (srcf == NULL) {
		printf("opening file goofed");
		exit(1);
	}

	char *src = ReadFile(srcf);
	char *csrc = CleanSrc(src);
	free(src);

	// Rest
	printf("%s", csrc);
	free(csrc);
}
