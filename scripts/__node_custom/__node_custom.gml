function Node_create_Custom(_x, _y, _group = noone, _param = {}) {
	if(!struct_has(_param, "path")) return noone;
	
	var node = new Node_Custom(_x, _y, _group);
	if(!node.setPath(_param.path)) return noone;
	return node;
}

function Node_create_Custom_path(_x, _y, path) {
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_Custom(_x, _y, PANEL_GRAPH.getCurrentContext());
	if(!node.setPath(path)) return noone;
	return node;	
}

function Node_Custom(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Custom";
	path = "";
	info = {};
	shader = {
		vs: noone,
		fs: noone,
	};
	
	input_index_map  = ds_map_create();
	output_index_map = ds_map_create();
	
	surface_in_index  = 0;
	surface_out_index = 0;
	
	static setPath = function(_path) {
		var _info = _path + "/info.json";
		if(!file_exists_empty(_info)) return false;
		
		info = json_load_struct(_info);
		path = _path;
		name = info.name;
		setDisplayName(name);
		
		shader.vs = d3d11_shader_compile_vs($"{path}/{info.shader_vs}", "main", "vs_4_0");
		if(!d3d11_shader_exists(shader.vs)) noti_warning(d3d11_get_error_string());
			
		shader.fs = d3d11_shader_compile_ps($"{path}/{info.shader_fs}", "main", "ps_4_0");
		if(!d3d11_shader_exists(shader.fs)) noti_warning(d3d11_get_error_string());
		
		ds_list_clear(inputs);
		ds_list_clear(outputs);
		
		for( var i = 0, n = array_length(info.inputs); i < n; i++ ) {
			var _input = info.inputs[i];
			inputs[| i] = nodeValue(_input.name, self, JUNCTION_CONNECT.input, value_type_from_string(_input.type), _input.value)
							.setVisible(_input.show_in_inspector, _input.show_in_graph);
			input_index_map[? _input.name] = i;
			
			for( var j = 0, m = array_length(_input.flags); j < m; j++ ) {
				switch(_input.flags[j]) {
					case "SURFACE_IN" : surface_in_index = i; break;
				}
			}
		}
		
		for( var i = 0, n = array_length(info.outputs); i < n; i++ ) {
			var _output = info.outputs[i];
			outputs[| i] = nodeValue(_output.name, self, JUNCTION_CONNECT.output, value_type_from_string(_output.type), _output.value)
							.setVisible(_output.show_in_graph);
			output_index_map[? _output.name] = i;
			
			for( var j = 0, m = array_length(_output.flags); j < m; j++ ) {
				switch(_output.flags[j]) {
					case "SURFACE_OUT" : surface_out_index = i; break;
				}
			}
		}
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		if(!d3d11_shader_exists(shader.vs)) return noone;
		if(!d3d11_shader_exists(shader.fs)) return noone;
		
		var _surf = _data[surface_in_index];
		_output   = surface_verify(_output, surface_get_width_safe(_surf), surface_get_height_safe(_surf));
		
		surface_set_target(_output);
		DRAW_CLEAR
		
		d3d11_shader_override_vs(shader.vs);
		d3d11_shader_override_ps(shader.fs);
		
		var uTypes = array_create(8, 0);
		var sampler_slot = 1;
		
		d3d11_cbuffer_begin();
		var _buffer = buffer_create(1, buffer_grow, 1);
		var _cbSize = 0;
		
		for( var i = 0, n = array_length(info.uniforms); i < n; i++ ) {
			var _u     = info.uniforms[i];
			var _index = input_index_map[? _u.input_name];
			
			var _uname = _u.name;
			var _utype = _u.type;
			var _value = _data[_index];
			
			switch(_utype) {
				case 1 : 
					d3d11_cbuffer_add_int(1); 
					_cbSize++;
					
					buffer_write(_buffer, buffer_s32, _value);
					break;
				case 0 : 
					d3d11_cbuffer_add_float(1); 
					_cbSize++;
					
					buffer_write(_buffer, buffer_f32, _value);
					break;
				case 2 : 
				case 3 : 
				case 4 : 
				case 5 : 
				case 6 : 
					if(is_array(_value)) {
						d3d11_cbuffer_add_float(array_length(_value)); 
						_cbSize += array_length(_value);
						
						for( var j = 0, m = array_length(_value); j < m; j++ ) 
							buffer_write(_buffer, buffer_f32, _value[j]);
					}
					break;
				case 8 : 
					var _clr = colToVec4(_value);
					d3d11_cbuffer_add_float(4);
					_cbSize += 4;
					
					for( var j = 0, m = 4; j < m; j++ ) 
						buffer_write(_buffer, buffer_f32, _clr[i]);
					break;
				case 7 : 
					if(is_surface(_value))
						d3d11_texture_set_stage_ps(sampler_slot, surface_get_texture(_value));
					sampler_slot++;
					break;
			}
		}
		
		d3d11_cbuffer_add_float(4 - _cbSize % 4);
		var cbuff = d3d11_cbuffer_end();
		d3d11_cbuffer_update(cbuff, _buffer);
		buffer_delete(_buffer);
		
		d3d11_shader_set_cbuffer_ps(10, cbuff);

		matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, 
			surface_get_width_safe(_surf), surface_get_height_safe(_surf), 1));
		vertex_submit(global.HLSL_VB, pr_trianglestrip, surface_get_texture(_surf));
		matrix_set(matrix_world, matrix_build_identity());
		
		d3d11_shader_override_vs(-1);
		d3d11_shader_override_ps(-1);
		surface_reset_target();
		
		return _output;
	} #endregion
}

function __initNodeCustom(list) { #region
	var root = DIRECTORY + "Nodes";
	directory_verify(root);
	
	root += "/Custom";
	directory_verify(root);
	
	if(check_version($"{root}/version"))
		zip_unzip("data/Nodes.zip", root);
		
	var f = file_find_first(root + "/*", fa_directory);
		
	while (f != "") {
		var _dir_raw = $"{root}/{f}";
		f = file_find_next();
		
		if(!directory_exists(_dir_raw)) continue;
		
		var _dir  = _dir_raw + "/";
		var _info = json_load_struct(_dir + "info.json");
		if(_info == noone) continue;
		
		var _spr  = sprite_add_center(_dir + _info.icon);
		var _n	  = new NodeObject(_info.name, _spr, "Node_Custom", [ 0, Node_create_Custom, { path: _dir_raw } ], _info.tags);
		_n.tooltip = _info.tooltip;
		
		var _tol = _dir + _info.tooltip_spr;
		if(file_exists_empty(_tol)) _n.tooltip_spr = sprite_add(_tol, 0, false, false, 0, 0);
		
		ds_list_add(list, _n);
				
		if(_info.category != noone) {
			var _cat = _info.location[0];
			var _grp = _info.location[1];
			var _ins = true;
			
			for( var i = 0, n = ds_list_size(NODE_CATEGORY); i < n; i++ ) {
				if(NODE_CATEGORY[| i].name != _cat) continue;
				var _list  = NODE_CATEGORY[| i].list;
				var j = 0;
						
				for( var m = ds_list_size(_list); j < m; j++ )
					if(_list[| j] == _grp) break;
						
				ds_list_insert(_list, j + 1, _n);
				_ins = false;
				break;
			}
			
			if(_ins) {
				ds_list_add(_list, _grp);
				ds_list_add(_list, _n);
			}
		}
	}
	file_find_close();
} #endregion