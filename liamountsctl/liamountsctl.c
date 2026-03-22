#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>
#include <stdbool.h>
#include <string.h>
#include <mntent.h>
#include <sys/stat.h>
#include <unistd.h>

bool fs_exists(const char* path) {
    return access(path, F_OK) == 0;
}

static void showMount(const char* name, const char* file, const char* access_mount_directory, const char* real_mount_directory) {
    printf("%s %s %s %s\n", name, file, access_mount_directory, real_mount_directory);
}

static void iterateMounts(void(*callback)(const char* name, const char* file, const char* access_mount_directory, const char* real_mount_directory)) {
    FILE *mounts = setmntent("/proc/mounts", "r");
    if (!mounts) {
        perror("setmntent");
        return;
    }
    
    struct mntent *entry;
    
    while ((entry = getmntent(mounts)) != NULL) {
        const char* target_dir = "/automounts/";
        
        if (strncmp(entry->mnt_dir, target_dir, strlen(target_dir)) == 0) {
            char* real_mount_directory = strdup(entry->mnt_dir);
            if (real_mount_directory) {
                const char* str = "/realmounts/";
                memcpy(real_mount_directory, str, strlen(str));

                if (fs_exists(real_mount_directory)) {
                    callback("", "", entry->mnt_dir, real_mount_directory);
                } else {
                    callback("", "", entry->mnt_dir, real_mount_directory);
                }
            }

            free(real_mount_directory);
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
