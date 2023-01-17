function Node_Camera(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Camera";
	preview_alpha = 0.5;
	
	shader = sh_camera;
	uni_scene   = shader_get_sampler_index(shader, "scene");
	uni_dim_scn = shader_get_uniform(shader, "scnDimension");
	uni_dim_cam = shader_get_uniform(shader, "camDimension");
	uni_pos     = shader_get_uniform(shader, "position");
	uni_zom     = shader_get_uniform(shader, "zoom");
	uni_sam_mod = shader_get_uniform(shader, "sampleMode");
	uni_blur    = shader_get_uniform(shader, "blur");
	
	inputs[| 0] = nodeValue(0, "Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Focus area", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 16, 16, 4, 4, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area, function() { return getDimension(0); });
	
	inputs[| 2] = nodeValue(2, "Zoom", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0.01, 4, 0.01 ]);
	
	inputs[| 3] = nodeValue(3, "Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [
		["Surface",	 false], 0, 3,
		["Camera",	 false], 1, 2,
		["Elements",  true], 
	];
	
	input_display_len = array_length(input_display_list);
	input_fix_len	= ds_list_size(inputs);
	data_length		= 2;
	
	function createNewInput() {
		var index = ds_list_size(inputs);
		var _s    = floor((index - input_fix_len) / data_length);
		
		inputs[| index + 0] = nodeValue( index + 0, "Element " + string(_s), self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
		
		inputs[| index + 1] = nodeValue( index + 1, "Parallax " + string(_s), self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ] )
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
		var _area = _data[1];
		var _zoom = _data[2];
		var _samp = _data[3];
		
		var _dw = round(surface_valid_size(_area[2]) * 2);
		var _dh = round(surface_valid_size(_area[3]) * 2);
		_outSurf = surface_verify(_outSurf, _dw, _dh);
		
		var _px = round(_area[0]);
		var _py = round(_area[1]);
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		shader_set(shader);
			shader_set_uniform_f(uni_dim_cam, _dw, _dh);
			shader_set_uniform_f(uni_zom, _zoom);
			shader_set_uniform_i(uni_sam_mod, _samp);
			
			var amo = (ds_list_size(inputs) - input_fix_len) / data_length;
			
			for( var i = 0; i < amo; i++ ) {
				var ind = i? input_fix_len + (i - 1) * data_length : 0;
				var sx = 0;
				var sy = 0;
				var sz = 0;
				
				if(i) {
					sz = _data[ind + 1][2];
					sx = _data[ind + 1][0] * sz * _px;
					sy = _data[ind + 1][1] * sz * _py;
				}
				
				var _surface = _data[ind];
				var _scnW = surface_get_width(_surface);
				var _scnH = surface_get_height(_surface);
				shader_set_uniform_f(uni_dim_scn, _scnW, _scnH);
				shader_set_uniform_f(uni_blur, sz);
				shader_set_uniform_f(uni_pos, (_px + sx) / _scnW, (_py + sy) / _scnH);
				texture_set_stage(uni_scene, surface_get_texture(_surface));
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dw, _dh, 0, c_white, 1);
			}
		shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = input_fix_len; i < ds_list_size(_inputs); i += data_length)
			createNewInput();
	}
}