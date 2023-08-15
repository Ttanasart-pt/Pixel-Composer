enum CAMERA_PROJ {
	ortho,
	perspective
}

#region setup
	globalvar PRIMITIVES, FORMAT_P, FORMAT_PT, FORMAT_PNT, FORMAT_2PC;
	PRIMITIVES = ds_map_create();

	vertex_format_begin();
	vertex_format_add_position_3d();
	FORMAT_P = vertex_format_end();

	vertex_format_begin();
	vertex_format_add_position_3d();
	vertex_format_add_texcoord();
	FORMAT_PT = vertex_format_end();

	vertex_format_begin();
	vertex_format_add_position_3d();
	vertex_format_add_normal();
	vertex_format_add_texcoord();
	FORMAT_PNT = vertex_format_end();
	
	vertex_format_begin();
	vertex_format_add_position();
	vertex_format_add_color();
	FORMAT_2PC = vertex_format_end();
#endregion

#region 3d obj
	function VertexObject() constructor {
		positions = [];
		textures  = [];
		normals   = [];
		
		faces  = [];
		buffer = noone;
		renderSurface = noone;
		renderTexture = noone;
		
		static addPosition = function(_pos, _merge = false) {
			if(!_merge) {
				array_push(positions, _pos);
				return array_length(positions) - 1;
			}
				
			var ind = array_find(positions, _pos);
			
			if(ind == -1) {
				array_push(positions, _pos);
				return array_length(positions) - 1;
			}
			
			return ind;
		}
		
		static addNormal = function(_nor, _merge = false) {
			if(!_merge) {
				array_push(normals, _nor);
				return array_length(normals) - 1;
			}
				
			var ind = array_find(normals, _nor);
			
			if(ind == -1) {
				array_push(normals, _nor);
				return array_length(normals) - 1;
			}
			
			return ind;
		}
		
		static addTexture = function(_tex, _merge = false) {
			if(!_merge) {
				array_push(textures, _tex);
				return array_length(textures) - 1;
			}
				
			var ind = array_find(textures, _tex);
			
			if(ind == -1) {
				array_push(textures, _tex);
				return array_length(textures) - 1;
			}
			
			return ind;
		}
		
		static addFace = function(v1 = [0, 0, 0], n1 = [0, 0, 0], t1 = [0, 0], 
								  v2 = [0, 0, 0], n2 = [0, 0, 0], t2 = [0, 0], 
								  v3 = [0, 0, 0], n3 = [0, 0, 0], t3 = [0, 0], _merge = false) {
			var pi0 = addPosition(v1, _merge);
			var pi1 = addPosition(v2, _merge);
			var pi2 = addPosition(v3, _merge);
			
			var ni0 = addNormal(n1, _merge);
			var ni1 = addNormal(n2, _merge);
			var ni2 = addNormal(n3, _merge);
			
			var ti0 = addTexture(t1, _merge);
			var ti1 = addTexture(t2, _merge);
			var ti2 = addTexture(t3, _merge);
			
			array_append(faces, [
				[pi0, ni0, ti0],
				[pi1, ni1, ti1],
				[pi2, ni2, ti2],
			]);
		}
		
		static createBuffer = function() {
			if(buffer != noone) vertex_delete_buffer(buffer);
			
			var VB = vertex_create_buffer();
			vertex_begin(VB, FORMAT_PNT);
			
			for( var i = 0, n = array_length(faces); i < n; i++ ) {
				var face = faces[i];
				var _pos = positions[face[0]];
				var _nor = normals  [face[1]];
				var _tex = textures [face[2]];
				
				vertex_add_pnt(VB, _pos, _nor, _tex);
			}
			
			vertex_end(VB);
			vertex_freeze(VB);
			
			buffer = VB;
			return VB;
		}
		
		static submit = function(surface = noone) {
			if(!is_surface(surface)) {
				__submit();
				return;
			}
			
			renderSurface = surface;
			submitTexture(surface_get_texture(surface));
		}
		
		static submitTexture = function(texture) {
			renderTexture = texture;
			__submit();
		}
		
		static __submit = function() {
			if(renderTexture == noone)	return;
			if(buffer == noone)			return;
			
			vertex_submit(buffer, pr_trianglelist, renderTexture);
		}
		
		static clone = function(_submit = true) {
			var v = new VertexObject();
			v.positions = array_clone(positions);
			v.textures  = array_clone(textures);
			v.normals   = array_clone(normals);
			
			v.faces = array_clone(faces);
			v.renderTexture = renderTexture;
			
			if(_submit) v.createBuffer();
			
			return v;
		}
		
		static destroy = function() {
			vertex_delete_buffer(buffer);
		}
	}
