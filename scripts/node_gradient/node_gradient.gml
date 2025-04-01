#region create

	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Gradient", "Type > Toggle",     "T", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 3); });
		addHotkey("Node_Gradient", "Angle > Rotate CCW","R", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[3].setValue((_n.inputs[3].getValue() + 90) % 360); });
		addHotkey("Node_Gradient", "Gradient > Invert", "I", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR 
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
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Gradient("Gradient", self, new gradientObject([ cola(c_black), cola(c_white) ])))
		.setMappable(15);
	
	newInput(2, nodeValue_Enum_Scroll("Type", self,  0, [ new scrollItem("Linear",   s_node_gradient_type, 0),
												          new scrollItem("Circular", s_node_gradient_type, 1),
												          new scrollItem("Radial",   s_node_gradient_type, 2) ]));
	
	newInput(3, nodeValue_Rotation("Angle", self, 0))
		.setMappable(10);

	newInput(4, nodeValue_Float("Radius", self, .5))
		.setMappable(11);
		
	newInput(5, nodeValue_Float("Shift", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-2, 2, 0.01] })
		.setMappable(12);
	
	newInput(6, nodeValue_Vec2("Center", self, [ 0.5, 0.5 ]))
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	newInput(7, nodeValue_Enum_Button("Loop", self,  0, [ "None", "Loop", "Pingpong" ]));
	
	newInput(8, nodeValue_Surface("Mask", self));
	
	newInput(9, nodeValue_Float("Scale", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 5, 0.01] })
		.setMappable(13);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(10, nodeValueMap("Angle map", self));
	
	newInput(11, nodeValueMap("Radius map", self));
	
	newInput(12, nodeValueMap("Shift map", self));
	
	newInput(13, nodeValueMap("Scale map", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(14, nodeValue_Bool("Uniform ratio", self, true));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(15, nodeValueMap("Gradient map", self));
	
	newInput(16, nodeValueGradientRange("Gradient map range", self, inputs[1]));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(17, nodeValue_Vec2("Shape", self, [ 1, 1 ]))
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Output",		true],	0, 8, 
		["Gradient",	false], 1, 15, 5, 12, 9, 13, 7, 
		["Shape",		false], 2, 3, 10, 4, 11, 6, 17, 14, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		var _hov = false;
		var  dim = getSingleValue(0);
		var  typ = getSingleValue(2);
		var  rot = getSingleValue(3);
		var  pos = getSingleValue(6);
		
		var a = inputs[ 6].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);                  active &= !a; _hov |= a;
		var a = inputs[16].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, current_data[0]); active &= !a; _hov |= a;
		
		var _px = _x + pos[0] * _s;
		var _py = _y + pos[1] * _s;
		var a = inputs[ 9].drawOverlay(hover, active, _px, _py, _s, _mx, _my, _snx, _sny, typ == 0? rot : 0, dim[0] / 2, 1); active &= !a; _hov |= a;
		
		if(typ != 1) {
			var a = inputs[ 3].drawOverlay(hover, active, _px, _py, _s, _mx, _my, _snx, _sny); active &= !a; _hov |= a;
		} else {
			var a = inputs[17].drawOverlay(hover, active, _px, _py, _s, _mx, _my, _snx, _sny, 0, [ dim[0] / 2, dim[1] / 2 ]); active &= !a; _hov |= a;
		}
		
		return _hov;
	}
	
	static step = function() {
		var _typ = getInputData(2);
		
		inputs[ 3].setVisible(_typ != 1);
		inputs[ 4].setVisible(_typ == 1);
		inputs[14].setVisible(_typ);
		inputs[17].setVisible(_typ == 1);
		
		inputs[1].mappableStep();
		inputs[3].mappableStep();
		inputs[4].mappableStep();
		inputs[5].mappableStep();
		inputs[9].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim  = _data[0];
		var _typ  = _data[2];
		var _cnt  = _data[6];
		var _lop  = _data[7];
		var _msk  = _data[8];
		var _uni  = _data[14];
		var _csca = _data[17];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_gradient);
			shader_set_gradient(_data[1], _data[15], _data[16], inputs[1]);
			
			shader_set_2("dimension",  _dim);
			
			shader_set_i("gradient_loop",  _lop);
			shader_set_f("center",   _cnt[0] / _dim[0], _cnt[1] / _dim[1]);
			shader_set_i("type",     _typ);
			shader_set_i("uniAsp",   _uni);
			shader_set_2("cirScale", _csca);
			
			shader_set_f_map("angle",  _data[3], _data[10], inputs[3]);
			shader_set_f_map("radius", _data[4], _data[11], inputs[4]);
			shader_set_f_map("shift",  _data[5], _data[12], inputs[5]);
			shader_set_f_map("scale",  _data[9], _data[13], inputs[9]);
			
			if(is_surface(_msk)) draw_surface_stretched_ext(_msk, 0, 0, _dim[0], _dim[1], c_white, 1);
			else                 draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}