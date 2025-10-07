#region
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_Rigid_Object", "Mesh edit",     "A");
		hotkeyCustom("Node_Rigid_Object", "Anchor remove", "E");
	});
#endregion

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
	
	update_on_frame    = true;
	manual_ungroupable = false;
	
	worldIndex      = undefined;
	worldScale      = 100;
	objects         = [];
	attributes.mesh = [];
	
	////- =Spawn
	newInput( 8, nodeValue_Bool(  "Spawn", true, "Make object spawn when start."));
	newInput(20, nodeValue_Int(   "Spawn Frame", 0));
	
	////- =Physics
	newInput(12, nodeValue_Int(    "Collision Group", 1));
	newInput( 0, nodeValue_Bool(   "Affect by Force", true));
	newInput( 1, nodeValue_Float(  "Mass", 10));
	newInput( 2, nodeValue_Slider( "Friction", 0.2));
	newInput( 3, nodeValue_Slider( "Air Resistance", 0.0));
	newInput( 4, nodeValue_Slider( "Rotation Resistance", 0.1));
	newInput(13, nodeValue_Slider( "Bounciness", 0.2));
	newInput(22, nodeValue_Float(  "Gravity Scale", 1));
	
	////- =Shape
	newInput( 6, nodeValue_Surface(     "Texture"));
	newInput( 5, nodeValue_Enum_Scroll( "Shape",  0, [ new scrollItem("Box",    s_node_shape_rectangle, 0), 
	                                                           new scrollItem("Circle", s_node_shape_circle,    0), 
	                                                           new scrollItem("Custom", s_node_shape_misc,      1) ]));
	newInput( 9, nodeValue_Trigger(     "Generate Mesh" ));
	b_gen_mesh = button(function() /*=>*/ {return generateAllMesh()}).setText("Generate Mesh");
	newInput(10, nodeValue_Slider(      "Mesh Expansion", 0, [ -2, 2, 0.1 ]));
	newInput(11, nodeValue_Bool(        "Add Pixel for Empty", true));
	
	////- =Transform
	newInput( 7, nodeValue_Vec2(     "Start Position", [ 16, 16 ])).setHotkey("G");
	newInput(17, nodeValue_Rotation( "Start Rotation", 0)).setHotkey("R");
	
	////- =Initial Velocity
	newInput(18, nodeValue_Bool( "Use Initial Velocity", false));
	newInput(19, nodeValue_Vec2( "Initial Velocity", [ 0, 0 ]));
	
	////- =Simulation
	newInput(14, nodeValue_Bool( "Continuous", false));
	newInput(15, nodeValue_Bool( "Fix Rotation", false));
	newInput(16, nodeValue_Bool( "Sleepable",  true));
	newInput(21, nodeValue_Bool( "Activate on Spawn",  true));
	
	// inputs 23
	
	newOutput(0, nodeValue_Output("Object", VALUE_TYPE.rigid, objects));
	
	array_foreach(inputs, function(inp, ind) /*=>*/ { 
		if(ind == 6) inp.setAnimable(false);
		else         inp.setAnimable(false).rejectArray();
	})
	
	input_display_list = [ 
		["Spawn",	   false, 8], 20, 
		["Physics",	   false], 0, 1, 2, 3, 4, 13, 
		["Shape",	   false], 6, 5, b_gen_mesh, 10, 11, 
		["Transform",  false], 7, 17, 
		["Initial Velocity", false, 18], 19, 
		["Simulation",  true], 14, 15, 16, 21, 
	];
	
	static newMesh = function(_index) {
		var _tex  = inputs[6].getValue();
		if(is_array(_tex)) _tex = array_safe_get(_tex, _index);
		
		var _sw = surface_get_width_safe(_tex);
		var _sh = surface_get_height_safe(_tex);
		
		var mesh     = struct_try_get(attributes, "mesh", []);
		mesh[_index] = [ [  0,   0], [_sw,   0], 
						 [_sw, _sh], [  0, _sh] ];
		attributes.mesh = mesh;
	}
	newMesh(0);
	
	tools = [];
	
	mesh_tools = [
		new NodeTool( "Mesh edit",		THEME.mesh_tool_edit   ),
		new NodeTool( "Anchor remove",  THEME.mesh_tool_delete ),
	];
		
	is_convex = true;
	hover_index     = -1;
	anchor_dragging = -1;
	anchor_drag_sx  = -1;
	anchor_drag_sy  = -1;
	anchor_drag_mx  = -1;
	anchor_drag_my  = -1;
	
	////- Mesh
	
	static getPreviewValues = function() { return inputs[6].getValue(); }
	
	static generateAllMesh = function() {
		var _tex = inputs[6].getValue();
			
		if(is_array(_tex)) {
			for( var i = 0, n = array_length(_tex); i < n; i++ ) 
				generateMesh(i);
		} else 
			generateMesh();
		doUpdate();
	}
	
	static generateMesh = function(index = 0) {
		var _tex = inputs[6].getValue();
		var _exp = inputs[10].getValue();
		var _pix = inputs[11].getValue();
		
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
		
		if(_pix && array_empty(mesh))
			mesh = [ [ cmX - .5, cmY - .5 ], [ cmX + .5, cmY - .5 ], 
				     [ cmX + .5, cmY + .5 ], [ cmX - .5, cmY + .5 ] ];
		
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
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		if(worldIndex == undefined) return;
		
		var pos = inputs[7].getValue();
		var px  = _x + pos[0] * _s;
		var py  = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[ 7].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[17].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		var _shp = inputs[5].getValue();
		var _tex = inputs[6].getValue();
		var _pos = inputs[7].getValue();
		var _dim = surface_get_dimension(_tex);
		var hovering = false;
		
		if(previewing == 0 && isNotUsingTool()) {
			_x = _x + (_pos[0] - _dim[0] / 2) * _s;
			_y = _y + (_pos[1] - _dim[1] / 2) * _s;
		}
		
		draw_set_color(COLORS._main_accent);
		switch(_shp) {
			case 0 : draw_rectangle(_x, _y, _x + _dim[0] * _s, _y + _dim[1] * _s, true); return false;
			case 1 : draw_ellipse(  _x, _y, _x + _dim[0] * _s, _y + _dim[1] * _s, true); return false;
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
			
			draw_line_width(_dx0, _dy0, _dx1, _dy1, hover_index == i + 0.5? 4 : 2);
			
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
			
			if(isNotUsingTool())
				draw_circle_prec(_dx, _dy, 4, false)
			else {
				draw_sprite_colored(THEME.anchor_selector, hover_index == i, _dx, _dy);
				if(point_distance(_mx, _my, _dx, _dy) < 8)
					_hover = i;
			}
		}
		
		hover_index = _hover;
		hovering = hovering || _hover != -1;
		
		if(anchor_dragging > -1) {
			var dx = anchor_drag_sx + (_mx - anchor_drag_mx) / _s;
			var dy = anchor_drag_sy + (_my - anchor_drag_my) / _s;
			
			dx = value_snap(dx, _snx);
			dy = value_snap(dy, _sny);
			
			mesh[anchor_dragging][0] = dx;
			mesh[anchor_dragging][1] = dy;
			
			if(mouse_release(mb_left))
				anchor_dragging = -1;
			return hovering;
		}
		
		if(hover_index == -1) return hovering;
			
		if(frac(hover_index) == 0) {
			if(mouse_click(mb_left, active)) {
				if(isUsingTool(0)) {
					anchor_dragging = hover_index;
					anchor_drag_sx  = mesh[hover_index][0];
					anchor_drag_sy  = mesh[hover_index][1];
					anchor_drag_mx  = _mx;
					anchor_drag_my  = _my;
					
				} else if(isUsingTool(1)) {
					if(array_length(mesh) > 3)
						array_delete(mesh, hover_index, 1);
				}
			}
			
		} else {
			if(mouse_click(mb_left, active)) {
				var ind = ceil(hover_index);
				ds_list_insert(lx, ind, (_mx - _x) / _s);
				ds_list_insert(ly, ind, (_my - _y) / _s);
				
				anchor_dragging = ind;
				anchor_drag_sx  = mesh[ind][0];
				anchor_drag_sy  = mesh[ind][1];
				anchor_drag_mx  = _mx;
				anchor_drag_my  = _my;
			}
		}
		
		return hovering;
	}
	
	////- Rigidbody
	
	static spawn = function(_index = 0, _position = undefined) {
		if(worldIndex == undefined) return undefined;
		
		var _shp  = inputs[ 5].getValue();
		var _tex  = inputs[ 6].getValue();
		var _spos = inputs[ 7].getValue();
		var _srot = inputs[17].getValue();
		var _spx, _spy;
		
		if(_position == undefined) {
			_spx = _spos[0] / worldScale;
			_spy = _spos[1] / worldScale;
			
		} else {
			_spx = _position[0] / worldScale;
			_spy = _position[1] / worldScale;
		}
		
		gmlBox2D_Object_Create_Begin(worldIndex, _spx, _spy, false);
		
		if(is_array(_tex)) { 
			_index = safe_mod(_index, array_length(_tex)); 
			_tex   = array_safe_get_fast(_tex, _index); 
		}
		
		if(is(_tex, SurfaceAtlas))
			_tex = _tex.getSurface();
			
		var ww = surface_get_width_safe(_tex);
		var hh = surface_get_height_safe(_tex);
		
		var ow = ww / 2 / worldScale;
		var oh = hh / 2 / worldScale;
		
		switch(_shp) {
			case 0 : gmlBox2D_Object_Create_Shape_Box(ow, oh);         break;
			case 1 : gmlBox2D_Object_Create_Shape_Circle(min(ow, oh)); break;
				
			case 2 : 
				var meshes = attributes.mesh;
				if(array_safe_get_fast(meshes, _index, noone) == noone) return undefined;
					
				var mesh = meshes[_index];
				var len  = array_length(mesh);
				var buff = buffer_create(8 * 2 * len, buffer_fixed, 8);
				
				buffer_to_start(buff);
				for(var i = 0; i < len; i++) {
					buffer_write(buff, buffer_f64, mesh[i][0] / worldScale - ow);
					buffer_write(buff, buffer_f64, mesh[i][1] / worldScale - oh);
				}
				
				gmlBox2D_Object_Create_Shape_Polygon(buffer_get_address(buff), len, 0);
				buffer_delete(buff);
				break;
		}
		
		var objId  = gmlBox2D_Object_Create_Complete(); 
		var boxObj = new __Box2DObject(objId, _tex);
		
		var _mov	  = inputs[0].getValue();
		var _weig     = inputs[1].getValue();
		var _cnt_frc  = inputs[2].getValue();
		var _air_res  = inputs[3].getValue();
		var _rot_frc  = inputs[4].getValue();
		var _bouncy   = inputs[13].getValue();
		var collIndex = inputs[12].getValue();
		var _conti    = inputs[14].getValue();
		var _fixRot   = inputs[15].getValue();
		var _sleep    = inputs[16].getValue();
		var _activate = inputs[21].getValue();
		var _gravSca  = inputs[22].getValue();
		
		gmlBox2D_Object_Set_Enable(       objId, _activate);
		gmlBox2D_Object_Set_Rotation(     objId, _srot);
		gmlBox2D_Object_Set_Fixed_Angle(  objId, false);
		gmlBox2D_Object_Set_Body_Type(    objId, _mov? 2 : 0);
		gmlBox2D_Object_Set_Damping(      objId, _air_res, _rot_frc);
		gmlBox2D_Object_Set_Gravity_Scale(objId, _gravSca);
		gmlBox2D_Object_Set_Continuous(   objId, _conti);
		gmlBox2D_Object_Set_Fixed_Angle(  objId, _fixRot);
		gmlBox2D_Object_Set_Sleepable(    objId, _sleep);
		
		gmlBox2D_Shape_Set_Friction(     objId, _cnt_frc);
		gmlBox2D_Shape_Set_Restitution(  objId, _bouncy);
		
		var _useInitV = inputs[18].getValue();
		var _initV    = inputs[19].getValue();
		
		if(_useInitV) gmlBox2D_Object_Set_Velocity(objId, _initV[0], _initV[1]);
		
		return boxObj;
	}
	
	static step = function() {
		var _shp = inputs[5].getValue();
		
		inputs[ 9].setVisible(_shp == 2);
		inputs[10].setVisible(_shp == 2);
		inputs[11].setVisible(_shp == 2);
		
		tools = _shp == 2? mesh_tools : -1;
		
		var _tex  = inputs[6].getValue();
		
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
		
		if(IS_FIRST_FRAME) objects = [];
		outputs[0].setValue(objects);
		
		var _tex  = inputs[ 6].getValue();
		var _spwn = inputs[ 8].getValue();
		var _spfr = inputs[20].getValue();
		
		if(!_spwn) return;
		
		if(_frame == _spfr) {
			objects = _spwn? array_create_ext(is_array(_tex)? array_length(_tex) : 1, function(i) /*=>*/ {return spawn(i)}) : [];
			outputs[0].setValue(objects);
		}
		
	}
	
	static getGraphPreviewSurface = function() /*=>*/ {return inputs[6].getValue()};
	
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