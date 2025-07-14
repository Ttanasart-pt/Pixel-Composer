function Node_Color_replace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Replace Palette";
	
	newActiveInput(9);
	newInput(10, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(7, nodeValue_Surface( "Mask"       ));
	newInput(8, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(7, 11);
	
	////- =Palettes
	newInput(1, nodeValue_Palette( "From", array_clone(DEF_PALETTE) ));
	newInput(2, nodeValue_Palette( "To",   array_clone(DEF_PALETTE) ));
	
	////- =Comparison
	newInput(13, nodeValue_Enum_Scroll( "Mode", 0, [ "Closest", "Random" ] ));
	newInput(14, nodeValueSeed());
	newInput( 3, nodeValue_Slider( "Threshold",      .1   ));
	newInput( 5, nodeValue_Bool(   "Multiply alpha", true ));
	
	////- =Replace Others
	newInput( 4, nodeValue_Bool(  "Replace Other Colors", false    ));
	newInput(15, nodeValue_Color( "Target Color",         ca_black ));
	
	////- =Render
	newInput(6, nodeValue_Bool("Hard replace", true, "Completely override pixel with new color instead of blending between it."));
	
	input_display_list = [ 9, 10, 
		["Surfaces",        true   ], 0, 7, 8, 11, 12, 
		["Palettes",       false   ], 1, 2, 
		["Comparison",     false   ], 13, 14, 3, 5, 
		["Replace Others", false, 4], 15, 
		["Render",         false   ],  6
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Nodes
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {	
		var fr  = _data[ 1];
		var to  = _data[ 2];
		var tr  = _data[ 3];
		var alp = _data[ 5];
		var hrd = _data[ 6];
		var msk = _data[ 7];
		var mde = _data[13];
		var sed = _data[14];
		
		var repo = _data[ 4];
		var oclr = _data[15];
		
		var _colorFrom = paletteToArray(fr);
		var _colorTo   = paletteToArray(to);
		
		inputs[14].setVisible(mde == 1);
		
		surface_set_shader(_outSurf, sh_palette_replace);
			shader_set_f("colorFrom",     _colorFrom);
			shader_set_i("colorFrom_amo", array_length(fr));
			shader_set_f("colorTo",		  _colorTo);
			shader_set_i("colorTo_amo",   array_length(to));
			
			shader_set_f("seed",	    sed);
			shader_set_i("mode",	    mde);
			shader_set_i("alphacmp",	alp);
			shader_set_i("hardReplace", hrd);
			shader_set_f("treshold",	tr);
			
			shader_set_i("replaceOthers",    repo);
			shader_set_color("replaceColor", oclr);
			
			shader_set_i("useMask", is_surface(msk));
			shader_set_surface("mask", msk);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[7], _data[8]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[10]);
		
		return _outSurf;
	}
}