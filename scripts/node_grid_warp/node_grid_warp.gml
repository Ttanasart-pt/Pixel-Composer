function Node_Grid_Warp(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grid Warp";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
		active_index = 1;
	
	newInput(2, nodeValue_Int("Grid", self, 1, "Amount of grid subdivision. Higher number means more grid, detail."))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 1 ] })
		.rejectArray();
		
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	function createNewInput() {
		var index = array_length(inputs);
		var i = index - input_fix_len;
		
		newInput(index, nodeValue_Vec2($"Anchor {i}", self, [ 0, 0 ]))
			.setUnitRef(function(index) /*=>*/ {return getDimension(index)});
		
		array_push(input_display_list, index);
		return inputs[index];
	}
	
	input_display_list = [ 1, 0, 
		["Mesh",    false], 2, 
		["Anchors",  true], 
	];
	
	setDynamicInput(1, false);
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static resetDisplay = function() {
		input_display_list = array_clone(input_display_list_raw, 1);
		for( var i = input_display_len, n = array_length(inputs); i < n; i++ )
			array_push(input_display_list, i);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
	}
	
	static step = function() {
		
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _grid = _data[2];
		
		var _aamo = (_grid + 1) * (_grid + 1);
		var _iamo = getInputAmount();
		
		if(_iamo < _aamo) {
			repeat(_aamo - _iamo) createNewInput();
			resetDisplay();
				
		} else if(_iamo > _aamo) {
			array_resize(inputs, input_fix_len + _aamo);
			resetDisplay();
		}
		
	}
}