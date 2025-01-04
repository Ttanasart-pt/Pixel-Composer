#macro   surface_reset_target surface_reset_target_override
#macro __surface_reset_target surface_reset_target
function surface_reset_target_override() { __surface_reset_target(); winwin_draw_sync(); }

#region ==================================== DRAW ====================================

	function draw_surface_safe(surface, _x = 0, _y = 0) {
		INLINE
	
		if(is_struct(surface)) {
			if(is_instanceof(surface, dynaSurf)) {
				surface.draw(_x, _y);
				return;
			} else if(is_instanceof(surface, SurfaceAtlas))
				surface = surface.getSurface();
		}
		if(is_array(surface) || !surface_exists(surface)) return;
	
		__channel_pre(surface);
			draw_surface(surface, _x, _y);
		__channel_pos(surface);
	}

	function draw_surface_stretched_safe(surface, _x, _y, _w, _h) {
		INLINE
	
		if(is_struct(surface)) {
			if(is_instanceof(surface, dynaSurf)) {
				surface.drawStretch(_x, _y, _w, _h);
				return;
			} else if(is_instanceof(surface, SurfaceAtlas))
				surface = surface.getSurface();
		}
		if(is_array(surface) || !surface_exists(surface)) return;
	
		__channel_pre(surface);
			draw_surface_stretched(surface, _x, _y, _w, _h);
		__channel_pos(surface);
	}

	function draw_surface_ext_safe(surface, _x = 0, _y = 0, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alpha = 1) {
		INLINE
	
		if(is_struct(surface)) {
			if(is_instanceof(surface, dynaSurf)) {
				surface.draw(_x, _y, _xs, _ys, _rot, _col, _alpha);
				return;
			} else if(is_instanceof(surface, SurfaceAtlas))
				surface = surface.getSurface();
		}
	
		if(is_array(surface) || !surface_exists(surface)) return;
	
		__channel_pre(surface);
			draw_surface_ext(surface, _x, _y, _xs, _ys, _rot, _col, _alpha);
		__channel_pos(surface);
	}

	function draw_surface_tiled_safe(surface, _x = 0, _y = 0) {
		INLINE
	
		if(is_struct(surface)) {
			if(is_instanceof(surface, dynaSurf)) {
				surface.drawTile(_x, _y);
				return;
			} else if(is_instanceof(surface, SurfaceAtlas))
				surface = surface.getSurface();
		}
		if(is_array(surface) || !surface_exists(surface)) return;
	
		__channel_pre(surface);
			draw_surface_tiled(surface, _x, _y);
		__channel_pos(surface);
	}

	function draw_surface_tiled_ext_safe(surface, _x = 0, _y = 0, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alpha = 1) {
		INLINE
	
		if(is_struct(surface)) {
			if(is_instanceof(surface, dynaSurf)) {
				surface.drawTile(_x, _y, _xs, _ys, _col, _alpha);
				return;
			} else if(is_instanceof(surface, SurfaceAtlas))
				surface = surface.getSurface();
		}
		if(is_array(surface) || !surface_exists(surface)) return;
	
		var back = surface_get_target();
		var bdim = surface_get_dimension(back);
	
		shader_set(sh_draw_tile);
			shader_set_f("backDimension", bdim);
			shader_set_f("foreDimension", surface_get_dimension(surface));
			shader_set_f("position"		, [ _x, _y ]);
			shader_set_f("scale"		, [ _xs, _ys ]);
			shader_set_f("rotation"		, _rot);
		
			draw_surface_stretched_ext(surface, 0, 0, bdim[0], bdim[1], _col, _alpha);
		shader_reset();
	}

	function draw_surface_part_ext_safe(surface, _l, _t, _w, _h, _x, _y, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alpha = 1) {
		INLINE
		
		if(is_struct(surface)) {
			if(is_instanceof(surface, dynaSurf)) {
				surface.drawPart(_l, _t, _w, _h, _x, _y, _xs, _ys, _rot, _col, _alpha);
				return;
			} else if(is_instanceof(surface, SurfaceAtlas))
				surface = surface.getSurface();
		}
		if(is_array(surface) || !surface_exists(surface)) return;
		
		__channel_pre(surface);
			draw_surface_part_ext(surface, _l, _t, _w, _h, _x, _y, _xs, _ys, _col, _alpha);
		__channel_pos(surface);
	}

