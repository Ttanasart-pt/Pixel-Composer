function Node_Padding(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Padding";
	dimension_index = -1;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0, 0, 0])
		.setDisplay(VALUE_DISPLAY.padding)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Fill method", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Solid" ]);
	
	inputs[| 3] = nodeValue("Fill color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 4] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 4;
		
	inputs[| 5] = nodeValue("Pad mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Pad out", "Pad to size" ]);
	
	inputs[| 6] = nodeValue("Target dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector)
	
	inputs[| 7] = nodeValue("Horizontal alignment", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ THEME.inspector_surface_halign, THEME.inspector_surface_halign, THEME.inspector_surface_halign]);
	
	inputs[| 8] = nodeValue("Vertical alignment", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ THEME.inspector_surface_valign, THEME.inspector_surface_valign, THEME.inspector_surface_valign ]);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 4, 
		["Output",   true], 0, 
		["Padding", false], 5, 1, 6, 7, 8, 
		["Filling", false], 2, 3, 
	];
	
	attribute_surface_depth();
	
	static step = function() {
		var mode = getInputData(5);
		
		inputs[| 1].setVisible(mode == 0);
		
		inputs[| 6].setVisible(mode == 1);
		inputs[| 7].setVisible(mode == 1);
		inputs[| 8].setVisible(mode == 1);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var mode = _data[5];
		
		var padding	= _data[1];
		
		var dim 	= _data[6];
		var halign	= _data[7];
		var valign	= _data[8];
		
		var fill	= _data[2];
		var fillClr = _data[3];
		var cDep    = attrDepth();
		
		inputs[| 3].setVisible(fill);
		
		var ww	= surface_get_width_safe(_data[0]);
		var hh	= surface_get_height_safe(_data[0]);
		
		if(mode == 0) {
			var sw	= ww + padding[0] + padding[2];
			var sh	= hh + padding[1] + padding[3];
		
			if(sw > 1 && sh > 1) { 
				_outSurf = surface_verify(_outSurf, sw, sh, cDep);
			
				surface_set_target(_outSurf);
					if(fill == 0) {
						DRAW_CLEAR
						BLEND_OVERRIDE;
					} else if(fill == 1)
						draw_clear_alpha(fillClr, 1);
				
					draw_surface_safe(_data[0], padding[2], padding[1]);
					BLEND_NORMAL;
				surface_reset_target();
			}
		} else if(mode == 1) { 
			_outSurf = surface_verify(_outSurf, dim[0], dim[1], cDep);
			
			surface_set_target(_outSurf);
			if(fill == 0) {
				DRAW_CLEAR
				BLEND_OVERRIDE;
			} else if(fill == 1)
				draw_clear_alpha(fillClr, 1);
			
			var sx = 0;
			var sy = 0;
			
			switch(halign) {
				case fa_left :   sx = 0;				 break;
				case fa_center : sx = (dim[0] - ww) / 2; break;
				case fa_right :  sx =  dim[0] - ww;		 break;
			}
			
			switch(valign) {
				case fa_top :    sy = 0;				 break;
				case fa_center : sy = (dim[1] - hh) / 2; break;
				case fa_bottom:  sy =  dim[1] - hh;		 break;
			}
			
			draw_surface_safe(_data[0], sx, sy);
			BLEND_NORMAL;
			surface_reset_target();
		}
		
		return _outSurf;
	}
}