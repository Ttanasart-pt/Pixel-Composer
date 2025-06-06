function Node_Layer_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Layer Output";
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Nodes
	
	array_push(project.globalLayer_output, self);
	
	static isActiveDynamic = function() /*=>*/ {return false};
	
	static update = function() {
		project.globalLayer_compose();
		
		var _outSurf = outputs[0].getValue();
		var _surf    = project.globalLayer_surface;
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		_outSurf = surface_verify(_outSurf, _sw, _sh);
		surface_set_shader(_outSurf);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		outputs[0].setValue(_outSurf);
	}
	
	////- Render
	
	static getNodeFrom = function() { return project.globalLayer_nodes; }
	
}