#endregion ==================================== DRAW ====================================

#region ==================================== CHECK ===================================

	function is_surface(s) {
		INLINE
		
		return !is_array(s) && (
			is_instanceof(s, dynaSurf) || 
			is_instanceof(s, SurfaceAtlas) || 
			(is_numeric(s) && s > 0 && surface_exists(s))
		);
		
	}

	function surface_verify(surf, w, h, format = surface_rgba8unorm) {
		INLINE
	
		if(!is_surface(surf)) return surface_create_valid(w, h, format);
		return surface_size_to(surf, w, h, format, true);
	}

	function surface_valid(surf, w, h, format = surface_rgba8unorm) {
		INLINE
		
		if(!is_surface(surf)) return false;
		var _sw = surface_get_width(surf);
		var _sh = surface_get_height(surf);
		var _f  = surface_get_format(surf);
	
		return _sw == w && _sh == h && _f == format;
	}

#endregion ==================================== CHECK ====================================

#region ==================================== GET =====================================

	function surface_get_width_safe(s, crop = true) {
		INLINE
	
		if(!is_surface(s)) return 1;
		if(is_struct(s)) {
			if(is_instanceof(s, dynaSurf)) return s.getWidth();
			else if(is_instanceof(s, SurfaceAtlas)) return crop? surface_get_width(s.getSurface()) : s.oriSurf_w;
			else return 1;
		}
	
		return surface_get_width(s);
	}

	function surface_get_height_safe(s, crop = true) {
		INLINE
	
		if(!is_surface(s)) return 1;
		if(is_struct(s)) {
			if(is_instanceof(s, dynaSurf)) return s.getHeight();
			else if(is_instanceof(s, SurfaceAtlas)) return crop? surface_get_height(s.getSurface()) : s.oriSurf_h;
			else return 1;
		}
	
		return surface_get_height(s);
	}

	function surface_get_format_safe(s, crop = true) {
		INLINE
	
		if(is_struct(s)) {
			if(is_instanceof(s, dynaSurf)) return s.getFormat();
			else if(is_instanceof(s, SurfaceAtlas)) return surface_get_format(s.getSurface());
			else return surface_rgba8unorm;
		}
	
		return surface_get_format(s);
	}

	function surface_get_dimension(s) {
		INLINE
	
		if(!is_surface(s)) return [ 1, 1 ];
		return [ surface_get_width_safe(s), surface_get_height_safe(s) ];
	}

	function surface_get_pixel(surface, _x, _y) {
		INLINE
	
		if(!is_surface(surface)) return;
		var f  = surface_get_format(surface);
		var fx = floor(_x);
		var fy = floor(_y);
		var rx = frac(_x);
		var ry = frac(_y);
		var px = surface_getpixel(surface, fx, fy);
	
		if(rx == 0 && ry == 0) {
			if(is_numeric(px)) return px;
			return make_color_rgb(px[0] * 256, px[1] * 256, px[2] * 256);
		}
	
		var p1 = surface_getpixel(surface, fx + 1, fy + 0);
		var p2 = surface_getpixel(surface, fx + 0, fy + 1);
		var p3 = surface_getpixel(surface, fx + 1, fy + 1);
	
		return merge_color(
				   merge_color(px, p1, rx),
				   merge_color(p2, p3, rx),
		       ry);
	
	}

	function surface_get_pixel_ext(surface, _x, _y) {
		INLINE
		
		if(is_instanceof(surface, SurfaceAtlas)) surface = surface.surface.get();
		if(is_array(surface) || !surface_exists(surface)) return 0;
		var px = surface_getpixel_ext(surface, _x, _y);
	
		if(is_numeric(px)) return int64(px);
		return round(px[0] * (255 * power(256, 0))) + round(px[1] * (255 * power(256, 1))) + round(px[2] * (255 * power(256, 2))) + round(px[3] * (255 * power(256, 3)));
	}

