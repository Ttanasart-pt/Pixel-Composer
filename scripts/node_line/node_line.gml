#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Line", "Data Type > Toggle",  "D", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[27].setValue((_n.inputs[27].getValue() + 1) % 4); });
		addHotkey("Node_Line", "Fix Length > Toggle", "F", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[19].setValue((_n.inputs[19].getValue() + 1) % 2); });
		addHotkey("Node_Line", "1px Mode > Toggle",   "1", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[17].setValue((_n.inputs[17].getValue() + 1) % 2); });
	});
	
	function __LinePoint(_x, _y, _prog, _progCrop, _weight = 1) constructor {
		x        = _x;
		y        = _y;
		prog     = _prog;
		progCrop = _progCrop;
		weight   = _weight;
		
		function toString() { return $"[{prog}]({x},{y})"; }
	}
	
#endregion

function Node_Line(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {	
	name = "Draw Line";
	
	newInput(39, nodeValueSeed());
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput(30, nodeValue_Bool(    "Use Path Bounding Box", false    ));
	newInput(31, nodeValue_Padding( "Padding",              [0,0,0,0] ))
	newInput(16, nodeValue_Bool(    "Width Pass",            false    ));
	
	////- =Background
	newInput( 1, nodeValue_EButton( "Background",    0, [ "None", "Solid", "Surface" ] ));
	newInput(48, nodeValue_Color(   "BG color",      ca_black ));
	newInput(49, nodeValue_Surface( "BG Surface"              ));
	newInput(50, nodeValue_EScroll( "BG Blend Mode", 0, [ "Override", "Max" ] ));
	
	////- =Line data
	newInput(27, nodeValue_EScroll(  "Data Type", 1, [ "Line", "Path", "Segments", "Two points" ]));
	newInput( 6, nodeValue_Rotation( "Rotation",  0 ));
	newInput( 7, nodeValue_PathNode( "Path"    ));
	newInput(28, nodeValue_Vector(   "Segment" )).setArrayDepth(2);
	newInput(32, nodeValue_Vec2(     "Start Point",   [0,.5] )).setUnitSimple();
	newInput(33, nodeValue_Vec2(     "End Point",     [1,.5] )).setUnitSimple();
	newInput(35, nodeValue_Bool(     "Force Loop",     false ));
	newInput(19, nodeValue_Bool(     "Fix Length",     false )).setTooltip("Fix length of each segment instead of segment count.");
	newInput( 2, nodeValue_ISlider(  "Segment",        1, [1, 32, 0.1] ));
	newInput(20, nodeValue_Float(    "Segment Length", 4 ));
	
	////- =Width
	newInput(17, nodeValue_Bool(  "1px Mode",             false      )).setTooltip("Render pixel perfect 1px line.");
	newInput( 3, nodeValue_Range( "Width",               [2,2], true )).setCurvable(11, CURVE_DEF_11);
	newInput(12, nodeValue_Bool(  "Span Width over Path", false      )).setTooltip("Apply the full 'Width Curve' to the trimmed path.");
	newInput(36, nodeValue_Bool(  "Apply Weight",         true       ));
	
	////- =Line settings
	newInput( 8, nodeValue_Slider_Range( "Range",    [0,1]  )).setTooltip("Range of the path to draw.");
	newInput(25, nodeValue_Bool(     "Invert",        false ));
	newInput( 9, nodeValue_Float(    "Shift",         0     ));
	newInput(26, nodeValue_Bool(     "Clamp Range",   false ));
	newInput(13, nodeValue_EButton(  "Start Cap",     0, __enum_array_gen([ "None", "Round", "Tri", "Square" ], s_node_line_cap)));
	newInput(43, nodeValue_EButton(  "End Cap",       0, __enum_array_gen([ "None", "Round", "Tri", "Square" ], s_node_line_cap)));
	newInput(14, nodeValue_ISlider(  "Round Segment", 8, [2, 32, 0.1] ));
	
	////- =Dash Line
	newInput(46, nodeValue_Bool(  "Dash",       false ));
	newInput(44, nodeValue_Float( "Dash Line",    [0] )).setDisplay(VALUE_DISPLAY.number_array);
	newInput(45, nodeValue_Float( "Dash Shift",    0  ));
	
	////- =Wiggle
	newInput(47, nodeValue_Bool(    "Use Wiggle",     false            ));
	newInput( 5, nodeValueSeed(,    "Wiggle Seed"                      ));
	newInput( 4, nodeValue_Float(   "Wig. Amplitude", 4                )).setCurvable(53, CURVE_DEF_11);
	newInput(51, nodeValue_Slider(  "Wig. Frequency", 8, [0, 32, 0.01] )).setCurvable(54, CURVE_DEF_11);
	newInput(52, nodeValue_ISlider( "Wig. Detail",    4, [0,  8, 1]    ));
	newInput(55, nodeValue_Float(   "Wig. Phase",     0                ));
	newInput(56, nodeValue_Bool(    "Wig. Trim Range",      false      ));
	newInput(57, nodeValue_Bool(    "Wig. Trim Curve",      false      ));
	
	////- =Color
	newInput(10, nodeValue_Gradient( "Color over Length",    gra_white ));
	newInput(24, nodeValue_Gradient( "Random Blend",         gra_white ));
	newInput(15, nodeValue_Bool(     "Span Color over Path", false )).setTooltip("Apply the full 'color over length' to the trimmed path.");
	newInput(37, nodeValue_Gradient( "Color Weight",         gra_white ));
	newInput(38, nodeValue_Vec2(     "Color Range",          [0,1] ));
	
	////- =Texture
	newInput(18, nodeValue_Surface(  "Texture" ));
	newInput(21, nodeValue_Vec2(     "Texture Position",       [0,0] ));
	newInput(22, nodeValue_Rotation( "Texture Rotation",        0    ));
	newInput(23, nodeValue_Vec2(     "Texture Scale",          [1,1] ));
	newInput(29, nodeValue_Bool(     "Scale Texture to Length", true ));
	
	////- =Line Cap
	newInput(40, nodeValue_Surface( "Start Cap" ));
	newInput(41, nodeValue_Surface( "End Cap"   ));
	newInput(42, nodeValue_Bool(    "Rotate Cap", true ));
	
	////- =Render
	newInput(34, nodeValue_EScroll( "SSAA", 0, [ "None", "2x", "4x", "8x" ] ));
	// Inputs 58
	
	input_display_list = [ 39, 
		[ "Output",         true     ],  0, 30, 31, 16, 
		[ "Background",     true     ],  1, 48, 49, 50, 
		[ "Line Data",     false     ], 27,  6,  7, 28, 32, 33, 35, 19,  2, 20, 
		[ "Width",         false     ], 17,  3, 11, 12, 36, 
		[ "Line Settings", false     ],  8, 25,  9, 26, 13, 43, 14, 
		[ "Dash",          false, 46 ], 44, 45, 
		[ "Wiggle",        false, 47 ],  5,  4, 53, 51, 54, 52, 55, 56, 57, 
		[ "Color",         false     ], 10, 24, 15, 37, 38, 
		[ "Texture",       false     ], 18, 21, 22, 23, 29, 
		[ "Textured Cap",  false     ], 40, 41, 42, 
		[ "Render",         true     ], 34, 
	];
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output( "Width Pass", VALUE_TYPE.surface, noone));
	
	////- Nodes
	
	lines        = [];
	line_data    = [];
	temp_surface = [ noone ];
	widthMap     = ds_map_create();
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		draw_set_color(COLORS._main_icon);
		for( var i = 0, n = array_length(lines); i < n; i++ ) {
			var points = lines[i];
			if(array_length(points) < 2) continue;
				
			for( var j = 1; j < array_length(points); j++ ) {
				var x0 = _x + points[j-1].x * _s;
				var y0 = _y + points[j-1].y * _s;
				var x1 = _x + points[j  ].x * _s;
				var y1 = _y + points[j  ].y * _s;
				
				draw_line_width(x0, y0, x1, y1, 4);
			}
		}
		
		var _dtype = getInputData(27);
		
		if(_dtype == 1) {
			InputDrawOverlay(inputs[7].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
			
		} else if(_dtype == 3) {
			InputDrawOverlay(inputs[32].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
			InputDrawOverlay(inputs[33].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		}
		
		return w_hovering;
	}
	
	static onValueUpdate = function(index = 0) {
		if(index == 11) ds_map_clear(widthMap);
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _seed     = _data[39];
			
			var _bg       = _data[ 1];
			var _bgcol    = _data[48];
			var _bgSurf   = _data[49];
			var _bgBlnd   = _data[50];
			
			var _dim      = _data[ 0];
			var _pbbox    = _data[30];
			var _ppadd    = _data[31];
			var _colW     = _data[16];
			
			var _dtype    = _data[27];
			var _ang      = _data[ 6];
			var _pat      = _data[ 7]; 
			var _segs     = _data[28];
			var _pnt0     = _data[32];
			var _pnt1     = _data[33];
			var _loop     = _data[35];
			var _fixL     = _data[19];
			var _seg      = _data[ 2];
			var _segL     = _data[20];
			
			var _1px      = _data[17];
			var _wid      = _data[ 3];
			var _widc     = _data[11], _widcUse = inputs[3].attributes.curved;
			var _widap    = _data[12];
			var _wg2wid   = _data[36];
			
			var _ratio    = _data[ 8];
			var _ratInv   = _data[25];
			var _shift    = _data[ 9];
			var _clamp    = _data[26];
			var _capS     = _data[13];
			var _capE     = _data[43];
			var _capP     = _data[14];
			
			var _dashUse  = _data[46];
			var _dashPat  = _data[44];
			var _dashShf  = _data[45];
			
			var _wigUse   = _data[47];
			var _sed      = _data[ 5];
			var _wigA     = _data[ 4];
			var _wigAC    = getInputData(53), curve_wigA = inputs[ 4].attributes.curved? new curveMap(_wigAC)  : undefined;
			
			var _wigF     = _data[51];
			var _wigFC    = getInputData(54), curve_wigF = inputs[ 4].attributes.curved? new curveMap(_wigFC)  : undefined;
			
			var _wigI     = _data[52];
			var _wigP     = _data[55];
			var _wigTrmR  = _data[56];
			var _wigTrmC  = _data[57];
			
			var _color    = _data[10];
			var _colb     = _data[24];
			var _colP     = _data[15];
			var _wg2clr   = _data[37];
			var _wg2clrR  = _data[38];
			
			var _tex      = _data[18];
			var _texPos   = _data[21];
			var _texRot   = _data[22]; _texRot = degtorad(_texRot);
			var _texSca   = _data[23];
			var _scaleTex = _data[29];
			
			var _cap_st   = _data[40];
			var _cap_ed   = _data[41];
			var _cap_rt   = _data[42];
			
			var _aa       = power(2, _data[34]);
		#endregion
		
		#region visible
			var _utex = inputs[18].value_from != noone;
		
			inputs[ 3].setVisible(!_1px);
			inputs[12].setVisible(!_1px);
			inputs[13].setVisible(!_1px && !_utex);
			inputs[14].setVisible(!_1px);
			inputs[18].setVisible(!_1px);
			
			inputs[15].setVisible(!_utex);
			inputs[16].setVisible(!_utex);
			
			inputs[ 2].setVisible(!_fixL);
			inputs[20].setVisible( _fixL);
			
			inputs[ 6].setVisible(_dtype == 0);
			inputs[ 7].setVisible(_dtype == 1, _dtype == 1);
			inputs[28].setVisible(_dtype == 2, _dtype == 2);
			
			inputs[30].setVisible( _dtype == 1 || _dtype == 2);
			inputs[31].setVisible((_dtype == 1 || _dtype == 2) && _pbbox);
			
			inputs[32].setVisible(_dtype == 3);
			inputs[33].setVisible(_dtype == 3);
			
			inputs[48].setVisible(_bg == 1);
			inputs[49].setVisible(_bg == 2);
			inputs[50].setVisible(_bg == 2);
			
			outputs[1].setVisible(_colW);
			
			if(_dtype == 1 && !is_path(_pat))  
				_dtype = 0;
				
			if(_dtype == 2 && (array_invalid(_segs) || array_invalid(_segs[0]))) 
				_dtype = 0; 
		#endregion
		
		#region line data
			random_set_seed(_seed);
			
			if(IS_FIRST_FRAME || inputs[11].is_anim)
				ds_map_clear(widthMap);
			
			var _surfDim = [ _dim[0], _dim[1] ];
			var __debug_timer = get_timer();
			
			var _rtStr = min(_ratio[0], _ratio[1]) + _shift;
			var _rtEnd = max(_ratio[0], _ratio[1]) + _shift;
			var _rtRng = _rtEnd - _rtStr;
			if(_rtRng <= 0) return _outData;
			
			var _useTex = !_1px && is_surface(_tex);
			
			if(_useTex) { 
				_capS = false; 
				_capE = false; 
				_1px  = false; 
			}
			
			if(_1px) {
				_capS = false; 
				_capE = false; 
			}
			
			random_set_seed(_sed);
			
			var p = new __vec2P();
			var _pathData = [];
			var minx = 999999, miny = 999999, maxx = -999999, maxy = -999999;
			
			var _ox, _nx, _nx1, _oy, _ny, _ny1;
			var _ow, _nw, _oa, _na, _oc, _nc, _owg, _nwg;
			var _op, _np;
			var wmin = 0, wmax = 1;
			
			switch(_dtype) {
				case 0 :
				case 3 :
					var x0, y0, x1, y1;
					
					if(_dtype == 0) {
						_ang = (_ang % 360 + 360) % 360;
					
						var _0 = point_rectangle_overlap(_dim[0], _dim[1], (_ang + 180) % 360);
						var _1 = point_rectangle_overlap(_dim[0], _dim[1], _ang);
						x0 = _0[0]; 
						y0 = _0[1];
						x1 = _1[0]; 
						y1 = _1[1];
						
					} else if(_dtype == 3) {
						x0 = _pnt0[0]; 
						y0 = _pnt0[1];
						x1 = _pnt1[0]; 
						y1 = _pnt1[1];
					}
					
					var _l = point_distance(x0, y0, x1, y1);
					var _d = point_direction(x0, y0, x1, y1);
					var _od = _d, _nd = _d;
						
					var ww          = _rtRng / _seg;
					var _total		= _rtRng;
					var _prog_total	= 0;
					var _prog_curr	= frac(_rtStr + _shift);
					var _prog_prev	= undefined;
					var points = [];
					
					lines     = [ points ];
					line_data = [ { length: 1 } ];
					
					while(_total > 0) {
						
						if(_prog_prev != undefined) {
							var stepSize = min(_total, ww, 1 - _prog_curr);
							_prog_curr  += stepSize;
							_prog_total += stepSize;
							_total      -= stepSize;
						}
						
						_nx = x0 + lengthdir_x(_l * _prog_curr, _d);
						_ny = y0 + lengthdir_y(_l * _prog_curr, _d);
							
						if(_wigUse) {
							var wgAmp = _wigA * (curve_wigA? curve_wigA.get(_prog_curr) : 1);
							var wgFre = _wigF * (curve_wigF? curve_wigF.get(_prog_curr) : 1);
							var wgLen = randomFractal(_sed, _prog_curr + _wigP, wgFre, _wigI) * wgAmp;
							_nx += lengthdir_x(wgLen, _d + 90); 
							_ny += lengthdir_y(wgLen, _d + 90);
						}
							
						array_push(points, new __LinePoint(_nx, _ny, _prog_total / _rtEnd, _prog_curr));
						
						if(_prog_curr == 1) {
							_prog_curr = 0;
							_prog_prev = undefined;
							points = [];
							
							array_push(lines, points);
							array_push(line_data, { length: 1 });
							
						} else
							_prog_prev = _prog_curr;
						
						_ox = _nx;
						_oy = _ny;
					}
					
					break;
					
				case 1 :
					var lineCount = 1; 
					if(struct_has(_pat, "getLineCount")) lineCount = _pat.getLineCount();
					if(struct_has(_pat, "getPathData"))  _pathData = _pat.getPathData();
					
					lines = array_verify(lines, lineCount);
					
					var _useDistance = _fixL && struct_has(_pat, "getLength");
					var _lineAmo     =  0;
					var wmin =  infinity;
					var wmax = -infinity;
					
					var _nx, _ny, _nw, _pl;
					var _pathLength, _prog;
					var points;
					
					for( var i = 0; i < lineCount; i++ ) {
						_pathLength = _useDistance? _pat.getLength(i) : 1;
						if(_pathLength <= 0) continue;
						
						var _pamo = _useDistance? ceil(_pathLength / _segL) + 1 : _seg;
						points = array_create(_pamo);
						
						for( var i = 0; i < _pamo; i++ ) {
							if(_useDistance) {
								_pl   = min(i * _segL, _pathLength);
								 p    = _pat.getPointDistance(_pl, i, p);
								_prog = _pl / _pathLength; 
								
							} else {
								_prog = i / (_pamo - 1);
								 p    = _pat.getPointRatio(_prog, i, p);
							}
							
							_nx = p.x;
							_ny = p.y;
							_nw = p[$ "weight"] ?? 1;
							
							points[i] = new __LinePoint( _nx, _ny, _prog, _prog, _nw );
							
							minx = min(minx, _nx); miny = min(miny, _ny);
							maxx = max(maxx, _nx); maxy = max(maxy, _ny);
							wmin = min(wmin, _nw); wmax = max(wmax, _nw);
						}
						
						if(_rtStr != 0 || _rtEnd != 1) { // trim
							var pointCrop = [];
							p0 = points[0];
							
							if(_rtStr <= 0) array_push(pointCrop, p0);
									
							for( var j = 1, m = array_length(points); j < m; j++ ) {
								p1 = points[j];
								var _p0 = p0.prog;
								var _p1 = p1.prog;
								
								if(_rtStr > _p0 && _rtStr < _p1) {
									var _midProg = (_rtStr - _p0) / (_p1 - _p0);
									array_push(pointCrop, new __LinePoint( 
										lerp(p0.x,      p1.x,      _midProg), 
										lerp(p0.y,      p1.y,      _midProg), 
										lerp(p0.prog,   p1.prog,   _midProg), 
										lerp(p0.prog,   p1.prog,   _midProg), 
										lerp(p0.weight, p1.weight, _midProg), 
									));
								}
								
								if(_rtEnd > _p0 && _rtEnd < _p1) {
									var _midProg = (_rtEnd - _p0) / (_p1 - _p0);
									array_push(pointCrop, new __LinePoint( 
										lerp(p0.x,      p1.x,      _midProg), 
										lerp(p0.y,      p1.y,      _midProg), 
										lerp(p0.prog,   p1.prog,   _midProg), 
										lerp(p0.prog,   p1.prog,   _midProg), 
										lerp(p0.weight, p1.weight, _midProg), 
									));
								}
								
								if(_rtStr <= _p1 && _rtEnd >= _p1)
									array_push(pointCrop, p1);
								
								p0 = p1;
							}
							
							for( var j = 0, m = array_length(pointCrop); j < m; j++ )
								pointCrop[j].prog = (pointCrop[j].prog - _rtStr) / _rtRng;
							
							points = pointCrop;
						} // trim
						
						if(_wigUse) { // wiggle
							for( var j = 0, m = array_length(points); j < m; j++ ) {
								var p0 = points[clamp(j-1, 0, m-1)];
								var p  = points[j];
								var p1 = points[clamp(j+1, 0, m-1)];
								
								p.dirr = point_direction(p0.x, p0.y, p1.x, p1.y); 
							}
							
							for( var j = 0, m = array_length(points); j < m; j++ ) {
								var p   = points[j];
								var pgr = _wigTrmR? p.progCrop : p.prog;
								var pgc = _wigTrmC? p.progCrop : p.prog;
								
								var wgAmp = _wigA * (curve_wigA? curve_wigA.get(pgc) : 1);
								var wgFre = _wigF * (curve_wigF? curve_wigF.get(pgc) : 1);
								var wgDis = randomFractal(_seed, pgr + _wigP, wgFre, _wigI) * wgAmp;
								var wgDir = p.dirr + 90; 
								
								p.x += lengthdir_x(wgDis, wgDir);
								p.y += lengthdir_y(wgDis, wgDir);
							}
						} // wiggle
						
						if(array_empty(points)) continue;
						if(_loop)   array_push(points, points[0]);
						if(_ratInv) array_reverse_ext(points);
						
						lines[_lineAmo]     = points;
						line_data[_lineAmo] = { length: _pathLength };
						
						_lineAmo++;
					}
					
					array_resize(lines,     _lineAmo);
					array_resize(line_data, _lineAmo);
					
					if(wmax == wmin) { wmin = 0; wmax = 1; }
					
					if(_pbbox) _surfDim = [ max(1, maxx - minx + _ppadd[0] + _ppadd[2]), max(1, maxy - miny + _ppadd[1] + _ppadd[3]) ];
					
					break;
					
				case 2 :
					if(!is_array(_segs[0][0])) //spreaded single path
						_segs = [ _segs ];
					
					lines     = array_create(array_length(_segs));
					line_data = array_create(array_length(_segs));
					
					for (var i = 0, n = array_length(_segs); i < n; i++) {
						var _seg    = _segs[i];
						if(array_empty(_seg)) continue;
						
						var m = array_length(_seg);
						
						var _uselen = array_length(_seg[0]) >= 3;
						var _lin    = array_create(m);
						
						var _l, _len = [ 0 ], _lenTotal = 0;
						var ox = _seg[0][0], oy = _seg[0][1], nx, ny;
						
						for (var j = 1; j < m; j++) {
							nx = _seg[j][0];
							ny = _seg[j][1];
							_l = point_distance(ox, oy, nx, ny);
							
							_len[j]    = _l;
							_lenTotal += _l;
							
							ox = nx;
							oy = ny;
						}
						
						if(_uselen) {
							for (var j = 0; j < m; j++)
								_lin[j] = new __LinePoint( _seg[j][0],  _seg[j][1],  _seg[j][2],  _seg[j][2] );
							
						} else {
							for (var j = 0; j < m; j++)
								_lin[j] = new __LinePoint( _seg[j][0], _seg[j][1], _len[j] / _lenTotal, _len[j] / _lenTotal );
						}
						
						if(_loop) _lin[m] = _lin[0];
						
						for (var j = 0; j < m; j++) {
							minx = min(minx, _lin[j].x);
							miny = min(miny, _lin[j].y);
							maxx = max(maxx, _lin[j].x);
							maxy = max(maxy, _lin[j].y);
						}
						
						lines[i]     = _lin;
						line_data[i] = { length: _lenTotal };
					}
					
					if(_pbbox) _surfDim = [ max(1, maxx - minx + _ppadd[0] + _ppadd[2]), max(1, maxy - miny + _ppadd[1] + _ppadd[3]) ];
					break;
					
					
			}
			
		#endregion
			
		#region dash
			if(_dashUse) {
				if(array_length(_dashPat) == 1)
					_dashPat = [ _dashPat[0], _dashPat[0] ];
				
				var _dashAmo   = array_length(_dashPat);
				var _dashTotal = array_sum(_dashPat);
				
				if(_dashAmo >= 2 && _dashTotal >= 2) {
					var _dashed     = [];
					var _dashedData = [];
					var dash_index  = 0;
					var dash_left   = 0;
					
					var dash_shift = _dashShf;
					    dash_shift = dash_shift % _dashTotal;
					
					if(dash_shift < 0) 
						dash_shift = (dash_shift + _dashTotal) % _dashTotal;
					
					for( var i = 0, n = array_length(_dashPat); i < n; i++ ) {
						if(dash_shift < _dashPat[i]) break;
							
						dash_shift -= _dashPat[i];
						dash_index++;
					}
					
					for( var i = 0, n = array_length(lines); i < n; i++ ) {
						if(array_length(lines[i]) < 2) continue;
						var points  = lines[i];
						var ldata   = line_data[i];
						var dpoints = [];
						
						var op = points[0];
						var ox = op.x;
						var oy = op.y;
						
						for( var j = 1, m = array_length(points); j < m; j++ ) {
							var np = points[j];
							var nx = np.x;
							var ny = np.y;
							
							var dash_draw = !(dash_index % 2);
							var _lRaw = point_distance(ox, oy, nx, ny);
							var _l    = _lRaw;
							var _rat  = 0;
							
							dash_left = _dashPat[dash_index] - dash_shift;
							// print(op, np, "|", dash_index, dash_left, dash_shift);
								
							if(dash_draw) array_push(dpoints, op);
							while(_l > 0) {
								
								var dash_step = min(_l, dash_left);
								var dash_offs = dash_left - dash_step;
								
								_l   -= dash_step;
								_rat += dash_step / _lRaw;
								
								var rp = new __LinePoint(
									lerp(ox,          nx,          _rat), 
									lerp(oy,          ny,          _rat), 
									lerp(op.prog,     np.prog,     _rat), 
									lerp(op.progCrop, np.progCrop, _rat), 
									lerp(op.weight,   np.weight,   _rat)
								);
								
								// print(" > ", _rat, rp, dash_draw);
								
								if(!dash_draw) {
									if(array_length(dpoints) >= 2) {
										array_push(_dashed, dpoints);
										array_push(_dashedData, { length: 1 });
									} 
									
									dpoints = [rp];
									
								} else 
									array_push(dpoints, rp);
								
								if(dash_offs == 0) {
									dash_index =  (dash_index + 1) % _dashAmo;
									dash_draw  = !(dash_index % 2);
									dash_left  = _dashPat[dash_index];
									
								} else 
									dash_left -= dash_step;
							}
							
							dash_shift = _dashPat[dash_index] - dash_left;
							// print(dash_shift, dash_left)
							
							op = np;
							ox = nx;
							oy = ny;
						}
						
						if(array_length(dpoints) >= 2) {
							array_push(_dashed, dpoints);
							array_push(_dashedData, { length: 1 });
						}
					}
					
					for( var i = 0, n = array_length(_dashed); i < n; i++ ) {
						var d = _dashed[i];
						for( var j = array_length(d) - 1; j >= 1; j-- ) {
							if(abs(d[j].x - d[j-1].x) < 1.5 && abs(d[j].y - d[j-1].y) < 1.5)
								array_delete(d, j, 1);
						}
					}
					
					lines     = _dashed;
					line_data = _dashedData;
				}
			}
		#endregion
			
		////- Draw
		
		var _colorPass = surface_verify(_outData[0], _surfDim[0], _surfDim[1], attrDepth());
		var _widthPass = surface_verify(_outData[1], _surfDim[0], _surfDim[1], attrDepth());
		var _padx = _pbbox * (_ppadd[2] - minx);
		var _pady = _pbbox * (_ppadd[1] - miny);
		
		var _wg2clrRng = _wg2clrR[1] - _wg2clrR[0];
		
		temp_surface[0] = surface_verify(temp_surface[0], _surfDim[0] * _aa, _surfDim[1] * _aa, attrDepth());
		var _cPassAA = temp_surface[0];
		var _capSta  = undefined;
		var _capEnd  = undefined;
		
		surface_set_target(_cPassAA);
			DRAW_CLEAR
			
			for( var i = 0, n = array_length(lines); i < n; i++ ) {
				if(array_length(lines[i]) < 2) continue;
				var points = lines[i];
				random_set_seed(_sed + i);
				
				var _ldata = line_data[i];
				var _len   = _ldata.length;
				var pxs    = [];
				var dat    = array_safe_get_fast(_pathData, i, noone);
				
				if(_useTex) {
					var tex = surface_get_texture(_tex);
				
					shader_set(sh_draw_mapping);
					shader_set_2("position", _texPos);
					shader_set_f("rotation", _texRot);
					shader_set_2("scale",    _texSca);
					shader_set_i("flipAxis", true);
					
					shader_set_interpolation(_tex);
					if(_scaleTex) shader_set_2("scale", [ _texSca[0] * _len, _texSca[1] ]);
					draw_primitive_begin_texture(pr_trianglestrip, tex);
					
				} else 
					draw_primitive_begin(pr_trianglestrip);
				
				var _col_base = dat == noone? gradientEval(_colb, random(1)) : dat.color;
				_ow = 1;
				
				var _stx = 0, _sty = 0, _sta = 0;
				var _edx = 0, _edy = 0, _eda = 0;
				
				for( var j = 0, m = array_length(points); j < m; j++ ) {
					var p0   = points[j];
					var _nx  = p0.x - 0.5 * _1px + _padx;
					var _ny  = p0.y - 0.5 * _1px + _pady;
					
					var prog = p0.prog;
					var prgc = p0.progCrop;
					var _dir = j? point_direction(_ox, _oy, _nx, _ny) : 
					              point_direction(_nx, _ny, points[j+1].x + _padx, points[j+1].y + _pady);
					
					     if(j ==   0) { _stx = _nx; _sty = _ny;              }
					else if(j ==   1) { _sta = _dir;                         }
					else if(j == m-1) { _edx = _nx; _edy = _ny; _eda = _dir; }
					
					var widProg = value_snap_real(_widap? prog : prgc, 0.01);
					_nw = random_range(_wid[0], _wid[1]);
					
					if(_widcUse) {
						if(!ds_map_exists(widthMap, widProg))
							widthMap[? widProg] = eval_curve_x(_widc, widProg, 0.1);
						_nw *= widthMap[? widProg];
					}
					
					var _ww = lerp_invert(p0.weight, wmin, wmax);
					if(is_nan(_ww)) _ww = 1;
					if(_wg2wid) _nw *= _ww / 2;
					
					_np = _colP? prog : prgc;
					_nc = _col_base;
					_nc = colorMultiply(_nc, gradientEval(_color, _np));
					_nc = colorMultiply(_nc, gradientEval(_wg2clr, (_ww - _wg2clrR[0]) / _wg2clrRng));
					_nd = _dir;
					
					if(j && _capSta == undefined) {
						_d = _dir + 180;
						_capSta = [
							[_capS, _oc, _ox * _aa, _oy * _aa, _ow / 2 * _aa, _d - 90, _d, _capP],
							[_capS, _oc, _ox * _aa, _oy * _aa, _ow / 2 * _aa, _d, _d + 90, _capP],
						];
					}
					
					_d = _dir;
					_capEnd = [
						[_capE, _nc, _nx * _aa, _ny * _aa, _nw / 2 * _aa, _d - 90, _d, _capP],
						[_capE, _nc, _nx * _aa, _ny * _aa, _nw / 2 * _aa, _d, _d + 90, _capP],
					];
					
					if(j)
					if(_1px) { 
						var dst = point_distance(_ox, _oy, _nx, _ny);
						if(dst <= 1 && i < m - 1) continue;
						draw_line_color(_ox * _aa, _oy * _aa, _nx * _aa, _ny * _aa, _oc, _nc);
						
					} else { 
						var _nd0 = _dir;
						var _nd1 = _nd0;
						
						if(j < m - 1) {
							var p2 = points[j + 1];
							var _nnx = p2.x + _padx;
							var _nny = p2.y + _pady;
							
							_nd1 = point_direction(_nx, _ny, _nnx, _nny);
							_nd = _nd0 + angle_difference(_nd1, _nd0) / 2;
						} else 
							_nd = _nd0;
						
						if(_useTex) {
							var _len = m - 1;
							
							var ox0 = _ox + lengthdir_x(_ow / 2, _od + 90);
							var oy0 = _oy + lengthdir_y(_ow / 2, _od + 90);
							var nx0 = _nx + lengthdir_x(_nw / 2, _nd + 90);
							var ny0 = _ny + lengthdir_y(_nw / 2, _nd + 90);

							var ox1 = _ox + lengthdir_x(_ow / 2, _od + 90 + 180);
							var oy1 = _oy + lengthdir_y(_ow / 2, _od + 90 + 180);
							var nx1 = _nx + lengthdir_x(_nw / 2, _nd + 90 + 180);
							var ny1 = _ny + lengthdir_y(_nw / 2, _nd + 90 + 180);
							
							var _u0 = 0;
							var _u1 = 1;
							var _v0 = _op;
							var _v1 = _np;
							
							draw_vertex_texture_color(ox0 * _aa, oy0 * _aa, _u0, _v0, _oc, 1);
							draw_vertex_texture_color(ox1 * _aa, oy1 * _aa, _u1, _v0, _oc, 1);
							draw_vertex_texture_color(nx0 * _aa, ny0 * _aa, _u0, _v1, _nc, 1);
							draw_vertex_texture_color(nx1 * _aa, ny1 * _aa, _u1, _v1, _nc, 1);
							
						} else {
							draw_line_width2_angle(_ox * _aa, _oy * _aa, _nx * _aa, _ny * _aa, 
							                       _ow * _aa, _nw * _aa, _od +  90, _nd +  90, _oc, _nc);
						}
					}
					
					_ox = _nx;
					_oy = _ny;
					_oc = _nc;
				
					_od = _nd;
					_ow = _nw;
					_op = _np;
					
					if(j % 120 == 0) {
						draw_primitive_end();
						if(_useTex) draw_primitive_begin_texture(pr_trianglestrip, tex); else draw_primitive_begin(pr_trianglestrip);
					}
				}
				
				draw_primitive_end();
				
				if(_capS && _capSta != undefined) {
					var c = _capSta[0]; drawCaps( c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7] );
					var c = _capSta[1]; drawCaps( c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7] );
				}
				
				if(_capE && _capEnd != undefined) {
					var c = _capEnd[0]; drawCaps( c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7] );
					var c = _capEnd[1]; drawCaps( c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7] );
				}
				
				if(_useTex) shader_reset();
				
				if(!array_empty(points)) {
					var _pp = [ 0, 0 ];
					
					if(is_surface(_cap_st)) {
						var _cap_st_s = _aa;
						var _cap_st_w = surface_get_width_safe(_cap_st);
						var _cap_st_h = surface_get_height_safe(_cap_st);
						var _rr = _cap_rt? _sta : 0;
						_pp = point_rotate_origin(-_cap_st_w / 2, -_cap_st_h / 2, _rr, _pp);
						
						var _cap_st_x = (_stx + _pp[0]) * _aa;
						var _cap_st_y = (_sty + _pp[1]) * _aa;
						
						draw_surface_ext(_cap_st, _cap_st_x, _cap_st_y, _cap_st_s, _cap_st_s, _rr, c_white, 1);
					}
					
					if(is_surface(_cap_ed)) {
						var _cap_ed_s = _aa;
						var _cap_ed_w = surface_get_width_safe(_cap_ed);
						var _cap_ed_h = surface_get_height_safe(_cap_ed);
						var _rr = _cap_rt? _eda : 0;
						_pp = point_rotate_origin(-_cap_ed_w / 2, -_cap_ed_h / 2, _rr, _pp);
						
						var _cap_ed_x = (_edx + _pp[0]) * _aa;
						var _cap_ed_y = (_edy + _pp[1]) * _aa;
						
						draw_surface_ext(_cap_ed, _cap_ed_x, _cap_ed_y, _cap_ed_s, _cap_ed_s, _rr, c_white, 1);
					}
				}
				
			}
		surface_reset_target();
		
		surface_set_shader(_colorPass, noone, true, BLEND.over);
			switch(_bg) {
				case 1 : 
					draw_clear(_bgcol); 
					BLEND_NORMAL
					break;
					
				case 2 : 
					BLEND_OVERRIDE
					draw_surface_safe(_bgSurf, 0, 0); 
					
					     if(_bgBlnd == 0) { BLEND_NORMAL }
					else if(_bgBlnd == 1) { BLEND_ADD    }
					break;
			}
			
			shader_set(sh_downsample);
			shader_set_dim("dimension", _cPassAA);
			shader_set_f("down", _aa);
			draw_surface(_cPassAA, 0, 0);
			shader_reset();
		surface_reset_shader();
		
		if(_colW && !_1px) { // width pass
			surface_set_target(_widthPass);
				if(_bg) draw_clear_alpha(0, 1);
				else	DRAW_CLEAR
				
				for( var i = 0, n = array_length(lines); i < n; i++ ) {
					if(array_length(lines[i]) < 2) continue;
					var points = lines[i];
					
					draw_primitive_begin(pr_trianglestrip);
					
					random_set_seed(_sed + i);
					var pxs = [];
					var dat = array_safe_get_fast(_pathData, i, noone);
					
					var _col_base = dat == noone? gradientEval(_colb, random(1)) : dat.color;
					
					for( var j = 0, m = array_length(points); j < m; j++ ) {
						var p0   = points[j];
						var _nx  = p0.x - 0.5 * _1px + _padx;
						var _ny  = p0.y - 0.5 * _1px + _pady;
						
						var prog = p0.prog;
						var prgc = p0.progCrop;
						var _dir = j? point_direction(_ox, _oy, _nx, _ny) : 0;
						
						var widProg = value_snap_real(_widap? prog : prgc, 0.01);
						_ww = lerp_invert(p0.weight, wmin, wmax);
						_nw = random_range(_wid[0], _wid[1]);
						
						if(_widcUse) {
							if(!ds_map_exists(widthMap, widProg))
								widthMap[? widProg] = eval_curve_x(_widc, widProg, 0.1);
							_nw *= widthMap[? widProg];
						}
						
						if(_wg2wid) _nw *= _ww / 2;
						
						if(j) {
							var _nd0 = _dir;
							var _nd1 = _nd0;
							
							if(j < m - 1) {
								var p2 = points[j + 1];
								var _nnx = p2.x + _padx;
								var _nny = p2.y + _pady;
						
								_nd1 = point_direction(_nx, _ny, _nnx, _nny);
								_nd  = _nd0 + angle_difference(_nd1, _nd0) / 2;
							} else 
								_nd = _nd0;
							
							draw_line_width2_angle_width(_ox, _oy, _nx, _ny, _ow, _nw, _od + 90, _nd + 90, c_white, c_white);
						} else {
							var p1   = points[j + 1];
							_nd = point_direction(_nx, _ny, p1.x + _padx, p1.y + _pady);
						}
					
						_ox = _nx;
						_oy = _ny;
						_od = _nd;
						_ow = _nw;
						
						if(j % 120 == 0) {
							draw_primitive_end();
							draw_primitive_begin(pr_trianglestrip);
						}
					}
					
					draw_primitive_end();
					
					if(_capS && _capSta != undefined) {
						var c = _capSta[0]; drawCaps( c[0], c_grey, c[2], c[3], c[4], c[5], c[6], true );
						var c = _capSta[1]; drawCaps( c[0], c_grey, c[2], c[3], c[4], c[5], c[6], true );
					}
					
					if(_capE && _capEnd != undefined) {
						var c = _capEnd[0]; drawCaps( c[0], c_grey, c[2], c[3], c[4], c[5], c[6], true );
						var c = _capEnd[1]; drawCaps( c[0], c_grey, c[2], c[3], c[4], c[5], c[6], true );
					}
					
				}
				
			surface_reset_target();
			
		}
		
		return [ _colorPass, _widthPass ];
	}
	
	static drawCaps = function(_typ, _cpc, _cpx, _cpy, _cpr, _a0, _a1, _prec = 32, w = false) {
		var _0 = c_black;
		var _1 = c_white;
		var _c = _cpc;
		draw_set_color(_c);
		
		switch(_typ) {
			case 1 : 
				if(w) draw_circle_angle(_cpx, _cpy, _cpr, _a0, _a1, _prec, _1, _0); 
				else  draw_circle_angle(_cpx, _cpy, _cpr, _a0, _a1, _prec, _c, _c); 
				break;
				
			case 2 : 
				var _x0 = _cpx + lengthdir_x(_cpr, _a0) - 1;
				var _y0 = _cpy + lengthdir_y(_cpr, _a0) - 1;
				var _x2 = _cpx + lengthdir_x(_cpr, _a1) - 1;
				var _y2 = _cpy + lengthdir_y(_cpr, _a1) - 1;
				
				if(w) draw_triangle_color(_cpx - 1, _cpy - 1, _x0, _y0, _x2, _y2, _1, _0, _0, false);
				else  draw_triangle_color(_cpx - 1, _cpy - 1, _x0, _y0, _x2, _y2, _c, _c, _c, false);
				break;
				
			case 3 : 
				var _x0 = _cpx + lengthdir_x(_cpr, _a0) - 1;
				var _y0 = _cpy + lengthdir_y(_cpr, _a0) - 1;
				var _x1 = _cpx + lengthdir_x(_cpr * sqrt(2), lerp_angle_direct(_a0, _a1, .5)) - 1;
				var _y1 = _cpy + lengthdir_y(_cpr * sqrt(2), lerp_angle_direct(_a0, _a1, .5)) - 1;
				var _x2 = _cpx + lengthdir_x(_cpr, _a1) - 1;
				var _y2 = _cpy + lengthdir_y(_cpr, _a1) - 1;
				
				if(w) {
					draw_triangle_color(_cpx - 1, _cpy - 1, _x0, _y0, _x1, _y1, _1, _0, _0, false);
					draw_triangle_color(_cpx - 1, _cpy - 1, _x1, _y1, _x2, _y2, _1, _0, _0, false);
				} else {
					draw_triangle_color(_cpx - 1, _cpy - 1, _x0, _y0, _x1, _y1, _c, _c, _c, false);
					draw_triangle_color(_cpx - 1, _cpy - 1, _x1, _y1, _x2, _y2, _c, _c, _c, false);
				}
				break;
		}
	}
}