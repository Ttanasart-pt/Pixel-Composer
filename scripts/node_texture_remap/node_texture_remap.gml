function Node_Texture_Remap(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Texture Remap";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newInput(1, nodeValue_Surface("RG Map")).setTooltip("Displacement map where red retermine the X position, and green determine the Y position.");
	
	newActiveInput(2);
	
	newInput(3, nodeValue_Enum_Button("Dimension Source",  0, [ "Surface", "RG Map" ]));
	
	newInput(4, nodeValue_Bool("Array Index", false));
	
	newInput(5, nodeValue_Int("Index Start", 0));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 2,
		["Surfaces", false], 0, 1, 3, 
		["Index",    false, 4], 5, 
	]
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static processData_prebatch  = function() { 
		shader_preset_interpolation(sh_texture_remap);  
		
		var _arr = getSingleValue(4);
		inputs[0].setArrayDepth(_arr);
	}
	
	static processData_postbatch = function() { shader_postset_interpolation(); }
	
	static processData = function(_outSurf, _data, _array_index) {
		if(!is_surface(_data[1])) return _outSurf;
		
		var _dim = _data[3];
		var _arr = _data[4];
		var _ist = _data[5];
		
		var _sw = surface_get_width(_data[_dim]);
		var _sh = surface_get_height(_data[_dim]);
		
		var _surf = _data[0];
		if(!is_array(_surf)) _surf = [ _surf ];
		
		_outSurf = surface_verify(_outSurf, _sw, _sh);
		
		surface_set_shader(_outSurf, noone);
			for( var i = 0, n = array_length(_surf); i < n; i++ ) {
				var _s = _surf[i];
				
				if(_arr && i < _ist) {
					draw_surface_stretched_safe(_s, 0, 0, _sw, _sh);
					break;
				}
				
				shader_set(sh_texture_remap);
					shader_set_interpolation(_s);
					shader_set_surface("map", _data[1]);
					shader_set_i("useIndex", _arr);
					shader_set_f("index", (_ist + i) / 255);
					
					draw_surface_stretched_safe(_s, 0, 0, _sw, _sh);
				shader_reset();
			}
		surface_reset_shader();
		
		return _outSurf;
	}
}