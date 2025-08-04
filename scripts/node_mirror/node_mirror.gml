#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Mirror", "Angle > Rotate CCW", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 90) % 360); });
	});
#endregion

function Node_Mirror(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Mirror";
	
	newActiveInput(3);
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	
	////- =Mirror
	newInput(1, nodeValue_Vec2(     "Position", [.5,.5] )).setHotkey("G").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput(2, nodeValue_Rotation( "Angle",     0      )).setHotkey("R");
	newInput(4, nodeValue_Bool(     "Both Side", false  ));
	// input 5
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Mirror mask", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3,
		["Surfaces", false], 0, 
		["Mirror",	 false], 1, 2, 4, 
	]
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _pos  = current_data[1];
		var _ang  = current_data[2];
		var _posx = _pos[0] * _s + _x;
		var _posy = _pos[1] * _s + _y;
		
		var dx0 = _posx + lengthdir_x(1000, _ang);
		var dx1 = _posx + lengthdir_x(1000, _ang + 180);
		var dy0 = _posy + lengthdir_y(1000, _ang);
		var dy1 = _posy + lengthdir_y(1000, _ang + 180);
		
		draw_set_color(COLORS._main_accent);
		draw_line(dx0, dy0, dx1, dy1);
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _posx, _posy, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index) {
		var _suf = _data[0];
		var _pos = _data[1];
		var _ang = _data[2];
		var _bth = _data[4];
		
		var _dim = surface_get_dimension(_suf);
		var _outSurf = surface_verify(_outData[0], _dim[0], _dim[1]);
		var _outMask = surface_verify(_outData[1], _dim[0], _dim[1]);
		
		shader_set(sh_mirror);
		surface_set_target_ext(0, _outSurf);
		surface_set_target_ext(1, _outMask);
		DRAW_CLEAR
		BLEND_OVERRIDE
			
			shader_set_f("dimension", _dim);
			shader_set_2("position",  _pos);
			shader_set_f("angle",     degtorad(_ang));
			shader_set_i("bothSide",  _bth);
			
			draw_surface_safe(_suf);
		
		BLEND_NORMAL
		shader_reset();
		surface_reset_target();
		
		return [ _outSurf, _outMask ];
	}
}