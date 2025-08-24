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

#if defined(_WIN32)
#define EXPORTED_FUNCTION extern "C" __declspec(dllexport)
#else /* macOS, Linux, and BSD */
#define EXPORTED_FUNCTION extern "C" __attribute__((visibility("default")))
#endif

EXPORTED_FUNCTION char *directory_get_current_working();
EXPORTED_FUNCTION double directory_set_current_working(char *dname);
EXPORTED_FUNCTION char *directory_get_temporary_path();
EXPORTED_FUNCTION char *directory_get_desktop_path();
EXPORTED_FUNCTION char *directory_get_documents_path();
EXPORTED_FUNCTION char *directory_get_downloads_path();
EXPORTED_FUNCTION char *directory_get_music_path();
EXPORTED_FUNCTION char *directory_get_pictures_path();
EXPORTED_FUNCTION char *directory_get_videos_path();
EXPORTED_FUNCTION char *executable_get_directory();
EXPORTED_FUNCTION char *executable_get_filename();
EXPORTED_FUNCTION char *executable_get_pathname();
EXPORTED_FUNCTION double symlink_create(char *fname, char *newname);
EXPORTED_FUNCTION double symlink_copy(char *fname, char *newname);
EXPORTED_FUNCTION double symlink_exists(char *fname);
EXPORTED_FUNCTION double hardlink_create(char *fname, char *newname);
EXPORTED_FUNCTION double file_numblinks(char *fname);
EXPORTED_FUNCTION double file_bin_numblinks(double fd);
EXPORTED_FUNCTION char *file_bin_hardlinks(double fd, char *dnames, double recursive);
EXPORTED_FUNCTION char *filename_absolute(char *fname);
EXPORTED_FUNCTION char *filename_canonical(char *fname);
EXPORTED_FUNCTION double filename_equivalent(char *fname1, char *fname2);
EXPORTED_FUNCTION double file_exists(char *fname);
EXPORTED_FUNCTION double file_delete(char *fname);
EXPORTED_FUNCTION double file_rename(char *oldname, char *newname);
EXPORTED_FUNCTION double file_copy(char *fname, char *newname);
EXPORTED_FUNCTION double file_size(char *fname);
EXPORTED_FUNCTION double directory_exists(char *dname);
EXPORTED_FUNCTION double directory_create(char *dname);
EXPORTED_FUNCTION double directory_destroy(char *dname);
EXPORTED_FUNCTION double directory_rename(char *oldname, char *newname);
EXPORTED_FUNCTION double directory_copy(char *dname, char *newname);
EXPORTED_FUNCTION double directory_size(char *dname);
EXPORTED_FUNCTION double directory_contents_close();
EXPORTED_FUNCTION double directory_contents_get_order();
EXPORTED_FUNCTION double directory_contents_set_order(double order);
EXPORTED_FUNCTION double directory_contents_get_cntfiles();
EXPORTED_FUNCTION double directory_contents_get_maxfiles();
EXPORTED_FUNCTION double directory_contents_set_maxfiles(double order);
EXPORTED_FUNCTION char *directory_contents_first(char *dname, char *pattern, double includedirs, double recursive);
EXPORTED_FUNCTION double directory_contents_first_async(char *dname, char *pattern, double includedirs, double recursive);
EXPORTED_FUNCTION double directory_contents_get_length();
EXPORTED_FUNCTION double directory_contents_get_completion_status();
EXPORTED_FUNCTION double directory_contents_set_completion_status(double complete);
EXPORTED_FUNCTION char *directory_contents_next();
EXPORTED_FUNCTION char *environment_get_variable(char *name);
EXPORTED_FUNCTION double environment_get_variable_exists(char *name);
EXPORTED_FUNCTION double environment_set_variable(char *name, char *value);
EXPORTED_FUNCTION double environment_unset_variable(char *name);
EXPORTED_FUNCTION char *environment_expand_variables(char *str);
EXPORTED_FUNCTION double file_datetime_accessed_year(char *fname);
EXPORTED_FUNCTION double file_datetime_accessed_month(char *fname);
EXPORTED_FUNCTION double file_datetime_accessed_day(char *fname);
EXPORTED_FUNCTION double file_datetime_accessed_hour(char *fname);
EXPORTED_FUNCTION double file_datetime_accessed_minute(char *fname);
EXPORTED_FUNCTION double file_datetime_accessed_second(char *fname);
EXPORTED_FUNCTION double file_datetime_modified_year(char *fname);
EXPORTED_FUNCTION double file_datetime_modified_month(char *fname);
EXPORTED_FUNCTION double file_datetime_modified_day(char *fname);
EXPORTED_FUNCTION double file_datetime_modified_hour(char *fname);
EXPORTED_FUNCTION double file_datetime_modified_minute(char *fname);
EXPORTED_FUNCTION double file_datetime_modified_second(char *fname);
EXPORTED_FUNCTION double file_datetime_created_year(char *fname);
EXPORTED_FUNCTION double file_datetime_created_month(char *fname);
EXPORTED_FUNCTION double file_datetime_created_day(char *fname);
EXPORTED_FUNCTION double file_datetime_created_hour(char *fname);
EXPORTED_FUNCTION double file_datetime_created_minute(char *fname);
EXPORTED_FUNCTION double file_datetime_created_second(char *fname);
EXPORTED_FUNCTION double file_bin_datetime_accessed_year(double fd);
EXPORTED_FUNCTION double file_bin_datetime_accessed_month(double fd);
EXPORTED_FUNCTION double file_bin_datetime_accessed_day(double fd);
EXPORTED_FUNCTION double file_bin_datetime_accessed_hour(double fd);
EXPORTED_FUNCTION double file_bin_datetime_accessed_minute(double fd);
EXPORTED_FUNCTION double file_bin_datetime_accessed_second(double fd);
EXPORTED_FUNCTION double file_bin_datetime_modified_year(double fd);
EXPORTED_FUNCTION double file_bin_datetime_modified_month(double fd);
EXPORTED_FUNCTION double file_bin_datetime_modified_day(double fd);
EXPORTED_FUNCTION double file_bin_datetime_modified_hour(double fd);
EXPORTED_FUNCTION double file_bin_datetime_modified_minute(double fd);
EXPORTED_FUNCTION double file_bin_datetime_modified_second(double fd);
EXPORTED_FUNCTION double file_bin_datetime_created_year(double fd);
EXPORTED_FUNCTION double file_bin_datetime_created_month(double fd);
EXPORTED_FUNCTION double file_bin_datetime_created_day(double fd);
EXPORTED_FUNCTION double file_bin_datetime_created_hour(double fd);
EXPORTED_FUNCTION double file_bin_datetime_created_minute(double fd);
EXPORTED_FUNCTION double file_bin_datetime_created_second(double fd);
EXPORTED_FUNCTION double file_bin_open(char *fname, double mode);
EXPORTED_FUNCTION double file_bin_rewrite(double fd);
EXPORTED_FUNCTION double file_bin_close(double fd);
EXPORTED_FUNCTION double file_bin_size(double fd);
EXPORTED_FUNCTION double file_bin_position(double fd);
EXPORTED_FUNCTION double file_bin_seek(double fd, double pos);
EXPORTED_FUNCTION double file_bin_read_byte(double fd);
EXPORTED_FUNCTION double file_bin_write_byte(double fd, double byte);
EXPORTED_FUNCTION double file_text_open_read(char *fname);
EXPORTED_FUNCTION double file_text_open_write(char *fname);
EXPORTED_FUNCTION double file_text_open_append(char *fname);
EXPORTED_FUNCTION double file_text_write_real(double fd, double val);
EXPORTED_FUNCTION double file_text_write_string(double fd, char *str);
EXPORTED_FUNCTION double file_text_writeln(double fd);
EXPORTED_FUNCTION double file_text_eoln(double fd);
EXPORTED_FUNCTION double file_text_eof(double fd);
EXPORTED_FUNCTION double file_text_read_real(double fd);
EXPORTED_FUNCTION char *file_text_read_string(double fd);
EXPORTED_FUNCTION char *file_text_readln(double fd);
EXPORTED_FUNCTION char *file_text_read_all(double fd); 
EXPORTED_FUNCTION double file_text_open_from_string(char *str);
EXPORTED_FUNCTION double file_text_close(double fd);
