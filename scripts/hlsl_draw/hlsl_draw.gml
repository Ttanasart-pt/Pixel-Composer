global.glsl_reserved = ds_map_create();
global.glsl_constant = ds_map_create();

var reserved = ["int", "float", "float2", "float3", "float4", "float3x3", "float4x4", "Texture2D", "SamplerState", "uniform",
				"gl_position", "gm_Matrices", "gl_FragColor", "gm_BaseTexture", 
				"and", "break", "do", "else", "end", "false", 
				"for", "function", "if", "in", "local", "nil", "not", 
				"or", "repeat", "return", "then", "true", "until", "while"];

for( var i = 0, n = array_length(reserved); i < n; i++ )
	global.glsl_reserved[? reserved[i]] = 1;
	
var constant = ["MATRIX_VIEW", "MATRIX_PROJECTION", "MATRIX_WORLD", "MATRIX_WORLD_VIEW", "MATRIX_WORLD_VIEW_PROJECTION" ];

for( var i = 0, n = array_length(constant); i < n; i++ )
	global.glsl_constant[? constant[i]] = 1;

global.HLSL_BREAK_TOKEN = [" ", "(", ")", "[", "]", "{", "}", ".", ",", ";", "+", "-", "*", "/", "^", "="];

function hlsl_token_splice(str) {
	var st = [];
	var ss = str;
	var sp;
	var cc;
	
	do {
		sp = 999999;
		for( var i = 0, n = array_length(global.HLSL_BREAK_TOKEN); i < n; i++ ) {
			var _pos = string_pos(global.HLSL_BREAK_TOKEN[i], ss);
			if(_pos != 0) sp = min(sp, _pos);
		}
		
		if(sp == 999999) { //no delim left
			array_push(st, ss);
			break;
		}
		
		var _ss = string_copy(ss, 1, sp - 1);
		array_push(st, _ss);
		
		cc = string_char_at(ss, sp);
		array_push(st, cc);
		
		ss = string_copy(ss, sp + 1, string_length(ss) - sp);
	} until(sp == 0);
	
	return st;
}

function draw_code_hlsl(_x, _y, str) {
	var tx = _x;
	var ty = _y;
	var words = hlsl_token_splice(str);
	
	for( var j = 0; j < array_length(words); j++ ) {
		var word = words[j];
		var wordNoS = string_trim(word);
		
		draw_set_color(COLORS._main_text);
		
		if(word == "(" || word == ")" || word == "[" || word == "]" || word == "{" || word == "}")
			draw_set_color(COLORS.lua_highlight_bracklet);
		else if(ds_map_exists(global.glsl_reserved, word))
			draw_set_color(COLORS.lua_highlight_keyword);
		else if(wordNoS == string_decimal(wordNoS) || ds_map_exists(global.glsl_constant, word))
			draw_set_color(COLORS.lua_highlight_number);
		else if(j < array_length(words) - 1) {
			if(words[j + 1] == "(") draw_set_color(COLORS.lua_highlight_function);
		}
		
		draw_text_add(tx, ty, word);
		tx += string_width(word);
	}
}