function Node_create_3D_Cube(_x, _y) {
	var node = new Node_3D_Cube(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_3D_Cube(_x, _y) : Node(_x, _y) constructor {
	name = "3D Cube";
	
	inputs[| 0] = nodeValue(0, "Main texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, DEF_SURFACE);
	inputs[| 1] = nodeValue(1, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d)
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	inputs[| 2] = nodeValue(2, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue(5, "Use textures", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[|  6] = nodeValue( 6, "Textures 0", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[|  7] = nodeValue( 7, "Textures 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[|  8] = nodeValue( 8, "Textures 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[|  9] = nodeValue( 9, "Textures 3", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 10] = nodeValue(10, "Textures 4", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 11] = nodeValue(11, "Textures 5", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	input_display_list = [
		["Transform",	false],	0, 1, 2, 3, 4, 
		["Texture",		false],	5, 6, 7, 8, 9, 10, 11
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	#region 3D setup
		TM = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1);
		cam = camera_create();
		cam_view = matrix_build_lookat(0, 0, 1, 0, 0, 0, 0, 1, 0);
		cam_proj = matrix_build_projection_ortho(1, 1, 1, 100);
		
		camera_set_proj_mat(cam, cam_view);
		camera_set_view_mat(cam, cam_proj);
	#endregion
	
	drag_index = -1;
	drag_sv = 0;
	drag_mx = 0;
	drag_my = 0;
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		var active = _active;
		if(inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my)) active = false;
		
		var _dim = inputs[| 1].getValue();
		var _rot = inputs[| 3].getValue();
		var cx = _x + _dim[0] * _s / 2;
		var cy = _y + _dim[1] * _s / 2;
		
		draw_set_color(c_ui_red);
		draw_line(cx - 64, cy, cx + 64, cy);
		
		draw_set_color(c_ui_lime);
		draw_line(cx, cy - 64, cx, cy + 64);
		
		draw_set_color(c_ui_cyan);
		draw_circle(cx, cy, 64, true);
		
		if(drag_index == 0) {
			var dx  = (_mx - drag_mx) / _s * 6;
			_rot[1] = drag_sv + dx;
			
			if(inputs[| 3].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_check_button_released(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else if(drag_index == 1) {
			var dy  = (_my - drag_my) / _s * -6;
			_rot[0] = drag_sv + dy;
			
			if(inputs[| 3].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_check_button_released(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else if(drag_index == 2) {
			var da  = point_direction(cx, cy, _mx, _my);
			_rot[2] = da;
			
			if(inputs[| 3].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_check_button_released(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else {
			if(distance_to_line(_mx, _my, cx - 64, cy, cx + 64, cy) < 16) {
				draw_set_color(c_ui_red);
				draw_line_width(cx - 64, cy, cx + 64, cy, 3);
				if(active && mouse_check_button_pressed(mb_left)) {
					drag_index	= 0;
					drag_sv		= _rot[1];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			} else if(distance_to_line(_mx, _my, cx, cy - 64, cx, cy + 64) < 16) {
				draw_set_color(c_ui_lime);
				draw_line_width(cx, cy - 64, cx, cy + 64, 3);
				if(active && mouse_check_button_pressed(mb_left)) {
					drag_index	= 1;
					drag_sv		= _rot[0];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			} else if(abs(point_distance(_mx, _my, cx, cy) - 64) < 8) {
				draw_set_color(c_ui_cyan);
				draw_circle_border(cx, cy, 64, 3);
				if(active && mouse_check_button_pressed(mb_left)) {
					drag_index	= 2;
					drag_sv		= _rot[2];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			}
		}
	}
	
	static update = function() {
		var _inSurf = inputs[| 0].getValue();
		
		var _ww  = surface_get_width(_inSurf);
		var _hh  = surface_get_height(_inSurf);
		var _dim = inputs[| 1].getValue();
		var _pos = inputs[| 2].getValue();
		var _rot = inputs[| 3].getValue();
		var _sca = inputs[| 4].getValue();
		
		var _usetex = inputs[| 5].getValue();
		for(var i = 6; i <= 11; i++) inputs[| i].show_in_inspector = _usetex;	
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf = surface_create(_dim[0], _dim[1]);
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, _dim[0], _dim[1]);
		
		TM = matrix_build(_ww / 2 + _pos[0], _hh / 2 + _pos[1], 0, _rot[0], _rot[1], _rot[2], _ww * _sca[0], _hh * _sca[1], 1);
		cam_proj = matrix_build_projection_ortho(_ww, _hh, 1, 100);
		camera_set_view_mat(cam, cam_proj);
		camera_set_view_size(cam, _ww, _hh);
		
		surface_set_target(_outSurf);
			shader_set(sh_vertex_pt);
			camera_apply(cam);
			draw_clear_alpha(0, 0);
			
			matrix_stack_push(TM);
			gpu_set_ztestenable(true);
			if(_usetex) {
				var face = [];
				for(var i = 0; i < 6; i++) face[i] = inputs[| 6 + i].getValue();
				
				matrix_stack_push(matrix_build(0, 0, 0.5, 0, 0, 0, 1, 1, 1));
				matrix_set(matrix_world, matrix_stack_top());
				vertex_submit(PRIMITIVES[? "plane"], pr_trianglelist, surface_get_texture(face[0]));
				matrix_stack_pop();
				
				matrix_stack_push(matrix_build(0, 0, -0.5, 0, 0, 0, 1, 1, 1));
				matrix_set(matrix_world, matrix_stack_top());
				vertex_submit(PRIMITIVES[? "plane"], pr_trianglelist, surface_get_texture(face[1]));
				matrix_stack_pop();
				
				matrix_stack_push(matrix_build(0, 0.5, 0, 90, 0, 0, 1, 1, 1));
				matrix_set(matrix_world, matrix_stack_top());
				vertex_submit(PRIMITIVES[? "plane"], pr_trianglelist, surface_get_texture(face[2]));
				matrix_stack_pop();
				
				matrix_stack_push(matrix_build(0, -0.5, 0, 90, 0, 0, 1, 1, 1));
				matrix_set(matrix_world, matrix_stack_top());
				vertex_submit(PRIMITIVES[? "plane"], pr_trianglelist, surface_get_texture(face[3]));
				matrix_stack_pop();
				
				matrix_stack_push(matrix_build(0.5, 0, 0, 0, 90, 0, 1, 1, 1));
				matrix_set(matrix_world, matrix_stack_top());
				vertex_submit(PRIMITIVES[? "plane"], pr_trianglelist, surface_get_texture(face[4]));
				matrix_stack_pop();
				
				matrix_stack_push(matrix_build(-0.5, 0, 0, 0, 90, 0, 1, 1, 1));
				matrix_set(matrix_world, matrix_stack_top());
				vertex_submit(PRIMITIVES[? "plane"], pr_trianglelist, surface_get_texture(face[5]));
				matrix_stack_pop();
			} else {
				matrix_set(matrix_world, matrix_stack_top());
				vertex_submit(PRIMITIVES[? "cube"], pr_trianglelist, surface_get_texture(_inSurf));
			}
			
			shader_reset();
			matrix_stack_pop();
			matrix_set(matrix_world, MATRIX_IDENTITY);
		surface_reset_target();
		
		gpu_set_ztestenable(false);
		camera_apply(0);
		
		return _outSurf;
	}
}