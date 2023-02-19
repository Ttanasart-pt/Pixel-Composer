function Node_Scatter(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Scatter";
	dimension_index = 1;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Amount", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8);
	
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector_range);
	
	inputs[| 4] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 5] = nodeValue("Area", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ def_surf_size / 2, def_surf_size / 2, def_surf_size / 2, def_surf_size / 2, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area, function() { return inputs[| 1].getValue(); });
	
	inputs[| 6] = nodeValue("Distribution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Area", "Border", "Map", "Direct Data" ]);
	
	inputs[| 7] = nodeValue("Point at center", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Rotate each copy to face the spawn center.");
	
	inputs[| 8] = nodeValue("Uniform scaling", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 9] = nodeValue("Scatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Random" ]);
	
	inputs[| 10] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom(9999999));
	
	inputs[| 11] = nodeValue("Random blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [ new gradientKey(0, c_white) ] )
		.setDisplay(VALUE_DISPLAY.gradient);
	
	inputs[| 12] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, 0.01]);
		
	inputs[| 13] = nodeValue("Distribution map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 14] = nodeValue("Distribution data", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 15] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, @"What to do when input array of surface.
- Spread: Create Array of output each scattering single surface.
- Mixed: Create single output scattering multiple images.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Spread output",  "Mixed" ]);
		
	inputs[| 16] = nodeValue("Multiply alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 
		["Surface",		false], 0, 1, 15, 10, 
		["Scatter",		false], 5, 6, 13, 14, 9, 2,
		["Transform",	false], 3, 8, 7, 4,
		["Render",		false], 11, 12, 16, 
	];
	
	temp_surf = [ surface_create(1, 1), surface_create(1, 1) ];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 5].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static onValueUpdate = function(index) {
		if(index == 15) {
			var _arr = inputs[| 15].getValue();
			inputs[| 0].force_array = _arr;
			
			doUpdate();
		}
	}
	
	static step = function() {
		var _dis = inputs[|  6].getValue();
		var _arr = inputs[| 15].getValue();
		inputs[| 0].force_array = _arr;
		
		inputs[| 13].setVisible(_dis == 2, _dis == 2);
		inputs[| 14].setVisible(_dis == 3, _dis == 3);
		inputs[|  9].setVisible(_dis != 2);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
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
		var _bldTyp	= inputs[| 11].getExtraData();
		var alpha	= _data[12];
		var mulpA	= _data[16];
		
		var _in_w, _in_h;
		
		var _posDist = [];
		if(_dist == 2 && is_surface(_distMap)) 
			_posDist = get_points_from_dist(_distMap, _amount);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			if(mulpA) BLEND_ALPHA_MULP;
			else      BLEND_ALPHA;
			
			var _sed = seed;
			var res_index = 0, bg = 0;
			for(var i = 0; i < _amount; i++) {
				var sp = noone, _x = 0, _y = 0;
			
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
					
					_x = sp[0];
					_y = sp[1];
				}
			
				var _scx = random_range_seed(_scale[0], _scale[1], _sed); _sed++;
				var _scy = random_range_seed(_scale[2], _scale[3], _sed); _sed++;
				if(_unis) _scy = _scx;
				
				var _r	 = (_pint? point_direction(_area[0], _area[1], _x, _y) : 0) + random_range_seed(_rota[0], _rota[1], _sed); _sed++;
				
				var surf = _inSurf;
				if(is_array(_inSurf)) 
					surf = _inSurf[irandom_seed(array_length(_inSurf) - 1, _sed)]; _sed++;
			
				var sw = surface_get_width(surf);
				var sh = surface_get_height(surf);
			
				if(_dist != AREA_DISTRIBUTION.area || _scat != AREA_SCATTER.uniform) {
					var p = point_rotate(-sw / 2 * _scx, -sh * _scy / 2, 0, 0, _r);
					_x += p[0];
					_y += p[1];
				}
			
				var clr = gradient_eval(color, random_seed(1, _sed), _bldTyp[| 0]); _sed++;
				var alp = random_range_seed(alpha[0], alpha[1], _sed); _sed++;
				
				draw_surface_ext_safe(surf, _x, _y, _scx, _scy, _r, clr, alp);
				//print(string(_x) + ", " + string(_y))
			}
			BLEND_NORMAL;
		surface_reset_target(); 
		
		return _outSurf;
	}
	
	static doApplyDeserialize = function() {
		var _arr = inputs[| 15].getValue();
		inputs[| 0].force_array = _arr;
			
		doUpdate();
	}
}