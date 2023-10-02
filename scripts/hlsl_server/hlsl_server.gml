#region functions
	global.HLSL_FUNCTIONS    = ds_map_create();
	global.HLSL_FUNCTIONS[? "abs"]		= ["x"];
	global.HLSL_FUNCTIONS[? "acos"]		= ["x"];
	global.HLSL_FUNCTIONS[? "asfloat"]	= ["x"];
	global.HLSL_FUNCTIONS[? "asin"]		= ["x"];
	global.HLSL_FUNCTIONS[? "asint"]	= ["x"];
	global.HLSL_FUNCTIONS[? "atan"]		= ["x"];
	global.HLSL_FUNCTIONS[? "atan2"]	= ["y", "x"];
	global.HLSL_FUNCTIONS[? "ceil"]		= ["x"];
	global.HLSL_FUNCTIONS[? "clamp"]	= ["x", "min", "max"];
	global.HLSL_FUNCTIONS[? "clip"]		= ["x"];
	global.HLSL_FUNCTIONS[? "cos"]		= ["x"];
	global.HLSL_FUNCTIONS[? "cosh"]		= ["x"];
	global.HLSL_FUNCTIONS[? "cross"]	= ["x", "y"];
	global.HLSL_FUNCTIONS[? "ddx"]		= ["x"];
	global.HLSL_FUNCTIONS[? "ddy"]		= ["x"];
	global.HLSL_FUNCTIONS[? "degrees"]	= ["x"];
	global.HLSL_FUNCTIONS[? "determinant"]	= ["x"];
	global.HLSL_FUNCTIONS[? "distance"]	= ["x", "y"];
	global.HLSL_FUNCTIONS[? "dot"]		= ["x", "y"];
	global.HLSL_FUNCTIONS[? "exp"]		= ["x"];
	global.HLSL_FUNCTIONS[? "exp2"]		= ["x"];
	global.HLSL_FUNCTIONS[? "faceforward"]	= ["n", "i", "ng"];
	global.HLSL_FUNCTIONS[? "floor"]	= ["x"];
	global.HLSL_FUNCTIONS[? "fma"]		= ["a", "b", "c"];
	global.HLSL_FUNCTIONS[? "fmod"]		= ["x", "y"];
	global.HLSL_FUNCTIONS[? "frac"]		= ["x"];
	global.HLSL_FUNCTIONS[? "frexp"]	= ["x", "exp"];
	global.HLSL_FUNCTIONS[? "fwidth"]	= ["x"];
	global.HLSL_FUNCTIONS[? "isfinite"]	= ["x"];
	global.HLSL_FUNCTIONS[? "isinf"]	= ["x"];
	global.HLSL_FUNCTIONS[? "isnan"]	= ["x"];
	global.HLSL_FUNCTIONS[? "ldexp"]	= ["x", "exp"];
	global.HLSL_FUNCTIONS[? "length"]	= ["x"];
	global.HLSL_FUNCTIONS[? "lerp"]		= ["x", "y", "s"];
	global.HLSL_FUNCTIONS[? "lit"]		= ["n_dot_l", "n_dot_h", "m"];
	global.HLSL_FUNCTIONS[? "log"]		= ["x"];
	global.HLSL_FUNCTIONS[? "log10"]	= ["x"];
	global.HLSL_FUNCTIONS[? "log2"]		= ["x"];
	global.HLSL_FUNCTIONS[? "max"]		= ["x", "y"];
	global.HLSL_FUNCTIONS[? "min"]		= ["x", "y"];
	global.HLSL_FUNCTIONS[? "modf"]		= ["x", "out ip"];
	global.HLSL_FUNCTIONS[? "mul"]		= ["x", "y"];
	global.HLSL_FUNCTIONS[? "noise"]	= ["x"];
	global.HLSL_FUNCTIONS[? "normalize"]= ["x"];
	global.HLSL_FUNCTIONS[? "pow"]		= ["x", "y"];
	global.HLSL_FUNCTIONS[? "radians"]	= ["x"];
	global.HLSL_FUNCTIONS[? "rcp"]		= ["x"];
	global.HLSL_FUNCTIONS[? "reflect"]	= ["i", "n"];
	global.HLSL_FUNCTIONS[? "refract"]	= ["i", "n", "?"];
	global.HLSL_FUNCTIONS[? "round"]	= ["x"];
	global.HLSL_FUNCTIONS[? "rsqrt"]	= ["x"];
	global.HLSL_FUNCTIONS[? "saturate"]	= ["x"];
	global.HLSL_FUNCTIONS[? "sign"]		= ["x"];
	global.HLSL_FUNCTIONS[? "sin"]		= ["x"];
	global.HLSL_FUNCTIONS[? "sincos"]	= ["x", "out s", "out c"];
	global.HLSL_FUNCTIONS[? "sinh"]		= ["x"];
	global.HLSL_FUNCTIONS[? "smoothstep"]= ["min", "max", "x"];
	global.HLSL_FUNCTIONS[? "sqrt"]		= ["x"];
	global.HLSL_FUNCTIONS[? "step"]		= ["y", "x"];
	global.HLSL_FUNCTIONS[? "tan"]		= ["x"];
	global.HLSL_FUNCTIONS[? "tanh"]		= ["x"];
	global.HLSL_FUNCTIONS[? "transpose"]= ["x"];
	global.HLSL_FUNCTIONS[? "trunc"]	= ["x"];
