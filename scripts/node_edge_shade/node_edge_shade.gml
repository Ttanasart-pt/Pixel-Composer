function Node_Edge_Shade(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Edge Shade";
	
	newActiveInput(1);
	
	////- =Surfaces
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- =Effect
	
	newInput(2, nodeValue_Gradient("Colors", gra_black_white)).setMappable(3);
	
	// input 5
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		["Surfaces",	false], 0, 
		["Effects",		false], 2, 3, 4, 
	]
	
	temp_surface = array_create(3);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		
		var _dim = surface_get_dimension(_surf);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		surface_set_shader(temp_surface[0], sh_edge_shade_convert);
			shader_set_f("dimension",  _dim);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		surface_set_shader(temp_surface[1], sh_edge_shade_extract);
			shader_set_f("dimension",  _dim);
			
			draw_surface_safe(temp_surface[0]);
		surface_reset_shader();
		
		surface_set_shader(_outSurf, sh_edge_shade_apply);
			shader_set_f("dimension",  _dim);
			shader_set_gradient(_data[2], _data[3], _data[4], inputs[2]);
			
			draw_surface_safe(temp_surface[1]);
		surface_reset_shader();
		
		return _outSurf;
	}
}