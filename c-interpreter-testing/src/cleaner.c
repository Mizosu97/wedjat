#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void p(int *c, int *lc, int *i, FILE *tmp)
{
	*lc = *c;
	(*i)++;
	fprintf(tmp, "%c", c);
}

char *CleanSrc(char *src)
{
	FILE *tmp = tmpfile();
	if (tmp == NULL) {
		printf("tmp goofed");
		exit(1);
	}

	int len = strlen(src);


	int instring = -1;
	int inarray = -1;
	char c;
	char lc;

	int i = 0;

	while (i <= len) {
		c = src[i];
		switch (c) {
			case '\"':
				if (lc != '\\') instring *= -1;
				p(&c, &lc, &i, tmp);
			case '[':
				if (instring == -1) inarray = 1;
				p(&c, &lc &i, tmp);
			case ']':
				if (instring == -1) inarray = -1;
				p(&c, &lc, &i, tmp);
			case ' ':
				if (instring == -1) {
					if (i == 0 || lc == ' ' || inarray == 1) {
						lc = c;
						i++;
					} else p(&c, &lc, &i, tmp);
				}

		}
	}


	return "a";
}
