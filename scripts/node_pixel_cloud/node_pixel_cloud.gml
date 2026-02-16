function Node_Pixel_Cloud(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Cloud";
	
	newActiveInput(8);
	
	////- =Input
	newInput(0, nodeValue_Surface("Surface In"));
	newInput(1, nodeValueSeed());
	
	////- =Movement
	newInput(5, nodeValue_Float(   "Distance",  1 ));
	newInput(2, nodeValue_Slider(  "Strength", .1, [ 0, 2, 0.01] )).setHotkey("S");
	newInput(3, nodeValue_Surface( "Strength map" ));
	
	////- =Color
	newInput(4, nodeValue_Gradient( "Color over lifetime",  gra_white)).setMappable(9);
	newInput(6, nodeValue_Curve(    "Alpha over lifetime",  CURVE_DEF_11 ));
	newInput(7, nodeValue_Slider(   "Random blending",     .1 ));
	// input 10
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 8, 
		["Input",     true], 0, 1,
		["Movement", false], 5, 2, 3, 
		["Color",     true], 4, 9, 6, 7
	]
	
	////- Node
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, 0, _dim[0] * 4));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		
		var _surf = _data[0];
		var _seed = _data[1];
		
		var _dist = _data[5];
		var _strn = _data[2];
		var _smap = _data[3];
		
		var _alph = _data[6];
		var _rand = _data[7];
		
		surface_set_shader(_outSurf, sh_pixel_cloud);
			shader_set_i("sampleMode", getAttribute("oversample"));
			shader_set_f("seed",     _seed);
			shader_set_f("strength", _strn);
			shader_set_f("dist",     _dist);
			
			shader_set_i("useMap", is_surface(_smap));
			shader_set_surface("strengthMap", _smap);
			
			shader_set_gradient(_data[4], _data[9], _data[10], inputs[4]);
			
			shader_set_curve("alpha" ,   _alph);
			shader_set_f("randomAmount", _rand);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		return _outSurf;
	}
}