function string_hexadecimal(str) {
	static HEX = "0123456789ABCDEF";
	
	var i = string_length(str);
	var d = 1;
	var v = 0;
	
	while(i > 0) {
		var ch  = string_char_at(str, i);
		var val = string_pos(string_upper(ch), HEX) - 1;
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

function color_get_hex(color, alpha = true) {
	var arr = is_array(color) && array_length(color) == 4;
	var r   = arr? round(color[0] * 256) : color_get_red(color);
	var g   = arr? round(color[1] * 256) : color_get_green(color);
	var b   = arr? round(color[2] * 256) : color_get_blue(color);
	var a   = arr? round(color[3] * 256) : color_get_alpha(color);
	
	return number_to_hex(r) + number_to_hex(g) + number_to_hex(b) + (alpha && is_int64(color)? number_to_hex(a) : "");
}

function color_from_rgb(str) {
	if(!is_string(str)) return str;
	if(string_length(str) < 6) return -1;
	
	var _r = string_hexadecimal(string_copy(str, 1, 2));
	var _g = string_hexadecimal(string_copy(str, 3, 2));
	var _b = string_hexadecimal(string_copy(str, 5, 2));
	
	if(string_length(str) == 8) {
		var _a = string_hexadecimal(string_copy(str, 7, 2));
		return make_color_rgba(_r, _g, _b, _a);
	}
	
	return make_color_rgb(_r, _g, _b);
}

function colorFromHex(hex) {
	if(string_length(hex) != 6) return 0;
	
	var rr = string_hexadecimal(string_copy(hex, 1, 2));
	var gg = string_hexadecimal(string_copy(hex, 3, 2));
	var bb = string_hexadecimal(string_copy(hex, 5, 2));
	
	return make_color_rgb(rr, gg, bb);
}