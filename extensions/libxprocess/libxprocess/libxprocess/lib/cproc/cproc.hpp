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

#pragma once

#if defined(_WIN32)
#if defined(_MSC_VER)
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#endif
#else
#include <sys/types.h>
#endif

namespace ngs::cproc {

  #if !defined(_WIN32)
  #define XPROCID int
  #else
  #define XPROCID unsigned long
  #endif
  #define CPROCID XPROCID
  #if defined(PROCESS_GUIWINDOW_IMPL)
  #if defined(_WIN32) || ((defined(__APPLE__) && defined(__MACH__)) && !defined(PROCESS_XQUARTZ_IMPL))
  #define WINDOW void *
  #elif (defined(__linux__) && !defined(__ANDROID__)) || (defined(__FreeBSD__) || defined(__DragonFly__) || defined(__NetBSD__) || defined(__OpenBSD__)) || defined(__sun) || defined(PROCESS_XQUARTZ_IMPL)
  #define WINDOW unsigned long
  #endif
  #define WINDOWID char *
  #endif
  #define PROCLIST int
  #define PROCINFO int
  #define KINFOFLAGS int
  #define KINFO_EXEP 0x1000
  #define KINFO_CWDP 0x2000
  #define KINFO_PPID 0x0100
  #define KINFO_CPID 0x0200
  #define KINFO_ARGV 0x0010
  #define KINFO_ENVV 0x0020
  #if defined(PROCESS_GUIWINDOW_IMPL)
  #define KINFO_OWID 0x0001
  #endif

  void proc_id_enumerate(XPROCID **proc_id, int *size);
  void free_proc_id(XPROCID *proc_id);
  void proc_id_from_self(XPROCID *proc_id);
  XPROCID proc_id_from_self();
  void parent_proc_id_from_self(XPROCID *parent_proc_id);
  XPROCID parent_proc_id_from_self();
  bool proc_id_exists(XPROCID proc_id);
  bool proc_id_suspend(XPROCID proc_id);
  bool proc_id_resume(XPROCID proc_id);
  bool proc_id_kill(XPROCID proc_id);
  const char *executable_from_self();
  void parent_proc_id_from_proc_id(XPROCID proc_id, XPROCID *parent_proc_id);
  XPROCID parent_proc_id_from_proc_id(XPROCID proc_id);
  void proc_id_from_parent_proc_id(XPROCID parent_proc_id, XPROCID **proc_id, int *size);
  const char *exe_from_proc_id(XPROCID proc_id);
  void exe_from_proc_id(XPROCID proc_id, char **buffer);
  const char *directory_get_current_working();
  bool directory_set_current_working(const char *dname);
  const char *cwd_from_proc_id(XPROCID proc_id);
  void cwd_from_proc_id(XPROCID proc_id, char **buffer);
  void free_cmdline(char **buffer);
  void cmdline_from_proc_id(XPROCID proc_id, char ***buffer, int *size);
  const char *environment_get_variable(const char *name);
  bool environment_get_variable_exists(const char *name);
  bool environment_set_variable(const char *name, const char *value);
  bool environment_unset_variable(const char *name);
  void free_environ(char **buffer);
  void environ_from_proc_id(XPROCID proc_id, char ***buffer, int *size);
  void environ_from_proc_id_ex(XPROCID proc_id, const char *name, char **value);
  const char *environ_from_proc_id_ex(XPROCID proc_id, const char *name);
  bool environ_from_proc_id_ex_exists(XPROCID proc_id, const char *name);
  const char *directory_get_temporary_path();
  PROCINFO proc_info_from_proc_id(XPROCID proc_id);
  PROCINFO proc_info_from_proc_id_ex(XPROCID proc_id, KINFOFLAGS kinfo_flags);
  void free_proc_info(PROCINFO proc_info);
  PROCLIST proc_list_create();
  XPROCID process_id(PROCLIST proc_list, int i);
  int process_id_length(PROCLIST proc_list);
  void free_proc_list(PROCINFO proc_info);
  #if defined(PROCESS_GUIWINDOW_IMPL)
  WINDOWID window_id_from_native_window(WINDOW window);
  WINDOW native_window_from_window_id(WINDOWID winid);
  void window_id_enumerate(WINDOWID **win_id, int *size);
  void proc_id_from_window_id(WINDOWID win_id, XPROCID *proc_id);
  void window_id_from_proc_id(XPROCID proc_id, WINDOWID **win_id, int *size);
  void free_window_id(WINDOWID *win_id);
  bool window_id_exists(WINDOWID win_id);
  bool window_id_suspend(WINDOWID win_id);
  bool window_id_resume(WINDOWID win_id);
  bool window_id_kill(WINDOWID win_id);
  #endif

  char *executable_image_file_path(PROCINFO proc_info);
  char *current_working_directory(PROCINFO proc_info);
  XPROCID parent_process_id(PROCINFO proc_info);
  XPROCID *child_process_id(PROCINFO proc_info);
  XPROCID child_process_id(PROCINFO proc_info, int i);
  int child_process_id_length(PROCINFO proc_info);
  char **commandline(PROCINFO proc_info);
  char *commandline(PROCINFO proc_info, int i);
  int commandline_length(PROCINFO proc_info);
  char **environment(PROCINFO proc_info);
  char *environment(PROCINFO proc_info, int i);
  int environment_length(PROCINFO proc_info);
  #if defined(PROCESS_GUIWINDOW_IMPL)
  WINDOWID *owned_window_id(PROCINFO proc_info);
  WINDOWID owned_window_id(PROCINFO proc_info, int i);
  int owned_window_id_length(PROCINFO proc_info);
  #endif

  CPROCID process_execute(const char *command);
  CPROCID process_execute_async(const char *command);
  ssize_t executed_process_write_to_standard_input(CPROCID proc_index, const char *input);
  const char *executed_process_read_from_standard_output(CPROCID proc_index);
  bool free_executed_process_standard_input(CPROCID proc_index);
  bool free_executed_process_standard_output(CPROCID proc_index);
  bool completion_status_from_executed_process(CPROCID proc_index);
  const char *current_process_read_from_standard_input();

} // namespace ngs::cproc
