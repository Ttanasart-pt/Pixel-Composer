/*

 MIT License
 
 Copyright © 2021-2022 Samuel Venable
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
*/

#include <algorithm>
#include <sstream>

#include <cstdlib>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <climits>
#include <cstdio>

#include "xproc.hpp"

#if !defined(_WIN32)
#include <signal.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#endif

#if defined(_WIN32)
#include <shlwapi.h>
#include <Objbase.h>
#include <tlhelp32.h>
#include <winternl.h>
#include <psapi.h>
#elif (defined(__APPLE__) && defined(__MACH__))
#include <sys/sysctl.h>
#include <sys/proc_info.h>
#include <libproc.h>
#elif (defined(__linux__) || defined(__ANDROID__))
#include <dirent.h>
#elif defined(__FreeBSD__)
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <sys/param.h>
#include <sys/queue.h>
#include <sys/user.h>
#include <libprocstat.h>
#include <libutil.h>
#elif defined(__DragonFly__) || defined(__OpenBSD__)
#include <sys/param.h>
#include <sys/sysctl.h>
#include <sys/user.h>
#include <kvm.h>
#elif defined(__NetBSD__)
#include <sys/param.h>
#include <sys/sysctl.h>
#include <kvm.h>
#elif defined(__sun)
#include <kvm.h>
#include <sys/param.h>
#include <sys/time.h>
#include <sys/proc.h>
#endif

#if defined(_WIN32)
#if defined(_MSC_VER)
#pragma comment(lib, "ntdll.lib")
#endif
#endif

namespace {

  void message_pump() {
    #if defined(_WIN32) 
    MSG msg; 
    while (PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE)) {
      TranslateMessage(&msg);
      DispatchMessage(&msg);
    }
    #endif
  }

  std::vector<std::string> string_split_by_first_equals_sign(std::string str) {
    std::size_t pos = 0;
    std::vector<std::string> vec;
    if ((pos = str.find_first_of("=")) != std::string::npos) {
      vec.push_back(str.substr(0, pos));
      vec.push_back(str.substr(pos + 1));
    }
    return vec;
  }

  #if defined(_WIN32)
  enum MEMTYP {
    MEMCMD,
    MEMENV,
    MEMCWD
  };

  #if !defined(_MSC_VER)
  #pragma pack(push, 8)
  #else
  #include <pshpack8.h>
  #endif

  /* CURDIR struct from:
   https://github.com/processhacker/phnt/
   CC BY 4.0 licence */

  typedef struct {
    UNICODE_STRING DosPath;
    HANDLE Handle;
  } CURDIR;

  /* RTL_DRIVE_LETTER_CURDIR struct from:
   https://github.com/processhacker/phnt/
   CC BY 4.0 licence */

  typedef struct {
    USHORT Flags;
    USHORT Length;
    ULONG TimeStamp;
    STRING DosPath;
  } RTL_DRIVE_LETTER_CURDIR;

  /* RTL_USER_PROCESS_PARAMETERS struct from:
   https://github.com/processhacker/phnt/
   CC BY 4.0 licence */

  typedef struct {
    ULONG MaximumLength;
    ULONG Length;
    ULONG Flags;
    ULONG DebugFlags;
    HANDLE ConsoleHandle;
    ULONG ConsoleFlags;
    HANDLE StandardInput;
    HANDLE StandardOutput;
    HANDLE StandardError;
    CURDIR CurrentDirectory;
    UNICODE_STRING DllPath;
    UNICODE_STRING ImagePathName;
    UNICODE_STRING CommandLine;
    PVOID Environment;
    ULONG StartingX;
    ULONG StartingY;
    ULONG CountX;
    ULONG CountY;
    ULONG CountCharsX;
    ULONG CountCharsY;
    ULONG FillAttribute;
    ULONG WindowFlags;
    ULONG ShowWindowFlags;
    UNICODE_STRING WindowTitle;
    UNICODE_STRING DesktopInfo;
    UNICODE_STRING ShellInfo;
    UNICODE_STRING RuntimeData;
    RTL_DRIVE_LETTER_CURDIR CurrentDirectories[32];
    ULONG_PTR EnvironmentSize;
    ULONG_PTR EnvironmentVersion;
    PVOID PackageDependencyData;
    ULONG ProcessGroupId;
    ULONG LoaderThreads;
    UNICODE_STRING RedirectionDllName;
    UNICODE_STRING HeapPartitionName;
    ULONG_PTR DefaultThreadpoolCpuSetMasks;
    ULONG DefaultThreadpoolCpuSetMaskCount;
  } RTL_USER_PROCESS_PARAMETERS;

  #if !defined(_MSC_VER)
  #pragma pack(pop)
  #else
  #include <poppack.h>
  #endif

  std::string narrow(std::wstring wstr) {
    if (wstr.empty()) return "";
    int nbytes = WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), (int)wstr.length(), nullptr, 0, nullptr, nullptr); 
    std::vector<char> buf(nbytes);
    return std::string { buf.data(), (std::size_t)WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), (int)wstr.length(), buf.data(), nbytes, nullptr, nullptr) };
  }

  HANDLE open_process_with_debug_privilege(ngs::xproc::PROCID proc_id) {
    HANDLE proc = nullptr;
    HANDLE hToken = nullptr;
    LUID luid;
    TOKEN_PRIVILEGES tkp;
    if (OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken)) {
      if (LookupPrivilegeValue(nullptr, SE_DEBUG_NAME, &luid)) {
        tkp.PrivilegeCount = 1;
        tkp.Privileges[0].Luid = luid;
        tkp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
        if (AdjustTokenPrivileges(hToken, false, &tkp, sizeof(tkp), nullptr, nullptr)) {
          proc = OpenProcess(PROCESS_ALL_ACCESS, false, proc_id);
        }
      }
      CloseHandle(hToken);
    }
    if (!proc) {
      proc = OpenProcess(PROCESS_ALL_ACCESS, false, proc_id);
    }
    return proc;
  }

  std::vector<wchar_t> cwd_cmd_env_from_proc(HANDLE proc, int type) {
    std::vector<wchar_t> buffer;
    PEB peb;
    SIZE_T nRead = 0; 
    ULONG len = 0;
    PROCESS_BASIC_INFORMATION pbi;
    RTL_USER_PROCESS_PARAMETERS upp;
    NTSTATUS status = NtQueryInformationProcess(proc, ProcessBasicInformation, &pbi, sizeof(pbi), &len);
    ULONG error = RtlNtStatusToDosError(status);
    if (error) return buffer;
    ReadProcessMemory(proc, pbi.PebBaseAddress, &peb, sizeof(peb), &nRead);
    if (!nRead) return buffer;
    ReadProcessMemory(proc, peb.ProcessParameters, &upp, sizeof(upp), &nRead);
    if (!nRead) return buffer;
    PVOID buf = nullptr; len = 0;
    if (type == MEMCWD) {
      buf = upp.CurrentDirectory.DosPath.Buffer;
      len = upp.CurrentDirectory.DosPath.Length;
    } else if (type == MEMENV) {
      buf = upp.Environment;
      len = (ULONG)upp.EnvironmentSize;
    } else if (type == MEMCMD) {
      buf = upp.CommandLine.Buffer;
      len = upp.CommandLine.Length;
    }
    buffer.resize(len / 2 + 1);
    ReadProcessMemory(proc, buf, &buffer[0], len, &nRead);
    if (!nRead) return buffer;
    buffer[len / 2] = L'\0';
    return buffer;
  }
  #endif

  #if (defined(__APPLE__) && defined(__MACH__))
  enum MEMTYP {
    MEMCMD,
    MEMENV
  };

  std::vector<std::string> cmd_env_from_proc_id(ngs::xproc::PROCID proc_id, int type) {
    std::vector<std::string> vec;
    std::size_t s = 0;
    int argmax = 0, nargs = 0;
    char *procargs = nullptr, *sp = nullptr, *cp = nullptr; 
    int mib[3];
    mib[0] = CTL_KERN;
    mib[1] = KERN_ARGMAX;
    s = sizeof(argmax);
    if (sysctl(mib, 2, &argmax, &s, nullptr, 0) == -1) {
      return vec;
    }
    procargs = (char *)malloc(argmax);
    if (procargs == nullptr) {
      return vec;
    }
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROCARGS2;
    mib[2] = proc_id;
    s = argmax;
    if (sysctl(mib, 3, procargs, &s, nullptr, 0) == -1) {
      free(procargs);
      return vec;
    }
    memcpy(&nargs, procargs, sizeof(nargs));
    cp = procargs + sizeof(nargs);
    for (; cp < &procargs[s]; cp++) {
      if (*cp == '\0') break;
    }
    if (cp == &procargs[s]) {
      free(procargs); 
      return vec;
    }
    for (; cp < &procargs[s]; cp++) {
      if (*cp != '\0') break;
    }
    if (cp == &procargs[s]) {
      free(procargs);
      return vec;
    }
    sp = cp;
    int i = 0;
    while ((*sp != '\0' || i < nargs) && sp < &procargs[s]) {
      if (type && i >= nargs) {
        vec.push_back(sp);
      } else if (!type && i < nargs) {
        vec.push_back(sp);
      }
      sp += strlen(sp) + 1;
      i++;
    }
    free(procargs);
    return vec;
  }
  #endif

  #if defined(__DragonFly__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__sun)
  kvm_t *kd = nullptr;
  #endif

} // anonymous namespace

