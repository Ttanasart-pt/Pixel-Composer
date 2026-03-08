function Node_MK_Brownian(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Brownian";
	update_on_frame = true;
	dimension_index = 12;
	
	newInput( 8, nodeValueSeed());
	
	////- =Dimension
	newInput(12, nodeValue_Dimension());
	newInput( 0, nodeValue_Surface( "Background" ));
	
	////- =Particles
	newInput( 1, nodeValue_Surface( "Sprite" )).setArrayDepth(1);
	newInput(15, nodeValue_Bool(    "Offset Lifespan", false ));
	
	////- =Spawn
	newInput( 3, nodeValue_Area( "Area",   DEF_AREA_REF )).setUnitSimple().setHotkey("A");
	newInput( 2, nodeValue_Int(  "Amount", 10           ));
	
	////- =Movement
	newInput( 5, nodeValue_Range(   "Speed",         [1,1]          ));
	newInput( 4, nodeValue_RotRand( "Direction",     [0,45,135,0,0] ));
	newInput( 9, nodeValue_Range(   "Angular speed", [-45,45]       ));
	
	////- =Smooth Turn
	newInput(11, nodeValue_Bool(  "Turn", false ));
	newInput(10, nodeValue_Range( "Angular Acceleration", [-2,2] ));
	
	////- =Render
	newInput(13, nodeValue_Range(    "Size", [ 1, 1 ], { linked : true } ));
	newInput( 6, nodeValue_Gradient( "Color", gra_white    ));
	newInput( 7, nodeValue_Curve(    "Alpha", CURVE_DEF_11 ));
	newInput(14, nodeValue_Bool(     "Tile",  false        ));
	// input 15
	
	newOutput( 0, nodeValue_Output( "Output",    VALUE_TYPE.surface, noone ));
	newOutput( 1, nodeValue_Output( "Positions", VALUE_TYPE.float,   []    ));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 8, 
		[ "Dimension",  false     ], 12,  0, 
		[ "Particles",  false     ],  1, 15, 
		[ "Spawn",      false     ],  3,  2, 
		[ "Movement",   false     ],  5,  4,  9, 
		[ "Smooth turn", true, 11 ], 10, 
		[ "Render",     false     ], 13,  6,  7, 14, 
	];
	
	////- Node
	
	area_x0 = 0; area_y0 = 0;
	area_x1 = 0; area_y1 = 0;
	
	static getDimension = function() /*=>*/ {return inputs[12].getValue()};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static getPosition = function(ind, t, _sped, _dire, _dirs, _turn, _dira) {
		random_set_seed(ind);
		
		var _px = irandom_range( area_x0, area_x1 );
		var _py = irandom_range( area_y0, area_y1 );
		
		var spd = random_range(_sped[0], _sped[1]);
		var dir = rotation_random_eval(_dire);
		var dis = random_range(_dirs[0], _dirs[1]);
		var dia = random_range(_dira[0], _dira[1]);
		
		repeat(t) {
			_px += lengthdir_x(spd, dir);
			_py += lengthdir_y(spd, dir);
			
			if(_turn) dis += random_range(_dira[0], _dira[1]);
			else      dis  = random_range(_dirs[0], _dirs[1]);
			
			dir += dis;
		}
		
		return [ _px, _py ];
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _seed = _data[ 8];
			
			var _dim  = _data[12];
			var _bg   = _data[ 0];
			
			var _sprt = _data[ 1];
			var _offs = _data[15];
			
			var _area = _data[ 3];
			var _amou = _data[ 2];
			
			var _sped = _data[ 5];
			var _dire = _data[ 4];
			var _dirs = _data[ 9];
			
			var _turn = _data[11];
			var _dira = _data[10];
			
			var _size = _data[13];
			var _colr = _data[ 6];
			var _alph = _data[ 7];
			var _tile = _data[14];
		#endregion
		
		var ww = _dim[0];
		var hh = _dim[1];
		
		var _sed = _seed;
		var  pw = 1;
		var  ph = 1;
		
		if(_sprt != noone) {
			var ss = is_array(_sprt)? _sprt[0] : _sprt;
			pw = surface_get_width_safe(ss);
			ph = surface_get_height_safe(ss);
		}
		
		var ind = 0;
		_outData[1] = array_verify(_outData[1], _amou);
		
		var _frame_total = TOTAL_FRAMES;
		var _frame_curr  = CURRENT_FRAME;
		
		area_x0 = _area[0] - _area[2]; 
		area_y0 = _area[1] - _area[3];
		
		area_x1 = _area[0] + _area[2]; 
		area_y1 = _area[1] + _area[3];
		
		surface_set_shader(_outData[0], noone, true, BLEND.normal);
			draw_surface_safe(_bg);
			
			repeat(_amou) {
				_sed += 100;
				
				var _ofs = irandom_seed(_frame_total, _sed);
				var _lif = (_frame_curr + (_offs * _ofs)) % _frame_total;
				
				var _pos  = getPosition(_sed, _lif, _sped, _dire, _dirs, _turn, _dira);
				var _cc   = _colr.eval(_ofs / _frame_total);
				var _aa   = eval_curve_x(_alph, _lif / _frame_total);
				random_set_seed(_sed + 50);
				
				_outData[1][ind] = [ _pos[0], _pos[1] ];
				
				if(_sprt == noone) {
					var _ss = irandom_range(_size[0], _size[1]);
					DYNADRAW_DEFAULT.draw(_pos[0], _pos[1], _ss, _ss, 0, _cc, _aa);
					
				} else {
					var _ss = random_range(_size[0], _size[1]);
					var _p  = _sprt;
					if(is_array(_p)) _p = array_safe_get_fast(_p, irandom(array_length(_p) - 1));
					
					var px = _pos[0];
					var py = _pos[1];
					draw_surface_ext_safe(_p, px, py, _ss, _ss, 0, _cc, _aa);
					
					if(_tile) {
						var wx = undefined;
						var wy = undefined;
						
						var ppw = pw * _ss;
						var pph = ph * _ss;
						
						     if(px < 0)        wx = px + ww;
						else if(px > ww - ppw) wx = px - ww;
						
						     if(py < 0)        wy = py + hh;
						else if(py > hh - pph) wy = py - hh;
						
						if(wx != undefined) draw_surface_ext_safe(_p, wx, py, _ss, _ss, 0, _cc, _aa);
						if(wy != undefined) draw_surface_ext_safe(_p, px, wy, _ss, _ss, 0, _cc, _aa);
						if(wx != undefined && wy != undefined) draw_surface_ext_safe(_p, wx, wy, _ss, _ss, 0, _cc, _aa);
					}
				}
				
				ind++;
			}
		surface_reset_shader();
		
		return _outData;
	}
}