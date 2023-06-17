function Node_Rigid_Object(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Object";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	//update_on_frame = true;
	
	w = 96;
	min_h = 96;
	
	object     = [];
	attributes.mesh = [];
	
	inputs[| 0] = nodeValue("Affect by force", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		.rejectArray();
	
	inputs[| 1] = nodeValue("Weight", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.rejectArray();
	
	inputs[| 2] = nodeValue("Contact friction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.rejectArray();
	
	inputs[| 3] = nodeValue("Air resistance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.rejectArray();
	
	inputs[| 4] = nodeValue("Rotation resistance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.rejectArray();
	
	inputs[| 5] = nodeValue("Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Box", "Circle", "Custom" ])
		.rejectArray();
	
	inputs[| 6] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.rejectArray();
	
	inputs[| 7] = nodeValue("Start shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16, 4, 4, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area);
	inputs[| 7].editWidget.adjust_shape = false;
	
	inputs[| 8] = nodeValue("Spawn", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Make object spawn when start.")
		.rejectArray();
	
	inputs[| 9] = nodeValue("Generate mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() {
			var _tex  = inputs[| 6].getValue();
			if(is_array(_tex)) {
				for( var i = 0; i < array_length(_tex); i++ ) 
					generateMesh(i);
			} else 
				generateMesh();
			doUpdate();
		}, "Generate"] );
	
	inputs[| 10] = nodeValue("Mesh expansion", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.rejectArray();
	
	outputs[| 0] = nodeValue("Object", self, JUNCTION_CONNECT.output, VALUE_TYPE.rigid, self);
	
	input_display_list = [ 8,
		["Texture",		false],	6,
		["Physical",	false],	0, 1, 2, 3, 4,
		["Shape",		false],	5, 9, 10, 7, 
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
	
	tools = [
		new NodeTool( "Mesh edit",		THEME.mesh_tool_edit ),
		new NodeTool( "Anchor remove",  THEME.mesh_tool_delete ),
	];
	
	static getPreviewValue = function() { return inputs[| 6]; }
	
	is_convex = true;
	hover = -1;
	anchor_dragging = -1;
	anchor_drag_sx  = -1;
	anchor_drag_sy  = -1;
	anchor_drag_mx  = -1;
	anchor_drag_my  = -1;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _shp = inputs[| 5].getValue();
		var _box = inputs[| 7].getValue();
		
		var meshes = attributes.mesh;
		if(preview_index >= array_length(meshes)) return;
		
		if(previewing == 0) {
			if(_shp == 2) {
				var _tex = inputs[| 6].getValue();
				if(is_array(_tex)) _tex = _tex[safe_mod(preview_index, array_length(_tex))];
				var tw = surface_get_width(_tex);
				var th = surface_get_height(_tex);
				
				draw_set_color(is_convex? COLORS._main_accent : COLORS._main_value_negative);
				
				for( var j = 0; j < array_length(meshes); j++ ) {
					var _m = meshes[j];
					var _l = array_length(_m);
					
					for( var i = 0; i < _l; i++ ) {
						var _px0 = _m[i][0];
						var _py0 = _m[i][1];
						var _px1 = _m[safe_mod(i + 1, _l)][0];
						var _py1 = _m[safe_mod(i + 1, _l)][1];
						
						_px0 = (_px0 / tw) * 2 - 1;
						_py0 = (_py0 / th) * 2 - 1;
						_px1 = (_px1 / tw) * 2 - 1;
						_py1 = (_py1 / th) * 2 - 1;
					
						_px0 = _box[0] + (_box[2]) * _px0;
						_py0 = _box[1] + (_box[3]) * _py0;
						_px1 = _box[0] + (_box[2]) * _px1;
						_py1 = _box[1] + (_box[3]) * _py1;
					
						var _dx0 = _x + _px0 * _s;
						var _dy0 = _y + _py0 * _s;
						var _dx1 = _x + _px1 * _s;
						var _dy1 = _y + _py1 * _s;
			
						draw_line_width(_dx0, _dy0, _dx1, _dy1, 1);
					}
				}
				
				draw_set_color(COLORS._main_accent);
				var x0 = _box[0] - _box[2];
				var x1 = _box[0] + _box[2];
				var y0 = _box[1] - _box[3];
				var y1 = _box[1] + _box[3];
				
				x0 = _x + x0 * _s;
				x1 = _x + x1 * _s;
				y0 = _y + y0 * _s;
				y1 = _y + y1 * _s;
				
				draw_rectangle(x0, y0, x1, y1, true);
			}
			
			inputs[| 7].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
			return;
		}
		
		if(_shp != 2) return;
		
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
			return;
		}
		
		if(hover == -1) return;
			
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
	}
	
	static generateMesh = function(index = 0) {
		var _tex = inputs[|  6].getValue();
		var _exp = inputs[| 10].getValue();
		
		if(is_array(_tex)) {
			index = safe_mod(index, array_length(_tex));
			_tex = _tex[index];
		}
		
		if(!is_surface(_tex)) return;
		
		var meshes = attributes.mesh;
		var mesh   = [];
		
		var ww = surface_get_width(_tex);
		var hh = surface_get_height(_tex);
		
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
			
			if(_a > 0)
				_pm[? point_direction_positive(cmX, cmY, i, j)] = [i, j];
		}
		
		if(ds_map_size(_pm)) {
			var keys = ds_map_keys_to_array(_pm);
			array_sort(keys, false);
		
			for( var i = 0; i < array_length(keys); i++ ) {
				var px = _pm[? keys[i]][0];
				var py = _pm[? keys[i]][1];
				
				if(px > cmX) px++;
				if(py > cmY) py++;
				
				if(_exp != 0) {
					var dist = point_distance(cmX, cmY, px, py) + _exp;
					var dirr = point_direction(cmX, cmY, px, py);
					
					px = cmX + lengthdir_x(dist, dirr);
					py = cmY + lengthdir_y(dist, dirr);
				}
				
				array_push(mesh, [ px, py ]);
			}
			
			mesh = removeColinear(mesh);
			mesh = removeConcave(mesh);
			
			var _sm = ds_map_create();
			
			for( var i = 0; i < array_length(mesh); i++ )
				_sm[? point_direction_positive(cmX, cmY, mesh[i][0], mesh[i][1])] = [ mesh[i][0], mesh[i][1] ];
			
			var keys = ds_map_keys_to_array(_sm);
			mesh = [];
			
			if(array_length(keys)) {
				array_sort(keys, false);
				
				for( var i = 0; i < array_length(keys); i++ ) {
					var k = keys[i];
					array_push( mesh, [_sm[? k][0], _sm[? k][1]] );
				}
			}
			
			ds_map_destroy(_sm);
		}
		
		ds_map_destroy(_pm);
		surface_free(temp);
		buffer_delete(surface_buffer);
		
		meshes[index] = mesh;
		attributes.mesh = meshes;
	}
	
	static removeColinear = function(mesh) {
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
		for( var i = 0; i < array_length(remSt); i++ ) {
			var ind = remSt[i];
			array_delete(mesh, ind, 1);
		}
		
		return mesh;
	}
	
	static removeConcave = function(mesh) {
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
		
		for( var i = 0; i < array_length(remSt); i++ ) {
			var ind = remSt[i];
			array_delete(mesh, ind, 1);
		}
		
		return mesh;
	}
	
	static onValueUpdate = function(index = 0) {
		if(index == 5) {
			var _spos  = inputs[| 7].getValue();
			var _shape = inputs[| 5].getValue();
			_spos[4] = _shape;
			inputs[| 7].setValue(_spos);
		}
	}
	
	static fixtureCreate = function(fixture, object) {
		var _mov	 = inputs[| 0].getValue();
		var _den	 = inputs[| 1].getValue();
		var _cnt_frc = inputs[| 2].getValue();
		var _air_frc = inputs[| 3].getValue();
		var _rot_frc = inputs[| 4].getValue();
		
		var _spos   = inputs[| 7].getValue();
		
		if(!_mov) {
			physics_fixture_set_kinematic(fixture);
			_den = 0;
		}
		
		physics_fixture_set_density(fixture, _den);
		physics_fixture_set_friction(fixture, _cnt_frc);
		physics_fixture_set_linear_damping(fixture, _air_frc);
		physics_fixture_set_angular_damping(fixture, _rot_frc);
		physics_fixture_set_awake(fixture, true);
		if(group != noone)
			physics_fixture_set_collision_group(fixture, group.collIndex);
		
		array_push(object.fixture, physics_fixture_bind_ext(fixture, object, _spos[2], _spos[3]));
		physics_fixture_delete(fixture);
	}
	
	static spawn = function(rpos = noone, index = 0, object = noone) {
		var _shp     = inputs[| 5].getValue();
		var _tex     = inputs[| 6].getValue();
		
		if(is_array(_tex)) {
			index = safe_mod(index, array_length(_tex));
			_tex = _tex[index];
		} else 
			index = 0;
		
		var _spos   = inputs[| 7].getValue();
		
		var ww = max(1, surface_get_width(_tex));
		var hh = max(1, surface_get_height(_tex));
		
		var ox = rpos == noone? _spos[0] : rpos[0];
		var oy = rpos == noone? _spos[1] : rpos[1];
		
		if(object == noone) {
			object = instance_create_depth(ox - _spos[2], oy - _spos[3], 0, oRigidbody);
			object.xscale = _spos[2] / ww * 2;
			object.yscale = _spos[3] / hh * 2;
			object.surface = _tex;
		} else if(instance_exists(object)) {
			for( var i = 0; i < array_length(object.fixture); i++ )
				physics_remove_fixture(object, object.fixture[i]);
			object.fixture = [];
		} else 
			return noone;
		
		if(_shp == 0) {
			var fixture = physics_fixture_create();
			physics_fixture_set_box_shape(fixture, _spos[2], _spos[3]);
			fixtureCreate(fixture, object);
		} else if(_shp == 1) {
			var fixture = physics_fixture_create();
			physics_fixture_set_circle_shape(fixture, min(_spos[2], _spos[3]));
			fixtureCreate(fixture, object);
		} else if(_shp == 2) {
			var meshes = attributes.mesh;
			if(array_safe_get(meshes, index, noone) == noone)
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
			
			cmx = cx;
			cmy = cy;
			
			cx = (cx / ww) * 2 - 1;
			cy = (cy / hh) * 2 - 1;
			
			cx = _spos[2] * cx;
			cy = _spos[3] * cy;
			
			if(!is_convex) return object;
			if(len < 3) return object;
				
			if(len <= 8) {
				var fixture = physics_fixture_create();
				physics_fixture_set_polygon_shape(fixture);
				
				for( var i = 0; i < len; i++ ) {
					var _px0 = mesh[i][0];
					var _py0 = mesh[i][1];
					
					_px0 = (_px0 / ww) * 2 - 1;
					_py0 = (_py0 / hh) * 2 - 1;
					
					_px0 = _spos[2] * _px0;
					_py0 = _spos[3] * _py0;
					
					physics_fixture_add_point(fixture, round(_px0), round(_py0));
				}
				
				fixtureCreate(fixture, object);
			} else {
				for( var i = 0; i < len; i++ ) {
					var fixture = physics_fixture_create();
					physics_fixture_set_polygon_shape(fixture);
					
					var _px0 = mesh[safe_mod(i + 0, len)][0];
					var _py0 = mesh[safe_mod(i + 0, len)][1];
					var _px1 = mesh[safe_mod(i + 1, len)][0];
					var _py1 = mesh[safe_mod(i + 1, len)][1];
						
					_px0 = (_px0 / ww) * 2 - 1;
					_py0 = (_py0 / hh) * 2 - 1;
					_px1 = (_px1 / ww) * 2 - 1;
					_py1 = (_py1 / hh) * 2 - 1;
					
					_px0 = _spos[2] * _px0;
					_py0 = _spos[3] * _py0;
					_px1 = _spos[2] * _px1;
					_py1 = _spos[3] * _py1;
				
					var d0 = point_direction(cx, cy, _px0, _py0);
					var d1 = point_direction(cx, cy, _px1, _py1);
				
					physics_fixture_add_point(fixture,   cx,   cy);
					physics_fixture_add_point(fixture, _px0, _py0);
					physics_fixture_add_point(fixture, _px1, _py1);
				
					fixtureCreate(fixture, object);
				}
			}
			
			//with(object) physics_mass_properties(phy_mass, cmx, cmy, phy_inertia);
		}
		
		return object;
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		if(!isAnimated()) return;
		
		//for( var i = 0; i < array_length(object); i++ )
		//	spawn(noone, i, object[i]);
	}
	
	static step = function() {
		var _shp = inputs[| 5].getValue();
		inputs[| 9].setVisible(_shp == 2);
		
		var _tex  = inputs[| 6].getValue();
		
		if(is_array(_tex)) {
			var meshes = attributes.mesh;
			
			for( var i = array_length(meshes); i < array_length(_tex); i++ )
				newMesh(i);
		}
	}
	
	static reset = function() {
		var _tex  = inputs[| 6].getValue();
		for( var i = 0; i < array_length(object); i++ ) {
			if(instance_exists(object[i]))
				instance_destroy(object[i]);
		}
		object = [];
		
		var _spwn = inputs[| 8].getValue();
		if(!_spwn) return;
		
		if(is_array(_tex)) {
			for( var i = 0; i < array_length(_tex); i++ )
				object[i] = spawn(noone, i);
		} else 
			object = [ spawn() ];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var _tex  = inputs[| 6].getValue();
		if(is_array(_tex) && array_length(_tex)) _tex = _tex[0];
		var _spos = inputs[| 7].getValue();
		
		draw_surface_stretch_fit(_tex, bbox.xc, bbox.yc, bbox.w, bbox.h, _spos[2], _spos[3]);
	}
	
	static attributeSerialize = function() {
		var att = {};
		
		var mesh = struct_try_get(attributes, "mesh", []);
		att.mesh = json_stringify(mesh);
		
		return att;
	}
	
	static attributeDeserialize = function(attr) {
		if(struct_has(attr, "mesh"))
			attributes.mesh = json_parse(attr.mesh);
	}
}