#endregion ==================================== GET ====================================

#region =================================== CREATE ===================================

	function surface_create_empty(w, h, format = surface_rgba8unorm) {
		INLINE
	
		var s = surface_create(w, h, format);
		surface_clear(s);
		return s;
	}

	function surface_create_size(surface, format = surface_rgba8unorm) {
		INLINE
	
		return surface_create_valid(surface_get_width_safe(surface), surface_get_height_safe(surface), format);
	}

	function surface_create_valid(w, h, format = surface_rgba8unorm) {
		INLINE
	
		return surface_create_empty(surface_valid_size(w), surface_valid_size(h), format);
	}

	function surface_create_from_buffer(w, h, buff, format = surface_rgba8unorm) {
		INLINE
	
		if(buff < 0) return;
		var s = surface_create_valid(surface_valid_size(w), surface_valid_size(h), format);
		buffer_set_surface(buff, s, 0);
		return s;
	}

	function surface_from_buffer(buff) {
		static header_length = 24;
		
		if(!buffer_exists(buff))					return noone;
		if(buffer_get_size(buff) < header_length)	return noone;
	
		buffer_seek(buff, buffer_seek_start, 0);
		var text = "";
		repeat(4) text += chr(buffer_read(buff, buffer_u8));
		if(text != "PXCS") return noone;
	
		var w = buffer_read(buff, buffer_u16);
		var h = buffer_read(buff, buffer_u16);
		var format = buffer_read(buff, buffer_u8);
		if(w < 1 || h < 1) return noone;
	
		var s = surface_create(w, h, format);
		buffer_set_surface(buff, s, header_length);
		return s;
	}

	function surface_create_from_sprite(spr) {
		if(!sprite_exists(spr)) return noone;
	
		if(sprite_get_number(spr) == 1)
			return surface_create_from_sprite_ext(spr, 0);
	
		var s = [];
		for( var i = 0; i < sprite_get_number(spr); i++ ) {
			array_push(s, surface_create_from_sprite_ext(spr, i));
		}
	
		return s;
	}

	function surface_create_from_sprite_ext(spr, ind, format = surface_rgba8unorm) {
		if(!sprite_exists(spr)) return noone;
		var sw = sprite_get_width(spr);
		var sh = sprite_get_height(spr);
	
		var s = surface_create_valid(sw, sh, format);
		surface_set_target(s);
			BLEND_OVERRIDE
			DRAW_CLEAR
			draw_sprite(spr, ind, sprite_get_xoffset(spr), sprite_get_yoffset(spr));
			BLEND_NORMAL
		surface_reset_target();
	
		return s;
	}

	function surface_size_lim(surface, width, height) {
		var sw = surface_get_width_safe(surface);
		var sh = surface_get_height_safe(surface);
		if(sw <= width && sh <= height) return surface;
	
		var ss = min(width / sw, height / sh);
		var s  = surface_create(max(1, sw * ss), max(1, sh * ss));
		surface_set_target(s);
		DRAW_CLEAR
		draw_surface_ext_safe(surface, 0, 0, ss, ss, 0, c_white, 1);
		surface_reset_target();
		return s;
	}

	function surface_size_to(surface, width, height, format = noone, skipCheck = false) {
		INLINE 
		if(!skipCheck && !is_surface(surface))			return surface;
		if(!is_numeric(width) || !is_numeric(height))	return surface;
		if(width < 1 && height < 1)						return surface;
	
		if(format != noone && format != surface_get_format(surface)) {
			surface_free(surface);
			return surface_create(width, height, format);
		}
	
		width  = surface_valid_size(width);
		height = surface_valid_size(height);
	
		var ww = surface_get_width(surface);
		var hh = surface_get_height(surface);
	
		if(ww == width && hh == height) return surface;
	
		surface_free(surface);
		surface = surface_create(width, height, format == noone? surface_rgba8unorm : format);
		
		return surface;
	}

	function surface_clear(surface, color = 0, alpha = 0) {
		INLINE
	
		if(!is_surface(surface)) return;
		surface_set_target(surface);
			draw_clear_alpha(color, alpha);
		surface_reset_target();
	}

	function surface_copy_from(dst, src, format = noone) {
		INLINE
	
		surface_set_target(dst);
		DRAW_CLEAR
		BLEND_OVERRIDE
			draw_surface_safe(src);
		BLEND_NORMAL
		surface_reset_target();
	}

	function surface_clone(surface, destination = noone, format = noone) {
		INLINE
	
		if(is_struct(surface) && is_instanceof(surface, dynaSurf)) 
			return surface.clone();
		if(!is_surface(surface)) return noone;
	
		destination = surface_verify(destination, surface_get_width_safe(surface), surface_get_height_safe(surface), format == noone? surface_get_format(surface) : format);
	
		surface_set_target(destination);
		DRAW_CLEAR
		BLEND_OVERRIDE
			draw_surface_safe(surface);
		BLEND_NORMAL
		surface_reset_target();
	
		return destination;
	}

