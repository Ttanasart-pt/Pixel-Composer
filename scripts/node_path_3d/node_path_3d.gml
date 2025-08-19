#region functions
	FN_NODE_TOOL_INVOKE {
		hotkeyTool("Node_Path_3D", "Transform", "G");
		hotkeyTool("Node_Path_3D", "Rotate",    "R");
		hotkeyTool("Node_Path_3D", "Scale",     "S");
		
		hotkeyTool("Node_Path_3D", "Anchor add / remove", "A");
		hotkeyTool("Node_Path_3D", "Edit Control point",  "C");
	});
	
	enum _ANCHOR3 {
		  x,   y,   z,
		c1x, c1y, c1z,
		c2x, c2y, c2z,
		
		ind, amount
	}
	
	function __vec3P(_x = 0, _y = _x, _z = _x, _w = 1) : __vec3(_x, _y, _z) constructor {
		weight = _w;
		static clone = function() /*=>*/ {return new __vec3P(x, y, z, weight)};
	}
	
	function d3d_path_tool_position(_node) : ToolObject() constructor {
		activeKeyboard = false;
		setNode(_node);
		
		drag_axis  = noone;
		drag_prev  = 0;
		
		original_values = [];
		drag_original   = new __vec3();
		
		drag_origin_x = 0; drag_origin_y = 0; drag_origin_z = 0;
		drag_dx       = 0; drag_dy       = 0; drag_dz       = 0;
		
		drag_mx = 0; drag_my = 0;
		drag_px = 0; drag_py = 0;
		axis_hover = noone;
		
		sz = 64;
		hs = sz / 2;
		sq = 8;
		ga = [0,0,0,0,0,0];
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			activeKeyboard = true;
		}
		
		function drawOverlay3D(active, _mx, _my, _snx, _sny, _params) {
			if(array_empty(node.anchor_select)) { PANEL_PREVIEW.resetTool(); return; }
			
			#region ---- main ----
				var _qinv = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
				
				var _camera = _params.scene.camera;
				var _panel  = _params.panel;
				var _qview  = new BBMOD_Quaternion().FromEuler(_camera.focus_angle_y, -_camera.focus_angle_x, 0);
				
				var _hover     = noone;
				var _hoverDist = 10;
				
				var cx = node.anchor_select_cx;
				var cy = node.anchor_select_cy;
		
				var _amo = array_length(node.anchor_select);
			#endregion
				
			#region display
				ga[0] = new BBMOD_Vec3(-sz, 0, 0);
				ga[1] = new BBMOD_Vec3(0, -sz, 0);
				ga[2] = new BBMOD_Vec3(0, 0, -sz);
				
				ga[3] = [	new BBMOD_Vec3(-hs + sq, -hs - sq,        0),
							new BBMOD_Vec3(-hs - sq, -hs - sq,        0), 
							new BBMOD_Vec3(-hs - sq, -hs + sq,        0), 
							new BBMOD_Vec3(-hs + sq, -hs + sq,        0), ];
				ga[4] = [	new BBMOD_Vec3(       0, -hs + sq, -hs - sq),
							new BBMOD_Vec3(       0, -hs - sq, -hs - sq), 
							new BBMOD_Vec3(       0, -hs - sq, -hs + sq), 
							new BBMOD_Vec3(       0, -hs + sq, -hs + sq), ];
				ga[5] = [	new BBMOD_Vec3(-hs + sq,        0, -hs - sq),
							new BBMOD_Vec3(-hs - sq,        0, -hs - sq), 
							new BBMOD_Vec3(-hs - sq,        0, -hs + sq), 
							new BBMOD_Vec3(-hs + sq,        0, -hs + sq), ];
					
				for( var i = 0; i < 3; i++ ) {
					ga[i] = _qview.Rotate(_qinv.Rotate(ga[i]));
					
					var th = 2 + (axis_hover == i || drag_axis == i);
					if(drag_axis != noone && drag_axis != i)
						continue;
					
					draw_set_color(COLORS.axis[i]);
					if(point_distance(cx, cy, cx + ga[i].X, cy + ga[i].Y) < 5)
						draw_line_round(cx, cy, cx + ga[i].X, cy + ga[i].Y, th);
					else 
						draw_line_round_arrow(cx, cy, cx + ga[i].X, cy + ga[i].Y, th, 3);
					
					var _d = distance_to_line(_mx, _my, cx, cy, cx + ga[i].X, cy + ga[i].Y);
					if(_d < _hoverDist) {
						_hover     =  i;
						_hoverDist = _d;
					}
				}
				
				for( var i = 3; i < 6; i++ ) {
					for( var j = 0; j < 4; j++ )
						ga[i][j] = _qview.Rotate(_qinv.Rotate(ga[i][j]));
					
					var th = 1;
					
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
			#endregion display
			
			if(drag_axis != noone) { // editing
				var mAdj, nor, prj, pln;
				var edit = false;
				
				if(!MOUSE_WRAPPING) {
					if(KEYBOARD_NUMBER == undefined) {
						drag_mx += _mx - drag_px;
						drag_my += _my - drag_py;
							
						var ray = _camera.viewPointToWorldRay(drag_mx, drag_my);
						
						if(drag_axis < 3) {
							switch(drag_axis) {
								case 0 : nor = new __vec3(0, 1, 0); prj = new __vec3(1, 0, 0); break;
								case 1 : nor = new __vec3(0, 0, 1); prj = new __vec3(0, 1, 0); break;
								case 2 : nor = new __vec3(1, 0, 0); prj = new __vec3(0, 0, 1); break;
							}
							
							pln  = new __plane(drag_original, nor);
							mAdj = d3d_intersect_ray_plane(ray, pln);
							
							if(drag_prev != undefined) {
								var _diff = mAdj.subtract(drag_prev);
								var _dist = _diff.dot(prj);
								
								drag_dx += prj.x * _dist;
								drag_dy += prj.y * _dist;
								drag_dz += prj.z * _dist;
							}
							
						} else {
							switch(drag_axis) {
								case 3 : nor = new __vec3(0, 0, 1); break;
								case 4 : nor = new __vec3(1, 0, 0); break;
								case 5 : nor = new __vec3(0, 1, 0); break;
							}
								
							pln  = new __plane(drag_original, nor);
							mAdj = d3d_intersect_ray_plane(ray, pln);
								
							if(drag_prev != undefined) {
								var _diff = mAdj.subtract(drag_prev);
								
								drag_dx += _diff.x;
								drag_dy += _diff.y;
								drag_dz += _diff.z;
								
							}
						}
						
						for( var i = 0; i < _amo; i++ ) {
							var _i    = node.anchor_select[i];
							var _ind  = node.input_fix_len + _i;
							var _orig = original_values[_i];
							
							var val = array_clone(_orig);
							val[0] += drag_dx;
							val[1] += drag_dy;
							val[2] += drag_dz;
							
							if(node.inputs[_ind].setValue(val)) edit = true;
						}
						
						drag_prev = mAdj;
						
					} else {
						for( var i = 0; i < _amo; i++ ) {
							var _i    = node.anchor_select[i];
							var _ind  = node.input_fix_len + _i;
							var _orig = original_values[_i];
							
							var val = array_clone(_orig);
							if(drag_axis < 3) val[drag_axis] += KEYBOARD_NUMBER;
							
							if(node.inputs[_ind].setValue(val)) edit = true;
						}
					}
					
					if(edit) UNDO_HOLDING = true;
				}
					
				setMouseWrap();
				drag_px = _mx;
				drag_py = _my;
				
				if((!activeKeyboard && mouse_release(mb_left)) || (activeKeyboard && (mouse_press(mb_left) || key_press(vk_enter))) ) {
					if(activeKeyboard) PANEL_PREVIEW.resetTool();
					
					drag_axis      = noone;
					UNDO_HOLDING   = false;
					activeKeyboard = false;
				}
				
				if(key_press(ord("X"))) {
					drag_axis = drag_axis == 0? 3 : 0;
					drag_prev = undefined;
					
					drag_dx = 0; 
					drag_dy = 0; 
					drag_dz = 0;
					
					KEYBOARD_STRING = "";
				}
				
				if(key_press(ord("Y"))) {
					drag_axis = drag_axis == 1? 3 : 1;
					drag_prev = undefined;
					
					drag_dx = 0; 
					drag_dy = 0; 
					drag_dz = 0;
					
					KEYBOARD_STRING = "";
				}
				
				if(key_press(ord("Z"))) {
					drag_axis = drag_axis == 2? 3 : 2;
					drag_prev = undefined;
					
					drag_dx = 0; 
					drag_dy = 0; 
					drag_dz = 0;
					
					KEYBOARD_STRING = "";
				}
				
				var _tooltipText = "Dragging";
				switch(drag_axis) {
					case 0 : _tooltipText += " X"; break;
					case 1 : _tooltipText += " Y"; break;
					case 2 : _tooltipText += " Z"; break;
					
					case 3 : _tooltipText += " XY"; break;
					case 4 : _tooltipText += " YZ"; break;
					case 5 : _tooltipText += " XZ"; break;
				}
				
				if(KEYBOARD_NUMBER != undefined)
					_tooltipText += $" [{KEYBOARD_NUMBER}]";
				
				PANEL_PREVIEW.setActionTooltip(_tooltipText);
				
			} else {
				if((_hover != noone && mouse_press(mb_left)) || activeKeyboard) {
					drag_axis = activeKeyboard? 3 : _hover;
					drag_mx	= _mx; drag_my = _my;
					drag_px = _mx; drag_py = _my;
					
					drag_prev = undefined;
					
					drag_origin_x = 0;
					drag_origin_y = 0;
					drag_origin_z = 0;
					
					for( var i = 0; i < _amo; i++ ) {
						var _i = node.anchor_select[i];
						var _a = node.anchors[_i];
					
						drag_origin_x += _a[0];
						drag_origin_y += _a[1];
						drag_origin_z += _a[2];
					}
						
					drag_origin_x /= _amo;
					drag_origin_y /= _amo;
					drag_origin_z /= _amo;
					
					drag_original = new __vec3(drag_origin_x, drag_origin_y, drag_origin_z);
					
					drag_dx = 0; 
					drag_dy = 0; 
					drag_dz = 0;
					
					original_values = array_verify(original_values, array_length(node.anchors));
					for( var i = 0, n = array_length(node.anchors); i < n; i++ ) 
						original_values[i] = array_clone(node.anchors[i]);
				}
			}
		}
	}
	
	function d3d_path_tool_rotation(_node) : ToolObject() constructor {
		activeKeyboard = false;
		setNode(_node);
		
		drag_axis  = noone;
		drag_prev  = 0;
		
		original_values = [];
		drag_original   = new __vec3();
		
		drag_origin_x = 0; drag_origin_y = 0; drag_origin_z = 0;
		drag_accu_rot = 0; 
		
		drag_mx = 0; drag_my = 0;
		drag_px = 0; drag_py = 0;
		axis_hover = noone;
		
		sz = 64;
		hs = sz / 2;
		sq = 8;
		ga = [0,0,0,0,0,0];
		
		cx = 0;
		cy = 0;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			activeKeyboard = true;
		}
		
		function drawOverlay3D(active, _mx, _my, _snx, _sny, _params) {
			if(array_empty(node.anchor_select)) { PANEL_PREVIEW.resetTool(); return; }
			
			#region ---- main ----
				var _qinv = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
				
				var _camera = _params.scene.camera;
				var _panel  = _params.panel;
				var _qview  = new BBMOD_Quaternion().FromEuler(_camera.focus_angle_y, -_camera.focus_angle_x, 0);
				
				var _hover     = noone;
				var _hoverDist = 10;
				
				var _amo = array_length(node.anchor_select);
			#endregion
				
			#region display
				for( var i = 0; i < 3; i++ ) {
					var op, np;
					var th = 2 + (axis_hover == i || drag_axis == i);
					
					if(drag_axis != noone && drag_axis != i)
						continue;
						
					draw_set_color(COLORS.axis[i]);
					for( var j = 0; j <= 32; j++ ) {
						var ang = j / 32 * 360;
						
						switch(i) {
							case 0 : np = new BBMOD_Vec3(0, lengthdir_x(sz, ang), lengthdir_y(sz, ang)); break;
							case 1 : np = new BBMOD_Vec3(lengthdir_x(sz, ang), 0, lengthdir_y(sz, ang)); break;
							case 2 : np = new BBMOD_Vec3(lengthdir_x(sz, ang), lengthdir_y(sz, ang), 0); break;
						}
						
						np = _qview.Rotate(_qinv.Rotate(np));
						
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
			#endregion
			
			if(drag_axis != noone) { // editing
				var mAdj, nor, prj, pln;
				var _rotator;
				var edit = false;
				
				if(!MOUSE_WRAPPING) {
					if(KEYBOARD_NUMBER == undefined) {
						var mAng = point_direction(cx, cy, _mx, _my);
						
						if(drag_prev != undefined)
							drag_accu_rot += drag_prev - mAng;
						drag_prev = mAng;
						
					} else 
						drag_accu_rot = KEYBOARD_NUMBER;
					
					switch(drag_axis) {
						case 0 : _rotator = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), drag_accu_rot); break;
						case 1 : _rotator = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(0, 1, 0), drag_accu_rot); break;
						case 2 : _rotator = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(0, 0, 1), drag_accu_rot); break;
					}
					
					for( var i = 0; i < _amo; i++ ) {
						var _i    = node.anchor_select[i];
						var _ind  = node.input_fix_len + _i;
						var _orig = original_values[_i];
						
						var _vv  = new BBMOD_Vec3(_orig[0] - drag_origin_x, _orig[1] - drag_origin_y, _orig[2] - drag_origin_z);
						var _vr  = _rotator.Rotate(_vv);
						var _val = array_clone(_orig);
						
						_val[0] = drag_origin_x + _vr.X;
						_val[1] = drag_origin_y + _vr.Y;
						_val[2] = drag_origin_z + _vr.Z;
						
						var _vv  = new BBMOD_Vec3(_orig[3], _orig[4], _orig[5]);
						var _vr  = _rotator.Rotate(_vv);
						
						_val[3] = _vr.X;
						_val[4] = _vr.Y;
						_val[5] = _vr.Z;
						
						var _vv  = new BBMOD_Vec3(_orig[6], _orig[7], _orig[8]);
						var _vr  = _rotator.Rotate(_vv);
						
						_val[6] = _vr.X;
						_val[7] = _vr.Y;
						_val[8] = _vr.Z;
						
						if(node.inputs[_ind].setValue(_val)) edit = true;
					}
					
					if(edit) UNDO_HOLDING = true;
				}
					
				setMouseWrap();
				drag_px = _mx;
				drag_py = _my;
				
				if((!activeKeyboard && mouse_release(mb_left)) || (activeKeyboard && (mouse_press(mb_left) || key_press(vk_enter))) ) {
					if(activeKeyboard) PANEL_PREVIEW.resetTool();
					
					drag_axis      = noone;
					UNDO_HOLDING   = false;
					activeKeyboard = false;
				}
				
				if(drag_axis != 0 && key_press(ord("X"))) {
					drag_axis = 0;
					drag_accu_rot = 0; 
					drag_prev = undefined;
					KEYBOARD_STRING = "";
				}
				
				if(drag_axis != 1 && key_press(ord("Y"))) {
					drag_axis = 1;
					drag_accu_rot = 0; 
					drag_prev = undefined;
					KEYBOARD_STRING = "";
				}
				
				if(drag_axis != 2 && key_press(ord("Z"))) {
					drag_axis = 2;
					drag_accu_rot = 0; 
					drag_prev = undefined;
					KEYBOARD_STRING = "";
				}
				
				var _tooltipText = "Rotating";
				switch(drag_axis) {
					case 0 : _tooltipText += " X"; break;
					case 1 : _tooltipText += " Y"; break;
					case 2 : _tooltipText += " Z"; break;
					
					case 3 : _tooltipText += " XY"; break;
					case 4 : _tooltipText += " YZ"; break;
					case 5 : _tooltipText += " XZ"; break;
				}
				
				if(KEYBOARD_NUMBER != undefined)
					_tooltipText += $" [{KEYBOARD_NUMBER}]";
				
				PANEL_PREVIEW.setActionTooltip(_tooltipText);
				
			} else {
				if((_hover != noone && mouse_press(mb_left)) || activeKeyboard) {
					drag_axis = activeKeyboard? 2 : _hover;
					drag_mx	= _mx; drag_my = _my;
					drag_px = _mx; drag_py = _my;
					
					drag_prev = undefined;
					
					drag_origin_x = 0;
					drag_origin_y = 0;
					drag_origin_z = 0;
					
					for( var i = 0; i < _amo; i++ ) {
						var _i = node.anchor_select[i];
						var _a = node.anchors[_i];
					
						drag_origin_x += _a[0];
						drag_origin_y += _a[1];
						drag_origin_z += _a[2];
					}
						
					drag_origin_x /= _amo;
					drag_origin_y /= _amo;
					drag_origin_z /= _amo;
					
					drag_original = new __vec3(drag_origin_x, drag_origin_y, drag_origin_z);
					drag_accu_rot = 0; 
					
					original_values = array_verify(original_values, array_length(node.anchors));
					for( var i = 0, n = array_length(node.anchors); i < n; i++ ) 
						original_values[i] = array_clone(node.anchors[i]);
					
					cx = node.anchor_select_cx;
					cy = node.anchor_select_cy;
					
				}
			}
		}
	}
	
	function d3d_path_tool_scale(_node) : ToolObject() constructor {
		activeKeyboard = false;
		setNode(_node);
		
		drag_axis  = noone;
		
		original_values = [];
		
		drag_origin_x = 0; drag_origin_y = 0; drag_origin_z = 0;
		drag_mx = 0; drag_my = 0;
		drag_px = 0; drag_py = 0;
		axis_hover = noone;
		
		sz = 64;
		hs = sz / 2;
		sq = 8;
		ga = [0,0,0,0,0,0];
		
		cx = 0;
		cy = 0;

		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			activeKeyboard = true;
		}
		
		function drawOverlay3D(active, _mx, _my, _snx, _sny, _params) {
			if(array_empty(node.anchor_select)) { PANEL_PREVIEW.resetTool(); return; }
			
			#region ---- main ----
				var _qinv = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
				
				var _camera = _params.scene.camera;
				var _panel  = _params.panel;
				var _qview  = new BBMOD_Quaternion().FromEuler(_camera.focus_angle_y, -_camera.focus_angle_x, 0);
				
				var _hover     = noone;
				var _hoverDist = 10;
				
				var _amo = array_length(node.anchor_select);
			#endregion
				
			#region display
				ga[0] = new BBMOD_Vec3(-sz, 0, 0);
				ga[1] = new BBMOD_Vec3(0, -sz, 0);
				ga[2] = new BBMOD_Vec3(0, 0, -sz);
				
				ga[3] = [	new BBMOD_Vec3(-hs + sq, -hs - sq,        0),
							new BBMOD_Vec3(-hs - sq, -hs - sq,        0), 
							new BBMOD_Vec3(-hs - sq, -hs + sq,        0), 
							new BBMOD_Vec3(-hs + sq, -hs + sq,        0), ];
				ga[4] = [	new BBMOD_Vec3(       0, -hs + sq, -hs - sq),
							new BBMOD_Vec3(       0, -hs - sq, -hs - sq), 
							new BBMOD_Vec3(       0, -hs - sq, -hs + sq), 
							new BBMOD_Vec3(       0, -hs + sq, -hs + sq), ];
				ga[5] = [	new BBMOD_Vec3(-hs + sq,        0, -hs - sq),
							new BBMOD_Vec3(-hs - sq,        0, -hs - sq), 
							new BBMOD_Vec3(-hs - sq,        0, -hs + sq), 
							new BBMOD_Vec3(-hs + sq,        0, -hs + sq), ];
					
				for( var i = 0; i < 3; i++ ) {
					ga[i] = _qview.Rotate(_qinv.Rotate(ga[i]));
					
					var th = 2 + (axis_hover == i || drag_axis == i);
					if(drag_axis != noone && drag_axis != i)
						continue;
					
					draw_set_color(COLORS.axis[i]);
					if(point_distance(cx, cy, cx + ga[i].X, cy + ga[i].Y) < 5)
						draw_line_round(cx, cy, cx + ga[i].X, cy + ga[i].Y, th);
					else 
						draw_line_round_arrow(cx, cy, cx + ga[i].X, cy + ga[i].Y, th, 3);
					
					var _d = distance_to_line(_mx, _my, cx, cy, cx + ga[i].X, cy + ga[i].Y);
					if(_d < _hoverDist) {
						_hover     =  i;
						_hoverDist = _d;
					}
				}
				
				for( var i = 3; i < 6; i++ ) {
					for( var j = 0; j < 4; j++ )
						ga[i][j] = _qview.Rotate(_qinv.Rotate(ga[i][j]));
					
					var th = 1;
					
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
			#endregion display
			
			if(drag_axis != noone) { // editing
				var mAdj, nor, prj, pln;
				var edit = false;
				
				if(!MOUSE_WRAPPING) {
					var _ss = KEYBOARD_NUMBER ?? (point_distance(cx, cy, _mx, _my) / point_distance(cx, cy, drag_mx, drag_my));
					var _sx = _ss, _sy = _ss, _sz = _ss;
					
					switch(drag_axis) {
						case 0 : _sx = _ss; _sy =   1; _sz =   1; break;
						case 1 : _sx =   1; _sy = _ss; _sz =   1; break;
						case 2 : _sx =   1; _sy =   1; _sz = _ss; break;
						
						case 3 : _sx = _ss; _sy = _ss; _sz =   1; break;
						case 4 : _sx =   1; _sy = _ss; _sz = _ss; break;
						case 5 : _sx = _ss; _sy =   1; _sz = _ss; break;
						
						case 6 : _sx = _ss; _sy = _ss; _sz = _ss; break;
					}
					
					for( var i = 0; i < _amo; i++ ) {
						var _i    = node.anchor_select[i];
						var _ind  = node.input_fix_len + _i;
						var _orig = original_values[_i];
						var val   = array_clone(_orig);
						
						val[0] = drag_origin_x + (val[0] - drag_origin_x) * _sx;
						val[1] = drag_origin_y + (val[1] - drag_origin_y) * _sy;
						val[2] = drag_origin_z + (val[2] - drag_origin_z) * _sz;
						
						val[3] = val[3] * _sx;
						val[4] = val[4] * _sy;
						val[5] = val[5] * _sz;
						
						val[6] = val[6] * _sx;
						val[7] = val[7] * _sy;
						val[8] = val[8] * _sz;
						
						if(node.inputs[_ind].setValue(val)) edit = true;
					}
					
					if(edit) UNDO_HOLDING = true;
				}
					
				setMouseWrap();
				drag_px = _mx;
				drag_py = _my;
				
				if((!activeKeyboard && mouse_release(mb_left)) || (activeKeyboard && (mouse_press(mb_left) || key_press(vk_enter))) ) {
					if(activeKeyboard) PANEL_PREVIEW.resetTool();
					
					drag_axis      = noone;
					UNDO_HOLDING   = false;
					activeKeyboard = false;
				}
				
				if(key_press(ord("X"))) {
					drag_axis = drag_axis == 0? 6 : 0;
					KEYBOARD_STRING = "";
				}
				
				if(key_press(ord("Y"))) {
					drag_axis = drag_axis == 1? 6 : 1;
					KEYBOARD_STRING = "";
				}
				
				if(key_press(ord("Z"))) {
					drag_axis = drag_axis == 2? 6 : 2;
					KEYBOARD_STRING = "";
				}
				
				var _tooltipText = "Dragging";
				switch(drag_axis) {
					case 0 : _tooltipText += " X"; break;
					case 1 : _tooltipText += " Y"; break;
					case 2 : _tooltipText += " Z"; break;
					
					case 3 : _tooltipText += " XY"; break;
					case 4 : _tooltipText += " YZ"; break;
					case 5 : _tooltipText += " XZ"; break;
					
					case 6 : _tooltipText += " XYZ"; break;
				}
				
				if(KEYBOARD_NUMBER != undefined)
					_tooltipText += $" [{KEYBOARD_NUMBER}]";
				
				PANEL_PREVIEW.setActionTooltip(_tooltipText);
				
			} else {
				if((_hover != noone && mouse_press(mb_left)) || activeKeyboard) {
					drag_axis = activeKeyboard? 6 : _hover;
					drag_mx	= _mx; drag_my = _my;
					drag_px = _mx; drag_py = _my;
					
					drag_origin_x = 0;
					drag_origin_y = 0;
					drag_origin_z = 0;
					
					for( var i = 0; i < _amo; i++ ) {
						var _i = node.anchor_select[i];
						var _a = node.anchors[_i];
					
						drag_origin_x += _a[0];
						drag_origin_y += _a[1];
						drag_origin_z += _a[2];
					}
						
					drag_origin_x /= _amo;
					drag_origin_y /= _amo;
					drag_origin_z /= _amo;
					
					original_values = array_verify(original_values, array_length(node.anchors));
					for( var i = 0, n = array_length(node.anchors); i < n; i++ ) 
						original_values[i] = array_clone(node.anchors[i]);
					
					cx = node.anchor_select_cx;
					cy = node.anchor_select_cy;
				}
			}
		}
	}
	
