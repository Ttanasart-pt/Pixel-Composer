function Node_create_Blend(_x, _y, _group = -1, _param = "") {
	var node = new Node_Blend(_x, _y, _group);
	return node;
}

function Node_Blend(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Blend";
	
	inputs[| 0] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, DEF_SURFACE);
	inputs[| 1] = nodeValue("Foreground", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, DEF_SURFACE);
	
	inputs[| 2] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, BLEND_TYPES );
	
	inputs[| 3] = nodeValue("Opacity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	inputs[| 4] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 5] = nodeValue("Fill mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "None", "Stretch", "Tile" ]);
	
	inputs[| 6] = nodeValue("Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Background", "Forground", "Mask", "Maximum", "Constant" ])
		.rejectArray();
	
	inputs[| 7] = nodeValue("Constant dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 8] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 8;
		
	inputs[| 9] = nodeValue("Preserve alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
		
	inputs[| 10] = nodeValue("Horizontal Align", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ THEME.inspector_surface_halign, THEME.inspector_surface_halign, THEME.inspector_surface_halign]);
		
	inputs[| 11] = nodeValue("Vertical Align", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ THEME.inspector_surface_valign, THEME.inspector_surface_valign, THEME.inspector_surface_valign]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 8, 
		["Surfaces",	 true],	0, 1, 4, 6, 7,
		["Blend",		false], 2, 3, 9,
		["Transform",	false], 5, 10, 11, 
	]
	
	temp = surface_create(1, 1);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _back	 = _data[0];
		var _fore	 = _data[1];
		var _type	 = _data[2];
		var _opacity = _data[3];
		var _mask	 = _data[4];
		var _tile	 = _data[5];
		
		var _outp	 = _data[6];
		var _out_dim = _data[7];
		var _pre_alp = _data[9];
		
		var _halign = _data[10];
		var _valign = _data[11];
		
		inputs[| 7].setVisible(_outp == 4);
		var ww = 1, hh = 1;
		var _foreDraw = _fore;
		
		inputs[| 10].setVisible(_tile == 0);
		inputs[| 11].setVisible(_tile == 0);
		
		if(_tile == 0 && is_surface(_fore)) {
			ww = surface_get_width(_back);
			hh = surface_get_height(_back);
			
			var fw = surface_get_width(_fore);
			var fh = surface_get_height(_fore);
			
			temp = surface_verify(temp, ww, hh);
			_foreDraw = temp;
			
			var sx = 0;
			var sy = 0;
			
			switch(_halign) {
				case 0 : sx = 0; break;
				case 1 : sx = ww / 2 - fw / 2; break;
				case 2 : sx = ww - fw; break;
			}
			
			switch(_valign) {
				case 0 : sy = 0; break;
				case 1 : sy = hh / 2 - fh / 2; break;
				case 2 : sy = hh - fh; break;
			}
			
			surface_set_target(temp);
			draw_clear_alpha(0, 0);
			BLEND_ALPHA
				draw_surface(_fore, sx, sy);
			BLEND_NORMAL
			surface_reset_target();
		}
		
		switch(_outp) {
			case 0 :
				ww = surface_get_width(_back);
				hh = surface_get_height(_back);
				break;
			case 1 :
				if(is_surface(_foreDraw)) {
					ww = surface_get_width(_foreDraw);
					hh = surface_get_height(_foreDraw);
				}
				break;
			case 2 :
				ww = surface_get_width(_mask);
				hh = surface_get_height(_mask);
				break;
			case 3 :
				ww = max(surface_get_width(_back), is_surface(_fore)? surface_get_width(_fore) : 1, surface_get_width(_mask));
				hh = max(surface_get_height(_back), is_surface(_fore)? surface_get_height(_fore) : 1, surface_get_height(_mask));
				break;
			case 4 :
				ww = _out_dim[0];
				hh = _out_dim[1];
				break;
		}
		
		_outSurf = surface_verify(_outSurf, ww, hh);
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		draw_surface_blend(_back, _foreDraw, _type, _opacity, _pre_alp, _mask, max(0, _tile - 1));
		surface_reset_target();
		
		return _outSurf;
	}
}