#endregion ==================================== CREATE ====================================

#region =================================== MODIFY ===================================

	function surface_stretch(surf, _w, _h) {
		INLINE
	
		if(!is_surface(surf)) return noone;
	
		_w = surface_valid_size(_w);
		_h = surface_valid_size(_h);
	
		var _surf = surface_create(_w, _h);
		surface_set_target(_surf);
			DRAW_CLEAR
			draw_surface_stretched(surf, 0, 0, _w, _h);
		surface_reset_target();
	
		surface_free(surf);
		return _surf;
	}

	function surface_mirror(surf, _h, _v) {
		INLINE
	
		if(!is_surface(surf)) return noone;
		var _surf = surface_create_size(surf);
	
		surface_set_target(_surf);
			DRAW_CLEAR
		
			var x0 = _h * surface_get_width_safe(_surf);
			var y0 = _v * surface_get_height_safe(_surf);
		
			draw_surface_ext_safe(surf, x0, y0, _h * 2 - 1, _v * 2 - 1, 0, c_white, 1);
		surface_reset_target();
		surface_free(surf);
	
		return _surf;
	}

	function surface_project_posterize(surf) {
		INLINE
	
		if(!PROJECT.attributes.palette_fix) return surf;
		if(!is_surface(surf))				return surf;
		
		var _surf = surface_create(surface_get_width(surf), surface_get_height(surf));
	
		surface_set_shader(_surf, sh_posterize_palette);
			shader_set_f("palette", PROJECT.palettes);
			shader_set_i("keys",    array_length(PROJECT.attributes.palette));
			shader_set_i("alpha",   1);
				
			draw_surface_safe(surf);
		surface_reset_shader();
		
		surface_free(surf);
	
		return _surf;
	}

#endregion ==================================== MODIFY ====================================