#endregion

function Node_Path_3D(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Path 3D";
	is_3D = NODE_3D.polygon;
	
	setDimension(96, 48);
	
	////- =Path
	newInput(1, nodeValue_Bool( "Loop",         false )).rejectArray();
	newInput(3, nodeValue_Bool( "Round anchor", false )).rejectArray();
	
	////- =Sampling
	newInput(0, nodeValue_Slider(      "Path progress", 0 )).setTooltip("Sample position from path.");
	newInput(2, nodeValue_Enum_Scroll( "Progress mode", 0, ["Entire line", "Segment"])).rejectArray();
	// inputs 4 
		
	newOutput(0, nodeValue_Output( "Position out", VALUE_TYPE.float,    [0,0] )).setDisplay(VALUE_DISPLAY.vector);
	newOutput(1, nodeValue_Output( "Path data",    VALUE_TYPE.pathnode, self  ));
	newOutput(2, nodeValue_Output( "Anchors",      VALUE_TYPE.float,    []    )).setVisible(false).setArrayDepth(1);
	
	input_display_list = [
		[ "Path",     false ], 1, 3, 
		[ "Sampling", false ], 0, 2, 
		[ "Anchors",  false ], 
	];
	
	output_display_list  = [ 1, 0, 2 ];
	
	function createNewInput(index = array_length(inputs),
	                                   _x = 0,   _y = 0,   _z = 0, 
									 _dxx = 0, _dxy = 0, _dxz = 0, 
									 _dyx = 0, _dyy = 0, _dyz = 0, rec = true) {
		
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue_Path_Anchor_3D("Anchor", []))
			.setValue([ _x, _y, _z, _dxx, _dxy, _dxz, _dyx, _dyy, _dyz, false ]);
		
		if(!rec) return inputs[index];
		
		recordAction(ACTION_TYPE.array_insert, inputs, [ inputs[index], index, $"add path anchor point {index}" ]);
		resetDisplayList();
		
		return inputs[index];
	}
	
	setDynamicInput(1, false);
	
	////- Nodes
	
	path_preview_surface = noone;
		
	#region ---- path ----
		path_loop    = false;
		anchors		 = [];
		anchor_view  = [];
		segments     = [];
		lengths		 = [];
		lengthAccs	 = [];
		lengthTotal	 = 0;
		boundary     = new BoundingBox3D();
		
		cached_pos = ds_map_create();
	#endregion
	
	#region ---- attributes ----
		attributes.display_name = false;
		attributes.snap_point   = true;
		attributes.snap_distance= 8;
		
		array_push(attributeEditors, "Display");
		array_push(attributeEditors, ["Display name", function() /*=>*/ {return attributes.display_name}, new checkBox(function() /*=>*/ {return toggleAttribute("display_name")})]);
		
		array_push(attributeEditors, "Snap");
		array_push(attributeEditors, ["Snap Enable",  function() /*=>*/ {return attributes.snap_point},    new checkBox(function() /*=>*/ {return toggleAttribute("snap_point")})]);
		array_push(attributeEditors, ["Snap Distance",function() /*=>*/ {return attributes.snap_distance}, textBox_Number(function(v) /*=>*/ {return setAttribute("snap_distance", v)})]);
	#endregion
	
	#region ---- editor ----
		tool_object_pos = new d3d_path_tool_position(self);
		tool_object_rot = new d3d_path_tool_rotation(self);
		tool_object_sca = new d3d_path_tool_scale(self);
		
		tool_pos = new NodeTool( "Transform", THEME.tools_3d_transform, "Node_Path_3D" ).setToolObject(tool_object_pos);
		tool_rot = new NodeTool( "Rotate",    THEME.tools_3d_rotate,    "Node_Path_3D" ).setToolObject(tool_object_rot);
		tool_sca = new NodeTool( "Scale",     THEME.tools_3d_scale,     "Node_Path_3D" ).setToolObject(tool_object_sca);
		
		tools = [
			tool_pos, tool_rot, tool_sca, -1, 
			new NodeTool( "Anchor add / remove", THEME.path_tools_add       ),
			new NodeTool( "Edit Control point",  THEME.path_tools_anchor    ),
		];
		
		line_hover = -1;
	
		drag_point    = -1;
		drag_points   = [];
		drag_type     = 0;
		drag_point_mx = 0;
		drag_point_my = 0;
		drag_point_mz = 0;
		
		drag_point_sx = 0;
		drag_point_sy = 0;
		drag_point_sz = 0;
		
		drag_plane        = noone;
		drag_plane_origin = new __vec3();
		drag_plane_normal = new __vec3();
		
		transform_type = 0;
		
		transform_minx = 0; transform_miny = 0; transform_minz = 0;
		transform_maxx = 0; transform_maxy = 0; transform_maxz = 0;
		
		transform_cx = 0;   transform_cy = 0;   transform_cz = 0;
		transform_sx = 0;   transform_sy = 0;   transform_sz = 0;
		transform_mx = 0;   transform_my = 0;   transform_mz = 0;
		
		anchor_freeze   = 0;
		anchor_select   = [];
		anchor_focus    = undefined;
		
		anchor_select_cx = 0;
		anchor_select_cy = 0;
	#endregion
	
	static resetDisplayList = function() {
		recordAction(ACTION_TYPE.var_modify,  self, [ array_clone(input_display_list), "input_display_list" ]);
		
		input_display_list = array_clone(input_display_list_raw);
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			array_push(input_display_list, i);
			inputs[i].name = $"Anchor {i - input_fix_len}";
		}
	}
	
	static onValueUpdate = function(index = 0) {
		if(index == 2) {
			var type = getInputData(2);	
			
			     if(type == 0) inputs[0].setDisplay(VALUE_DISPLAY.slider);
			else if(type == 1) inputs[0].setDisplay(VALUE_DISPLAY._default);
		}
	}
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {}
	
	static drawOverlay3D = function(active, _mx, _my, _snx, _sny, _params) {
		var ansize = array_length(inputs) - input_fix_len;
		var edited = false;
		
		var _qinv  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
	
		var _camera = _params.scene.camera;
		var _qview  = new BBMOD_Quaternion().FromEuler(_camera.focus_angle_y, -_camera.focus_angle_x, 0);
		var ray     = _camera.viewPointToWorldRay(_mx, _my);
		var _tooln  = getUsingToolName();
		
		/////////////////////////////////////////////////////// EDIT ///////////////////////////////////////////////////////
		
		if(drag_point > -1) { 
			var mAdj = d3d_intersect_ray_plane(ray, drag_plane);
			
			var dx = drag_point_sx + mAdj.x - drag_point_mx;
			var dy = drag_point_sy + mAdj.y - drag_point_my;
			var dz = drag_point_sz + mAdj.z - drag_point_mz;
			
			if(drag_type < 2) { // move points
				var inp = inputs[input_fix_len + drag_point];
				var anc = array_clone(inp.getValue());
				
				if(drag_type != 0 && key_mod_down(SHIFT))
					anc[_ANCHOR3.ind] = !anc[_ANCHOR3.ind];
				
				if(drag_type == 0) { //drag anchor point
					anc[_ANCHOR3.x] = dx;
					anc[_ANCHOR3.y] = dy;
					anc[_ANCHOR3.z] = dz;
					
					if(key_mod_press(CTRL)) {
						anc[_ANCHOR3.x] = round(anc[_ANCHOR3.x]);
						anc[_ANCHOR3.y] = round(anc[_ANCHOR3.y]);
						anc[_ANCHOR3.z] = round(anc[_ANCHOR3.z]);
					}
					
				} else if(drag_type == 1) { //drag control 1
					anc[_ANCHOR3.c1x] = dx - anc[_ANCHOR3.x];
					anc[_ANCHOR3.c1y] = dy - anc[_ANCHOR3.y];
					anc[_ANCHOR3.c1z] = dz - anc[_ANCHOR3.z];
					
					if(!anc[_ANCHOR3.ind]) {
						anc[_ANCHOR3.c2x] = -anc[_ANCHOR3.c1x];
						anc[_ANCHOR3.c2y] = -anc[_ANCHOR3.c1y];
						anc[_ANCHOR3.c2z] = -anc[_ANCHOR3.c1z];
					}
					
					if(key_mod_press(CTRL)) {
						anc[_ANCHOR3.c1x] = round(anc[_ANCHOR3.c1x]);
						anc[_ANCHOR3.c1y] = round(anc[_ANCHOR3.c1y]);
						anc[_ANCHOR3.c1z] = round(anc[_ANCHOR3.c1z]);
						
						if(!anc[_ANCHOR3.ind]) {
							anc[_ANCHOR3.c2x] = round(anc[_ANCHOR3.c2x]);
							anc[_ANCHOR3.c2y] = round(anc[_ANCHOR3.c2y]);
							anc[_ANCHOR3.c2z] = round(anc[_ANCHOR3.c2z]);
						}
					}
					
				} else if(drag_type == -1) { //drag control 2
					anc[_ANCHOR3.c2x] = dx - anc[_ANCHOR3.x];
					anc[_ANCHOR3.c2y] = dy - anc[_ANCHOR3.y];
					anc[_ANCHOR3.c2z] = dz - anc[_ANCHOR3.z];
					
					if(!anc[_ANCHOR3.ind]) {
						anc[_ANCHOR3.c1x] = -anc[_ANCHOR3.c2x];
						anc[_ANCHOR3.c1y] = -anc[_ANCHOR3.c2y];
						anc[_ANCHOR3.c1z] = -anc[_ANCHOR3.c2z];
					}
					
					if(key_mod_press(CTRL)) {
						anc[_ANCHOR3.c2x] = round(anc[_ANCHOR3.c2x]);
						anc[_ANCHOR3.c2y] = round(anc[_ANCHOR3.c2y]);
						anc[_ANCHOR3.c2z] = round(anc[_ANCHOR3.c2z]);
						
						if(!anc[_ANCHOR3.ind]) {
							anc[_ANCHOR3.c1x] = round(anc[_ANCHOR3.c1x]);
							anc[_ANCHOR3.c1y] = round(anc[_ANCHOR3.c1y]);
							anc[_ANCHOR3.c1z] = round(anc[_ANCHOR3.c1z]);
						}
					}
				} 
				
				if(inp.setValue(anc))
					edited = true;
			}
			
			if(edited) UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_point = -1;
				RENDER_ALL
				UNDO_HOLDING = false;
			}
		}
		
		/////////////////////////////////////////////////////// DRAW PATH ///////////////////////////////////////////////////////
		
		var _line_hover  = -1;
		var anchor_hover = -1;
		var hover_type   = 0;
		var hovering     = false;
		
		var minx =  99999, miny =  99999, minz =  99999;
		var maxx = -99999, maxy = -99999, maxz = -99999;
				
		anchor_view = array_verify(anchor_view, array_length(anchors));
				
		if(!array_empty(anchors)) {
			draw_set_color(COLORS._main_accent);
			
			var _v3 = new __vec3();
			
			for( var i = 0, n = array_length(segments); i < n; i++ ) {
				var _seg = segments[i];
				
				var _px = 0, _py = 0, _pz = 0; 
				var _ox = 0, _oy = 0; 
				var _nx = 0, _ny = 0; 
				var  p  = 0;
					
				for( var j = 0, m = array_length(_seg); j < m; j += 3 ) {
					_v3.x = _seg[j + 0];
					_v3.y = _seg[j + 1];
					_v3.z = _seg[j + 2];
					
					var _posView = _camera.worldPointToViewPoint(_v3);
					_nx = _posView.x;
					_ny = _posView.y;
					
					minx = min(minx, _nx); miny = min(miny, _ny);
					maxx = max(maxx, _nx); maxy = max(maxy, _ny);
					
					if(j) {
						if((key_mod_press(CTRL) || isUsingTool(1)) && distance_to_line(_mx, _my, _ox, _oy, _nx, _ny) < 4)
							_line_hover = i;
						draw_line_width(_ox, _oy, _nx, _ny, 1 + 2 * (line_hover == i));
					}
					
					_ox = _nx;
					_oy = _ny;
				}
			}
			
			var _showAnchor = true;
			switch(_tooln) {
				case "Weight edit" : 
					_showAnchor = false;
					break;
			}
			
			if(_showAnchor)
			for(var i = 0; i < ansize; i++) {
				var _a = anchors[i];
				_v3.x  = _a[0];
				_v3.y  = _a[1];
				_v3.z  = _a[2];
				
				_posView = _camera.worldPointToViewPoint(_v3);
				var xx   = _posView.x;
				var yy   = _posView.y;
				var cont = false;
				var _ax0 = 0, _ay0 = 0;
				var _ax1 = 0, _ay1 = 0;
				
				anchor_view[i] = [ xx,yy ];
				
				if(array_length(_a) < 6) continue;
				
				if(_a[2] != 0 || _a[3] != 0 || _a[4] != 0 || _a[5] != 0) {
					_v3.x = _a[0] + _a[3];
					_v3.y = _a[1] + _a[4];
					_v3.z = _a[2] + _a[5];
					
					_posView = _camera.worldPointToViewPoint(_v3);
					_ax0  = _posView.x;
					_ay0  = _posView.y;
					
					_v3.x = _a[0] + _a[6];
					_v3.y = _a[1] + _a[7];
					_v3.z = _a[2] + _a[8];
					
					_posView = _camera.worldPointToViewPoint(_v3);
					_ax1  = _posView.x;
					_ay1  = _posView.y;
					
					cont = true;
		
					draw_set_color(COLORS.node_path_overlay_control_line);
					draw_line(_ax0, _ay0, xx, yy);
					draw_line(_ax1, _ay1, xx, yy);
					
					draw_circle(_ax0, _ay0, ui(3), false);
					draw_circle(_ax1, _ay1, ui(3), false);
				}
				
				var _anHov = 0;
				
				if(drag_point == i) {
					_anHov = 1;
					
				} else if(point_in_circle(_mx, _my, xx, yy, 8)) {
					_anHov = 1;
					anchor_hover = i;
					hover_type   = 0;
					
				} else if(cont && point_in_circle(_mx, _my, _ax0, _ay0, 8)) {
					draw_circle_ui(_ax0, _ay0, 6, 0, COLORS._main_accent);
					anchor_hover = i;
					hover_type   = 1;
					
				} else if(cont && point_in_circle(_mx, _my, _ax1, _ay1, 8)) {
					draw_circle_ui(_ax1, _ay1, 6, 0, COLORS._main_accent);
					anchor_hover =  i;
					hover_type   = -1;
				}
				
				var _type = anchor_focus == i? 2 : 1;
				draw_anchor(_anHov, xx, yy, ui(8), _type);
				
				if(attributes.display_name) {
					draw_set_text(f_p1, fa_left, fa_bottom, COLORS._main_accent);
					draw_text(xx + ui(4), yy - ui(4), inputs[input_fix_len + i].name);
				}
				
			}
		}
		
		line_hover = _line_hover;
		
		/////////////////////////////////////////////////////// TOOLS ///////////////////////////////////////////////////////
		
		if(anchor_hover != -1) { // no tool, dragging existing point
			var _a = array_clone(getInputData(input_fix_len + anchor_hover));
			if(isUsingTool(2) && hover_type == 0) {
				draw_sprite_ui_uniform(THEME.cursor_path_anchor, 0, _mx + 4, _my + 4);
				
				if(mouse_press(mb_left, active)) {
					
					if(_a[3] != 0 || _a[4] != 0 || _a[5] != 0 || _a[6] != 0 || _a[7] != 0 || _a[8] != 0) {
						_a[3] = 0; _a[4] = 0; _a[5] = 0;
						_a[6] = 0; _a[7] = 0; _a[8] = 0;
						_a[9] = false;
						
						inputs[input_fix_len + anchor_hover].setValue(_a);
						
					} else {
						_a[3] = -8; _a[4] = 0; _a[5] = 0;
						_a[6] =  8; _a[7] = 0; _a[8] = 0;
						_a[9] = false;
						
						drag_point    = anchor_hover;
						drag_type     = 1;
						
						drag_plane_origin = new __vec3(_a[0], _a[1], _a[2]);
						drag_plane_normal = ray.direction.multiply(-1)._normalize();
						drag_plane        = new __plane(drag_plane_origin, drag_plane_normal);
						
						var mAdj = d3d_intersect_ray_plane(ray, drag_plane);
						drag_point_mx = mAdj.x;
						drag_point_my = mAdj.y;
						drag_point_mz = mAdj.z;
						
						drag_point_sx = _a[0];
						drag_point_sy = _a[1];
						drag_point_sz = _a[2];
					}
				}
			} else if(hover_type == 0 && key_mod_press(SHIFT)) { //remove
				draw_sprite_ui_uniform(THEME.cursor_path_remove, 0, _mx + 4, _my + 4);
				
				if(mouse_press(mb_left, active)) {
					var _indx = input_fix_len + anchor_hover;
					recordAction(ACTION_TYPE.array_delete, inputs, [ inputs[_indx], _indx, "remove path anchor point" ]);
					
					array_delete(inputs, _indx, 1);
					resetDisplayList();
					triggerRender();
				}
			} else {
				draw_sprite_ui_uniform(THEME.cursor_path_move, 0, _mx + 4, _my + 4);
				
				if(mouse_press(mb_left, active)) {
					if(isUsingTool(2)) {
						_a[_ANCHOR3.ind] = true;
						inputs[input_fix_len + anchor_hover].setValue(_a);
					}

					drag_point    = anchor_hover;
					drag_type     = hover_type;
					
					drag_plane_origin = new __vec3(_a[0], _a[1], _a[2]);
					drag_plane_normal = ray.direction.multiply(-1)._normalize();
					drag_plane        = new __plane(drag_plane_origin, drag_plane_normal);
					
					var mAdj = d3d_intersect_ray_plane(ray, drag_plane);
					drag_point_mx = mAdj.x;
					drag_point_my = mAdj.y;
					drag_point_mz = mAdj.z;
					
					drag_point_sx = _a[0];
					drag_point_sy = _a[1];
					drag_point_sz = _a[2];
					
					if(hover_type == 1) {
						drag_point_sx = _a[0] + _a[3];
						drag_point_sy = _a[1] + _a[4];	
						drag_point_sz = _a[2] + _a[5];	
						
					} else if(hover_type == -1) {
						drag_point_sx = _a[0] + _a[6];
						drag_point_sy = _a[1] + _a[7];
						drag_point_sz = _a[2] + _a[8];
					} 
				}
			}
		
		} else if(key_mod_press(CTRL) || _tooln == "Anchor add / remove") {	// anchor edit
			draw_sprite_ui_uniform(THEME.cursor_path_add, 0, _mx + 4, _my + 4);
			
			if(mouse_press(mb_left, active)) {
				
				drag_plane_origin = new __vec3();
				drag_plane_normal = ray.direction.multiply(-1)._normalize();
				drag_plane        = new __plane(drag_plane_origin, drag_plane_normal);
				var mAdj = d3d_intersect_ray_plane(ray, drag_plane);
				
				var ind = array_length(inputs);
				var anc = createNewInput(, mAdj.x, mAdj.y, mAdj.z, 0, 0, 0, 0, 0, 0, false);
				
				if(_line_hover == -1) {
					drag_point = array_length(inputs) - input_fix_len - 1;
				} else {
					array_remove(inputs, anc);
					array_insert(inputs, input_fix_len + _line_hover + 1, anc);
					drag_point = _line_hover + 1;
					ind = input_fix_len + _line_hover + 1;
				}
				
				recordAction(ACTION_TYPE.array_insert, inputs, [ inputs[ind], ind, $"add path anchor point {ind}" ]);
				resetDisplayList();
				UNDO_HOLDING = true;
				
				drag_type     = -1;
				
				drag_point_mx = mAdj.x;
				drag_point_my = mAdj.y;
				drag_point_mz = mAdj.z;
				
				drag_point_sx = mAdj.x;
				drag_point_sy = mAdj.y;
				drag_point_sz = mAdj.z;
				
				RENDER_ALL
			}
		}
		
		var _show_selecting = isNotUsingTool();
		
		if(isUsingTool()) {
			hovering = true;
			
			var _currTool = PANEL_PREVIEW.tool_current;
			var _tool     = _currTool.getToolObject();
			
			if(_tool != noone) {
				_tool.drawOverlay3D(active, _mx, _my, _snx, _sny, _params);
				if(mouse_lclick()) anchor_freeze = 1;
				_show_selecting = true;
			}
		}
		
		if(_show_selecting) {
			var panel  = _params.panel;
			
			if(anchor_freeze == 0 && panel.selection_selecting && anchor_hover == -1) {
				var sx0 = panel.canvas_x + panel.selection_x0 * panel.canvas_s;
	        	var sy0 = panel.canvas_y + panel.selection_y0 * panel.canvas_s;
	        	var sx1 = panel.canvas_x + panel.selection_x1 * panel.canvas_s;
	        	var sy1 = panel.canvas_y + panel.selection_y1 * panel.canvas_s;
	        	
				anchor_select   = [];
				
				for( var i = 0, n = array_length(anchor_view); i < n; i++ ) {
					var _anc = anchor_view[i];
					
					if(point_in_rectangle(_anc[0], _anc[1], sx0, sy0, sx1, sy1)) 
						array_push(anchor_select, i);
				}
				
			}
			
			if(mouse_lrelease()) 
				anchor_freeze = 0;
		}
		
		var _amo = array_length(anchor_select);
		if(_amo) {
			anchor_select_cx = 0;
			anchor_select_cy = 0;
		
			for( var i = 0; i < _amo; i++ ) {
				var _a   = anchor_select[i];
				var _anc = anchor_view[_a];
				
				draw_anchor(0, _anc[0], _anc[1], ui(8), 2);
				
				anchor_select_cx += _anc[0];
				anchor_select_cy += _anc[1];
			}
			
			anchor_select_cx /= _amo;
			anchor_select_cy /= _amo;
		}
		
		return anchor_hover != -1 || hovering;
	}
	
	static updateLength = function() { 
		boundary     = new BoundingBox();
		segments     = [];
		lengths      = [];
		lengthAccs   = [];
		lengthTotal  = 0;
		
		var _index  = 0;
		var sample  = PREFERENCES.path_resolution;
		var ansize  = array_length(inputs) - input_fix_len;
		if(ansize < 2) return;
		
		var con = path_loop? ansize : ansize - 1;
		
		for(var i = 0; i < con; i++) {
			var _a0 = anchors[(i + 0) % ansize];
			var _a1 = anchors[(i + 1) % ansize];
			
			var l   = 0;
			var _ox = 0, _oy = 0, _oz = 0;
			var _nx = 0, _ny = 0, _nz = 0;
			var p   = 0;
			
			var sg = array_create((sample + 1) * 3);
			
			for(var j = 0; j <= sample; j++) {
				var _t = j / sample;
				
				if(_a0[6] == 0 && _a0[7] == 0 && _a0[8] == 0 && _a1[3] == 0 && _a1[4] == 0 && _a1[5] == 0) {
					_nx = lerp(_a0[0], _a1[0], _t);
					_ny = lerp(_a0[1], _a1[1], _t);
					_nz = lerp(_a0[2], _a1[2], _t);
					
				} else {
					_nx = eval_bezier_n(_t, _a0[0], _a1[0], _a0[0] + _a0[6], _a1[0] + _a1[3]);
					_ny = eval_bezier_n(_t, _a0[1], _a1[1], _a0[1] + _a0[7], _a1[1] + _a1[4]);
					_nz = eval_bezier_n(_t, _a0[2], _a1[2], _a0[2] + _a0[8], _a1[2] + _a1[5]);
					
				}
				
				sg[j * 3 + 0] = _nx;
				sg[j * 3 + 1] = _ny;
				sg[j * 3 + 2] = _nz;
				
				boundary.addPoint(_nx, _ny, _nz);
				if(j) l += point_distance_3d(_nx, _ny, _nz, _ox, _oy, _oz);
				
				_ox = _nx;
				_oy = _ny;
			}
			
			segments[i]   = sg;
			lengths[i]    = l;
			lengthTotal  += l;
			lengthAccs[i] = lengthTotal;
		}
		
		// var minx   = boundary.minx - 8, miny = boundary.miny - 8;
		// var maxx   = boundary.maxx + 8, maxy = boundary.maxy + 8;
		// var rngx   = maxx - minx,   rngy = maxy - miny;
		// var prev_s = 128;
		// var _surf  = surface_create(prev_s, prev_s);
		
		// _surf = surface_verify(_surf, prev_s, prev_s);
		// surface_set_target(_surf);
		// 	DRAW_CLEAR
			
		// 	var ox, oy, nx, ny;
		// 	draw_set_color(c_white);
		// 	for (var i = 0, n = array_length(segments); i < n; i++) {
		// 		var segment = segments[i];
				
		// 		for (var j = 0, m = array_length(segment); j < m; j += 2) {
		// 			nx = (segment[j + 0] - minx) / rngx * prev_s;
		// 			ny = (segment[j + 1] - miny) / rngy * prev_s;
					
		// 			if(j) draw_line_round(ox, oy, nx, ny, 4);
					
		// 			ox = nx;
		// 			oy = ny;
		// 		}
		// 	}
			
		// 	draw_set_color(COLORS._main_accent);
		// 	for (var i = 0, n = array_length(anchors); i < n; i++) {
		// 		var _a0 = anchors[i];
		// 		draw_circle((_a0[0] - minx) / rngx * prev_s, (_a0[1] - miny) / rngy * prev_s, 8, false);
		// 	}
		// surface_reset_target();
		
		// path_preview_surface = surface_verify(path_preview_surface, prev_s, prev_s);
		// surface_set_shader(path_preview_surface, sh_FXAA);
		// 	shader_set_f("dimension",  prev_s, prev_s);
		// 	shader_set_f("cornerDis",  0.5);
		// 	shader_set_f("mixAmo",     1);
			
		// 	draw_surface_safe(_surf);
		// surface_reset_shader();
		
		// surface_free(_surf);
	} 
	
	static getLineCount		= function() /*=>*/ {return 1};
	static getSegmentCount	= function() /*=>*/ {return array_length(lengths)};
	static getBoundary		= function() /*=>*/ {return boundary};
	static getLength		= function() /*=>*/ {return lengthTotal};
	static getAccuLength	= function() /*=>*/ {return lengthAccs};
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) {
		if(!is(out, __vec3P)) out = new __vec3P(); else { out.x = 0; out.y = 0; out.z = 0; }
		if(array_empty(lengths)) return out;
		
		var _cKey = _dist;
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			out.z = _p.z;
			return out;
		}
		
		var loop = getInputData(1);
		if(loop) _dist = safe_mod(_dist, lengthTotal, MOD_NEG.wrap);
		
		var ansize = array_length(inputs) - input_fix_len;
		if(ansize == 0) return out;
		
		var _a0, _a1;
		
		for(var i = 0; i < ansize; i++) {
			_a0 = anchors[(i + 0) % ansize];
			_a1 = anchors[(i + 1) % ansize];
			
			if(_dist > lengths[i]) {
				_dist -= lengths[i];
				continue;
			}
			
			var _t = _dist / lengths[i];
			
			if(_a0[6] == 0 && _a0[7] == 0 && _a0[8] == 0 && _a1[3] == 0 && _a1[4] == 0 && _a1[5] == 0) {
				out.x = lerp(_a0[0], _a1[0], _t);
				out.y = lerp(_a0[1], _a1[1], _t);
				out.z = lerp(_a0[2], _a1[2], _t);
				
			} else {
				out.x = eval_bezier_n(_t, _a0[0], _a1[0], _a0[0] + _a0[6], _a1[0] + _a1[3]);
				out.y = eval_bezier_n(_t, _a0[1], _a1[1], _a0[1] + _a0[7], _a1[1] + _a1[4]);
				out.z = eval_bezier_n(_t, _a0[2], _a1[2], _a0[2] + _a0[8], _a1[2] + _a1[5]);
				
			}
			
			cached_pos[? _cKey] = new __vec3P(out.x, out.y, out.z);
			return out;
		}
		
		return out;
	}
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) {
		var pix = (path_loop? frac(_rat) : clamp(_rat, 0, 0.99)) * lengthTotal;
		return getPointDistance(pix, _ind, out);
	}
	
	static getPointSegment = function(_rat) {
		if(array_empty(lengths)) return new __vec3P();
		
		var loop   = getInputData(1);
		var ansize = array_length(inputs) - input_fix_len;
		
		if(_rat < 0) return new __vec3P(anchors[0][0], anchors[0][1], anchors[0][2]);
		
		_rat = safe_mod(_rat, ansize);
		var _i0 = clamp(floor(_rat), 0, ansize - 1);
		var _i1 = (_i0 + 1) % ansize;
		var _t  = frac(_rat);
		
		if(_i1 >= ansize && !loop) return new __vec3P(anchors[ansize - 1][0], anchors[ansize - 1][1], anchors[ansize - 1][2]);
		
		var _a0 = anchors[_i0];
		var _a1 = anchors[_i1];
		var px, py, pz;
		
		if(_a0[6] == 0 && _a0[7] == 0 && _a0[8] == 0 && _a1[3] == 0 && _a1[4] == 0 && _a1[5] == 0) {
			px = lerp(_a0[0], _a1[0], _t);
			py = lerp(_a0[1], _a1[1], _t);
			pz = lerp(_a0[2], _a1[2], _t);
			
		} else {
			px = eval_bezier_n(_t, _a0[0], _a1[0], _a0[0] + _a0[6], _a1[0] + _a1[3]);
			py = eval_bezier_n(_t, _a0[1], _a1[1], _a0[1] + _a0[7], _a1[1] + _a1[4]);
			pz = eval_bezier_n(_t, _a0[2], _a1[2], _a0[2] + _a0[8], _a1[2] + _a1[5]);
			
		}
			
		return new __vec3P(px, py, pz);
	}
	
	////- Updates
	
	static update = function(frame = CURRENT_FRAME) {
		ds_map_clear(cached_pos);
		
		var _rat  = getInputData(0);
		path_loop = getInputData(1);
		var _typ  = getInputData(2);
		var _rnd  = getInputData(3);
		
		var _a = [];
		for(var i = input_fix_len; i < array_length(inputs); i++) {
			var _val = getInputData(i);
			var _anc = array_create(10, 0);
			
			for(var j = 0; j < 10; j++)
				_anc[j] = array_safe_get(_val, j);
				
			if(_rnd) {
				_anc[0] = round(_val[0]);
				_anc[1] = round(_val[1]);
				_anc[2] = round(_val[2]);
			}
			
			array_push(_a, _anc);
		}
		
		anchors = _a;
		outputs[2].setValue(_a);
		
		updateLength();
		
		if(is_array(_rat)) {
			var _out = array_create(array_length(_rat));
			
			for( var i = 0, n = array_length(_rat); i < n; i++ ) {
				if(_typ == 0)		_out[i] = getPointRatio(_rat[i]);
				else if(_typ == 1)	_out[i] = getPointSegment(_rat[i]);
			}
			
			outputs[0].setValue(_out);
		} else {
			var _out = [0, 0];
			
			if(_typ == 0)		_out = getPointRatio(_rat);
			else if(_typ == 1)	_out = getPointSegment(_rat);
			
			outputs[0].setValue(_out.toArray());
		}
	}
	
	////- Preview
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_path_3d, 0, bbox);
	}
	
	static getPreviewObject 		= function() /*=>*/ {return noone};
	static getPreviewObjects		= function() /*=>*/ {return []};
	static getPreviewObjectOutline  = function() /*=>*/ {return []};
	
}