#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char* argv[]) {
    if (argc <= 1) {
        printf("liamountsctl list - displays a list of mounted devices\n");
        return 0;
    }


    if (strcmp(argv[1], "list") == 0) {
        
    } else {
        printf("unknown command\n");
    }

    return 0;
}
