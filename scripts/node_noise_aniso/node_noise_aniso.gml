#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Noise_Aniso", "Render Mode > Toggle",  "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 2); });
		addHotkey("Node_Noise_Aniso", "Rotation > Rotate CCW", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue((_n.inputs[4].getValue() + 90) % 360); });
	});
#endregion

function Node_Noise_Aniso(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Anisotropic Noise";
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput(13, nodeValue_Surface( "UV Map"     ));
	newInput(14, nodeValue_Slider(  "UV Mix", 1  ));
	newInput(11, nodeValue_Surface( "Mask"       ));
	
	////- =Noise
	newInput( 2, nodeValueSeed());
	newInput( 1, nodeValue_Float(    "X Amount",  2     )).setMappable(6);
	newInput( 5, nodeValue_Float(    "Y Amount",  16    )).setMappable(7);
	newInput( 3, nodeValue_Vec2(     "Position", [0,0]  )).setHotkey("G").setUnitSimple();
	newInput( 4, nodeValue_Rotation( "Rotation",  0     )).setHotkey("R").setMappable(8);
	newInput(12, nodeValue_Bool(     "Tile",      false ));
	
	////- =Render
	newInput( 9, nodeValue_Enum_Scroll( "Render Mode", 0, [ "Blend", "Waterfall" ] ));
	newInput(10, nodeValueSeed());
	// input 15
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		[ "Output", false ],  0, 13, 14, 11, 
		[ "Noise",  false ],  2,  1,  6,  5,  7,  3,  4,  8, 12, 
		[ "Render", false ],  9, 10, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _pos = getInputSingle(3);
		var  px  = _x + _pos[0] * _s;
		var  py  = _y + _pos[1] * _s;
		
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim = _data[0];
		var _pos = _data[3];
		var _mod = _data[9];
		
		inputs[10].setVisible(_mod == 0);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_ani_noise);
			shader_set_uv(_data[13], _data[14]);
			
			shader_set_2("dimension",   _dim);
			shader_set_f("position",	_pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f("seed",		_data[2]);
			shader_set_f("colrSeed",	_data[10]);
			shader_set_i("tile",	    _data[12]);
			
			shader_set_f_map("noiseX",  _data[1], _data[6], inputs[1]);
			shader_set_f_map("noiseY",  _data[5], _data[7], inputs[5]);
			shader_set_f_map("angle",	_data[4], _data[8], inputs[4]);
			
			shader_set_i("mode",		_mod);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}