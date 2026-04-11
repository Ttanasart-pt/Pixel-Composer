#region data
	globalvar LUT_DATA; LUT_DATA = {};
	
	function LUT_data(_path) constructor {
		path = _path;
		read = 0;
		
		dmin = [0,0,0];
		dmax = [1,1,1];
		
		size    = 8;
		rawData = buffer_create(1, buffer_grow, 1);
		buffer_to_start(rawData);
		
		surface = undefined;
		fileId  = undefined;
		
		static LUT_num = function(line) { 
			var l = string_trim(line);
			return real(l);
		}
		
		static LUT_num3 = function(line) { 
			var l = string_trim(line);
			var s = string_split(l, " ");
			return [ real(s[0]), real(s[1]), real(s[2]) ];
		}
		
		static pathReadInit = function() {
			fileId = file_text_open_read(path);
			
			var o0   = ord("0"), o9 = ord("9");
			
			while(!file_text_eof(fileId)) {
				var _line = file_text_readln(fileId);
				
				if(string_starts_with(_line, "DOMAIN_MIN"))
					dmin = LUT_num3(string_replace(_line, "DOMAIN_MIN", ""));
					
				else if(string_starts_with(_line, "DOMAIN_MAX"))
					dmax = LUT_num3(string_replace(_line, "DOMAIN_MAX", ""));
					
				else if(string_starts_with(_line, "LUT_3D_SIZE"))
					size = LUT_num(string_replace(_line, "LUT_3D_SIZE", ""));
					
				else {
					var _o = ord(string_char_at(_line, 1));
					if(_o >= o0 && _o <= o9) {
						var st = 1;
						var sp = string_pos_ext(" ", _line, st);
						var s  = string_copy(_line, st, sp - st);
						buffer_write(rawData, buffer_f32, real(s));
						st = sp + 1;
						
						var sp = string_pos_ext(" ", _line, st);
						var s  = string_copy(_line, st, sp - st);
						buffer_write(rawData, buffer_f32, real(s));
						st = sp + 1;
						
						var sp = string_length(_line);
						var s  = string_copy(_line, st, sp - st);
						buffer_write(rawData, buffer_f32, real(s));
						
						buffer_write(rawData, buffer_f32, 1);
						break;
					}
				}
			}
			
			read = 1;
		}
		
		static pathReadStep = function(_time = 1 / 60) {
			var _timeM = _time * 1_000_000;
			var _dt = get_timer();
			
			while(!file_text_eof(fileId)) {
				var _line = string_trim(file_text_readln(fileId));
				if(_line == "") break;
				
				var st = 1;
				var sp = string_pos_ext(" ", _line, st);
				var s  = string_copy(_line, st, sp - st);
				buffer_write(rawData, buffer_f32, real(s));
				st = sp + 1;
				
				var sp = string_pos_ext(" ", _line, st);
				var s  = string_copy(_line, st, sp - st);
				buffer_write(rawData, buffer_f32, real(s));
				st = sp + 1;
				
				var sp = string_length(_line);
				var s  = string_copy(_line, st, sp - st);
				buffer_write(rawData, buffer_f32, real(s));
				st = sp + 1;
				
				buffer_write(rawData, buffer_f32, 1);
				
				if(get_timer() - _dt > _timeM) break;
			}
			
			if(file_text_eof(fileId)) {
				file_text_close(fileId);
				read = 2;
			}
		}
		
		static getSurface = function() {
			if(surface != undefined) return surface;
			
			surface = surface_create(size * size, size, surface_rgba32float);
			buffer_set_surface(rawData, surface, 0);
			
			return surface;
		}
		
	}
	
	function lut_get(_path) {
		if(!file_exists_empty(_path)) return;
		
		var _filemod = file_get_modify_s(_path);
		var _hash    = md5_string_unicode($"{_path}{_filemod}");
		if(has(LUT_DATA, _hash)) return LUT_DATA[$ _hash];
		
		LUT_DATA[$ _hash] = new LUT_data(_path);
		LUT_DATA[$ _hash].pathReadInit();
		return LUT_DATA[$ _hash];
	}
#endregion

function Node_LUT(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "LUT";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(1, nodeValue_Surface( "Mask"       ));
	newInput(2, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(1, 3); // inputs 3, 4
	
	////- =LUT
	newInput( 7, nodeValue_Path(   "LUT File"    )).setDisplay(VALUE_DISPLAY.path_load, { filter: "CUBE file|*.cube" });
	newInput( 8, nodeValue_Slider( "Strength", 1 ));
	// 9
	
	newOutput( 0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone ));
	newOutput( 1, nodeValue_Output("LUT Surface", VALUE_TYPE.surface, noone ));
	
	input_display_list = [  5,  6, 
		[ "Surfaces", true ],  0,  1,  2,  3,  4, 
		[ "LUT",     false ],  7,  8, 
	];
	
	////- Nodes
	
	lutObject = undefined;
	
	static step = function() {
		if(lutObject != undefined && lutObject.read == 1) {
			lutObject.pathReadStep();
			if(lutObject.read == 2)
				triggerRender();
		}
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			
			var _path = _data[ 7];
			var _str  = _data[ 8];
		#endregion
		
		if(!is_surface(_surf))        return _outData;
		if(!file_exists_empty(_path)) return _outData;
		
		lutObject = lut_get(_path);
		
		if(lutObject == undefined) return _outData;
		if(lutObject.read < 2)     return _outData;
		
		var _LUTsurf = lutObject.getSurface();
		
		if(!surface_exists(_LUTsurf)) return _outData;
		
		var _outSurf = _outData[0];
		_outData[1]  = surface_verify(_outData[1], surface_get_width(_LUTsurf), surface_get_height(_LUTsurf));
		surface_set_shader(_outData[1]);
			draw_surface(_LUTsurf, 0, 0);
		surface_reset_shader();
		
		surface_set_shader(_outSurf, sh_lut_apply);
			gpu_set_texfilter_ext(shader_get_sampler_index(sh_lut_apply, "lutSurface"), true);
			shader_set_s("lutSurface", _LUTsurf       );
			shader_set_f("lutSize",    lutObject.size );
			
			shader_set_f("strength",   _str );
			
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outData; 
	}
	
	on_drop_file = function(path) {
		inputs[7].setValue(path);
		return false;
	}
	
	static dropPath = function(path) {
		if(is_array(path)) path = array_safe_get(path, 0);
		if(!file_exists_empty(path)) return;
		
		inputs[7].setValue(path);
	
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(lutObject != undefined && lutObject.read == 1)
			draw_sprite_ui(THEME.loading, 0, xx + w * _s / 2, yy + h * _s / 2, _s, _s, current_time / 2, COLORS._main_icon, 1);
	}
	
}