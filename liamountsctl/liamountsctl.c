#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <mntent.h>

static void showMount(const char* name, const char* path, const char* file) {
    printf("%s %s %s\n", name, path, file);
}

static void iterateMounts(void(*callback)(const char* name, const char* path, const char* file)) {
    FILE *mounts = setmntent("/proc/mounts", "r");
    if (!mounts) {
        perror("setmntent");
        return;
    }
    
    struct mntent *entry;
    
    while ((entry = getmntent(mounts)) != NULL) {
        const char* target_dir = "/automounts/";
        
        if (strncmp(entry->mnt_dir, target_dir, strlen(target_dir)) == 0) {
            printf("1  %s -> %s (%s)\n", 
                entry->mnt_fsname, 
                entry->mnt_dir,
                entry->mnt_type);
        } else {
            target_dir = "/realmounts/";

            if (strncmp(entry->mnt_dir, target_dir, strlen(target_dir)) == 0) {
                printf("2  %s -> %s (%s)\n", 
                    entry->mnt_fsname, 
                    entry->mnt_dir,
                    entry->mnt_type);
            }
        }
    }
    
    endmntent(mounts);
}

int main(int argc, char* argv[]) {
    if (argc <= 1) {
        printf("liamountsctl list - displays a list of mounted devices\n");
        printf("liamountsctl umount name - \n");
        return 0;
    }


    if (strcmp(argv[1], "list") == 0) {
        iterateMounts(showMount);
    } else {
        printf("unknown command\n");
    }

    return 0;
}
