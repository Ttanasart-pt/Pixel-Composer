function Node_MK_Panels(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Panels";
	dimension_index = 1;
	
	tooltip_panel_pattern = @"Defines set of operations for creating panels:
- x: Split X axis
- y: Split Y axis
- i: Inset
- h[n]: Split X axis [n] parts equally
- v[n]: Split Y axis [n] parts equally";
	tooltip_shape_pattern = @"Defines set of shapes to draw:
- r: Rectangle
- c: Cornered Rectangle
- *s: Add split";
	
	newInput( 1, nodeValue_Dimension());
	newInput( 2, nodeValueSeed());
	
	////- =Panels
	newInput( 0, nodeValue_Area(    "Area",         DEF_AREA_REF  )).setUnitRef(function() /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
	newInput( 3, nodeValue_Text(    "Panel Pattern",  "xxyyi"     )).setDisplay(VALUE_DISPLAY.text_box).setTooltip(tooltip_panel_pattern);
	newInput(16, nodeValue_Int(     "Max Iteration",  -1          ));
	newInput( 4, nodeValue_Int(     "Min Size",        3          ));
	newInput(10, nodeValue_Range(   "Padding",        [0,0], true ));
	newInput( 5, nodeValue_Palette( "Panel Colors",   [ca_white]  )).setOptions("Select by:", "array_select", [ "Index Loop", "Index Ping-pong", "Random" ], THEME.array_select_type).iconPad();
	
	////- =Split
	newInput(17, nodeValue_Range(   "Split Ratio",   [.2,.8]     ));
	newInput(20, nodeValue_Range(   "Split Width",   [0,0], true ));
	newInput(23, nodeValue_Bool(    "Split Alternate", false     ));
	
	newInput(18, nodeValue_Slider(  "Split Draw",       0        ));
	newInput( 6, nodeValue_EScroll( "Split Draw Color", 0, [ "Next Color" ] ));
	newInput(19, nodeValue_Slider(  "Split Length",    .75       ));
	
	////- =Shapes
	newInput( 7, nodeValue_Text(   "Shape Pattern", "rc-"        )).setDisplay(VALUE_DISPLAY.text_box).setTooltip(tooltip_shape_pattern);
	newInput( 9, nodeValue_Corner( "Corner",        [.5,0,0,0]   ));
	newInput(24, nodeValue_Bool(   "Corner Shuffle", false       ));
	newInput(25, nodeValue_Bool(   "Corner Offset",  true        ));
	
	////- =Slot
	newInput(15, nodeValueSeed(,   "Slot Seed"));
	newInput(11, nodeValue_Range(  "Slot Size",    [.2,.2], true ));
	newInput(14, nodeValue_Range(  "Slot Width",   [.5,.5], true ));
	newInput(13, nodeValue_Range(  "Slot Count",   [3,8]         ));
	newInput(12, nodeValue_Int(    "Slot Spacing", 2             ));
	
	////- =Highlight
	newInput( 8, nodeValue_Vec4(    "Highlight",    [0,.5,.5,0]  ));
	newInput(21, nodeValue_Slider(  "Highlight Chance", 1        ));
	newInput(22, nodeValue_Slider(  "Highlight Invert", 0        ));
	// inputs 25
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 1, 2, 
		[ "Panels",    false ], 0, 3, 16, 4, 10, 5, 
		[ "Split",     false ], 17, 20, 23, 18, 6, 19, 
		[ "Shapes",    false ], 7, 9, 24, 25, 
		[ "Slot",      false ], 15, 11, 14, 13, 12, 
		[ "Highlight", false ], 8, 21, 22, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Nodes
	
	temp_surface = [0];
	__temp_data  = [];
	__seed_iter  = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
	}
	
	static boxProcess = function(_box, _itr = 0) {
		var _dimens   = __temp_data[ 1];
		random_set_seed(__seed_iter++);
		
		var _pattern  = __temp_data[ 3];
		var _maxItr   = __temp_data[16]; 
		var _minSize  = __temp_data[ 4]; _minSize = max(2, _minSize);
		var _padding  = __temp_data[10]; _padding = max(0, irandom_range(_padding[0], _padding[1]));
		
		var _highl    = __temp_data[ 8];
		var _highRate = __temp_data[21];
		var _highInv  = __temp_data[22];
		
		var _split    = __temp_data[17];
		var _splitWid = __temp_data[20];
		var _splitInv = __temp_data[23];
		
		var _splitDrw = __temp_data[18];
		var _splitRen = __temp_data[ 6];
		var _splitRat = __temp_data[19];
		
		var _rpatt    = __temp_data[ 7];
		var _corn     = __temp_data[ 9];
		var _cornRan  = __temp_data[24];
		var _cornOff  = __temp_data[25];
		
		var _slotSeed = __temp_data[15];
		var _slotSize = __temp_data[11];
		var _slotRato = __temp_data[14];
		var _slotCont = __temp_data[13];
		var _slotSpac = __temp_data[12];
		
		var _palette  = __temp_data[ 5], _colr_indx_len  = array_length(_palette), _colr_indx_typ = inputs[5].attributes.array_select;
		
		var _i = 0;
		switch(_colr_indx_typ) {
			case 0  : _i = _itr % _colr_indx_len;                break;
			case 1  : _i = pingpong_value(_itr, _colr_indx_len); break;
			case 2  : _i = irandom(_colr_indx_len - 1);          break;
		}
		var _c = _palette[_i];
		
		var _ind   = irandom_range(1, string_length(_rpatt));
		var _dchr0 = string_char_at(_rpatt, _ind-1);
		var _dchr  = string_char_at(_rpatt, _ind);
		var _dchr1 = string_char_at(_rpatt, _ind+1);
		if(_dchr == "s") { _dchr = _dchr0; _dchr1 = _dchr; }
		
		var _x0 = _box[0], _y0 = _box[1];
		var _x1 = _box[2], _y1 = _box[3];
		
		switch(_dchr) {
			case "r":
			case "c":
				_x0 += _padding; _y0 += _padding;
				_x1 -= _padding; _y1 -= _padding;
				break;
		}
		
		var _w  = _x1 - _x0;
		var _h  = _y1 - _y0;
		if(_w < 3 || _h < 3) return;
		
		surface_set_target(temp_surface[0]);
		DRAW_CLEAR
		switch(_dchr) {
			case "r" :
				shader_set(sh_mk_panels);
					shader_set_2("position",     [_x0, _y0]    );
					shader_set_2("dimension",    [_w, _h]      );
					shader_set_4("corner",       [0,0,0,0]     );
					
					draw_sprite_stretched_ext(s_fx_pixel, 0, _x0, _y0, _w, _h, _c);
				shader_reset();
				break;
			
			case "c" :
				if(_cornRan) _corn = array_shuffle(_corn);
				shader_set(sh_mk_panels);
					shader_set_2("position",     [_x0, _y0]    );
					shader_set_2("dimension",    [_w, _h]      );
					shader_set_4("corner",       _corn         );
					
					draw_sprite_stretched_ext(s_fx_pixel, 0, _x0, _y0, _w, _h, _c);
				shader_reset();
							
				if(_cornOff) {
					var cr0 = floor(min(_w, _h) * _corn[0] / 2);
					var cr1 = floor(min(_w, _h) * _corn[1] / 2);
					var cr2 = floor(min(_w, _h) * _corn[2] / 2);
					var cr3 = floor(min(_w, _h) * _corn[3] / 2);
					
					_x0 += max(cr0, cr2) + 1;
					_y0 += max(cr0, cr1) + 1;
					_x1 -= max(cr1, cr3) + 1;
					_y1 -= max(cr2, cr3) + 1;
				}
				break;
		}
		
		switch(_dchr1) {
			case "s":
				random_set_seed(__seed_iter + _slotSeed);
				var _side = irandom(3);
				var _slot = irandom_range(_slotCont[0], _slotCont[1]);
				var _sltw = random_range(_slotSize[0], _slotSize[1]);
				var _slrt = random_range(_slotRato[0], _slotRato[1]);
				var _flip = choose(0, 1);
				
				BLEND_SUBTRACT
				draw_set_color(c_white);
				switch(_side) {
					case 0 :
						var _ltw = _h * _slrt;
						var _lw  = _sltw * _w;
						var _lh  = floor(_ltw / _slot - _slotSpac);
						var _yy0 = _y0 + _slotSpac;
						if(_flip) _yy0 += _h - _ltw;
						
						_lw = abs(_lw);
						_lh = abs(_lh);
						
						repeat(_slot) {
							draw_rectangle(_x1 - _lw, _yy0, _x1, _yy0 + _lh, false);
							_yy0 += _lh + _slotSpac;
						}
						
						_x1 -= _lw + 1;
						break;
					
					case 1 :
						var _ltw = _w * _slrt;
						var _lw  = floor(_ltw / _slot - _slotSpac);
						var _lh  = _sltw * _w;
						var _xx0 = _x0 + _slotSpac;
						if(_flip) _xx0 += _w - _ltw;
						
						_lw = abs(_lw);
						_lh = abs(_lh);
						
						repeat(_slot) {
							draw_rectangle(_xx0, _y0, _xx0 + _lw, _y0 + _lh, false);
							_xx0 += _lw + _slotSpac;
						}
						
						_y0 += _lh + 1;
						break;
						
					case 2 :
						var _ltw = _h * _slrt;
						var _lw  =  _sltw * _w;
						var _lh  = floor(_ltw / _slot - _slotSpac);
						var _yy0 = _y1 - _slotSpac;
						if(_flip) _yy0 -= _h - _ltw;
						
						_lw = abs(_lw);
						_lh = abs(_lh);
						
						repeat(_slot) {
							draw_rectangle(_x0, _yy0, _x0 + _lw, _yy0 - _lh, false);
							_yy0 -= _lh + _slotSpac;
						}
						
						_x0 += _lw + 1;
						break;
						
					case 3 :
						var _ltw = _w * _slrt;
						var _lw  = floor(_ltw / _slot - _slotSpac);
						var _lh  = _sltw * _w;
						var _xx0 = _x1 - _slotSpac;
						if(_flip) _xx0 -= _w - _ltw;
						
						_lw = abs(_lw);
						_lh = abs(_lh);
						
						repeat(_slot) {
							draw_rectangle(_xx0, _y1, _xx0 - _lw, _y1 - _lh, false);
							_xx0 -= _lw + _slotSpac;
						}
						
						_y1 -= _lh + 1;
						break;
						
				}
				BLEND_NORMAL
				break;
		}
		surface_reset_target();
		
		if(random(1) < _highRate) {
			shader_set(sh_mk_panel_higlight);
				shader_set_2("dimension", _dimens );
				shader_set_4("highlight", random(1) < _highInv? [_highl[2], _highl[3], _highl[0], _highl[1]] : _highl  );
				draw_surface(temp_surface[0], 0, 0);
			shader_reset();
			
		} else {
			draw_surface(temp_surface[0], 0, 0);
		}
		
		if(_maxItr > -1 && _itr >= _maxItr) return;
		
		_w  = _x1 - _x0;
		_h  = _y1 - _y0;
		if(_w < _minSize || _h < _minSize) return;
		
		random_set_seed(__seed_iter + 10);		
		var _pind  = irandom_range(1, string_length(_pattern));
		var _pchr  = string_char_at(_pattern, _pind);
		var _pchr1 = string_char_at(_pattern, _pind + 1);
		var _spww  = irandom_range(_splitWid[0], _splitWid[1]);
		
		if(string_digits(_pchr) == _pchr) {
			_pchr1 = _pchr;
			_pchr  = string_char_at(_pattern, _pind - 1);
		}
		
		if(_splitInv) switch(_box[4]) {
			case "x" : if (_pchr != _box[4]) _pchr = "y"; break;
			case "y" : if (_pchr != _box[4]) _pchr = "x"; break;
			case "v" : if (_pchr != _box[4]) _pchr = "h"; break;
			case "h" : if (_pchr != _box[4]) _pchr = "v"; break;
		}
		
		switch(_pchr) {
			case "x" : // split x
				var _sp = _w * clamp(random_range(_split[0], _split[1]), 0, 1);
				var _xc = round(_x0 + _sp);
				var _yc = (_y0 + _y1) / 2;
				var _spl = _h / 2 * _splitRat - _padding;
				
				if(random(1) < _splitDrw && _spl > 1) {
					gpu_set_colorwriteenable(1, 1, 1, 0);
					draw_set_color(_palette[(_i + 1) % _colr_indx_len]);
					draw_line(_xc, _yc - _spl, _xc, _yc + _spl - 1);
					gpu_set_colorwriteenable(1, 1, 1, 1);
				}
				
				boxProcess([ _x0, _y0, _xc - _spww, _y1, _pchr ], _itr + 1);
				boxProcess([ _xc + _spww, _y0, _x1, _y1, _pchr ], _itr + 1);
				break;
			
			case "y" : // split y
				var _sp = _h * clamp(random_range(_split[0], _split[1]), 0, 1);
				var _xc = (_x0 + _x1) / 2;
				var _yc = round(_y0 + _sp);
				var _spl = _w / 2 * _splitRat - _padding;
				
				if(random(1) < _splitDrw && _spl > 1) {
					gpu_set_colorwriteenable(1, 1, 1, 0);
					draw_set_color(_palette[(_i + 1) % _colr_indx_len]);
					draw_line(_xc - _spl, _yc, _xc + _spl - 1, _yc);
					gpu_set_colorwriteenable(1, 1, 1, 1);
				}
				
				boxProcess([ _x0, _y0, _x1, _yc - _spww, _pchr ], _itr + 1);
				boxProcess([ _x0, _yc + _spww, _x1, _y1, _pchr ], _itr + 1);
				break;
			
			case "h" : // horizontal equal split
				var _parts = max(2, toNumber(_pchr1));
				for( var i = 0; i < _parts; i++ ) {
					boxProcess([ lerp(_x0, _x1, (i + 0) / (_parts)), _y0, 
					             lerp(_x0, _x1, (i + 1) / (_parts)), _y1, _pchr ], _itr + 1);
				}
				break;
			
			case "v" : // vertical equal split
				var _parts = max(2, toNumber(_pchr1));
				for( var i = 0; i < _parts; i++ ) {
					boxProcess([ _x0, lerp(_y0, _y1, (i + 0) / (_parts)), 
					             _x1, lerp(_y0, _y1, (i + 1) / (_parts)), _pchr ], _itr + 1);
				}
				break;
			
			case "i" : // inset
				var _si = irandom_range(1, min(_w, _h) * .2);
				
				boxProcess([ _x0 + _si, _y0 + _si, _x1 - _si, _y1 - _si, _pchr ], _itr + 1);
				break;
				
			case "p" : // padding
				var _sw = irandom_range(1, _w * .2);
				var _sh = irandom_range(1, _h * .2);
				
				boxProcess([ _x0 + _sw, _y0 + _sh, _x1 - _sw, _y1 - _sh, _pchr ], _itr + 1);
				break;
		}
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dim  = _data[ 1];
			var _seed = _data[ 2]; __seed_iter = _seed;
			
			var _area = _data[ 0];
			var _patt = _data[ 3];
			var _ratt = _data[ 7];
			var _pall = _data[ 5];
			
			__temp_data = _data;
		#endregion
		
	    var _sw  = _dim[0];
	    var _sh  = _dim[1];
	    var _x0  = _area[AREA_INDEX.center_x] - _area[AREA_INDEX.half_w];
	    var _y0  = _area[AREA_INDEX.center_y] - _area[AREA_INDEX.half_h];
	    var _x1  = _area[AREA_INDEX.center_x] + _area[AREA_INDEX.half_w];
	    var _y1  = _area[AREA_INDEX.center_y] + _area[AREA_INDEX.half_h];
	    var _box = [ _x0, _y0, _x1, _y1, "o" ];
	    
	    temp_surface[0] = surface_verify(temp_surface[0], _sw, _sh);
	    
	    if(string_length(_patt) == 0) return _outSurf;
	    if(string_length(_ratt) == 0) return _outSurf;
	    if(array_empty(_pall))        return _outSurf;
	    
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			boxProcess(_box);
		surface_reset_target();
		
		return _outSurf;
	}
}