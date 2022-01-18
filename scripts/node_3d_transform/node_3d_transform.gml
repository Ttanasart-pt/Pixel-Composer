function Node_create_3D_Transform(_x, _y) {
	var node = new Node_3D_Transform(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_3D_Transform(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "3D Transform";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, OUTPUT_SCALING.same_as_input)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Same as input", "Constant", "Relative to input" ])
		.setVisible(false);
	
	inputs[| 5] = nodeValue(5, "Constant dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d)
		.setDisplay(VALUE_DISPLAY.vector);
	node_input_visible(inputs[| 5], false);
	
	input_display_list = [0, 
		["Outputs",		true],	4, 5, 
		["Transform",	false], 1, 2, 3 
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	#region 3D setup
		TM = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1);
		cam = camera_create();
		cam_view = matrix_build_lookat(0, 0, 1, 0, 0, 0, 0, 1, 0);
		cam_proj = matrix_build_projection_ortho(1, 1, 1, 100);
		
		camera_set_proj_mat(cam, cam_view);
		camera_set_view_mat(cam, cam_proj);
	
		//camera_set_view_size(cam, cam_w, cam_h);
		//camera_set_view_pos(cam, 0, 0);
	#endregion
	
	drag_index = -1;
	drag_sv = 0;
	drag_mx = 0;
	drag_my = 0;
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		var active = _active;
		if(inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my)) active = false;
		var _out = outputs[| 0].getValue();
		if(!is_surface(_out) || !surface_exists(_out)) return;
		
		var _rot = inputs[| 2].getValue();
		var cx = _x + surface_get_width(_out) * _s / 2;
		var cy = _y + surface_get_height(_out) * _s / 2;
		
		draw_set_color(c_ui_red);
		draw_line(cx - 64, cy, cx + 64, cy);
		
		draw_set_color(c_ui_lime);
		draw_line(cx, cy - 64, cx, cy + 64);
		
		draw_set_color(c_ui_cyan);
		draw_circle(cx, cy, 64, true);
		
		if(drag_index == 0) {
			var dx  = (_mx - drag_mx) / _s * 6;
			_rot[1] = drag_sv + dx;
			
			if(inputs[| 2].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_check_button_released(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else if(drag_index == 1) {
			var dy  = (_my - drag_my) / _s * -6;
			_rot[0] = drag_sv + dy;
			
			if(inputs[| 2].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_check_button_released(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else if(drag_index == 2) {
			var da  = point_direction(cx, cy, _mx, _my);
			_rot[2] = da;
			
			if(inputs[| 2].setValue(_rot)) 
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
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _out_type = inputs[| 4].getValue();
		var _out = inputs[| 5].getValue();
		
		var _ww, _hh;
		
		switch(_out_type) {
			case OUTPUT_SCALING.same_as_input :
				node_input_visible(inputs[| 5], false);
				_ww  = surface_get_width(_data[0]);
				_hh  = surface_get_height(_data[0]);
				break;
			case OUTPUT_SCALING.constant :	
				node_input_visible(inputs[| 5], true);
				_ww  = _out[0];
				_hh  = _out[1];
				break;
			case OUTPUT_SCALING.relative : 
				node_input_visible(inputs[| 5], true);
				_ww  = surface_get_width(_data[0]) * _out[0];
				_hh  = surface_get_height(_data[0]) * _out[1];
				break;
		}
		
		if(_ww <= 0 || _hh <= 0) return;
		surface_size_to(_outSurf, _ww, _hh);
		
		var _pos = _data[1];
		var _rot = _data[2];
		var _sca = _data[3];
		
		TM = matrix_build(_ww / 2 + _pos[0], _hh / 2 + _pos[1], 0, _rot[0], _rot[1], _rot[2], _ww * _sca[0], _hh * _sca[1], 1);
		cam_proj = matrix_build_projection_ortho(_ww, _hh, 1, 100);
		camera_set_view_mat(cam, cam_proj);
		camera_set_view_size(cam, _ww, _hh);
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
		
			shader_set(sh_vertex_pt);
			camera_apply(cam);
			
			matrix_set(matrix_world, TM);
			vertex_submit(PRIMITIVES[? "plane"], pr_trianglelist, surface_get_texture(_data[0]));
			shader_reset();
			
			matrix_set(matrix_world, MATRIX_IDENTITY);
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}