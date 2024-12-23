global.NODE_SUB_CATAG = [ "input", "output" ];
global.PCX_CONSTANT = [ "value", "self" ];

function pxl_document_parser(prompt) {
	var params = [];
	var lines  = string_split(prompt, "\n");
	
	for( var i = 0, n = array_length(lines); i < n; i++ ) {
		var line = lines[i];
		line = functionStringClean(line);
		
		var eq = string_split(line, "=");
		
		if(array_length(eq) > 1) {
			for( var j = 0; j < array_length(eq) - 1; j++ )
				array_push_unique(params, string_trim(eq[j]));
		}
	}
	
	return params;
}

function pxl_autocomplete_server_node(prompt, pr_list) {
	var sp = string_splice(prompt, ".");
	if(array_length(sp) <= 1) return;
	
	if(struct_has(PROJECT_VARIABLES, sp[0])) {
		var _glo_var = PROJECT_VARIABLES[$ sp[0]];
		var _arr     = variable_struct_get_names(_glo_var);
		
		for( var i = 0, n = array_length(_arr); i < n; i++ ) {
			var _key = _arr[i];
			var match = string_partial_match(string_lower(_key), string_lower(sp[1]));
			if(match == -9999 && sp[1] != "")
				continue;
			
			ds_priority_add(pr_list, [[THEME.ac_constant, 0], _key, sp[0], $"{sp[0]}.{_key}"], match);
		}
		
	} 
	
	if(sp[0] == "self" && array_length(sp) == 2) {
		var _val = context[$ "node_values"];
		var _arr = variable_struct_get_names(_val);
		
		for( var i = 0, n = array_length(_arr); i < n; i++ ) {
			var _key = _arr[i];
			var match = string_partial_match(string_lower(_key), string_lower(sp[1]));
			if(match == -9999 && sp[1] != "")
				continue;
			
			ds_priority_add(pr_list, [[THEME.ac_constant, 2], _key, "self", $"{sp[0]}.{_key}"], match);
		}
		
	} 
	
	if(ds_map_exists(PROJECT.nodeNameMap, sp[0])) {
		if(array_length(sp) == 2) {
			for( var i = 0, n = array_length(global.NODE_SUB_CATAG); i < n; i++ ) {
				var gl = global.NODE_SUB_CATAG[i];
				
				var match = string_partial_match(string_lower(gl), string_lower(sp[1]));
				if(match == -9999 && sp[1] != "") continue;
	
				ds_priority_add(pr_list, [[THEME.ac_node, i], gl, sp[0], $"{sp[0]}.{gl}"], match);
			}
			
		} else if(array_length(sp) == 3) {
			var node = PROJECT.nodeNameMap[? sp[0]];
			var F    = noone;
			var tag  = "";
			
			switch(string_lower(sp[1])) {
				case2_mf0/* */"inputs" case2_mf1   "input" case2_mf2  : tag = "input";  F = node.inputMap;  break;
				case2_mf0/* */"outputs" case2_mf1  "output" case2_mf2 : tag = "output"; F = node.outputMap; break;
			}
			
			if(!is_struct(F)) return;
			
			var ks = struct_get_names(F);
			for( var i = 0, n = array_length(ks); i < n; i++ ) {
				var k = ks[i];
				var match = string_partial_match(string_lower(k), string_lower(sp[2]));
				if(match == -9999 && sp[2] != "") continue;
				
				var fn = F[$ k];
				ds_priority_add(pr_list, [fn.junction_drawing, k, $"{sp[0]}.{tag}", $"{sp[0]}.{sp[1]}.{k}"], match);
			}
		}
	}
}

