function Node_Color_Separate(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Separate Color";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Bool("All Colors", self, true));
	
	newInput(2, nodeValue_Palette("Colors", self, array_clone(DEF_PALETTE)));
	
	newInput(3, nodeValue_Bool("Match All", self, true, "If false, only match pixels with the exact same color."));
	
	input_display_list = [ 
		["Surfaces",  true], 0, 
		["Colors",   false], 1, 2, 3, 
	];
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	static extractAll = function(_surf) {
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		
		var c_buffer = buffer_create(ww * hh * 4, buffer_fixed, 4);
		
		buffer_get_surface(c_buffer, _surf, 0);
		buffer_seek(c_buffer, buffer_seek_start, 0);
		
		var amo     = ww * hh;
		var palette = array_create(amo), ind = 0;
		var bm      = 0b11111111 << 24;
		
		for( var i = 0; i < amo; i++ ) {
			var c = buffer_read(c_buffer, buffer_u32);
			if(c & bm == 0) continue;
			palette[ind++] = c;
		}
		
		buffer_delete(c_buffer);
		
		var _len = array_unique_ext(palette, 0, ind);
		array_resize(palette, _len);
		array_sort(palette, __sortHue);
		
		return palette;
	}
	
	static update = function() {
		var _surf = inputs[0].getValue();
		var _allc = inputs[1].getValue();
		var _colr = inputs[2].getValue();
		var _mata = inputs[3].getValue();
		
		inputs[2].setVisible(!_allc);
		inputs[3].setVisible(!_allc);
		
		if(!is_surface(_surf)) return;
		
		var _clist = _colr;
		if(_allc) _clist = extractAll(_surf);
		
		var _dim  = surface_get_dimension(_surf);
		var _outp = outputs[0].getValue();
		_outp = array_verify(_outp, array_length(_clist));
		
		for( var i = 0, n = array_length(_clist); i < n; i++ ) {
		    _outp[i] = surface_verify(_outp[i], _dim[0], _dim[1]);
		    
		    surface_set_shader(_outp[i], sh_separate_color);
		        shader_set_palette(_clist);
		        shader_set_color("color",     _clist[i]);
		        shader_set_i("matchAll",      !_allc && _mata);
		        
		        draw_surface(_surf, 0, 0);
		    surface_reset_shader();
		}
		
		outputs[0].setValue(_outp);
	}
}