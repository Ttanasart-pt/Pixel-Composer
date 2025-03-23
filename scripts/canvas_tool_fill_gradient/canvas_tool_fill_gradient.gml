function canvas_tool_fill_gradient(toolAttr) : canvas_tool_shader() constructor {
	tool_attribute = toolAttr;
	
	mouse_sx = 0;
	mouse_sy = 0;
	
	fx = 0;
	fy = 0;
	
	tx = 0;
	ty = 0; 
	
	static dither2 = [  0,  2,
					    3,  1 ];
	static dither4 = [  0,  8,  2, 10,
					   12,  4, 14,  6,
					    3, 11,  1,  9,
					   15,  7, 13,  5];
	static dither8 = [  0, 32,  8, 40,  2, 34, 10, 42, 
					   48, 16, 56, 24, 50, 18, 58, 26,
					   12, 44,  4, 36, 14, 46,  6, 38, 
					   60, 28, 52, 20, 62, 30, 54, 22,
					    3, 35, 11, 43,  1, 33,  9, 41,
					   51, 19, 59, 27, 49, 17, 57, 25,
					   15, 47,  7, 39, 13, 45,  5, 37,
					   63, 31, 55, 23, 61, 29, 53, 21];
					   
	function init() { mouse_init = true; }
	
	function onInit(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		mouse_sx = _mx;
		mouse_sy = _my;
	}
	
	function stepEffect(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _dim = node.attributes.dimension;
		var _dit = tool_attribute.dither;
		
		fx = (mouse_sx - _x) / _s;
		fy = (mouse_sy - _y) / _s;
		
		tx = (_mx - _x) / _s;
		ty = (_my - _y) / _s;
		
		if(key_mod_press(SHIFT)) {
    		var _dx = tx - fx;
    		var _dy = ty - fy;
    		
    		if(abs(_dx) > abs(_dy)) 
    		     tx = fx + _dx;
    		else ty = fy + _dy;
		}
		
		surface_set_shader(preview_surface[1], sh_canvas_gradient);
			
			shader_set_f("dimension", _dim);
			shader_set_f("p0",        fx, fy);
			shader_set_f("p1",        tx, ty);
			shader_set_color("color", CURRENT_COLOR);
			
            shader_set_i("dithering", bool(_dit));
            
			switch(_dit) {
				case 1 :
					shader_set_f("ditherSize",	2);
					shader_set_f("dither",		dither2);
					break;
					
				case 2 :
					shader_set_f("ditherSize",	4);
					shader_set_f("dither",		dither4);
					break;
					
				case 3 :
					shader_set_f("ditherSize",	8);
					shader_set_f("dither",		dither8);
					break;
					
			}
			
			draw_surface_safe(preview_surface[0]);
		surface_reset_shader();
		
	}
	
	function drawOverlay( hover, active, _x, _y, _s, _mx, _my, _snx, _sny ) {
	    
	    var _fx = _x + fx * _s;
	    var _fy = _y + fy * _s;
	    var _tx = _x + tx * _s;
	    var _ty = _y + ty * _s;
	    
	    draw_set_color(c_white); draw_line(_fx, _fy, _tx, _ty);
	    
	    draw_set_color(c_white);       draw_circle_prec(_fx, _fy, ui(3), false);
	    draw_set_color(CURRENT_COLOR); draw_circle_prec(_tx, _ty, ui(6), false);
	    
	    draw_set_color(c_white); draw_circle_prec(_fx, _fy, ui(3), true);
	    draw_set_color(c_white); draw_circle_prec(_tx, _ty, ui(6), true);
	    
	    
	}
}