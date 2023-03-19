function Node_Camera(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Camera";
	preview_alpha = 0.5;
	
	shader = sh_camera;
	uni_backg   = shader_get_sampler_index(shader, "backg");
	uni_scene   = shader_get_sampler_index(shader, "scene");
	uni_dim_scn = shader_get_uniform(shader, "scnDimension");
	uni_dim_cam = shader_get_uniform(shader, "camDimension");
	uni_pos     = shader_get_uniform(shader, "position");
	uni_zom     = shader_get_uniform(shader, "zoom");
	uni_sam_mod = shader_get_uniform(shader, "sampleMode");
	uni_blur    = shader_get_uniform(shader, "blur");
	uni_fix_bg  = shader_get_uniform(shader, "fixBG");
	
	inputs[| 0] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue("Focus area", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 16, 16, 4, 4, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area, function() { return getDimension(0); });
	
	inputs[| 2] = nodeValue("Zoom", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0.01, 4, 0.01 ]);
	
	inputs[| 3] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
	
	inputs[| 4] = nodeValue("Fix background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Surface",	  true], 0, 3, 4, 
		["Camera",	 false], 1, 2,
		["Elements",  true], 
	];
	
	attribute_surface_depth();

	input_display_len = array_length(input_display_list);
	input_fix_len	= ds_list_size(inputs);
	data_length		= 2;
	
	function createNewInput() {
		var index = ds_list_size(inputs);
		var _s    = floor((index - input_fix_len) / data_length);
		
		inputs[| index + 0] = nodeValue("Element " + string(_s), self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
		
		inputs[| index + 1] = nodeValue("Parallax " + string(_s), self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ] )
			.setDisplay(VALUE_DISPLAY.vector)
			.setUnitRef(function(index) { return getDimension(index); });
		
		array_push(input_display_list, index + 0);
		array_push(input_display_list, index + 1);
	}
	if(!LOADING && !APPENDING) createNewInput();
	
	static refreshDynamicInput = function() {
		var _in = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			ds_list_add(_in, inputs[| i]);
		
		array_resize(input_display_list, input_display_len);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			if(inputs[| i].value_from) {
				ds_list_add(_in, inputs[| i + 0]);
				ds_list_add(_in, inputs[| i + 1]);
				
				array_push(input_display_list, i + 0);
				array_push(input_display_list, i + 1);
			} else {
				delete inputs[| i + 0];
				delete inputs[| i + 1];
			}
		}
		
		for( var i = 0; i < ds_list_size(_in); i++ )
			_in[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _in;
		
		createNewInput();
	}
	
	static onValueFromUpdate = function(index) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	}
	
	static getPreviewValue = function() { return inputs[| 0]; }
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(array_length(current_data) == 0) return;
		
		var _out = outputs[| 0].getValue();
		var _area = current_data[1];
		var _zoom = current_data[2];
		
		var _px = _x + (_area[0] - _area[2] * _zoom) * _s;
		var _py = _y + (_area[1] - _area[3] * _zoom) * _s;
		
		draw_surface_ext_safe(_out, _px, _py, _s * _zoom, _s * _zoom);
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		draw_set_color(COLORS._main_accent);
		var x0 = _px;
		var y0 = _py;
		var x1 = x0 + _area[2] * 2 * _zoom * _s;
		var y1 = y0 + _area[3] * 2 * _zoom * _s;
		
		draw_rectangle_dashed(x0, y0, x1, y1);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		if(!is_surface(_data[0])) return;
		var _area = _data[1];
		var _zoom = _data[2];
		var _samp = _data[3];
		var _fix  = _data[4];
		var cDep  = attrDepth();
		
		var _dw = round(surface_valid_size(_area[2]) * 2);
		var _dh = round(surface_valid_size(_area[3]) * 2);
		_outSurf = surface_verify(_outSurf, _dw, _dh, cDep);
		var pingpong = [ surface_create_valid(_dw, _dh, cDep), surface_create_valid(_dw, _dh, cDep) ];
		var ppInd = 0;
		
		var _px = round(_area[0]);
		var _py = round(_area[1]);
		var _pw = round(_area[2]);
		var _ph = round(_area[3]);
		var amo = (ds_list_size(inputs) - input_fix_len) / data_length - 1;
		
		surface_set_target(pingpong[0]);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		if(amo <= 0) {
			if(_fix) {
				if(_samp)	draw_surface_tiled_safe(_data[0], 0, 0);
				else		draw_surface_safe(_data[0], 0, 0);
			} else {
				var sx = _px / _zoom - _pw;
				var sy = _py / _zoom - _ph;
				if(_samp)	draw_surface_tiled_ext_safe(_data[0], -sx, -sy, 1 / _zoom, 1 / _zoom, c_white, 1);
				else		draw_surface_ext_safe(_data[0], -sx, -sy, 1 / _zoom, 1 / _zoom, 0, c_white, 1);
			}
		} else {
			var sx = _px / _zoom - _pw;
			var sy = _py / _zoom - _ph;
				
			if(_fix)	draw_surface_safe(_data[0], 0, 0);
			else		draw_surface_tiled_ext_safe(_data[0], sx, sy, 1 / _zoom, 1 / _zoom, c_white, 1);
		}
		BLEND_NORMAL;
		surface_reset_target();
		
		surface_set_target(pingpong[1]);
		DRAW_CLEAR
		surface_reset_target();
		
		shader_set(shader);
		shader_set_uniform_f(uni_dim_cam, _dw, _dh);
		shader_set_uniform_f(uni_zom, _zoom);
		shader_set_uniform_i(uni_sam_mod, _samp);
		
		for( var i = 0; i < amo; i++ ) {
			ppInd = !ppInd;
			
			surface_set_target(pingpong[ppInd]);
			var ind = input_fix_len + i * data_length;
			
			var sz = _data[ind + 1][2];
			var sx = _data[ind + 1][0] * sz * _px;
			var sy = _data[ind + 1][1] * sz * _py;
			
			var _surface = _data[ind];
			var _scnW = surface_get_width(_surface);
			var _scnH = surface_get_height(_surface);
			
			shader_set_uniform_f(uni_dim_scn, _scnW, _scnH);
			shader_set_uniform_f(uni_blur, sz);
			shader_set_uniform_f(uni_pos, (_px + sx) / _scnW, (_py + sy) / _scnH);
			shader_set_uniform_i(uni_fix_bg, !i && _fix);
			texture_set_stage(uni_backg, surface_get_texture(pingpong[!ppInd])); //prev surface
			texture_set_stage(uni_scene, surface_get_texture(_surface)); //surface to draw
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dw, _dh, 0, c_white, 1);
			surface_reset_target();
		}
		
		shader_reset();
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		draw_surface_safe(pingpong[ppInd], 0, 0);
		BLEND_NORMAL;
		surface_reset_target();
		
		surface_free(pingpong[0]);
		surface_free(pingpong[1]);
		
		return _outSurf;
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = input_fix_len; i < ds_list_size(_inputs); i += data_length)
			createNewInput();
	}
}