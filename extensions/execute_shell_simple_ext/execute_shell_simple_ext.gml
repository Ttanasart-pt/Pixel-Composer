#define execute_shell_simple
/// (path, args = "", action = "open", showCmd = 5/*SW_OPEN*/)
var _path = argument[0];
var _args = argument_count > 1 ? argument[1] : "";
var _action = argument_count > 2 ? argument[2] : "open";
var _showCmd = argument_count > 3 ? argument[3] : 5;
return execute_shell_simple_raw(_path, _args, _action, _showCmd)