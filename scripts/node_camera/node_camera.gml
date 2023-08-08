function Node_Camera(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Camera";
	preview_alpha = 0.5;
	
	inputs[| 0] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue("Focus area", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0, 16, 16, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area, function() { return getDimension(0); });
	
	inputs[| 2] = nodeValue("Zoom", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0.01, 4, 0.01 ]);
	
	inputs[| 3] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Repeat", "Repeat X", "Repeat Y" ]);
	
	inputs[| 4] = nodeValue("Fix background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 5] = nodeValue("Depth of Field", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 6] = nodeValue("Focal distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 7] = nodeValue("Defocus", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 8] = nodeValue("Focal range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Background",   true], 0, 4, 3, 
		["Camera",		false], 1, 2, 5, 6, 8, 7, 
		["Elements",	 true], 
	];
	
	attribute_surface_depth();

	setIsDynamicInput(3);
	
	temp_surface = [ noone, noone ];
	
	static createNewInput = function()  {
		var index = ds_list_size(inputs);
		var _s    = floor((index - input_fix_len) / data_length);
		
		inputs[| index + 0] = nodeValue($"Element {_s}", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
		
		inputs[| index + 1] = nodeValue($"Parallax {_s}", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ] )
			.setDisplay(VALUE_DISPLAY.vector)
			.setUnitRef(function(index) { return getDimension(index); });
		
		inputs[| index + 2] = nodeValue($"Oversample {_s}", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
			.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Repeat", "Repeat X", "Repeat Y" ]);
		
		array_append(input_display_list, [ index + 0, index + 1, index + 2 ]);
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
				ds_list_add(_in, inputs[| i + 2]);
				
				array_push(input_display_list, i + 0);
				array_push(input_display_list, i + 1);
				array_push(input_display_list, i + 2);
			} else {
				delete inputs[| i + 0];
				delete inputs[| i + 1];
				delete inputs[| i + 2];
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
		
		var _cam_x = _x + (_area[0] - _area[2] * _zoom) * _s;
		var _cam_y = _y + (_area[1] - _area[3] * _zoom) * _s;
		
		draw_surface_ext_safe(_out, _cam_x, _cam_y, _s * _zoom, _s * _zoom);
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		draw_set_color(COLORS._main_accent);
		var x0 = _cam_x;
		var y0 = _cam_y;
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
		
		var _dof  = _data[5];
		var _dof_dist = _data[6];
		var _dof_stop = _data[7];
		var _dof_rang = _data[8];
		
		var cDep  = attrDepth();
		
		var _cam_x = round(_area[0]);
		var _cam_y = round(_area[1]);
		var _cam_w = round(_area[2]);
		var _cam_h = round(_area[3]);
		
		var _surf_w = round(surface_valid_size(_cam_w * 2));
		var _surf_h = round(surface_valid_size(_cam_h * 2));
		var ppInd   = 0;
		
		_outSurf = surface_verify(_outSurf, _surf_w, _surf_h, cDep);
		temp_surface[0] = surface_verify(temp_surface[0], _surf_w, _surf_h, cDep);
		temp_surface[1] = surface_verify(temp_surface[1], _surf_w, _surf_h, cDep);
		
		var amo = (ds_list_size(inputs) - input_fix_len) / data_length - 1;
		
		surface_set_target(temp_surface[0]);
		DRAW_CLEAR
		surface_reset_target();
		
		surface_set_target(temp_surface[1]);
		DRAW_CLEAR
		surface_reset_target();
		
		shader_set(sh_camera);
		shader_set_f("camDimension", _surf_w, _surf_h);
		shader_set_f("zoom", _zoom);
		
		var _surface, sx, sy, sz, _samp;
		var px, py;
		var _scnW, _scnH;
				
		for( var i = -1; i < amo; i++ ) {
			ppInd = !ppInd;
			
			surface_set_target(temp_surface[ppInd]);
			if(i == -1) {
				_surface = _data[0];
				sx		 = _fix? 0 : _cam_x;
				sy		 = _fix? 0 : _cam_y;
				sz		 = 0;
				_samp	 = _data[3];
				
				px = sx;
				py = sy;
			} else {
				var ind = input_fix_len + i * data_length;
			
				_surface = _data[ind];
				sz       = _data[ind + 1][2];
				sx       = _data[ind + 1][0] * sz * _cam_x;
				sy       = _data[ind + 1][1] * sz * _cam_y;
				_samp    = _data[ind + 2];
				
				px = _cam_x + sx;
				py = _cam_y + sy;
			}
			
			_scnW = surface_get_width(_surface);
			_scnH = surface_get_height(_surface);
			
			px /= _scnW;
			py /= _scnH;
			
			shader_set_i("bg",			 i == -1? 1 : 0);
			shader_set_i("sampleMode",	 _samp);
			shader_set_f("scnDimension", _scnW, _scnH);
			shader_set_f("position",	 px, py);
			if(_dof) {
				var _x = max(abs(sz - _dof_dist) - _dof_rang, 0);
					_x = _x * tanh(_x / 10);
				shader_set_f("bokehStrength", _x * _dof_stop);
			} else	 shader_set_f("bokehStrength", 0);
			
			shader_set_surface("backg", temp_surface[!ppInd]); //prev surface
			shader_set_surface("scene", _surface); //surface to draw
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _surf_w, _surf_h);
			surface_reset_target();
		}
		
		shader_reset();
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		draw_surface_safe(temp_surface[ppInd], 0, 0);
		BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}