#endregion

#region primitives
	var _0 = -.5;
	var _1 =  .5;
	
	var v = new VertexObject();
	v.addFace( [_1, _0, 0], [0, 0, 1], [1, 0], 
			   [_0, _0, 0], [0, 0, 1], [0, 0], 
			   [_1, _1, 0], [0, 0, 1], [1, 1], );
	
	v.addFace( [_1, _1, 0], [0, 0, 1], [1, 1], 
			   [_0, _0, 0], [0, 0, 1], [0, 0], 
			   [_0, _1, 0],	[0, 0, 1], [0, 1], );
	
	PRIMITIVES[? "plane"] = v;

	var v = [];
	
	v[0] = new VertexObject();
	v[0].addFace( [_1, _0, _0], [0, 0, -1], [1, 0],
		   	      [_0, _0, _0], [0, 0, -1], [0, 0],
		   	      [_1, _1, _0], [0, 0, -1], [1, 1], );
	
	v[0].addFace( [_1, _1, _0], [0, 0, -1], [1, 1], 
			      [_0, _0, _0], [0, 0, -1], [0, 0], 
			      [_0, _1, _0], [0, 0, -1], [0, 1], );
	
	v[1] = new VertexObject();
	v[1].addFace( [_1, _0, _1], [0, 0, 1], [0, 0], 
			      [_0, _0, _1], [0, 0, 1], [1, 0], 
			      [_1, _1, _1], [0, 0, 1], [0, 1], );
	
	v[1].addFace( [_1, _1, _1], [0, 0, 1], [0, 1], 
			      [_0, _0, _1], [0, 0, 1], [1, 0], 
			      [_0, _1, _1], [0, 0, 1], [1, 1], );
	
	v[2] = new VertexObject();
	v[2].addFace( [_1, _0, _0], [0, -1, 0], [1, 0], 
			      [_0, _0, _0], [0, -1, 0], [0, 0], 
			      [_1, _0, _1], [0, -1, 0], [1, 1], );
	
	v[2].addFace( [_1, _0, _1], [0, -1, 0], [1, 1], 
			      [_0, _0, _0], [0, -1, 0], [0, 0], 
			      [_0, _0, _1], [0, -1, 0], [0, 1], );
	
	v[3] = new VertexObject();
	v[3].addFace( [_1, _1, _0], [0, 1, 0], [1, 0], 
			      [_0, _1, _0], [0, 1, 0], [0, 0], 
			      [_1, _1, _1], [0, 1, 0], [1, 1], );
	
	v[3].addFace( [_1, _1, _1], [0, 1, 0], [1, 1], 
			      [_0, _1, _0], [0, 1, 0], [0, 0], 
			      [_0, _1, _1], [0, 1, 0], [0, 1], );
	
	v[4] = new VertexObject();
	v[4].addFace( [_0, _1, _0], [-1, 0, 0], [1, 1], 
			      [_0, _0, _0], [-1, 0, 0], [1, 0], 
			      [_0, _1, _1], [-1, 0, 0], [0, 1], );
	
	v[4].addFace( [_0, _1, _1], [-1, 0, 0], [0, 1], 
			      [_0, _0, _0], [-1, 0, 0], [1, 0], 
			      [_0, _0, _1], [-1, 0, 0], [0, 0], );
	
	v[5] = new VertexObject();
	v[5].addFace( [_1, _1, _0], [1, 0, 0], [0, 1], 
			      [_1, _0, _0], [1, 0, 0], [0, 0], 
			      [_1, _1, _1], [1, 0, 0], [1, 1], );
			   	    	  		 		 
	v[5].addFace( [_1, _1, _1], [1, 0, 0], [1, 1], 
			      [_1, _0, _0], [1, 0, 0], [0, 0], 
			      [_1, _0, _1], [1, 0, 0], [1, 0], );
	
	PRIMITIVES[? "cube"] = v;
#endregion

