function Node_Sky(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Sky";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Vec2("Offset", self, [ 0, 0 ]));
	
	newInput(2, nodeValue_Vec2("Scale", self, [ 1, 1 ]));
	
	newInput(3, nodeValue_Enum_Scroll("Model", self, 0, [ "Preetham", "Basic scattering", "Hosek" ]));
	
	newInput(4, nodeValue_Float("Turbidity", self, 2));
	
	newInput(5, nodeValue_Vec2("Sun", self, [ .2, .2 ]))
	    .setUnitRef(function(index) /*=>*/ {return getDimension(index)}, VALUE_UNIT.reference);
	
	newInput(6, nodeValue_Float("Sun radius", self, 500));
	
	newInput(7, nodeValue_Float("Sun radiance", self, 20));
	
	newInput(8, nodeValue_Float("Albedo", self, 1));
	
	newInput(9, nodeValue_Enum_Scroll("Coordinate", self, 0, [ "Rectangular", "Polar" ]));
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
	   // ["Transform", false], 1, 2, 
		["Sky",	   false], 3, 4, 8, 
		["Sun",    false], 5, 6, 7, 
		//["Render", false], 9, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		
		var hv = inputs[5].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		var _sca = _data[2];
		
		var _mod    = _data[3];
		var _tur    = _data[4];
		var _sun    = _data[5];
		var _sunRad = _data[6];
		var _sunRdd = _data[7];
		var _alb    = _data[8];
		var _map    = _data[9];
		
		if(_mod == 0) {
		    inputs[4].setVisible( true);
		    inputs[6].setVisible(false);
		    inputs[7].setVisible(false);
		    inputs[8].setVisible(false);
		    
    		surface_set_shader(_outSurf, sh_sky_preetham);
    			DRAW_CLEAR
    			
    			shader_set_2("dimension",   _dim);
    			shader_set_2("sunPosition", _sun);
    			shader_set_f("turbidity",   _tur);
    			shader_set_i("mapping",     _map);
    			
    			draw_empty();
    		surface_reset_shader();
    		
		} else if(_mod == 1) {
		    inputs[4].setVisible(false);
		    inputs[6].setVisible( true);
		    inputs[7].setVisible( true);
		    inputs[8].setVisible(false);
		    
    		surface_set_shader(_outSurf, sh_sky_scattering);
    			DRAW_CLEAR
    			
    			shader_set_2("dimension",   _dim);
    			shader_set_2("sunPosition", _sun);
    			shader_set_f("sunRadius",   _sunRad);
    			shader_set_f("sunRadiance", _sunRdd);
    			shader_set_i("mapping",     _map);
    			
    			draw_empty();
    		surface_reset_shader();
    		
		} else if(_mod == 2) {
		    inputs[4].setVisible(false);
		    inputs[6].setVisible(false);
		    inputs[7].setVisible(false);
		    inputs[8].setVisible(false);
		    
    		surface_set_shader(_outSurf, sh_sky_hosek);
    			DRAW_CLEAR
    			
    			shader_set_2("dimension",   _dim);
    			shader_set_2("sunPosition", _sun);
    			shader_set_f("turbidity",   3);
    			shader_set_f("albedo",      1);
    			shader_set_i("mapping",     _map);
    			
    			draw_empty();
    		surface_reset_shader();
		}
		
		return _outSurf;
	}
}