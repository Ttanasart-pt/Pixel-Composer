function Node_Project_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Project Output";
	
	newInput( 0, nodeValue_Surface( "Surface In" )).setRequired();
	
	newInput( 1, nodeValue_Bool( "Animated", false ));
	// 2
	
	newOutput( 0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 1, ]
	
	////- Nodes
	
	project.outputNode = self;
	outputSurface      = noone;
	
	animated = false;
	
	rendering   = false;
	render_path = undefined;
	renderer    = undefined;
	
	static renderGif = function(_target) {
		rendering   = true;
		render_path = _target;
		
		var gw = surface_get_width_safe(outputSurface);
		var gh = surface_get_height_safe(outputSurface);
		renderer  = gif_open(gw, gh, c_black);
		
		project.animator.render();
	}
	
	static update = function() {
		project.outputNode = self;
		
		var _surf = inputs[ 0].getValue();
		animated  = inputs[ 1].getValue();
		
		update_on_frame = animated;
		
		if(!is_just_surface(_surf)) { outputSurface = noone; return; }
		
		if(rendering) {
			gif_add_surface(renderer, _surf, 100/30);
			if(IS_LAST_FRAME) {
				gif_save(renderer, render_path);
				rendering = false;
				
				run_in(1, function() /*=>*/ {return closeProject()});
			}
		}
		
		var _sw = surface_get_width(_surf);
		var _sh = surface_get_height(_surf);
		
		outputSurface = surface_verify(outputSurface, _sw, _sh);
		surface_set_shader(outputSurface);
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		outputs[0].setValue(outputSurface);
	}
	
}