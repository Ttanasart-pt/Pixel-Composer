function Node_Cellular(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Cellular Noise";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ DEF_SURF_W / 2, DEF_SURF_H / 2])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4)
		.setMappable(11);
	
	inputs[| 3] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 3].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 4] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Point", "Edge", "Cell", "Crystal" ]);
	
	inputs[| 5] = nodeValue("Contrast", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 4, 0.01] });
	
	inputs[| 6] = nodeValue("Pattern", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Tiled", "Uniform", "Radial" ]);
	
	inputs[| 7] = nodeValue("Middle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0., 1., 0.01] });
	
	inputs[| 8] = nodeValue("Radial scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1., 10., 0.01] });
	
	inputs[| 9] = nodeValue("Radial shatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-10., 10., 0.01] })
		.setVisible(false);
	
	inputs[| 10] = nodeValue("Colored", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	//////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 11] = nodeValueMap("Scale map", self);
	
	//////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 12] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	input_display_list = [
		["Output",		false], 0, 
		["Noise",		false], 4, 6, 3, 1, 12, 2, 11, 
		["Radial",		false], 8, 9,
		["Rendering",	false], 5, 7, 10, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var hv   = inputs[| 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() { #region
		inputs[| 2].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim  = _data[0];
		var _pos  = _data[1];
		var _tim  = _data[3];
		var _type = _data[4];
		var _con  = _data[5];
		var _pat  = _data[6];
		var _mid  = _data[7];
		
		inputs[|  8].setVisible(_pat ==  2);
		inputs[|  9].setVisible(_pat ==  2);
		inputs[| 10].setVisible(_type == 2);
		
		var _rad = _data[ 8];
		var _sht = _data[ 9];
		var _col = _data[10];
		var _rot = _data[12];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		switch(_type) {
			case 0 : shader = sh_cell_noise;			break;
			case 1 : shader = sh_cell_noise_edge;		break;
			case 2 : shader = sh_cell_noise_random;		break;
			case 3 : shader = sh_cell_noise_crystal;	break;
		}
		
		surface_set_shader(_outSurf, shader);
			shader_set_f("dimension",		_dim);
			shader_set_f("seed",			_tim);
			shader_set_2("position",		_pos);
			shader_set_f_map("scale",		_data[2], _data[11], inputs[| 2]);
			shader_set_f("contrast",		_con);
			shader_set_f("middle",			_mid);
			shader_set_f("radiusScale",		_rad);
			shader_set_f("radiusShatter",	_sht);
			shader_set_i("pattern",			_pat);
			shader_set_i("colored",			_col);
			shader_set_f("rotation",		degtorad(_rot));
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		return _outSurf;
	}
}