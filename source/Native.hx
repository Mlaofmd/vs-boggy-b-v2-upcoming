// #if cpp
// #if windows
// @:cppFileCode("include <sysinfoapi.h>")
// #elseif mac
// @:cppFileCode("include <sys/sysctl.h>")
// #elseif linux
// @:cppFileCode("include <sdtio.h>")
// #end
// #end

class Native {
    // #if cpp
    // #if windows
    // @:functionCode('
    //     unsigned long long allocatedRAM = 0;
    //     GetPhysicallyInstalledSystemMemory(&allocatedRAM);
    //     return allocatedRAM;
    // ')
    // #elseif mac
    // @:functionCode('
    //     int mib[] = {CTL_HW, HW_MEMSIZE};
    //     int64_t value = 0;
    //     size_t length = sizeof(value);

    //     if (-1 == sysctl(mib, 2, &value, &length, NULL, 0))
    //         return 0;

    //     return value / 1024 / 1024;
    // ')
    // #elseif linux
    // @:functionCode('
    //     FILE *meminfo = fopen("/proc/meminfo", "r");

    //     if (meminfo == NULL)
    //         return 0;

    //     char line[256];
    //     while(fgets(line, sizeof(line), meminfo)) {
    //         int ram;
    //         if (sscanf(line, "MemTotal: %d kB", &ram) == 1) {
    //             fclose(meminfo);
    //             return ram / 1024;
    //         }
    //     }

    //     fclose(meminfo);
    //     return 0;
    // ')
    // #end
    // #end
    public static function getTotalRAM():Float {
        return openfl.system.System.totalMemory;
    }
}