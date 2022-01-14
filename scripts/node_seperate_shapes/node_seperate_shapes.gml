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
		var _r =  c & 255;
		var _g = (c >> 8) & 255;
		var _b = (c >> 16) & 255;
		
		return make_color_rgb(_r, _g, _b);
	}
	
	_prev_type = -1;
	
	function update() {
		var _inSurf = inputs[| 0].getValue();
		var _out_type = inputs[| 1].getValue();
		
		var ww = surface_get_width(_inSurf);
		var hh = surface_get_height(_inSurf);
		
		for(var i = 0; i < 2; i++) {
			if(!is_surface(temp_surf[i])) temp_surf[i] = surface_create(surface_get_width(_inSurf), surface_get_height(_inSurf));
			else surface_size_to(temp_surf[i], surface_get_width(_inSurf), surface_get_height(_inSurf));
			
			surface_set_target(temp_surf[i]);
			draw_clear_alpha(0, 0);
			surface_reset_target();
		}
		
		shader_set(sh_seperate_shape_index);
		surface_set_target(temp_surf[1]);
			draw_surface_safe(_inSurf, 0, 0);
		surface_reset_target();
		shader_reset();
		
		shader_set(sh_seperate_shape_ite);
		shader_set_uniform_f_array(uniform_it_dim, [ surface_get_width(_inSurf), surface_get_height(_inSurf) ]);
		shader_reset();
		
		var res_index, iteration = surface_get_width(_inSurf) + surface_get_height(_inSurf);
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
			shader_set_uniform_f_array(shader_get_uniform(sh_seperate_shape_counter, "dimension"), [ surface_get_width(_inSurf), surface_get_height(_inSurf) ]);
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
				}
			}
			
			var _boundary = array_create(px);
			var _sw = surface_get_width(temp_surf[res_index]);
			var _sh = surface_get_height(temp_surf[res_index]);
			
			buffer_delete(surface_buffer);
			surface_buffer = buffer_create(_sw * _sh * 4, buffer_fixed, 2);
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
					var cc = surface_getpixel(_pixel_surface, 1 + i, 0);
					
					#region boundary search (brute force)
						if(_out_type == 1) {
							var t = _sh;
							var b = 0;
							var l = 0;
							var r = _sw;
						
							for( var j = 0; j < surface_get_width(_inSurf); j++ ) {
								for( var k = 0; k < surface_get_height(_inSurf); k++ ) {
									var _sc = get_color_buffer(j, k, _sw, _sh);
									if(_sc == cc) {
										t = min(t, k);
										b = max(b, k);
										l = max(l, j);
										r = min(r, j);
									}
								}
							}
							
							_boundary[i] = [l, t, r, b];
						}
					#endregion
					
					texture_set_stage(shader_get_sampler_index(sh_seperate_shape_sep, "original"), surface_get_texture(_inSurf));
					shader_set_uniform_f_array(shader_get_uniform(sh_seperate_shape_sep, "color"), [ color_get_red(cc), color_get_green(cc) ]);
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