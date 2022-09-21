#define generate_working_directory
// generate_working_directory() - Call this Function at Game Start
// Sets directory_get_current_working() to Ubuntu (Linux) Assets SubFolder
// Sets directory_get_current_working() to Mac App Bundle Resources Folder

if (os_type == os_linux)  { return directory_set_current_working(directory_get_current_working() + "/assets/"); }
if (os_type != os_macosx) { return true; }

success = false; 
exe_pname = executable_get_directory();          // = "/Path/To/YourAppBundle.app/Contents/MacOS/";
macos_dname = filename_dir(exe_pname);           // = "/Path/To/YourAppBundle.app/Contents/MacOS";
macos_bname = filename_name(macos_dname);        // = "MacOS";
contents_dname = filename_dir(macos_dname);      // = "/Path/To/YourAppBundle.app/Contents";
contents_bname = filename_name(contents_dname);  // = "Contents";
app_dname = filename_dir(contents_dname);        // = "/Path/To/YourAppBundle.app";
app_ename = filename_ext(app_dname);             // = ".app";
contents_pname = filename_path(macos_dname);     // = "/Path/To/YourAppBundle.app/Contents/";
resources_pname = contents_pname + "Resources/"; // = "/Path/To/YourAppBundle.app/Contents/Resources/";

// if running from the IDE change working directory to:
if (directory_exists(filename_path(parameter_string(1)))) {
  success = directory_set_current_working(filename_path(parameter_string(1)));
} // if "/Path/To/YourAppBundle.app/Contents/MacOS/YourExe" and "/Path/To/YourAppBundle.app/Contents/Resources/" exists
else if (macos_bname == "MacOS" && contents_bname == "Contents" && app_ename == ".app" && directory_exists(resources_pname)) {
  // set working directory to "/Path/To/YourAppBundle.app/Contents/Resources/" and allow loading normal included files
  success = directory_set_current_working(resources_pname);
}

return success;