function pxl_autocomplete_server(prompt, params = [], context = {}) { 
	if(isNumber(prompt)) return [];
	
	var res = [];
	if(string_trim(prompt) == "") return res;
	
	var pr_list = ds_priority_create();
	
	//////////////////////////////////
	ds_priority_clear(pr_list);
	
	for( var i = 0, n = array_length(global.PCX_CONSTANT); i < n; i++ ) {
		var gl = global.PCX_CONSTANT[i];
		
		var match = string_partial_match(string_lower(gl), string_lower(prompt));
		if(match == -9999) continue;
		
		ds_priority_add(pr_list, [[THEME.ac_constant, 2], gl, "local", gl], match);
	}
	
	repeat(ds_priority_size(pr_list))
		array_push(res, ds_priority_delete_max(pr_list));
	
	//////////////////////////////////
	ds_priority_clear(pr_list);
	
	for( var i = 0, n = array_length(params); i < n; i++ ) {
		var gl = params[i];
		
		var match = string_partial_match(string_lower(gl), string_lower(prompt));
		if(match == -9999) continue;
		
		ds_priority_add(pr_list, [[THEME.ac_constant, 2], gl, "local", gl], match);
	}
	
	repeat(ds_priority_size(pr_list))
		array_push(res, ds_priority_delete_max(pr_list));
	
	//////////////////////////////////
	ds_priority_clear(pr_list);
	
	var _arr = variable_struct_get_names(PROJECT_VARIABLES);
	for( var i = 0, n = array_length(_arr); i < n; i++ ) {
		var gl = _arr[i];
		
		var match = string_partial_match(string_lower(gl), string_lower(prompt));
		if(match == -9999) continue;
		
		ds_priority_add(pr_list, [[THEME.ac_constant, 0], gl, "global", gl], match);
	}
	
	repeat(ds_priority_size(pr_list))
		array_push(res, ds_priority_delete_max(pr_list));
		
	//////////////////////////////////
	ds_priority_clear(pr_list);
	
	var F = PROJECT.globalNode.value;
	var k = ds_map_find_first(F);
	var a = ds_map_size(F);
	repeat(a) {
		var match = string_partial_match(string_lower(k), string_lower(prompt));
		if(match == -9999) {
			k = ds_map_find_next(F, k);
			continue;
		}
		
		var fn = F[? prompt];
		ds_priority_add(pr_list, [[THEME.ac_constant, 0], k, "global", k], match);
		k = ds_map_find_next(F, k);
	}
	
	repeat(ds_priority_size(pr_list))
		array_push(res, ds_priority_delete_max(pr_list));
		
	//////////////////////////////////
	ds_priority_clear(pr_list);
	
	pxl_autocomplete_server_node(prompt, pr_list);
	
	repeat(ds_priority_size(pr_list))
		array_push(res, ds_priority_delete_max(pr_list));
		
	//////////////////////////////////
	ds_priority_clear(pr_list);
	
	var F = PROJECT.nodeNameMap;
	var k = ds_map_find_first(F);
	var a = ds_map_size(F);
	repeat(a) {
		var match = string_partial_match(string_lower(k), string_lower(prompt));
		if(match == -9999) {
			k = ds_map_find_next(F, k);
			continue;
		}
		
		var fn = F[? prompt];
		ds_priority_add(pr_list, [[THEME.ac_constant, 1], k, "node", k], match);
		k = ds_map_find_next(F, k);
	}
	
	repeat(ds_priority_size(pr_list))
		array_push(res, ds_priority_delete_max(pr_list));
		
	//////////////////////////////////
	ds_priority_clear(pr_list);
	
	var F = global.PCX_FUNCTIONS;
	var _keys = ds_map_keys_to_array(F);
	
	for( var i = 0, n = array_length(_keys); i < n; i++ ) {
		var _key = _keys[i];
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

function pxl_function_guide_server(prompt) { 
	if(!ds_map_exists(global.PCX_FUNCTIONS, prompt)) return "";
	
	var fn = global.PCX_FUNCTIONS[? prompt];
	var guide = prompt + "(";
	for( var i = 0, n = array_length(fn[0]); i < n; i++ ) 
		guide += (i? ", " : "") + string(fn[0][i]);
	guide += ")";
	
	return guide;
}