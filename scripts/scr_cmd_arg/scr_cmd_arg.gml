/// @param string
function scr_cmd_arg(argument0) {
	var s = argument0;
	if (string_pos(" ", s)) {
		return @'"' + s + @'"';
	} else return s;
}