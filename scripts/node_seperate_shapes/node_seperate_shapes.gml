function Node_create_Seperate_Shape(_x, _y) {
	var node = new Node_Seperate_Shape(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Seperate_Shape(_x, _y) : Node(_x, _y) constructor {
	name		= "Separate shape";
	auto_update = false;
	
	uniform_it_dim = shader_get_uniform(sh_seperate_shape_ite, "dimension");
	
	is_dynamic_output = true;
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Output", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Node", "Array" ])
		.setVisible(false);
	
	inputs[| 2] = nodeValue(2, "Tolerance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.setVisible(false);
	
	static createOutput = function() {
		var o = nodeValue(ds_list_size(outputs), "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
		ds_list_add(outputs, o);
		
		return o;
	}
	
	temp_surf = [ surface_create(1, 1), surface_create(1, 1) ];
	surface_buffer = buffer_create(1 * 1 * 4, buffer_fixed, 2);
	
	function get_color_buffer(_x, _y, w, h) {
		buffer_seek(surface_buffer, buffer_seek_start, (w * _y + _x) * 4);
		var c = buffer_read(surface_buffer, buffer_u32);
		return c;
	}
	
	_prev_type = -1;
	
	function update() {
		var _inSurf = inputs[| 0].getValue();
		var _out_type = inputs[| 1].getValue();
		var t = current_time;
		
		if(!is_surface(_inSurf)) return;
		
		var ww = surface_get_width(_inSurf);
		var hh = surface_get_height(_inSurf);
		
		for(var i = 0; i < 2; i++) {
			if(!is_surface(temp_surf[i])) temp_surf[i] = surface_create(ww, hh);
			else surface_size_to(temp_surf[i], ww, hh);
			
			surface_set_target(temp_surf[i]);
			draw_clear_alpha(0, 0);
			surface_reset_target();
		}
		
		shader_set(sh_seperate_shape_index);
		shader_set_uniform_f(shader_get_uniform(sh_seperate_shape_index, "tolerance"), inputs[| 2].getValue());
		surface_set_target(temp_surf[1]);
			draw_surface_safe(_inSurf, 0, 0);
		surface_reset_target();
		shader_reset();
		
		shader_set(sh_seperate_shape_ite);
		shader_set_uniform_f_array(uniform_it_dim, [ ww, hh ]);
		shader_reset();
		
		var res_index = 0, iteration = ww + hh;
		for(var i = 0; i <= iteration; i++) {
			var bg = i % 2;
			var fg = (i + 1) % 2;
			
			shader_set(sh_seperate_shape_ite);
			surface_set_target(temp_surf[bg]);
			draw_clear_alpha(0, 0);
			BLEND_ADD
				draw_surface_safe(temp_surf[fg], 0, 0);
			BLEND_NORMAL
			surface_reset_target();
			shader_reset();
			
			res_index = bg;
		}
		
		var _pixel_surface = surface_create(PREF_MAP[? "shape_separation_max"], 1);
		surface_set_target(_pixel_surface);
		draw_clear_alpha(0, 0);
		BLEND_ADD
			shader_set(sh_seperate_shape_counter);
			texture_set_stage(shader_get_sampler_index(sh_seperate_shape_counter, "surface"), surface_get_texture(temp_surf[res_index]));
			shader_set_uniform_f_array(shader_get_uniform(sh_seperate_shape_counter, "dimension"), [ ww, hh ]);
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, PREF_MAP[? "shape_separation_max"], 1, 0, c_white, 1);
			shader_reset();
		BLEND_NORMAL
		surface_reset_target();
		
		var px = surface_getpixel(_pixel_surface, 0, 0);
		
		if(px > 0) {
			var _outSurf, _val;
			
			if(_out_type == 0) {
				while(ds_list_size(outputs) > px)
					ds_list_delete(outputs, px - 1);
			} else if(_out_type == 1) {
				_val = array_create(px);
				if(_prev_type != _out_type) {
					ds_list_clear(outputs);	
					outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, _val);
					outputs[| 1] = nodeValue(1, "Shape map", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, temp_surf[res_index]);
					outputs[| 2] = nodeValue(2, "Boundary data", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, []);
				
					_prev_type = _out_type;
				} else {
					outputs[| 0].setValue(_val);
				}
			}
			
			var _boundary = array_create(px);
			
			buffer_delete(surface_buffer);
			surface_buffer = buffer_create(ww * hh * 4, buffer_fixed, 2);
			buffer_get_surface(surface_buffer, temp_surf[res_index], 0);
			
			for(var i = 0; i < px; i++) {
				if(_out_type == 0) {
					if(i >= ds_list_size(outputs)) {
						createOutput();
					}
					
					_outSurf = outputs[| i].getValue();
					surface_size_to(_outSurf, ww, hh);
				} else {
					_outSurf = surface_create(ww, hh);
					_val[@ i] = _outSurf;
				}
				
				surface_set_target(_outSurf);
				draw_clear_alpha(0, 0);
				BLEND_ADD
					shader_set(sh_seperate_shape_sep);
					var ccx = surface_getpixel_ext(_pixel_surface, 1 + i, 0);
					var alpha = (ccx >> 24) & 255;
					var blue = (ccx >> 16) & 255;
					var green = (ccx >> 8) & 255;
					var red = ccx & 255;
					
					#region boundary search
						if(_out_type == 1) {
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
								var _sc = get_color_buffer(j, k, ww, hh);
								if(_sc == ccx) {
									t = min(t, k);
									b = max(b, k);
									l = min(l, j);
									r = max(r, j);
								}
							}
							
							_boundary[i] = [l, t, r, b];
						}
					#endregion
					
					texture_set_stage(shader_get_sampler_index(sh_seperate_shape_sep, "original"), surface_get_texture(_inSurf));
					shader_set_uniform_f(shader_get_uniform(sh_seperate_shape_sep, "color"), red, green, blue, alpha);
					draw_surface_safe(temp_surf[res_index], 0, 0);
					shader_reset();
				BLEND_NORMAL
				surface_reset_target();
			}
			
			if(_out_type == 1) {
				outputs[| 2].setValue(_boundary);	
			}
		}
	}
}