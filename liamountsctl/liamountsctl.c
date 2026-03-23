#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>
#include <stdbool.h>
#include <string.h>
#include <mntent.h>
#include <sys/stat.h>
#include <unistd.h>

#define PATH_MAX 256

static bool fs_exists(const char* path) {
    return access(path, F_OK) == 0;
}

static bool fs_isDir(const char* path) {
    struct stat st;
    if (stat(path, &st) == 0) {
        return S_ISDIR(st.st_mode);
    }
    return false;
}

static const char* get_fs_dev_file(const char* mnt_fsname) {
    static char result[PATH_MAX];
    char current[PATH_MAX];
    
    strncpy(current, mnt_fsname, PATH_MAX - 1);
    
    while (1) {
        // Если это не каталог — выходим
        if (!fs_isDir(current)) {
            strncpy(result, current, PATH_MAX - 1);
            return result;
        }
        
        // Ищем в /proc/mounts
        FILE* mounts = setmntent("/proc/mounts", "r");
        if (!mounts) {
            strncpy(result, current, PATH_MAX - 1);
            return result;
        }
        
        struct mntent* entry;
        const char* source = NULL;
        
        while ((entry = getmntent(mounts)) != NULL) {
            if (strcmp(entry->mnt_dir, current) == 0) {
                source = entry->mnt_fsname;
                break;
            }
        }
        
        endmntent(mounts);
        
        // Если не нашли монтирование или источник совпадает — выходим
        if (!source || strcmp(source, current) == 0) {
            strncpy(result, current, PATH_MAX - 1);
            return result;
        }
        
        // Идём дальше по цепочке
        strncpy(current, source, PATH_MAX - 1);
    }
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

                const char* dev_path = get_fs_dev_file(entry->mnt_fsname);
                if (fs_exists(real_mount_directory)) {
                    callback("", dev_path, entry->mnt_dir, real_mount_directory);
                } else {
                    callback("", dev_path, entry->mnt_dir, entry->mnt_dir);
                }

                free(real_mount_directory);
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

    if (setuid(0) != 0) {
        perror("setuid");
        return 1;
    }

    if (strcmp(argv[1], "list") == 0) {
        iterateMounts(showMount);
    } else {
        printf("unknown command\n");
    }

    return 0;
}
