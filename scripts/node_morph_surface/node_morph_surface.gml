function Node_Morph_Surface(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Morph Surface";
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface from" ));
	newInput(1, nodeValue_Surface( "Surface to"   ));
	
	////- =Morph
	newInput(2, nodeValue_Slider( "Morph Amount", 0 )).setHotkey("S");
	newInput(3, nodeValue_Slider( "Threshold",   .1 )).setHotkey("T");
	// input 4
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		["Surfaces", true],	0, 1,
		["Morph",	false],	2, 3, 
	];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my,  0, _dim[0] / 2));
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, 90, _dim[1] / 2));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var sFrom = _data[0];
		var sTo   = _data[1];
		var amo   = _data[2];
		var thres = _data[3];
		
		if(!is_surface(sFrom)) return _outSurf;
		if(!is_surface(sTo)) return _outSurf;
		
		var _dim = surface_get_dimension(sFrom);
		
		surface_set_shader(_outSurf, sh_morph_surface);
			shader_set_interpolation(sFrom);
			shader_set_s("sFrom",     sFrom );
			shader_set_s("sTo",       sTo   );
			shader_set_2("dimension", _dim  );
			shader_set_f("amount",    amo   );
			shader_set_f("threshold", thres );
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf;
	}
}