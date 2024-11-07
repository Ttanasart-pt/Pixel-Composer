function Node_Color_replace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Replace Palette";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	newInput(1, nodeValue_Palette("Palette from", self, array_clone(DEF_PALETTE), "Color to be replaced."));
	
	newInput(2, nodeValue_Palette("Palette to", self, array_clone(DEF_PALETTE), "Palette to be replaced to."));
	
	newInput(3, nodeValue_Float("Threshold", self, 0.1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(4, nodeValue_Bool("Set others to black", self, false, "Set pixel that doesn't match any color in 'palette from' to black."));
	
	newInput(5, nodeValue_Bool("Multiply alpha", self, true));
	
	newInput(6, nodeValue_Bool("Hard replace", self, true, "Completely override pixel with new color instead of blending between it."));
	
	newInput(7, nodeValue_Surface("Mask", self));
	
	newInput(8, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(9, nodeValue_Bool("Active", self, true));
		active_index = 9;
	
	newInput(10, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
		
	__init_mask_modifier(7); // inputs 11, 12
	
	newInput(13, nodeValue_Enum_Scroll("Mode", self,  0, [ "Closet", "Random" ]));
	
	newInput(14, nodeValueSeed(self));
	
	input_display_list = [ 9, 10, 14, 
		["Surfaces",	 true], 0, 7, 8, 11, 12, 
		["Palette",		false], 1, 2, 
		["Comparison",	false], 13, 3, 5, 
		["Render",		false], 4, 6
	];
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {	
		var fr  = _data[ 1];
		var to  = _data[ 2];
		var tr  = _data[ 3];
		var in  = _data[ 4];
		var alp = _data[ 5];
		var hrd = _data[ 6];
		var msk = _data[ 7];
		var mde = _data[13];
		var sed = _data[14];
		
		var _colorFrom = paletteToArray(fr);
		var _colorTo   = paletteToArray(to);
		
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
			shader_set_i("inverted",	in);
			
			shader_set_i("useMask", is_surface(msk));
			shader_set_surface("mask", msk);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		if(!in) _outSurf = mask_apply(_data[0], _outSurf, _data[7], _data[8]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[10]);
		
		return _outSurf;
	}
}