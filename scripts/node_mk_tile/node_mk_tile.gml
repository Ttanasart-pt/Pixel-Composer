function Node_MK_Tile(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Tile";
	dimension_index = -1;
	
	newInput(0, nodeValue_Surface("Texture", self));
	
	newInput(1, nodeValue_Surface("Background texture", self));
	
	newInput(2, nodeValue_Enum_Button("Type", self,  0, [ "GMS Corner (18 sprites)", "GMS Corner + Side (55 sprites)", "Godot Blob (48 sprites)" ] ));
	
	newInput(3, nodeValue_Enum_Button("Output type", self,  0, [ "Sheet", "Array" ] ));
	
	newInput(4, nodeValue_Padding("Crop", self, [ 8, 8, 8, 8 ]));
	
	newInput(5, nodeValue_Enum_Button("Edge type", self,  0, [ "Uniform", "Individual" ] ));
	
	newInput(6, nodeValue_Surface("Edge",			self));
	newInput(7, nodeValue_Surface("Edge bottom",	self));
	newInput(8, nodeValue_Surface("Edge left",	self));
	newInput(9, nodeValue_Surface("Edge right",	self));
	
	newInput(10, nodeValue_Padding("Edge shift", self, [ 0, 0, 0, 0 ]));
		
	newInput(11, nodeValue_Toggle("Full edge", self, 0, { data: [ "T", "B", "L", "R" ] }));
	
	newInput(12, nodeValue_Enum_Scroll("Edge sprite", self,  0, [ "Single", "Side + Center", "Side + Center + Side" ] ));
	
	newInput(13, nodeValue_Enum_Button("Edge transform", self,  0, [ "Flip", "Rotate" ] ));
		
	newInput(14, nodeValue_Bool("Sort array by bit", self, true))
		
	input_display_list = [ new Inspector_Sprite(s_MKFX), 
		["Surfaces",	  true], 0, 1, 
		["Tile set",	 false], 2, 4, 
		["Edge",		 false], 5, 12, 13, 10, 11,
		["Edge Textures", true], 6, 7, 8, 9, 
		["Output",		 false], 3, 14, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	temp_surface = array_create(55);
	for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
		temp_surface[i] = array_create(1, 1);
	
	__edge_uniform = array_create(4);
	__edge_surface = array_create(4 * 7);
	__edge_buffer  = [ surface_create(1, 1), surface_create(1, 1), surface_create(1, 1) ];
	edge_surface   = [];
	
	attributes.show_tile_index = false;
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, ["Show index", function() /*=>*/ {return attributes.show_tile_index}, new checkBox(function() /*=>*/ {return toggleAttribute("show_tile_index")}) ]);
	
	#region overlay
		tile_overlay_select = noone;
	#endregion
	
	#region index
		index_18 = [ 0, /**/  8, 12,  4, /**/  7, 11, 
					 0, /**/ 10, 15,  5, /**/ 13, 14, 
					 0, /**/  2,  3,  1, /**/  9,  6];
		
		index_18_et = [ 0, /**/ 0, 1, 2, /**/ 0, 0, 
					    0, /**/ 0, 0, 0, /**/ 3, 4, 
					    0, /**/ 0, 0, 0, /**/ 3, 4];
		
		index_18_eb = [ 0, /**/ 0, 0, 0, /**/ 3, 4, 
					    0, /**/ 0, 0, 0, /**/ 0, 0, 
					    0, /**/ 0, 1, 2, /**/ 4, 3];
		
		index_18_el = [ 0, /**/ 0, 0, 0, /**/ 0, 3, 
					    0, /**/ 1, 0, 0, /**/ 0, 4, 
					    0, /**/ 2, 0, 0, /**/ 3, 4];
		
		index_18_er = [ 0, /**/ 0, 0, 0, /**/ 3, 0, 
					    0, /**/ 0, 0, 1, /**/ 4, 0, 
					    0, /**/ 0, 0, 2, /**/ 4, 3];
		
		/////////////////////////////////////////////////////////////////////
		
		index_55 = [208, 224, 104, /**/  64, /**/  80, 120, 216,  72, /**/  88, 219,  -1, 
					148, 255,  41, /**/  66, /**/  86, 127, 223,  75, /**/  95, 126,  -1, 
					 22,   7,  11, /**/   2, /**/ 210, 251, 254, 106, /**/ 250, 218, 122, 
					 16,  24,   8, /**/   0, /**/  18,  27,  30,  10, /**/  26,  94,  91, 
					 -1,  -1,  -1, /**/  -1, /**/  82, 123, 222,  74, /**/  90,  -1,  -1];
		
		index_55_et = [ 0, 1, 2, /**/ 5, /**/ 0, 1, 1, 2, /**/ 1, 3, 0,  
					    0, 0, 0, /**/ 0, /**/ 0, 0, 0, 0, /**/ 0, 4, 0,  
					    0, 0, 0, /**/ 0, /**/ 3, 3, 4, 4, /**/ 6, 6, 6, 
						0, 1, 2, /**/ 5, /**/ 3, 3, 4, 4, /**/ 6, 3, 4,  
					    0, 0, 0, /**/ 0, /**/ 3, 3, 4, 4, /**/ 6, 0, 0, ];
		
		index_55_eb = [ 0, 0, 0, /**/ 0, /**/ 3, 3, 4, 4, /**/ 6, 4, 0, 
					    0, 0, 0, /**/ 0, /**/ 3, 3, 4, 4, /**/ 6, 3, 0,  
					    0, 1, 2, /**/ 5, /**/ 0, 0, 0, 0, /**/ 0, 4, 3, 
						0, 1, 2, /**/ 5, /**/ 0, 1, 1, 2, /**/ 1, 6, 6, 
					    0, 0, 0, /**/ 0, /**/ 3, 3, 4, 4, /**/ 6, 0, 0, ];
		
		index_55_el = [ 0, 0, 0, /**/ 0, /**/ 0, 0, 3, 3, /**/ 4, 3, 0,  
					    1, 0, 0, /**/ 1, /**/ 1, 0, 3, 3, /**/ 4, 4, 0,  
					    2, 0, 0, /**/ 2, /**/ 1, 0, 4, 4, /**/ 4, 6, 4, 
						5, 0, 0, /**/ 5, /**/ 2, 0, 4, 4, /**/ 4, 6, 3,  
					    0, 0, 0, /**/ 0, /**/ 1, 0, 6, 6, /**/ 6, 0, 0, ];
		
		index_55_er = [ 0, 0, 0, /**/ 0, /**/ 3, 3, 0, 0, /**/ 3, 4, 0,  
					    0, 0, 1, /**/ 1, /**/ 3, 3, 0, 1, /**/ 3, 3, 0,  
					    0, 0, 2, /**/ 2, /**/ 4, 4, 0, 1, /**/ 4, 4, 6, 
						0, 0, 5, /**/ 5, /**/ 4, 4, 0, 2, /**/ 4, 3, 6,  
					    0, 0, 0, /**/ 0, /**/ 6, 6, 0, 1, /**/ 6, 0, 0, ];
						
		/////////////////////////////////////////////////////////////////////
		
		index_48 = [ 64,  80,  88, 72, /**/  91, 216, 120,  94, /**/ 208, 250, 224, 104, 
					 66,  82,  90, 74, /**/ 210, 254, 251, 106, /**/ 148, 126,  -1, 123, 
					  2,  18,  26, 10, /**/  86, 223, 127,  75, /**/ 222, 255, 219,  41, 
					  0,  16,  24,  8, /**/ 122,  30,  27, 218, /**/  22,   7,  95,  11, ];
		
		index_48_et = [ 5, 0, 1, 2, 4, 1, 1, 3, 0, 6, 1, 2, 
		                0, 3, 6, 4, 3, 4, 3, 4, 0, 4, 0, 3, 
						0, 3, 6, 4, 0, 0, 0, 0, 4, 0, 3, 0, 
						5, 0, 1, 2, 6, 4, 3, 6, 0, 0, 0, 0, ];
																   
		index_48_eb = [ 0, 3, 6, 4, 6, 4, 3, 6, 0, 0, 0, 0, 
						0, 3, 6, 4, 0, 0, 0, 0, 0, 3, 0, 3, 
						5, 0, 1, 2, 3, 4, 3, 4, 4, 0, 4, 0, 
						5, 0, 1, 2, 3, 1, 1, 4, 0, 1, 6, 2, ];
																   
		index_48_el = [ 0, 0, 4, 3, 3, 3, 0, 6, 0, 4, 0, 0, 
						1, 1, 6, 6, 1, 4, 0, 4, 1, 4, 0, 0, 
						2, 2, 4, 4, 1, 3, 0, 3, 6, 0, 3, 0, 
						5, 5, 0, 0, 4, 4, 0, 6, 2, 0, 4, 0, ];
																   
		index_48_er = [ 0, 3, 3, 0, 6, 0, 3, 3, 0, 4, 0, 0, 
						1, 6, 6, 1, 4, 0, 4, 1, 0, 3, 0, 6, 
						2, 4, 4, 2, 3, 0, 3, 1, 0, 0, 4, 1, 
						5, 0, 0, 5, 6, 0, 4, 4, 0, 0, 3, 2, ];
						
	#endregion
	
	static step = function() {
		var _outType = getSingleValue( 3);
		var _edgType = getSingleValue( 5);
		var _edgFull = getSingleValue(11);
		
		inputs[ 6].name = _edgType == 1? "Edge top" : "Edge"
		inputs[ 7].setVisible(_edgType == 1, _edgType == 1);
		inputs[ 8].setVisible(_edgType == 1, _edgType == 1);
		inputs[ 9].setVisible(_edgType == 1, _edgType == 1);
		inputs[13].setVisible(_edgType == 0);
		inputs[14].setVisible(_outType == 1);
	}
	
	static generateFull = function(_data, _tex0, _tex1, _edge, _crop, indMain, indEdge_et, indEdge_eb, indEdge_el, indEdge_er) {
		var _len  = array_length(indMain);
		var _sprs = array_create(_len);
		var _use1 = is_surface(_tex1);
		var _sw   = surface_get_width_safe(_tex0);
		var _sh   = surface_get_height_safe(_tex0);
		
		var r = _crop[0];
		var t = _crop[1];
		var l = _crop[2];
		var b = _crop[3];
		
		var _edgFull = _data[11];
		
		for( var i = 0; i < _len; i++ ) {
			var _index = indMain[i];
			if(_index < 0) {
				_sprs[i] = noone;
				continue;
			}
			
			var _s = surface_verify(temp_surface[i], _sw, _sh);
			
			surface_set_target(_s);
				DRAW_CLEAR
				BLEND_ALPHA_MULP
				
				if(_use1) draw_surface_safe(_tex1);
				
				if(_index == 255) draw_surface_safe(_tex0);
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
				
				var _et = _edge[0][indEdge_et[i]];
				var _eb = _edge[1][indEdge_eb[i]];
				var _el = _edge[2][indEdge_el[i]];
				var _er = _edge[3][indEdge_er[i]];
				
				if(_el != noone) {
					shader_set(sh_mk_tile55_edge_l);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b0100));
						
					draw_surface_ext(_el, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				}
				
				if(_er != noone) {
					shader_set(sh_mk_tile55_edge_r);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b1000));
						
					draw_surface_ext(_er, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				}
				
				if(_et != noone) {
					shader_set(sh_mk_tile55_edge_t);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b0001));
						
					draw_surface_ext(_et, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				}
				
				if(_eb != noone) {
					shader_set(sh_mk_tile55_edge_b);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b0010));
						
					draw_surface_ext(_eb, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				}
				
				BLEND_NORMAL
			surface_reset_target();
			
			_sprs[i] = _s;
		}
		
		return _sprs;
	}
	
	static generateSimple = function(_data, _tex0, _tex1, _edge, _crop, indMain, indEdge_et, indEdge_eb, indEdge_el, indEdge_er) {
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
		
		for( var i = 0; i < 18; i++ ) {
			var _index = indMain[i];
			if(_index < 0) {
				_sprs[i] = noone;
				continue;
			}
			var _s = surface_verify(temp_surface[i], _sw, _sh);
			
			surface_set_target(_s);
				DRAW_CLEAR
				BLEND_ALPHA_MULP
				
				if(_index == 15) draw_surface_safe(_tex0);
				else if(_use1)	 draw_surface_safe(_tex1);
				
				if(_index & 0b0001) draw_surface_part(_tex0, 0, 0, _sw - r, _sh - b, 0, 0);
				if(_index & 0b0010) draw_surface_part(_tex0, l, 0, _sw - l, _sh - b, l, 0);
				if(_index & 0b0100) draw_surface_part(_tex0, 0, t, _sw - r, _sh - t, 0, t);
				if(_index & 0b1000) draw_surface_part(_tex0, l, t, _sw - l, _sh - t, l, t);
				
				if(_index & 0b1100 >= 0b1100) draw_surface_part(_tex0, 0, t, _sw, _sh - t, 0, t);
				if(_index & 0b1010 >= 0b1010) draw_surface_part(_tex0, l, 0, _sw - l, _sh, l, 0);
				if(_index & 0b0101 >= 0b0101) draw_surface_part(_tex0, 0, 0, _sw - r, _sh, 0, 0);
				if(_index & 0b0011 >= 0b0011) draw_surface_part(_tex0, 0, 0, _sw, _sh - b, 0, 0);
				
				var _et = _edge[0][indEdge_et[i]];
				var _eb = _edge[1][indEdge_eb[i]];
				var _el = _edge[2][indEdge_el[i]];
				var _er = _edge[3][indEdge_er[i]];
				
				if(_el != noone) {
					shader_set(sh_mk_tile18_edge_l);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b0100));
					
					draw_surface_ext(_el, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				}
				
				if(_er != noone) {
					shader_set(sh_mk_tile18_edge_r);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b1000));
					
					draw_surface_ext(_er, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				}
				
				if(_et != noone) {
					shader_set(sh_mk_tile18_edge_t);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b0001));
					
					draw_surface_ext(_et, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				}
				
				if(_eb != noone) {
					shader_set(sh_mk_tile18_edge_b);
					shader_set_f("dimension", _sw, _sh);
					shader_set_f("crop", _crop);
					shader_set_i("edge", _index);
					shader_set_i("fullEdge", bool(_edgFull & 0b0010));
						
					draw_surface_ext(_eb, 0, 0, 1, 1, 0, c_white, 1);
					shader_reset();
				}
				
				BLEND_NORMAL
			surface_reset_target();
			
			_sprs[i] = _s;
		}
		
		return _sprs;
	}
	
	static generate18 = function(_data, _tex0, _tex1, _edge, _crop) { INLINE return generateSimple(_data, _tex0, _tex1, _edge, _crop, index_18, index_18_et, index_18_eb, index_18_el, index_18_er); }
	static generate55 = function(_data, _tex0, _tex1, _edge, _crop) { INLINE return generateFull(  _data, _tex0, _tex1, _edge, _crop, index_55, index_55_et, index_55_eb, index_55_el, index_55_er); }
	static generate48 = function(_data, _tex0, _tex1, _edge, _crop) { INLINE return generateFull(  _data, _tex0, _tex1, _edge, _crop, index_48, index_48_et, index_48_eb, index_48_el, index_48_er); }
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _tex0 = _data[0];
		var _tex1 = _data[1];
		var _type = _data[2];
		var _outp = _data[3];
		var _crop = _data[4];
		
		var _edgType = _data[5];
		var _edgeShf = _data[10];
		var _edgFull = _data[11];
		var _edgSprt = _data[12];
		var _edgTran = _data[13];
		var _edges   = _edgType == 0? [ _data[6], _data[6], _data[6], _data[6] ] : [ _data[6], _data[7], _data[8], _data[9] ];
		var _edge;
		
		var _shi = [ 1, 3, 2, 0 ];
		
		var _sw = surface_get_width_safe(_tex0);
		var _sh = surface_get_height_safe(_tex0);
		var _pp;
		
		for( var i = 0, n = array_length(__edge_buffer); i < n; i++ )
			__edge_buffer[i] = surface_verify(__edge_buffer[i], _sw, _sh);
		
		if(_edgType == 0 && is_surface(_data[6])) {
			var _esw = surface_get_width_safe(_data[6]);
			var _esh = surface_get_height_safe(_data[6]);
			
			__edge_uniform[0] = surface_verify(__edge_uniform[0], _esw, _esh);
			__edge_uniform[1] = surface_verify(__edge_uniform[1], _esw, _esh);
			__edge_uniform[2] = surface_verify(__edge_uniform[2], _esh, _esw);
			__edge_uniform[3] = surface_verify(__edge_uniform[3], _esh, _esw);
			
			surface_set_shader(__edge_uniform[0], noone);
				draw_surface_safe(_data[6]);
			surface_reset_shader();
			
			surface_set_shader(__edge_uniform[1], noone);
				draw_surface_ext(_data[6], 0, _esh, 1, -1, 0, c_white, 1);
			surface_reset_shader();
			
			surface_set_shader(__edge_uniform[2], noone);
				draw_surface_ext(_data[6], 0, 0, -1, 1, 90, c_white, 1);
			surface_reset_shader();
			
			surface_set_shader(__edge_uniform[3], noone);
				draw_surface_ext(_data[6], _esh, 0, -1, -1, 90, c_white, 1);
			surface_reset_shader();
			
			_edges = __edge_uniform;
		}
		
		for( var i = 0; i < 4; i++ ) { //edges
			var _ed    = _edges[i];
			var _edShf = _edgeShf[_shi[i]];
			
			edge_surface[i] = array_create(7, noone);
			if(!is_surface(_ed)) continue;
			
			var _ew  = surface_get_width_safe(_ed);
			var _eh  = surface_get_height_safe(_ed);
			var _am  = _edgSprt + 1;
			var _esw = _ew > _eh? _ew / _am : 0;
			var _esh = _ew > _eh? 0 : _eh / _am;
			
			for( var j = 0; j < 7; j++ ) {
				var _sIndx = i * 7 + j;
				var _edBuf = _ed;
				
				__edge_surface[_sIndx] = surface_verify(__edge_surface[_sIndx], _sw, _sh);
				
				surface_set_target(__edge_buffer[0]);
					DRAW_CLEAR
					BLEND_OVERRIDE
					
					if(_edgSprt == 0) { 
						draw_surface_safe(_ed); 
					} else if(_edgSprt == 1) { // flip side
						switch(j) {
							case 0 : draw_surface(_ed, -_esw * 0, -_esh * 0); break;
							case 1 : draw_surface(_ed, -_esw * 1, -_esh * 1); break;
							case 2 : draw_surface(_ed, -_esw * 0, -_esh * 0); break;
							case 3 : 
							case 4 : 
							case 5 : 
							case 6 : draw_surface(_ed, -_esw * 0, -_esh * 0); break;
						}
					} else if(_edgSprt == 2) { // indiviual sides
						switch(j) {
							case 0 : draw_surface(_ed, -_esw * 0, -_esh * 0); break;
							case 1 : draw_surface(_ed, -_esw * 1, -_esh * 1); break;
							case 2 : draw_surface(_ed, -_esw * 2, -_esh * 2); break;
						}
					}
					
					BLEND_NORMAL
				surface_reset_target();
					
				_edBuf = __edge_buffer[0];
				
				if(_edgType == 0 && _edgTran == 1) { // rotate surface for uniform edge type
					surface_set_target(__edge_buffer[1]);
						DRAW_CLEAR
						BLEND_ALPHA_MULP
						
						switch(i) {
							//case 1 : draw_surface_ext(_edBuf, _sw, 0, -1, 1, 0, c_white, 1); break;
							case 3 : draw_surface_ext(_edBuf, 0, _sh, 1, -1, 0, c_white, 1); break;
							default: draw_surface_ext(_edBuf, 0, 0, 1, 1, 0, c_white, 1);    break;
						}
						
						BLEND_NORMAL
					surface_reset_target();
						
					_edBuf = __edge_buffer[1];
				} 
				
				if(_edgSprt == 1 && j >= 2) {
					surface_set_target(__edge_buffer[2]);
						DRAW_CLEAR
						BLEND_ALPHA_MULP
							
						if(j == 2) { // flip surface
							if(i == 0 || i == 1) draw_surface_ext(_edBuf, _sw, 0, -1, 1, 0, c_white, 1); // flip x
							if(i == 2 || i == 3) draw_surface_ext(_edBuf, 0, _sh, 1, -1, 0, c_white, 1); // flip y
						} else if(j == 3) {
							if(i == 0 || i == 1) draw_surface_part_ext(_edBuf, 0, 0, _sw / 2, _sh, _sw / 2, 0,  1, 1, c_white, 1);
							if(i == 2 || i == 3) draw_surface_part_ext(_edBuf, 0, 0, _sw, _sh / 2, 0, _sh / 2,  1, 1, c_white, 1);
						} else if(j == 4) {
							if(i == 0 || i == 1) draw_surface_part_ext(_edBuf, 0, 0, _sw / 2, _sh, _sw / 2, 0, -1, 1, c_white, 1);
							if(i == 2 || i == 3) draw_surface_part_ext(_edBuf, 0, 0, _sw, _sh / 2, 0, _sh / 2, 1, -1, c_white, 1);
						} else if(j == 5) {
							if(i == 0 || i == 1) {
								draw_surface_part_ext(_edBuf, 0, 0, _sw / 2, _sh,   0, 0,  1, 1, c_white, 1);
								draw_surface_part_ext(_edBuf, 0, 0, _sw / 2, _sh, _sw, 0, -1, 1, c_white, 1);
							}
								
							if(i == 2 || i == 3) {
								draw_surface_part_ext(_edBuf, 0, 0, _sw, _sh / 2, 0,   0, 1,  1, c_white, 1);
								draw_surface_part_ext(_edBuf, 0, 0, _sw, _sh / 2, 0, _sh, 1, -1, c_white, 1);
							}
						} else if(j == 6) {
							if(i == 0 || i == 1) {
								draw_surface_part_ext(_edBuf, 0, 0, _sw / 2, _sh, _sw / 2, 0,  1, 1, c_white, 1);
								draw_surface_part_ext(_edBuf, 0, 0, _sw / 2, _sh, _sw / 2, 0, -1, 1, c_white, 1);
							}
								
							if(i == 2 || i == 3) {
								draw_surface_part_ext(_edBuf, 0, 0, _sw, _sh / 2, 0, _sh / 2, 1,  1, c_white, 1);
								draw_surface_part_ext(_edBuf, 0, 0, _sw, _sh / 2, 0, _sh / 2, 1, -1, c_white, 1);
							}
						}
							
						BLEND_NORMAL
					surface_reset_target();
						
					_edBuf = __edge_buffer[2];
				}
				
				surface_set_target(__edge_surface[_sIndx]);
					DRAW_CLEAR
					BLEND_OVERRIDE
					
					var _xx = 0;
					var _yy = 0;
					
					switch(i) {
						case 0 : _yy += _edShf; break;
						case 1 : _yy -= _edShf; break;
						case 2 : _xx += _edShf; break;
						case 3 : _xx -= _edShf; break;
					}
					
					draw_surface(_edBuf, _xx, _yy);
					
					BLEND_NORMAL
				surface_reset_target();
				
				edge_surface[i][j] = __edge_surface[_sIndx];
			}
		}
			
		_edge = edge_surface;
		
		if(!is_surface(_tex0)) return _outSurf;
		
		var _surfs = [];
		var _col   = 1;
		var _row   = 1;
		
		switch(_type) {
			case 0 : 
				_surfs = generate18(_data, _tex0, _tex1, _edge, _crop); 
				_col   = 6;
				_row   = 3;
				break;
				
			case 1 : 
				_surfs = generate55(_data, _tex0, _tex1, _edge, _crop); 
				_col   = 11;
				_row   = 5;
				break;
				
			case 2 : 
				_surfs = generate48(_data, _tex0, _tex1, _edge, _crop); 
				_col   = 12;
				_row   = 4;
				break;
		}
		
		if(_outp == 1) return _surfs;
		
		var _sw  = surface_get_width_safe(_tex0);
		var _sh  = surface_get_height_safe(_tex0);
		
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
	}

	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!attributes.show_tile_index) return;
		
		var _tex = getSingleValue(0);
		var _typ = getSingleValue(2);
		var _out = getSingleValue(0,, true);
		
		if(!is_surface(_tex)) return;
		if(!is_surface(_out)) return;
		
		var _dim = surface_get_dimension(_tex);
		var _oim = surface_get_dimension(_out);
		var _til = [ _oim[0] / _dim[0], _oim[1] / _dim[1] ];
		var _tw  = _dim[0] * _s;
		var _th  = _dim[1] * _s;
		
		////////////////////////////////////////////////////////////////////////////////////////
		
		draw_set_color(COLORS._main_icon_light);
		draw_set_alpha(0.5);
			for(var i = 1; i < _til[0]; i++) {
				var _lx = _x + i * _tw;
				draw_line(_lx, _y, _lx, _y + _oim[1] * _s);
			}
			
			for(var i = 1; i < _til[1]; i++) {
				var _ly = _y + i * _th;
				draw_line(_x, _ly, _x + _oim[0] * _s, _ly);
			}
		draw_set_alpha(1);
		
		////////////////////////////////////////////////////////////////////////////////////////
		
		var _bitmask_draw = false;
		var _bitmask_x    = 0;
		var _bitmask_y    = 0;
		
		for(var i = 0; i < _til[1]; i++) {
			var _ly = _y + i * _th;
			
			for(var j = _typ? 0 : 1; j < _til[0]; j++) {
				var _lx = _x + j * _tw;
				var _id = _typ? i * _til[0] + j : i * (_til[0] - 1) + j - 1;
				
				if(hover && point_in_rectangle(_mx, _my, _lx, _ly, _lx + _tw, _ly + _th)) {
					draw_set_color(COLORS._main_icon_light)
					draw_rectangle(_lx, _ly, _lx + _tw - 1, _ly + _th - 1, true);
					
					if(mouse_press(mb_left))
						tile_overlay_select = tile_overlay_select == _id? noone : _id;
				}
				
				draw_set_text(f_p0, fa_left, fa_left, _id == tile_overlay_select? COLORS._main_icon_light : COLORS._main_icon);
				draw_text(_lx + 4, _ly + 4, _id);
				
				if(_id == tile_overlay_select) {
					_bitmask_draw = true;
					_bitmask_x    = _lx;
					_bitmask_y    = _ly;
				}
			}
		}
		
		if(_bitmask_draw) {
			draw_set_color(COLORS._main_accent);
			
			for(var i = 0; i < 3; i++)
			for(var j = 0; j < 3; j++) {
				var _id = i * 3 + j;
				
				var _lx = _bitmask_x + (j - 1) * _tw;
				var _ly = _bitmask_y + (i - 1) * _th;
				
				draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_accent);
				draw_text(_lx + _tw / 2, _ly + _th / 2, _id);
				
				draw_rectangle(_lx, _ly, _lx + _tw - 1, _ly + _th - 1, true);
			}
		}
	}
}