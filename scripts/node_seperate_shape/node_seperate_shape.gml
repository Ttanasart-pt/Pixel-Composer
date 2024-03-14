function Node_Seperate_Shape(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Separate Shape";
	//error_update_enabled = true;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.rejectArray();
	
	inputs[| 1] = nodeValue("Tolerance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 1, 0.01 ], update_stat: SLIDER_UPDATE.release })
		.rejectArray();
		
	inputs[| 2] = nodeValue("Override color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.rejectArray();
	
	inputs[| 3] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.rejectArray();
	
	inputs[| 4] = nodeValue("Ignore blank", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Skip empty and black shape.")
		.rejectArray();
	
	outputs[| 0] = nodeValue("Surface out",	self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Atlas",	self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, []);
	
	input_display_list = [
		["Shape",	false], 0, 1, 4,
		["Override Color", true, 2], 3,
	]
	
	attribute_surface_depth();
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1) ];
	surface_buffer = buffer_create(1 * 1 * 4, buffer_fixed, 2);
	surface_w = 1;
	surface_h = 1;
	
	attributes.max_shape = 64;
	array_push(attributeEditors, ["Maximum shapes", function() { return attributes.max_shape; },
		new textBox(TEXTBOX_INPUT.number, function(val) { 
			attributes.max_shape = val;
			triggerRender();
		})]);
	
	function get_color_buffer(_x, _y) {
		buffer_seek(surface_buffer, buffer_seek_start, (surface_w * _y + _x) * 4);
		var c = buffer_read(surface_buffer, buffer_u32);
		return c;
	}
	
	_prev_type = -1;
	
	static onInspector1Update = function() { separateShape(); }
	
	static update = function() {
		separateShape();
	}
	
	static separateShape = function() {
		var _inSurf = getInputData(0);
		var _thres  = getInputData(1);
		var _ovr    = getInputData(2);
		var _ovrclr = getInputData(3);
		var _ignore = getInputData(4);
		var t = current_time;
		
		if(!is_surface(_inSurf)) return;
		
		var ww = surface_get_width_safe(_inSurf);
		var hh = surface_get_height_safe(_inSurf);
		surface_w = ww;
		surface_h = hh;
		
		for(var i = 0; i < 2; i++) {
			temp_surface[i] = surface_verify(temp_surface[i], ww, hh, attrDepth());
			
			surface_set_target(temp_surface[i]);
			DRAW_CLEAR
			surface_reset_target();
		}
		
		#region region indexing
			surface_set_shader(temp_surface[1], sh_seperate_shape_index);
				shader_set_i("ignore", _ignore);
				draw_sprite_stretched(s_fx_pixel, 0, 0, 0, ww, hh);
			surface_reset_shader();
		
			shader_set(sh_seperate_shape_ite);
				shader_set_i("ignore", _ignore);
				shader_set_f("dimension", ww, hh);
				shader_set_f("threshold", _thres);
				shader_set_surface("map", _inSurf);
			shader_reset();
		
			var res_index = 0, iteration = ww + hh;
			for(var i = 0; i <= iteration; i++) {
				var bg = i % 2;
				var fg = !bg;
			
				surface_set_shader(temp_surface[bg], sh_seperate_shape_ite,, BLEND.over);
					draw_surface_safe(temp_surface[fg], 0, 0);
				surface_reset_shader();
			
				res_index = bg;
			}
		#endregion
		
		#region count and match color
			var _pixel_surface = surface_create_valid(attributes.max_shape, 1);
			surface_set_shader(_pixel_surface, sh_seperate_shape_counter);
				shader_set_surface("surface", temp_surface[res_index]);
				shader_set_f("dimension", [ ww, hh ]);
				shader_set_i("maxShape", attributes.max_shape);
				shader_set_i("ignore", _ignore);
			
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, attributes.max_shape, 1, 0, c_white, 1);
			surface_reset_shader();
		
			var px = surface_get_pixel(_pixel_surface, 0, 0);
			if(px == 0) return;
		#endregion
		
		#region extract region
			var _outSurf, _val;
			_val = array_create(px);
			outputs[| 0].setValue(_val);
			
			var _atlas = array_create(px);
			var _pad   = 0;
			
			buffer_delete(surface_buffer);
			surface_buffer = buffer_create(ww * hh * 4, buffer_fixed, 2);
			buffer_get_surface(surface_buffer, temp_surface[res_index], 0);
			
			for(var i = 0; i < px; i++) {
				var ccx = surface_get_pixel_ext(_pixel_surface, 1 + i, 0);
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
				
				_outSurf = surface_create_valid(r - l + 1 + _pad * 2, b - t + 1 + _pad * 2);
				_val[i] = _outSurf;
				
				surface_set_shader(_outSurf, sh_seperate_shape_sep);
					shader_set_surface("original", _inSurf);
					shader_set_f("color", red, green, blue, alpha);
					shader_set_i("override", _ovr);
					shader_set_f("overColor", colToVec4(_ovrclr));
				
					draw_surface_safe(temp_surface[res_index], -l + _pad, -t + _pad);
				surface_reset_shader();
				
				_atlas[i] = new SurfaceAtlas(_outSurf, l, t).setOrginalSurface(_inSurf);
			}
			
			outputs[| 1].setValue(_atlas);
		#endregion
	}
}