#endregion

global.HLSL_VAR = [ "float", "int", "float2", "float3", "float4", "float3x3", "float4x4", "sampler" ];

function hlsl_document_parser(prompt, node = noone) {
	var params = [];
	var lines = string_split(prompt, "\n");
	
	for( var i = node.input_fix_len, n = ds_list_size(node.inputs); i < n; i += node.data_length ) {
		var _arg_name = node.getInputData(i + 0);
		var _arg_type = node.getInputData(i + 1);
		
		if(_arg_type == 7) {
			array_push(params, [ _arg_name + "Object", "Texture2D" ]);
			array_push(params, [ _arg_name, "SamplerState" ]);
		} else array_push(params, [ _arg_name, array_safe_get(global.HLSL_VAR, _arg_type) ]);
	}
	
	for( var i = 0, n = array_length(lines); i < n; i++ ) {
		var line   = string_trim(lines[i]);
		var _token = string_split(line, " ");
		var _vari  = false;
		var _vart  = "";
		var _vars  = "";
		
		for( var j = 0, m = array_length(_token); j < m; j++ ) {
			if(_vari)
				_vars += _token[j];
			
			if(array_exists(global.HLSL_VAR, _token[j])) {
				_vart = _token[j];
				_vari = true;
			}
		}
		
		_vars = string_replace_all(_vars, ";", "");
		_vars = string_replace_all(_vars, " ", "");
		_vars = string_splice(_vars, ",");
		
		var _varType = [];
		
		for( var j = 0, m = array_length(_vars); j < m; j++ ) {
			var _eq = string_splice(_vars[j], "=");
			_varType[j] = [ _eq[0], _vart ];
		}
		
		params = array_append(params, _varType);
	}
	
	return params;
}

function hlsl_autocomplete_server(prompt, params = []) { 
	var res = [];
	var pr_list = ds_priority_create();
	
	//////////////////////////////////
	ds_priority_clear(pr_list);
	
	for( var i = 0, n = array_length(params); i < n; i++ ) {
		var gl = params[i];
		
		var match = string_partial_match(string_lower(gl[0]), string_lower(prompt));
		if(match == -9999) continue;
		
		ds_priority_add(pr_list, [[THEME.ac_constant, 2], gl[0], gl[1], gl[0]], match);
	}
	
	repeat(ds_priority_size(pr_list))
		array_push(res, ds_priority_delete_max(pr_list));
	
	//////////////////////////////////
	ds_priority_clear(pr_list);
	
	for( var i = 0, n = array_length(global.HLSL_VAR); i < n; i++ ) {
		var gl = global.HLSL_VAR[i];
		
		var match = string_partial_match(string_lower(gl), string_lower(prompt));
		if(match == -9999) continue;
		
		ds_priority_add(pr_list, [[THEME.ac_constant, 3], gl, "var type", gl], match);
	}
	
	repeat(ds_priority_size(pr_list))
		array_push(res, ds_priority_delete_max(pr_list));
	
	//////////////////////////////////
	ds_priority_clear(pr_list);
	
	var F = global.HLSL_FUNCTIONS;
	var _keys = ds_map_keys_to_array(F);
	
	for( var i = 0, n = array_length(_keys); i < n; i++ ) {
		var _key  = _keys[i];
		var match = string_partial_match(string_lower(_key), string_lower(prompt));
		if(match == -9999)
			continue;
		
		ds_priority_add(pr_list, [[THEME.ac_function, 0], _key, "function", _key], match);
	}
	
	repeat(ds_priority_size(pr_list))
		array_push(res, ds_priority_delete_max(pr_list));
		
	ds_priority_destroy(pr_list);
	
	return res;
}

function hlsl_function_guide_server(prompt) { 
	if(!ds_map_exists(global.HLSL_FUNCTIONS, prompt)) return "";
	
	var fn = global.HLSL_FUNCTIONS[? prompt];
	var guide = prompt + "(";
	for( var i = 0, n = array_length(fn); i < n; i++ ) 
		guide += (i? ", " : "") + string(fn[i]);
	guide += ")";
	
	return guide;
}