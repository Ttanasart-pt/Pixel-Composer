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
	
	inputs[| 6] = nodeValue("Edge",			self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	inputs[| 7] = nodeValue("Edge bottom",	self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	inputs[| 8] = nodeValue("Edge left",	self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	inputs[| 9] = nodeValue("Edge right",	self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 10] = nodeValue("Edge shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.padding);
		
	inputs[| 11] = nodeValue("Full edge", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.toggle, { data: [ "T", "B", "L", "R" ] });
	
	inputs[| 12] = nodeValue("Extend edge", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	inputs[| 13] = nodeValue("Edge sprite", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Single", "Side + Center", "Side + Center + Side" ] );
	
	input_display_list = [ 
		["Surfaces", false], 0, 1, 
		["Tiling",	 false], 2, 4, 
		["Edge",	 false], 5, 13, 10, 11, 12, 
		["Edge Textures", true], 6, 7, 8, 9, 
		["Output",	 false], 3, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	temp_surface = array_create(55);
	for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
		temp_surface[i] = array_create(1, 1);
	
	__edge_surface = array_create(12);
	__edge_buffer  = [ surface_create(1, 1), surface_create(1, 1)];
	edge_surface   = [];
	
	#region index
		index_18 = [ 0,  8, 12,  4,  7, 11, 
					 0, 10, 15,  5, 13, 14, 
					 0,  2,  3,  1,  9,  6];
		
		index_18_et = [ 0, 0, 1, 2, 0, 0, 
					    0, 0, 0, 0, 0, 2, 
					    0, 0, 0, 0, 0, 2];
		
		index_18_eb = [ 0, 0, 0, 0, 0, 2, 
					    0, 0, 0, 0, 0, 0, 
					    0, 0, 1, 2, 2, 0];
		
		index_18_el = [ 0, 0, 0, 0, 0, 0, 
					    0, 1, 0, 0, 0, 2, 
					    0, 2, 0, 0, 0, 2];
		
		index_18_er = [ 0, 0, 0, 0, 0, 0, 
					    0, 0, 0, 1, 2, 0, 
					    0, 0, 0, 2, 2, 0];
		
		index_55 = [208, 224, 104, /**/  64, /**/  80, 120, 216,  72, /**/  88, 219,  -1, 
					148, 255,  41, /**/  66, /**/  86, 127, 223,  75, /**/  95, 126,  -1, 
					 22,   7,  11, /**/   2, /**/ 210, 251, 254, 106, /**/ 250, 218, 122, 
					 16,  24,   8, /**/   0, /**/  18,  27,  30,  10, /**/  26,  94,  91, 
					 -1,  -1,  -1, /**/  -1, /**/  82, 123, 222,  74, /**/  90,  -1,  -1];
		
		index_55_et = [ 0, 1, 2, /**/ 1, /**/ 0, 1, 1, 0, /**/ 1, 0, 0,  
					    0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 2, 0,  
					    0, 0, 0, /**/ 0, /**/ 0, 0, 2, 2, /**/ 0, 0, 0, 
						0, 1, 2, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0,  
					    0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0, ];
		
		index_55_eb = [ 0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0,  
					    0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0,  
					    0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0, 
						0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0,  
					    0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0, ];
		
		index_55_el = [ 0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0,  
					    0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0,  
					    0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0, 
						0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0,  
					    0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0, ];
		
		index_55_er = [ 0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0,  
					    0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0,  
					    0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0, 
						0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0,  
					    0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 0, 0, ];
	#endregion
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		
	} #endregion
	
	static step = function() { #region
		var _edgType = getSingleValue( 5);
		var _edgFull = getSingleValue(11);
		
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
		
		var _edgeShf = _data[10];
		var _edgFull = _data[11];
		var _edgExtn = _data[12];
		
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
				
				var _et = _edge[0][index_18_et[i]];
				var _eb = _edge[1][index_18_eb[i]];
				var _el = _edge[2][index_18_el[i]];
				var _er = _edge[3][index_18_er[i]];
				
				if(_el != noone) { #region
					shader_set(sh_mk_tile18_edge_l);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b0100));
					shader_set_i("extendEdge", _edgExtn);
						
					draw_surface_ext(_el, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				} #endregion
				
				if(_er != noone) { #region
					shader_set(sh_mk_tile18_edge_r);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b1000));
					shader_set_i("extendEdge", _edgExtn);
					
					
					draw_surface_ext(_er, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				} #endregion
				
				if(_et != noone) { #region
					shader_set(sh_mk_tile18_edge_t);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b0001));
					shader_set_i("extendEdge", _edgExtn);
					
					draw_surface_ext(_et, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				} #endregion
				
				if(_eb != noone) { #region
					shader_set(sh_mk_tile18_edge_b);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b0010));
					shader_set_i("extendEdge", _edgExtn);
						
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
		
		var _edgFull = _data[11];
		var _edgExtn = _data[12];
		
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
				
				var _et = _edge[0][1];
				var _eb = _edge[1][1];
				var _el = _edge[2][1];
				var _er = _edge[3][1];
				
				if(_el == noone) { #region
					shader_set(sh_mk_tile55_edge_l);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b0100));
					shader_set_i("extendEdge", _edgExtn);
						
					draw_surface_ext(_el, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				} #endregion
				
				if(_er == noone) { #region
					shader_set(sh_mk_tile55_edge_r);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b1000));
					shader_set_i("extendEdge", _edgExtn);
						
					draw_surface_ext(_er, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				} #endregion
				
				if(_et == noone) { #region
					shader_set(sh_mk_tile55_edge_t);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b0001));
					shader_set_i("extendEdge", _edgExtn);
						
					draw_surface_ext(_et, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				} #endregion
				
				if(_eb == noone) { #region
					shader_set(sh_mk_tile55_edge_b);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b0010));
					shader_set_i("extendEdge", _edgExtn);
						
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
		var _edgFull = _data[11];
		var _edgSprt = _data[13];
		var _edges   = _edgType == 0? [ _data[6], _data[6], _data[6], _data[6] ] : [ _data[6], _data[7], _data[8], _data[9] ];
		var _edge;
		
		var _rot = [ 0, 180, 90, 270 ];
		var _shi = [ 1, 3, 2, 0 ];
		
		var _sw = surface_get_width_safe(_tex0);
		var _sh = surface_get_height_safe(_tex0);
		var _pp;
		
		for( var i = 0, n = array_length(__edge_buffer); i < n; i++ )
			__edge_buffer[i] = surface_verify(__edge_buffer[i], _sw, _sh);
		
		for( var i = 0; i < 4; i++ ) {
			var _ed    = _edges[i];
			var _edShf = _edgeShf[_shi[i]];
			
			edge_surface[i] = [ noone, noone, noone ];
			if(!is_surface(_ed)) continue;
			
			var _ew  = surface_get_width_safe(_ed);
			var _eh  = surface_get_height_safe(_ed);
			var _am  = _edgSprt + 1;
			var _esw = _ew > _eh? _ew / _am : 0;
			var _esh = _ew > _eh? 0 : _eh / _am;
			
			for( var j = 0; j < 3; j++ ) {
				var _sIndx = i * 3 + j;
				var _edBuf = _ed;
				
				__edge_surface[_sIndx] = surface_verify(__edge_surface[_sIndx], _sw, _sh);
				
				if(_edgSprt) {
					surface_set_target(__edge_buffer[0]); #region
						DRAW_CLEAR
						BLEND_OVERRIDE
					
						if(_edgSprt == 1) {
							switch(j) {
								case 0 : draw_surface(_ed, -_esw * 0, -_esh * 0); break;
								case 1 : draw_surface(_ed, -_esw * 1, -_esh * 1); break;
								case 2 : draw_surface(_ed, -_esw * 0, -_esh * 0); break;
							}
						} else if(_edgSprt == 2) {
							switch(j) {
								case 0 : draw_surface(_ed, -_esw * 0, -_esh * 0); break;
								case 1 : draw_surface(_ed, -_esw * 1, -_esh * 1); break;
								case 2 : draw_surface(_ed, -_esw * 2, -_esh * 2); break;
							}
						}
					
						BLEND_NORMAL
					surface_reset_target(); #endregion
					
					_edBuf = __edge_buffer[0];
					
					if(_edgSprt == 1 && j == 2) {
						surface_set_target(__edge_buffer[1]); #region
							DRAW_CLEAR
							BLEND_OVERRIDE
					
							if(i == 0 || i == 1) draw_surface_ext(__edge_buffer[0], _sw, 0, -1, 1, 0, c_white, 1);
							if(i == 2 || i == 3) draw_surface_ext(__edge_buffer[0], 0, _sh, 1, -1, 0, c_white, 1);
						
							BLEND_NORMAL
						surface_reset_target(); #endregion
						
						_edBuf = __edge_buffer[1];
					}
				}
				
				surface_set_target(__edge_surface[_sIndx]); #region
					DRAW_CLEAR
					BLEND_OVERRIDE
					
					var _rr = 0;
					var _xx = 0;
					var _yy = 0;
					
					if(_edgType == 0) {
						_rr = _rot[i];
						
						if(_edgSprt) {
							if(i == 1 && j != 1) _rr += 180;
							if(i == 2 && j == 0) _rr += 180;
							if(i == 3 && j == 2) _rr += 180;
						}
						
						_pp = point_rotate(0, 0, _sw / 2, _sh / 2, _rr);
						_xx = _pp[0];
						_yy = _pp[1];
					} 
					
					switch(i) {
						case 0 : _yy += _edShf; break;
						case 1 : _yy -= _edShf; break;
						case 2 : _xx += _edShf; break;
						case 3 : _xx -= _edShf; break;
					}
					
					draw_surface_ext(_edBuf, _xx, _yy, 1, 1, _rr, c_white, 1);
					
					BLEND_NORMAL
				surface_reset_target(); #endregion
				
				edge_surface[i][j] = __edge_surface[_sIndx];
			}
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