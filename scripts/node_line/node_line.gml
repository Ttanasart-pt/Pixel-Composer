function Node_Line(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {	
	name = "Draw Line";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Bool("Background", self, false));
	
	newInput(2, nodeValue_Int("Segment", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 32, 0.1] });
	
	newInput(3, nodeValue_Vec2("Width", self, [ 2, 2 ]));
	
	newInput(4, nodeValue_Float("Wiggle", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 0.01] });
	
	newInput(5, nodeValue_Float("Random seed", self, 0));
	
	newInput(6, nodeValue_Rotation("Rotation", self, 0));
	
	newInput(7, nodeValue_PathNode("Path", self, noone, "Draw line along path."))
		.setVisible(true, true);
	
	newInput(8, nodeValue_Slider_Range("Range", self, [0, 1]))
		.setTooltip("Range of the path to draw.");
	
	newInput(9, nodeValue_Float("Shift", self, 0));
	
	newInput(10, nodeValue_Gradient("Color over length", self, new gradientObject(cola(c_white))));
	
	newInput(11, nodeValue("Width over length", self, CONNECT_TYPE.input, VALUE_TYPE.curve, CURVE_DEF_11));
	
	newInput(12, nodeValue_Bool("Span width over path", self, false, "Apply the full 'width over length' to the trimmed path."));
		
	newInput(13, nodeValue_Bool("Round cap", self, false));
	
	newInput(14, nodeValue_Int("Round segment", self, 4))
		.setDisplay(VALUE_DISPLAY.slider, { range: [2, 16, 0.1] });
	
	newInput(15, nodeValue_Bool("Span color over path", self, false, "Apply the full 'color over length' to the trimmed path."));
	
	newInput(16, nodeValue_Bool("Width pass", self, false));
	
	newInput(17, nodeValue_Bool("1px mode", self, false, "Render pixel perfect 1px line."));
	
	newInput(18, nodeValue_Surface("Texture", self));
	
	newInput(19, nodeValue_Bool("Fix length", self, false, "Fix length of each segment instead of segment count."));
	
	newInput(20, nodeValue_Float("Segment length", self, 4));
	
	newInput(21, nodeValue_Vec2("Texture position", self, [ 0, 0 ]));
	
	newInput(22, nodeValue_Rotation("Texture Rotation", self, 0));
	
	newInput(23, nodeValue_Vec2("Texture scale", self, [ 1, 1 ]));
	
	newInput(24, nodeValue_Gradient("Random Blend", self, new gradientObject(cola(c_white))));
	
	newInput(25, nodeValue_Bool("Invert", self, false ));
	
	newInput(26, nodeValue_Bool("Clamp range", self, false ));
	
	newInput(27, nodeValue_Enum_Scroll("Data Type", self,  1, [ "None", "Path", "Segments" ]));
	
	newInput(28, nodeValue_Vector("Segments", self, [[]]))
		.setArrayDepth(2);
		
	newInput(29, nodeValue_Bool("Scale texture to length", self, true ));
	
	newInput(30, nodeValue_Bool("Use Path Bounding box", self, false ));
	
	newInput(31, nodeValue_Padding("Padding", self, [ 0, 0, 0, 0 ]))
		
	input_display_list = [
		["Output",			true],	0, 1, 30, 31, 
		["Line data",		false], 27, 6, 7, 28, 19, 2, 20, 
		["Line settings",	false], 17, 3, 11, 12, 8, 25, 9, 26, 13, 14, 
		["Wiggle",			false], 4, 5, 
		["Render",			false], 10, 24, 15, 16, 
		["Texture",			false], 18, 21, 22, 23, 29, 
	];
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Width Pass", self, VALUE_TYPE.surface, noone));
	
	lines     = [];
	line_data = [];
	
	widthMap = ds_map_create();
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		draw_set_color(COLORS._main_accent);
		for( var i = 0, n = array_length(lines); i < n; i++ ) {
			var points = lines[i];
			if(array_length(points) < 2) continue;
				
			for( var j = 1; j < array_length(points); j++ ) {
				var x0 = points[j - 1].x;
				var y0 = points[j - 1].y;
				var x1 = points[j].x;
				var y1 = points[j].y;
				
				x0 = _x + x0 * _s;
				y0 = _y + y0 * _s;
				x1 = _x + x1 * _s;
				y1 = _y + y1 * _s;
				
				draw_line(x0, y0, x1, y1);
				
				// draw_circle(x0, y0, 4, false);
			}
		}
	}
	
	static step = function() {
		var px    = !getInputData(17);
		var _tex  = inputs[18].value_from != noone;
		var _flen = getInputData(19);
		
		inputs[ 3].setVisible(px);
		inputs[11].setVisible(px);
		inputs[12].setVisible(px);
		inputs[13].setVisible(px && !_tex);
		inputs[14].setVisible(px);
		inputs[18].setVisible(px);
		
		inputs[15].setVisible(!_tex);
		inputs[16].setVisible(!_tex);
		
		inputs[ 2].setVisible(!_flen);
		inputs[20].setVisible( _flen);
		
		var _dtype = getInputData(27);
		var _pbbox = getInputData(30);
		
		inputs[ 6].setVisible(_dtype == 0);
		inputs[ 7].setVisible(_dtype == 1, _dtype == 1);
		inputs[28].setVisible(_dtype == 2, _dtype == 2);
		
		inputs[30].setVisible(_dtype);
		inputs[31].setVisible(_dtype && _pbbox);
	}
	
	static onValueUpdate = function(index = 0) {
		if(index == 11) ds_map_clear(widthMap);
	}
	
	static processData = function(_outData, _data, _output_index, _array_index) {
		#region data
			var _dim   = _data[0];
			var _bg    = _data[1];
			var _seg   = _data[2];
			var _wid   = _data[3];
			var _wig   = _data[4];
			var _sed   = _data[5];
			var _ang   = _data[6];
			var _pat   = _data[7]; 
			var _ratio = _data[8];
			var _shift = _data[9];
		
			var _color = _data[10];
			var _widc  = _data[11];
			var _widap = _data[12];
		
			var _cap   = _data[13];
			var _capP  = _data[14];
			var _colP  = _data[15];
			var _colW  = _data[16];
			var _1px   = _data[17];
			var _text  = _data[18];
		
			var _fixL  = _data[19];
			var _segL  = _data[20];
		
			var _tex    = _data[18];
			var _texPos = _data[21];
			var _texRot = _data[22];
			var _texSca = _data[23];
		
			var _colb   = _data[24];
			var _ratInv = _data[25];
			var _clamp  = _data[26];
			
			var _dtype    = _data[27];
			var _segs     = _data[28];
			var _scaleTex = _data[29];
			
			var _pbbox = _data[30];
			var _ppadd = _data[31];
		#endregion
		
		/////// Guard clauses
		
		if(_dtype == 1 && _pat == noone) return _outData;
		if(_dtype == 2 && (array_invalid(_segs) || array_invalid(_segs[0]))) return _outData; 
		
		/////// Data
		
		if(IS_FIRST_FRAME || inputs[11].is_anim)
			ds_map_clear(widthMap);
		
		var _surfDim = [ _dim[0], _dim[1] ];
		var __debug_timer = get_timer();
		
		var _rangeMin = min(_ratio[0], _ratio[1]);
		var _rangeMax = max(_ratio[0], _ratio[1]);
		if(_rangeMax == 1) _rangeMax = 0.99999;
		
		var _rtStr = min(_rangeMin, _rangeMax);
		var _rtMax = max(_rangeMin, _rangeMax);
		
		var _useTex = is_surface(_text);
		if(_useTex) { _cap = false; _1px = false; }
		
		random_set_seed(_sed);
		var _sedIndex = 0;
		
		var p = new __vec2();
		var _pathData = [];
		var minx = 999999, miny = 999999, maxx = -999999, maxy = -999999;
		
		var _ox, _nx, _nx1, _oy, _ny, _ny1;
		var _ow, _nw, _oa, _na, _oc, _nc, _owg, _nwg;
		
		switch(_dtype) {
			case 0 :
				_ang = (_ang % 360 + 360) % 360;
			
				var x0, y0, x1, y1;
				var _0 = point_rectangle_overlap(_dim[0], _dim[1], (_ang + 180) % 360);
				var _1 = point_rectangle_overlap(_dim[0], _dim[1], _ang);
				x0 = _0[0]; y0 = _0[1];
				x1 = _1[0]; y1 = _1[1];
				
				var _l = point_distance(x0, y0, x1, y1);
				var _d = point_direction(x0, y0, x1, y1);
				var _od = _d, _nd = _d;
					
				var ww          = _rtMax / _seg;
				var _total		= _rtMax;
				var _prog_curr	= frac(_shift) - ww;
				var _prog		= _prog_curr + 1;
				var _prog_total	= 0;
				var points = [];
					
				while(_total > 0) {
					if(_prog_curr >= 1) _prog_curr = 0;
					else _prog_curr = min(_prog_curr + min(_total, ww), 1);
					_prog_total += min(_total, ww);
						
					_nx = x0 + lengthdir_x(_l * _prog_curr, _d);
					_ny = y0 + lengthdir_y(_l * _prog_curr, _d);
						
					var wgLen = random1D(_sed + _sedIndex, -_wig, _wig); _sedIndex++;
					_nx += lengthdir_x(wgLen, _d + 90); 
					_ny += lengthdir_y(wgLen, _d + 90);
						
					if(_prog_total > _rtStr) //prevent drawing point before range start.
						array_push(points, { x: _nx, y: _ny, prog: _prog_total / _rtMax, progCrop: _prog_curr, weight: 1 });
						
					if(_prog_curr > _prog)
						_total -= (_prog_curr - _prog);
					_prog = _prog_curr;
					_ox = _nx;
					_oy = _ny;
				}
					
				lines     = [ points ];
				line_data = [ { length: 1 } ];
				break;
				
			case 1 :
				var lineLen = 1;
				if(struct_has(_pat, "getLineCount")) lineLen  = _pat.getLineCount();
				if(struct_has(_pat, "getPathData")) _pathData = _pat.getPathData();
				
				lines = array_verify(lines, lineLen);
				var _lineAmo = 0;
				
				if(_rtMax > 0) 
				for( var i = 0; i < lineLen; i++ ) {
					var _useDistance = _fixL && struct_has(_pat, "getLength");
					var _pathLength  = _useDistance? _pat.getLength(i) : 1;
					if(_pathLength == 0) continue;
						
					var _pathStr = _rtStr;
					var _pathEnd = _rtMax;
						
					var _stepLen = min(_pathEnd, 1 / _seg); 				// Distance to move per step
					if(_stepLen <= 0.00001) continue;
						
					var _total		= _pathEnd;								// Length remaining
					var _total_prev = _total;								// Use to prevent infinite loop
					var _freeze		= 0;									// Use to prevent infinite loop
						
					var _prog_curr	= _clamp? _shift : frac(_shift);		// Pointer to the current position
					var _prog_next  = 0;
					var _prog		= _prog_curr + 1;						// Record previous position to delete from _total
					var _prog_total	= 0;									// Record the distance the pointer has moved so far
					var points		= [];
					var pointAmo    = 0;
					var wght;
					var _pathPng;
					
					if(_useDistance) {						
						_pathStr   *= _pathLength;
						_pathEnd   *= _pathLength;
						_stepLen    = min(_segL, _pathEnd);
							
						_total	   *= _pathLength;
						_total_prev = _total;
							
						_prog_curr *= _pathLength;
					}
					
					var _segLength    = struct_has(_pat, "getAccuLength")? _pat.getAccuLength(i) : [];
					var _segLengthAmo = array_length(_segLength);
					var _segIndex     = 0;
					var _segIndexPrev = 0;
					
					if(_segLengthAmo)
					while(_prog_curr > _segLength[_segIndex]) {
						_segIndex++;
						if(_segIndex == _segLengthAmo) {
							_segIndex = 0;
							break;
						}
					}
					
					// print($"===== {_prog_curr} / {_segLength} : {_segIndex} - {_pathLength} =====");
					
					while(true) {
						wght = 1;
						_segIndexPrev = _segIndex;
						
						if(_useDistance) {
							var segmentLength = array_safe_get_fast(_segLength, _segIndex, _pathLength);
							
							_prog_next = min(_prog_curr + _stepLen, _pathLength, segmentLength);
							_pathPng   = _ratInv? _pathLength - _prog_curr : _prog_curr;
							
							//print($"{segmentLength}/{_pathLength} = {_prog_next}");
							if(_prog_next == segmentLength) _segIndex++;
							
							var _pp = _clamp? clamp(_pathPng, 0, _pathLength) : _pathPng;
							// print($"_pp = {_pp}, total = {_total}");
							
							p = _pat.getPointDistance(_pp, i, p);
							if(struct_has(_pat, "getWeightDistance"))
								wght = _pat.getWeightDistance(_pp, i);
								
						} else {
							_prog_next = min(_prog_curr + _stepLen, 1); //Move forward _stepLen or _total (if less) stop at 1
							_pathPng   = _ratInv? 1 - _prog_curr : _prog_curr;
							
							var _pp = _clamp? clamp(_pathPng, 0, 1) : _pathPng
							
							p = _pat.getPointRatio(_pp, i, p);
							if(struct_has(_pat, "getWeightRatio"))
								wght = _pat.getWeightRatio(_pp, i);
						}
						
						_nx = p.x;
						_ny = p.y;
						// print($"{_nx}, {_ny}");
							
						if(_total < _pathEnd) { //Do not wiggle the last point.
							var _d = point_direction(_ox, _oy, _nx, _ny);
							_nx   += lengthdir_x(random1D(_sed + _sedIndex, -_wig, _wig), _d + 90); _sedIndex++;
							_ny   += lengthdir_y(random1D(_sed + _sedIndex, -_wig, _wig), _d + 90); _sedIndex++;
						}
							
						if(_prog_total >= _pathStr) { //Do not add point before range start. Do this instead of starting at _rtStr to prevent wiggle. 
							points[pointAmo++] = { 
								x:        _nx, 
								y:        _ny, 
								prog:     (_prog_total - _pathStr) / (_pathEnd - _pathStr), 
								progCrop: _prog_curr / _pathLength, 
								weight:   wght 
							}
							
							minx = min(minx, _nx);
							miny = min(miny, _ny);
							maxx = max(maxx, _nx);
							maxy = max(maxy, _ny);
						}
						
						if(_total <= 0) break;
						
						if(_prog_next == _prog_curr && _segIndexPrev == _segIndex) { /*print("Terminate line not moving");*/ break; }
						else if(_prog_next > _prog_curr) {
							_prog_total += _prog_next - _prog_curr;
							_total      -= _prog_next - _prog_curr;
						}
						_stepLen = min(_stepLen, _total);
							
						_prog_curr = _prog_next;
						_ox		   = _nx;
						_oy		   = _ny;
							
						if(_total_prev == _total && _segIndexPrev == _segIndex && ++_freeze > 16) { /*print("Terminate line not moving");*/ break; }
						_total_prev = _total;
						
						if(_segIndex >= _segLengthAmo) { /*print("Terminate line finish last segment");*/ break; }
					}
					
					array_resize(points, pointAmo);
					
					lines[_lineAmo]     = points;
					line_data[_lineAmo] = { length: _pathLength };
					
					_lineAmo++;
				}
				
				array_resize(lines,     _lineAmo);
				array_resize(line_data, _lineAmo);
				
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
						for (var j = 0; j < m; j++) {
							_lin[j] = { x: _seg[j][0], y: _seg[j][1], prog: _seg[j][2], progCrop: _seg[j][2], weight: 1 };
							
							minx = min(minx, _lin[j].x);
							miny = min(miny, _lin[j].y);
							maxx = max(maxx, _lin[j].x);
							maxy = max(maxy, _lin[j].y);
						}
							
					} else {
						for (var j = 0; j < m; j++) {
							_lin[j] = { x: _seg[j][0], y: _seg[j][1], prog: _len[j] / _lenTotal, progCrop: _len[j] / _lenTotal, weight: 1 };
							
							minx = min(minx, _lin[j].x);
							miny = min(miny, _lin[j].y);
							maxx = max(maxx, _lin[j].x);
							maxy = max(maxy, _lin[j].y);
						}
					}
					
					lines[i]     = _lin;
					line_data[i] = { length: _lenTotal };
				}
				
				if(_pbbox) _surfDim = [ max(1, maxx - minx + _ppadd[0] + _ppadd[2]), max(1, maxy - miny + _ppadd[1] + _ppadd[3]) ];
				break;
		}
		
		/////// Draw
		
		var _colorPass = surface_verify(_outData[0], _surfDim[0], _surfDim[1], attrDepth());
		var _widthPass = surface_verify(_outData[1], _surfDim[0], _surfDim[1], attrDepth());
		var _padx = _pbbox * (_ppadd[2] - minx);
		var _pady = _pbbox * (_ppadd[1] - miny);
		
		surface_set_target(_colorPass);
			if(_bg) draw_clear_alpha(0, 1);
			else	DRAW_CLEAR
			
			if(_useTex) {
				var tex = surface_get_texture(_tex);
				
				shader_set(sh_draw_mapping);
				shader_set_2("position", _texPos);
				shader_set_f("rotation", degtorad(_texRot));
				shader_set_2("scale",    _texSca);
				
				shader_set_interpolation(_tex);
			}
			
			for( var i = 0, n = array_length(lines); i < n; i++ ) {
				var points = lines[i];
				if(array_length(points) < 2) continue;
				
				var _ldata = line_data[i];
				var _len   = _ldata.length;
				var _caps  = [];
				
				if(_useTex && _scaleTex) shader_set_2("scale",    [ _texSca[0] * _len, _texSca[1] ]);
				
				if(_useTex) draw_primitive_begin_texture(pr_trianglestrip, tex);
				else        draw_primitive_begin(pr_trianglestrip);
				
				random_set_seed(_sed + i);
				var pxs = [];
				var dat = array_safe_get_fast(_pathData, i, noone);
				
				var _col_base = dat == noone? _colb.eval(random(1)) : dat.color;
				
				for( var j = 0; j < array_length(points); j++ ) {
					var p0   = points[j];
					var _nx  = p0.x - 0.5 * _1px + _padx;
					var _ny  = p0.y - 0.5 * _1px + _pady;
					
					var prog = p0.prog;
					var prgc = p0.progCrop;
					var _dir = j? point_direction(_ox, _oy, _nx, _ny) : 0;
					
					var widProg = value_snap_real(_widap? prog : prgc, 0.01);
					
					_nw  = random_range(_wid[0], _wid[1]);
					if(!ds_map_exists(widthMap, widProg))
						widthMap[? widProg] = eval_curve_x(_widc, widProg, 0.1);
					_nw *= widthMap[? widProg];
					_nw *= p0.weight;
					
					_nc = colorMultiply(_col_base, _color.eval(_colP? prog : prgc));
					
					if(_cap) { 
						if(j == 1) {
							_d = _dir + 180;
							_caps[0] = [ _oc, _ox, _oy, _ow / 2, _d - 90, _d ];
							_caps[1] = [ _oc, _ox, _oy, _ow / 2, _d, _d + 90 ];
						}
						
						if(j == array_length(points) - 1) {
							_d = _dir;
							_caps[2] = [ _nc, _nx, _ny, _nw / 2, _d - 90, _d ];
							_caps[3] = [ _nc, _nx, _ny, _nw / 2, _d, _d + 90 ];
						}
					} 
					
					if(_1px) { 
						if(j) {
							var dst = point_distance(_ox, _oy, _nx, _ny);
							if(dst <= 1 && i < array_length(points) - 1) continue;
							draw_line_color(_ox, _oy, _nx, _ny, _oc, _nc);
						}
						
						_ox = _nx;
						_oy = _ny;
						_oc = _nc;
					
					} else { 
						if(j) {
							var _nd0 = _dir;
							var _nd1 = _nd0;
							
							if(j < array_length(points) - 1) {
								var p2 = points[j + 1];
								var _nnx = p2.x + _padx;
								var _nny = p2.y + _pady;
								
								_nd1 = point_direction(_nx, _ny, _nnx, _nny);
								_nd = _nd0 + angle_difference(_nd1, _nd0) / 2;
							} else 
								_nd = _nd0;
							
							if(_useTex) {
								var _len = array_length(points) - 1;
								
								var ox0 = _ox + lengthdir_x(_ow / 2, _od + 90);
								var oy0 = _oy + lengthdir_y(_ow / 2, _od + 90);
								var nx0 = _nx + lengthdir_x(_nw / 2, _nd + 90);
								var ny0 = _ny + lengthdir_y(_nw / 2, _nd + 90);
	
								var ox1 = _ox + lengthdir_x(_ow / 2, _od + 90 + 180);
								var oy1 = _oy + lengthdir_y(_ow / 2, _od + 90 + 180);
								var nx1 = _nx + lengthdir_x(_nw / 2, _nd + 90 + 180);
								var ny1 = _ny + lengthdir_y(_nw / 2, _nd + 90 + 180);
								
								draw_vertex_texture_color(ox0, oy0, 0, (j - 1) / _len, _oc, 1);
								draw_vertex_texture_color(ox1, oy1, 1, (j - 1) / _len, _oc, 1);
								draw_vertex_texture_color(nx0, ny0, 0, (j - 0) / _len, _nc, 1);
								draw_vertex_texture_color(nx1, ny1, 1, (j - 0) / _len, _nc, 1);
								
							} else
								draw_line_width2_angle(_ox, _oy, _nx, _ny, _ow, _nw, _od + 90, _nd + 90, _oc, _nc);
						} else {
							var p1   = points[j + 1];
							_nd = point_direction(_nx, _ny, p1.x + _padx, p1.y + _pady);
						}
					
						_ox = _nx;
						_oy = _ny;
						_od = _nd;
						_ow = _nw;
						_oc = _nc;
					}
				
					
					if(j % 120 == 0) {
						draw_primitive_end();
						
						if(_useTex) draw_primitive_begin_texture(pr_trianglestrip, tex);
						else        draw_primitive_begin(pr_trianglestrip);
					}
				}
				
				draw_primitive_end();
				
				for( var j = 0, m = array_length(_caps); j < m; j++ ) {
					var _cps = _caps[j];
					draw_set_color(_cps[0]);
					draw_circle_angle(_cps[1], _cps[2], _cps[3], _cps[4], _cps[5], _capP);
				}
			}
			
			if(_useTex) shader_reset();
		surface_reset_target();
		
		if(_colW && !_1px) {
			
			surface_set_target(_widthPass);
				if(_bg) draw_clear_alpha(0, 1);
				else	DRAW_CLEAR
				
				for( var i = 0, n = array_length(lines); i < n; i++ ) {
					var points = lines[i];
					if(array_length(points) < 2) continue;
					
					var _caps = [];
					
					draw_primitive_begin(pr_trianglestrip);
					
					random_set_seed(_sed + i);
					var pxs = [];
					var dat = array_safe_get_fast(_pathData, i, noone);
					
					var _col_base = dat == noone? _colb.eval(random(1)) : dat.color;
					
					for( var j = 0; j < array_length(points); j++ ) {
						var p0   = points[j];
						var _nx  = p0.x - 0.5 * _1px + _padx;
						var _ny  = p0.y - 0.5 * _1px + _pady;
						
						var prog = p0.prog;
						var prgc = p0.progCrop;
						var _dir = j? point_direction(_ox, _oy, _nx, _ny) : 0;
						
						var widProg = value_snap_real(_widap? prog : prgc, 0.01);
						
						_nw  = random_range(_wid[0], _wid[1]);
						if(!ds_map_exists(widthMap, widProg))
							widthMap[? widProg] = eval_curve_x(_widc, widProg, 0.1);
						_nw *= widthMap[? widProg];
						_nw *= p0.weight;
						
						if(_cap) {
							if(j == 1) {
								_d = _dir + 180;
								_caps[0] = [ c_grey, _ox, _oy, _ow / 2, _d - 90, _d ];
								_caps[1] = [ c_grey, _ox, _oy, _ow / 2, _d, _d + 90 ];
							}
							
							if(j == array_length(points) - 1) {
								_d = _dir;
								_caps[2] = [ c_grey, _nx, _ny, _nw / 2, _d - 90, _d ];
								_caps[3] = [ c_grey, _nx, _ny, _nw / 2, _d, _d + 90 ];
							}
						}
						
						if(j) {
							var _nd0 = _dir;
							var _nd1 = _nd0;
							
							if(j < array_length(points) - 1) {
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
					
					for( var j = 0, m = array_length(_caps); j < m; j++ ) {
						var _cps = _caps[j];
						draw_set_color(_cps[0]);
						draw_circle_angle(_cps[1], _cps[2], _cps[3], _cps[4], _cps[5], _capP);
					}
				}
				
			surface_reset_target();
			
		}
		
		return [ _colorPass, _widthPass ];
	}
}