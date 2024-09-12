#include <stdio.h>
#include <stdlib.h>
#include "utility.h"
#include "cleaner.h"

int main(int argc, char **argv)
{
	char *src = ReadFile(argv[1]);

	// Rest
	printf("%s", src);
}
