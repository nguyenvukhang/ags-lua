#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

char *strremove(char *str, const char *sub) {
  char *p, *q, *r;
  if (*sub && (q = r = strstr(str, sub)) != NULL) {
    size_t len = strlen(sub);
    while ((r = strstr(p = r + len, sub)) != NULL) {
      while (p < r)
        *q++ = *p++;
    }
    while ((*q++ = *p++) != '\0')
      continue;
  }
  return str;
}

int main() {
  char scanlist[][100] = {
    "~/dots",
    "~/dots/nvim/.config/nvim",
    "~/dots/pass/.password-store",
    "~/dots/personal",
    "~/dots/walls",
    "~/dots/zsh",
    "~/repos/blog",
    "~/repos/hcanoe-firebase/repo",
    "~/repos/min",
    "~/repos/notes",
    "~/repos/uni",
    "~/sunnus/app/dev",
    "~/sunnus/web/dev",
  };

  char *HOME = getenv("HOME");
  printf("%s\n", HOME);
  char *a;
  char b[50];
  for (int i = 0; i < sizeof(scanlist)/sizeof(scanlist[0]); i++) {
    a = strremove(scanlist[i], "~");
    strcpy(b, HOME);
    strcat(b, a);
    printf("%s\n", b);
  }

  /* check if a file exists
   * https://stackoverflow.com/questions/230062/whats-the-best-way-to-check-if-a-file-exists-in-c
   */


  /* 
   * print a particular index
   */
  /* printf("%s ", scanlist[0]); */

  /* 
   * replace a particular index with a new string
   */
  /* strcpy(scanlist[0], "Tesla"); */

  // length of array of strings

  /* for (int i = 0; i < sizeof(scanlist)/sizeof(scanlist[0]); i++) {
   *   printf("%s\n", scanlist[i]);
   * }
   *
   * */

  return 0;
}
