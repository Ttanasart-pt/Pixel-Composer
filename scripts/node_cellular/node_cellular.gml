#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Cellular", "Type > Toggle",         "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[ 4].setValue((_n.inputs[ 4].getValue() + 1) % 4); });
		addHotkey("Node_Cellular", "Pattern > Toggle",      "P", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[ 6].setValue((_n.inputs[ 6].getValue() + 1) % 3); });
		addHotkey("Node_Cellular", "Colored > Toggle",      "C", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[10].setValue((_n.inputs[10].getValue() + 1) % 2); });
		addHotkey("Node_Cellular", "Rotation > Rotate CCW", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[12].setValue((_n.inputs[12].getValue() + 90) % 360); });
	});
#endregion

function Node_Cellular(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Cellular Noise";
	
	////- =Output
	
	newInput( 0, nodeValue_Dimension());
	newInput(13, nodeValue_Surface( "Mask" ));
	
	////- =Noise
	
	newInput( 4, nodeValue_Enum_Scroll( "Type",    0, [ "Point", "Edge", "Cell", "Crystal" ]));
	newInput( 6, nodeValue_Enum_Button( "Pattern", 0, [ "Tiled", "Uniform", "Radial" ]));
	newInput( 3, nodeValueSeed());
	newInput(14, nodeValue_Rotation( "Phase", 0 ));
	
	////- =Transform
	
	newInput( 1, nodeValue_Vec2(     "Position", [ DEF_SURF_W / 2, DEF_SURF_H / 2])).setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	newInput(12, nodeValue_Rotation( "Rotation", 0 ));
	newInput( 2, nodeValue_Float(    "Scale",    4 )).setMappable(11);
	
	////- =Radial
	
	newInput( 8, nodeValue_Slider( "Radial scale",   2, [  1, 10, 0.01] ));
	newInput( 9, nodeValue_Slider( "Radial shatter", 0, [-10, 10, 0.01] )).setVisible(false);
	
	////- =Rendering
	
	newInput( 5, nodeValue_Slider( "Contrast",  1, [0, 4, 0.01] ));
	newInput( 7, nodeValue_Slider( "Middle",   .5, [0, 1, 0.01] ));
	newInput(10, nodeValue_Bool(   "Colored",  false ))
	
	// input 15
	
	input_display_list = [
		["Output",    false], 0, 13, 
		["Noise",     false], 4, 6, 3, 14, 
		["Transform", false], 1, 12, 2, 11, 
		["Radial",    false], 8, 9,
		["Rendering", false], 5, 7, 10, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim  = _data[0];
		var _pos  = _data[1];
		var _tim  = _data[3];
		var _type = _data[4];
		var _con  = _data[5];
		var _pat  = _data[6];
		var _mid  = _data[7];
		
		inputs[ 8].setVisible(_pat  == 2);
		inputs[ 9].setVisible(_pat  == 2);
		inputs[10].setVisible(_type == 2);
		inputs[14].setVisible(_type != 3);
		
		var _rad = _data[ 8];
		var _sht = _data[ 9];
		var _col = _data[10];
		var _rot = _data[12];
		var _phs = _data[14];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		switch(_type) {
			case 0 : shader = sh_cell_noise;			break;
			case 1 : shader = sh_cell_noise_edge;		break;
			case 2 : shader = sh_cell_noise_random;		break;
			case 3 : shader = sh_cell_noise_crystal;	break;
		}
		
		surface_set_shader(_outSurf, shader);
			shader_set_f("dimension",     _dim);
			shader_set_f("seed",          _tim);
			shader_set_f("phase",         _phs / 360);
			
			shader_set_2("position",      _pos);
			shader_set_f_map("scale",     _data[2], _data[11], inputs[2]);
			shader_set_f("contrast",      _con);
			shader_set_f("middle",        _mid);
			shader_set_f("radiusScale",   _rad);
			shader_set_f("radiusShatter", _sht);
			shader_set_i("pattern",       _pat);
			shader_set_i("colored",       _col);
			shader_set_f("rotation",      degtorad(_rot));
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}