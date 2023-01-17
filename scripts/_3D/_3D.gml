enum CAMERA_PROJ {
	ortho,
	perspective
}

#region setup
	globalvar PRIMITIVES, FORMAT_PT, FORMAT_PNT;
	PRIMITIVES = ds_map_create();

	vertex_format_begin();
	vertex_format_add_position_3d();
	vertex_format_add_texcoord();
	FORMAT_PT = vertex_format_end();

	vertex_format_begin();
	vertex_format_add_position_3d();
	vertex_format_add_normal();
	vertex_format_add_texcoord();
	FORMAT_PNT = vertex_format_end();
#endregion

#region plane
	var _0 = -.5;
	var _1 =  .5;
	
	var VB = vertex_create_buffer();
	vertex_begin(VB, FORMAT_PT);
	
	vertex_add_pt(VB, [_1, _0, 0], [ 1,  0]);
	vertex_add_pt(VB, [_0, _0, 0], [ 0,  0]);
	vertex_add_pt(VB, [_1, _1, 0], [ 1,  1]);
						    		 	 
	vertex_add_pt(VB, [_1, _1, 0], [ 1,  1]);
	vertex_add_pt(VB, [_0, _0, 0], [ 0,  0]);
	vertex_add_pt(VB, [_0, _1, 0], [ 0,  1]);
		
	vertex_end(VB);
	vertex_freeze(VB);
	PRIMITIVES[? "plane"] = VB;
	
	var VB = vertex_create_buffer();
	vertex_begin(VB, FORMAT_PNT);
		
	vertex_add_pnt(VB, [_1, _0, 0], [0, 0, 1], [1, 0]);
	vertex_add_pnt(VB, [_0, _0, 0], [0, 0, 1], [0, 0]);
	vertex_add_pnt(VB, [_1, _1, 0], [0, 0, 1], [1, 1]);
						    		
	vertex_add_pnt(VB, [_1, _1, 0], [0, 0, 1], [1, 1]);
	vertex_add_pnt(VB, [_0, _0, 0], [0, 0, 1], [0, 0]);
	vertex_add_pnt(VB, [_0, _1, 0], [0, 0, 1], [0, 1]);
		
	vertex_end(VB);
	vertex_freeze(VB);
	PRIMITIVES[? "plane_normal"] = VB;
#endregion

#region cube
	var VB = vertex_create_buffer();
	vertex_begin(VB, FORMAT_PNT);
		
	vertex_add_pnt(VB, [_1, _0, _0], [0, 0, -1], [1, 0]);
	vertex_add_pnt(VB, [_0, _0, _0], [0, 0, -1], [0, 0]);
	vertex_add_pnt(VB, [_1, _1, _0], [0, 0, -1], [1, 1]);
						    		
	vertex_add_pnt(VB, [_1, _1, _0], [0, 0, -1], [1, 1]);
	vertex_add_pnt(VB, [_0, _0, _0], [0, 0, -1], [0, 0]);
	vertex_add_pnt(VB, [_0, _1, _0], [0, 0, -1], [0, 1]);
	
	vertex_add_pnt(VB, [_1, _0, _1], [0, 0, 1], [0, 0]);
	vertex_add_pnt(VB, [_0, _0, _1], [0, 0, 1], [1, 0]);
	vertex_add_pnt(VB, [_1, _1, _1], [0, 0, 1], [0, 1]);
						    		
	vertex_add_pnt(VB, [_1, _1, _1], [0, 0, 1], [0, 1]);
	vertex_add_pnt(VB, [_0, _0, _1], [0, 0, 1], [1, 0]);
	vertex_add_pnt(VB, [_0, _1, _1], [0, 0, 1], [1, 1]);
	
	
	vertex_add_pnt(VB, [_1, _0, _0], [0, 1, 0], [1, 0]);
	vertex_add_pnt(VB, [_0, _0, _0], [0, 1, 0], [0, 0]);
	vertex_add_pnt(VB, [_1, _0, _1], [0, 1, 0], [1, 1]);
						   	   			 
	vertex_add_pnt(VB, [_1, _0, _1], [0, 1, 0], [1, 1]);
	vertex_add_pnt(VB, [_0, _0, _0], [0, 1, 0], [0, 0]);
	vertex_add_pnt(VB, [_0, _0, _1], [0, 1, 0], [0, 1]);
							  
	vertex_add_pnt(VB, [_1, _1, _0], [0, -1, 0], [1, 0]);
	vertex_add_pnt(VB, [_0, _1, _0], [0, -1, 0], [0, 0]);
	vertex_add_pnt(VB, [_1, _1, _1], [0, -1, 0], [1, 1]);
						   	 
	vertex_add_pnt(VB, [_1, _1, _1], [0, -1, 0], [1, 1]);
	vertex_add_pnt(VB, [_0, _1, _0], [0, -1, 0], [0, 0]);
	vertex_add_pnt(VB, [_0, _1, _1], [0, -1, 0], [0, 1]);
	
	
	vertex_add_pnt(VB, [_0, _1, _0], [1, 0, 0], [1, 1]);
	vertex_add_pnt(VB, [_0, _0, _0], [1, 0, 0], [1, 0]);
	vertex_add_pnt(VB, [_0, _1, _1], [1, 0, 0], [0, 1]);
							      	  			    
	vertex_add_pnt(VB, [_0, _1, _1], [1, 0, 0], [0, 1]);
	vertex_add_pnt(VB, [_0, _0, _0], [1, 0, 0], [1, 0]);
	vertex_add_pnt(VB, [_0, _0, _1], [1, 0, 0], [0, 0]);
						   			  
	vertex_add_pnt(VB, [_1, _1, _0], [-1, 0, 0], [0, 1]);
	vertex_add_pnt(VB, [_1, _0, _0], [-1, 0, 0], [0, 0]);
	vertex_add_pnt(VB, [_1, _1, _1], [-1, 0, 0], [1, 1]);
							    	  		 		 
	vertex_add_pnt(VB, [_1, _1, _1], [-1, 0, 0], [1, 1]);
	vertex_add_pnt(VB, [_1, _0, _0], [-1, 0, 0], [0, 0]);
	vertex_add_pnt(VB, [_1, _0, _1], [-1, 0, 0], [1, 0]);
	
	vertex_end(VB);
	vertex_freeze(VB);
	PRIMITIVES[? "cube"] = VB;
