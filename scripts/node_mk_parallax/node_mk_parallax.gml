function Node_MK_Parallax(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Parallax";
	update_on_frame = true;
	
	////- =Surface
	
	// inputs 0
		
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone));
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		var _s    = floor((index - input_fix_len) / data_length);
		if(_s) array_push(input_display_list, new Inspector_Spacer(20, true));
		
		newInput(index + 0, nodeValue_Surface( $"Surface {_s}"));
		newInput(index + 1, nodeValue_Vec2(    $"Position {_s}", [0,0])).setUnitRef(function(i) /*=>*/ {return getDimension(i)});
		newInput(index + 2, nodeValue_Vec2(    $"Parallax {_s}", [0,0]));
		
		var stat_label = new Inspector_Label("");
		inputs[index].stat = stat_label;
		
		array_push(input_display_list, index + 0);
		array_push(input_display_list, index + 1);
		array_push(input_display_list, index + 2);
		array_push(input_display_list, stat_label);
		return inputs[index + 0];
	} 
	
	input_display_list = [ new Inspector_Sprite(s_MKFX),
		["Surfaces",  false], 
	]
	
	setDynamicInput(3, true, VALUE_TYPE.surface);
	
	temp_surface = [ noone, noone, noone ];
	
	static processData = function(_outSurf, _data, _array_index) {
		var amo = getInputAmount();
		if(amo <= 0) return _outSurf;
		
		var _surf = _data[0];
		if(!is_surface(_surf)) return _outSurf;
			
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
			surface_clear(temp_surface[i]);
		}
		_outSurf = surface_verify(_outSurf, _sw, _sh);
		blend_temp_surface = temp_surface[2];
		
		var _bg = 0;
		
		for( var i = 0; i < amo; i++ ) {
			var _ind = input_fix_len + i * data_length;
			
			var _srf = _data[_ind + 0];
			var _pos = _data[_ind + 1];
			var _pal = _data[_ind + 2];
			
			var _ssw = surface_get_width_safe(_srf)  * _pal[0] / TOTAL_FRAMES;
			var _ssh = surface_get_height_safe(_srf) * _pal[1] / TOTAL_FRAMES;
			
			var stat_label = inputs[_ind].stat;
			stat_label.text = "";
			if((frac(_ssw) != 0 && frac(1/_ssw)) || (frac(_ssh) != 0 && frac(1/_ssh) != 0)) 
				stat_label.text = "Inconsistent speed detected. This may cause stutters. Consider adjusting the parallax speed or animation length.";
			
			var _sx = _pos[0] + _ssw * CURRENT_FRAME;
			var _sy = _pos[1] + _ssh * CURRENT_FRAME;
			
			surface_set_shader(temp_surface[_bg], noone, true, BLEND.over);
				draw_surface_blend_ext(temp_surface[!_bg], _srf, _sx, _sy, 1, 1, 0, c_white, 1, BLEND_MODE.normal, false, 1);
			surface_reset_shader();
			
			_bg = !_bg;
		}
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE
			draw_surface_safe(temp_surface[!_bg]);
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}