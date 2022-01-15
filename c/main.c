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
    "~/dummy/meme/lord",
  };

  char *HOME = getenv("HOME");
  // printf("%s\n", HOME);
  char git_suffix[5] = "/.git";
  char *no_tildy;
  char full_path[100];
  char git_data_file[105];
  for (int i = 0; i < sizeof(scanlist)/sizeof(scanlist[0]); i++) {
    no_tildy = strremove(scanlist[i], "~");

    strcpy(full_path, HOME);
    strcpy(git_data_file, HOME);

    strcat(full_path, no_tildy); // b -> full path to repo
    strcat(git_data_file, no_tildy);
    strcat(git_data_file, git_suffix);

    if (access(git_data_file, F_OK) == 0) {
      // file exists
      printf("    exists");
    } else {
      printf("not exists");
    }
    printf("%s\n", git_data_file);
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
