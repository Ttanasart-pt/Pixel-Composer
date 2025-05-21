function Node_Rigid_Fracture(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Fracture";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 96);
	
	manual_ungroupable = false;
	
	worldIndex = undefined;
	worldScale = 100;
	objects    = [];
	meshes     = [];
	
	newInput( 0, nodeValue_Surface( "Base Texture"));
	
	////- Fracture
	
	newInput( 1, nodeValue_Surface( "Fracture Map"));
	newInput( 2, nodeValue_Slider(  "Fracture Threshold", .1));
	newInput( 3, nodeValue_Slider(  "Mesh Expansion", 0, [ -2, 2, 0.1 ]));
	
	////- Physics
	
	newInput( 4, nodeValue_Float(  "Density", 1));
	newInput( 5, nodeValue_Slider( "Friction", 0.2));
	newInput( 6, nodeValue_Slider( "Air Resistance", 0.0));
	newInput( 7, nodeValue_Slider( "Rotation Resistance", 0.1));
	newInput( 8, nodeValue_Slider( "Bounciness", 0.2));
	newInput(15, nodeValue_Float(  "Gravity Scale", 1));
	newInput(14, nodeValue_Bool(   "Activate on Spawn", true));
	
	////- Transform
	
	newInput( 9, nodeValue_Vec2( "Position", [ 0, 0 ] ));
	
	////- Joint
	
	newInput(10, nodeValue_Bool(   "Use Joint", false ));
	newInput(11, nodeValue_Float(  "Stiffness", 10 ));
	newInput(12, nodeValue_Slider( "Damping", .5 ));
	newInput(13, nodeValue_Float(  "Breaking Force", 0 )).setTooltip("Amount of force to break the joint, zero for unbreakable.");
	
	// input 16
	
	newOutput(0, nodeValue_Output("Object", VALUE_TYPE.rigid, objects));
	
	input_display_list = [ 0,  
		["Fracture",  false], 1, button(function() /*=>*/ {return fracture()}).setText("Fracture"), 2, 3, 
		["Physics",   false], 4, 5, 6, 7, 8, 15, 14, 
		["Transform", false], 9, 
		["Joint",     false, 10], 11, 12, 13, 
	];
	
	temp_surface   = [ noone, noone ];
	
	////- Mesh
	
	static generateMesh = function(_texture) {
		if(!is_surface(_texture)) return [];
		
		var _exp = getInputData(3);
		var _pix = false;
		
		var mesh = [];
		var ww   = surface_get_width_safe(_texture);
		var hh   = surface_get_height_safe(_texture);
		
		var surface_buffer = buffer_create(ww * hh * 4, buffer_fixed, 2);
		buffer_get_surface(surface_buffer, _texture, 0);
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
		
		if(cmA == 0) return [];
		
		cmX /= cmA;
		cmY /= cmA;
		
		var temp = surface_create_valid(ww, hh);
		
		surface_set_shader(temp, sh_mesh_generation);
			shader_set_f("dimension", ww, hh);
			shader_set_f("com",       cmX, cmY);
			draw_surface_safe(_texture);
		surface_reset_shader();
		
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
		
		return mesh;
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
	
	////- Fracture
	
	static separateShape = function(_fracSurf) {
		var _thres  = getInputData(2);
		
		var ww = surface_get_width_safe(_fracSurf);
		var hh = surface_get_height_safe(_fracSurf);
		
		for(var i = 0; i < 2; i++) temp_surface[i] = surface_verify(temp_surface[i], ww, hh, surface_rgba32float);
		
		#region region indexing
			surface_set_shader(temp_surface[1], sh_seperate_shape_index);
				shader_set_f("dimension", ww, hh);
				shader_set_i("ignore",    true);
				shader_set_i("mode",      0);
				
				draw_empty();
			surface_reset_shader();
			
			shader_set(sh_seperate_shape_ite);
				shader_set_f("dimension", ww, hh);
				shader_set_f("threshold", _thres);
				shader_set_i("ignore",    true);
				shader_set_i("mode",      0);
				shader_set_surface("map", _fracSurf);
			shader_reset();
		
			var res_index = 0, iteration = ww + hh;
			var bg = 0;
			
			repeat(iteration) {
				surface_set_shader(temp_surface[bg], sh_seperate_shape_ite,, BLEND.over);
					draw_surface_safe(temp_surface[!bg]);
				surface_reset_shader();
			
				res_index = bg;
				bg = !bg;
			}
		#endregion
		
		#region count and match color
			var i = 0, pxc = ww * hh;
			var reg = ds_map_create();
			
			var b = buffer_create(pxc * 16, buffer_fixed, 1);
			buffer_get_surface(b, temp_surface[res_index], 0);
			buffer_seek(b, buffer_seek_start, 0);
			
			repeat(pxc) {
				var _r = buffer_read(b, buffer_f32);
				var _g = buffer_read(b, buffer_f32);
				var _b = buffer_read(b, buffer_f32);
				var _a = buffer_read(b, buffer_f32);
				
				if(_r == 0 && _g == 0 && _b == 0 && _a == 0) continue;
				reg[? _g * ww + _r] = [ _r, _g, _b, _a ];
			}
			
			var px = ds_map_size(reg);
			
			if(px == 0) { ds_map_destroy(reg); return []; }
		#endregion
		
		#region extract region
			var _atlas = array_create(px);
			var key    = ds_map_keys_to_array(reg);
			var _ind   = 0;
			
			for(var i = 0; i < px; i++) {
				var _k  = key[i];
				var _cc = reg[? _k];
				
				var min_x = round(_cc[0]);
				var min_y = round(_cc[1]);
				var max_x = round(_cc[2]);
				var max_y = round(_cc[3]);
				
				var _sw = max_x - min_x + 1;
				var _sh = max_y - min_y + 1;
				
				if(_sw * _sh <= 4) continue;
				
				var _outSurf = surface_create_valid(_sw, _sh);
				
				surface_set_shader(_outSurf, sh_seperate_shape_sep);
					shader_set_surface("original", _fracSurf);
					shader_set_f("color",          _cc);
					shader_set_i("override",       true);
					shader_set_color("overColor",  ca_white);
					
					draw_surface_safe(temp_surface[res_index], -min_x, -min_y);
				surface_reset_shader();
				
				_atlas[_ind++] = new SurfaceAtlas(_outSurf, min_x, min_y).setOrginalSurface(_fracSurf);
			}
			
			array_resize(_atlas, _ind);
			ds_map_destroy(reg);
		#endregion
		
		return _atlas;
	}
	
	static fracture = function() {
		for( var i = 0, n = array_length(meshes); i < n; i++ ) {
			var _mesh = meshes[i];
			surface_free_safe(_mesh.mask);
			surface_free_safe(_mesh.texture);
		}
		
		meshes = [];
		var _fracSurf = getInputData(1);
		if(!is_surface(_fracSurf)) return;
		
		var _atlases = separateShape(_fracSurf);
		
		for( var i = 0, n = array_length(_atlases); i < n; i++ ) {
			var _atlas = _atlases[i];
			var _mask  = _atlas.getSurface();
			
			meshes[i] = {
				mask: _mask,
				texture: noone,
				
				points: generateMesh(_mask),
				bbox: [ _atlas.x, _atlas.y ],
			}
		}
		
	}
	
	////- Rigidbody
	
	static spawn = function() {
		objects = [];
		if(array_empty(meshes)) return;
		
		var _baseSurf = getInputData(0);
		if(!is_surface(_baseSurf)) return;
		
		var _dens     = getInputData(4);
		var _cnt_frc  = getInputData(5);
		var _air_res  = getInputData(6);
		var _rot_frc  = getInputData(7);
		var _bouncy   = getInputData(8);
		var _sPos     = getInputData(9);
		var _gravSca  = getInputData(15);
		var _activate = getInputData(14);
		
		var sw = surface_get_width_safe(_baseSurf);
		var sh = surface_get_height_safe(_baseSurf);
		
		var _spos = [ _sPos[0] - sw / 2, _sPos[1] - sh / 2 ];
		
		for( var i = 0, n = array_length(meshes); i < n; i++ ) {
			var _mesh = meshes[i];
			var _mask = _mesh.mask;
			var _pnts = _mesh.points;
			var _bbox = _mesh.bbox;
			
			var ww = surface_get_width_safe(_mask);
			var hh = surface_get_height_safe(_mask);
			
			_mesh.texture = surface_verify(_mesh.texture, ww, hh);
			surface_set_target(_mesh.texture);
				DRAW_CLEAR
				BLEND_OVERRIDE
					draw_surface(_baseSurf, -_bbox[0], -_bbox[1]);
				BLEND_MULTIPLY
					draw_surface(_mask, 0, 0);
				BLEND_NORMAL
			surface_reset_target();
			
			var px = (_spos[0] + _bbox[0]) / worldScale;
			var py = (_spos[1] + _bbox[1]) / worldScale;
			
			var len = array_length(_pnts);
			if(len < 3) continue;
				
			gmlBox2D_Object_Create_Begin(worldIndex, px, py, false);
			
			var buff = buffer_create(8 * 2 * len, buffer_fixed, 8);
			
			buffer_to_start(buff);
			for(var j = 0; j < len; j++) {
				buffer_write(buff, buffer_f64, _pnts[j][0] / worldScale);
				buffer_write(buff, buffer_f64, _pnts[j][1] / worldScale);
			}
			
			gmlBox2D_Object_Create_Shape_Polygon(buffer_get_address(buff), len, 0);
			buffer_delete(buff);
			
			var objId  = gmlBox2D_Object_Create_Complete(); 
			var boxObj = new __Box2DObject(objId, _mesh.texture);
			
			// gmlBox2D_Object_Set_Body_Type(  objId, 0);
			gmlBox2D_Object_Set_Enable(        objId, _activate);
			gmlBox2D_Object_Set_Density(       objId, _dens);
			gmlBox2D_Object_Set_Damping(       objId, _air_res, _rot_frc);
			gmlBox2D_Object_Set_Gravity_Scale( objId, _gravSca);
			gmlBox2D_Shape_Set_Friction(       objId, _cnt_frc);
			gmlBox2D_Shape_Set_Restitution(    objId, _bouncy);
			
			boxObj.px = px * worldScale;
			boxObj.py = py * worldScale;
			boxObj.xoffset = ww / 2;
			boxObj.yoffset = hh / 2;
			
			array_push(objects, boxObj);
		}
		
		//// ===== joints =====
		
		var _joint = getInputData(10);
		if(!_joint) return;
		
		var _jstif = getInputData(11);
		var _jdamp = getInputData(12);
		var _jbrek = getInputData(13);
		
		var _points = array_create_ext(array_length(objects), function(i) /*=>*/ {
			var _o  = objects[i];
			var _v2 = new __vec2(_o.px, _o.py);
			_v2.objId = _o.objId;
			
			return _v2;
		});
		
		var _mst  = minimum_spanning_tree(_points);
		for( var i = 0, n = array_length(_mst); i < n; i++ ) {
			var _edge = _mst[i];
			var _p1 = _points[_edge.p1].objId;
			var _p2 = _points[_edge.p2].objId;
			
			gmlBox2D_Joint_Weld(worldIndex, _p1, _p2, -9999, -9999, _jstif, _jdamp, _jbrek);
		}
		
		return;
	}
	
	////- Update
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(worldIndex == undefined) return;
		
		var _baseSurf = getInputData(0);
		var _sPos     = getInputData(9);
		
		if(!is_surface(_baseSurf)) return;
		
		var _sw = surface_get_width_safe(_baseSurf);
		var _sh = surface_get_height_safe(_baseSurf);
		
		var _px = _x + (_sPos[0] - _sw / 2) * _s;
		var _py = _y + (_sPos[1] - _sh / 2) * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_rectangle(_px, _py, _px + _sw * _s, _py + _sh * _s, true);
		
		var ox, oy, nx, ny;
		for( var i = 0, n = array_length(meshes); i < n; i++ ) {
			var _mesh = meshes[i];
			var _pnts = _mesh.points;
			var _bbox = _mesh.bbox;
			
			if(array_empty(_pnts)) continue;
			
			var fx = _px + (_bbox[0] + _pnts[0][0]) * _s;
			var fy = _py + (_bbox[1] + _pnts[0][1]) * _s;
			
			ox = fx;
			oy = fy;
			
			for( var j = 1, m = array_length(_pnts); j < m; j++ ) {
				nx = _px + (_bbox[0] + _pnts[j][0]) * _s;
				ny = _py + (_bbox[1] + _pnts[j][1]) * _s;
				
				draw_line(ox, oy, nx, ny);
				
				ox = nx;
				oy = ny;
			}
			
			draw_line(fx, fy, ox, oy);
		}
		
		InputDrawOverlay(inputs[9].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		if(IS_FIRST_FRAME) {
			fracture();
			spawn();
		}
		
		outputs[0].setValue(objects);
	}
	
	static getGraphPreviewSurface = function() /*=>*/ {return getInputData(0)};
	
}

function minimum_spanning_tree(points) {
    var n = array_length(points);
    var edges = [];
    
    for (var i = 0; i < n; i++)
    for (var j = i + 1; j < n; j++) {
        var dist = point_distance(points[i].x, points[i].y, points[j].x, points[j].y);
        array_push(edges, {dist: dist, p1: i, p2: j});
    }

    array_sort(edges, function(a,b) /*=>*/ {return a.dist - b.dist});

    var parent    = array_create(n, -1);
    var rank      = array_create(n, 0);
    var mst_edges = [];

    function find(parent, v) {
        if (parent[v] == -1) 
            return v;
        
        parent[v] = find(parent, parent[v]);
        return parent[v];
    }

    function union(parent, rank, v1, v2) {
        var root1 = find(parent, v1);
        var root2 = find(parent, v2);

        if (root1 != root2) {
            if (rank[root1] > rank[root2]) {
                parent[root2] = root1;
                
            } else if (rank[root1] < rank[root2]) {
                parent[root1] = root2;
                
            } else {
                parent[root2] = root1;
                rank[root1]++;
            }
        }
    }

    for (var i = 0; i < array_length(edges); i++) {
        var edge = edges[i];
        if (find(parent, edge.p1) != find(parent, edge.p2)) {
            union(parent, rank, edge.p1, edge.p2);
            array_push(mst_edges, edge);
        }
    }

    return mst_edges;
}