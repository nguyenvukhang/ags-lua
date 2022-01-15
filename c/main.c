#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

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
  for (int i = 0; i < sizeof(scanlist)/sizeof(scanlist[0]); i++) {
    printf("%s\n", scanlist[i]);
  }

  return 0;
}
