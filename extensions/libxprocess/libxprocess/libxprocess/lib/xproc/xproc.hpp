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

#include <vector>
#include <string>

namespace ngs::xproc {

  #if !defined(_WIN32)
  typedef int PROCID;
  #else
  typedef unsigned long PROCID;
  #endif

  std::vector<PROCID> proc_id_enum();
  bool proc_id_exists(PROCID proc_id);
  bool proc_id_suspend(PROCID proc_id);
  bool proc_id_resume(PROCID proc_id);
  bool proc_id_kill(PROCID proc_id);
  std::vector<PROCID> parent_proc_id_from_proc_id(PROCID proc_id);
  std::vector<PROCID> proc_id_from_parent_proc_id(PROCID parent_proc_id);
  std::vector<PROCID> proc_id_from_exe(std::string exe);
  std::vector<PROCID> proc_id_from_cwd(std::string cwd);
  std::string exe_from_proc_id(PROCID proc_id);
  std::string cwd_from_proc_id(PROCID proc_id);
  std::vector<std::string> cmdline_from_proc_id(PROCID proc_id);
  std::vector<std::string> environ_from_proc_id(PROCID proc_id);
  std::string envvar_value_from_proc_id(PROCID proc_id, std::string name);
  bool envvar_exists_from_proc_id(PROCID proc_id, std::string name);

} // namespace ngs::xproc
