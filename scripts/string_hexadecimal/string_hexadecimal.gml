function string_hexadecimal(str){
	static HEX = "0123456789abcdef";
	
	var i = string_length(str);
	var d = 1;
	var v = 0;
	
	while(i > 0) {
		var ch = string_char_at(str, i);
		var val = string_pos(ch, HEX) - 1;
		v += val * d;
		
		d *= 16;
		i--;
	}
	
	return v;
}

function number_to_hex(val) {
	static HEX = "0123456789ABCDEF";
	var ss = "";
	while(val > 0) {
		var i = val % 16;
		ss  = string_char_at(HEX, i + 1) + ss;
		val = floor(val / 16);
	}
	while(string_length(ss) < 2) {
		ss = "0" + ss;	
	}
	
	return ss;
}

function color_get_alpha(color) {
	return (color & (0xFF << 24)) >> 24;
}

function color_get_hex(color, alpha = false) {
	var r = color_get_red(color);
	var g = color_get_green(color);
	var b = color_get_blue(color);
	var a = color_get_alpha(color);
		
	var hex = number_to_hex(r) + number_to_hex(g) + number_to_hex(b) + (alpha? " " + number_to_hex(a) : "");
	return hex;
}

function color_from_rgb(str) {
	var _r = string_hexadecimal(string_copy(str, 1, 2));
	var _g = string_hexadecimal(string_copy(str, 3, 2));
	var _b = string_hexadecimal(string_copy(str, 5, 2));
		
	return make_color_rgb(_r, _g, _b);
}