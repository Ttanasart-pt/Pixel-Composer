enum RIGID_SHAPE { 
	box,
	circle,
	mesh
}

function Node_Rigid_Object(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Object";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	object = [];
	attributes.mesh = [];
	
	inputs[| 0] = nodeValue("Affect by force", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		.rejectArray()
		.setAnimable(false);
	
	inputs[| 1] = nodeValue("Weight", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.rejectArray()
		.setAnimable(false);
	
	inputs[| 2] = nodeValue("Contact friction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.rejectArray()
		.setAnimable(false);
	
	inputs[| 3] = nodeValue("Air resistance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.rejectArray()
		.setAnimable(false);
	
	inputs[| 4] = nodeValue("Rotation resistance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.rejectArray()
		.setAnimable(false);
	
	inputs[| 5] = nodeValue("Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ new scrollItem("Box", s_node_shape_rectangle, 0), new scrollItem("Circle", s_node_shape_circle, 0), new scrollItem("Custom", s_node_shape_misc, 1) ])
		.rejectArray()
		.setAnimable(false);
	
	inputs[| 6] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setAnimable(false);
	
	inputs[| 7] = nodeValue("Start position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setAnimable(false);
	
	inputs[| 8] = nodeValue("Spawn", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Make object spawn when start.")
		.rejectArray()
		.setAnimable(false);
	
	inputs[| 9] = nodeValue("Generate mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, false )
		.setDisplay(VALUE_DISPLAY.button, { name: "Generate", UI : true, onClick: function() { generateAllMesh(); } });
	
	inputs[| 10] = nodeValue("Mesh expansion", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -2, 2, 0.1 ] })
		.rejectArray()
		.setAnimable(false);
	
	inputs[| 11] = nodeValue("Add pixel collider", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		.rejectArray()
		.setAnimable(false);
		
	inputs[| 12] = nodeValue("Collision group", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.rejectArray()
		
	outputs[| 0] = nodeValue("Object", self, JUNCTION_CONNECT.output, VALUE_TYPE.rigid, object);
	
	input_display_list = [ 8, 12, 
		["Texture",	false],	6, 
		["Physics",	false],	0, 1, 2, 3, 4, 
		["Shape",	false],	7, 5, 9, 10, 11, 
	];
	
	static newMesh = function(index) {
		var mesh = struct_try_get(attributes, "mesh", []);
		mesh[index] = [ [ 0,  0], 
						[32,  0], 
						[32, 32], 
						[ 0, 32] ];
		attributes.mesh = mesh;
	}
	newMesh(0);
	
	tools = [];
	
	mesh_tools = [
		new NodeTool( "Mesh edit",		THEME.mesh_tool_edit ),
		new NodeTool( "Anchor remove",  THEME.mesh_tool_delete ),
	];
		
	is_convex = true;
	hover     = -1;
	anchor_dragging = -1;
	anchor_drag_sx  = -1;
	anchor_drag_sy  = -1;
	anchor_drag_mx  = -1;
	anchor_drag_my  = -1;
	
	static getPreviewValues = function() { #region
		return getInputData(6); 
	} #endregion
	
	static generateAllMesh = function() { #region
		var _tex  = getInputData(6);
			
		if(is_array(_tex)) {
			for( var i = 0, n = array_length(_tex); i < n; i++ ) 
				generateMesh(i);
		} else 
			generateMesh();
		doUpdate();
	} #endregion
	
	static drawOverlayPreviewSingle = function(_i, _x, _y, _s, _pr_x, _pr_y, _tex_s) { #region
		var meshes = attributes.mesh;
		var _shp = getInputData(5);
		
		var ww = surface_get_width_safe(_tex_s);
		var hh = surface_get_height_safe(_tex_s);
		var _tex = _tex_s;
		
		if(is_instanceof(_tex_s, SurfaceAtlas)) {
			_tex = _tex_s.getSurface();
			_pr_x += _tex_s.x * _s;
			_pr_y += _tex_s.y * _s;
		} else {
			_pr_x -= ww * _s / 2;
			_pr_y -= hh * _s / 2;
		}
		
		if(_shp == 2 && array_length(meshes) > _i) {
			draw_set_color(is_convex? COLORS._main_accent : COLORS._main_value_negative);
				
			var _m = meshes[_i];
			var _l = array_length(_m);
					
			for( var i = 0; i < _l; i++ ) {
				var _px0 = _m[i][0];
				var _py0 = _m[i][1];
				var _px1 = _m[safe_mod(i + 1, _l)][0];
				var _py1 = _m[safe_mod(i + 1, _l)][1];
						
				_px0 = _pr_x + _px0 * _s;
				_py0 = _pr_y + _py0 * _s;
				_px1 = _pr_x + _px1 * _s;
				_py1 = _pr_y + _py1 * _s;
						
				draw_line_width(_px0, _py0, _px1, _py1, 1);
			}
		}
			
		draw_surface_ext_safe(_tex, _pr_x, _pr_y, _s, _s, 0, c_white, 0.5);
	} #endregion
	
	static drawOverlayPreview = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _pos = getInputData(7);	
		var _tex = getInputData(6);
		
		var _pr_x = _x + _pos[0] * _s;
		var _pr_y = _y + _pos[1] * _s;
			
		if(is_array(_tex)) {
			for( var i = 0, n = array_length(_tex); i < n; i++ ) 
				drawOverlayPreviewSingle(i, _x, _y, _s, _pr_x, _pr_y, _tex[i]);
		} else 
			drawOverlayPreviewSingle(0, _x, _y, _s, _pr_x, _pr_y, _tex);
			
		return inputs[| 7].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var gr = is_instanceof(group, Node_Rigid_Group)? group : noone;
		if(inline_context != noone) gr = inline_context;
		
		if(gr == noone) return;
		
		if(previewing == 0) {
			for( var i = 0, n = array_length(gr.nodes); i < n; i++ ) {
				var _node = gr.nodes[i];
				if(!is_instanceof(_node, Node_Rigid_Object)) continue;
				var _hov = _node.drawOverlayPreview(active, _x, _y, _s, _mx, _my, _snx, _sny);
				active &= _hov;
			}
			return active;
		}
		
		var _shp = getInputData(5);
		if(_shp != 2) return active;
		
		var meshes = attributes.mesh;
		var _hover = -1, _side = 0;
		draw_set_color(is_convex? COLORS._main_accent : COLORS._main_value_negative);
		
		var mesh = meshes[preview_index];
		var len  = array_length(mesh);
		
		is_convex = true;
		for( var i = 0; i < len; i++ ) {
			var _px0 = mesh[safe_mod(i + 0, len)][0];
			var _py0 = mesh[safe_mod(i + 0, len)][1];
			var _px1 = mesh[safe_mod(i + 1, len)][0];
			var _py1 = mesh[safe_mod(i + 1, len)][1];
			var _px2 = mesh[safe_mod(i + 2, len)][0];
			var _py2 = mesh[safe_mod(i + 2, len)][1];
			
			var side = cross_product(_px0, _py0, _px1, _py1, _px2, _py2);
			if(_side != 0 && sign(_side) != sign(side)) 
				is_convex = false;
			_side = side;
			
			var _dx0 = _x + _px0 * _s;
			var _dy0 = _y + _py0 * _s;
			var _dx1 = _x + _px1 * _s;
			var _dy1 = _y + _py1 * _s;
			
			draw_line_width(_dx0, _dy0, _dx1, _dy1, hover == i + 0.5? 4 : 2);
			
			if(isUsingTool(0) && distance_to_line(_mx, _my, _dx0, _dy0, _dx1, _dy1) < 6)
				_hover = i + 0.5;
		}
		
		draw_set_color(COLORS._main_accent);
		draw_set_text(f_p1, fa_center, fa_bottom);
		
		for( var i = 0; i < len; i++ ) {
			var _px = mesh[i][0];
			var _py = mesh[i][1];
			
			var _dx = _x + _px * _s;
			var _dy = _y + _py * _s;
			
			//draw_text(_dx, _dy - 8, i);
			if(isNotUsingTool())
				draw_circle_prec(_dx, _dy, 4, false)
			else {
				draw_sprite_colored(THEME.anchor_selector, hover == i, _dx, _dy);
				if(point_distance(_mx, _my, _dx, _dy) < 8)
					_hover = i;
			}
		}
		
		hover = _hover;
		
		if(anchor_dragging > -1) {
			var dx = anchor_drag_sx + (_mx - anchor_drag_mx) / _s;
			var dy = anchor_drag_sy + (_my - anchor_drag_my) / _s;
			
			dx = value_snap(dx, _snx);
			dy = value_snap(dy, _sny);
			
			mesh[anchor_dragging][0] = dx;
			mesh[anchor_dragging][1] = dy;
			
			if(mouse_release(mb_left))
				anchor_dragging = -1;
			return active;
		}
		
		if(hover == -1) return active;
			
		if(frac(hover) == 0) {
			if(mouse_click(mb_left, active)) {
				if(isUsingTool(0)) {
					anchor_dragging = hover;
					anchor_drag_sx  = mesh[hover][0];
					anchor_drag_sy  = mesh[hover][1];
					anchor_drag_mx  = _mx;
					anchor_drag_my  = _my;
				} else if(isUsingTool(1)) {
					if(array_length(mesh) > 3)
						array_delete(mesh, hover, 1);
				}
			}
		} else {
			if(mouse_click(mb_left, active)) {
				var ind = ceil(hover);
				ds_list_insert(lx, ind, (_mx - _x) / _s);
				ds_list_insert(ly, ind, (_my - _y) / _s);
				
				anchor_dragging = ind;
				anchor_drag_sx  = mesh[ind][0];
				anchor_drag_sy  = mesh[ind][1];
				anchor_drag_mx  = _mx;
				anchor_drag_my  = _my;
			}
		}
		
		var a = inputs[| 7].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active &= !a;
		
		return active;
	} #endregion
	
	static generateMesh = function(index = 0) { #region
		var _tex = getInputData(6);
		var _exp = getInputData(10);
		var _pix = getInputData(11);
		
		if(is_array(_tex)) _tex = array_safe_get_fast(_tex, index);
		
		if(is_instanceof(_tex, SurfaceAtlas))
			_tex = _tex.getSurface();
		
		if(!is_surface(_tex)) return;
		
		var meshes = attributes.mesh;
		var mesh   = [];
		
		var ww = surface_get_width_safe(_tex);
		var hh = surface_get_height_safe(_tex);
		
		var surface_buffer = buffer_create(ww * hh * 4, buffer_fixed, 2);
		buffer_get_surface(surface_buffer, _tex, 0);
		buffer_seek(surface_buffer, buffer_seek_start, 0);
		
		var cmX = 0;
		var cmY = 0;
		var cmA = 0;
		
		for( var j = 0; j < hh; j++ )
		for( var i = 0; i < ww; i++ ) {
			var cc = buffer_read(surface_buffer, buffer_u32);
			var _a = (cc & (0b11111111 << 24)) >> 24;
			
			if(_a > 0) {
				cmX += i;
				cmY += j;
				cmA++;
			}
		}
		
		if(cmA == 0) return;
		
		cmX /= cmA;
		cmY /= cmA;
		
		var uni_com = shader_get_uniform(sh_mesh_generation, "com");
		var uni_dim = shader_get_uniform(sh_mesh_generation, "dimension");
		var temp	= surface_create_valid(ww, hh);
		
		surface_set_target(temp);
		DRAW_CLEAR
		shader_set(sh_mesh_generation);
		
		shader_set_uniform_f(uni_dim, ww, hh);
		shader_set_uniform_f(uni_com, cmX, cmY);
		draw_surface_safe(_tex, 0, 0);
		
		shader_reset();
		surface_reset_target();
		
		buffer_get_surface(surface_buffer, temp, 0);
		buffer_seek(surface_buffer, buffer_seek_start, 0);
		
		var _pm = ds_map_create();
		
		for( var j = 0; j < hh; j++ )
		for( var i = 0; i < ww; i++ ) {
			var cc = buffer_read(surface_buffer, buffer_u32);
			var _a = (cc & (0b11111111 << 24)) >> 24;
			
			if(_a > 0) _pm[? point_direction_positive(cmX, cmY, i, j)] = [ i, j ];
		}
		
		if(ds_map_size(_pm)) {
			var keys = ds_map_keys_to_array(_pm);
			array_sort(keys, false);
			
			var _minx = ww, _maxx = 0;
			var _miny = hh, _maxy = 0;
				
			for( var i = 0, n = array_length(keys); i < n; i++ ) {
				var px = _pm[? keys[i]][0];
				var py = _pm[? keys[i]][1];
				
				_minx  = min(_minx, px + 0.5);
				_maxx  = max(_maxx, px + 0.5);
				_miny  = min(_miny, py + 0.5);
				_maxy  = max(_maxy, py + 0.5);
				
				if(px > cmX) px++;
				if(py > cmY) py++;
				
				if(_exp != 0) {
					var dist = max(0.5, point_distance(cmX, cmY, px, py) + _exp);
					var dirr = point_direction(cmX, cmY, px, py);
					
					px = cmX + lengthdir_x(dist, dirr);
					py = cmY + lengthdir_y(dist, dirr);
				}
				
				array_push(mesh, [ px, py ]);
			}
			
			mesh = removeColinear(mesh);
			mesh = removeConcave(mesh);
					 
			var _sm = ds_map_create();
			
			if(array_length(mesh)) {
				for( var i = 0, n = array_length(mesh); i < n; i++ ) 
					_sm[? point_direction_positive(cmX, cmY, mesh[i][0], mesh[i][1])] = [ mesh[i][0], mesh[i][1] ];
			}
			
			var keys = ds_map_keys_to_array(_sm);
			mesh = [];
			
			if(array_length(keys)) {
				array_sort(keys, false);
				
				for( var i = 0, n = array_length(keys); i < n; i++ ) {
					var k = keys[i];
					array_push( mesh, [_sm[? k][0], _sm[? k][1]] );
				}
			}
				
			ds_map_destroy(_sm);
		}
		
		if(_pix && array_empty(mesh)) {
			mesh = [ 
				[ _minx - 0.5, _minx - 0.5 ], 
				[ _maxx + 0.5, _minx - 0.5 ], 
				[ _maxx + 0.5, _maxy + 0.5 ], 
				[ _minx - 0.5, _maxy + 0.5 ],
			];
		}
		
		ds_map_destroy(_pm);
		surface_free(temp);
		buffer_delete(surface_buffer);
		
		meshes[index] = mesh;
		attributes.mesh = meshes;
	} #endregion
	
	static removeColinear = function(mesh) { #region
		var len   = array_length(mesh), _side = 0;
		var remSt = [];
		var tolerance = 5;
		
		for( var i = 0; i < len; i++ ) {
			var _px0 = mesh[safe_mod(i + 0, len)][0];
			var _py0 = mesh[safe_mod(i + 0, len)][1];
			var _px1 = mesh[safe_mod(i + 1, len)][0];
			var _py1 = mesh[safe_mod(i + 1, len)][1];
			var _px2 = mesh[safe_mod(i + 2, len)][0];
			var _py2 = mesh[safe_mod(i + 2, len)][1];
				
			var dir0 = point_direction(_px0, _py0, _px1, _py1);
			var dir1 = point_direction(_px1, _py1, _px2, _py2);
			
			if(abs(dir0 - dir1) <= tolerance) 
				array_push(remSt, safe_mod(i + 1, len));
		}
		
		array_sort(remSt, false);
		for( var i = 0, n = array_length(remSt); i < n; i++ ) {
			var ind = remSt[i];
			array_delete(mesh, ind, 1);
		}
		
		return mesh;
	} #endregion
	
	static removeConcave = function(mesh) { #region
		var len = array_length(mesh);
		if(len <= 3) return;
		
		var startIndex = 0;
		var maxx = 0;
		
		for( var i = 0; i < len; i++ ) {
			var _px0 = mesh[i][0];
			
			if(_px0 > maxx) {
				maxx = _px0;
				startIndex = i;
			}
		}
		
		var remSt = [];
		var chkSt = ds_stack_create();
		ds_stack_push(chkSt, startIndex);
		ds_stack_push(chkSt, safe_mod(startIndex + 1, len));
		
		var anchorTest = safe_mod(startIndex + 2, len)
		var log = false;
		var _side = 1;
		
		printIf(log, "Start " + string(startIndex))
		
		while(true) {
			var potentialPoint = ds_stack_pop(chkSt);
			var anchorPoint    = ds_stack_top(chkSt);
			printIf(log, "Checking " + string(potentialPoint) + " Against " + string(anchorPoint) + " Test " + string(anchorTest))
			if(potentialPoint == startIndex) break;
			
			var _px0 = mesh[anchorPoint][0];
			var _py0 = mesh[anchorPoint][1];
			var _px1 = mesh[potentialPoint][0];
			var _py1 = mesh[potentialPoint][1];
			var _px2 = mesh[anchorTest][0];
			var _py2 = mesh[anchorTest][1];
			
			var side = sign(cross_product(_px0, _py0, _px1, _py1, _px2, _py2));
			if(_side == 0 || _side == side) {
				ds_stack_push(chkSt, potentialPoint);
				ds_stack_push(chkSt, anchorTest);
				anchorTest = safe_mod(anchorTest + 1, len);
				
				_side = side;
			} else {
				if(ds_stack_size(chkSt) == 1) {
					ds_stack_push(chkSt, anchorTest);
					anchorTest = safe_mod(anchorTest + 1, len);
				}
				array_push(remSt, potentialPoint);
				printIf(log, " > Remove " + string(potentialPoint));
			}
		}
		
		array_sort(remSt, false);
		
		for( var i = 0, n = array_length(remSt); i < n; i++ ) {
			var ind = remSt[i];
			array_delete(mesh, ind, 1);
		}
		
		return mesh;
	} #endregion
	
	static fixtureCreate = function(fixture, object, dx = 0, dy = 0) { #region
		var _mov	  = getInputData(0);
		var _den	  = getInputData(1);
		var _cnt_frc  = getInputData(2);
		var _air_frc  = getInputData(3);
		var _rot_frc  = getInputData(4);
		var collIndex = getInputData(12);
		
		if(!_mov) {
			physics_fixture_set_kinematic(fixture);
			_den = 0;
		}
		
		physics_fixture_set_density(fixture, _den);
		physics_fixture_set_friction(fixture, _cnt_frc);
		physics_fixture_set_linear_damping(fixture, _air_frc);
		physics_fixture_set_angular_damping(fixture, _rot_frc);
		physics_fixture_set_awake(fixture, true);
		physics_fixture_set_collision_group(fixture, collIndex);
		
		array_push(object.fixture, physics_fixture_bind_ext(fixture, object, dx, dy));
		physics_fixture_delete(fixture);
	} #endregion
	
	static spawn = function(index = 0, object = noone) { #region
		var _shp  = getInputData(5);
		var _tex  = getInputData(6);
		var _spos = getInputData(7);
		
		if(is_array(_tex)) { 
			index = safe_mod(index, array_length(_tex)); 
			_tex = array_safe_get_fast(_tex, index); 
		}
		
		var ww = surface_get_width_safe(_tex);
		var hh = surface_get_height_safe(_tex);
		var sw = ww, sh = hh;
		
		var ox = _spos[0];
		var oy = _spos[1];
		
		if(is_instanceof(_tex, SurfaceAtlas)) {
			ox += _tex.x;
			oy += _tex.y;
			sw  = 0;
			sh  = 0;
			
			_tex = _tex.getSurface();
		}
		
		if(object == noone) {
			object = instance_create_depth(ox - sw / 2, oy - sh / 2, 0, oRigidbody);
			object.surface = _tex;
			
		} else if(instance_exists(object)) {
			for( var i = 0, n = array_length(object.fixture); i < n; i++ )
				physics_remove_fixture(object, object.fixture[i]);
			object.fixture = [];
			
		} else 
			return noone;
		
		if(_shp == 0) {
			var fixture = physics_fixture_create();
			
			physics_fixture_set_box_shape(fixture, ww / 2, hh / 2);
			
			fixtureCreate(fixture, object, ww / 2, hh / 2);
			
			object.type   = RIGID_SHAPE.box;
			object.width  = ww;
			object.height = hh;
			
		} else if(_shp == 1) {
			var fixture = physics_fixture_create();
			var rr = min(ww, hh) / 2;
			
			physics_fixture_set_circle_shape(fixture, rr);
			
			fixtureCreate(fixture, object, rr, rr);
			
			object.type   = RIGID_SHAPE.circle;
			object.radius = rr;
			
		} else if(_shp == 2) {
			var meshes = attributes.mesh;
			if(array_safe_get_fast(meshes, index, noone) == noone)
				return noone;
				
			var mesh = meshes[index];
			var cx   = 0, cy   = 0;
			var cmx  = 0, cmy  = 0;
			
			var len = array_length(mesh), _side = 0;
			is_convex = true;
			for( var i = 0; i < len; i++ ) {
				var _px0 = mesh[safe_mod(i + 0, len)][0];
				var _py0 = mesh[safe_mod(i + 0, len)][1];
				var _px1 = mesh[safe_mod(i + 1, len)][0];
				var _py1 = mesh[safe_mod(i + 1, len)][1];
				var _px2 = mesh[safe_mod(i + 2, len)][0];
				var _py2 = mesh[safe_mod(i + 2, len)][1];
				
				var side = cross_product(_px0, _py0, _px1, _py1, _px2, _py2);
				if(_side != 0 && sign(_side) != sign(side)) 
					is_convex = false;
				_side = side;
				
				cx += _px0;
				cy += _py0;
			}
			
			cx /= len;
			cy /= len;
			
			if(!is_convex) return object;
			if(len < 3)    return object;
				
			if(len <= 8) {
				var fixture = physics_fixture_create();
				physics_fixture_set_polygon_shape(fixture);
				
				for( var i = 0; i < len; i++ ) {
					var _px0 = mesh[i][0];
					var _py0 = mesh[i][1];
					
					physics_fixture_add_point(fixture, _px0, _py0);
				}
				
				fixtureCreate(fixture, object, -1, -1);
			} else {
				for( var i = 0; i < len; i++ ) {
					var fixture = physics_fixture_create();
					physics_fixture_set_polygon_shape(fixture);
					
					var _px0 = mesh[safe_mod(i + 0, len)][0];
					var _py0 = mesh[safe_mod(i + 0, len)][1];
					var _px1 = mesh[safe_mod(i + 1, len)][0];
					var _py1 = mesh[safe_mod(i + 1, len)][1];
					
					physics_fixture_add_point(fixture,   cx,   cy);
					physics_fixture_add_point(fixture, _px0, _py0);
					physics_fixture_add_point(fixture, _px1, _py1);
				
					fixtureCreate(fixture, object, -1, -1);
				}
			}
			
			object.type   = RIGID_SHAPE.mesh;
		}
		
		return object;
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		if(IS_FIRST_FRAME) reset();
		
		outputs[| 0].setValue(object);
	} #endregion
	
	static step = function() { #region
		var _shp = getInputData(5);
		
		inputs[|  9].setVisible(_shp == 2);
		inputs[| 10].setVisible(_shp == 2);
		inputs[| 11].setVisible(_shp == 2);
		
		tools = _shp == 2? mesh_tools : -1;
		
		var _tex  = getInputData(6);
		
		if(is_array(_tex)) {
			var meshes = attributes.mesh;
			
			for( var i = array_length(meshes); i < array_length(_tex); i++ )
				newMesh(i);
		}
	} #endregion
	
	static reset = function() { #region
		var _tex = getInputData(6);
		
		for( var i = 0, n = array_length(object); i < n; i++ ) {
			if(instance_exists(object[i]))
				instance_destroy(object[i]);
		}
		object = [];
		
		var _spwn = getInputData(8);
		if(!_spwn) return;
		
		if(is_array(_tex)) {
			for( var i = 0, n = array_length(_tex); i < n; i++ )
				object[i] = spawn(i);
		} else 
			object = [ spawn() ];
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		if(!previewable) return;
		
		var bbox = drawGetBbox(xx, yy, _s);
		var _tex = getInputData(6);
		
		if(is_array(_tex)) {
			if(array_empty(_tex)) return;
			_tex = _tex[0];
		}
		
		var aa   = 0.5 + 0.5 * renderActive;
		if(!isHighlightingInGraph()) aa *= 0.25;
		draw_surface_bbox(_tex, bbox,, aa);
	} #endregion
	
	static attributeSerialize = function() { #region
		var att = {};
		
		var mesh = struct_try_get(attributes, "mesh", []);
		att.mesh = json_stringify(mesh);
		
		return att;
	} #endregion
	
	static attributeDeserialize = function(attr) { #region
		struct_append(attributes, attr); 
		
		if(struct_has(attr, "mesh"))
			attributes.mesh = json_parse(attr.mesh);
	} #endregion
}