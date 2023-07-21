function Node_Scatter(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Scatter";
	dimension_index = 1;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Amount", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8);
	
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector_range);
	
	inputs[| 4] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 5] = nodeValue("Area", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ DEF_SURF_W / 2, DEF_SURF_H / 2, DEF_SURF_W / 2, DEF_SURF_H / 2, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area, function() { return inputs[| 1].getValue(); });
	
	inputs[| 6] = nodeValue("Distribution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Area", "Border", "Map", "Direct Data", "Path", "Full image" ]);
	
	inputs[| 7] = nodeValue("Point at center", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Rotate each copy to face the spawn center.");
	
	inputs[| 8] = nodeValue("Uniform scaling", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 9] = nodeValue("Scatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Random" ]);
	
	inputs[| 10] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom(9999999));
	
	inputs[| 11] = nodeValue("Random blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) );
	
	inputs[| 12] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, 0.01]);
		
	inputs[| 13] = nodeValue("Distribution map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 14] = nodeValue("Distribution data", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setDisplay(VALUE_DISPLAY.vector);
	inputs[| 14].array_depth = 1;
	
	inputs[| 15] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, @"What to do when input array of surface.
- Spread: Create Array of output each scattering single surface.
- Mixed: Create single output scattering multiple images.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Spread output",  "Mixed" ]);
		
	inputs[| 16] = nodeValue("Multiply alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		
	inputs[| 17] = nodeValue("Use value", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, [ "Scale" ], "Apply the third value in each data point (if exist) on given properties.")
		.setDisplay(VALUE_DISPLAY.text_array, [ "Scale",  "Rotation", "Color" ]);
		
	inputs[| 18] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Normal", "Add" ]);
		
	inputs[| 19] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone);
		
	inputs[| 20] = nodeValue("Rotate along path", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
		
	outputs[| 1] = nodeValue("Atlas data", self, JUNCTION_CONNECT.output, VALUE_TYPE.atlas, [])
		.rejectArrayProcess();
	
	input_display_list = [ 
		["Output", 		 true], 0, 1, 15, 10, 
		["Scatter",		false], 5, 6, 13, 14, 19, 20, 17, 9, 2,
		["Transform",	false], 3, 8, 7, 4,
		["Render",		false], 18, 11, 12, 16, 
	];
	
	attribute_surface_depth();
	
	scatter_data = [];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(process_amount > 1) return;
		
		var _distType	= current_data[6];
		if(_distType < 3)
			inputs[| 5].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static onValueUpdate = function(index) {
		if(index == 15) {
			var _arr = inputs[| 15].getValue();
			inputs[| 0].array_depth = _arr;
			
			update();
		}
	}
	
	static step = function() {
		var _dis = inputs[|  6].getValue();
		var _arr = inputs[| 15].getValue();
		inputs[| 0].array_depth = _arr;
		
		inputs[| 13].setVisible(_dis == 2, _dis == 2);
		inputs[| 14].setVisible(_dis == 3, _dis == 3);
		inputs[| 17].setVisible(_dis == 3);
		inputs[|  9].setVisible(_dis != 2);
		inputs[| 19].setVisible(_dis == 4, _dis == 4);
		inputs[| 20].setVisible(_dis == 4);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		if(_output_index == 1) return scatter_data;
		if(_output_index == 0 && _array_index == 0) scatter_data = [];
		
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
		var mulpA	= _data[16];
		var useV	= _data[17];
		var blend   = _data[18];
		
		var path    = _data[19];
		var pathRot = _data[20];
		
		var _in_w, _in_h;
		
		var vSca = array_exists(useV, "Scale");
		var vRot = array_exists(useV, "Rotation");
		var vCol = array_exists(useV, "Color");
		
		var _posDist = [];
		if(_dist == 2 && is_surface(_distMap)) 
			_posDist = get_points_from_dist(_distMap, _amount, seed);
		
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
			
			var _sed = seed;
			var res_index = 0, bg = 0;
			for(var i = 0; i < _amount; i++) {
				var sp = noone, _x = 0, _y = 0;
				var _v = noone;
				
				if(_dist < 2) {
					sp = area_get_random_point(_area, _dist, _scat, i, _amount, _sed); _sed += 20;
					_x = sp[0];
					_y = sp[1];
				} else if(_dist == 2) {
					sp = array_safe_get(_posDist, i);
					if(!is_array(sp)) continue;
				
					_x = _area[0] + _area[2] * (sp[0] * 2 - 1.);
					_y = _area[1] + _area[3] * (sp[1] * 2 - 1.);
				} else if(_dist == 3) {
					sp = array_safe_get(_distData, i);
					if(!is_array(sp)) continue;
					
					_x = array_safe_get(sp, 0);
					_y = array_safe_get(sp, 1);
					_v = array_safe_get(sp, 2, noone);
				} else if(_dist == 4) {
					if(path != noone && struct_has(path, "getPointRatio")) {
						var pp  = path.getPointRatio(i / max(1, _amount - 1) * 0.9999);
						_x = pp.x;
						_y = pp.y;
					}
				} else if(_dist == 5) {
					_x = random_range_seed(0, _dim[0], _sed); _sed++;
					_y = random_range_seed(0, _dim[1], _sed); _sed++;
					
					//print(string(_x) + ", " + string(_y));
				}
				
				var posS = _dist < 4? seed + _y * _dim[0] + _x : seed + i * 100;
				var _scx = random_range_seed(_scale[0], _scale[1], posS); posS++;
				var _scy = random_range_seed(_scale[2], _scale[3], posS); posS++; 
				if(_unis) _scy = _scx;
				
				if(vSca && _v != noone) {
					_scx *= _v;
					_scy *= _v;
				}
				
				var _r	 = (_pint? point_direction(_area[0], _area[1], _x, _y) : 0) + random_range_seed(_rota[0], _rota[1], posS); posS++;
				
				if(vRot && _v != noone)
					_r *= _v;
					
				if(_dist == 4 && path != noone && pathRot) {
					var rat = i / max(1, _amount - 1) * 0.9999;
					var p0  = path.getPointRatio(clamp(rat - 0.001, 0, 0.9999));
					var p1  = path.getPointRatio(clamp(rat + 0.001, 0, 0.9999));
					
					var dirr = point_direction(p0.x, p0.y, p1.x, p1.y);
					_r += dirr;
				}
				
				var surf = _inSurf;
				var ind  = 0;
				if(is_array(_inSurf)) {
					if(array_length(_inSurf) == 0) break;
					
					ind  = irandom_seed(array_length(_inSurf) - 1, posS);
					surf = _inSurf[ind]; 
					posS++;
				}
				
				var sw = surface_get_width(surf);
				var sh = surface_get_height(surf);
			
				if(_dist != AREA_DISTRIBUTION.area || _scat != AREA_SCATTER.uniform) {
					var p = point_rotate(-sw / 2 * _scx, -sh * _scy / 2, 0, 0, _r);
					_x += p[0];
					_y += p[1];
				}
				
				var grSamp = random_seed(1, posS); posS++;
				if(vCol && _v != noone)
					grSamp *= _v;
				
				var clr = color.eval(grSamp); 
				var alp = random_range_seed(alpha[0], alpha[1], posS); posS++;
				
				array_push(scatter_data, new SurfaceAtlas(surf, [ _x, _y ], _r, [ _scx, _scy ], clr, alp));
				draw_surface_ext_safe(surf, _x, _y, _scx, _scy, _r, clr, alp);
				
				if(_dist == 5) {
					var _sw = surface_get_width(surf)  * _scx;
					var _sh = surface_get_height(surf) * _scy;
					
					if(_x < _sw)
						draw_surface_ext_safe(surf, _dim[0] + _x, _y, _scx, _scy, _r, clr, alp);
					if(_y < _sh)
						draw_surface_ext_safe(surf, _x, _dim[1] + _y, _scx, _scy, _r, clr, alp);
					if(_x < _sw && _y < _sh)
						draw_surface_ext_safe(surf, _dim[0] + _x, _dim[1] + _y, _scx, _scy, _r, clr, alp);
					
					if(_x > _dim[0] - _sw)
						draw_surface_ext_safe(surf, _x - _dim[0], _y, _scx, _scy, _r, clr, alp);
					if(_y > _dim[1] - _sh)
						draw_surface_ext_safe(surf, _x, _y - _dim[1], _scx, _scy, _r, clr, alp);
					if(_x > _dim[0] - _sw || _y > _dim[1] - _sh)
						draw_surface_ext_safe(surf, _x - _dim[0], _y - _dim[1], _scx, _scy, _r, clr, alp);
				}
			}
			BLEND_NORMAL;
		surface_reset_target(); 
		
		return _outSurf;
	}
	
	static doApplyDeserialize = function() {
		var _arr = inputs[| 15].getValue();
		inputs[| 0].array_depth = _arr;
			
		doUpdate();
	}
}