function Node_MK_Tile(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Tile";
	dimension_index = -1;
	
	inputs[| 0] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Background Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 2] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Corner (18 sprites)", "Corner + Side (55 sprites)" ] );
	
	inputs[| 3] = nodeValue("Output Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Sheet", "Array" ] );
	
	inputs[| 4] = nodeValue("Crop", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 8, 8, 8, 8 ])
		.setDisplay(VALUE_DISPLAY.padding);
	
	inputs[| 5] = nodeValue("Edge Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Individual" ] );
	
	inputs[| 6] = nodeValue("Edge", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 7] = nodeValue("Edge bottom", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 8] = nodeValue("Edge left", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 9] = nodeValue("Edge right", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 10] = nodeValue("Edge shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.padding);
	
	input_display_list = [ 
		["Surfaces", false], 0, 1, 
		["Tiling",	 false], 2, 4, 
		["Edge",	 false], 10, 5, 6, 7, 8, 9, 
		["Output",	 false], 3, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	temp_surface = array_create(55);
	for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
		temp_surface[i] = array_create(1, 1);
	
	__edge_surface = array_create(4);
	edge_surface   = [];
	
	index_18 = [ 0,  8, 12,  4,  7, 11, 
				 0, 10, 15,  5, 13, 14, 
				 0,  2,  3,  1,  9,  6];
		
	index_55 = [208, 224, 104,  64, /**/  80, 120, 216,  72, /**/  88, 219,  -1, 
				148, 255,  41,  66, /**/  86, 127, 223,  75, /**/  95, 126,  -1, 
				 22,   7,  11,   2, /**/ 210, 251, 254, 106, /**/ 250, 218, 122, 
				 16,  24,   8,   0, /**/  18,  27,  30,  10, /**/  26,  94,  91, 
				 -1,  -1,  -1,  -1, /**/  82, 123, 222,  74, /**/  90,  -1,  -1];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		
	} #endregion
	
	static step = function() { #region
		var _edgType = getSingleValue(5);
		
		inputs[| 6].name = _edgType == 1? "Edge top" : "Edge"
		inputs[| 7].setVisible(_edgType == 1, _edgType == 1);
		inputs[| 8].setVisible(_edgType == 1, _edgType == 1);
		inputs[| 9].setVisible(_edgType == 1, _edgType == 1);
	} #endregion
	
	static generate18 = function(_data, _tex0, _tex1, _edge, _crop) { #region
		var _sprs = array_create(18);
		var _use1 = is_surface(_tex1);
		var _sw   = surface_get_width_safe(_tex0);
		var _sh   = surface_get_height_safe(_tex0);
		
		var r = _crop[0];
		var t = _crop[1];
		var l = _crop[2];
		var b = _crop[3];
		
		var _edgType = _data[5];
		var _et = _edge[0]; var _uet = is_surface(_et);
		var _eb = _edge[1]; var _ueb = is_surface(_eb);
		var _el = _edge[2]; var _uel = is_surface(_el);
		var _er = _edge[3]; var _uer = is_surface(_er);
		
		for( var i = 0; i < 18; i++ ) {
			var _index = index_18[i];
			if(_index < 0) {
				_sprs[i] = noone;
				continue;
			}
			var _s = surface_verify(temp_surface[i], _sw, _sh);
			
			surface_set_target(_s);
				DRAW_CLEAR
				BLEND_ALPHA_MULP
				
				if(_index == 15) draw_surface(_tex0, 0, 0);
				else if(_use1)	 draw_surface(_tex1, 0, 0);
				
				if(_index & 0b0001) draw_surface_part(_tex0, 0, 0, _sw - r, _sh - b, 0, 0);
				if(_index & 0b0010) draw_surface_part(_tex0, l, 0, _sw - l, _sh - b, l, 0);
				if(_index & 0b0100) draw_surface_part(_tex0, 0, t, _sw - r, _sh - t, 0, t);
				if(_index & 0b1000) draw_surface_part(_tex0, l, t, _sw - l, _sh - t, l, t);
				
				if(_index & 0b1100 >= 0b1100) draw_surface_part(_tex0, 0, t, _sw, _sh - t, 0, t);
				if(_index & 0b1010 >= 0b1010) draw_surface_part(_tex0, l, 0, _sw - l, _sh, l, 0);
				if(_index & 0b0101 >= 0b0101) draw_surface_part(_tex0, 0, 0, _sw - r, _sh, 0, 0);
				if(_index & 0b0011 >= 0b0011) draw_surface_part(_tex0, 0, 0, _sw, _sh - b, 0, 0);
				
				if(_uel) { #region
					shader_set(sh_mk_tile18_edge_l);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
						
					draw_surface_ext(_el, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				} #endregion
				
				if(_uer) { #region
					shader_set(sh_mk_tile18_edge_r);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
						
					draw_surface_ext(_er, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				} #endregion
				
				if(_uet) { #region
					shader_set(sh_mk_tile18_edge_t);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
						
					draw_surface_ext(_et, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				} #endregion
				
				if(_ueb) { #region
					shader_set(sh_mk_tile18_edge_b);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
						
					draw_surface_ext(_eb, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				} #endregion
				
				BLEND_NORMAL
			surface_reset_target();
			
			_sprs[i] = _s;
		}
		
		return _sprs;
	} #endregion
	
	static generate55 = function(_data, _tex0, _tex1, _edge, _crop) { #region
		var _sprs = array_create(55);
		var _use1 = is_surface(_tex1);
		var _sw   = surface_get_width_safe(_tex0);
		var _sh   = surface_get_height_safe(_tex0);
		
		var r = _crop[0];
		var t = _crop[1];
		var l = _crop[2];
		var b = _crop[3];
		
		var _et = _edge[0]; var _uet = is_surface(_et);
		var _eb = _edge[1]; var _ueb = is_surface(_eb);
		var _el = _edge[2]; var _uel = is_surface(_el);
		var _er = _edge[3]; var _uer = is_surface(_er);
		
		for( var i = 0; i < 55; i++ ) {
			var _index = index_55[i];
			if(_index < 0) {
				_sprs[i] = noone;
				continue;
			}
			
			var _s = surface_verify(temp_surface[i], _sw, _sh);
			
			surface_set_target(_s);
				DRAW_CLEAR
				BLEND_ALPHA_MULP
				
				if(_use1) draw_surface(_tex1, 0, 0);
				
				if(_index == 255) draw_surface(_tex0, 0, 0);
				else         draw_surface_part(_tex0, l, t, _sw - l - r, _sh - t - b, l, t);
				
				if(_index & 0b0100_0000 >= 0b0100_0000) draw_surface_part(_tex0, l, t, _sw - l - r, _sh - t, l, t);
				if(_index & 0b0000_0010 >= 0b0000_0010) draw_surface_part(_tex0, l, 0, _sw - l - r, _sh - b, l, 0);
				if(_index & 0b0001_0000 >= 0b0001_0000) draw_surface_part(_tex0, l, t, _sw - l, _sh - t - b, l, t);
				if(_index & 0b0000_1000 >= 0b0000_1000) draw_surface_part(_tex0, 0, t, _sw - r, _sh - t - b, 0, t);
				
				if(_index & 0b1110_0000 >= 0b1110_0000) draw_surface_part(_tex0, 0, t, _sw, _sh - t, 0, t);
				if(_index & 0b1001_0100 >= 0b1001_0100) draw_surface_part(_tex0, l, 0, _sw - l, _sh, l, 0);
				if(_index & 0b0010_1001 >= 0b0010_1001) draw_surface_part(_tex0, 0, 0, _sw - r, _sh, 0, 0);
				if(_index & 0b0000_0111 >= 0b0000_0111) draw_surface_part(_tex0, 0, 0, _sw, _sh - b, 0, 0);
				
				if(_index & 0b1101_0000 >= 0b1101_0000) draw_surface_part(_tex0, l, t, _sw - l, _sh - t, l, t);
				if(_index & 0b0110_1000 >= 0b0110_1000) draw_surface_part(_tex0, 0, t, _sw - r, _sh - t, 0, t);
				if(_index & 0b0000_1011 >= 0b0000_1011) draw_surface_part(_tex0, 0, 0, _sw - r, _sh - b, 0, 0);
				if(_index & 0b0001_0110 >= 0b0001_0110) draw_surface_part(_tex0, l, 0, _sw - l, _sh - b, l, 0);
				
				if(_uel) { #region
					shader_set(sh_mk_tile55_edge_l);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
						
					draw_surface_ext(_el, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				} #endregion
				
				if(_uer) { #region
					shader_set(sh_mk_tile55_edge_r);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
						
					draw_surface_ext(_er, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				} #endregion
				
				if(_uet) { #region
					shader_set(sh_mk_tile55_edge_t);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
						
					draw_surface_ext(_et, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				} #endregion
				
				if(_ueb) { #region
					shader_set(sh_mk_tile55_edge_b);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
						
					draw_surface_ext(_eb, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				} #endregion
				
				BLEND_NORMAL
			surface_reset_target();
			
			_sprs[i] = _s;
		}
		
		return _sprs;
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _tex0 = _data[0];
		var _tex1 = _data[1];
		var _type = _data[2];
		var _outp = _data[3];
		var _crop = _data[4];
		
		var _edgType = _data[5];
		var _edgeShf = _data[10];
		var _edges   = _edgType == 0? [ _data[6], _data[6], _data[6], _data[6] ] : [ _data[6], _data[7], _data[8], _data[9] ];
		var _edge;
		
		var _rt = [ 0, 180, 90, 270 ];
		var _sh = [ 1, 3, 2, 0 ];
		
		for( var i = 0; i < 4; i++ ) {
			var _ed = _edges[i];
			if(!is_surface(_ed)) {
				edge_surface[i] = noone;
				continue;
			}
			
			var _ew = surface_get_width_safe(_ed);
			var _eh = surface_get_height_safe(_ed);
					
			var _edShf = _edgeShf[_sh[i]];
			
			__edge_surface[i] = surface_verify(__edge_surface[i], _ew, _eh);
			surface_set_target(__edge_surface[i]);
				DRAW_CLEAR
				BLEND_OVERRIDE
				
				if(_edgType == 0) {
					var p = point_rotate(0, 0, _ew / 2, _eh / 2, _rt[i]);
					switch(i) {
						case 0 : p[1] += _edShf; break;
						case 1 : p[1] -= _edShf; break;
						case 2 : p[0] += _edShf; break;
						case 3 : p[0] -= _edShf; break;
					}
						
					draw_surface_ext(_ed, p[0], p[1], 1, 1, _rt[i], c_white, 1);
					
				} else {
					switch(i) {
						case 0 : draw_surface(_ed, 0,  _edShf); break;
						case 1 : draw_surface(_ed, 0, -_edShf); break;
						case 2 : draw_surface(_ed,  _edShf, 0); break;
						case 3 : draw_surface(_ed, -_edShf, 0); break;
					}
				}
				
				BLEND_NORMAL
			surface_reset_target();
			
			edge_surface[i] = __edge_surface[i];
		}
			
		_edge = edge_surface;
		
		if(!is_surface(_tex0)) return _outSurf;
		
		var _surfs = _type == 0? generate18(_data, _tex0, _tex1, _edge, _crop) : generate55(_data, _tex0, _tex1, _edge, _crop);
		
		if(_outp == 1) return _surfs;
		
		var _sw  = surface_get_width_safe(_tex0);
		var _sh  = surface_get_height_safe(_tex0);
		var _col = _type == 0? 6 : 11;
		var _row = _type == 0? 3 :  5;
		
		var _w   = _sw * _col;
		var _h   = _sh * _row;
		_outSurf = surface_verify(_outSurf, _w, _h);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE
			
			for( var i = 0, n = array_length(_surfs); i < n; i++ ) {
				var _surf = _surfs[i];
				if(!is_surface(_surf)) continue;
				
				var _r = floor(i / _col);
				var _c = i % _col;
				
				var _x = _sw * _c;
				var _y = _sh * _r;
				
				draw_surface(_surf, _x, _y);
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	} #endregion
}