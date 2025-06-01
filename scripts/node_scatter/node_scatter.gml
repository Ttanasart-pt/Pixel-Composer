#region
	enum NODE_SCATTER_DIST {
		area,
		border,
		map,
		data,
		path,
		tile
	}
	
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Scatter", "Distribution > Toggle", "D", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[ 6].setValue((_n.inputs[ 6].getValue() + 1) % 6); });
		addHotkey("Node_Scatter", "Scatter > Toggle",      "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[ 9].setValue((_n.inputs[ 9].getValue() + 1) % 2); });
		addHotkey("Node_Scatter", "Blend Mode > Toggle",   "B", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[18].setValue((_n.inputs[18].getValue() + 1) % 3); });
	});
	
#endregion

function Node_Scatter(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Scatter";
	dimension_index = 1;
	
	newInput(10, nodeValueSeed());
	
	////- =Surfaces
	
	newInput( 0, nodeValue_Surface(     "Surface In" ));
	newInput( 1, nodeValue_Dimension());
	newInput(15, nodeValue_Int(         "Array", 0, @"What to do when input array of surface.
- Spread: Create Array of output each scattering single surface.
- Mixed: Create single output scattering multiple images."))
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Spread output", "Index", "Random", "Data", "Texture" ]);
		
	newInput(24, nodeValue_Int(         "Array Indices", [] )).setArrayDepth(1);
	newInput(25, nodeValue_Surface(     "Array Texture" ));
	newInput(26, nodeValue_Range(       "Animated Array",    [0,0], { linked : true } ));
	newInput(27, nodeValue_Enum_Scroll( "Animated Array End", 0, [ "Loop", "Ping Pong", "Hide" ] ));
	
	////- =Scatter
	
	onSurfaceSize = function() /*=>*/ {return getInputData(1, DEF_SURF)}; 
	
	newInput( 6, nodeValue_Enum_Scroll(    "Distribution",  5, [ "Area", "Border", "Map", "Direct Data", "Path", "Full image + Tile" ]));
	newInput( 5, nodeValue_Area(           "Area", DEF_AREA_REF, { onSurfaceSize })).setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput(13, nodeValue_Surface(        "Distribution Map"));
	newInput(14, nodeValue_Vector(         "Distribution Data", [])).setArrayDepth(1);
	newInput(17, nodeValue_Text(           "Extra Value", [], "Apply the third and later values in each data point (if exist) on given properties."))
		.setDisplay(VALUE_DISPLAY.text_array, { data: [ "Scale", "Rotation", "Color", "Alpha", "Array Index" ] });
	newInput( 9, nodeValue_Enum_Button(    "Scatter",  1, [ "Uniform", "Random", "Poisson" ]));
	newInput(31, nodeValue_Bool(           "Auto Amount", false));
	newInput( 2, nodeValue_Int(            "Amount", 8)).setValidator(VV_min(0));
	newInput(30, nodeValue_Vec2(           "Uniform Amount", [ 4, 4 ]));
	newInput(35, nodeValue_Rotation_Range( "Angle Range", [ 0, 360 ]));
	newInput(44, nodeValue_Float(          "Distance", 8)).setValidator(VV_min(0));
	
	////- =Path
	
	newInput(19, nodeValue_PathNode(    "Path"));
	newInput(38, nodeValue_Enum_Button( "Spacing", 0, [ "After", "Between", "Around" ]));
	newInput(20, nodeValue_Bool(        "Rotate Along Path", true));
	newInput(21, nodeValue_Slider(      "Path Shift", 0));
	newInput(22, nodeValue_Float(       "Scatter Distance", 0));
	
	////- =Position
	
	newInput(40, nodeValue_Anchor());
	newInput(33, nodeValue_Vec2_Range( "Random Position", [ 0, 0, 0, 0 ]));
	newInput(36, nodeValue_Vec2(       "Shift Position", [ 0, 0 ]));
	newInput(37, nodeValue_Bool(       "Exact",  false))
	newInput(39, nodeValue_Range(      "Shift Radial", [ 0, 0 ]));
	
	////- =Rotation
	
	newInput( 7, nodeValue_Bool(            "Point at Center", false, "Rotate each copy to face the spawn center."));
	newInput( 4, nodeValue_Rotation_Random( "Angle", [ 0, 0, 0, 0, 0 ] ));
	newInput(32, nodeValue_Rotation(        "Rotate per Radius", 0));
	
	////- =Scale
	
	newInput( 3, nodeValue_Vec2_Range( "Scale", [ 1, 1, 1, 1 ] , { linked : true }));
	newInput( 8, nodeValue_Bool(       "Uniform Scaling", true));
	newInput(34, nodeValue_Vec2(       "Scale per Radius", [ 0, 0 ]));
	newInput(43, nodeValue_Surface(    "Scale Surface"));
	
	////- =Color
	
	newInput(11, nodeValue_Gradient(     "Random Blend", new gradientObject(ca_white))).setMappable(28);
	newInput(12, nodeValue_Slider_Range( "Alpha", [ 1, 1 ]));
	newInput(16, nodeValue_Bool(         "Multiply Alpha", true));
	newInput(41, nodeValue_Surface(      "Sample Surface"));
	newInput(42, nodeValue_Vec2_Range(   "Sample Wiggle", [ 0, 0, 0, 0 ]));
	
	////- =Render
	
	newInput(18, nodeValue_Enum_Scroll( "Blend Mode",  0, [ "Normal", "Add", "Max" ]));
	newInput(23, nodeValue_Bool(        "Sort Y", false));
	
	// inputs: 45
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
		
	newOutput(1, nodeValue_Output("Atlas Data", VALUE_TYPE.atlas, []))
		.setVisible(false)
		.rejectArrayProcess();
	
	input_display_list = [ 10, 
		["Surfaces",  true],  0,  1, 15, 24, 25, 26, 27, 
		["Scatter",  false],  6,  5, 13, 14, 17,  9, 31,  2, 30, 35, 44, 
		["Path",     false], 19, 38, 20, 21, 22, 
		["Position", false], 40, 33, 36, 37, 39, 
		["Rotation", false],  7,  4, 32, 
		["Scale",    false],  3,  8, 34, 43, 
		["Color",    false], 11, 28, 12, 16, 41, 42, 
		["Render",   false], 18, 23, 
	];
	
	transform_prop = [ 10, 40, 33, 36, 37, 39 ];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	surface_size_map  = {};
	surface_valid_map = {};
	
	scatter_data = [];
	scatter_map  = noone;
	scatter_mapa = 0;
	scatter_maps = 0;
	scatter_mapp = [];
	
	surfSamp = new Surface_sampler();
	scalSamp = new Surface_sampler();
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var _distType = current_data[6];
		
		if(_distType <  3) InputDrawOverlay(inputs[ 5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		if(_distType == 4) InputDrawOverlay(inputs[19].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		InputDrawOverlay(inputs[29].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, current_data[1]));
		
		return w_hovering;
	}
	
	static getTool = function() { 
		var _path = getInputData(19);
		return is_instanceof(_path, Node)? _path : self; 
	}
	
	static onValueUpdate = function(index) {
		if(index == 15) {
			var _arr = getInputData(15);
			inputs[0].array_depth = _arr;
			
			update();
		}
	}
	
	////- PROCESS
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var seed       = _data[10];
			
			var _inSurf    = _data[ 0];
			var _dim       = _data[ 1];
			var _arr       = _data[15];
			var arrId      = _data[24];
			var arrTex     = _data[25], useArrTex = is_surface(arrTex);
			var arrAnim    = _data[26];
			var arrAnimEnd = _data[27];
			
			var _dist      = _data[ 6];
			var _area      = _data[ 5];
			var _distMap   = _data[13];
			var _distData  = _data[14];
			var useV       = _data[17];
			var _scat      = _data[ 9];
			var uniAut     = _data[31];
			var _amount    = _data[ 2];
			var uniAmo     = _data[30];
			var cirRng     = _data[35];
			var poisDist   = _data[44];
			
			var path       = _data[19];
			var pthSpac    = _data[38];
			var pathRot    = _data[20];
			var pathShf    = _data[21];
			var pathDis    = _data[22];
			
			var anchor     = _data[40];
			var posWig     = _data[33];
			var posShf     = _data[36];
			var posExt     = _data[37];
			var shfRad     = _data[39];
			
			var _pint      = _data[ 7];
			var _rota      = _data[ 4];
			var uniRot     = _data[32];
			
			var _scale     = _data[ 3];
			var _unis      = _data[ 8];
			var uniSca     = _data[34];
			var scalSam    = _data[43]; scalSamp.setSurface(scalSam);
			
			var color      = _data[11];
			var clr_map    = _data[28];
			var clr_rng    = _data[29];
			var alpha      = _data[12];
			var mulpA      = _data[16];
			var sampSrf    = _data[41]; surfSamp.setSurface(sampSrf);
			var sampWig    = _data[42];
			
			var blend      = _data[18];
			var sortY      = _data[23];
		#endregion
		
		#region visible
			update_on_frame = _arr && (arrAnim[0] != 0 || arrAnim[1] != 0);
			
			inputs[0].array_depth = bool(_arr);
			
			inputs[13].setVisible(_dist == 2,   _dist == 2);
			inputs[14].setVisible(_dist == 3,   _dist == 3);
			inputs[17].setVisible(_dist == 3);
			inputs[ 9].setVisible(_dist != 2 && _dist != 3);
			inputs[19].setVisible(_dist == 4,   _dist == 4);
			inputs[20].setVisible(_dist == 4);
			inputs[21].setVisible(_dist == 4 && pthSpac == 0);
			inputs[22].setVisible(_dist == 4);
			inputs[38].setVisible(_dist == 4 && _scat == 0);
			inputs[24].setVisible(_arr == 3,    _arr  == 3);
			inputs[25].setVisible(_arr == 4,    _arr  == 4);
			inputs[26].setVisible(_arr);
			inputs[27].setVisible(_arr);
			
			inputs[ 5].setVisible(_dist <  3);
			inputs[ 2].setVisible(_dist != 3 && _scat != 2);
			inputs[30].setVisible(false);
			inputs[31].setVisible(false);
			inputs[32].setVisible(false);
			inputs[34].setVisible(false);
			inputs[35].setVisible(false);
			
			inputs[44].setVisible(_scat == 2);
			
			if(_dist == 0 && _scat == 0) {
				if(_area[AREA_INDEX.shape] == AREA_SHAPE.elipse) {
					inputs[ 2].setVisible( uniAut);
					inputs[30].setVisible(!uniAut);
					inputs[31].setVisible( true);
					inputs[32].setVisible(!uniAut);
					inputs[34].setVisible(!uniAut);
					inputs[35].setVisible(!uniAut);
					
				} else {
					inputs[ 2].setVisible(false);
					inputs[30].setVisible( true);
				}
				
			} else if(_dist == 5) {
				inputs[ 2].setVisible(_scat == 1);
				inputs[30].setVisible(_scat == 0);
			}
		#endregion
		
		var iSca = 2 + array_get_index(useV, "Scale");
		var iRot = 2 + array_get_index(useV, "Rotation");
		var iCol = 2 + array_get_index(useV, "Color");
		var iAlp = 2 + array_get_index(useV, "Alpha");
		var iArr = 2 + array_get_index(useV, "Array Index");
		
		var _dyna     = false;
		var surfArray = is_array(_inSurf);
		if(surfArray && array_empty(_inSurf)) return _outData;
		
		#region cache value
			surface_size_map  = {};
			surface_valid_map = {};
			
			if(surfArray) {
				for( var i = 0, n = array_length(_inSurf); i < n; i++ ) {
					_dyna = _dyna || is(_inSurf[i], dynaSurf);
					surface_valid_map[$ _inSurf[i]] = is_surface(_inSurf[i]);
					surface_size_map[$ _inSurf[i]]  = surface_get_dimension(_inSurf[i]);
				}
				
			} else {
				_dyna = is(_inSurf, dynaSurf);
				surface_valid_map[$ _inSurf] = is_surface(_inSurf);
				surface_size_map[$ _inSurf]  = surface_get_dimension(_inSurf);
			}
			
			color.cache();
		#endregion
		
		#region data
			var _posDist = [];
			if(_dist == NODE_SCATTER_DIST.map) {
				if(!is_surface(_distMap))
					return _outData;
				
				scatter_mapp = get_points_from_dist(_distMap, _amount, seed);
				scatter_map  = _distMap;
				scatter_maps = seed;
				scatter_mapa = _amount;
				
				_posDist = scatter_mapp;
			}
			
			if(_dist == NODE_SCATTER_DIST.area) { // Area
				if(_scat == 0 && (!uniAut || _area[AREA_INDEX.shape] == AREA_SHAPE.rectangle)) 
					_amount = uniAmo[0] * uniAmo[1];
				
				if(_scat == 2) {
					var _points = area_get_random_point_poisson_c(_area, poisDist, seed);
					_amount = array_length(_points);
				}
				
			} else if(_dist == NODE_SCATTER_DIST.data) { // Data
				_amount = array_length(_distData);
			
			} else if(_dist == NODE_SCATTER_DIST.path) { // Path
				var path_valid    = path != noone && struct_has(path, "getPointRatio");
			
				if(!path_valid) return _outData;
			
				var _pathProgress = 0;
				var path_amount   = struct_has(path, "getLineCount")? path.getLineCount() : 1;
				var _pre_amount   = _amount;
				_amount *= path_amount;
			
				var path_line_index = 0;
				
			} else if(_dist == NODE_SCATTER_DIST.tile) {
				if(_scat == 0) _amount = uniAmo[0] * uniAmo[1];
				
				if(_scat == 2) {
					var _area   = [ _dim[0] / 2, _dim[1] / 2, _dim[0] / 2, _dim[1] / 2, 0 ];
					var _points = area_get_random_point_poisson_c(_area, poisDist, seed);
					_amount = array_length(_points);
				}
				
			}
		
			var _sed     = seed;
			var _sct     = array_verify(_outData[1], _amount);
			var _sct_len = 0;
			var _arrLen  = array_safe_length(_inSurf);
		
			random_set_seed(_sed);
			
			var _wigX = posWig[0] != 0 || posWig[1] != 0;
			var _wigY = posWig[2] != 0 || posWig[3] != 0;
			
			var _scaUniX = _scale[0] == _scale[1];
			var _scaUniY = _scale[2] == _scale[3];
			
			var _alpUni = alpha[0] == alpha[1];
			
			var _clrUni = !inputs[11].attributes.mapped && color.keyLength == 1;
			var _clrSin = color.evalFast(0);
			
			var _useAtl = outputs[1].visible;
			var _datLen = array_length(scatter_data);
			
			var _p = [ 0, 0 ];
		#endregion
		
		var _outSurf = _outData[0];
		
		surface_set_target(_outSurf);
			gpu_set_tex_filter(getAttribute("interpolate") > 1);
			DRAW_CLEAR
			
			switch(blend) {
				case 0 :
					if(mulpA) BLEND_ALPHA_MULP
					else      BLEND_ALPHA
					break;
					
				case 1 : 
					BLEND_ADD 
					break;
					
				case 2 : 
					BLEND_ALPHA_MULP
					gpu_set_blendequation(bm_eq_max);
					break;
			}
			
			var positions = array_create(_amount);
			var posIndex  = 0;
			
			var  i  = -1;
			var _ww = _dim[0];
			var _hh = _dim[1];
			var uniAmoX = uniAmo[0];
			var uniAmoY = uniAmo[1];
			
			var _w2 = _ww / 2;
			var _h2 = _hh / 2;
			var _wa = _ww / uniAmoX;
			var _ha = _hh / uniAmoY;
			
			var sp, _x, _y, _v;
			
			repeat(_amount) {
				i++;
				
				var _atl = _sct_len >= _datLen? 0 : scatter_data[_sct_len];
				sp = noone;
				_v = noone;
				_x = 0;
				_y = 0;
				
				if(_atl != 0) {
					_x = _atl.x;
					_y = _atl.y;
				}
				
				var _csed = _sed + i * 100 * pi;
				random_set_seed(_csed);
				
				var _scx = _scaUniX? _scale[0] : random_range_seed(_scale[0], _scale[1], _csed++);
				var _scy = _scaUniY? _scale[2] : random_range_seed(_scale[2], _scale[3], _csed++);
				
				switch(_dist) { // position
					case NODE_SCATTER_DIST.area : 
						if(_scat == 2) {
							var _p = _points[i];
							_x = _p[0];
							_y = _p[1];
							break;
						}
						
						if(_scat == 0) {
							var _axc = _area[AREA_INDEX.center_x];
							var _ayc = _area[AREA_INDEX.center_y];
							var _aw  = _area[AREA_INDEX.half_w], _aw2 = _aw * 2;
							var _ah  = _area[AREA_INDEX.half_h], _ah2 = _ah * 2;
							var _ax0 = _axc - _aw, _ax1 = _axc + _aw;
							var _ay0 = _ayc - _ah, _ay1 = _ayc + _ah;
							
							var _acol = i % uniAmoX;
							var _arow = floor(i / uniAmoX);
								
							if(_area[AREA_INDEX.shape] == AREA_SHAPE.rectangle) {
								_x = uniAmoX == 1? _axc : _ax0 + (_acol + 0.5) * _aw2 / uniAmoX;
								_y = uniAmoY == 1? _ayc : _ay0 + (_arow + 0.5) * _ah2 / uniAmoY;
								
							} else if(_area[AREA_INDEX.shape] == AREA_SHAPE.elipse) {
								if(uniAut) {
									sp = area_get_random_point(_area, _dist, _scat, i, _amount);
									_x = sp[0];
									_y = sp[1];
								} else {
									var _ang = cirRng[0] + _acol * (cirRng[1] - cirRng[0]) / uniAmoX;
									var _rad = uniAmoY == 1? 0.5 : _arow / (uniAmoY - 1);
									_ang += _arow * uniRot;
									
									_x += _axc + lengthdir_x(_rad * _aw, _ang);
									_y += _ayc + lengthdir_y(_rad * _ah, _ang);
									
									_scx += _arow * uniSca[0];
									_scy += _arow * uniSca[1];
								}
							}
						} else {
							sp = area_get_random_point(_area, _dist, _scat, i, _amount, _csed);
							_x = sp[0];
							_y = sp[1];
						}
						break;
						
					case NODE_SCATTER_DIST.border : 
						sp = area_get_random_point(_area, _dist, _scat, i, _amount);
						_x = sp[0];
						_y = sp[1];
						break;
						
					case NODE_SCATTER_DIST.map : 
						sp = array_safe_get_fast(_posDist, i);
						if(!is_array(sp)) continue;
						
						_x = _area[0] + _area[2] * (sp[0] * 2 - 1.);
						_y = _area[1] + _area[3] * (sp[1] * 2 - 1.);
						break;
						
					case NODE_SCATTER_DIST.data : 
						sp = array_safe_get_fast(_distData, i);
						if(!is_array(sp)) continue;
						_v = sp;
						
						_x = array_safe_get_fast(sp, 0);
						_y = array_safe_get_fast(sp, 1);
						break;
						
					case NODE_SCATTER_DIST.path : 
						if(_scat == 0) {
							switch(pthSpac) {
								case 0 :
									_pathProgress = i / max(1, _pre_amount);
									_pathProgress = frac(_pathProgress + pathShf);
									break;
									
								case 1 :
									_pathProgress = i / max(1, _pre_amount - 1);
									break;
									
								case 2 :
									_pathProgress = (i + 0.5) / max(1, _pre_amount);
									break;
									
							}
							
						} else {
							_pathProgress = random_seed(1, _sed++);
							_pathProgress = frac(_pathProgress + pathShf);
						}
						
						var pp = path.getPointRatio(_pathProgress, path_line_index);
						_x = pp.x + random_range_seed(-pathDis, pathDis, _csed++);
						_y = pp.y + random_range_seed(-pathDis, pathDis, _csed++);
						break;
						
					case NODE_SCATTER_DIST.tile : 
						if(_scat == 0) {
							var _acol =       i % uniAmoX;
							var _arow = floor(i / uniAmoX);
								
							_x = uniAmoX == 1? _w2 : (_acol + 0.5) * _wa;
							_y = uniAmoY == 1? _h2 : (_arow + 0.5) * _ha;
								
						} else if(_scat == 1) {
							_x = random_range_seed(0, _ww, _csed++);
							_y = random_range_seed(0, _hh, _csed++);
							
						} else if(_scat == 2) {
							var _p = _points[i];
							_x = _p[0];
							_y = _p[1];
						}
						break;
				}
				
				if(_wigX) _x += random_range_seed(posWig[0], posWig[1], _csed++);
				if(_wigY) _y += random_range_seed(posWig[2], posWig[3], _csed++);
			
				_x += posShf[0] * i;
				_y += posShf[1] * i;
			
				var shrRad = random_range_seed(shfRad[0], shfRad[1], _csed++);
				var shrAng = point_direction(_x, _y, _area[0], _area[1]);
				
				_x -= lengthdir_x(shrRad, shrAng);
				_y -= lengthdir_y(shrRad, shrAng);
				
				if(_unis) {
					_scy = max(_scx, _scy);
					_scx = _scy;
				}
				
				if(iSca > 1 && _v != noone) {
					var vSca = array_safe_get_fast(_v, iSca, 1);
					_scx *= vSca;
					_scy *= vSca;
				}
				
				var _r = (_pint? point_direction(_area[0], _area[1], _x, _y) : 0) + rotation_random_eval_fast(_rota, _csed++);
				
				if(iRot > 1 && _v != noone)
					_r += array_safe_get_fast(_v, iRot, 0);
					
				if(_dist == NODE_SCATTER_DIST.path && pathRot) {
					var pr1 = clamp(_pathProgress + 0.01, 0, 1);
					var pr0 = pr1 - 0.02;
					
					var p0 = path.getPointRatio(pr0, path_line_index);
					var p1 = path.getPointRatio(pr1, path_line_index);
					
					var dirr = point_direction(p0.x, p0.y, p1.x, p1.y);
					_r += dirr;
				}
				
				var surf = _inSurf;
				var ind  = 0;
				
				if(surfArray) {
					switch(_arr) { 
						case 1 : ind  = safe_mod(i, _arrLen);             break;
						case 2 : ind  = irandom(_arrLen - 1);             break;
						case 3 : ind  = array_safe_get_fast(arrId, i, 0); break;
						case 4 : if(useArrTex) ind = colorBrightness(surface_get_pixel(arrTex, _x, _y)) * (_arrLen - 1); break;
					}
					
					if(arrAnim[0] != 0 || arrAnim[1] != 0) {
						var _arrAnim_spd = random_range(arrAnim[0], arrAnim[1]);
						var _animInd     = ind + CURRENT_FRAME * _arrAnim_spd;
						
						switch(arrAnimEnd) {
							case 0 : ind = safe_mod(_animInd, _arrLen); break;
								
							case 1 :
								var pp = safe_mod(_animInd, _arrLen * 2 - 1);
								ind = pp < _arrLen? pp : _arrLen * 2 - pp;
								break;
								
							case 2 : ind = _animInd; break;
						}
					}
					
					if(iArr > 1 && _v != noone) 
						ind = safe_mod(array_safe_get_fast(_v, iArr, ind), _arrLen);
						
					surf = array_safe_get_fast(_inSurf, ind, 0); 
				}
				
				if(surf == 0 || !surface_valid_map[$ surf]) continue;
				
				var dim = surface_size_map[$ surf];
				var sw  = dim[0];
				var sh  = dim[1];
				
				if(scalSamp.active) {
					var _samC = scalSamp.getPixel(_x, _y);
					var _samB = colorBrightness(_samC);
					_scx *= _samB;
					_scy *= _samB;
				}
				
				var _shf_x = sw * _scx * anchor[0];
				var _shf_y = sh * _scy * anchor[1];
				
				if(_r == 0) {
					_x -= _shf_x;
					_y -= _shf_y;
					
				} else {
					_p = point_rotate(_x - _shf_x, _y - _shf_y, _x, _y, _r, _p);
					_x = _p[0];
					_y = _p[1];
				}
				
				var grSamp = random_seed(1, _sed++);
				
				var clr = _clrUni? _clrSin  : evaluate_gradient_map(grSamp, color, clr_map, clr_rng, inputs[11], true);
				var alp  = _alpUni? alpha[0] : random_range_seed(alpha[0], alpha[1], _csed++);
				
				if(iCol > 1 && _v != noone) 
					clr = colorMultiply(clr, array_safe_get_fast(_v, iCol, cola(c_white, 1)));
				
				if(surfSamp.active) {
					var _samC = surfSamp.getPixel(_x + random_range_seed(sampWig[0], sampWig[1], _csed++), 
					                              _y + random_range_seed(sampWig[2], sampWig[3], _csed++));
					clr =  colorMultiply(clr, _samC);
					alp *= color_get_alpha(_samC);
				}
				
				if(iAlp > 1 && _v != noone) 
					alp += array_safe_get_fast(_v, iAlp, 0);
					
				if(posExt) { 
					_x = round(_x); 
					_y = round(_y); 
				}
				
				if(!is(_atl, SurfaceAtlasFast))  _atl = new SurfaceAtlasFast(surf, _x, _y, _r, _scx, _scy, clr, alp);
				else						     _atl.set(surf, _x, _y, _r, _scx, _scy, clr, alp);
				
				_atl.w = sw;
				_atl.h = sh;
				
				_sct[_sct_len] = _atl;
				_sct_len++;
				
				if(_dist == NODE_SCATTER_DIST.path)
					path_line_index = floor(i / _pre_amount);
			}
			
			array_resize(_sct, _sct_len);
			if(sortY) array_sort(_sct, function(a1, a2) /*=>*/ {return a1.y - a2.y});
			
			var i = 0;
			
			repeat(_sct_len) {
				var _atl = _sct[i++];
				
				surf = _atl.surface;
				_x   = _atl.x;
				_y	 = _atl.y;
				_scx = _atl.sx;
				_scy = _atl.sy;
				_r	 = _atl.rotation;
				clr	 = _atl.blend; 
				alp	 = _atl.alpha;
				
				if(_dyna) surf.draw(_x, _y, _scx, _scy, _r, clr, alp);
				else      draw_surface_ext(surf, _x, _y, _scx, _scy, _r, clr, alp);
				
				if(_dist == NODE_SCATTER_DIST.tile) {
					var _sw = _atl.w * _scx;
					var _sh = _atl.h * _scy;
					
					if(_dyna) {
						if(_x < _sw)				         surf.draw(_x + _ww, _y,       _scx, _scy, _r, clr, alp);
						if(_y < _sh)				         surf.draw(      _x, _y + _hh, _scx, _scy, _r, clr, alp);
						if(_x < _sw && _y < _sh)	         surf.draw(_x + _ww, _y + _hh, _scx, _scy, _r, clr, alp);
						
						if(_x > _ww - _sw)					 surf.draw(_x - _ww, _y,       _scx, _scy, _r, clr, alp);
						if(_y > _hh - _sh)					 surf.draw(_x,       _y - _hh, _scx, _scy, _r, clr, alp);
						if(_x > _ww - _sw || _y > _hh - _sh) surf.draw(_x - _ww, _y - _hh, _scx, _scy, _r, clr, alp);
						
					} else {
						if(_x < _sw)				         draw_surface_ext(surf, _x + _ww, _y,       _scx, _scy, _r, clr, alp);
						if(_y < _sh)				         draw_surface_ext(surf,       _x, _y + _hh, _scx, _scy, _r, clr, alp);
						if(_x < _sw && _y < _sh)	         draw_surface_ext(surf, _x + _ww, _y + _hh, _scx, _scy, _r, clr, alp);
						
						if(_x > _ww - _sw)					 draw_surface_ext(surf, _x - _ww, _y,       _scx, _scy, _r, clr, alp);
						if(_y > _hh - _sh)					 draw_surface_ext(surf, _x,       _y - _hh, _scx, _scy, _r, clr, alp);
						if(_x > _ww - _sw || _y > _hh - _sh) draw_surface_ext(surf, _x - _ww, _y - _hh, _scx, _scy, _r, clr, alp);
					}
				}
			}
			
			BLEND_NORMAL
			gpu_set_blendequation(bm_eq_add);
			gpu_set_tex_filter(false);
		surface_reset_target(); 
		
		scatter_data = _sct;
		
		_outData[0] = _outSurf;
		_outData[1] = _sct;
		
		return _outData;
	}
}