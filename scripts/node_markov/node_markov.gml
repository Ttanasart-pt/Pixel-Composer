function Node_Markov(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Markov";
	
	newActiveInput(9);
	newInput( 5, nodeValueSeed());
	newInput( 0, nodeValue_Surface( "Surface In" ));
	
	////- =Matching
	newInput( 1, nodeValue_Surface( "Match" ));
	newInput( 8, nodeValue_Palette( "Match Group", [ca_black] )).setTooltip("Colors in these group will be treat as the same color.");
	newInput( 3, nodeValue_Slider(  "Threshold",  .1          ));
	newInput(15, nodeValue_EScroll( "Transform",   0, [ "None", "Rotate 90 Random", "Rotate 90x4" ] ));
	newInput( 6, nodeValue_EScroll( "Boundary",    1, [ "Ignore", "Stop", "Clamp" ] ));
	
	////- =Tiling
	newInput(10, nodeValue_EScroll( "Tiling",       0, [ "None", "Match Size", "Custom Size" ] ));
	newInput(12, nodeValue_IVec2(   "Tile Size",   [1,1] ));
	newInput(13, nodeValue_IVec2(   "Tile Offset", [0,0] ));
	
	////- =Replacement
	newInput( 2, nodeValue_Surface( "Replace"           )).setArrayDepth(1);
	newInput( 4, nodeValue_Slider(  "Replace Chance", 1 )).setMappable(11);
	newInput(14, nodeValue_Float(   "Maximum Count",  0 ));
	newInput( 7, nodeValue_EScroll( "Transform",      0, [ "None", "Rotate 90" ] ));
	newInput(16, nodeValue_Bool(    "Reverse Order",  false ));
	// inputs 17
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 9, 5, 0, 
		[ "Matching",    false ],  1,  8,  3, 15,  6, 
		[ "Tiling",      false ], 10, 12, 13, 
		[ "Replacement", false ],  2,  4, 11, 14,  7, 16, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static step = function() {}
	
	temp_surface = [noone];
	buff_match   = undefined;
	buff_data    = [];
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _seed = _data[ 5];
			var _surf = _data[ 0];
			
			var _smat = _data[ 1];
			var _matg = _data[ 8];
			var _mthr = _data[ 3];
			var _mtrn = _data[15];
			var _boun = _data[ 6];
			
			var _tile = _data[10];
			var _tsiz = _data[12];
			var _toff = _data[13];
			
			var _srep = _data[ 2];
			var _schc = _data[ 4];
			var _maxr = _data[14];
			var _rota = _data[ 7];
			var _revr = _data[16];
			
			inputs[12].setVisible(_tile == 2);
			
			if(!is_surface(_surf) || !is_surface(_smat) || _srep == noone) return _outSurf;
		#endregion
		
		var _sdim = surface_get_dimension(_surf);
		var _mdim = surface_get_dimension(_smat);
		
		temp_surface[0] = surface_verify(temp_surface[0], _sdim[0], _sdim[1], surface_r8unorm);
		surface_set_shader(temp_surface[0], sh_markov_match);
			shader_set_2("dimension",      _sdim );
			shader_set_2("matchDimension", _mdim );
			
			shader_set_f_map("matchChance",_schc, _data[11], inputs[4] );
			shader_set_s("matchSurface",   _smat );
			shader_set_f("seed",           _seed + CURRENT_FRAME );
			shader_set_f("threshold",      _mthr );
			shader_set_i("transforms",     _mtrn );
			shader_set_i("boundary",       _boun );
			
			shader_set_i("tiling",         _tile );
			shader_set_2("tileOffset",     _toff );
			shader_set_2("tileSize",       _tsiz );
			
			shader_set_palette(_matg, "matchGroup", "matchGroupCount", 256 );
			
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		var _ssize = surface_get_byte_size(_surf);
		buff_match = buffer_verify(buff_match, _ssize);
		buffer_get_surface(buff_match, temp_surface[0], 0);
		buffer_to_start(buff_match);
		buff_data = array_verify(buff_data, _ssize);
		
		var i = 0;
		repeat(_ssize) buff_data[i++] = buffer_read(buff_match, buffer_u8);
		
		var _repArr = is_array(_srep)? _srep : [_srep];
		var _repAmo = array_length(_repArr);
		
		var ox   = -(_mdim[0] - 1) / 2;
		var oy   = -(_mdim[1] - 1) / 2;
		var _amo = _maxr;
		var _p   = [0,0];
		
		random_set_seed(_seed + CURRENT_FRAME);
		surface_set_target(_outSurf);
			DRAW_CLEAR
			draw_surface_safe(_surf, 0, 0);
			
			var b  = _revr? _ssize - 1 : 0;
			var db = _revr? -1 : 1;
			var sw = _sdim[0];
			
			repeat(_ssize) {
				var _matRes = buff_data[b];
				var _x = b % sw;
				var _y = b div sw;
				b += db;
				
				var i = 0;
				repeat(4) {
					if(_matRes & (1 << i)) {
						var _s   = _repArr[irandom(_repAmo - 1)];
						var offx = ox, offy = oy;
						var _scx = 1,  _scy = 1;
						var _rot = i * 90;
						
						switch(_rota) {
							case 1 : _rot += irandom(4) * 90; break;
							case 2 : _scx *= choose(-1,1);    break;
							case 3 : _scy *= choose(-1,1);    break;
						}
						
						var dx = _x;
						var dy = _y;
						_rot = _rot % 360;
						
						switch(_rot) {
							case  90 : dy++;       break;
							case 180 : dx++; dy++; break;
							case 270 : dx++;       break;
						}
						
						draw_surface_ext_safe(_s, dx, dy, _scx, _scy, _rot, c_white, 1);
						
						_amo--;
						if(_maxr && _amo == 0) break;
					}
					
					i++;
				}
				
				if(_maxr && _amo == 0) break;
			}
		surface_reset_target();
		
		return _outSurf; 
	}
}