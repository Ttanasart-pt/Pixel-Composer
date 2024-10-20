function Node_Sky(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Sky";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Enum_Scroll("Model", self, 0, [ "Preetham" ]));
	
	newInput(2, nodeValue_Float("Turbidity", self, 2));
	
	newInput(3, nodeValue_Float("Azimuth", self, 0))
	    .setDisplay(VALUE_DISPLAY.slider, { range: [ -180, 180, 1 ] });
	
	newInput(4, nodeValue_Float("Inclination", self, 0))
	    .setDisplay(VALUE_DISPLAY.slider, { range: [ -180, 180, 1 ] });
	
	newInput(5, nodeValue_Vec2("Scale", self, [ 1, 1 ]));
	
	newInput(6, nodeValue_Vec2("Offset", self, [ 0, 0 ]));
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
	    ["Transform", false], 6, 5, 
		["Sky",	      false], 1, 2, 3, 4, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		
		var hv = inputs[6].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _mod = _data[1];
		var _tur = _data[2];
		var _azi = _data[3];
		var _inc = _data[4];
		var _sca = _data[5];
		var _pos = _data[6];
		
		if(_mod == 0) {
    		surface_set_shader(_outSurf, sh_sky_preetham);
    			DRAW_CLEAR
    			
    			shader_set_2("dimension",   _dim);
    			shader_set_2("position",    _pos);
    			shader_set_2("scale",       _sca);
    			shader_set_f("turbidity",   _tur);
    			shader_set_f("azimuth",     degtorad(_azi));
    			shader_set_f("inclination", degtorad(_inc));
    			
    			draw_empty();
    		surface_reset_shader();
		}
		
		return _outSurf;
	}
}