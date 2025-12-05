#region create
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_FXAA", "Distance > Set", KEY_GROUP.numeric, 0, function() /*=>*/ { 
			GRAPH_FOCUS_NUMBER 
			 _n.inputs[2].setValue(toDecimal(KEYBOARD_NUMBER));
			KEYBOARD_STRING = "";
		});
	});
	
#endregion

function Node_FXAA(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "FXAA";
	
	newActiveInput(1);
	newInput(4, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(5, nodeValue_Surface( "Mask"       ));
	newInput(6, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(5, 7); // inputs 7, 8, 
	
	////- =Effect
	newInput(2, nodeValue_Slider( "Distance", .5 )).setHotkey("S");
	newInput(3, nodeValue_Slider( "Mix",       1 ));
	// input 9
	
	input_display_list = [ 1, 4, 
		["Surfaces", false], 0, 5, 6, 7, 8, 
		["Effect",   false], 2, 3, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Mask", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index) {
		var _mask  = _data[5];
		var _mix   = _data[6];
		
		var _dim = surface_get_dimension(_data[0]);
		_outData[0] = surface_verify(_outData[0], _dim[0], _dim[1]);
		_outData[1] = surface_verify(_outData[1], _dim[0], _dim[1]);
		
		surface_set_target_ext(0, _outData[0]);
		surface_set_target_ext(1, _outData[1]);
		shader_set(sh_FXAA);
		DRAW_CLEAR
		BLEND_OVERRIDE
		gpu_set_tex_filter(true);
			shader_set_2("dimension", _dim);
			shader_set_f("cornerDis", _data[2]);
			shader_set_f("mixAmo",    _data[3]);
			
			draw_surface_safe(_data[0]);
		gpu_set_tex_filter(false);
		BLEND_NORMAL
		shader_reset();
		surface_reset_target();
		
		__process_mask_modifier(_data);
		_outData[0] = mask_apply(_data[0], _outData[0], _mask, _mix);
		_outData[0] = channel_apply(_data[0], _outData[0], _data[4]);
		
		return _outData;
	}
}