enum NODE_SCATTER_DIST {
	area,
	border,
	map,
	data,
	path,
	tile
}

function Node_Scatter(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Scatter";
	dimension_index = 1;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Amount", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8);
	
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector_range, { linked : true });
	
	inputs[| 4] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0, 0, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.rotation_random);
	
	onSurfaceSize = function() { return getInputData(1, DEF_SURF); };
	inputs[| 5] = nodeValue("Area", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ DEF_SURF_W / 2, DEF_SURF_H / 2, DEF_SURF_W / 2, DEF_SURF_H / 2, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area, { onSurfaceSize });
	
	inputs[| 6] = nodeValue("Distribution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Area", "Border", "Map", "Direct Data", "Path", "Full image + Tile" ]);
	
	inputs[| 7] = nodeValue("Point at center", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Rotate each copy to face the spawn center.");
	
	inputs[| 8] = nodeValue("Uniform scaling", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 9] = nodeValue("Scatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Random" ]);
	
	inputs[| 10] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom(9999999));
	
	inputs[| 11] = nodeValue("Random blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) );
	
	inputs[| 12] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
		
	inputs[| 13] = nodeValue("Distribution map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 14] = nodeValue("Distribution data", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setDisplay(VALUE_DISPLAY.vector);
	inputs[| 14].array_depth = 1;
	
	inputs[| 15] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, @"What to do when input array of surface.
- Spread: Create Array of output each scattering single surface.
- Mixed: Create single output scattering multiple images.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Spread output", "Index", "Random", "Data", "Texture" ]);
		
	inputs[| 16] = nodeValue("Multiply alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		
	inputs[| 17] = nodeValue("Use value", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, [ "Scale" ], "Apply the third value in each data point (if exist) on given properties.")
		.setDisplay(VALUE_DISPLAY.text_array, { data: [ "Scale",  "Rotation", "Color" ] });
		
	inputs[| 18] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Normal", "Add" ]);
		
	inputs[| 19] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone);
		
	inputs[| 20] = nodeValue("Rotate along path", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		
	inputs[| 21] = nodeValue("Path Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 22] = nodeValue("Scatter Distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 23] = nodeValue("Sort Y", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 24] = nodeValue("Array indices", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [])
		.setArrayDepth(1);
	
	inputs[| 25] = nodeValue("Array texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
		
	outputs[| 1] = nodeValue("Atlas data", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, [])
		.rejectArrayProcess();
	
	input_display_list = [ 
		["Surfaces", 	 true], 0, 1, 15, 10, 24, 25, 
		["Scatter",		false], 5, 6, 13, 14, 17, 9, 2,
		["Path",		false], 19, 20, 21, 22, 
		["Transform",	false], 3, 8, 7, 4,
		["Render",		false], 18, 11, 12, 16, 23, 
	];
	
	attribute_surface_depth();
	
	scatter_data = [];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _distType	= current_data[6];
		if(_distType < 3)
			inputs[| 5].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static onValueUpdate = function(index) { #region
		if(index == 15) {
			var _arr = getInputData(15);
			inputs[| 0].array_depth = _arr;
			
			update();
		}
	} #endregion
	
	static step = function() { #region
		var _dis = getInputData(6);
		var _arr = getInputData(15);
		inputs[| 0].array_depth = bool(_arr);
		
		inputs[| 13].setVisible(_dis == 2, _dis == 2);
		inputs[| 14].setVisible(_dis == 3, _dis == 3);
		inputs[| 17].setVisible(_dis == 3);
		inputs[|  9].setVisible(_dis != 2);
		inputs[| 19].setVisible(_dis == 4, _dis == 4);
		inputs[| 20].setVisible(_dis == 4);
		inputs[| 21].setVisible(_dis == 4);
		inputs[| 22].setVisible(_dis == 4);
		inputs[| 24].setVisible(_arr == 3, _arr == 3);
		inputs[| 25].setVisible(_arr == 4, _arr == 4);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		if(_output_index == 1) return scatter_data;
		
		var _inSurf = _data[0];
		if(_inSurf == 0)
			return;
		
		var _dim	= _data[1];
		var _amount	= _data[2];
		var _scale	= _data[3];
		var _rota	= _data[4];
		
		var _area	= _data[5];
		
		var _dist		= _data[ 6];
		var _distMap	= _data[13];
		var _distData	= _data[14];
		var _scat		= _data[ 9];
		
		var _pint	= _data[7];
		var _unis	= _data[8];
		
		var seed	= _data[10];
		var color	= _data[11];
		var alpha	= _data[12];
		var _arr    = _data[15];
		var mulpA	= _data[16];
		var useV	= _data[17];
		var blend   = _data[18];
		
		var path    = _data[19];
		var pathRot = _data[20];
		var pathShf = _data[21];
		var pathDis = _data[22];
		var sortY   = _data[23];
		var arrId   = _data[24];
		var arrTex  = _data[25], useArrTex = is_surface(arrTex);
		
		var _in_w, _in_h;
		
		var vSca = array_exists(useV, "Scale");
		var vRot = array_exists(useV, "Rotation");
		var vCol = array_exists(useV, "Color");
		
		var _posDist = [];
		if(_dist == NODE_SCATTER_DIST.map) {
			if(!is_surface(_distMap))
				return _outSurf;
			_posDist = get_points_from_dist(_distMap, _amount, seed);
		}
			
		if(_dist == 4) {
			var path_valid    = path != noone && struct_has(path, "getPointRatio");
			
			if(!path_valid) return _outSurf;
			
			var _pathProgress = 0;
			var path_amount   = struct_has(path, "getLineCount")? path.getLineCount() : 1;
			var _pre_amount   = _amount;
			_amount *= path_amount;
			
			var path_line_index = 0;
		}
		
		var _sed = seed;
		var _sct = array_create(_amount);
		var _sct_len = 0;
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			switch(blend) {
				case 0 :
					if(mulpA) BLEND_ALPHA_MULP;
					else      BLEND_ALPHA;
					break;
				case 1 :
					BLEND_ADD;
					break;
			}
			
			var positions = array_create(_amount);
			var posIndex  = 0;
			
			for(var i = 0; i < _amount; i++) {
				if(is_array(_inSurf) && array_length(_inSurf) == 0) break;
				
				var sp = noone, _x = 0, _y = 0;
				var _v = noone;
				
				if(_dist == NODE_SCATTER_DIST.area || _dist == NODE_SCATTER_DIST.border) {
					sp = area_get_random_point(_area, _dist, _scat, i, _amount, _sed); _sed += 20;
					_x = sp[0];
					_y = sp[1];
				} else if(_dist == NODE_SCATTER_DIST.map) {
					sp = array_safe_get(_posDist, i);
					if(!is_array(sp)) continue;
				
					_x = _area[0] + _area[2] * (sp[0] * 2 - 1.);
					_y = _area[1] + _area[3] * (sp[1] * 2 - 1.);
				} else if(_dist == NODE_SCATTER_DIST.data) {
					sp = array_safe_get(_distData, i);
					if(!is_array(sp)) continue;
					
					_x = array_safe_get(sp, 0);
					_y = array_safe_get(sp, 1);
					_v = array_safe_get(sp, 2, noone);
				} else if(_dist == NODE_SCATTER_DIST.path) {
					_pathProgress = _scat? random_seed(1, _sed) : i / max(1, _pre_amount); _sed++;
					_pathProgress = frac((_pathProgress + pathShf) * 0.9999);
					
					var pp = path.getPointRatio(_pathProgress, path_line_index);
					_x = pp.x + random_range_seed(-pathDis, pathDis, _sed); _sed++;
					_y = pp.y + random_range_seed(-pathDis, pathDis, _sed); _sed++;
				} else if(_dist == NODE_SCATTER_DIST.tile) {
					if(_scat == 0) {
						var _col = ceil(sqrt(_amount));
						var _row = ceil(_amount / _col);
				
						var _iwid = _dim[0] / _col;
						var _ihig = _dim[1] / _row;
						
						var _irow = floor(i / _col);
						var _icol = safe_mod(i, _col);
						
						_x = _icol * _iwid;
						_y = _irow * _ihig;
					} else if(_scat == 1) {
						_x = random_range_seed(0, _dim[0], _sed); _sed++;
						_y = random_range_seed(0, _dim[1], _sed); _sed++;
					}
				}
				
				var posS = _dist < 4? seed + _y * _dim[0] + _x : seed + i * 100;
				var _scx = random_range_seed(_scale[0], _scale[1], posS); posS++;
				var _scy = random_range_seed(_scale[2], _scale[3], posS); posS++; 
				if(_unis) _scy = _scx;
				
				if(vSca && _v != noone) {
					_scx *= _v;
					_scy *= _v;
				}
				
				var _r = (_pint? point_direction(_area[0], _area[1], _x, _y) : 0) + angle_random_eval(_rota, posS); posS++;
				
				if(vRot && _v != noone)
					_r *= _v;
					
				if(_dist == NODE_SCATTER_DIST.path && pathRot) {
					var p0 = path.getPointRatio(clamp(_pathProgress - 0.001, 0, 0.9999), path_line_index);
					var p1 = path.getPointRatio(clamp(_pathProgress + 0.001, 0, 0.9999), path_line_index);
					
					var dirr = point_direction(p0.x, p0.y, p1.x, p1.y);
					_r += dirr;
				}
				
				var surf = _inSurf;
				var ind  = 0;
				
				if(is_array(_inSurf)) {
					switch(_arr) { 
						case 1 : ind  = safe_mod(i, array_length(_inSurf));						break;
						case 2 : ind  = irandom_seed(array_length(_inSurf) - 1, posS); posS++;	break;
						case 3 : ind  = array_safe_get(arrId, i, 0);							break;
						case 4 : if(useArrTex) ind = color_get_brightness(surface_get_pixel(arrTex, _x, _y)) * (array_length(_inSurf) - 1); break;
					}
					
					surf = array_safe_get(_inSurf, ind, 0); 
				}
				
				var sw = surface_get_width_safe(surf);
				var sh = surface_get_height_safe(surf);
				
				var _p = point_rotate(_x - sw / 2 * _scx, _y - sh * _scy / 2, _x, _y, _r);
				_x = _p[0];
				_y = _p[1];
				
				var grSamp = random_seed(1, posS); posS++;
				if(vCol && _v != noone)
					grSamp *= _v;
				
				var clr = color.eval(grSamp); 
				var alp = random_range_seed(alpha[0], alpha[1], posS); posS++;
				
				var _atl = array_safe_get(scatter_data, _sct_len);
				if(!is_instanceof(_atl, SurfaceAtlas)) 
					_atl = new SurfaceAtlas(surf, _x, _y, _r, _scx, _scy, clr, alp);
				else 
					_atl.set(surf, _x, _y, _r, _scx, _scy, clr, alp);
				_sct[_sct_len] = _atl;
				_sct_len++;
				
				if(_dist == NODE_SCATTER_DIST.path)
					path_line_index = floor(i / _pre_amount);
			}
			
			array_resize(_sct, _sct_len);
			if(sortY) array_sort(_sct, function(a1, a2) { return a1.y - a2.y; });
			
			for( var i = 0; i < _sct_len; i++ ) {
				var _atl = _sct[i];
				
				surf = _atl.getSurface();
				_x   = _atl.x;
				_y	 = _atl.y;
				_scx = _atl.sx;
				_scy = _atl.sy;
				_r	 = _atl.rotation;
				clr	 = _atl.blend;
				alp	 = _atl.alpha;
				
				draw_surface_ext_safe(surf, _x, _y, _scx, _scy, _r, clr, alp);
				
				if(_dist == NODE_SCATTER_DIST.tile) {
					var _sw = surface_get_width_safe(surf)  * _scx;
					var _sh = surface_get_height_safe(surf) * _scy;
					
					if(_x < _sw)				draw_surface_ext_safe(surf, _dim[0] + _x, _y, _scx, _scy, _r, clr, alp);
					if(_y < _sh)				draw_surface_ext_safe(surf, _x, _dim[1] + _y, _scx, _scy, _r, clr, alp);
					if(_x < _sw && _y < _sh)	draw_surface_ext_safe(surf, _dim[0] + _x, _dim[1] + _y, _scx, _scy, _r, clr, alp);
					
					if(_x > _dim[0] - _sw)							draw_surface_ext_safe(surf, _x - _dim[0], _y, _scx, _scy, _r, clr, alp);
					if(_y > _dim[1] - _sh)							draw_surface_ext_safe(surf, _x, _y - _dim[1], _scx, _scy, _r, clr, alp);
					if(_x > _dim[0] - _sw || _y > _dim[1] - _sh)	draw_surface_ext_safe(surf, _x - _dim[0], _y - _dim[1], _scx, _scy, _r, clr, alp);
				}
			}
			
			BLEND_NORMAL;
		surface_reset_target(); 
		
		scatter_data = _sct;
		
		return _outSurf;
	} #endregion
	
	static doApplyDeserialize = function() { #region
		var _arr = getInputData(15);
		inputs[| 0].array_depth = _arr;
			
		doUpdate();
	} #endregion
}