#endregion

#region helper
	function _3d_node_init(iDim, iPos, iRot, iSca) {
		VB = [];
		use_normal = true;
		
		TM = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1);
		cam = camera_create();
		
		cam_view = matrix_build_lookat(0, 0, 1, 0, 0, 0, 0, 1, 0);
		cam_proj = matrix_build_projection_ortho(1, 1, 1, 100);
		
		camera_set_view_mat(cam, cam_view);
		camera_set_proj_mat(cam, cam_proj);
		
		drag_index = -1;
		drag_sv = 0;
		drag_mx = 0;
		drag_my = 0;
		
		input_dim = iDim;
		input_pos = iPos;
		input_rot = iRot;
		input_sca = iSca;
	}
	
	function _3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny, invx = false, invy = true) {
		if(inputs[| input_pos].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		
		var _dim = inputs[| input_dim].getValue();
		var _pos = inputs[| input_pos].getValue();
		var _rot = inputs[| input_rot].getValue();
		var cx = _x + _pos[0] * _s;
		var cy = _y + _pos[1] * _s;
		
		draw_set_color(COLORS.axis[0]);
		draw_line(cx - 64, cy, cx + 64, cy);
		
		draw_set_color(COLORS.axis[1]);
		draw_line(cx, cy - 64, cx, cy + 64);
		
		draw_set_color(COLORS.axis[2]);
		draw_circle(cx, cy, 64, true);
		
		if(drag_index == 0) {
			var dx  = (_mx - drag_mx) / _s * -6;
			_rot[1] = drag_sv - dx * (invx? -1 : 1);
			
			if(inputs[| input_rot].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else if(drag_index == 1) {
			var dy  = (_my - drag_my) / _s * 6;
			_rot[0] = drag_sv - dy * (invy? -1 : 1);
			
			if(inputs[| input_rot].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else if(drag_index == 2) {
			var dz  = point_direction(cx, cy, _mx, _my) - point_direction(cx, cy, drag_mx, drag_my);
			_rot[2] = drag_sv + dz;
			
			if(inputs[| input_rot].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else {
			if(active && distance_to_line(_mx, _my, cx - 64, cy, cx + 64, cy) < 16) {
				draw_set_color(COLORS.axis[0]);
				draw_line_width(cx - 64, cy, cx + 64, cy, 3);
				if(mouse_press(mb_left, active)) {
					drag_index	= 0;
					drag_sv		= _rot[1];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			} else if(active && distance_to_line(_mx, _my, cx, cy - 64, cx, cy + 64) < 16) {
				draw_set_color(COLORS.axis[1]);
				draw_line_width(cx, cy - 64, cx, cy + 64, 3);
				if(mouse_press(mb_left, active)) {
					drag_index	= 1;
					drag_sv		= _rot[0];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			} else if(active && abs(point_distance(_mx, _my, cx, cy) - 64) < 8) {
				draw_set_color(COLORS.axis[2]);
				draw_circle_border(cx, cy, 64, 3);
				if(mouse_press(mb_left, active)) {
					drag_index	= 2;
					drag_sv		= _rot[2];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			}
		}
		
		inputs[| input_pos].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	function _3d_local_transform(_lpos, _lrot, _lsca) {
		matrix_stack_push(matrix_build(_lpos[0], _lpos[1], _lpos[2], 0, 0, 0, 1, 1, 1));
		matrix_stack_push(matrix_build(0, 0, 0, _lrot[0], _lrot[1], _lrot[2], 1, 1, 1));
		matrix_stack_push(matrix_build(0, 0, 0, 0, 0, 0, _lsca[0], _lsca[1], _lsca[2]));
		
		matrix_set(matrix_world, matrix_stack_top());
	}
	
	function _3d_clear_local_transform() {
		matrix_stack_pop();
		matrix_stack_pop();
		matrix_stack_pop();
	}
	
	function _3d_pre_setup(_outSurf, _dim, _pos, _sca, _ldir, _lhgt, _lint, _lclr, _aclr, _lpos, _lrot, _lsca, _proj = CAMERA_PROJ.perspective, _fov = 60, _pass = "diff", _applyLocal = true) {
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		var lightFor = [ -cos(degtorad(_ldir)), -_lhgt, -sin(degtorad(_ldir)) ];
		
		gpu_set_ztestenable(true);
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		
		var shader = sh_vertex_pnt_light;
		if(_pass == "diff")			shader = sh_vertex_pnt_light;
		else if(_pass == "norm")	shader = sh_vertex_normal_pass;
		else if(_pass == "dept")	shader = sh_vertex_depth_pass;
		
		uniVertex_lightFor = shader_get_uniform(shader, "u_LightForward");
		uniLightAmb = shader_get_uniform(shader, "u_AmbientLight");
		uniLightClr = shader_get_uniform(shader, "u_LightColor");
		uniLightInt = shader_get_uniform(shader, "u_LightIntensity");
		uniLightNrm = shader_get_uniform(shader, "useNormal");
		
		shader_set(shader);
		shader_set_uniform_f_array(uniVertex_lightFor, lightFor);
		shader_set_uniform_f_array(uniLightAmb, colorArrayFromReal(_aclr));
		shader_set_uniform_f_array(uniLightClr, colorArrayFromReal(_lclr));
		shader_set_uniform_f(uniLightInt, _lint);
		shader_set_uniform_i(uniLightNrm, use_normal);
		
		var cam_view, cam_proj;
		
		if(_proj == CAMERA_PROJ.ortho) {
			cam_view = matrix_build_lookat(0, 0, 128, 0, 0, 0, 0, 1, 0);
			cam_proj = matrix_build_projection_ortho(_dim[0], _dim[1], 0.1, 256);
		} else {
			var _adjFov = power(_fov / 90, 1 / 4) * 90;
			var dist = _dim[0] / 2 * dtan(90 - _adjFov);
			cam_view = matrix_build_lookat(0, 0, 1 + dist, 0, 0, 0, 0, 1, 0);
			cam_proj = matrix_build_projection_perspective(_dim[0], _dim[1], dist, dist + 256);
		}
		
		var cam = camera_get_active();
		camera_set_view_size(cam, _dim[0], _dim[1]);
		camera_set_view_mat(cam, cam_view);
		camera_set_proj_mat(cam, cam_proj);
		camera_apply(cam);
		
		if(_proj == CAMERA_PROJ.ortho) 
			matrix_stack_push(matrix_build(_dim[0] / 2 - _pos[0], _pos[1] - _dim[1] / 2, 0, 0, 0, 0, _dim[0] * _sca[0], _dim[1] * _sca[1], 1));
		else 							   				 		  
			matrix_stack_push(matrix_build(_dim[0] / 2 - _pos[0], _pos[1] - _dim[1] / 2, 0, 0, 0, 0, _dim[0] * _sca[0], _dim[1] * _sca[1], 1));
		//matrix_stack_push(matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1));
		
		if(_applyLocal) _3d_local_transform(_lpos, _lrot, _lsca);
		
		matrix_set(matrix_world, matrix_stack_top());
	}
	
	function _3d_post_setup() {
		shader_reset();
			
		matrix_stack_clear();
		matrix_set(matrix_world, MATRIX_IDENTITY);
		
		gpu_set_ztestenable(false);
		var cam = camera_get_active();
		camera_set_view_mat(cam, matrix_build_lookat(0, 0, 1, 0, 0, 0, 0, 1, 0));
		camera_set_proj_mat(cam, matrix_build_projection_ortho(1, 1, 0.1, 256));
		camera_apply(cam);
		
		surface_reset_target();
	}
#endregion