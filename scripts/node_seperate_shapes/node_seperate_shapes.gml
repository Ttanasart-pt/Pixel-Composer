enum NODE_SEP_SHAPE_OUTPUT_TYPE {
	node,
	array
}

function Node_Seperate_Shape(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Separate Shape";
	error_update_enabled = true;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0)
		.rejectArray();
	
	inputs[| 1] = nodeValue("Tolerance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.rejectArray();
		
	inputs[| 2] = nodeValue("Override color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		.rejectArray();
	
	inputs[| 3] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.rejectArray();
	
	inputs[| 4] = nodeValue("Ignore blank", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Skip empty and black shape.")
		.rejectArray();
	
	outputs[| 0] = nodeValue("Surface out",	self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Shape map",	self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 2] = nodeValue("Boundary data",	self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, []);
	
	input_display_list = [
		["Shape",	false], 0, 1, 4,
		["Render",	false], 2, 3,
	]
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1) ];
	surface_buffer = buffer_create(1 * 1 * 4, buffer_fixed, 2);
	surface_w = 1;
	surface_h = 1;
	
	function get_color_buffer(_x, _y) {
		buffer_seek(surface_buffer, buffer_seek_start, (surface_w * _y + _x) * 4);
		var c = buffer_read(surface_buffer, buffer_u32);
		return c;
	}
	
	_prev_type = -1;
	
	static onInspectorUpdate = function() {
		var _inSurf = inputs[| 0].getValue();
		var _thres  = inputs[| 1].getValue();
		var _ovr    = inputs[| 2].getValue();
		var _ovrclr = inputs[| 3].getValue();
		var _ignore = inputs[| 4].getValue();
		var t = current_time;
		
		if(!is_surface(_inSurf)) return;
		
		var ww = surface_get_width(_inSurf);
		var hh = surface_get_height(_inSurf);
		surface_w = ww;
		surface_h = hh;
	
		for(var i = 0; i < 2; i++) {
			temp_surface[i] = surface_verify(temp_surface[i], ww, hh);
			
			surface_set_target(temp_surface[i]);
			draw_clear_alpha(0, 0);
			surface_reset_target();
		}
		
		shader_set(sh_seperate_shape_index);
		shader_set_uniform_i(shader_get_uniform(sh_seperate_shape_index, "ignore"), _ignore);
		surface_set_target(temp_surface[1]);
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, ww, hh);
		surface_reset_target();
		shader_reset();
		
		shader_set(sh_seperate_shape_ite);
		shader_set_uniform_i(shader_get_uniform(sh_seperate_shape_ite, "ignore"), _ignore);
		shader_set_uniform_f(shader_get_uniform(sh_seperate_shape_ite, "dimension"), ww, hh);
		shader_set_uniform_f(shader_get_uniform(sh_seperate_shape_ite, "threshold"), _thres);
		if(is_surface(_inSurf))
			texture_set_stage(shader_get_sampler_index(sh_seperate_shape_ite, "map"), surface_get_texture(_inSurf));
		
		var res_index = 0, iteration = ww + hh;
		for(var i = 0; i <= iteration; i++) {
			var bg = i % 2;
			var fg = !bg;
			
			surface_set_target(temp_surface[bg]);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE;
				draw_surface_safe(temp_surface[fg], 0, 0);
			BLEND_NORMAL;
			surface_reset_target();
			
			res_index = bg;
		}
		
		shader_reset();
		
		var _pixel_surface = surface_create_valid(PREF_MAP[? "shape_separation_max"], 1);
		surface_set_target(_pixel_surface);
		draw_clear_alpha(0, 0);
		BLEND_OVERRIDE;
			shader_set(sh_seperate_shape_counter);
			texture_set_stage(shader_get_sampler_index(sh_seperate_shape_counter, "surface"), surface_get_texture(temp_surface[res_index]));
			shader_set_uniform_f_array_safe(shader_get_uniform(sh_seperate_shape_counter, "dimension"), [ ww, hh ]);
			shader_set_uniform_i(shader_get_uniform(sh_seperate_shape_counter, "maxShape"), PREF_MAP[? "shape_separation_max"]);
			shader_set_uniform_i(shader_get_uniform(sh_seperate_shape_counter, "ignore"), _ignore);
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, PREF_MAP[? "shape_separation_max"], 1, 0, c_white, 1);
			shader_reset();
		BLEND_NORMAL;
		surface_reset_target();
		
		var px = surface_getpixel(_pixel_surface, 0, 0);
		
		if(px == 0) return;
		
		var _outSurf, _val;
		_val = array_create(px);
		outputs[| 0].setValue(_val);
			
		var _boundary = array_create(px);
			
		buffer_delete(surface_buffer);
		surface_buffer = buffer_create(ww * hh * 4, buffer_fixed, 2);
		buffer_get_surface(surface_buffer, temp_surface[res_index], 0);
			
		for(var i = 0; i < px; i++) {
			_outSurf = surface_create_valid(ww, hh);
			_val[@ i] = _outSurf;
				
			surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE;
				shader_set(sh_seperate_shape_sep);
				var ccx = surface_getpixel_ext(_pixel_surface, 1 + i, 0);
				var alpha = (ccx >> 24) & 255;
				var blue = (ccx >> 16) & 255;
				var green = (ccx >> 8) & 255;
				var red = ccx & 255;
					
				var min_x = floor(red / 255 * ww);
				var min_y = floor(green / 255 * hh);
				var max_x = ceil(blue / 255 * ww);
				var max_y = ceil(alpha / 255 * hh);
				var t = max_y;
				var b = min_y;
				var l = max_x;
				var r = min_x;
							
				for( var j = min_x; j < max_x; j++ ) 
				for( var k = min_y; k < max_y; k++ ) {
					var _sc = get_color_buffer(j, k);
					if(_sc != ccx) continue;
					
					t = min(t, k);
					b = max(b, k);
					l = min(l, j);
					r = max(r, j);
				}
							
				_boundary[i] = [l, t, r, b];
					
				if(is_surface(_inSurf))
					texture_set_stage(shader_get_sampler_index(sh_seperate_shape_sep, "original"), surface_get_texture(_inSurf));
				shader_set_uniform_f(shader_get_uniform(sh_seperate_shape_sep, "color"), red, green, blue, alpha);
				shader_set_uniform_i(shader_get_uniform(sh_seperate_shape_sep, "override"), _ovr);
				shader_set_uniform_f_array_safe(shader_get_uniform(sh_seperate_shape_sep, "overColor"), colToVec4(_ovrclr));
				draw_surface_safe(temp_surface[res_index], 0, 0);
				shader_reset();
			BLEND_NORMAL;
			surface_reset_target();
		}
			
		outputs[| 2].setValue(_boundary,,, false);
	}
}