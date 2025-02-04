function Node_Seperate_Shape(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Separate Shape";
	
	newInput(0, nodeValue_Surface("Surface In", self))
		.rejectArray();
	
	newInput(1, nodeValue_Float("Tolerance", self, 0.2))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 1, 0.01 ], update_stat: SLIDER_UPDATE.release })
		.rejectArray();
		
	newInput(2, nodeValue_Bool("Override color", self, false))
		.rejectArray();
	
	newInput(3, nodeValue_Color("Color", self, cola(c_white)))
		.rejectArray();
	
	newInput(4, nodeValue_Bool("Ignore blank", self, true, "Skip empty shapes."))
		.rejectArray();
	
	newInput(5, nodeValue_Enum_Button("Mode", self,  0 , [ "Greyscale", "Alpha" ] ))
		
	newInput(6, nodeValue_Bool("Crop", self, true ))
		
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Atlas",	self, VALUE_TYPE.atlas, []));
	
	input_display_list = [
		["Shape",	false], 0, 5, 1, 4,
		["Output",  false], 2, 3, 6, 
	]
	
	temp_surface   = [ noone, noone ];
	surface_buffer = buffer_create(1 * 1 * 4, buffer_fixed, 2);
	surface_w = 1;
	surface_h = 1;
	
	_prev_type = -1;
	
	setTrigger(1,,, function() /*=>*/ {return separateShape()});
	
	static update = function() { separateShape(); }
	
	static separateShape = function() {
		var _inSurf = getInputData(0);
		var _thres  = getInputData(1);
		var _ovr    = getInputData(2);
		var _ovrclr = getInputData(3);
		var _ignore = getInputData(4);
		var _mode   = getInputData(5);
		var _crop   = getInputData(6);
		
		var t = current_time;
		
		if(!is_surface(_inSurf)) return;
		
		var ww = surface_get_width_safe(_inSurf);
		var hh = surface_get_height_safe(_inSurf);
		
		for(var i = 0; i < 2; i++) temp_surface[i] = surface_verify(temp_surface[i], ww, hh, surface_rgba32float);
		
		#region region indexing
			surface_set_shader(temp_surface[1], sh_seperate_shape_index);
				shader_set_i("mode",      _mode);
				shader_set_i("ignore",    _ignore);
				shader_set_f("dimension", ww, hh);
				
				draw_sprite_stretched(s_fx_pixel, 0, 0, 0, ww, hh);
			surface_reset_shader();
			
			shader_set(sh_seperate_shape_ite);
				shader_set_i("mode",      _mode);
				shader_set_i("ignore",    _ignore);
				shader_set_f("dimension", ww, hh);
				shader_set_f("threshold", _thres);
				shader_set_surface("map", _inSurf);
			shader_reset();
		
			var res_index = 0, iteration = ww + hh;
			for(var i = 0; i <= iteration; i++) {
				var bg = i % 2;
				var fg = !bg;
				
				surface_set_shader(temp_surface[bg], sh_seperate_shape_ite,, BLEND.over);
					draw_surface_safe(temp_surface[fg]);
				surface_reset_shader();
			
				res_index = bg;
			}
		#endregion
		
		#region count and match color
			var i = 0, pxc = ww * hh;
			var reg = ds_map_create();
			
			var b = buffer_create(pxc * 16, buffer_fixed, 1);
			buffer_get_surface(b, temp_surface[res_index], 0);
			buffer_seek(b, buffer_seek_start, 0);
			
			repeat(pxc) {
				var _r = buffer_read(b, buffer_f32);
				var _g = buffer_read(b, buffer_f32);
				var _b = buffer_read(b, buffer_f32);
				var _a = buffer_read(b, buffer_f32);
				
				if(_r == 0 && _g == 0 && _b == 0 && _a == 0) continue;
				
				reg[? _g * ww + _r] = [ _r, _g, _b, _a ];
			}
			
			var px = ds_map_size(reg);
			if(px == 0) return;
		#endregion
		
		#region extract region
			var _outSurf, _val;
			_val = array_create(px);
			
			var _atlas = array_create(px);
			var key    = ds_map_keys_to_array(reg);
			var _ind   = 0;
			
			for(var i = 0; i < px; i++) {
				var _k  = key[i];
				var _cc = reg[? _k];
				
				var min_x = _crop? round(_cc[0]) : 0;
				var min_y = _crop? round(_cc[1]) : 0;
				var max_x = _crop? round(_cc[2]) : ww;
				var max_y = _crop? round(_cc[3]) : hh;
				
				var _sw = _crop? max_x - min_x + 1 : ww;
				var _sh = _crop? max_y - min_y + 1 : hh;
				
				if(_sw <= 1 || _sh <= 1) continue;
				
				_outSurf   = surface_create_valid(_sw, _sh);
				_val[_ind] = _outSurf;
				
				surface_set_shader(_outSurf, sh_seperate_shape_sep);
					shader_set_surface("original", _inSurf);
					shader_set_f("color",          _cc);
					shader_set_i("override",       _ovr);
					shader_set_color("overColor",  _ovrclr);
					
					draw_surface_safe(temp_surface[res_index], -min_x, -min_y);
				surface_reset_shader();
				
				_atlas[_ind] = new SurfaceAtlas(_outSurf, min_x, min_y).setOrginalSurface(_inSurf);
				_ind++;
			}
			
			array_resize(_val,   _ind);
			array_resize(_atlas, _ind);
			
			ds_map_destroy(reg);
			
			outputs[0].setValue(_val);
			outputs[1].setValue(_atlas);
		#endregion
	}
}