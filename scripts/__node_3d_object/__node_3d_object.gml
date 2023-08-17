function Node_3D_Object(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "3D Object";
	h	  = 64;
	min_h = h;
	
	preview_channel = 0;
	
	inputs[| 0] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_d3d_index = ds_list_size(inputs);
	
	#macro __d3d_input_list_transform ["Transform", false], 0, 1, 2
	
	#region ---- overlay ----
		drag_axis  = noone;
		drag_sv    = 0;
		drag_delta = 0;
		drag_prev  = 0;
		
		drag_mx = 0;
		drag_my = 0;
		drag_px = 0;
		drag_py = 0;
		drag_cx = 0;
		drag_cy = 0;
		
		drag_original = 0;
		
		axis_hover = noone;
		
		tools = [
			new NodeTool( "Transform", THEME.tools_3d_transform ),
			new NodeTool( "Rotate", THEME.tools_3d_rotate ),
			new NodeTool( "Scale", THEME.tools_3d_scale ),
		];
	#endregion
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) { #region
		var _pos = inputs[| 0].getValue(,,, true);
		var _rot = inputs[| 1].getValue(,,, true);
		var _sca = inputs[| 2].getValue(,,, true);
		
		var _camera = params.camera;
		var _camPos = _camera.position;
		var _camTar = _camera.focus;
		var _camDis = _camera.focus_dist;
		var _camAx  = _camera.focus_angle_x;
		var _camAy  = _camera.focus_angle_y;
		
		var _qview = new BBMOD_Quaternion().FromEuler(_camAy, -_camAx, 0);
		
		var _vpos    = new __vec3( _pos[0], _pos[1], _pos[2] );
		var _posView = _camera.worldPointToViewPoint(_vpos);
		
		var cx = _posView.x;
		var cy = _posView.y;
		
		var _hover = noone;
		var _hoverDist = 10;
		var th;
		
		if(isUsingTool(0)) {		#region move
			var ga   = [];
			var size = 64;
			var hs = size / 2;
			var sq = 8;
		
			ga[0] = new BBMOD_Vec3(-size, 0, 0);
			ga[1] = new BBMOD_Vec3(0, 0,  size);
			ga[2] = new BBMOD_Vec3(0, -size, 0);
			
			ga[3] = [ new BBMOD_Vec3(-hs + sq,        0,  hs - sq),
					  new BBMOD_Vec3(-hs - sq,        0,  hs - sq), 
					  new BBMOD_Vec3(-hs - sq,        0,  hs + sq), 
					  new BBMOD_Vec3(-hs + sq,        0,  hs + sq), ];
			ga[4] = [ new BBMOD_Vec3(       0, -hs + sq,  hs - sq),
					  new BBMOD_Vec3(       0, -hs - sq,  hs - sq), 
					  new BBMOD_Vec3(       0, -hs - sq,  hs + sq), 
					  new BBMOD_Vec3(       0, -hs + sq,  hs + sq), ];
			ga[5] = [ new BBMOD_Vec3(-hs + sq, -hs - sq,        0),
					  new BBMOD_Vec3(-hs - sq, -hs - sq,        0), 
					  new BBMOD_Vec3(-hs - sq, -hs + sq,        0), 
					  new BBMOD_Vec3(-hs + sq, -hs + sq,        0), ];
			
			for( var i = 0; i < 3; i++ ) {
				ga[i] = _qview.Rotate(ga[i]);
			
				th = 2 + (axis_hover == i || drag_axis == i);
				if(drag_axis != noone && drag_axis != i)
					continue;
				
				draw_set_color(COLORS.axis[i]);
				if(point_distance(cx, cy, cx + ga[i].X, cy + ga[i].Y) < 5)
					draw_line_round(cx, cy, cx + ga[i].X, cy + ga[i].Y, th);
				else 
					draw_line_round_arrow(cx, cy, cx + ga[i].X, cy + ga[i].Y, th, 3);
				
				var _d = distance_to_line(_mx, _my, cx, cy, cx + ga[i].X, cy + ga[i].Y);
				if(_d < _hoverDist) {
					_hover = i;
					_hoverDist = _d;
				}
			}
			
			for( var i = 3; i < 6; i++ ) {
				for( var j = 0; j < 4; j++ )
					ga[i][j] = _qview.Rotate(ga[i][j]);
				
				th = 1;
				
				var p0x = cx + ga[i][0].X, p0y = cy + ga[i][0].Y;
				var p1x = cx + ga[i][1].X, p1y = cy + ga[i][1].Y;
				var p2x = cx + ga[i][2].X, p2y = cy + ga[i][2].Y;
				var p3x = cx + ga[i][3].X, p3y = cy + ga[i][3].Y;
				
				var _pax = (p0x + p1x + p2x + p3x) / 4;
				var _pay = (p0y + p1y + p2y + p3y) / 4;
				
				if((abs(p0x - _pax) + abs(p1x - _pax) + abs(p2x - _pax) + abs(p3x - _pax)) / 4 < 1)
					continue;
				if((abs(p0y - _pay) + abs(p1y - _pay) + abs(p2y - _pay) + abs(p3y - _pay)) / 4 < 1)
					continue;
				
				draw_set_color(COLORS.axis[(i - 3 - 1 + 3) % 3]);
				if(axis_hover == i || drag_axis == i) {
					draw_primitive_begin(pr_trianglestrip);
						draw_vertex(p0x, p0y);
						draw_vertex(p1x, p1y);
						draw_vertex(p3x, p3y);
						draw_vertex(p2x, p2y);
					draw_primitive_end();
				} else if (drag_axis == noone) {
					draw_line(p0x, p0y, p1x, p1y);
					draw_line(p1x, p1y, p2x, p2y);
					draw_line(p2x, p2y, p3x, p3y);
					draw_line(p3x, p3y, p0x, p0y);
				} else 
					continue;
				
				if(point_in_rectangle_points(_mx, _my, p0x, p0y, p1x, p1y, p3x, p3y, p2x, p2y))
					_hover = i;
			}
			
			axis_hover = _hover;
			
			if(drag_axis != noone) {
				if(!MOUSE_WRAPPING) {
					drag_mx += _mx - drag_px;
					drag_my += _my - drag_py;
					
					var _mmx = drag_mx - drag_cx;
					var _mmy = drag_my - drag_cy;
					var mAdj, nor;
					
					var ray = _camera.viewPointToWorldRay(_mx, _my);
					
					if(drag_axis < 3) {
						switch(drag_axis) {
							case 0 : nor = new __vec3(0, 0, 1); break;
							case 1 : nor = new __vec3(1, 0, 0); break;
							case 2 : nor = new __vec3(0, 1, 0); break;
						}
						
						var pln = new __plane(drag_original, nor);
						mAdj = d3d_intersect_ray_plane(ray, pln);
						
						if(drag_prev != undefined) {
							var _diff = mAdj.subtract(drag_prev);
							_pos[drag_axis] += _diff.getIndex(drag_axis);
							
							if(inputs[| 0].setValue(_pos)) 
								UNDO_HOLDING = true;
						}
					} else {
						switch(drag_axis) {
							case 3 : nor = new __vec3(0, 0, 1); break;
							case 4 : nor = new __vec3(1, 0, 0); break;
							case 5 : nor = new __vec3(0, 1, 0); break;
						}
						
						var pln = new __plane(drag_original, nor);
						mAdj = d3d_intersect_ray_plane(ray, pln);
						
						if(drag_prev != undefined) {
							var _diff = mAdj.subtract(drag_prev);
							_pos[0] += _diff.x;
							_pos[1] += _diff.y;
							_pos[2] += _diff.z;
							
							if(inputs[| 0].setValue(_pos)) 
								UNDO_HOLDING = true;
						}
					}
					
					drag_prev = mAdj;
				}
				
				setMouseWrap();
				drag_px = _mx;
				drag_py = _my;
			}
			
			if(_hover != noone && mouse_press(mb_left, active)) {
				drag_axis = _hover;
				drag_prev = undefined;
				drag_mx	= _mx;
				drag_my	= _my;
				drag_px = _mx;
				drag_py = _my;
				drag_cx = cx;
				drag_cy = cy;
				
				drag_original = new __vec3(_pos);
			}
		#endregion 
		} else if(isUsingTool(1)) { #region rotate
			var size  = 64;
			var _qrot = object.rotation;
			var _qinv = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
			
			for( var i = 0; i < 3; i++ ) {
				var op, np;
				
				th = 2 + (axis_hover == i || drag_axis == i);
				if(drag_axis != noone && drag_axis != i)
					continue;
					
				draw_set_color(COLORS.axis[i]);
				for( var j = 0; j <= 32; j++ ) {
					var ang = j / 32 * 360;
					
					switch(i) {
						case 0 : np = new BBMOD_Vec3(0, lengthdir_x(size, ang), lengthdir_y(size, ang)); break;
						case 1 : np = new BBMOD_Vec3(lengthdir_x(size, ang), lengthdir_y(size, ang), 0); break;
						case 2 : np = new BBMOD_Vec3(lengthdir_x(size, ang), 0, lengthdir_y(size, ang)); break;
					}
					
					np = _qview.Rotate(_qinv.Rotate(_qrot.Rotate(np)));
					
					if(j && (op.Z > 0 && np.Z > 0 || drag_axis == i)) {
						draw_line_round(cx + op.X, cy + op.Y, cx + np.X, cy + np.Y, th);
						var _d = distance_to_line(_mx, _my, cx + op.X, cy + op.Y, cx + np.X, cy + np.Y);
						if(_d < _hoverDist) {
							_hover = i;
							_hoverDist = _d;
						}
					}
					
					op = np;
				}
			}
			
			axis_hover = _hover;
			
			if(drag_axis != noone) {
				var mAng = point_direction(cx, cy, _mx, _my);
				var _n   = BBMOD_VEC3_FORWARD;
				
				switch(drag_axis) {
					case 0 : _n = new BBMOD_Vec3(-1,  0,  0); break;
					case 1 : _n = new BBMOD_Vec3( 0,  0, -1); break;
					case 2 : _n = new BBMOD_Vec3( 0, -1,  0); break;
				}
				
				_n = _qrot.Rotate(_n).Normalize();
				
				var _nv = _qview.Rotate(_qinv.Rotate(_n));
				draw_line_round(cx, cy, cx + _nv.X * 100, cy + _nv.Y * 100, 2);
				
				if(drag_prev != undefined) {
					var _rd = (mAng - drag_prev) * (_nv.Z > 0? 1 : -1);
					
					var _currR = new BBMOD_Quaternion().FromAxisAngle(_n, _rd);
					var _mulp  = _currR.Mul(_qrot);
					var _Nrot  = _mulp.ToArray();
					
					if(inputs[| 1].setValue(_Nrot))
						UNDO_HOLDING = true;
				}
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(cx, cy, _mx, _my, 1, 4);
				
				drag_prev = mAng;
			}
			
			if(_hover != noone && mouse_press(mb_left, active)) {
				drag_axis = _hover;
				drag_prev = undefined;
			}
		#endregion 
		} else if(isUsingTool(2)) { #region scale
			var ga   = [];
			var size = 64;
			var hs = size / 2;
			var sq = 8;
			var _qrot = object.rotation;
			var _qinv = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
			
			ga[0] = new BBMOD_Vec3(-size, 0, 0);
			ga[1] = new BBMOD_Vec3(0, -size, 0);
			ga[2] = new BBMOD_Vec3(0, 0, -size);
			
			ga[3] = [ new BBMOD_Vec3(-hs + sq, -hs - sq,        0),
					  new BBMOD_Vec3(-hs - sq, -hs - sq,        0), 
					  new BBMOD_Vec3(-hs - sq, -hs + sq,        0), 
					  new BBMOD_Vec3(-hs + sq, -hs + sq,        0), ];
			ga[4] = [ new BBMOD_Vec3(       0, -hs + sq, -hs - sq),
					  new BBMOD_Vec3(       0, -hs - sq, -hs - sq), 
					  new BBMOD_Vec3(       0, -hs - sq, -hs + sq), 
					  new BBMOD_Vec3(       0, -hs + sq, -hs + sq), ];
			ga[5] = [ new BBMOD_Vec3(-hs + sq,        0, -hs - sq),
					  new BBMOD_Vec3(-hs - sq,        0, -hs - sq), 
					  new BBMOD_Vec3(-hs - sq,        0, -hs + sq), 
					  new BBMOD_Vec3(-hs + sq,        0, -hs + sq), ];
			
			for( var i = 0; i < 3; i++ ) {
				ga[i] = _qview.Rotate(_qinv.Rotate(_qrot.Rotate(ga[i])));
			
				th = 2 + (axis_hover == i || drag_axis == i);
				if(drag_axis != noone && drag_axis != i)
					continue;
				
				draw_set_color(COLORS.axis[i]);
				if(point_distance(cx, cy, cx + ga[i].X, cy + ga[i].Y) < 5)
					draw_line_round(cx, cy, cx + ga[i].X, cy + ga[i].Y, th);
				else 
					draw_line_round_arrow_block(cx, cy, cx + ga[i].X, cy + ga[i].Y, th, 3);
				
				var _d = distance_to_line(_mx, _my, cx, cy, cx + ga[i].X, cy + ga[i].Y);
				if(_d < _hoverDist) {
					_hover = i;
					_hoverDist = _d;
				}
			}
			
			for( var i = 3; i < 6; i++ ) {
				for( var j = 0; j < 4; j++ )
					ga[i][j] = _qview.Rotate(_qinv.Rotate(_qrot.Rotate(ga[i][j])));
				
				th = 1;
				
				var p0x = cx + ga[i][0].X, p0y = cy + ga[i][0].Y;
				var p1x = cx + ga[i][1].X, p1y = cy + ga[i][1].Y;
				var p2x = cx + ga[i][2].X, p2y = cy + ga[i][2].Y;
				var p3x = cx + ga[i][3].X, p3y = cy + ga[i][3].Y;
				
				var _pax = (p0x + p1x + p2x + p3x) / 4;
				var _pay = (p0y + p1y + p2y + p3y) / 4;
				
				if((abs(p0x - _pax) + abs(p1x - _pax) + abs(p2x - _pax) + abs(p3x - _pax)) / 4 < 1)
					continue;
				if((abs(p0y - _pay) + abs(p1y - _pay) + abs(p2y - _pay) + abs(p3y - _pay)) / 4 < 1)
					continue;
				
				draw_set_color(COLORS.axis[(i - 3 - 1 + 3) % 3]);
				if(axis_hover == i || drag_axis == i) {
					draw_primitive_begin(pr_trianglestrip);
						draw_vertex(p0x, p0y);
						draw_vertex(p1x, p1y);
						draw_vertex(p3x, p3y);
						draw_vertex(p2x, p2y);
					draw_primitive_end();
				} else if (drag_axis == noone) {
					draw_line(p0x, p0y, p1x, p1y);
					draw_line(p1x, p1y, p2x, p2y);
					draw_line(p2x, p2y, p3x, p3y);
					draw_line(p3x, p3y, p0x, p0y);
				} else 
					continue;
				
				if(point_in_rectangle_points(_mx, _my, p0x, p0y, p1x, p1y, p3x, p3y, p2x, p2y))
					_hover = i;
			}
			
			axis_hover = _hover;
			
			if(drag_axis != noone) {
				if(!MOUSE_WRAPPING) {
					drag_mx += _mx - drag_px;
					drag_my += _my - drag_py;
					
					var _mmx = drag_mx - drag_cx;
					var _mmy = drag_my - drag_cy;
					var mAdj, nor;
					
					var ray = _camera.viewPointToWorldRay(_mx, _my);
					
					if(drag_axis < 3) {
						switch(drag_axis) {
							case 0 : nor = new __vec3(0, 0, 1); break;
							case 1 : nor = new __vec3(1, 0, 0); break;
							case 2 : nor = new __vec3(0, 1, 0); break;
						}
						
						var pln = new __plane(drag_original, nor);
						mAdj = d3d_intersect_ray_plane(ray, pln);
						
						if(drag_prev != undefined) {
							var _diff = mAdj.subtract(drag_prev);
							_sca[drag_axis] += _diff.getIndex(drag_axis);
							
							if(inputs[| 2].setValue(_sca)) 
								UNDO_HOLDING = true;
						}
					} else {
						switch(drag_axis) {
							case 3 : nor = new __vec3(0, 0, 1); break;
							case 4 : nor = new __vec3(1, 0, 0); break;
							case 5 : nor = new __vec3(0, 1, 0); break;
						}
						
						var pln = new __plane(drag_original, nor);
						mAdj = d3d_intersect_ray_plane(ray, pln);
						
						if(drag_prev != undefined) {
							var _diff = mAdj.subtract(drag_prev);
							_sca[0] += _diff.x;
							_sca[1] += _diff.y;
							_sca[2] += _diff.z;
							
							if(inputs[| 2].setValue(_sca)) 
								UNDO_HOLDING = true;
						}
					}
					
					drag_prev = mAdj;
				}
				
				setMouseWrap();
				drag_px = _mx;
				drag_py = _my;
			}
			
			if(_hover != noone && mouse_press(mb_left, active)) {
				drag_axis = _hover;
				drag_prev = undefined;
				drag_mx	= _mx;
				drag_my	= _my;
				drag_px = _mx;
				drag_py = _my;
				drag_cx = cx;
				drag_cy = cy;
				
				drag_original = new __vec3(_sca);
			}
		#endregion 
		}
		
		if(drag_axis != noone && mouse_release(mb_left)) {
			drag_axis = noone;
			UNDO_HOLDING = false;
		}
	} #endregion
	
	static setTransform = function(object, _data) { #region
		var _pos = _data[0];
		var _rot = _data[1];
		var _sca = _data[2];
		
		object.position.set(_pos[0], _pos[1], _pos[2]);
		object.rotation.set(_rot[0], _rot[1], _rot[2], _rot[3]);
		object.scale.set(_sca[0], _sca[1], _sca[2]);
		return object;
	} #endregion
}