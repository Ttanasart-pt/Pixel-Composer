function Node_create_3D_Obj(_x, _y) {
	var node = new Node_3D_Obj(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_3D_Obj(_x, _y) : Node(_x, _y) constructor {
	name = "3D Obj";
	
	inputs[| 0] = nodeValue(0, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, [ "*.obj", "" ]);
	
	inputs[| 1] = nodeValue(1, "Generate", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() { 
			updateObj();
			doUpdate(); 
		}, "Generate"] );
	
	inputs[| 2] = nodeValue(2, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 4] = nodeValue(4, "Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 180 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue(5, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	input_display_list = [ 2, 
		["Geometry",	false], 0, 1, 
		["Transform",	false], 3, 4, 5 
	];
	input_display_len  = array_length(input_display_list);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	function reset_tex() {
		tex_surface = PIXEL_SURFACE;
		surface_set_target(tex_surface);
			draw_clear(c_black);
		surface_reset_target();
	}
	reset_tex();
	
	function createMaterial(m_index) {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue( index, "Texture " + materials[m_index], self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, tex_surface);
		inputs[| index].setVisible(false);
		
		input_display_list[input_display_len + m_index] = index;
	}
	
	VB = noone;
	materials = [];
	
	static updateObj = function() {
		var _path = inputs[| 0].getValue();
		var _v = readObj(_path);
		if(_v != noone) {
			VB = _v[0];
			materials = _v[1];
		}
		
		do_reset_material = true;
	}
	do_reset_material = false;
	
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
		if(inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my)) active = false;
		
		var _dim = inputs[| 2].getValue();
		var _rot = inputs[| 4].getValue();
		var cx = _x + _dim[0] * _s / 2;
		var cy = _y + _dim[1] * _s / 2;
		
		draw_set_color(COLORS.axis[0]);
		draw_line(cx - 64, cy, cx + 64, cy);
		
		draw_set_color(COLORS.axis[1]);
		draw_line(cx, cy - 64, cx, cy + 64);
		
		draw_set_color(COLORS.axis[2]);
		draw_circle(cx, cy, 64, true);
		
		if(drag_index == 0) {
			var dx  = (_mx - drag_mx) / _s * 6;
			_rot[1] = drag_sv + dx;
			
			if(inputs[| 4].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_check_button_released(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else if(drag_index == 1) {
			var dy  = (_my - drag_my) / _s * -6;
			_rot[0] = drag_sv + dy;
			
			if(inputs[| 4].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_check_button_released(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else if(drag_index == 2) {
			var da  = point_direction(cx, cy, _mx, _my);
			_rot[2] = da;
			
			if(inputs[| 4].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_check_button_released(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else {
			if(distance_to_line(_mx, _my, cx - 64, cy, cx + 64, cy) < 16) {
				draw_set_color(COLORS.axis[0]);
				draw_line_width(cx - 64, cy, cx + 64, cy, 3);
				if(active && mouse_check_button_pressed(mb_left)) {
					drag_index	= 0;
					drag_sv		= _rot[1];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			} else if(distance_to_line(_mx, _my, cx, cy - 64, cx, cy + 64) < 16) {
				draw_set_color(COLORS.axis[1]);
				draw_line_width(cx, cy - 64, cx, cy + 64, 3);
				if(active && mouse_check_button_pressed(mb_left)) {
					drag_index	= 1;
					drag_sv		= _rot[0];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			} else if(abs(point_distance(_mx, _my, cx, cy) - 64) < 8) {
				draw_set_color(COLORS.axis[2]);
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
		if(!surface_exists(tex_surface)) reset_tex();
		
		if(do_reset_material) {
			array_resize(input_display_list, input_display_len);
		
			while(ds_list_size(inputs) > 6)
				ds_list_delete(inputs, 6);
		
			for(var i = 0; i < array_length(materials); i++)  {
				createMaterial(i);
			}
			do_reset_material = false;
		}
		
		var _dim		= inputs[| 2].getValue();
		var _pos		= inputs[| 3].getValue();
		var _rot		= inputs[| 4].getValue();
		var _sca		= inputs[| 5].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf = surface_create_valid(_dim[0], _dim[1]);
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, _dim[0], _dim[1]);
		
		TM = matrix_build(_dim[0] / 2 + _pos[0], _dim[1] / 2 + _pos[1], 0, _rot[0], _rot[1], _rot[2], _dim[0] * _sca[0], _dim[1] * _sca[1], 1);
		cam_proj = matrix_build_projection_ortho(_dim[0], _dim[1], 1, 100);
		camera_set_view_mat(cam, cam_proj);
		camera_set_view_size(cam, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
			shader_set(sh_vertex_pt);
				camera_apply(cam);
				gpu_set_ztestenable(true);
				
				draw_clear_alpha(0, 0);
				matrix_stack_push(TM);
				
				matrix_set(matrix_world, matrix_stack_top());
				if(VB != noone) {
					for(var i = 0; i < array_length(VB); i++) {
						if(i >= ds_list_size(inputs)) break;
						var tex = inputs[| 6 + i].getValue();
						if(is_surface(tex))
							vertex_submit(VB[i], pr_trianglelist, surface_get_texture(tex));
					}
				}
			shader_reset();
			
			matrix_stack_pop();
			matrix_set(matrix_world, MATRIX_IDENTITY);
		surface_reset_target();
		
		gpu_set_ztestenable(false);
		camera_apply(0);
	}
}