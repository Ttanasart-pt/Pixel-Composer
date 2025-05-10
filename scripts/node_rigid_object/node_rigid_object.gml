#region
	FN_NODE_TOOL_INVOKE {
		hotkeyTool("Node_Rigid_Object", "Mesh edit",     "A");
		hotkeyTool("Node_Rigid_Object", "Anchor remove", "E");
	});
#endregion

enum RIGID_SHAPE { 
	box,
	circle,
	mesh
}

function __Box2DObject(_objId = undefined, _texture = undefined) constructor {
	objId   = _objId;
	texture = _texture;
}

function Node_Rigid_Object(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Object";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 96);
	
	manual_ungroupable = false;
	getInputData       = getInputDataForce;
	
	worldIndex      = undefined;
	worldScale      = 100;
	objects         = [];
	attributes.mesh = [];
	
	newInput( 8, nodeValue_Bool(  "Spawn",               self, true, "Make object spawn when start."));
	
	////- Physics
	
	newInput(12, nodeValue_Int(    "Collision Group",     self, 1));
	newInput( 0, nodeValue_Bool(   "Affect by Force",     self, true));
	newInput( 1, nodeValue_Float(  "Mass",                self, 10));
	newInput( 2, nodeValue_Slider( "Friction",            self, 0.2));
	newInput( 3, nodeValue_Slider( "Air Resistance",      self, 0.0));
	newInput( 4, nodeValue_Slider( "Rotation Resistance", self, 0.1));
	newInput(13, nodeValue_Slider( "Bounciness",          self, 0.2));
	
	////- Shape
	
	newInput( 6, nodeValue_Surface(     "Texture", self));
	newInput( 5, nodeValue_Enum_Scroll( "Shape",   self,  0, [ new scrollItem("Box",    s_node_shape_rectangle, 0), 
	                                                           new scrollItem("Circle", s_node_shape_circle,    0), 
	                                                           new scrollItem("Custom", s_node_shape_misc,      1) ]));
	newInput( 9, nodeValue_Trigger(     "Generate mesh",       self )).setDisplay(VALUE_DISPLAY.button, { name: "Generate", UI : true, onClick: function() /*=>*/ {return generateAllMesh()} });
	newInput(10, nodeValue_Slider(      "Mesh expansion",      self, 0, [ -2, 2, 0.1 ]));
	newInput(11, nodeValue_Bool(        "Add pixel collider",  self, true));
	
	////- Transform
	
	newInput( 7, nodeValue_Vec2(        "Start position",      self, [ 16, 16 ]));
		
	// inputs 14
		
	newOutput(0, nodeValue_Output("Object", self, VALUE_TYPE.rigid, objects));
	
	array_foreach(inputs, function(inp, ind) /*=>*/ { 
		if(ind == 6) inp.setAnimable(false);
		else         inp.setAnimable(false).rejectArray();
	})
	
	input_display_list = [ 8, 
		["Physics",	  false], 12, 0, 1, 2, 3, 4, 13, 
		["Shape",	  false], 6, 5, 9, 10, 11, 
		["Transform", false], 7,
	];
	
	static newMesh = function(_index) {
		var mesh     = struct_try_get(attributes, "mesh", []);
		mesh[_index] = [ [ 0,  0], 
						 [32,  0], 
						 [32, 32], 
						 [ 0, 32] ];
		attributes.mesh = mesh;
	}
	newMesh(0);
	
	tools = [];
	
	mesh_tools = [
		new NodeTool( "Mesh edit",		THEME.mesh_tool_edit   ),
		new NodeTool( "Anchor remove",  THEME.mesh_tool_delete ),
	];
		
	is_convex = true;
	hover     = -1;
	anchor_dragging = -1;
	anchor_drag_sx  = -1;
	anchor_drag_sy  = -1;
	anchor_drag_mx  = -1;
	anchor_drag_my  = -1;
	
	////- Mesh
	
	static getPreviewValues = function() { return getInputData(6); }
	
	static generateAllMesh = function() {
		var _tex = getInputData(6);
			
		if(is_array(_tex)) {
			for( var i = 0, n = array_length(_tex); i < n; i++ ) 
				generateMesh(i);
		} else 
			generateMesh();
		doUpdate();
	}
	
	static generateMesh = function(index = 0) {
		var _tex = getInputData(6);
		var _exp = getInputData(10);
		var _pix = getInputData(11);
		
		if(is_array(_tex)) _tex = array_safe_get_fast(_tex, index);
		
		if(is(_tex, SurfaceAtlas))
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
		draw_surface_safe(_tex);
		
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
		for( var i = 0, n = array_length(remSt); i < n; i++ ) {
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
		
		for( var i = 0, n = array_length(remSt); i < n; i++ ) {
			var ind = remSt[i];
			array_delete(mesh, ind, 1);
		}
		
		return mesh;
	}
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var gr = is(group, Node_Rigid_Group)? group : noone;
		if(inline_context != noone) gr = inline_context;
		if(gr == noone) return;
		
		InputDrawOverlay(inputs[7].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		var _shp = getInputData(5);
		var _tex = getInputData(6);
		var _pos = getInputData(7);
		var _dim = surface_get_dimension(_tex);
		
		if(previewing == 0) {
			_x = _x + (_pos[0] - _dim[0] / 2) * _s;
			_y = _y + (_pos[1] - _dim[1] / 2) * _s;
		}
		
		draw_set_color(COLORS._main_accent);
		switch(_shp) {
			case 0 : draw_rectangle(_x, _y, _x + _dim[0] * _s, _y + _dim[1] * _s, true); return active;
			case 1 : draw_ellipse(  _x, _y, _x + _dim[0] * _s, _y + _dim[1] * _s, true); return active;
		}
		
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
		
		return active;
	}
	
	////- Rigidbody
	
	static spawn = function(_index = 0, _object = noone) {
		if(worldIndex == undefined) return undefined;
		
		var _shp  = getInputData(5);
		var _tex  = getInputData(6);
		var _spos = getInputData(7);
		
		gmlBox2D_Object_Create_Begin(worldIndex, _spos[0] / worldScale, _spos[1] / worldScale);
		
		if(is_array(_tex)) { 
			_index = safe_mod(_index, array_length(_tex)); 
			_tex   = array_safe_get_fast(_tex, _index); 
		}
		
		if(is(_tex, SurfaceAtlas))
			_tex = _tex.getSurface();
			
		var ww = surface_get_width_safe(_tex);
		var hh = surface_get_height_safe(_tex);
		
		switch(_shp) {
			case 0 : gmlBox2D_Object_Create_Shape_Box((ww / 2) / worldScale, (hh / 2) / worldScale); break;
			case 1 : gmlBox2D_Object_Create_Shape_Circle(min(ww, hh) / 2 / worldScale); break;
				
			case 2 : 
				var meshes = attributes.mesh;
				if(array_safe_get_fast(meshes, _index, noone) == noone) return undefined;
					
				var mesh = meshes[_index];
				var len  = array_length(mesh);
				var buff = buffer_create(8 * 2 * len, buffer_fixed, 8);
				
				buffer_to_start(buff);
				for(var i = 0; i < len; i++) {
					buffer_write(buff, buffer_f64, mesh[i][0] / worldScale);
					buffer_write(buff, buffer_f64, mesh[i][1] / worldScale);
				}
				
				gmlBox2D_Object_Create_Shape_Polygon(buffer_get_address(buff), len, 0);
				buffer_delete(buff);
				break;
		}
		
		var objId  = gmlBox2D_Object_Create_Complete(); 
		var boxObj = new __Box2DObject(objId, _tex);
		
		var _mov	  = getInputData(0);
		var _weig     = getInputData(1);
		var _cnt_frc  = getInputData(2);
		var _air_res  = getInputData(3);
		var _rot_frc  = getInputData(4);
		var _bouncy   = getInputData(13);
		var collIndex = getInputData(12);
		
		gmlBox2D_Object_Set_Fixed_Angle( objId, false);
		gmlBox2D_Object_Set_Body_Type(   objId, _mov? 2 : 0);
		gmlBox2D_Object_Set_Damping(     objId, _air_res, _rot_frc);
		gmlBox2D_Shape_Set_Friction(     objId, _cnt_frc);
		gmlBox2D_Shape_Set_Restitution(  objId, _bouncy);
		
		return boxObj;
	}
	
	static step = function() {
		var _shp = getInputData(5);
		
		inputs[ 9].setVisible(_shp == 2);
		inputs[10].setVisible(_shp == 2);
		inputs[11].setVisible(_shp == 2);
		
		tools = _shp == 2? mesh_tools : -1;
		
		var _tex  = getInputData(6);
		
		if(is_array(_tex)) {
			var meshes = attributes.mesh;
			
			for( var i = array_length(meshes); i < array_length(_tex); i++ )
				newMesh(i);
		}
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		if(IS_FIRST_FRAME) reset();
		
		outputs[0].setValue(objects);
	}
	
	static reset = function() { 
		var _tex  = getInputData(6);
		var _spwn = getInputData(8);
		
		objects = [];
		if(!_spwn) return;
		
		objects = array_create_ext(is_array(_tex)? array_length(_tex) : 1, function(i) /*=>*/ {return spawn(i)});
	}
	
	static getGraphPreviewSurface = function() /*=>*/ {return getInputData(6)};
	
	////- Serialize
	
	static attributeSerialize = function() {
		var att = {};
		
		var mesh = struct_try_get(attributes, "mesh", []);
		att.mesh = json_stringify(mesh);
		
		return att;
	}
	
	static attributeDeserialize = function(attr) {
		struct_append(attributes, attr); 
		
		if(struct_has(attr, "mesh"))
			attributes.mesh = json_parse(attr.mesh);
	}
}