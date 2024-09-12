#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utility.h"

void p(int *c, int *lc, int *i, FILE *tmp)
{
	*lc = *c;
	(*i)++;
	fprintf(tmp, "%c", c);
}

char *CleanSrc(char *src)
{
	printf("cleanedsrc function entered\n");
	FILE *tmp = tmpfile();
	if (tmp == NULL) {
		printf("tmp goofed");
		exit(1);
	}

	int len = strlen(src);


	int instring = -1;
	int inarray = -1;
	int c;
	int lc;

	int i = 0;

	while (i < len - 1 ) {
		c = src[i];
		if (c == '\0') {
			printf("end");
			break;
		}
		printf("%d\t%c\n", i, c);
		switch (c) {
			case '\"':
				if (lc != '\\') instring *= -1;
				p(&c, &lc, &i, tmp);
				break;
			case '[':
				if (instring == -1) inarray = 1;
				p(&c, &lc, &i, tmp);
				break;
			case ']':
				if (instring == -1) inarray = -1;
				p(&c, &lc, &i, tmp);
				break;
			case ' ':
				if (i == 0 || lc == ' ' || inarray == 1) {
					lc = c;
					i++;
				} else p(&c, &lc, &i, tmp);

				break;
			case '\n':
				if (instring == -1) {
					lc = c;
					i++;
				}
				break;
			case '\t':
				if (instring == -1) {
					lc = c;
					i++;
				}
				break;
			case '>':
				if (instring == -1) {
					int li = i;
					while (li < len-1) {
						if (src[li] == '\n') {
							lc = '\n';
							i = ++li;
							break;
						}
						li++;
					}
				}
				break;
			default:
				p(&c, &lc, &i, tmp);
				break;

		}
	}
	printf("after loop");

	char *final = ReadFile(tmp);
	fclose(tmp);
	return final;
}
