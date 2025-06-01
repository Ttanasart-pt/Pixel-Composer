#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Padding", "Fill Method > Toggle", "F", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 2); });
	});
#endregion

function Node_Padding(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Padding";
	dimension_index = -1;
	
	newActiveInput(4);
	
	////- =Surfaces
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- =Padding
	
	newInput(1, nodeValue_Padding("Padding", [0, 0, 0, 0])).setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	newInput(5, nodeValue_Enum_Button("Pad Mode",  0, [ "Pad out", "Pad to size" ]));
	newInput(6, nodeValue_Vec2("Target Dimension", DEF_SURF))
	newInput(7, nodeValue_Enum_Button("Horizontal Alignment",  0 , [ THEME.inspector_surface_halign, THEME.inspector_surface_halign, THEME.inspector_surface_halign]));
	newInput(8, nodeValue_Enum_Button("Vertical Alignment",  0 , [ THEME.inspector_surface_valign, THEME.inspector_surface_valign, THEME.inspector_surface_valign ]));
	
	////- =Filling
	
	newInput(2, nodeValue_Enum_Scroll("Fill Method",  0, [ "Empty", "Solid" ]));
	newInput(3, nodeValue_Color("Fill Color", ca_black));
		
	// input 9
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 4, 
		["Surfaces", true], 0, 
		["Padding", false], 5, 1, 6, 7, 8, 
		["Filling", false], 2, 3, 
	];
	
	attribute_surface_depth();
	
	draw_transforms = [];
	static drawOverlayTransform = function(_node) { return array_safe_get(draw_transforms, preview_index, noone); }
	
	static step = function() {
		var mode = getInputData(5);
		
		inputs[1].setVisible(mode == 0);
		
		inputs[6].setVisible(mode == 1);
		inputs[7].setVisible(mode == 1);
		inputs[8].setVisible(mode == 1);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var mode = _data[5];
		
		var surf    = _data[0];
		var padding	= _data[1];
		
		var dim 	= _data[6];
		var halign	= _data[7];
		var valign	= _data[8];
		
		var fill	= _data[2];
		var fillClr = _data[3];
		var cDep    = attrDepth();
		
		inputs[3].setVisible(fill);
		
		var ww	= surface_get_width_safe(surf);
		var hh	= surface_get_height_safe(surf);
		
		if(mode == 0) {
			var sw	= ww + padding[0] + padding[2];
			var sh	= hh + padding[1] + padding[3];
		
			if(sw > 1 && sh > 1) { 
				_outSurf = surface_verify(_outSurf, sw, sh, cDep);
			
				surface_set_target(_outSurf);
					if(fill == 0) {
						DRAW_CLEAR
						BLEND_OVERRIDE
					} else if(fill == 1)
						draw_clear_alpha(fillClr, color_get_alpha(fillClr));
				
					draw_surface_safe(surf, padding[2], padding[1]);
					BLEND_NORMAL
				surface_reset_target();
			}
			
			draw_transforms[_array_index] = [ padding[2], padding[1], 1, 1, 0];
			
		} else if(mode == 1) { 
			_outSurf = surface_verify(_outSurf, dim[0], dim[1], cDep);
			
			surface_set_target(_outSurf);
			if(fill == 0) {
				DRAW_CLEAR
				BLEND_OVERRIDE
			} else if(fill == 1)
				draw_clear_alpha(fillClr, color_get_alpha(fillClr));
			
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
			
			draw_surface_safe(surf, sx, sy);
			BLEND_NORMAL
			surface_reset_target();
			
			draw_transforms[_array_index] = [ sx, sy, 1, 1, 0 ];
		}
		
		return _outSurf;
	}
}