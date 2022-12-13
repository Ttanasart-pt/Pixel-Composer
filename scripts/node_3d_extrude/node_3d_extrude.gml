function Node_3D_Extrude(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "3D Extrude";
	
	uniVertex_lightFor = shader_get_uniform(sh_vertex_pnt_light, "u_LightForward");
	uniLightAmb = shader_get_uniform(sh_vertex_pnt_light, "u_AmbientLight");
	uniLightClr = shader_get_uniform(sh_vertex_pnt_light, "u_LightColor");
	uniLightInt = shader_get_uniform(sh_vertex_pnt_light, "u_LightIntensity");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue(1, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 0.1 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 5] = nodeValue(5, "Render scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 6] = nodeValue(6, "Manual generate", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() { 
			generateMesh();
		}, "Generate"] );
		
	inputs[| 7] = nodeValue(7, "Light direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 8] = nodeValue(8, "Light height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [-1, 1, 0.01]);
		
	inputs[| 9] = nodeValue(9, "Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 10] = nodeValue(10, "Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 11] = nodeValue(11, "Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey);
	
	inputs[| 12] = nodeValue(12, "Height map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	input_display_list = [1, 
		["Geometry",	false], 0, 12, 6,
		["Transform",	false], 2, 3, 4, 5,
		["Light",		false], 7, 8, 9, 10, 11
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	VB = vertex_create_buffer();
	vertex_begin(VB, FORMAT_PT);
	vertex_end(VB);
	
	static onValueUpdate = function(index) {
		if(index == 0 || index == 12) 
			generateMesh();
	}
	
	static generateMesh = function() {
		var _ins = inputs[| 0].getValue();
		var _hei = inputs[| 12].getValue();
		if(!is_surface(_ins)) return;
		
		var ww = surface_get_width(_ins);
		var hh = surface_get_height(_ins);
		var tw = 1 / ww;
		var th = 1 / hh;
		var sw = -ww / 2 * tw;
		var sh = -hh / 2 * th;
		var useH = is_surface(_hei);
		
		if(useH) {
			var height_buffer = buffer_create(ww * hh * 4, buffer_fixed, 2);
			buffer_get_surface(height_buffer, _hei, 0);
			buffer_seek(height_buffer, buffer_seek_start, 0);
			
			var hei = array_create(ww, hh);
			
			for( var j = 0; j < hh; j++ )
			for( var i = 0; i < ww; i++ ) {
				var cc = buffer_read(height_buffer, buffer_u32);
				var _b = colorBrightness(cc & ~0b11111111);
				hei[i][j] = _b;
			}
			
			buffer_delete(height_buffer);
		}
		
		var surface_buffer = buffer_create(ww * hh * 4, buffer_fixed, 2);
		buffer_get_surface(surface_buffer, _ins, 0);
		buffer_seek(surface_buffer, buffer_seek_start, 0);
		
		vertex_begin(VB, FORMAT_PNT);
		var ap = array_create(ww, hh);
		
		for( var j = 0; j < hh; j++ )
		for( var i = 0; i < ww; i++ ) {
			var cc = buffer_read(surface_buffer, buffer_u32);
			var _a = (cc & (0b11111111 << 24)) >> 24;
			ap[i][j] = _a;
		}
		
		buffer_delete(surface_buffer);
		
		for( var i = 0; i < ww; i++ )
		for( var j = 0; j < hh; j++ ) {
			if(ap[i][j] == 0) continue;
			
			var i0 = sw + i * tw, i1 = i0 + tw;
			var j0 = sh + j * th, j1 = j0 + th;
			var tx0 = tw * i, tx1 = tx0 + tw;
			var ty0 = th * j, ty1 = ty0 + th;
			
			var dep = (useH? hei[i][j] : 1) * 0.5;
			
			vertex_add_pnt(VB, [i1, j0, -dep], [0, 0, -1], [tx1, ty0]);
			vertex_add_pnt(VB, [i0, j0, -dep], [0, 0, -1], [tx0, ty0]);
			vertex_add_pnt(VB, [i1, j1, -dep], [0, 0, -1], [tx1, ty1]);
						    		
			vertex_add_pnt(VB, [i1, j1, -dep], [0, 0, -1], [tx1, ty1]);
			vertex_add_pnt(VB, [i0, j0, -dep], [0, 0, -1], [tx0, ty0]);
			vertex_add_pnt(VB, [i0, j1, -dep], [0, 0, -1], [tx0, ty1]);
			
			vertex_add_pnt(VB, [i1, j0,  dep], [0, 0, 1], [tx1, ty0]);
			vertex_add_pnt(VB, [i0, j0,  dep], [0, 0, 1], [tx0, ty0]);
			vertex_add_pnt(VB, [i1, j1,  dep], [0, 0, 1], [tx1, ty1]);
						    		    
			vertex_add_pnt(VB, [i1, j1,  dep], [0, 0, 1], [tx1, ty1]);
			vertex_add_pnt(VB, [i0, j0,  dep], [0, 0, 1], [tx0, ty0]);
			vertex_add_pnt(VB, [i0, j1,  dep], [0, 0, 1], [tx0, ty1]);
			
			if((useH && dep > hei[i][j - 1]) || (j == 0 || ap[i][j - 1] == 0)) {
				vertex_add_pnt(VB, [i0, j0,  dep], [0, -1, 0], [tx1, ty0]);
				vertex_add_pnt(VB, [i0, j0, -dep], [0, -1, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i1, j0,  dep], [0, -1, 0], [tx1, ty1]);
						    		    
				vertex_add_pnt(VB, [i0, j0, -dep], [0, -1, 0], [tx1, ty1]);
				vertex_add_pnt(VB, [i1, j0, -dep], [0, -1, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i1, j0,  dep], [0, -1, 0], [tx0, ty1]);
			}
			
			if((useH && dep > hei[i][j + 1]) || (j == hh - 1 || ap[i][j + 1] == 0)) {
				vertex_add_pnt(VB, [i0, j1,  dep], [0, 1, 0], [tx1, ty0]);
				vertex_add_pnt(VB, [i0, j1, -dep], [0, 1, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i1, j1,  dep], [0, 1, 0], [tx1, ty1]);
						    		    
				vertex_add_pnt(VB, [i0, j1, -dep], [0, 1, 0], [tx1, ty1]);
				vertex_add_pnt(VB, [i1, j1, -dep], [0, 1, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i1, j1,  dep], [0, 1, 0], [tx0, ty1]);
			}
			
			if((useH && dep > hei[i - 1][j]) || (i == 0 || ap[i - 1][j] == 0)) {
				vertex_add_pnt(VB, [i0, j0,  dep], [1, 0, 0], [tx1, ty0]);
				vertex_add_pnt(VB, [i0, j0, -dep], [1, 0, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i0, j1,  dep], [1, 0, 0], [tx1, ty1]);
						    		    
				vertex_add_pnt(VB, [i0, j0, -dep], [1, 0, 0], [tx1, ty1]);
				vertex_add_pnt(VB, [i0, j1, -dep], [1, 0, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i0, j1,  dep], [1, 0, 0], [tx0, ty1]);
			}
			
			if((useH && dep > hei[i + 1][j]) || (i == ww - 1 || ap[i + 1][j] == 0)) {
				vertex_add_pnt(VB, [i1, j0,  dep], [-1, 0, 0], [tx1, ty0]);
				vertex_add_pnt(VB, [i1, j0, -dep], [-1, 0, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i1, j1,  dep], [-1, 0, 0], [tx1, ty1]);
						    		    
				vertex_add_pnt(VB, [i1, j0, -dep], [-1, 0, 0], [tx1, ty1]);
				vertex_add_pnt(VB, [i1, j1, -dep], [-1, 0, 0], [tx0, ty0]);
				vertex_add_pnt(VB, [i1, j1,  dep], [-1, 0, 0], [tx0, ty1]);
			}
		}
		vertex_end(VB);
		update();
	}
	
	drag_index = -1;
	drag_sv = 0;
	drag_mx = 0;
	drag_my = 0;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
		if(inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my)) 
			active = false;
		
		var _dim = inputs[| 1].getValue();
		var _pos = inputs[| 2].getValue();
		var _rot = inputs[| 3].getValue();
		var cx = _x + _pos[0] * _s;
		var cy = _y + _pos[1] * _s;
		
		draw_set_color(COLORS.axis[0]);
		draw_line(cx - 64, cy, cx + 64, cy);
		
		draw_set_color(COLORS.axis[1]);
		draw_line(cx, cy - 64, cx, cy + 64);
		
		draw_set_color(COLORS.axis[2]);
		draw_circle(cx, cy, 64, true);
		
		if(drag_index == 0) {
			var dx  = (_mx - drag_mx) / _s * 6;
			_rot[1] = drag_sv + dx;
			
			if(inputs[| 3].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else if(drag_index == 1) {
			var dy  = (_my - drag_my) / _s * -6;
			_rot[0] = drag_sv + dy;
			
			if(inputs[| 3].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else if(drag_index == 2) {
			var da  = point_direction(cx, cy, _mx, _my);
			_rot[2] = da;
			
			if(inputs[| 3].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else {
			if(distance_to_line(_mx, _my, cx - 64, cy, cx + 64, cy) < 16) {
				draw_set_color(COLORS.axis[0]);
				draw_line_width(cx - 64, cy, cx + 64, cy, 3);
				if(mouse_press(mb_left, active)) {
					drag_index	= 0;
					drag_sv		= _rot[1];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			} else if(distance_to_line(_mx, _my, cx, cy - 64, cx, cy + 64) < 16) {
				draw_set_color(COLORS.axis[1]);
				draw_line_width(cx, cy - 64, cx, cy + 64, 3);
				if(mouse_press(mb_left, active)) {
					drag_index	= 1;
					drag_sv		= _rot[0];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			} else if(abs(point_distance(_mx, _my, cx, cy) - 64) < 8) {
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
		
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my);
	}
	
	#region 3D setup
		TM = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1);
		cam = camera_create();
		cam_view = matrix_build_lookat(0, 0, 1, 0, 0, 0, 0, 1, 0);
		cam_proj = matrix_build_projection_ortho(1, 1, 1, 100);
		
		camera_set_proj_mat(cam, cam_view);
		camera_set_view_mat(cam, cam_proj);
	#endregion
	
	static update = function() {
		var _ins = inputs[| 0].getValue();
		var _dim = inputs[| 1].getValue();
		var _pos = inputs[| 2].getValue();
		var _rot = inputs[| 3].getValue();
		var _lsc = inputs[| 4].getValue();
		var _sca = inputs[| 5].getValue();
		
		var _ldir = inputs[|  7].getValue();
		var _lhgt = inputs[|  8].getValue();
		var _lint = inputs[|  9].getValue();
		var _lclr = inputs[| 10].getValue();
		var _aclr = inputs[| 11].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf = surface_create_valid(_dim[0], _dim[1]);
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, _dim[0], _dim[1]);
		
		if(!is_surface(_ins)) return _outSurf;
		
		var TM = matrix_build(_pos[0], _pos[1], 0, _rot[0], _rot[1], _rot[2], _dim[0] * _sca[0], _dim[1] * _sca[1], 1);
		var cam_proj = matrix_build_projection_ortho(_dim[0], _dim[1], 1, 100);
		camera_set_view_mat(cam, cam_proj);
		camera_set_view_size(cam, _dim[0], _dim[1]);
		
		var lightFor = [ -cos(degtorad(_ldir)), -_lhgt, -sin(degtorad(_ldir)) ];
		
		gpu_set_ztestenable(true);
		surface_set_target(_outSurf);
			shader_set(sh_vertex_pnt_light);
			shader_set_uniform_f_array(uniVertex_lightFor, lightFor);
			shader_set_uniform_f_array(uniLightAmb, colorArrayFromReal(_aclr));
			shader_set_uniform_f_array(uniLightClr, colorArrayFromReal(_lclr));
			shader_set_uniform_f(uniLightInt, _lint);
			camera_apply(cam);
			draw_clear_alpha(0, 0);
				
			matrix_stack_push(TM);
			matrix_stack_push(matrix_build(0, 0, 0, 0, 0, 0, _lsc[0], _lsc[1], _lsc[2]));
				
			matrix_set(matrix_world, matrix_stack_top());
			vertex_submit(VB, pr_trianglelist, surface_get_texture(_ins));
			
			shader_reset();
			matrix_stack_pop();
			matrix_stack_pop();
			matrix_set(matrix_world, MATRIX_IDENTITY);
		surface_reset_target();
		
		gpu_set_ztestenable(false);
		camera_apply(0);
		
		return _outSurf;
	}
}