function Node_Grid_Warp(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grid Warp";
	
	newActiveInput(1);
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- =Mesh
	newInput(2, nodeValue_IVec2( "Grid", [ 2, 2 ])).setTooltip("Amount of grid subdivision. Higher number means more grid, detail.").rejectArray();
	newInput(3, nodeValue_Int(   "Subdivision", 4 ));
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	function createNewInput() {
		var index = array_length(inputs);
		var i = index - input_fix_len;
		
		newInput(index, nodeValue_Vec2($"Anchor {i}", [ 0, 0 ])).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
		
		array_push(input_display_list, index);
		inputs[index].overlay_draw_text = false;
		return inputs[index];
	}
	
	input_display_list = [ 1, 0, 
		["Mesh",    false], 2, 3, 
		["Anchors",  true], 
	];
	
	setDynamicInput(1, false);
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static resetInput = function() {
		input_display_list = array_clone(input_display_list_raw, 1);
		array_resize(inputs, input_fix_len);
		
		var _grid  = getInputData(2);
		var _gridW = _grid[0];
		var _gridH = _grid[1];
		
		var _ind  = input_fix_len;
		var _dim  = getDimension(0);
		
		for(var i = 0; i <= _gridH; i++)
		for(var j = 0; j <= _gridW; j++) {
			var _inp = createNewInput();
			_inp.setValueInspector([ j / _gridW, i / _gridH ]);
		}
		
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {

		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
		var _surf  = getInputData(0);
		var _grid  = getInputData(2);
		var _gridW = _grid[0];
		var _gridH = _grid[1];
		
		var _aamo = (_gridW + 1) * (_gridH + 1);
		var _iamo = getInputAmount();
		
		if(_iamo != _aamo) return w_hovering;
		
		var _an = array_create(_iamo);
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			var _i = i - input_fix_len;
			
			var _rawVal = getInputData(i);
			_an[_i][0] = _x + _rawVal[0] * _s;
			_an[_i][1] = _y + _rawVal[1] * _s;
		}
		
		draw_set_color(COLORS._main_accent);
		for( var i = 0; i <  _gridH; i++ )
		for( var j = 0; j <= _gridW; j++ ) {
			var _a0 = _an[(i    ) * (_gridW + 1) + j];
			var _a1 = _an[(i + 1) * (_gridW + 1) + j];
			
			draw_line(_a0[0], _a0[1], _a1[0], _a1[1]);
		}
		
		for( var i = 0; i <= _gridH; i++ )
		for( var j = 0; j <  _gridW; j++ ) {
			var _a0 = _an[i * (_gridW + 1) + (j    )];
			var _a1 = _an[i * (_gridW + 1) + (j + 1)];
			
			draw_line(_a0[0], _a0[1], _a1[0], _a1[1]);
		}
				
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ )
			InputDrawOverlay(inputs[i].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, 1));
		
		return w_hovering;
	}
	
	static preGetInputs  = function() {
		var _grid  = inputs[2].getValue();
		var _gridW = _grid[0];
		var _gridH = _grid[1];
		
		var _aamo = (_gridW + 1) * (_gridH + 1);
		var _iamo = getInputAmount();
		if(_iamo != _aamo) resetInput();
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf  = _data[0];
		var _grid  = _data[2];
		var _subd  = _data[3];
		
		var _gridW = _grid[0];
		var _gridH = _grid[1];
		
		if(!is_surface(_surf)) return _outSurf;
		
		var _dim  = surface_get_dimension(_surf);
		var _stW  = _gridW? 1 / _gridW : 1;
		var _stH  = _gridH? 1 / _gridH : 1;
		var _imp  = 1 / _subd;
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE
			draw_set_color_alpha(c_white, 1);
			gpu_set_tex_filter(attributes.interpolate > 1);
			
			draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_surf));
			var _itr = 0;
			var ix0, ix1, iy0, iy1;
			
			for( var i = 0; i < _gridH; i++ )
			for( var j = 0; j < _gridW; j++ ) {
				var _a0 = _data[input_fix_len + (i    ) * (_gridW + 1) + (j    )];
				var _a1 = _data[input_fix_len + (i    ) * (_gridW + 1) + (j + 1)];
				var _a2 = _data[input_fix_len + (i + 1) * (_gridW + 1) + (j    )];
				var _a3 = _data[input_fix_len + (i + 1) * (_gridW + 1) + (j + 1)];
				
				var _a0x = _a0[0], _a0y = _a0[1];
				var _a1x = _a1[0], _a1y = _a1[1];
				var _a2x = _a2[0], _a2y = _a2[1];
				var _a3x = _a3[0], _a3y = _a3[1];

				var _u0 = _stW * (j    );
				var _u1 = _stW * (j + 1);
				var _v0 = _stH * (i    );
				var _v1 = _stH * (i + 1);
				
				for( var yy = 0; yy < _subd; yy++ )
				for( var xx = 0; xx < _subd; xx++ ) {
					
					iy0 = yy  * _imp;
					iy1 = iy0 + _imp;
					
					ix0 = xx  * _imp;
					ix1 = ix0 + _imp;
					
					var _aa0x = lerp(lerp(_a0x, _a1x, ix0), lerp(_a2x, _a3x, ix0), iy0);
					var _aa0y = lerp(lerp(_a0y, _a2y, iy0), lerp(_a1y, _a3y, iy0), ix0);
					
					var _aa1x = lerp(lerp(_a0x, _a1x, ix1), lerp(_a2x, _a3x, ix1), iy0);
					var _aa1y = lerp(lerp(_a0y, _a2y, iy0), lerp(_a1y, _a3y, iy0), ix1);
					
					var _aa2x = lerp(lerp(_a0x, _a1x, ix0), lerp(_a2x, _a3x, ix0), iy1);
					var _aa2y = lerp(lerp(_a0y, _a2y, iy1), lerp(_a1y, _a3y, iy1), ix0);
					
					var _aa3x = lerp(lerp(_a0x, _a1x, ix1), lerp(_a2x, _a3x, ix1), iy1);
					var _aa3y = lerp(lerp(_a0y, _a2y, iy1), lerp(_a1y, _a3y, iy1), ix1);
					
					var _uu0  = lerp(_u0, _u1, ix0);
					var _uu1  = lerp(_u0, _u1, ix1);
					var _vv0  = lerp(_v0, _v1, iy0);
					var _vv1  = lerp(_v0, _v1, iy1);
					
					draw_vertex_texture(_aa0x, _aa0y, _uu0, _vv0);
					draw_vertex_texture(_aa1x, _aa1y, _uu1, _vv0);
					draw_vertex_texture(_aa2x, _aa2y, _uu0, _vv1);
					
					draw_vertex_texture(_aa1x, _aa1y, _uu1, _vv0);
					draw_vertex_texture(_aa2x, _aa2y, _uu0, _vv1);
					draw_vertex_texture(_aa3x, _aa3y, _uu1, _vv1);
					
					if(++_itr > 32) {
						draw_primitive_end();
						draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_surf));
					}
				}
				
			}
			
			draw_primitive_end();
			gpu_set_tex_filter(false);
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}