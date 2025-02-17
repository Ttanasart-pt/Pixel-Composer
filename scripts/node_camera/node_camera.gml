function Node_Camera(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Camera";
	preview_alpha = 0.5;
	
	onSurfaceSize = function() { return surface_get_dimension(getInputData(0)); };
	newInput(0, nodeValue_Area("Focus area", self, DEF_AREA, { onSurfaceSize, useShape : false }));
	
	newInput(1, nodeValue_Float("Zoom", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0.01, 4, 0.01 ] });
	
	newInput(2, nodeValue_Bool("Depth of Field", self, false));
	
	newInput(3, nodeValue_Float("Focal distance", self, 0));
	
	newInput(4, nodeValue_Float("Defocus", self, 1));
	
	newInput(5, nodeValue_Float("Focal range", self, 0));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Camera",		false], 0, 1, 
		["Depth Of Field", true, 2], 3, 5, 4, 
		["Elements",	 true], 
	];
	
	attribute_surface_depth();

	temp_surface = [ noone, noone ];
	
	static createNewInput = function() { 
		var index = array_length(inputs);
		var _s    = floor((index - input_fix_len) / data_length);
		
		if(_s) array_push(input_display_list, new Inspector_Spacer(20, true));
		
		newInput(index + 0, nodeValue_Surface($"Element {_s}", self, noone));
		
		newInput(index + 1, nodeValue_Enum_Button($"Positioning {_s}", self,  false, [ "Space", "Camera" ]));
	
		newInput(index + 2, nodeValue_Vec2($"Position {_s}", self, [ 0, 0 ] ))
			.setUnitRef(function(index) { return getDimension(index); });
		
		newInput(index + 3, nodeValue_Enum_Scroll($"Oversample {_s}", self,  0, [ new scrollItem("Empty ",   s_node_camera_repeat, 0), 
													                              new scrollItem("Repeat ",  s_node_camera_repeat, 1), 
													                              new scrollItem("Repeat X", s_node_camera_repeat, 2), 
													                              new scrollItem("Repeat Y", s_node_camera_repeat, 3), ]));
		
		newInput(index + 4, nodeValue_Vec2($"Parallax {_s}", self, [ 0, 0 ]));
		
		newInput(index + 5, nodeValue($"Depth {_s}", self, CONNECT_TYPE.input, VALUE_TYPE.float, 0));
		
		for( var i = 0; i < data_length; i++ ) array_push(input_display_list, index + i);
		
		return inputs[index + 0];
	} 
	
	setDynamicInput(6, true, VALUE_TYPE.surface);
	
	static getPreviewValues = function() { return getInputData(input_fix_len); }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		PROCESSOR_OVERLAY_CHECK
		
		var _out  = outputs[0].getValue();
		if(is_array(_out)) _out = _out[preview_index];
		
		var _area = current_data[0];
		var _zoom = current_data[1];
		
		var _cam_x = _x + (_area[0] - _area[2] * _zoom) * _s;
		var _cam_y = _y + (_area[1] - _area[3] * _zoom) * _s;
		
		if(PANEL_PREVIEW.getNodePreview() == self)
			draw_surface_ext_safe(_out, _cam_x, _cam_y, _s * _zoom, _s * _zoom);
		inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		draw_set_color(COLORS._main_accent);
		var x0 = _cam_x;
		var y0 = _cam_y;
		var x1 = x0 + _area[2] * 2 * _zoom * _s;
		var y1 = y0 + _area[3] * 2 * _zoom * _s;
		
		draw_rectangle_dashed(x0, y0, x1, y1);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _area = _data[0];
		var _zoom = _data[1];
		
		var _dof      = _data[2];
		var _dof_dist = _data[3];
		var _dof_stop = _data[4];
		var _dof_rang = _data[5];
		
		var cDep   = attrDepth();
		
		var _cam_x = round(_area[0]);
		var _cam_y = round(_area[1]);
		var _cam_w = round(_area[2]);
		var _cam_h = round(_area[3]);
		
		var _surf_w = round(surface_valid_size(_cam_w * 2));
		var _surf_h = round(surface_valid_size(_cam_h * 2));
		
		_outSurf = surface_verify(_outSurf, _surf_w, _surf_h, cDep);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _surf_w, _surf_h, cDep);
			surface_clear(temp_surface[i]);
		}
		
		var amo = getInputAmount();
		if(amo <= 0) return _outSurf;
		
		shader_set(sh_camera);
		shader_set_f("camDimension", _surf_w, _surf_h);
		shader_set_f("zoom", _zoom);
		
		var ppInd = 0;
		
		for( var i = 0; i < amo; i++ ) {
			var ind = input_fix_len + i * data_length;
			
			var _surf  = _data[ind + 0];
			var _sposT = _data[ind + 1];
			var _spos  = _data[ind + 2];
			var _samp  = _data[ind + 3];
			var _paral = _data[ind + 4];
			var _sdof  = _data[ind + 5];
			
			if(!is_surface(_surf)) continue;
			ppInd = !ppInd;
			
			var sx = _spos[0] + _paral[0] * _cam_x;
			var sy = _spos[1] + _paral[1] * _cam_y;
			
			var px, py;
			
			if(_sposT == 0) {
				px = _cam_x - sx;
				py = _cam_y - sy;
			} else {
				px = -sx;
				py = -sy;
			}
			
			var _scnW = surface_get_width_safe(_surf);
			var _scnH = surface_get_height_safe(_surf);
			
			px /= _scnW;
			py /= _scnH;
			
			shader_set_i("sampleMode",	 _samp);
			shader_set_f("scnDimension", _scnW, _scnH);
			shader_set_f("position",	 px, py);
			
			shader_set_f("bokehStrength", 0);
			if(_dof) {
				var _x = max(abs(_sdof - _dof_dist) - _dof_rang, 0);
					_x = _x * tanh(_x / 10);
				shader_set_f("bokehStrength", _x * _dof_stop);
			}
			
			shader_set_surface("backg", temp_surface[!ppInd]);	//prev surface
			shader_set_surface("scene", _surf);					//surface to draw
			
			surface_set_target(temp_surface[ppInd]);
				draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _surf_w, _surf_h);
			surface_reset_target();
		}
		
		shader_reset();
		
		surface_set_shader(_outSurf, noone);
			draw_surface_safe(temp_surface[ppInd]);
		surface_reset_shader();
		
		return _outSurf;
	}
}