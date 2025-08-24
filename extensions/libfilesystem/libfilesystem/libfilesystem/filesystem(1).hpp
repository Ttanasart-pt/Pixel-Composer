/*

 MIT License
 
 Copyright © 2020-2022 Samuel Venable
 
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
#include <string>
#include <cstdint>

namespace ngs::fs {

  // File Descriptors
  #define FD_RDONLY 0 // Opened as Read-Only
  #define FD_WRONLY 1 // Opened as Write-Only
  #define FD_RDWR   2 // Reading and Writing
  #define FD_APPEND 3 // Opened for Appending
  #define FD_RDAP   4 // Reading and Appending

  // Directory Contents
  #define DC_ATOZ   0 // Alphabetical Order
  #define DC_ZTOA   1 // Reverse Alphabetical Order
  #define DC_AOTON  2 // Date Accessed Ordered Old to New
  #define DC_ANTOO  3 // Date Accessed Ordered New to Old
  #define DC_MOTON  4 // Date Modified Ordered Old to New
  #define DC_MNTOO  5 // Date Modified Ordered New to Old
  #define DC_COTON  6 // Date Created Ordered Old to New
  #define DC_CNTOO  7 // Date Created Ordered New to Old
  #define DC_RAND   8 // Random Order

  std::string directory_get_current_working();
  bool directory_set_current_working(std::string dname);
  std::string directory_get_temporary_path();
  std::string directory_get_desktop_path();
  std::string directory_get_documents_path();
  std::string directory_get_downloads_path();
  std::string directory_get_music_path();
  std::string directory_get_pictures_path();
  std::string directory_get_videos_path();
  std::string executable_get_directory();
  std::string executable_get_filename();
  std::string executable_get_pathname();
  bool symlink_create(std::string fname, std::string newname);
  bool symlink_copy(std::string fname, std::string newname);
  bool symlink_exists(std::string fname);
  bool hardlink_create(std::string fname, std::string newname);
  std::uintmax_t file_numblinks(std::string fname);
  std::uintmax_t file_bin_numblinks(int fd);
  std::string file_bin_hardlinks(int fd, std::string dnames, bool recursive);
  std::string filename_absolute(std::string fname);
  std::string filename_canonical(std::string fname);
  bool filename_equivalent(std::string fname1, std::string fname2);
  bool file_exists(std::string fname);
  bool file_delete(std::string fname);
  bool file_rename(std::string oldname, std::string newname);
  bool file_copy(std::string fname, std::string newname);
  std::uintmax_t file_size(std::string fname);
  bool directory_exists(std::string dname);
  bool directory_create(std::string dname);
  bool directory_destroy(std::string dname);
  bool directory_rename(std::string oldname, std::string newname);
  bool directory_copy(std::string dname, std::string newname);
  std::uintmax_t directory_size(std::string dname);
  unsigned directory_contents_get_order();
  void directory_contents_set_order(unsigned order);
  unsigned directory_contents_get_cntfiles();
  unsigned directory_contents_get_maxfiles();
  void directory_contents_set_maxfiles(unsigned maxfiles);
  std::string directory_contents_first(std::string dname, std::string pattern, bool includedirs, bool recursive);
  void directory_contents_first_async(std::string dname, std::string pattern, bool includedirs, bool recursive);
  unsigned directory_contents_get_length();
  bool directory_contents_get_completion_status();
  void directory_contents_set_completion_status(bool complete);
  std::string directory_contents_next();
  void directory_contents_close();
  std::string environment_get_variable(std::string name);
  bool environment_get_variable_exists(std::string name);
  bool environment_set_variable(std::string name, std::string value);
  bool environment_unset_variable(std::string name);
  std::string environment_expand_variables(std::string str);
  int file_datetime_accessed_year(std::string fname);
  int file_datetime_accessed_month(std::string fname);
  int file_datetime_accessed_day(std::string fname);
  int file_datetime_accessed_hour(std::string fname);
  int file_datetime_accessed_minute(std::string fname);
  int file_datetime_accessed_second(std::string fname);
  int file_datetime_modified_year(std::string fname);
  int file_datetime_modified_month(std::string fname);
  int file_datetime_modified_day(std::string fname);
  int file_datetime_modified_hour(std::string fname);
  int file_datetime_modified_minute(std::string fname);
  int file_datetime_modified_second(std::string fname);
  int file_datetime_created_year(std::string fname);
  int file_datetime_created_month(std::string fname);
  int file_datetime_created_day(std::string fname);
  int file_datetime_created_hour(std::string fname);
  int file_datetime_created_minute(std::string fname);
  int file_datetime_created_second(std::string fname);
  int file_bin_datetime_accessed_year(int fd);
  int file_bin_datetime_accessed_month(int fd);
  int file_bin_datetime_accessed_day(int fd);
  int file_bin_datetime_accessed_hour(int fd);
  int file_bin_datetime_accessed_minute(int fd);
  int file_bin_datetime_accessed_second(int fd);
  int file_bin_datetime_modified_year(int fd);
  int file_bin_datetime_modified_month(int fd);
  int file_bin_datetime_modified_day(int fd);
  int file_bin_datetime_modified_hour(int fd);
  int file_bin_datetime_modified_minute(int fd);
  int file_bin_datetime_modified_second(int fd);
  int file_bin_datetime_created_year(int fd);
  int file_bin_datetime_created_month(int fd);
  int file_bin_datetime_created_day(int fd);
  int file_bin_datetime_created_hour(int fd);
  int file_bin_datetime_created_minute(int fd);
  int file_bin_datetime_created_second(int fd);
  int file_bin_open(std::string fname, int mode);
  int file_bin_rewrite(int fd);
  int file_bin_close(int fd);
  long file_bin_size(int fd);
  long file_bin_position(int fd);
  long file_bin_seek(int fd, long pos);
  int file_bin_read_byte(int fd);
  int file_bin_write_byte(int fd, int byte);
  int file_text_open_read(std::string fname);
  int file_text_open_write(std::string fname);
  int file_text_open_append(std::string fname);
  long file_text_write_real(int fd, double val);
  long file_text_write_string(int fd, std::string str);
  int file_text_writeln(int fd);
  bool file_text_eoln(int fd);
  bool file_text_eof(int fd);
  double file_text_read_real(int fd);
  std::string file_text_read_string(int fd);
  std::string file_text_readln(int fd);
  std::string file_text_read_all(int fd);
  int file_text_open_from_string(std::string str);
  int file_text_close(int fd);

} // namespace ngs::fs
