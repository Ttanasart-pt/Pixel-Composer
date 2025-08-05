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
	newInput(4, nodeValue_Gradient( "Color over lifetime",  new gradientObject(ca_white))).setMappable(9);
	newInput(6, nodeValue_Curve(    "Alpha over lifetime",  CURVE_DEF_11 ));
	newInput(7, nodeValue_Slider(   "Random blending",     .1 ));
	
	// input 10
	
	input_display_list = [ 8, 
		["Input",     true], 0, 1,
		["Movement", false], 5, 2, 3, 
		["Color",     true], 4, 9, 6, 7
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		
		surface_set_shader(_outSurf, sh_pixel_cloud);
			shader_set_f("seed"    , _data[1]);
			shader_set_f("strength", _data[2]);
			shader_set_f("dist"    , _data[5]);
			
			shader_set_i("useMap", is_surface(_data[3]));
			shader_set_surface("strengthMap", _data[3]);
			
			shader_set_gradient(_data[4], _data[9], _data[10], inputs[4]);
			
			shader_set_curve("alpha" , _data[6]);
			shader_set_f("randomAmount", _data[7]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	}
}