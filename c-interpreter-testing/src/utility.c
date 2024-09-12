#include <stdio.h>
#include <stdlib.h>

char *ReadFile(char *path)
{
	// Open file
        FILE *fp = fopen(path, "r");
        if (fp == NULL) {
                printf("File not found.");
                exit(1);
        }

        // Get file length
        fseek(fp, 0, SEEK_END);
        int ccount = ftell(fp);
        fseek(fp, 0, SEEK_SET);

        // Read file to array
        char *res = malloc((ccount + 1) * sizeof(char));
        for (int i = 0; i < ccount; i++) {
                res[i] = fgetc(fp);
        }
        res[ccount] = '\0';
        fclose(fp);

	// Return
	return res;
}
