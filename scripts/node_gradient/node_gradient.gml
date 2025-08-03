#region create
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Gradient", "Type > Toggle",     "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 3); });
		addHotkey("Node_Gradient", "Angle > Rotate CCW","R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue((_n.inputs[3].getValue() + 90) % 360); });
		addHotkey("Node_Gradient", "Gradient > Invert", "I", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS 
			var _grad = _n.inputs[1].getValue();
			var _k = [];
			for( var i = 0, n = array_length(_grad.keys); i < n; i++ ) {
				_k[i] = _grad.keys[n - i - 1];
				_k[i].time = 1 - _k[i].time;
			}
			_grad.keys = _k;
			_grad.refresh();
			_n.triggerRender();
		});
	});
#endregion

function Node_Gradient(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Gradient";
	
	////- Output
	newInput(0, nodeValue_Dimension());
	newInput(8, nodeValue_Surface( "Mask" ));
	
	////- Gradient
	newInput( 1, nodeValue_Gradient(    "Gradient", new gradientObject([ ca_black, ca_white ]))).setMappable(15);
	newInput( 5, nodeValue_Slider(      "Shift", 0, [-2,2,.01] )).setMappable(12);
	newInput( 9, nodeValue_Slider(      "Scale", 1, [ 0,5,.01] )).setMappable(13);
	newInput( 7, nodeValue_Enum_Button( "Loop",  0, [ "None", "Loop", "Pingpong" ]));
	
	////- Shape
	__gradTypes = __enum_array_gen(["Linear", "Circular", "Radial", "Diamond"], s_node_gradient_type);
	newInput( 2, nodeValue_Enum_Scroll( "Type",           0, __gradTypes));
	newInput( 3, nodeValue_Rotation(    "Angle",          0      )).setMappable(10);
	newInput( 4, nodeValue_Float(       "Radius",        .5      )).setMappable(11);
	newInput( 6, nodeValue_Vec2(        "Center",        [.5,.5] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput(17, nodeValue_Vec2(        "Shape",         [1,1]   ))
	newInput(14, nodeValue_Bool(        "Uniform ratio",  true   ));
	// inputs 18
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Output",		true],	0, 8, 
		["Gradient",	false], 1, 15, 5, 12, 9, 13, 7, 
		["Shape",		false], 2, 3, 10, 4, 11, 6, 17, 14, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 

		PROCESSOR_OVERLAY_CHECK
		
		var  dim = getSingleValue(0);
		var  typ = getSingleValue(2);
		var  rot = getSingleValue(3);
		var  pos = getSingleValue(6);
		
		InputDrawOverlay(inputs[ 6].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[16].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, current_data[0]));
		
		var _px = _x + pos[0] * _s;
		var _py = _y + pos[1] * _s;
		InputDrawOverlay(inputs[ 9].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny, typ == 0? rot : 0, dim[0] / 2, 1));
		
		if(typ != 1) InputDrawOverlay(inputs[ 3].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
		else         InputDrawOverlay(inputs[17].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny, 0, [ dim[0] / 2, dim[1] / 2 ]));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim  = _data[ 0];
		var _typ  = _data[ 2];
		var _cnt  = _data[ 6];
		var _lop  = _data[ 7];
		var _msk  = _data[ 8];
		var _uni  = _data[14];
		var _csca = _data[17];
		
		inputs[ 3].setVisible(_typ != 1);
		inputs[ 4].setVisible(_typ == 1);
		inputs[14].setVisible(_typ);
		inputs[17].setVisible(_typ == 1);
		
		var _sw = toNumber(_dim[0]);
		var _sh = toNumber(_dim[1]);
		
		_outSurf = surface_verify(_outSurf, _sw, _sh, attrDepth());
		surface_set_shader(_outSurf, sh_gradient);
			shader_set_gradient(_data[1], _data[15], _data[16], inputs[1]);
			
			shader_set_2("dimension",  _dim);
			
			shader_set_i("gradient_loop",  _lop);
			shader_set_2("center",   _cnt);
			shader_set_i("type",     _typ);
			shader_set_i("uniAsp",   _uni);
			shader_set_2("cirScale", _csca);
			
			shader_set_f_map("angle",  _data[3], _data[10], inputs[3]);
			shader_set_f_map("radius", _data[4], _data[11], inputs[4]);
			shader_set_f_map("shift",  _data[5], _data[12], inputs[5]);
			shader_set_f_map("scale",  _data[9], _data[13], inputs[9]);
			
			if(is_surface(_msk)) draw_surface_stretched_ext(_msk, 0, 0, _sw, _sh, c_white, 1);
			else                 draw_empty();
		surface_reset_shader();
		
		return _outSurf;
	}
}