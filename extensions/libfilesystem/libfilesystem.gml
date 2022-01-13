#define get_temp_directory
if (os_type == os_windows) {
  if (directory_exists(environment_get_variable("TMP"))) {
    return filename_absolute(environment_get_variable("TMP"));
  }
  if (directory_exists(environment_get_variable("TEMP"))) {
    return filename_absolute(environment_get_variable("TEMP"));
  }
  if (directory_exists(environment_get_variable("USERPROFILE"))) {
    return filename_absolute(environment_get_variable("USERPROFILE"));
  }
  return filename_absolute(environment_get_variable("WINDIR"));
} else {
  if (directory_exists(environment_get_variable("TMPDIR"))) {
    return filename_absolute(environment_get_variable("TMPDIR"));
  }
  if (directory_exists(environment_get_variable("TMP"))) {
    return filename_absolute(environment_get_variable("TMP"));
  }
  if (directory_exists(environment_get_variable("TEMP"))) {
    return filename_absolute(environment_get_variable("TEMP"));
  }
  if (directory_exists(environment_get_variable("TEMPDIR"))) {
    return filename_absolute(environment_get_variable("TEMPDIR"));
  }
  return "/tmp/";
}

#define generate_working_directory
// generate_working_directory() - Call this Function at Game Start
// Sets get_working_directory() to Mac App Bundle Resources Folder

if (os_type != os_macosx) { return true; }

success = false; 
exe_pname = get_program_directory();             // = "/Path/To/YourAppBundle.app/Contents/MacOS/";
macos_dname = filename_dir(exe_pname);           // = "/Path/To/YourAppBundle.app/Contents/MacOS";
macos_bname = filename_name(macos_dname);        // = "MacOS";
contents_dname = filename_dir(macos_dname);      // = "/Path/To/YourAppBundle.app/Contents";
contents_bname = filename_name(contents_dname);  // = "Contents";
app_dname = filename_dir(contents_dname);        // = "/Path/To/YourAppBundle.app";
app_ename = filename_ext(app_dname);             // = ".app";
contents_pname = filename_path(macos_dname);     // = "/Path/To/YourAppBundle.app/Contents/";
resources_pname = contents_pname + "Resources/"; // = "/Path/To/YourAppBundle.app/Contents/Resources/";

// if running from the IDE change working directory to:
if (directory_exists(game_save_id + "/game/assets/")) {
  success = set_working_directory(game_save_id + "/game/assets/");
} // if "/Path/To/YourAppBundle.app/Contents/MacOS/YourExe" and "/Path/To/YourAppBundle.app/Contents/Resources/" exists
else if (macos_bname == "MacOS" && contents_bname == "Contents" && app_ename == ".app" && directory_exists(resources_pname)) {
  // set working directory to "/Path/To/YourAppBundle.app/Contents/Resources/" and allow loading normal included files
  success = set_working_directory(resources_pname);
}

return success;