#region =================================== OTHERS ===================================

	function surface_copy_size(dest, source, format = noone) {
		INLINE
	
		if(!is_surface(dest))   return;
		if(!is_surface(source)) return;
	
		surface_size_to(dest, surface_get_width_safe(source), surface_get_height_safe(source), format);
		surface_set_target(dest);
		DRAW_CLEAR
		surface_reset_target();
	
		surface_copy_from(dest, source);
	}

	function surface_valid_size(s) {
		INLINE
	
		if(!is_numeric(s)) return 1;
		if(is_infinity(s)) return 1;
		return clamp(round(s), 1, 8192);
	}

	function surface_array_free(arr) {
		INLINE
	
		if(!is_array(arr)) {
			if(is_surface(arr)) surface_free(arr);
			return;
		}
	
		for( var i = 0, n = array_length(arr); i < n; i++ ) 
			surface_array_free(arr[i]);
	}

	function surface_array_clone(arr) {
		if(!is_array(arr)) return is_surface(arr)? surface_clone(arr) : arr;
		
		var _arr = [];
	
		for( var i = 0, n = array_length(arr); i < n; i++ ) 
			_arr[i] = surface_array_clone(arr[i]);
	
		return _arr;
	}

	function surface_format_get_buffer_type(format) {
		switch(format) {
			case surface_rgba4unorm :  return buffer_u8;  break;
			case surface_rgba8unorm :  return buffer_u8;  break;
			case surface_rgba16float : return buffer_f16; break;
			case surface_rgba32float : return buffer_f32; break;
		
			case surface_r8unorm  : return buffer_u8;  break;
			case surface_r16float : return buffer_f16; break;
			case surface_r32float : return buffer_f32; break;
		}
		return buffer_u8;
	}

	function surface_format_get_channel(format) {
		switch(format) {
			case surface_rgba4unorm  :  
			case surface_rgba8unorm  :  
			case surface_rgba16float : 
			case surface_rgba32float : return 4; break;
		
			case surface_r8unorm  : 
			case surface_r16float : 
			case surface_r32float : return 1; break;
		}
		return 1;
	}

	function surface_format_get_depth(format) {
		switch(format) {
			case surface_rgba4unorm  : return 4;  break;
			case surface_rgba8unorm  : return 8;  break;
			case surface_rgba16float : return 16; break
			case surface_rgba32float : return 32; break;
		
			case surface_r8unorm  : return 8;  break
			case surface_r16float : return 16; break
			case surface_r32float : return 32; break;
		}
		return 1;
	}

	function surface_format_get_bytes(format) {
		switch(format) {
			case surface_rgba4unorm :  return 4 * 0.5; break;
			case surface_rgba8unorm :  return 4 * 1; break;
			case surface_rgba16float : return 4 * 2; break;
			case surface_rgba32float : return 4 * 4; break;
		
			case surface_r8unorm  : return 1 * 1; break;
			case surface_r16float : return 1 * 2; break;
			case surface_r32float : return 1 * 3; break;
		}
		return 1;
	}

	function surface_format_string(format) {
		switch(format) {
			case surface_rgba8unorm	 : return "8bit RGBA"
			case surface_rgba4unorm	 : return "4bit RGBA"
			case surface_rgba16float : return "16bit RGBA"
			case surface_rgba32float : return "32bit RGBA"
			case surface_r8unorm	 : return "8bit BW"
			case surface_r16float	 : return "16bit BW"
			case surface_r32float	 : return "32bit BW"
		}
		
		return "undefined";
	}

	function surface_get_size(surface) {
		INLINE
	
		var sw = surface_get_width_safe(surface);
		var sh = surface_get_height_safe(surface);
		var sz = sw * sh * surface_format_get_bytes(surface_get_format(surface));
		return sz;
	}

	function surface_texture(surface) {
		INLINE
	
		if(!is_surface(surface)) return -1;
		return surface_get_texture(surface);
	}

	#macro surface_free surface_free_safe
	#macro __surface_free surface_free 

	function surface_free_safe(surface) {
		INLINE
	
		if(!is_surface(surface)) return;
		__surface_free(surface);
	}

	function surface_save_safe(surface, path) {
		if(!is_surface(surface)) return;
		
		     if(is_instanceof(surface, SurfaceAtlas))     surface = surface.surface.get();
		else if(is_instanceof(surface, SurfaceAtlasFast)) surface = surface.surface;
		else if(is_instanceof(surface, dynaSurf))		  surface = array_safe_get(surface.surfaces, 0);
		
		if(is_array(surface) || !surface_exists(surface)) return;
		
		var f = surface_get_format(surface);
	
		if(f == surface_rgba8unorm) {
			surface_save(surface, path);
			return;
		}
	
		var w = surface_get_width_safe(surface);
		var h = surface_get_height_safe(surface);
		var s = surface_create(w, h, surface_rgba8unorm);
	
		switch(f) {
			case surface_rgba4unorm  :
			case surface_rgba8unorm	 :
			case surface_rgba16float :
			case surface_rgba32float :
				surface_set_shader(s, sh_draw_normal);
					draw_surface_safe(surface);
				surface_reset_shader();
				surface_save(s, path);
				return;
				
			case surface_r8unorm	 : s = surface_create(w, h, surface_rgba8unorm);	break;
			case surface_r16float	 : s = surface_create(w, h, surface_rgba16float);	break;
			case surface_r32float	 : s = surface_create(w, h, surface_rgba32float);	break;
			default: return;
		}
	
		surface_set_shader(s, sh_draw_single_channel);
			draw_surface_safe(surface);
		surface_reset_shader();
	
		surface_save(s, path);
		surface_free(s);
		return;
	}

	function surface_cvt_8unorm(target, surface) {
		if(!is_surface(surface)) return target;
		
		target = surface_verify(target, surface_get_width_safe(surface), surface_get_height_safe(surface));
		var _typ = surface_get_format(surface);
		
		switch(_typ) {
			case surface_rgba4unorm  :
			case surface_rgba8unorm	 :
			case surface_rgba16float :
			case surface_rgba32float :
				surface_set_shader(target, sh_draw_normal);
				break;
			case surface_r8unorm	 :	
			case surface_r16float	 :	
			case surface_r32float	 :	
				surface_set_shader(target, sh_draw_single_channel);
				break;
		}
				
		draw_surface_safe(surface);
		surface_reset_shader();
		
		return target;
	}