#region helper
	enum GIZMO_3D_TYPE {
		move,
		rotate,
		scale
	}

	function _3d_node_init(iDim, gPos, gSca, iPos, iRot, iSca) {
		VB = [];
		use_normal = true;
		
		TM  = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1);
		cam = camera_create();
		
		cam_view = matrix_build_lookat(0, 0, 1, 0, 0, 0, 0, 1, 0);
		cam_proj = matrix_build_projection_ortho(1, 1, 1, 100);
		
		camera_set_view_mat(cam, cam_view);
		camera_set_proj_mat(cam, cam_proj);
		
		drag_index = noone;
		drag_sv    = 0;
		drag_delta = 0;
		drag_prev  = 0;
		
		drag_mx    = 0;
		drag_my    = 0;
		
		input_dim  = iDim;
		global_pos = gPos;
		global_sca = gSca;
		input_pos  = iPos;
		input_rot  = iRot;
		input_sca  = iSca;
		
		gizmo_hover = noone;
		
		tools = [
			new NodeTool( "Transform", THEME.tools_3d_transform ),
			new NodeTool( "Rotate", THEME.tools_3d_rotate ),
			new NodeTool( "Scale", THEME.tools_3d_scale ),
		];
	}
	
	function _3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _gpos = inputs[| global_pos].getValue();
		var _gsca = inputs[| global_sca].getValue();
		
		var _pos  = inputs[| input_pos].getValue();
		var _rot  = inputs[| input_rot].getValue();
		var _sca  = inputs[| input_sca].getValue();
		
		var cx = _x + _gpos[0] * _s;
		var cy = _y + _gpos[1] * _s;
		
		var _qrot  = new BBMOD_Quaternion().FromEuler(_rot[0], -_rot[1], -_rot[2]);
		var _hover = noone;
		var _hoverDist = 10;
		
		if(isUsingTool(0)) {
			var ga = [];
			var dir = 0;
			
			ga[0] = new BBMOD_Vec3(64,   0,  0);
			ga[1] = new BBMOD_Vec3( 0, -64,  0);
			ga[2] = new BBMOD_Vec3( 0,   0, 64);
			
			for( var i = 0; i < 3; i++ ) {
				ga[i] = _qrot.Rotate(ga[i]);
				
				var th = 2 + (gizmo_hover == i);
				if(drag_index == i) {
					th = 3;
					dir = point_direction(0, 0, ga[i].X, ga[i].Y);
				} else if(drag_index != noone)
					th = 1;
							
				draw_set_color(COLORS.axis[i]);
				draw_line_round_arrow(cx, cy, cx + ga[i].X, cy + ga[i].Y, th);
				
				var _d = distance_to_line(_mx, _my, cx, cy, cx + ga[i].X, cy + ga[i].Y);
				if(_d < _hoverDist) {
					_hover = i;
					_hoverDist = _d;
				}
			}
			
			gizmo_hover = _hover;
			
			if(drag_index != noone) {
				var mAng = point_direction(cx, cy, _mx, _my);
				var _n   = BBMOD_VEC3_FORWARD;
				
				var _mmx = _mx - cx;
				var _mmy = _my - cy;
				var _max = ga[drag_index].X;
				var _may = ga[drag_index].Y;
				
				var mAdj = dot_product(_mmx, _mmy, _max, _may);
				
				if(drag_prev != undefined) {
					_pos[drag_index] += (mAdj - drag_prev) / 8000;
					
					if(inputs[| input_pos].setValue(_pos)) 
						UNDO_HOLDING = true;
				}
				drag_prev = mAdj;
			}
		} else if(isUsingTool(1)) {
			var _pa = [], pa = [];
			var drx, dry, drz;
			
			var _sub = 64;
			for( var i = 0; i <= _sub; i++ ) {
				var ang = i * 360 / _sub;
				
				pa[0] = new BBMOD_Vec3(0, lengthdir_x(64, ang), lengthdir_y(64, ang));
				pa[0] = _qrot.Rotate(pa[0]);
			
				pa[1] = new BBMOD_Vec3(lengthdir_x(64, ang), 0, lengthdir_y(64, ang));
				pa[1] = _qrot.Rotate(pa[1]);
			
				pa[2] = new BBMOD_Vec3(lengthdir_x(64, ang), lengthdir_y(64, ang), 0);
				pa[2] = _qrot.Rotate(pa[2]);
				
				if(i) {
					for( var j = 0; j < 3; j++ ) {
						draw_set_color(COLORS.axis[j]);
						var th = (_pa[j].Z >= 0) + 1 + (gizmo_hover == j);
						if(drag_index == j) 
							th = 3;
						else if(drag_index != noone)
							th = 1;
						
						if(_pa[j].Z >= 0 || i % 2 || drag_index == j) {
							draw_line_round(cx + _pa[j].X, cy + _pa[j].Y, cx + pa[j].X, cy + pa[j].Y, th);
							drx = point_direction(cx + _pa[j].X, cy + _pa[j].Y, cx + pa[j].X, cy + pa[j].Y);
						}
				
						var _d = distance_to_line(_mx, _my, cx + _pa[j].X, cy + _pa[j].Y, cx + pa[j].X, cy + pa[j].Y);
						if(_d < _hoverDist) {
							_hover = j;
							_hoverDist = _d;
						}
					}
				}
			
				for( var j = 0; j < 3; j++ )
					_pa[j] = pa[j];
			}
		
			gizmo_hover = _hover;
		
			if(drag_index != noone) {
				var mAng = point_direction(cx, cy, _mx, _my);
				var _n   = BBMOD_VEC3_FORWARD;
			
				switch(drag_index) {
					case 0 : _n = new BBMOD_Vec3(1.0, 0.0, 0.0); break;
					case 1 : _n = new BBMOD_Vec3(0.0, 1.0, 0.0); break;
					case 2 : _n = new BBMOD_Vec3(0.0, 0.0, 1.0); break;
				}
				
				if(drag_prev != undefined) {
					var _currQ = new BBMOD_Quaternion().FromEuler(_rot[0], _rot[1], _rot[2]);
					var _currR = new BBMOD_Quaternion().FromAxisAngle(_n, (mAng - drag_prev) * (_currQ.Rotate(_n).Z > 0? -1 : 1));
					var _mulp  = _currQ.Mul(_currR);
					var _Nrot  = new BBMOD_Matrix(_mulp.ToMatrix()).ToEuler();
				
					if(inputs[| input_rot].setValue(_Nrot)) 
						UNDO_HOLDING = true;
				}
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(cx, cy, _mx, _my, 2, 8);
				
				drag_prev = mAng;
			}
		} else if(isUsingTool(2)) {
			var ga = [];
			
			ga[0] = new BBMOD_Vec3(64,   0,  0);
			ga[1] = new BBMOD_Vec3( 0, -64,  0);
			ga[2] = new BBMOD_Vec3( 0,   0, 64);
			
			for( var i = 0; i < 3; i++ ) {
				ga[i] = _qrot.Rotate(ga[i]);
				
				var th = 2 + (gizmo_hover == i);
				if(drag_index == i) 
					th = 3;
				else if(drag_index != noone)
					th = 1;
							
				draw_set_color(COLORS.axis[i]);
				draw_line_round_arrow_scale(cx, cy, cx + ga[i].X, cy + ga[i].Y, th);
				
				var _d = distance_to_line(_mx, _my, cx, cy, cx + ga[i].X, cy + ga[i].Y);
				if(_d < _hoverDist) {
					_hover = i;
					_hoverDist = _d;
				}
			}
			
			gizmo_hover = _hover;
			
			if(drag_index != noone) {
				var mAng = point_direction(cx, cy, _mx, _my);
				var _n   = BBMOD_VEC3_FORWARD;
				
				var _mmx = _mx - cx;
				var _mmy = _my - cy;
				var _max = ga[drag_index].X;
				var _may = ga[drag_index].Y;
				
				var mAdj = dot_product(_mmx, _mmy, _max, _may);
				
				if(drag_prev != undefined) {
					_sca[drag_index] += (mAdj - drag_prev) / 8000;
					
					if(inputs[| input_sca].setValue(_sca)) 
						UNDO_HOLDING = true;
				}
				drag_prev = mAdj;
			}
		}
		
		if(drag_index != noone && mouse_release(mb_left)) {
			drag_index = noone;
			UNDO_HOLDING = false;
		}
		
		if(_hover != noone && mouse_press(mb_left, active)) {
			drag_index	= _hover;
			drag_prev   = undefined;
			drag_mx		= _mx;
			drag_my		= _my;
		}
		
		inputs[| global_pos].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	#endregion
	}
	
	function _3d_local_transform(_lpos, _lrot, _lsca) {
		matrix_stack_push(matrix_build(0, 0, 0, _lrot[0], _lrot[1], _lrot[2], 1, 1, 1));
		matrix_stack_push(matrix_build(-_lpos[0], -_lpos[1], _lpos[2], 0, 0, 0, 1, 1, 1));
		matrix_stack_push(matrix_build(0, 0, 0, 0, 0, 0, _lsca[0], _lsca[1], _lsca[2]));
		
		matrix_set(matrix_world, matrix_stack_top());
	}
	
	function _3d_clear_local_transform() {
		matrix_stack_pop();
		matrix_stack_pop();
		matrix_stack_pop();
	}
	
	function __3d_transform(pos = 0, rot = 0, sca = 0, lpos = 0, lrot = 0, lsca = 0, apply_local = true, sdim = true) constructor {
		self.pos = pos;
		self.rot = rot;
		self.sca = sca;
		
		self.local_pos = lpos;
		self.local_rot = lrot;
		self.local_sca = lsca;
		
		self.apply_local    = apply_local;
		self.scaleDimension = sdim;
	}
	
	function __3d_light(dir = 0, height = 0, intensity = 0, color = c_white, ambient = c_white) constructor {
		self.dir		= dir;
		self.height		= height;
		self.intensity	= intensity;
		self.color		= color;
		self.ambient	= ambient;
	}
	
	function __3d_camera(proj, fov) constructor {
		self.projection = proj;
		self.fov		= fov;
	}
	
	function _3d_pre_setup(_outSurf, _dim, _transform, _light, _cam, _pass = "diff") {
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		var _pos  = _transform.pos;
		var _sca  = _transform.sca;
		var _lpos = _transform.local_pos;
		var _lrot = _transform.local_rot;
		var _lsca = _transform.local_sca;
		
		var _ldir = _light.dir;
		var _lhgt = _light.height;
		var _lint = _light.intensity;
		var _lclr = _light.color;
		var _aclr = _light.ambient;
		
		var _proj = _cam.projection;
		var _fov  = _cam.fov;
		
		var _applyLocal		= _transform.apply_local;
		var scaleDimension  = _transform.scaleDimension;
		
		var lightFor = [ -cos(degtorad(_ldir)), -_lhgt, -sin(degtorad(_ldir)) ];
		
		gpu_set_ztestenable(true);
		surface_set_target(_outSurf);
		DRAW_CLEAR
		
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
		shader_set_uniform_f_array_safe(uniVertex_lightFor, lightFor);
		shader_set_uniform_f_array_safe(uniLightAmb, colorArrayFromReal(_aclr));
		shader_set_uniform_f_array_safe(uniLightClr, colorArrayFromReal(_lclr));
		shader_set_uniform_f(uniLightInt, _lint);
		shader_set_uniform_i(uniLightNrm, use_normal);
		
		var cam_view, cam_proj;
		var dw = array_safe_get(_dim, 0);
		var dh = array_safe_get(_dim, 1);
		
		if(_proj == CAMERA_PROJ.ortho) {
			cam_view = matrix_build_lookat(0, 0, 128, 0, 0, 0, 0, 1, 0);
			cam_proj = matrix_build_projection_ortho(dw, dh, 0.1, 256);
		} else {
			var _adjFov = power(_fov / 90, 1 / 4) * 90;
			var dist = _dim[0] / 2 * dtan(90 - _adjFov);
			cam_view = matrix_build_lookat(0, 0, 1 + dist, 0, 0, 0, 0, 1, 0);
			cam_proj = matrix_build_projection_perspective(dw, dh, dist, dist + 256);
		}
		
		var cam = camera_get_active();
		camera_set_view_size(cam, dw, dh);
		camera_set_view_mat(cam, cam_view);
		camera_set_proj_mat(cam, cam_proj);
		camera_apply(cam);
		
		if(_proj == CAMERA_PROJ.ortho) 
			matrix_stack_push(matrix_build(dw / 2 - _pos[0], _pos[1] - dh / 2, 0, 0, 0, 0, (scaleDimension? dw : 1) * _sca[0], (scaleDimension? dh : 1) * _sca[1], 1));
		else 							   				 		  
			matrix_stack_push(matrix_build(dw / 2 - _pos[0], _pos[1] - dh / 2, 0, 0, 0, 0, (scaleDimension? dw : 1) * _sca[0], (scaleDimension? dh : 1) * _sca[1], 1));
		//matrix_stack_push(matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1));
		
		if(_applyLocal) _3d_local_transform(_lpos, _lrot, _lsca);
		
		matrix_set(matrix_world, matrix_stack_top());
		
		return _outSurf;
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