namespace ngs::xproc {

  std::vector<PROCID> proc_id_enum() {
    std::vector<PROCID> vec;
    #if defined(_WIN32)
    HANDLE hp = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (!hp) return vec;
    PROCESSENTRY32 pe;
    pe.dwSize = sizeof(PROCESSENTRY32);
    if (Process32First(hp, &pe)) {
      do {
        message_pump();
        vec.push_back(pe.th32ProcessID);
      } while (Process32Next(hp, &pe));
    }
    CloseHandle(hp);
    #elif (defined(__APPLE__) && defined(__MACH__))
    vec.push_back(0);
    int cntp = proc_listpids(PROC_ALL_PIDS, 0, nullptr, 0);
    std::vector<PROCID> proc_info(cntp);
    std::fill(proc_info.begin(), proc_info.end(), 0);
    proc_listpids(PROC_ALL_PIDS, 0, &proc_info[0], sizeof(PROCID) * cntp);
    for (int i = cntp - 1; i >= 0; i--) {
      if (proc_info[i] == 0) continue;
      vec.push_back(proc_info[i]);
    }
    #elif (defined(__linux__) || defined(__ANDROID__))
    vec.push_back(0);
    DIR *proc = opendir("/proc");
    struct dirent *ent = nullptr;
    PROCID tgid = 0;
    if (proc == nullptr) return vec;
    while ((ent = readdir(proc))) {
      if (!isdigit(*ent->d_name))
        continue;
      tgid = (PROCID)strtoul(ent->d_name, nullptr, 10);
      vec.push_back(tgid);
    }
    closedir(proc);
    #elif defined(__FreeBSD__)
    int cntp = 0;
    kinfo_proc *proc_info = kinfo_getallproc(&cntp);
    if (proc_info) {
      for (int i = 0; i < cntp; i++) {
        vec.push_back(proc_info[i].ki_pid);
      }
      free(proc_info);
    }
    #elif defined(__DragonFly__)
    int cntp = 0;
    kinfo_proc *proc_info = nullptr;
    const char *nlistf, *memf;
    nlistf = memf = "/dev/null";
    kd = kvm_openfiles(nlistf, memf, nullptr, O_RDONLY, nullptr); 
    if (!kd) return vec;
    if ((proc_info = kvm_getprocs(kd, KERN_PROC_ALL, 0, &cntp))) {
      for (int i = 0; i < cntp; i++) {
        if (proc_info[i].kp_pid >= 0) {
          vec.push_back(proc_info[i].kp_pid);
        }
      }
    }
    kvm_close(kd);
    #elif defined(__NetBSD__)
    int cntp = 0;
    kinfo_proc2 *proc_info = nullptr;
    kd = kvm_openfiles(nullptr, nullptr, nullptr, KVM_NO_FILES, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getproc2(kd, KERN_PROC_ALL, 0, sizeof(struct kinfo_proc2), &cntp))) {
      for (int i = cntp - 1; i >= 0; i--) {
        vec.push_back(proc_info[i].p_pid);
      }
    }
    kvm_close(kd);
    #elif defined(__OpenBSD__)
    vec.push_back(0);
    int cntp = 0;
    kinfo_proc *proc_info = nullptr;
    kd = kvm_openfiles(nullptr, nullptr, nullptr, KVM_NO_FILES, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getprocs(kd, KERN_PROC_ALL, 0, sizeof(struct kinfo_proc), &cntp))) {
      for (int i = cntp - 1; i >= 0; i--) {
        vec.push_back(proc_info[i].p_pid);
      }
    }
    kvm_close(kd);
    #elif defined(__sun)
    struct pid cur_pid;
    proc *proc_info = nullptr;
    kd = kvm_open(nullptr, nullptr, nullptr, O_RDONLY, nullptr);
    if (!kd) return vec;
    while ((proc_info = kvm_nextproc(kd))) {
      if (kvm_kread(kd, (std::uintptr_t)proc_info->p_pidp, &cur_pid, sizeof(cur_pid)) != -1) {
        vec.insert(vec.begin(), cur_pid.pid_id);
      }
    }
    kvm_close(kd);
    #endif
    return vec;
  }

  bool proc_id_exists(PROCID proc_id) {
    std::vector<PROCID> vec = proc_id_enum();
    auto itr = std::find(vec.begin(), vec.end(), proc_id);
    return (itr != vec.end());
  }

  bool proc_id_suspend(PROCID proc_id) {
    #if !defined(_WIN32)
    return (kill(proc_id, SIGSTOP) != -1);
    #else
    HANDLE proc = open_process_with_debug_privilege(proc_id);
    if (proc == nullptr) return false;
    typedef NTSTATUS (__stdcall *NTSP)(IN HANDLE ProcessHandle);
    HMODULE hModule = GetModuleHandleW(L"ntdll.dll");
    if (!hModule) return false;
    FARPROC farProc = GetProcAddress(hModule, "NtSuspendProcess");
    if (!farProc) return false;
    NTSP NtSuspendProcess = (NTSP)farProc;
    NTSTATUS status = NtSuspendProcess(proc);
    ULONG error = RtlNtStatusToDosError(status);
    CloseHandle(proc);
    return (!error);
    #endif
  }

  bool proc_id_resume(PROCID proc_id) {
    #if !defined(_WIN32)
    return (kill(proc_id, SIGCONT) != -1);
    #else
    HANDLE proc = open_process_with_debug_privilege(proc_id);
    if (proc == nullptr) return false;
    typedef NTSTATUS (__stdcall *NTRP)(IN HANDLE ProcessHandle);
    HMODULE hModule = GetModuleHandleW(L"ntdll.dll");
    if (!hModule) return false;
    FARPROC farProc = GetProcAddress(hModule, "NtResumeProcess");
    if (!farProc) return false;
    NTRP NtResumeProcess = (NTRP)farProc;
    NTSTATUS status = NtResumeProcess(proc);
    ULONG error = RtlNtStatusToDosError(status);
    CloseHandle(proc);
    return (!error);
    #endif
  }

  bool proc_id_kill(PROCID proc_id) {
    #if !defined(_WIN32)
    return (kill(proc_id, SIGKILL) != -1);
    #else
    HANDLE proc = open_process_with_debug_privilege(proc_id);
    if (proc == nullptr) return false;
    bool result = TerminateProcess(proc, 0);
    CloseHandle(proc);
    return result;
    #endif
  }

  std::vector<PROCID> parent_proc_id_from_proc_id(PROCID proc_id) {
    std::vector<PROCID> vec;
    #if defined(_WIN32)
    HANDLE hp = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (!hp) return vec;
    PROCESSENTRY32 pe;
    pe.dwSize = sizeof(PROCESSENTRY32);
    if (Process32First(hp, &pe)) {
      do {
        if (pe.th32ProcessID == proc_id) {
          message_pump();
          vec.push_back(pe.th32ParentProcessID);
          break;
        }
      } while (Process32Next(hp, &pe));
    }
    CloseHandle(hp);
    #elif (defined(__APPLE__) && defined(__MACH__))
    proc_bsdinfo proc_info;
    if (proc_pidinfo(proc_id, PROC_PIDTBSDINFO, 0, &proc_info, sizeof(proc_info)) > 0) {
      vec.push_back(proc_info.pbi_ppid);
    }
    if (vec.empty() && (proc_id == 0 || proc_id == 1))
      vec.push_back(0);
    #elif (defined(__linux__) || defined(__ANDROID__))
    char buffer[BUFSIZ];
    sprintf(buffer, "/proc/%d/stat", proc_id);
    FILE *stat = fopen(buffer, "r");
    if (stat) {
      std::size_t size = fread(buffer, sizeof(char), sizeof(buffer), stat);
      if (size > 0) {
        char *token = nullptr;
        if ((token = strtok(buffer, " "))) {
          if ((token = strtok(nullptr, " "))) {
            if ((token = strtok(nullptr, " "))) {
              if ((token = strtok(nullptr, " "))) {
                PROCID parent_proc_id = (PROCID)strtoul(token, nullptr, 10);
                vec.push_back(parent_proc_id);
              }
            }
          }
        }
      }
      fclose(stat);
    }
    if (vec.empty() && proc_id == 0) 
      vec.push_back(0);
    #elif defined(__FreeBSD__)
    kinfo_proc *proc_info = kinfo_getproc(proc_id);
    if (proc_info) {
      vec.push_back(proc_info->ki_ppid);
      free(proc_info);
    } 
    #elif defined(__DragonFly__)
    int cntp = 0;
    kinfo_proc *proc_info = nullptr;
    const char *nlistf, *memf;
    nlistf = memf = "/dev/null";
    kd = kvm_openfiles(nlistf, memf, nullptr, O_RDONLY, nullptr); 
    if (!kd) return vec;
    if ((proc_info = kvm_getprocs(kd, KERN_PROC_PID, proc_id, &cntp))) {
      if (proc_info->kp_ppid >= 0) {
        vec.push_back(proc_info->kp_ppid);
      }
    }
    kvm_close(kd);
    if (vec.empty() && proc_id == 0)
      vec.push_back(0);
    #elif defined(__NetBSD__)
    int cntp = 0;
    kinfo_proc2 *proc_info = nullptr;
    kd = kvm_openfiles(nullptr, nullptr, nullptr, KVM_NO_FILES, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getproc2(kd, KERN_PROC_PID, proc_id, sizeof(struct kinfo_proc2), &cntp))) {
      vec.push_back(proc_info->p_ppid);
    }
    kvm_close(kd);
    #elif defined(__OpenBSD__)
    int cntp = 0;
    kinfo_proc *proc_info = nullptr;
    kd = kvm_openfiles(nullptr, nullptr, nullptr, KVM_NO_FILES, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getprocs(kd, KERN_PROC_PID, proc_id, sizeof(struct kinfo_proc), &cntp))) {
      vec.push_back(proc_info->p_ppid);
    }
    kvm_close(kd);
    if (vec.empty() && proc_id == 0)
      vec.push_back(0);
    #elif defined(__sun)
    proc *proc_info = nullptr;
    kd = kvm_open(nullptr, nullptr, nullptr, O_RDONLY, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getproc(kd, proc_id))) {
      vec.push_back(proc_info->p_ppid);
    }
    kvm_close(kd);
    #endif
    return vec;
  }

  std::vector<PROCID> proc_id_from_parent_proc_id(PROCID parent_proc_id) {
    std::vector<PROCID> vec;
    #if defined(_WIN32)
    HANDLE hp = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (!hp) return vec;
    PROCESSENTRY32 pe;
    pe.dwSize = sizeof(PROCESSENTRY32);
    if (Process32First(hp, &pe)) {
      do {
        message_pump();
        if (pe.th32ParentProcessID == parent_proc_id) {
          vec.push_back(pe.th32ProcessID);
        }
      } while (Process32Next(hp, &pe));
    }
    CloseHandle(hp);
    #elif (defined(__APPLE__) && defined(__MACH__))
    int cntp = proc_listpids(PROC_PPID_ONLY, (uint32_t)parent_proc_id, nullptr, 0);
    std::vector<PROCID> proc_info(cntp);
    std::fill(proc_info.begin(), proc_info.end(), 0);
    proc_listpids(PROC_PPID_ONLY, (uint32_t)parent_proc_id, &proc_info[0], sizeof(PROCID) * cntp);
    for (int i = cntp - 1; i >= 0; i--) {
      if (proc_info[i] == 0) continue;
      if (proc_info[i] == 1 && parent_proc_id == 0) {
        vec.push_back(0);
      }
      vec.push_back(proc_info[i]);
    }
    #elif (defined(__linux__) || defined(__ANDROID__))
    std::vector<PROCID> proc_id = proc_id_enum();
    for (std::size_t i = 0; i < proc_id.size(); i++) {
      std::vector<PROCID> ppid = parent_proc_id_from_proc_id(proc_id[i]);
      if (!ppid.empty() && ppid[0] == parent_proc_id) {
        vec.push_back(proc_id[i]);
      }
    }
    #elif defined(__FreeBSD__)
    int cntp = 0; 
    kinfo_proc *proc_info = kinfo_getallproc(&cntp);
    if (proc_info) {
      for (int i = 0; i < cntp; i++) {
        if (proc_info[i].ki_ppid == parent_proc_id) {
          vec.push_back(proc_info[i].ki_pid);
        }
      }
      free(proc_info);
    }
    #elif defined(__DragonFly__)
    int cntp = 0;
    kinfo_proc *proc_info = nullptr;
    const char *nlistf, *memf;
    nlistf = memf = "/dev/null";
    kd = kvm_openfiles(nlistf, memf, nullptr, O_RDONLY, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getprocs(kd, KERN_PROC_ALL, 0, &cntp))) {
      for (int i = 0; i < cntp; i++) {
        if (proc_info[i].kp_pid == 1 && proc_info[i].kp_ppid == 0 && parent_proc_id == 0) {
          vec.push_back(0);
        }
        if (proc_info[i].kp_pid >= 0 && proc_info[i].kp_ppid >= 0 && proc_info[i].kp_ppid == parent_proc_id) {
          vec.push_back(proc_info[i].kp_pid);
        }
      }
    }
    kvm_close(kd);
    #elif defined(__NetBSD__)
    int cntp = 0;
    kinfo_proc2 *proc_info = nullptr;
    kd = kvm_openfiles(nullptr, nullptr, nullptr, KVM_NO_FILES, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getproc2(kd, KERN_PROC_ALL, 0, sizeof(struct kinfo_proc2), &cntp))) {
      for (int i = cntp - 1; i >= 0; i--) {
        if (proc_info[i].p_ppid == parent_proc_id) {
          vec.push_back(proc_info[i].p_pid);
        }
      }
    }
    kvm_close(kd);
    #elif defined(__OpenBSD__)
    int cntp = 0;
    kinfo_proc *proc_info = nullptr;
    kd = kvm_openfiles(nullptr, nullptr, nullptr, KVM_NO_FILES, nullptr); 
    if (!kd) return vec;
    if ((proc_info = kvm_getprocs(kd, KERN_PROC_ALL, 0, sizeof(struct kinfo_proc), &cntp))) {
      for (int i = cntp - 1; i >= 0; i--) {
        if (proc_info[i].p_pid == 1 && proc_info[i].p_ppid == 0 && parent_proc_id == 0) {
          vec.push_back(0);
        }
        if (proc_info[i].p_ppid == parent_proc_id) {
          vec.push_back(proc_info[i].p_pid);
        }
      }
    }
    kvm_close(kd);
    #elif defined(__sun)
    struct pid cur_pid;
    proc *proc_info = nullptr;
    kd = kvm_open(nullptr, nullptr, nullptr, O_RDONLY, nullptr);
    if (!kd) return vec;
    while ((proc_info = kvm_nextproc(kd))) {
      if (proc_info->p_ppid == parent_proc_id) {
        if (kvm_kread(kd, (std::uintptr_t)proc_info->p_pidp, &cur_pid, sizeof(cur_pid)) != -1) {
          vec.insert(vec.begin(), cur_pid.pid_id);
        }
      }
    }
    kvm_close(kd);
    #endif
    return vec;
  }

  std::vector<PROCID> proc_id_from_exe(std::string exe) {
    auto fnamecmp = [](std::string fname1, std::string fname2) {
      #if defined(_WIN32)
      std::size_t fp = fname2.find_last_of("\\/");
      bool abspath = (!fname1.empty() && fname1.length() >= 3 && fname1[1] == ':' &&
        (fname1[2] == '\\' || fname1[2] == '/'));
      #else
      std::size_t fp = fname2.find_last_of("/");
      bool abspath = (!fname1.empty() && fname1.length() >= 1 && fname1[0] == '/');
      #endif
      if (fname1.empty() || fname2.empty() || fp == std::string::npos) return false;
      #if defined(_WIN32)
      if (abspath && fname1.length() == 3) return (fname1 == fname2.substr(0, fp + 1));
      #else
      if (abspath && fname1.length() == 1) return (fname1 == fname2.substr(0, fp + 1));
      #endif
      if (abspath) return (fname1 == fname2 || fname1 == fname2.substr(0, fp));
      return (fname1 == fname2.substr(fp + 1));
    };
    std::vector<PROCID> vec;
    std::vector<PROCID> proc_id = proc_id_enum();
    for (std::size_t i = 0; i < proc_id.size(); i++) {
      if (fnamecmp(exe, exe_from_proc_id(proc_id[i]))) {
        vec.push_back(proc_id[i]);
      }
    }
    return vec;
  }

  std::vector<PROCID> proc_id_from_cwd(std::string cwd) {
    auto fnamecmp = [](std::string fname1, std::string fname2) {
      if (fname1.empty() || fname2.empty()) return false;
      return (fname1 == fname2);
    };
    std::vector<PROCID> vec;
    std::vector<PROCID> proc_id = proc_id_enum();
    for (std::size_t i = 0; i < proc_id.size(); i++) {
      if (fnamecmp(cwd, cwd_from_proc_id(proc_id[i]))) {
        vec.push_back(proc_id[i]);
      }
    }
    return vec;
  }

  std::string exe_from_proc_id(PROCID proc_id) {
    std::string path;
    #if defined(_WIN32)
    if (proc_id == GetCurrentProcessId()) {
      wchar_t buffer[MAX_PATH];
      if (GetModuleFileNameW(nullptr, buffer, sizeof(buffer)) != 0) {
        wchar_t exe[MAX_PATH];
        if (_wfullpath(exe, buffer, MAX_PATH)) {
          path = narrow(exe);
        }
      }
    } else {
      HANDLE proc = open_process_with_debug_privilege(proc_id);
      if (proc == nullptr) return path;
      wchar_t buffer[MAX_PATH];
      DWORD size = sizeof(buffer);
      if (QueryFullProcessImageNameW(proc, 0, buffer, &size) != 0) {
        wchar_t exe[MAX_PATH];
        if (_wfullpath(exe, buffer, MAX_PATH)) {
          path = narrow(exe);
        }
      }
      CloseHandle(proc);
    }
    #elif (defined(__APPLE__) && defined(__MACH__))
    char exe[PROC_PIDPATHINFO_MAXSIZE];
    if (proc_pidpath(proc_id, exe, sizeof(exe)) > 0) {
      char buffer[PATH_MAX];
      if (realpath(exe, buffer)) {
        path = buffer;
      }
    }
    #elif (defined(__linux__) || defined(__ANDROID__))
    char exe[PATH_MAX];
    if (realpath(("/proc/" + std::to_string(proc_id) + "/exe").c_str(), exe)) {
      path = exe;
    }
    #elif defined(__FreeBSD__) || defined(__DragonFly__)
    int mib[4]; 
    std::size_t len;
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PATHNAME;
    mib[3] = proc_id;
    if (sysctl(mib, 4, nullptr, &len, nullptr, 0) == 0) {
      std::string strbuff;
      strbuff.resize(len, '\0');
      char *exe = strbuff.data();
      if (sysctl(mib, 4, exe, &len, nullptr, 0) == 0) {
        char buffer[PATH_MAX];
        if (realpath(exe, buffer)) {
          path = buffer;
        }
      }
    }
    #elif defined(__NetBSD__)
    int mib[4]; 
    std::size_t len;
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC_ARGS;
    mib[2] = proc_id;
    mib[3] = KERN_PROC_PATHNAME;
    if (sysctl(mib, 4, nullptr, &len, nullptr, 0) == 0) {
      std::string strbuff;
      strbuff.resize(len, '\0');
      char *exe = strbuff.data();
      if (sysctl(mib, 4, exe, &len, nullptr, 0) == 0) {
        char buffer[PATH_MAX];
        if (realpath(exe, buffer)) {
          path = buffer;
        }
      }
    }
    #elif defined(__OpenBSD__)
    auto is_executable = [](PROCID proc_id, std::string in, std::string *out) {
      *out = "";
      bool success = false;
      struct stat st;
      if (!stat(in.c_str(), &st) && (st.st_mode & S_IXUSR) && (st.st_mode & S_IFREG)) {
        char executable[PATH_MAX];
        if (realpath(in.c_str(), executable)) {
          int cntp = 0;
          kinfo_file *kif = nullptr;
          kd = kvm_openfiles(nullptr, nullptr, nullptr, KVM_NO_FILES, nullptr);
          if (!kd) return false;
          if ((kif = kvm_getfiles(kd, KERN_FILE_BYPID, proc_id, sizeof(struct kinfo_file), &cntp))) {
            for (int i = 0; i < cntp; i++) {
              if (kif[i].fd_fd == KERN_FILE_TEXT) {
                if (st.st_dev == (dev_t)kif[i].va_fsid || st.st_ino == (ino_t)kif[i].va_fileid) {
                  *out = executable;
                  success = true;
                  break;
                }
              }
            }
          }
          kvm_close(kd);
        }
      }
      return success;
    };
    std::vector<std::string> buffer = cmdline_from_proc_id(proc_id);
    if (!buffer.empty()) {
      bool is_exe = false;
      std::string argv0;
      if (!buffer[0].empty()) {
        if (buffer[0][0] == '/') {
          argv0 = buffer[0];
          is_exe = is_executable(proc_id, argv0.c_str(), &path);
        } else if (buffer[0].find('/') == std::string::npos) {
          std::string penv = envvar_value_from_proc_id(proc_id, "PATH");
          if (!penv.empty()) {
            std::vector<std::string> env;
            std::string tmp;
            std::stringstream sstr(penv); 
            while (std::getline(sstr, tmp, ':')) {
              env.push_back(tmp);
            }
            for (std::size_t i = 0; i < env.size(); i++) {
              argv0 = env[i] + "/" + buffer[0];
              is_exe = is_executable(proc_id, argv0.c_str(), &path);
              if (is_exe) break;
              if (buffer[0][0] == '-') {
                argv0 = env[i] + "/" + buffer[0].substr(1);
                is_exe = is_executable(proc_id, argv0.c_str(), &path);
                if (is_exe) break;
              }
            }
          }
        } else {
          std::string pwd = envvar_value_from_proc_id(proc_id, "PWD");
          if (!pwd.empty()) {
            argv0 = pwd + "/" + buffer[0];
            is_exe = is_executable(proc_id, argv0.c_str(), &path);
          }
          if (pwd.empty() || !is_exe) {
            std::string cwd = cwd_from_proc_id(proc_id);
            if (!cwd.empty()) {
              argv0 = cwd + "/" + buffer[0];
              is_exe = is_executable(proc_id, argv0.c_str(), &path);
            }
          }
        }
      }
    }
    #elif defined(__sun)
    char exe[PATH_MAX];
    if (realpath(("/proc/" + std::to_string(proc_id) + "/path/a.out").c_str(), exe)) {
      path = exe;
    }
    #endif
    return path;
  }

  std::string cwd_from_proc_id(PROCID proc_id) {
    std::string path;
    #if defined(_WIN32)
    HANDLE proc = open_process_with_debug_privilege(proc_id);
    if (proc == nullptr) return path;
    std::vector<wchar_t> buffer = cwd_cmd_env_from_proc(proc, MEMCWD);
    if (!buffer.empty()) {
      wchar_t cwd[MAX_PATH];
      if (_wfullpath(cwd, &buffer[0], MAX_PATH)) {
        path = narrow(cwd);
        if (!path.empty() && std::count(path.begin(), path.end(), '\\') > 1 && path.back() == '\\') {
          path = path.substr(0, path.length() - 1);
        }
      }
    }
    CloseHandle(proc);
    #elif (defined(__APPLE__) && defined(__MACH__))
    proc_vnodepathinfo vpi;
    if (proc_pidinfo(proc_id, PROC_PIDVNODEPATHINFO, 0, &vpi, sizeof(vpi)) > 0) {
      char buffer[PATH_MAX];
      if (realpath(vpi.pvi_cdir.vip_path, buffer)) {
        path = buffer;
      }
    }
    #elif (defined(__linux__) || defined(__ANDROID__))
    char cwd[PATH_MAX];
    if (realpath(("/proc/" + std::to_string(proc_id) + "/cwd").c_str(), cwd)) {
      path = cwd;
    }
    #elif defined(__FreeBSD__)
    unsigned cntp = 0;
    procstat *proc_stat = procstat_open_sysctl();
    if (proc_stat) {
      kinfo_proc *proc_info = procstat_getprocs(proc_stat, KERN_PROC_PID, proc_id, &cntp);
      if (proc_info) {
        filestat_list *head = procstat_getfiles(proc_stat, proc_info, 0);
        if (head) {
          filestat *fst = nullptr;
          STAILQ_FOREACH(fst, head, next) {
            if (fst->fs_uflags & PS_FST_UFLAG_CDIR) {
              char buffer[PATH_MAX];
              if (realpath(fst->fs_path, buffer)) {
                path = buffer;
              }
            }
          }
          procstat_freefiles(proc_stat, head);
        }
        procstat_freeprocs(proc_stat, proc_info);
      }
      procstat_close(proc_stat);
    }
    #elif defined(__DragonFly__)
    /* Probably the hackiest thing ever we are doing here, because the "official" API is broken OS-level. */
    FILE *fp = popen(("pos=`ans=\\`/usr/bin/fstat -w -p " + std::to_string(proc_id) + " | /usr/bin/sed -n 1p\\`; " +
      "/usr/bin/awk -v ans=\"$ans\" 'BEGIN{print index(ans, \"INUM\")}'`; str=`/usr/bin/fstat -w -p " + 
      std::to_string(proc_id) + " | /usr/bin/sed -n 3p`; /usr/bin/awk -v str=\"$str\" -v pos=\"$pos\" " +
      "'BEGIN{print substr(str, 0, pos + 4)}' | /usr/bin/awk 'NF{NF--};1 {$1=$2=$3=$4=\"\"; print" +
      " substr($0, 5)'}").c_str(), "r");
    if (fp) {
      char buffer[PATH_MAX];
      if (fgets(buffer, sizeof(buffer), fp)) {
        std::string str = buffer;
        std::size_t pos = str.find("\n", strlen(buffer) - 1);
        if (pos != std::string::npos) {
          str.replace(pos, 1, "");
        }
        if (realpath(str.c_str(), buffer)) {
          path = buffer;
        }
      }
      pclose(fp);
    }
    #elif defined(__OpenBSD__)
    int mib[3];
    std::size_t len = 0;
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC_CWD;
    mib[2] = proc_id;
    if (sysctl(mib, 3, nullptr, &len, nullptr, 0) == 0) {
      std::string strbuff;
      strbuff.resize(len, '\0');
      char *cwd = strbuff.data();
      if (sysctl(mib, 3, cwd, &len, nullptr, 0) == 0) {
        char buffer[PATH_MAX];
        if (realpath(cwd, buffer)) {
          path = buffer;
        }
      }
    }
    #elif defined(__NetBSD__)
    int mib[4];
    std::size_t len = 0;
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC_ARGS;
    mib[2] = proc_id;
    mib[3] = KERN_PROC_CWD;
    if (sysctl(mib, 4, nullptr, &len, nullptr, 0) == 0) {
      std::string strbuff;
      strbuff.resize(len, '\0');
      char *cwd = strbuff.data();
      if (sysctl(mib, 4, cwd, &len, nullptr, 0) == 0) {
        char buffer[PATH_MAX];
        if (realpath(cwd, buffer)) {
          path = buffer;
        }
      }
    }
    #elif defined(__sun)
    char cwd[PATH_MAX];
    if (realpath(("/proc/" + std::to_string(proc_id) + "/path/cwd").c_str(), cwd)) {
      path = cwd;
    }
    #endif
    return path;
  }

  std::vector<std::string> cmdline_from_proc_id(PROCID proc_id) {
    std::vector<std::string> vec;
    #if defined(_WIN32)
    HANDLE proc = open_process_with_debug_privilege(proc_id);
    if (proc == nullptr) return vec;
    int cmdsize = 0;
    std::vector<wchar_t> buffer = cwd_cmd_env_from_proc(proc, MEMCMD);
    if (!buffer.empty()) {
      wchar_t **cmd = CommandLineToArgvW(&buffer[0], &cmdsize);
      if (cmd) {
        for (int i = 0; i < cmdsize; i++) {
          message_pump();
          vec.push_back(narrow(cmd[i]));
        }
        LocalFree(cmd);
      }
    }
    CloseHandle(proc);
    #elif (defined(__APPLE__) && defined(__MACH__))
    vec = cmd_env_from_proc_id(proc_id, MEMCMD);
    #elif (defined(__linux__) || defined(__ANDROID__))
    FILE *file = fopen(("/proc/" + std::to_string(proc_id) + "/cmdline").c_str(), "rb");
    if (file) {
      char *cmd = nullptr;
      std::size_t size = 0;
      while (getdelim(&cmd, &size, 0, file) != -1) {
        vec.push_back(cmd);
      }
      while (!vec.empty() && vec.back().empty())
        vec.pop_back();
      if (cmd) free(cmd);
      fclose(file);
    }
    #elif defined(__FreeBSD__)
    unsigned cntp = 0;
    procstat *proc_stat = procstat_open_sysctl();
    if (proc_stat) {
      kinfo_proc *proc_info = procstat_getprocs(proc_stat, KERN_PROC_PID, proc_id, &cntp);
      if (proc_info) {
        char **cmd = procstat_getargv(proc_stat, proc_info, 0);
        if (cmd) {
          for (int i = 0; cmd[i]; i++) {
            vec.push_back(cmd[i]);
          }
          procstat_freeargv(proc_stat);
        }
        procstat_freeprocs(proc_stat, proc_info);
      }
      procstat_close(proc_stat);
    }
    #elif defined(__DragonFly__)
    int cntp = 0;
    kinfo_proc *proc_info = nullptr;
    const char *nlistf, *memf;
    nlistf = memf = "/dev/null";
    kd = kvm_openfiles(nlistf, memf, nullptr, O_RDONLY, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getprocs(kd, KERN_PROC_PID, proc_id, &cntp))) {
      char **cmd = kvm_getargv(kd, proc_info, 0);
      if (cmd) {
        for (int i = 0; cmd[i]; i++) {
          vec.push_back(cmd[i]);
        }
      }
    }
    kvm_close(kd);
    #elif defined(__NetBSD__)
    int cntp = 0;
    kinfo_proc2 *proc_info = nullptr;
    kd = kvm_openfiles(nullptr, nullptr, nullptr, KVM_NO_FILES, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getproc2(kd, KERN_PROC_PID, proc_id, sizeof(struct kinfo_proc2), &cntp))) {
      char **cmd = kvm_getargv2(kd, proc_info, 0);
      if (cmd) {
        for (int i = 0; cmd[i]; i++) {
          vec.push_back(cmd[i]);
        }
      }
    }
    kvm_close(kd);
    #elif defined(__OpenBSD__)
    int cntp = 0;
    kinfo_proc *proc_info = nullptr;
    kd = kvm_openfiles(nullptr, nullptr, nullptr, KVM_NO_FILES, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getprocs(kd, KERN_PROC_PID, proc_id, sizeof(struct kinfo_proc), &cntp))) {
      char **cmd = kvm_getargv(kd, proc_info, 0);
      if (cmd) {
        for (int i = 0; cmd[i]; i++) {
          vec.push_back(cmd[i]);
        }
      }
    }
    kvm_close(kd);
    #elif defined(__sun)
    char **cmd = nullptr;
    proc *proc_info = nullptr;
    user *proc_user = nullptr;
    kd = kvm_open(nullptr, nullptr, nullptr, O_RDONLY, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getproc(kd, proc_id))) {
      if ((proc_user = kvm_getu(kd, proc_info))) {
        if (!kvm_getcmd(kd, proc_info, proc_user, &cmd, nullptr)) {
          for (int i = 0; cmd[i]; i++) {
            vec.push_back(cmd[i]);
          }
          free(cmd);
        }
      }
    }
    kvm_close(kd);
    #endif
    return vec;
  }

  std::vector<std::string> environ_from_proc_id(PROCID proc_id) {
    std::vector<std::string> vec;
    #if defined(_WIN32)
    HANDLE proc = open_process_with_debug_privilege(proc_id);
    if (proc == nullptr) return vec;
    std::vector<wchar_t> buffer = cwd_cmd_env_from_proc(proc, MEMENV);
    int i = 0;
    if (!buffer.empty()) {
      while (buffer[i] != L'\0') {
        message_pump();
        vec.push_back(narrow(&buffer[i]));
        i += (int)(wcslen(&buffer[0] + i) + 1);
      }
    }
    CloseHandle(proc);
    #elif (defined(__APPLE__) && defined(__MACH__))
    vec = cmd_env_from_proc_id(proc_id, MEMENV);
    #elif (defined(__linux__) || defined(__ANDROID__))
    FILE *file = fopen(("/proc/" + std::to_string(proc_id) + "/environ").c_str(), "rb");
    if (file) {
      char *env = nullptr;
      std::size_t size = 0;
      while (getdelim(&env, &size, 0, file) != -1) {
        vec.push_back(env);
      }
      struct is_empty {
        bool operator()(const std::string &s) {
          return s.empty();
        }
      };
      vec.erase(std::remove_if(vec.begin(), vec.end(), is_empty()), vec.end());
      if (env) free(env);
      fclose(file);
    }
    #elif defined(__FreeBSD__)
    unsigned cntp = 0;
    procstat *proc_stat = procstat_open_sysctl();
    if (proc_stat) {
      kinfo_proc *proc_info = procstat_getprocs(proc_stat, KERN_PROC_PID, proc_id, &cntp);
      if (proc_info) {
        char **env = procstat_getenvv(proc_stat, proc_info, 0);
        if (env) {
          for (int i = 0; env[i]; i++) {
            vec.push_back(env[i]);
          }
          procstat_freeenvv(proc_stat);
        }
        procstat_freeprocs(proc_stat, proc_info);
      }
      procstat_close(proc_stat);
    }
    #elif defined(__DragonFly__)
    int cntp = 0;
    kinfo_proc *proc_info = nullptr;
    const char *nlistf, *memf;
    nlistf = memf = "/dev/null";
    kd = kvm_openfiles(nlistf, memf, nullptr, O_RDONLY, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getprocs(kd, KERN_PROC_PID, proc_id, &cntp))) {
      char **env = kvm_getenvv(kd, proc_info, 0);
      if (env) {
        for (int i = 0; env[i]; i++) {
          vec.push_back(env[i]);
        }
      }
    }
    kvm_close(kd);
    #elif defined(__NetBSD__)
    int cntp = 0;
    kinfo_proc2 *proc_info = nullptr;
    kd = kvm_openfiles(nullptr, nullptr, nullptr, KVM_NO_FILES, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getproc2(kd, KERN_PROC_PID, proc_id, sizeof(struct kinfo_proc2), &cntp))) {
      char **env = kvm_getenvv2(kd, proc_info, 0);
      if (env) {
        for (int i = 0; env[i]; i++) {
          vec.push_back(env[i]);
        }
      }
    }
    kvm_close(kd);
    #elif defined(__OpenBSD__)
    int cntp = 0;
    kinfo_proc *proc_info = nullptr;
    kd = kvm_openfiles(nullptr, nullptr, nullptr, KVM_NO_FILES, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getprocs(kd, KERN_PROC_PID, proc_id, sizeof(struct kinfo_proc), &cntp))) {
      char **env = kvm_getenvv(kd, proc_info, 0);
      if (env) {
        for (int i = 0; env[i]; i++) {
          vec.push_back(env[i]);
        }
      }
    }
    kvm_close(kd);
    #elif defined(__sun)
    char **env = nullptr;
    proc *proc_info = nullptr;
    user *proc_user = nullptr;
    kd = kvm_open(nullptr, nullptr, nullptr, O_RDONLY, nullptr);
    if (!kd) return vec;
    if ((proc_info = kvm_getproc(kd, proc_id))) {
      if ((proc_user = kvm_getu(kd, proc_info))) {
        if (!kvm_getcmd(kd, proc_info, proc_user, nullptr, &env)) {
          for (int i = 0; env[i]; i++) {
            vec.push_back(env[i]);
          }
          free(env);
        }
      }
    }
    kvm_close(kd);
    #endif
    return vec;
  }

  std::string envvar_value_from_proc_id(PROCID proc_id, std::string name) {
    std::string value;
    std::vector<std::string> vec = environ_from_proc_id(proc_id);
    if (!vec.empty()) {
      for (std::size_t i = 0; i < vec.size(); i++) {
        message_pump();
        std::vector<std::string> equalssplit = string_split_by_first_equals_sign(vec[i]);
        if (equalssplit.size() == 2) {
          #if defined(_WIN32)
          std::transform(equalssplit[0].begin(), equalssplit[0].end(), equalssplit[0].begin(), ::toupper);
          std::transform(name.begin(), name.end(), name.begin(), ::toupper);
          #endif
          if (equalssplit[0] == name) {
            value = equalssplit[1];
            break;
          }
        }
      }
    }
    return value;
  }

  bool envvar_exists_from_proc_id(PROCID proc_id, std::string name) {
    bool exists = false;
    std::vector<std::string> vec = environ_from_proc_id(proc_id);
    if (!vec.empty()) {
      for (std::size_t i = 0; i < vec.size(); i++) {
        message_pump();
        std::vector<std::string> equalssplit = string_split_by_first_equals_sign(vec[i]);
        if (!equalssplit.empty()) {
          #if defined(_WIN32)
          std::transform(equalssplit[0].begin(), equalssplit[0].end(), equalssplit[0].begin(), ::toupper);
          std::transform(name.begin(), name.end(), name.begin(), ::toupper);
          #endif
          if (equalssplit[0] == name) {
            exists = true;
            break;
          }
        }
      }
    }
    return exists;
  }

} // namespace ngs::xproc