#endregion =================================== OTHERS ===================================

#region ================================= SERIALIZE ==================================

	function surface_array_serialize(arr) {
		INLINE
	
		var _arr = __surface_array_serialize(arr);
		return json_stringify(_arr);
	}

	function __surface_array_serialize(arr) {
		if(!is_array(arr)) {
			if(is_surface(arr)) {
				var buff = buffer_create(surface_get_width_safe(arr) * surface_get_height_safe(arr) * 4, buffer_fixed, 1);
				buffer_get_surface(buff, arr, 0);
				var comp = buffer_compress(buff, 0, buffer_get_size(buff));
				var enc  = buffer_base64_encode(comp, 0, buffer_get_size(comp));
				buffer_delete(buff);
				return { width: surface_get_width_safe(arr), height: surface_get_height_safe(arr), buffer: enc };
			} else
				return arr;
		}
	
		var _arr = [];
	
		for( var i = 0, n = array_length(arr); i < n; i++ ) 
			_arr[i] = __surface_array_serialize(arr[i]);
	
		return _arr;
	}

	function surface_array_deserialize(arr, index = -1) {
		INLINE
	
		var _arr = json_try_parse(arr);
		return index == -1? __surface_array_deserialize(_arr) : __surface_array_deserialize(_arr[index]);
	}
	
	function __surface_array_deserialize(arr) {
		if(!is_array(arr)) {
			if(!is_struct(arr) || !struct_has(arr, "buffer")) 
				return noone;
			
			var buff = buffer_base64_decode(arr.buffer);
			    buff = buffer_decompress(buff);
			return surface_create_from_buffer(arr.width, arr.height, buff);
		}
	
		var _arr = [];
	
		for( var i = 0, n = array_length(arr); i < n; i++ ) 
			_arr[i] = __surface_array_deserialize(arr[i]);
	
		return _arr;
	}

	function surface_encode(surface, stringify = true) {
		if(is_instanceof(surface, SurfaceAtlas)) surface = surface.surface.get();
		if(is_array(surface) || !surface_exists(surface)) return "";
	
		var _sw  = surface_get_width_safe(surface); 
		var _sh  = surface_get_height_safe(surface); 
		var _sf  = surface_get_format(surface);
		var buff = buffer_create(_sw * _sh * surface_format_get_bytes(_sf), buffer_fixed, 1);
		
		buffer_get_surface(buff, surface, 0);
		var comp = buffer_compress(buff, 0, buffer_get_size(buff));
		var enc  = buffer_base64_encode(comp, 0, buffer_get_size(comp));
		var str  = { 
			width: _sw, 
			height: _sh, 
			buffer: enc,
			format: _sf,
		};
		
		buffer_delete(buff);
		
		return stringify? json_stringify(str) : str;
	}

	function surface_decode(_struct) {
		if(is_string(_struct)) _struct = json_try_parse(_struct);
		if(!is_struct(_struct))            return noone;
		if(!struct_has(_struct, "buffer")) return noone;
		
		var buff = buffer_base64_decode(_struct.buffer);
		var buff = buffer_decompress(buff);
		var form = struct_try_get(_struct, "format", surface_rgba8unorm);
		return surface_create_from_buffer(_struct.width, _struct.height, buff, form);
	}

#endregion ================================= SERIALIZE =================================
