#region create
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Normal", "Height > Set", KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Normal", "Flip X > Toggle",    "F", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[5].setValue(!_n.inputs[5].getValue()); });
		addHotkey("Node_Normal", "Normalize > Toggle", "N", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue(!_n.inputs[4].getValue()); });
	});
#endregion

function Node_Normal(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Normal";
	
	newActiveInput(3);
	
	////- =Surfaces
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- =Normal
	newInput(1, nodeValue_Float(  "Height",    1    ));
	newInput(2, nodeValue_Slider( "Smooth",    0, [ 0, 4, .1 ] )).setTooltip("Include diagonal pixel in normal calculation, which leads to smoother output.");
	newInput(5, nodeValue_Bool(   "Flip X",    true ));
	newInput(4, nodeValue_Bool(   "Normalize", true ));
	// inputs 6
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3,
		["Surfaces", false], 0,
		["Normal",	 false], 1, 2, 5, 4, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[ 1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny,  0, _dim[0] / 32));
		InputDrawOverlay(inputs[ 2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny, 90, _dim[1] /  2));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _hei = _data[1];
		var _smt = _data[2];
		var _nor = _data[4];
		var _swx = _data[5];
		
		surface_set_shader(_outSurf, sh_normal);
			gpu_set_texfilter(true);
			
			shader_set_f("dimension", surface_get_dimension(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_f("height",    _hei);
			shader_set_f("smooth",    _smt);
			shader_set_i("normal",    _nor);
			shader_set_i("swapx",     _swx);
			
			draw_surface_safe(_data[0]);
			
			gpu_set_texfilter(false);
		surface_reset_shader();
		
		return _outSurf;
	}
}