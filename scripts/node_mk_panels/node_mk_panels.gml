function Node_MK_Panels(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Panels";
	dimension_index = 1;
	
	newInput( 1, nodeValue_Dimension());
	newInput( 2, nodeValueSeed());
	
	////- =Panels
	newInput( 0, nodeValue_Area(    "Area",         DEF_AREA_REF, { useShape : false } )).setUnitRef(function() /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
	newInput( 3, nodeValue_Text(    "Panel Pattern",  "xxyyi-"     )).setDisplay(VALUE_DISPLAY.text_box)
		.setSideButton(button(function() /*=>*/ {return randomPanel()}).setIcon(THEME.icon_random, 0, COLORS._main_icon).iconPad());
	newInput(27, nodeValue_Int(     "Min Iteration",   2           ));
	newInput(16, nodeValue_Int(     "Max Iteration",  -1           ));
	newInput( 4, nodeValue_Slider(  "Min Size",       .1           ));
	newInput(10, nodeValue_Range(   "Padding",        [0,0], true  ));
	newInput( 5, nodeValue_Palette( "Panel Colors",   DEF_PALETTE  )).setOptions("Select by:", "array_select", [ "Index Loop", "Index Ping-pong", "Random" ], THEME.array_select_type).iconPad();
	
	////- =Split
	newInput(26, nodeValue_Range(   "Inset Range",   [.05,.1]    ));
	newInput(17, nodeValue_Range(   "Split Ratio",   [.2,.8]     ));
	newInput(20, nodeValue_Range(   "Split Width",   [0,0], true ));
	newInput(23, nodeValue_Bool(    "Split Alternate", false     )).setTooltip("Force next split to be in the opposite axis as the previous one.");
	
	newInput(18, nodeValue_Slider(  "Split Draw",       0        ));
	newInput( 6, nodeValue_EScroll( "Split Draw Color", 0, [ "Next Color" ] ));
	newInput(19, nodeValue_Slider(  "Split Length",    .75       ));
	
	////- =Shapes
	newInput(30, nodeValueSeed(,   "Shape Seed"));
	newInput( 7, nodeValue_Text(   "Shape Pattern", "rsrd-"      )).setDisplay(VALUE_DISPLAY.text_box)
		.setSideButton(button(function() /*=>*/ {return randomShape()}).setIcon(THEME.icon_random, 0, COLORS._main_icon).iconPad());
	newInput( 9, nodeValue_Corner( "Corner",        [.25,0,0,0]  ));
	newInput(24, nodeValue_Bool(   "Corner Shuffle", false       ));
	newInput(28, nodeValue_Range(  "Pipe Size",     [4,4], true  ));
	newInput(25, nodeValue_Slider( "Shape Offset",   0           ));
	newInput(43, nodeValue_Slider( "Corner Deco",    0           ));
	
	////- =Slot
	newInput(15, nodeValueSeed(,   "Slot Seed"));
	newInput(11, nodeValue_Range(  "Slot Size",    [.2,.2], true ));
	newInput(14, nodeValue_Range(  "Slot Width",   [.5,.5], true ));
	newInput(13, nodeValue_Range(  "Slot Count",   [3,8]         ));
	newInput(12, nodeValue_Int(    "Slot Spacing", 2             ));
	
	////- =Highlight
	newInput( 8, nodeValue_Vec4(    "Highlight", [-.5,.5,.5,-.5] ));
	newInput(21, nodeValue_Slider(  "Highlight Chance",  1       ));
	newInput(22, nodeValue_Slider(  "Highlight Invert", .25      ));
	newInput(29, nodeValue_Slider(  "Shade Darken",     .5       ));
	
	////- =Glow
	newInput(33, nodeValue_Bool(    "Use Glow",       false       ))
	newInput(35, nodeValue_Slider(  "Glowbar Chance",  .5         ));
	newInput(34, nodeValue_Slider(  "Glowbar Size",    .5         ));
	newInput(32, nodeValue_Palette( "Glowbar Color", [ca_white]   ))
	
	////- =Glow
	newInput(36, nodeValue_Bool(   "Shine Use",        false         ));
	newInput(40, nodeValue_Slider( "Shine Chance",     .5            ));
	newInput(37, nodeValue_Range(  "Shine Width",     [.1,.1], true  ));
	newInput(39, nodeValue_Float(  "Shine Speed",       1            ));
	newInput(42, nodeValue_Slider( "Shine Shift",       0            ));
	newInput(38, nodeValue_Slider( "Shine Intensity",  .5            ));
	newInput(41, nodeValue_Bool(   "Shine Invert",     false         ));
	
	////- =Post-Process
	newInput(31, nodeValue_Bool( "Posterize",  false ));
	// inputs 44
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 1, 2, 
		[ "Panels",       false     ], 0, 3, 27, 16, 4, 10, 5, 
		[ "Split",        false     ], 26, 17, 20, 23, new Inspector_Spacer(ui(4), true), 18, 6, 19, 
		[ "Shapes",       false     ], 30, 7, 9, 24, 28, 25, 43, 
		[ "Slot",         false     ], 15, 11, 14, 13, 12, 
		[ "Highlight",    false     ], 8, 21, 22, 29, 
		[ "Glow",         false,    ], 35, 34, 32, 
		[ "Shine",        false, 36 ], 40, 37, 39, 42, 38, 41, 
		[ "Post-Process", false     ], 31, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output("Glow Mask",   VALUE_TYPE.surface, noone ));
	
	////- Nodes
	
	temp_surface = [0,0,0];
	__temp_data  = [];
	__seed_iter  = 0;
	
	panel_pre_pattern = "";
	panel_pattern     = "";
	
	shape_pre_pattern = "";
	shape_pattern     = "";
	
	shMKPanels = new Shader(sh_mk_panels);
	shMKPanels.getUniforms([
		"surfaceDim", 
		"position", 
		"dimension", 
		"corner", 
		"shade", 
		"style", 
		"shadeDark", 
		"frame", 
		"shineUse", 
		"shineWidth", 
		"shineSpeed", 
		"shineInten", 
		"shineInver", 
		"shineShft", 
	]);
	
	shMKPanelsH = new Shader(sh_mk_panel_higlight);
	shMKPanelsH.getUniforms([
		"dimension",
		"highlight",
	]);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
	}
	
	static randomPanel = function() {
		randomize();
		static panelChar = "xyhviIfF-";
		var _len = irandom_range(2, 10);
		var _pat = "";
		
		repeat(_len) {
			var _ch = string_char_at(panelChar, random_range(1, string_length(panelChar)));
			_pat += _ch;
			switch(_ch) {
				case "h":
				case "v":
					_pat += string(irandom_range(3, 8));
					break;
			}
		}
		
		inputs[3].setValue(_pat);
	}
	
	static randomShape = function() {
		randomize();
		static shapeChar = "rdcP--";
		var _len = irandom_range(2, 10);
		var _pat = "";
		
		repeat(_len) {
			var _ch = string_char_at(shapeChar, random_range(1, string_length(shapeChar)));
			_pat += _ch;
			if(choose(0,1)) _pat += "s";
		}
		
		inputs[7].setValue(_pat);
	}
	
	static boxProcess = function(_box, _itr = 0) {
		#region data
			var _dimens   = __temp_data[ 1];
			random_set_seed(__seed_iter++);
			
			var _minItr   = __temp_data[27]; 
			var _maxItr   = __temp_data[16]; 
			var _minSize  = __temp_data[ 4], _minW = max(2, _minSize * _dimens[0]), _minH = max(2, _minSize * _dimens[1]);
			var _padding  = __temp_data[10]; _padding = max(0, irandom_range(_padding[0], _padding[1]));
			
			var _highl    = __temp_data[ 8];
			var _highRate = __temp_data[21];
			var _highInv  = __temp_data[22];
			var _darken   = __temp_data[29];
			
			var _split    = __temp_data[17];
			var _splitWid = __temp_data[20];
			var _splitInv = __temp_data[23];
			var _inset    = __temp_data[26];
			
			var _splitDrw = __temp_data[18];
			var _splitRen = __temp_data[ 6];
			var _splitRat = __temp_data[19];
			
			var _shSeed   = __temp_data[30];
			var _corn     = __temp_data[ 9];
			var _cornRan  = __temp_data[24];
			var _subpan   = __temp_data[28];
			var _shapOff  = __temp_data[25];
			var _cornDeco = __temp_data[43];
			
			var _slotSeed = __temp_data[15];
			var _slotSize = __temp_data[11];
			var _slotRato = __temp_data[14];
			var _slotCont = __temp_data[13];
			var _slotSpac = __temp_data[12];
			
			var _glow     = __temp_data[33];
			var _glowch   = __temp_data[35];
			var _glows    = __temp_data[34];
			var _glowc    = __temp_data[32];
			
			var _shineUse = __temp_data[36];
			var _shineChn = __temp_data[40]; if(random(1) > _shineChn) _shineUse = false;
			var _shineWid = __temp_data[37];
			var _shineSpd = __temp_data[39];
			var _shineShf = __temp_data[42];
			var _shineInt = __temp_data[38];
			var _shineInv = __temp_data[41];
			
			var _palette  = __temp_data[ 5], _colr_indx_len  = array_length(_palette), _colr_indx_typ = inputs[5].attributes.array_select;
		#endregion
		
		#region draw shape
			var _i = 0;
			switch(_colr_indx_typ) {
				case 0  : _i = _itr % _colr_indx_len;                break;
				case 1  : _i = pingpong_value(_itr, _colr_indx_len); break;
				case 2  : _i = irandom(_colr_indx_len - 1);          break;
			}
			var _c = _palette[_i];
			
			random_set_seed(__seed_iter + _shSeed);
			var _sstr = "";
			var _sind = 0;
			
			if(_itr < string_length(shape_pre_pattern)) {
				_sstr = shape_pre_pattern;
				_sind = _itr + 1;
				
			} else {
				_sstr = shape_pattern;
				_sind = irandom_range(1, string_length(shape_pattern));
			}
			
			var _dchr0 = string_char_at(_sstr, _sind-1);
			var _dchr  = string_char_at(_sstr, _sind);
			var _dchr1 = string_char_at(_sstr, _sind+1);
			
			switch(_dchr) {
				case "s" : 
				case "g" : 
				case "G" : 
					_dchr = _dchr0; 
					_dchr1 = _dchr; 
					break;
			}
			
			var _x0 = _box[0], _y0 = _box[1];
			var _x1 = _box[2], _y1 = _box[3];
			var _cx = (_x0 + _x1) / 2;
			var _cy = (_y0 + _y1) / 2;
			
			switch(_dchr) {
				case "r":
				case "c":
					_x0 += _padding; _y0 += _padding;
					_x1 -= _padding; _y1 -= _padding;
					break;
			}
			
			var _w = _x1 - _x0;
			var _h = _y1 - _y0;
			var _m = min(_w, _h)
			var _a = _h > _w;
			if(_dchr1 == "G") _a += 2;
			if(_w < 3 || _h < 3) return;
			
			surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			switch(_dchr) {
				case "r" :
					shader_set(sh_mk_panels);
						shMKPanels.position   .setA( [_x0, _y0] );
						shMKPanels.dimension  .setA( [_w, _h]   );
						shMKPanels.corner     .setA( [0,0,0,0]  );
						
						shMKPanels.shade      .setI( _dchr1 == "g" || _dchr1 == "G"? _a : -1 );
						shMKPanels.shadeDark  .setF( _darken    );
						
						shMKPanels.shineUse   .setI( _shineUse  );
						shMKPanels.shineWidth .setF( random_range(_shineWid[0], _shineWid[1])  );
						shMKPanels.shineSpeed .setF( _shineSpd  );
						shMKPanels.shineInten .setF( _shineInt  );
						shMKPanels.shineInver .setI( _shineInv  );
						shMKPanels.shineShft  .setF( random_range(-_shineShf, _shineShf)  );
						
						draw_sprite_stretched_ext(s_fx_pixel, 0, _x0, _y0, _w, _h, _c);
					shader_reset();
					break;
				
				case "d" :
				case "c" :
					if(_cornRan) _corn = array_shuffle(_corn);
					shader_set(sh_mk_panels);
						shMKPanels.position   .setA( [_x0, _y0] );
						shMKPanels.dimension  .setA( [_w, _h]   );
						shMKPanels.corner     .setA( [0,0,0,0]  );
						
						shMKPanels.style      .setI( _dchr  == "c" );
						shMKPanels.shade      .setI( _dchr1 == "g" || _dchr1 == "G"? _a : -1 );
						shMKPanels.shadeDark  .setF( _darken    );
						
						shMKPanels.shineUse   .setI( _shineUse  );
						shMKPanels.shineWidth .setF( random_range(_shineWid[0], _shineWid[1])  );
						shMKPanels.shineSpeed .setF( _shineSpd  );
						shMKPanels.shineInten .setF( _shineInt  );
						shMKPanels.shineInver .setI( _shineInv  );
						shMKPanels.shineShft  .setF( random_range(-_shineShf, _shineShf)  );
						
						draw_sprite_stretched_ext(s_fx_pixel, 0, _x0, _y0, _w, _h, _c);
					shader_reset();
								
					var cr0 = floor(_m * _corn[0] / 2) * _shapOff;
					var cr1 = floor(_m * _corn[1] / 2) * _shapOff;
					var cr2 = floor(_m * _corn[2] / 2) * _shapOff;
					var cr3 = floor(_m * _corn[3] / 2) * _shapOff;
					
					_x0 += max(cr0, cr2) + 1;
					_y0 += max(cr0, cr1) + 1;
					_x1 -= max(cr1, cr3) + 1;
					_y1 -= max(cr2, cr3) + 1;
					break;
				
				case "e":
					draw_set_color(_c);
					draw_set_circle_precision(64);
					draw_ellipse(_x0, _y0, _x1, _y1, false);
					
					var cr0 = floor(_m / 2) * _shapOff;
					var cr1 = floor(_m / 2) * _shapOff;
					var cr2 = floor(_m / 2) * _shapOff;
					var cr3 = floor(_m / 2) * _shapOff;
					
					_x0 += max(cr0, cr2) + 1;
					_y0 += max(cr0, cr1) + 1;
					_x1 -= max(cr1, cr3) + 1;
					_y1 -= max(cr2, cr3) + 1;
					break;
					
				case "E":
					draw_set_color(_c);
					draw_set_circle_precision(64);
					draw_circle(_cx, _cy, _m/2, false);
					
					_x0 = round(lerp(_x0, _cx - _m/2, _shapOff));
					_y0 = round(lerp(_y0, _cy - _m/2, _shapOff));
					_x1 = round(lerp(_x1, _cx + _m/2, _shapOff));
					_y1 = round(lerp(_y1, _cy + _m/2, _shapOff));
					break;
					
				case "p":
				case "P":
					var _amo  = (_a? _w : _h) / irandom_range(_subpan[0], _subpan[1]);
					var _sw   = _a? _w / _amo : _w;
					var _sh   = _a? _h : _h / _amo;
					var _xx0  = _x0;
					var _yy0  = _y0;
					if(_cornRan) _corn = array_shuffle(_corn);
					
					repeat(_amo) {
						shader_set(sh_mk_panels);
							shMKPanels.position   .setA( [_x0, _y0] );
							shMKPanels.dimension  .setA( [_w, _h]   );
							shMKPanels.corner     .setA( [0,0,0,0]  );
							
							shMKPanels.shade      .setI( _dchr == "p"? _a : _a + 2 );
							shMKPanels.shadeDark  .setF( _darken    );
							
							shMKPanels.shineUse   .setI( _shineUse  );
							shMKPanels.shineWidth .setF( random_range(_shineWid[0], _shineWid[1])  );
							shMKPanels.shineSpeed .setF( _shineSpd  );
							shMKPanels.shineInten .setF( _shineInt  );
							shMKPanels.shineInver .setI( _shineInv  );
							shMKPanels.shineShft  .setF( random_range(-_shineShf, _shineShf)  );
							
							draw_sprite_stretched_ext(s_fx_pixel, 0, _xx0, _yy0, _sw, _sh, _c);
						shader_reset();
						
						if(_a) _xx0 += _sw;
						else      _yy0 += _sh;
					}
					break;
					
			}
			
			if(random(1) < _cornDeco) {
				BLEND_SUBTRACT
					draw_set_color(c_white);
					var pd = 2;
					draw_point( _x0 + pd,     _y0 + pd     );
					draw_point( _x1 - pd - 1, _y0 + pd     );
					draw_point( _x0 + pd,     _y1 - pd - 1 );
					draw_point( _x1 - pd - 1, _y1 - pd - 1 );
				BLEND_NORMAL
			}
			
			switch(_dchr1) {
				case "s":
					random_set_seed(__seed_iter + _slotSeed);
					var _side = irandom(3);
					var _slot = irandom_range(_slotCont[0], _slotCont[1]);
					var _sltw = random_range(_slotSize[0], _slotSize[1]);
					var _slrt = random_range(_slotRato[0], _slotRato[1]);
					var _flip = choose(0, 1);
					var _lx0 = 0, _ly0 = 0;
					var _lx1 = 0, _ly1 = 0;
					var _lth = 1;
					
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
							
							_lth = _lw;
							_lx0 = _x1 - _lw/2 - 1;
							_ly0 = _yy0 - 1;
							
							repeat(_slot) {
								draw_rectangle(_x1 - _lw, _yy0, _x1, _yy0 + _lh, false);
								_yy0 += _lh + _slotSpac;
							}
							
							_lx1 = _lx0;
							_ly1 = _yy0 - _lh + _slotSpac + 1;
							_x1 -= _lw + 1;
							break;
						
						case 1 :
							var _ltw = _w * _slrt;
							var _lw  = floor(_ltw / _slot - _slotSpac);
							var _lh  = _sltw * _h;
							var _xx0 = _x0 + _slotSpac;
							if(_flip) _xx0 += _w - _ltw;
							
							_lw = abs(_lw);
							_lh = abs(_lh);
							
							_lth = _lh;
							_lx0 = _xx0 - 1;
							_ly0 = _y0 + _lh/2;
							
							repeat(_slot) {
								draw_rectangle(_xx0, _y0, _xx0 + _lw, _y0 + _lh, false);
								_xx0 += _lw + _slotSpac;
							}
							
							_lx1 = _xx0 - _lw + _slotSpac + 1;
							_ly1 = _ly0;
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
							
							_lth = _lw;
							_lx0 = _x0 + _lw/2;
							_ly0 = _yy0 - 1;
							
							repeat(_slot) {
								draw_rectangle(_x0, _yy0, _x0 + _lw, _yy0 - _lh, false);
								_yy0 -= _lh + _slotSpac;
							}
							
							_lx1 = _lx0;
							_ly1 = _yy0 - _lh + _slotSpac + 1;
							_x0 += _lw + 1;
							break;
							
						case 3 :
							var _ltw = _w * _slrt;
							var _lw  = floor(_ltw / _slot - _slotSpac);
							var _lh  = _sltw * _h;
							var _xx0 = _x1 - _slotSpac;
							if(_flip) _xx0 -= _w - _ltw;
							
							_lw = abs(_lw);
							_lh = abs(_lh);
							
							_lth = _lh;
							_lx0 = _xx0 + 1;
							_ly0 = _y1 - _lh/2 - 1;
							
							repeat(_slot) {
								draw_rectangle(_xx0, _y1, _xx0 - _lw, _y1 - _lh, false);
								_xx0 -= _lw + _slotSpac;
							}
							
							_lx1 = _xx0 - _lw + _slotSpac - 1;
							_ly1 = _ly0;
							_y1 -= _lh + 1;
							break;
							
					}
					BLEND_NORMAL
					break;
			}
			surface_reset_target();
			
			if(random(1) < _glowch && _dchr1 == "s") {
				_lx0 = clamp(_lx0, _box[0], _box[2]);
				_lx1 = clamp(_lx1, _box[0], _box[2]);
				_ly0 = clamp(_ly0, _box[1], _box[3]);
				_ly1 = clamp(_ly1, _box[1], _box[3]);
				
				var _llth = floor(_lth * _glows) - 1;
				var _pi   = 0;
				
				for( var i = _llth; i >= 0; i -= 2 ) {
					draw_set_color(array_safe_get(_glowc, _pi++, c_white, ARRAY_OVERFLOW.loop));
					draw_line_width(_lx0, _ly0, _lx1, _ly1, i);
				}
				
				surface_set_target(temp_surface[2]);
					draw_set_color(c_white)
					draw_line_width(_lx0, _ly0, _lx1, _ly1, _llth);
				surface_reset_target();
			}
			
			if(random(1) < _highRate) {
				shader_set(sh_mk_panel_higlight);
					shMKPanelsH.highlight.setA( random(1) < _highInv? [_highl[2], _highl[3], _highl[0], _highl[1]] : _highl  );
					draw_surface(temp_surface[0], 0, 0);
				shader_reset();
				
			} else {
				draw_surface(temp_surface[0], 0, 0);
			}
			
			surface_set_target(temp_surface[2]);
				shader_set(sh_mk_panel_glow_mask);
				draw_surface(temp_surface[0], 0, 0);
				shader_reset();
			surface_reset_target();
		#endregion
		
		if(_maxItr > -1 && _itr >= _maxItr) return;
		
		_w  = _x1 - _x0;
		_h  = _y1 - _y0;
		if(_w < _minW || _h < _minH) return;
		
		#region separate panels
			random_set_seed(__seed_iter + 10);
			var _pstr = "";
			var _pind = 0;
			
			if(_itr < string_length(panel_pre_pattern)) {
				_pstr = panel_pre_pattern;
				_pind = _itr + 1;
				
			} else {
				_pstr = panel_pattern;
				_pind = irandom_range(1, string_length(panel_pattern));
			}
			
			var _pchr  = string_char_at(_pstr, _pind);
			var _pchr1 = string_char_at(_pstr, _pind + 1);
			var _spww  = irandom_range(_splitWid[0], _splitWid[1]);
			
			if(string_digits(_pchr) == _pchr) {
				_pchr1 = _pchr;
				_pchr  = string_char_at(_pstr, _pind - 1);
			}
			
			if(_splitInv) switch(_pchr) {
				case "x" : if (_box[4] == "y" || _box[4] == "v") _pchr = "y"; break;
				case "y" : if (_box[4] == "x" || _box[4] == "h") _pchr = "x"; break;
				case "v" : if (_box[4] == "y" || _box[4] == "v") _pchr = "h"; break;
				case "h" : if (_box[4] == "x" || _box[4] == "h") _pchr = "v"; break;
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
					var _sw = round(max(1, _w * random_range(_inset[0], _inset[1])));
					var _sh = round(max(1, _h * random_range(_inset[0], _inset[1])));
					
					boxProcess([ _x0 + _sw, _y0 + _sh, _x1 - _sw, _y1 - _sh, _pchr ], _itr + 1);
					break;
				
				case "I" : // inset uniform
					var _si = round(max(1, min(_w, _h) * random_range(_inset[0], _inset[1])));
					
					boxProcess([ _x0 + _si, _y0 + _si, _x1 - _si, _y1 - _si, _pchr ], _itr + 1);
					break;
						
				case "e": // frame
				case "f": // frame
					var _sw = round(max(1, _w * random_range(_inset[0], _inset[1])));
					var _sh = round(max(1, _h * random_range(_inset[0], _inset[1])));
					
					if(choose(0,1)) {
						boxProcess([ _x0,       _y0,       _x1,       _y0 + _sh, _pchr ], _itr + 1);
						boxProcess([ _x0,       _y1 - _sh, _x1,       _y1,       _pchr ], _itr + 1);
						
						boxProcess([ _x0,       _y0 + _sh, _x0 + _sw, _y1 - _sh, _pchr ], _itr + 1);
						boxProcess([ _x1 - _sw, _y0 + _sh, _x1,       _y1 - _sh, _pchr ], _itr + 1);
						
					} else {
						boxProcess([ _x0,       _y0,       _x0 + _sw, _y1, _pchr ], _itr + 1);
						boxProcess([ _x1 - _sw, _y0,       _x1,       _y1, _pchr ], _itr + 1);
						
						boxProcess([ _x0 + _sw, _y0, _x1 - _sw, _y0 + _sh, _pchr ], _itr + 1);
						boxProcess([ _x0 + _sw, _y1 - _sh, _x1 - _sw, _y1, _pchr ], _itr + 1);
					}
					
					if(_pchr == "f") boxProcess([ _x0 + _sw, _y0 + _sh, _x1 - _sw, _y1 - _sh, _pchr ], _itr + 1);
					break;
					
				case "E": // frame uniform
				case "F": // frame uniform
					var _si = round(max(1, min(_w, _h) * random_range(_inset[0], _inset[1])));
					
					if(choose(0,1)) {
						boxProcess([ _x0,       _y0,       _x1,       _y0 + _si, _pchr ], _itr + 1);
						boxProcess([ _x0,       _y1 - _si, _x1,       _y1,       _pchr ], _itr + 1);
						
						boxProcess([ _x0,       _y0 + _si, _x0 + _si, _y1 - _si, _pchr ], _itr + 1);
						boxProcess([ _x1 - _si, _y0 + _si, _x1,       _y1 - _si, _pchr ], _itr + 1);
					
					} else {
						boxProcess([ _x0,       _y0,       _x0 + _si, _y1, _pchr ], _itr + 1);
						boxProcess([ _x1 - _si, _y0,       _x1,       _y1, _pchr ], _itr + 1);
						
						boxProcess([ _x0 + _si, _y0, _x1 - _si, _y0 + _si, _pchr ], _itr + 1);
						boxProcess([ _x0 + _si, _y1 - _si, _x1 - _si, _y1, _pchr ], _itr + 1);
					}
					
					if(_pchr == "F") boxProcess([ _x0 + _si, _y0 + _si, _x1 - _si, _y1 - _si, _pchr ], _itr + 1);
					break;
					
				case "C": // corner
				case "D": // corner
					var _si = round(max(1, min(_w, _h) * random_range(_inset[0], _inset[1])));
					
					if(_pchr == "C") boxProcess([ _x0, _y0, _x1, _y1, _pchr ], _itr + 1);
					
					boxProcess([ _x0,       _y0, _x0 + _si, _y0 + _si, _pchr ], _itr + 1);
					boxProcess([ _x1 - _si, _y0, _x1,       _y0 + _si, _pchr ], _itr + 1);
					
					boxProcess([ _x0,       _y1 - _si, _x0 + _si, _y1, _pchr ], _itr + 1);
					boxProcess([ _x1 - _si, _y1 - _si, _x1,       _y1, _pchr ], _itr + 1);
					break;
				
				default : if(_minItr != -1 && _itr < _minItr) boxProcess(_box, _itr + 1);
			}
		#endregion
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			__temp_data = _data;
			
			var _dim  = _data[ 1];
			var _seed = _data[ 2]; __seed_iter = _seed;
			var _area = _data[ 0];
			var _patt = _data[ 3];
			var _ratt = _data[ 7];
			
			var _pall = _data[ 5];
			var _glow = _data[32];
			
			var _posterize = _data[31];
			var _frame     = CURRENT_FRAME / TOTAL_FRAMES;
			
			update_on_frame = _data[36];
		#endregion
		
		#region pattern
			panel_pre_pattern = "";
			panel_pattern = _patt;
		
			var _patt_split = string_splice(_patt, "|");
			if(array_length(_patt_split) == 2) {
				panel_pre_pattern = _patt_split[0];
				panel_pattern     = _patt_split[1];
			}
			
			shape_pre_pattern = "";
			shape_pattern     = _ratt;
			
			var _ratt_split = string_splice(_ratt, "|");
			if(array_length(_ratt_split) == 2) {
				shape_pre_pattern = _ratt_split[0];
				shape_pattern     = _ratt_split[1];
			}
			
		#endregion
		
	    var _sw  = _dim[0];
	    var _sh  = _dim[1];
	    var _x0  = _area[AREA_INDEX.center_x] - _area[AREA_INDEX.half_w];
	    var _y0  = _area[AREA_INDEX.center_y] - _area[AREA_INDEX.half_h];
	    var _x1  = _area[AREA_INDEX.center_x] + _area[AREA_INDEX.half_w];
	    var _y1  = _area[AREA_INDEX.center_y] + _area[AREA_INDEX.half_h];
	    var _box = [ _x0, _y0, _x1, _y1, "o" ];
	    
	    for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
	    	temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
	    
	    if(string_length(_patt) == 0) return _outData;
	    if(string_length(_ratt) == 0) return _outData;
	    if(array_empty(_pall))        return _outData;
	    
	    shader_set(sh_mk_panels);
			shMKPanels.surfaceDim .setA( _dim    );
			shMKPanels.frame      .setF( _frame  );
		shader_reset();
		
		shader_set(sh_mk_panel_higlight);
			shMKPanelsH.dimension.setA( _dim );
		shader_reset();
					
		surface_set_target(temp_surface[2]);
			draw_clear(c_black);
		surface_reset_target();
		
		surface_set_target(temp_surface[1]);
			DRAW_CLEAR
			boxProcess(_box);
		surface_reset_target();
		
		if(_posterize) {
			surface_set_shader(_outData[0], sh_mk_panel_posterize);
				shader_set_palette(_pall, "palette", "keys");
				shader_set_s("glowMask", temp_surface[2]);
				
				draw_surface(temp_surface[1], 0, 0)
			surface_reset_shader();
			
		} else {
			surface_set_shader(_outData[0]);
				draw_surface(temp_surface[1], 0, 0)
			surface_reset_shader();
		}
		
		surface_set_shader(_outData[1]);
			draw_surface(temp_surface[2], 0, 0)
		surface_reset_shader();
		
		return _outData;
	}
}