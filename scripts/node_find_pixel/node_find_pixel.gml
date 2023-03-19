function Node_Find_Pixel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Find pixel";
	w = 96;
	
	shader = sh_find_pixel;
	shader_dim = shader_get_uniform(shader, "dimension");
	shader_tex = shader_get_sampler_index(shader, "texture");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Search color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
		
	outputs[| 0] = nodeValue("Position", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	static getPreviewValue = function() { return inputs[| 0]; }
	
	temp_surface = [ surface_create(1, 1) ];
	
	function process_data(_output, _data, _output_index, _array_index = 0) {  
		var _surf = _data[0];
		var _col  = _data[1];
		
		if(!is_surface(_surf)) return [0, 0];
		
		temp_surface[0] = surface_verify(temp_surface[0], 1, 1);
		
		surface_set_target(temp_surface[0]);
		DRAW_CLEAR
		shader_set(shader);
			texture_set_stage(shader_tex, surface_get_texture(_surf));
			shader_set_uniform_f(shader_dim, surface_get_width(_surf), surface_get_height(_surf));
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, 1, 1, 0, _col, 1);
		shader_reset();
		surface_reset_target();
		
		var pos = surface_getpixel(temp_surface[0], 0, 0);
		var _x  = round(color_get_red(pos)   / 255 * surface_get_width(_surf));
		var _y  = round(color_get_green(pos) / 255 * surface_get_height(_surf));
		
		return [ _x, _y ];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(bbox.h <= 0) return;
		
		var col = inputs[| 1].getValue();
		
		if(is_array(col)) {
			drawPalette(col, bbox.x0, bbox.y0, bbox.w, bbox.h);
			return;
		}
		
		draw_set_color(col);
		draw_rectangle(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 0);
	}
}