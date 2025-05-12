function Node_Grid_Warp(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grid Warp";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
		active_index = 1;
	
	newInput(2, nodeValue_Int("Grid", self, 1, "Amount of grid subdivision. Higher number means more grid, detail."))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 1 ] })
		.rejectArray();
		
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	function createNewInput() {
		var index = array_length(inputs);
		var i = index - input_fix_len;
		
		newInput(index, nodeValue_Vec2($"Anchor {i}", self, [ 0, 0 ]))
			.setUnitRef(function(index) /*=>*/ {return getDimension(index)}, VALUE_UNIT.reference);
		
		inputs[index].overlay_draw_text = false;
		return inputs[index];
	}
	
	input_display_list = [ 1, 0, 
		["Mesh",    false], 2, 
		["Anchors",  true], 
	];
	
	setDynamicInput(1, false);
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static resetInput = function() {
		input_display_list = array_clone(input_display_list_raw, 1);
		array_resize(inputs, input_fix_len);
		
		var _grid = getInputData(2);
		var _st   = _grid? 1 / _grid : 1;
		var _ind  = input_fix_len;
		var _dim  = getDimension(0);
		
		for(var i = 0; i <= _grid; i++)
		for(var j = 0; j <= _grid; j++) {
			array_push(input_display_list, _ind++);
			
			var _inp = createNewInput();
			_inp.setValueInspector([ j * _st * _dim[0], i * _st * _dim[1] ]);
		}
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {

		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
		var _surf = getInputData(0);
		var _grid = getInputData(2);
		
		var _aamo = (_grid + 1) * (_grid + 1);
		var _iamo = getInputAmount();
		
		if(_iamo != _aamo) return w_hovering;
		
		var _an = array_create(_iamo);
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			var _i = i - input_fix_len;
			
			_an[_i] = inputs[i].getValue();
			_an[_i][0] = _x + _an[_i][0] * _s;
			_an[_i][1] = _y + _an[_i][1] * _s;
		}
		
		draw_set_color(COLORS._main_accent);
		for( var i = 0; i <  _grid; i++ )
		for( var j = 0; j <= _grid; j++ ) {
			var _a0 = _an[(i    ) * (_grid + 1) + j];
			var _a1 = _an[(i + 1) * (_grid + 1) + j];
			
			draw_line(_a0[0], _a0[1], _a1[0], _a1[1]);
		}
		
		for( var i = 0; i <= _grid; i++ )
		for( var j = 0; j <  _grid; j++ ) {
			var _a0 = _an[i * (_grid + 1) + (j    )];
			var _a1 = _an[i * (_grid + 1) + (j + 1)];
			
			draw_line(_a0[0], _a0[1], _a1[0], _a1[1]);
		}
				
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ )
			InputDrawOverlay(inputs[i].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static step = function() {
		
	}
	
	static preGetInputs  = function() {
		var _grid = inputs[2].getValue();
		
		var _aamo = (_grid + 1) * (_grid + 1);
		var _iamo = getInputAmount();
		if(_iamo != _aamo) resetInput();
	}
	
	static draw_vertex_rectangle = function(_x0, _y0, _x1, _y1, _x2, _y2, _x3, _y3, _u0, _v0, _u1, _v1) {
		draw_vertex_texture(_x0, _y0, _u0, _v0);
		draw_vertex_texture(_x1, _y1, _u1, _v0);
		draw_vertex_texture(_x2, _y2, _u0, _v1);
		
		draw_vertex_texture(_x1, _y1, _u1, _v0);
		draw_vertex_texture(_x2, _y2, _u0, _v1);
		draw_vertex_texture(_x3, _y3, _u1, _v1);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _grid = _data[2];
		
		if(!is_surface(_surf)) return _outSurf;
		
		var _dim  = surface_get_dimension(_surf);
		var _st   = _grid? 1 / _grid : 1;
		var _smp  = 2;
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE
			
			draw_set_color(c_white);
			draw_set_alpha(1);
			
			draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_surf));
				for( var i = 0; i < _grid; i++ )
				for( var j = 0; j < _grid; j++ ) {
					var _a0 = _data[input_fix_len + (i    ) * (_grid + 1) + (j    )];
					var _a1 = _data[input_fix_len + (i    ) * (_grid + 1) + (j + 1)];
					var _a2 = _data[input_fix_len + (i + 1) * (_grid + 1) + (j    )];
					var _a3 = _data[input_fix_len + (i + 1) * (_grid + 1) + (j + 1)];
					
					var _u0 = _st * (j    );
					var _u1 = _st * (j + 1);
					var _v0 = _st * (i    );
					var _v1 = _st * (i + 1);
					
					draw_vertex_rectangle(_a0[0], _a0[1], _a1[0], _a1[1], _a2[0], _a2[1], _a3[0], _a3[1], _u0, _v0, _u1, _v1);
				}
			draw_primitive_end();
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}