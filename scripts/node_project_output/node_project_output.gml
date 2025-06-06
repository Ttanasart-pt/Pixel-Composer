function Node_Project_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Project Output";
	
	newInput(0, nodeValue_Surface( "Surface In" ));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Nodes
	
	project.outputNode = self;
	outputSurface      = noone;
	
	static update = function() {
		var _surf = inputs[0].getValue();
		
		if(!is_surface(_surf)) { outputSurface = noone; return; }
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		outputSurface = surface_verify(outputSurface, _sw, _sh);
		surface_set_shader(outputSurface);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		outputs[0].setValue(outputSurface);
	}
	
}