function Node_create_3D_Json(_x, _y, _group = noone) {
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename_compat("3d Json (.json)|*.json", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_3D_Mesh_Json(_x, _y, _group);
	node.skipDefault();
	node.setPath(path);
	return node;
}

function Node_create_3D_Json_path(_x, _y, path) {
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_3D_Mesh_Json(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.skipDefault();
	node.setPath(path);
	return node;
}

function Node_3D_Mesh_Json(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Json";
	setAlwaysTimeline(new timelineItemNode_3D_Json(self));
	
	var i = in_mesh;
	
	////- =Transform
	newInput(i+4, nodeValue_Bool( "Reset Origin", true ));
	
	////- =Object
	newInput(i+0, nodeValue_FPath(   "File Path" )).setDisplay(VALUE_DISPLAY.path_load, { filter: "Json Object (.json)|*.json" });
	newInput(i+2, nodeValue_Float(   "Import Scale", 1/16 ));
	newInput(i+3, nodeValue_EScroll( "Axis",         1, [ "Z up", "Y up" ]));
	
	////- =Animation
	newInput(i+8, nodeValue_Bool(  "Stretch Animation", false ));
	newInput(i+7, nodeValue_Float( "Animation Speed",   1     ));
	newInput(i+9, nodeValue_Bool(  "Loop",             true   ));
	newInput(i+6, nodeValue_Text(  "Active Animation"         ));
	
	////- =Material
	newInput(i+1, nodeValue_Bool( "Flip UV", false, "Flip UV axis, can be use to fix some texture mapping error."));
	newInput(i+5, nodeValue_Bool( "Use Texture Dimension", true ));
	// input i+10
		
	array_foreach(inputs, function(i,_) /*=>*/ {return i.rejectArray()}, in_mesh);
	
	element_editing_visible = undefined;
	
	function drawElementGroup(_out, _x, _y, _w, _m, _hover, _focus) {
		var hg = ui(24);
		var bs = ui(16);
		var hh = 0;
		
		var isGroup = is_struct(_out);
		
		var _uuid = isGroup? (_out[$ "uuid"] ?? "") : _out;
		if(_uuid == "" || !has(idMap, _uuid)) return hh;
		
		var _ele = idMap[$ _uuid];
		var _nam = _ele[$ "name"] ?? "";
		var _typ = _ele[$ "type"] ?? "";
		var _cli = _ele[$ "color"] ?? 0;
		var _col = COLORS.labels[_cli % array_length(COLORS.labels)];
		
		if(_typ == "") return hh;
		
		var tx = _x + ui(12);
		var yc = _y + hg / 2;
		
		var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + hg - 1);
		if(_hov) draw_sprite_stretched_ext(THEME.box_r2, 0, _x + ui(8), _y, _w - ui(16), hg, COLORS._main_icon, .1);
				
		var _vis   = attributes.element_visible[$ _uuid] ?? true;
		var vhover = _hover && point_in_circle(_m[0], _m[1], tx + bs / 2, yc, bs / 2);
		
		draw_sprite_ui_uniform(THEME.visible, _vis, tx + bs / 2, yc, .5, vhover? COLORS._main_icon_light : COLORS._main_icon);
		if(vhover) {
			if(element_editing_visible != undefined && _vis != element_editing_visible) {
				attributes.element_visible[$ _uuid] = element_editing_visible;
				triggerRender();
			}
			
			if(mouse_lpress(_focus))
				element_editing_visible = !_vis;
		}
		tx += bs;
		
		if(isGroup) {
			var _opn = _ele[$ "isOpen"] ?? true;
			var vhover = _hover && point_in_circle(_m[0], _m[1], tx + bs / 2, yc, bs / 2);
			
			draw_sprite_ui_uniform(THEME.folder_content, _opn, tx + bs / 2, yc, .5, vhover? COLORS._main_icon_light : COLORS._main_icon);
			if(vhover) {
				if(mouse_lpress(_focus))
					_ele[$ "isOpen"] = !_opn;
			}
			
			tx += bs;
		}
		
		if(!isGroup) {
			var cc = merge_color(_col, COLORS._main_icon_light, .5);
			draw_sprite_ui_uniform(THEME.addon_icon, 0, tx + bs / 2, yc, .6, cc, .5);
			tx += bs;
		}
		
		tx += ui(4);
		var cc = merge_color(_col, COLORS._main_text, .5);
		draw_set_text(f_p3, fa_left, fa_center, cc);
		draw_text_add(tx, yc, _nam);
		
		_y += hg;
		hh += hg;
		
		if(isGroup && _opn)
		for( var i = 0, n = array_length(_out.children); i < n; i++ ) {
			var _hh  = drawElementGroup(_out.children[i], _x + ui(12), _y, _w - ui(12), _m, _hover, _focus);
			
			_y += _hh;
			hh += _hh;
		}
		
		return hh;
	}
	
	element_renderer_h = 0;
	element_renderer   = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { 
		var yy = _y + ui(8);
		var hg = ui(24);
		var bs = ui(16);
		var hh = ui(16);
		
		var _h = element_renderer_h;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		if(outliner == undefined) {
			for( var i = 0, n = array_length(elements); i < n; i++ ) {
				var _ele  = elements[i];
				var _nam  = _ele[$ "name"] ?? "";
				var _uuid = _ele[$ "uuid"] ?? "";
				var _vis  = attributes.element_visible[$ _uuid] ?? true;
				
				var tx = _x + ui(12);
				var yc = yy + hg / 2;
				
				var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, yy, _x + _w, yy + hg - 1);
				if(_hov) draw_sprite_stretched_ext(THEME.box_r2, 0, _x + ui(8), yy, _w - ui(16), hg, COLORS._main_icon, .1);
					
				var vhover = _hover && point_in_circle(_m[0], _m[1], tx + bs / 2, yc, bs / 2);
				draw_sprite_ui_uniform(THEME.visible, _vis, tx + bs / 2, yc, .5, vhover? COLORS._main_icon_light : COLORS._main_icon);
				if(vhover) {
					if(element_editing_visible != undefined && _vis != element_editing_visible) {
						attributes.element_visible[$ _uuid] = element_editing_visible;
						triggerRender();
					}
					
					if(mouse_lpress(_focus))
						element_editing_visible = !_vis;
				}
				tx += bs;
				
				draw_sprite_ui_uniform(THEME.addon_icon, 0, tx + bs / 2, yc, .6, COLORS._main_icon);
				tx += bs;
				
				tx += ui(4);
				draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
				draw_text_add(tx, yc, _nam);
				
				yy += hg;
				hh += hg;
			}
			
		} else {
			for( var i = 0, n = array_length(outliner); i < n; i++ ) {
				var _hh  = drawElementGroup(outliner[i], _x, yy, _w, _m, _hover, _focus);
				
				yy += _hh;
				hh += _hh;
			}
		}
		
		if(mouse_lrelease()) element_editing_visible = undefined;
		
		element_renderer_h = hh;
		return hh;
	}); 
	
	animation_renderer_h = 0;
	animation_renderer   = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { 
		var yy = _y + ui(8);
		var hg = ui(24);
		var bs = ui(16);
		var hh = ui(16);
		
		var _h = animation_renderer_h;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		var _animCurr = inputs[in_mesh+6].getValue();
		
		for( var i = 0, n = array_length(animations); i < n; i++ ) {
			var _ele  = animations[i];
			var _nam  = _ele[$ "name"] ?? "";
			var _uuid = _ele[$ "uuid"] ?? "";
			var _lens = _ele[$ "length"] ?? 0;
			var _curr = _animCurr == _uuid;
			
			var tx = _x + ui(12);
			var yc = yy + hg / 2;
			
			var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, yy, _x + _w, yy + hg - 1);
			if(_hov) {
				draw_sprite_stretched_ext(THEME.box_r2, 0, _x + ui(8), yy, _w - ui(16), hg, COLORS._main_icon, .1);
				if(mouse_lpress(_focus))
					inputs[in_mesh+6].setValue(_curr? "" : _uuid);
			}
			
			draw_sprite_ui_uniform(THEME.sequence_control, 1, tx + bs / 2, yc, .5, _curr? COLORS._main_value_positive : COLORS._main_icon);
			tx += bs;
			
			tx += ui(4);
			draw_set_text(f_p3, fa_left, fa_center, _curr? COLORS._main_value_positive : COLORS._main_text);
			draw_text_add(tx, yc, _nam);
			
			draw_set_text(f_p3, fa_right, fa_center, COLORS._main_text_sub)
			draw_text_add(_x + _w - ui(24), yc, $"{_lens}s");
			
			yy += hg;
			hh += hg;
		}
		
		animation_renderer_h = hh;
		return hh;
	}); 
	
	anim_section = [ "Animation", false ];
	
	status_label = new Inspector_Label();
	status_label.visible = false;
	
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform, 
		[ "Object",    false ], i+0, status_label, i+2, i+3,  
		[ "Elements",  false ], element_renderer,
		anim_section, animation_renderer, i+8, i+7, i+9, 
		[ "Material",  false ], i+1, i+5, -2, 
	]
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		newInput(index, nodeValue_D3Material("Material", new __d3dMaterial())).setVisible(true, true);
		
		array_push(input_display_list, inAmo);
		postCreateNewInput(index);
		return inputs[index];
	}
	
	setDynamicInput(1, false);
	
	////- Nodes
	
	attributes.element_visible = {};
	
	#region model
		idMap        = {};
		
		current_path = "";
		object       = noone;
		material_map = {};
		material_key = [];
		use_texture  = false;
		
		elements     = [];
		groups       = [];
		animations   = [];
		textures     = [];
		
		model_scale  = 1;
		model_axis   = 0;
		model_bbox   = [ 0, 0, 0, 0, 0, 0 ];
		
		tex_width    = 1;
		tex_height   = 1;
		
		outliner     = undefined;
		
		invertMatrix = noone;
	#endregion
	
	#region animation
		animCurrent = undefined;
	#endregion
	
	insp1button = button(function() /*=>*/ { 
		current_path = ""; 
		outputs[0].setValue(noone);
		triggerRender();
		
	}).setTooltip(__txt("Refresh"))
		.setIcon(THEME.refresh_icon, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	edit_time = 0;
	attributes.file_checker = true;
	array_push(attributeEditors, Node_Attribute("File Watcher", function() /*=>*/ {return attributes.file_checker}, function() /*=>*/ {return new checkBox(function() /*=>*/ {return toggleAttribute("file_checker")})}));
	
	function setPath(path) { inputs[in_mesh + 0].setValue(path); }
	
	////- Util
	
	function interpolate_lin(a, b, t) {
		return {
			x: lerp(a.x, b.x, t),
			y: lerp(a.y, b.y, t),
			z: lerp(a.z, b.z, t)
		}
	}
	
	function interpolate_catmul(k0, k1, k2, k3, dt) {
		var v0 = k0[$ "data_points"][0];
		var t0 = k0[$ "time"];
		
		var v1 = k1[$ "data_points"][0];
		var t1 = k1[$ "time"];
		
		var v2 = k2[$ "data_points"][0];
		var t2 = k2[$ "time"];
		
		var v3 = k3[$ "data_points"][0];
		var t3 = k3[$ "time"];
		
	    var t01 = t1 - t0;
	    var t12 = t2 - t1;
	    var t23 = t3 - t2;
	
	    var t = (dt  - t1) / t12;
		
	    var x0 = v0.x;
	    var x1 = v1.x;
	    var x2 = v2.x;
	    var x3 = v3.x;
		
	    var a = -x0 + 3*x1 - 3*x2 + x3;
	    var b = 2*x0 - 5*x1 + 4*x2 - x3;
	    var c = -x0 + x2;
	    var d = 2*x1;
	
	    var xt = .5 * (a*t*t*t + b*t*t + c*t + d);
		
	    var y0 = v0.y;
	    var y1 = v1.y;
	    var y2 = v2.y;
	    var y3 = v3.y;
	
	    var a = -y0 + 3*y1 - 3*y2 + y3;
	    var b = 2*y0 - 5*y1 + 4*y2 - y3;
	    var c = -y0 + y2;
	    var d = 2*y1;
	
	    var yt = .5 * (a*t*t*t + b*t*t + c*t + d);
	
	    var z0 = v0.z;
	    var z1 = v1.z;
	    var z2 = v2.z;
	    var z3 = v3.z;
	
	    var a = -z0 + 3*z1 - 3*z2 + z3;
	    var b = 2*z0 - 5*z1 + 4*z2 - z3;
	    var c = -z0 + z2;
	    var d = 2*z1;
	    var zt = .5 * (a*t*t*t + b*t*t + c*t + d);
	
	    return {x: xt, y: yt, z: zt};
	}

	////- Update
	
	__edgeA = __3dObject_Edge;
	
	static readElement = function(_element, _matrix) {
		if(has(_element, "rotation")) {
			var _rr = _element[$ "rotation"] ?? [0,0,0];
			var _rx = _rr[0];
			var _ry = _rr[1];
			var _rz = _rr[2];
			
		} else {
			var _rx = _element[$ "rotationX"] ?? 0;
			var _ry = _element[$ "rotationY"] ?? 0;
			var _rz = _element[$ "rotationZ"] ?? 0;
		}
		
		var _ro = [0,0,0];
		     if(has(_element, "origin"))         _ro = _element[$ "origin"];
		else if(has(_element, "rotationOrigin")) _ro = _element[$ "rotationOrigin"];
		
		var ox, oy, oz;
		var fx, fy, fz;
		
		ox = _ro[0];
		oy = _ro[1];
		oz = _ro[2];
		
		if(!has(_element, "faces")) return;
		
		var _face = _element.faces; 
		var _tMat = new BBMOD_Matrix();
		
		if(has(_element, "from")) {
			var _from = _element.from;
			fx = _from[0];
			fy = _from[1];
			fz = _from[2];
			
			_tMat = _tMat.Translate(fx, fy, fz);
		}
		
		_tMat = _tMat.Translate(-ox, -oy, -oz);
		_tMat = _tMat.RotateZ(-_rz);
		_tMat = _tMat.RotateY(-_ry);
		_tMat = _tMat.RotateX(-_rx);
		_tMat = _tMat.Translate(ox, oy, oz);
		
		var _cMat = _tMat.Mul(_matrix);
		var _tArr = _cMat.Mul(invertMatrix).ToArray();
		
		var fx = 0, fy = 0, fz = 0;
		var tx = 0, ty = 0, tz = 0;
		
		if(has(_element, "from")) {
			tx = _element.to[0] - _element.from[0];
			ty = _element.to[1] - _element.from[1];
			tz = _element.to[2] - _element.from[2];
		}
		
		// elements
		
		var _mat = [];
		var _vrt = [];
		var _edg = [];
		var _vbs = [];
		
		array_push(elements, _element);
		_element.name      = _element[$ "name"] ?? $"cube {array_length(elements)}";
		_element.type      = "element";
		_element.visible   = true;
		_element.material  = _mat;
		_element.transform = undefined;
		_element.matrix    = [_tArr];
		_element.vertex    = [_vrt];
		_element.edges     = [_edg];
		_element.VB        = _vbs;
		_element.uuid      = _element[$ "uuid"] ?? array_length(elements);
		
		var _uuid = _element.uuid;
		if(!has(attributes.element_visible, _uuid))
			attributes.element_visible[$ _uuid] = true;
		idMap[$ _uuid] = _element;
		
		var _matt = undefined;
		
		if(has(_face, "up") && (_face.up[$ "enabled"] ?? true)) {
			var _f  = _face.up;
			var fu = _f.uv[0], fv = _f.uv[3];
			var tu = _f.uv[2], tv = _f.uv[1];
			
			_matt = string_trim(_f[$ "texture"] ?? "", ["#"]);
			
			var _v = [ // -y
				__vertexA( [ fx, ty, fz ] ).setNormal( 0, 1, 0 ).setUV(fu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 0, 1, 0 ).setUV(tu, tv),
				__vertexA( [ fx, ty, tz ] ).setNormal( 0, 1, 0 ).setUV(fu, tv),
				
				__vertexA( [ tx, ty, fz ] ).setNormal( 0, 1, 0 ).setUV(tu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 0, 1, 0 ).setUV(tu, tv),
				__vertexA( [ fx, ty, fz ] ).setNormal( 0, 1, 0 ).setUV(fu, fv),
			];
			
			array_append(_vrt, _v);
			array_append(_edg, [ new __edgeA([fx, ty, fz], [fx, ty, tz]), new __edgeA([fx, ty, tz], [tx, ty, tz]), 
			                     new __edgeA([tx, ty, tz], [tx, ty, fz]), new __edgeA([tx, ty, fz], [fx, ty, fz]) ]); 
		}
		
		if(has(_face, "down") && (_face.down[$ "enabled"] ?? true)) {
			var _f = _face.down;
			var fu = _f.uv[0], fv = _f.uv[3];
			var tu = _f.uv[2], tv = _f.uv[1];
			
			_matt = string_trim(_f[$ "texture"] ?? "", ["#"]);
			
			var _v = [ // +y
				__vertexA( [ fx, fy, fz ] ).setNormal( 0,-1, 0 ).setUV(fu, fv),
				__vertexA( [ fx, fy, tz ] ).setNormal( 0,-1, 0 ).setUV(fu, tv),
				__vertexA( [ tx, fy, tz ] ).setNormal( 0,-1, 0 ).setUV(tu, tv),
				
				__vertexA( [ tx, fy, fz ] ).setNormal( 0,-1, 0 ).setUV(tu, fv),
				__vertexA( [ fx, fy, fz ] ).setNormal( 0,-1, 0 ).setUV(fu, fv),
				__vertexA( [ tx, fy, tz ] ).setNormal( 0,-1, 0 ).setUV(tu, tv),
			];
			
			array_append(_vrt, _v);
			array_append(_edg, [ new __edgeA([fx, fy, fz], [fx, fy, tz]), new __edgeA([fx, fy, tz], [tx, fy, tz]),
			                     new __edgeA([tx, fy, tz], [tx, fy, fz]), new __edgeA([tx, fy, fz], [fx, fy, fz]) ]);
		}
		
		if(has(_face, "east") && (_face.east[$ "enabled"] ?? true)) {
			var _f = _face.east;
			var fu = _f.uv[0], fv = _f.uv[3];
			var tu = _f.uv[2], tv = _f.uv[1];
			
			_matt = string_trim(_f[$ "texture"] ?? "", ["#"]);
			
			var _v = [ // +x
				__vertexA( [ tx, fy, fz ] ).setNormal( 1, 0, 0 ).setUV(tu, fv),
				__vertexA( [ tx, fy, tz ] ).setNormal( 1, 0, 0 ).setUV(fu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 1, 0, 0 ).setUV(fu, tv),
				
				__vertexA( [ tx, ty, fz ] ).setNormal( 1, 0, 0 ).setUV(tu, tv),
				__vertexA( [ tx, fy, fz ] ).setNormal( 1, 0, 0 ).setUV(tu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 1, 0, 0 ).setUV(fu, tv),
			];
			
			array_append(_vrt, _v);
			array_append(_edg, [ new __edgeA([tx, fy, fz], [tx, fy, tz]), new __edgeA([tx, fy, tz], [tx, ty, tz]), 
			                     new __edgeA([tx, ty, tz], [tx, ty, fz]), new __edgeA([tx, ty, fz], [tx, fy, fz]) ]);
		}
		
		if(has(_face, "west") && (_face.west[$ "enabled"] ?? true)) {
			var _f = _face.west;
			var fu = _f.uv[0], fv = _f.uv[3];
			var tu = _f.uv[2], tv = _f.uv[1];
			
			_matt = string_trim(_f[$ "texture"] ?? "", ["#"]);
			
			var _v = [ // -x
				__vertexA( [ fx, fy, fz ] ).setNormal(-1, 0, 0 ).setUV(fu, fv),
				__vertexA( [ fx, ty, tz ] ).setNormal(-1, 0, 0 ).setUV(tu, tv),
				__vertexA( [ fx, fy, tz ] ).setNormal(-1, 0, 0 ).setUV(tu, fv),
				
				__vertexA( [ fx, ty, fz ] ).setNormal(-1, 0, 0 ).setUV(fu, tv),
				__vertexA( [ fx, ty, tz ] ).setNormal(-1, 0, 0 ).setUV(tu, tv),
				__vertexA( [ fx, fy, fz ] ).setNormal(-1, 0, 0 ).setUV(fu, fv),
			];
			
			array_append(_vrt, _v);
			array_append(_edg, [ new __edgeA([fx, fy, fz], [fx, fy, tz]), new __edgeA([fx, fy, tz], [fx, ty, tz]), 
			                     new __edgeA([fx, ty, tz], [fx, ty, fz]), new __edgeA([fx, ty, fz], [fx, fy, fz]) ]);
		}
		
		if(has(_face, "north") && (_face.north[$ "enabled"] ?? true)) {
			var _f = _face.north;
			var fu = _f.uv[0], fv = _f.uv[3];
			var tu = _f.uv[2], tv = _f.uv[1];
			
			_matt = string_trim(_f[$ "texture"] ?? "", ["#"]);
			
			var _v = [ // -z
				__vertexA( [ fx, fy, fz ] ).setNormal( 0, 0,-1 ).setUV(fu, fv),
				__vertexA( [ tx, ty, fz ] ).setNormal( 0, 0,-1 ).setUV(tu, tv),
				__vertexA( [ fx, ty, fz ] ).setNormal( 0, 0,-1 ).setUV(fu, tv),
				
				__vertexA( [ tx, fy, fz ] ).setNormal( 0, 0,-1 ).setUV(tu, fv),
				__vertexA( [ tx, ty, fz ] ).setNormal( 0, 0,-1 ).setUV(tu, tv),
				__vertexA( [ fx, fy, fz ] ).setNormal( 0, 0,-1 ).setUV(fu, fv),
			];
			
			array_append(_vrt, _v);
			array_append(_edg, [ new __edgeA([fx, fy, fz], [fx, ty, fz]), new __edgeA([fx, ty, fz], [tx, ty, fz]), 
			                     new __edgeA([tx, ty, fz], [tx, fy, fz]), new __edgeA([tx, fy, fz], [fx, fy, fz]) ]);
			
		}
		
		if(has(_face, "south") && (_face.south[$ "enabled"] ?? true)) {
			var _f = _face.south;
			var fu = _f.uv[0], fv = _f.uv[3];
			var tu = _f.uv[2], tv = _f.uv[1];
			
			_matt = string_trim(_f[$ "texture"] ?? "", ["#"]);
			
			var _v = [ // +z
				__vertexA( [ fx, fy, tz ] ).setNormal( 0, 0, 1 ).setUV(fu, fv),
				__vertexA( [ fx, ty, tz ] ).setNormal( 0, 0, 1 ).setUV(fu, tv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 0, 0, 1 ).setUV(tu, tv),
				
				__vertexA( [ tx, fy, tz ] ).setNormal( 0, 0, 1 ).setUV(tu, fv),
				__vertexA( [ fx, fy, tz ] ).setNormal( 0, 0, 1 ).setUV(fu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 0, 0, 1 ).setUV(tu, tv),
			];
			
			array_append(_vrt, _v);
			array_append(_edg, [ new __edgeA([fx, fy, tz], [fx, ty, tz]), new __edgeA([fx, ty, tz], [tx, ty, tz]), 
			                     new __edgeA([tx, ty, tz], [tx, fy, tz]), new __edgeA([tx, fy, tz], [fx, fy, tz]) ]);
			                     
		}
		
		array_push(_vbs, object.buildVertex(_vrt));
		array_push(_mat, _matt);
		
		if(has(_element, "children"))
		for( var i = 0, n = array_length(_element.children); i < n; i++ )
			readElement(_element.children[i], _cMat);
	}
	
	static readMaterial = function(_data) {
		material_map  = has(_data, "textures")? _data.textures : (has(_data, "texture")? _data.texture : {});
		if(is_array(material_map)) {
			var _map = {};
			for( var i = 0, n = array_length(material_map); i < n; i++ )
				_map[$ i] = material_map[i];
			
			material_map = _map;
		}
		
		material_key = struct_get_names(material_map);
	}
	
	static readJson = function(_path) {
		if(!file_exists_empty(_path)) return;
		current_path = _path;
		edit_time    = file_get_modify_s(_path);
		status_label.visible = false;
		
		if(object != noone) object.destroy();
		object    = new __3dObject();
		object.VF = global.VF_POS_NORM_TEX_COL;
		
		var _data = json_load_struct(_path);
		if(!has(_data, "elements")) return;
		
		if(has(_data, "geckolib_modid")) {
			status_label.visible  = true;
			status_label.boxColor = COLORS._main_value_negative;
			status_label.text     = "Geckolib model support is limited.";
		}
		
		#region prop
			model_scale   = getInputSingle(in_mesh + 2);
			model_axis    = getInputSingle(in_mesh + 3);
			var _rootPath = project.getVar("json_asset_dir");
			
			if(has(_data, "resolution")) {
				tex_width  = _data[$ "resolution"][$ "width"]  ?? 16;
				tex_height = _data[$ "resolution"][$ "height"] ?? 16;
				
			} else {
				tex_width  = _data[$ "textureWidth"]  ?? 16;
				tex_height = _data[$ "textureHeight"] ?? 16;
			}
			
			outliner = _data[$ "outliner"];
		#endregion
		
		#region model
			var _elements = _data.elements;
			model_bbox    = [ infinity, infinity, infinity, -infinity, -infinity, -infinity ];
			
			var _rMat = [ 1, 0, 0, 0, 
				          0, 1, 0, 0, 
				          0, 0, 1, 0, 
				          0, 0, 0, 1 ];
			
			if(model_axis == 1)
				_rMat = [ 1, 0, 0, 0, 
					      0, 0, 1, 0, 
					      0,-1, 0, 0, 
					      0, 0, 0, 1 ];
			
			invertMatrix = new BBMOD_Matrix(_rMat).Scale(model_scale, model_scale, model_scale);
			
			elements = [];
			for( var i = 0, n = array_length(_elements); i < n; i++ )
				readElement(_elements[i], new BBMOD_Matrix());
		#endregion
		
		#region group
			groups = [];
			
			if(has(_data, "groups")) {
				var _groups = _data.groups;
				for( var i = 0, n = array_length(_groups); i < n; i++ ) {
					var _group  = _groups[i];
					var _uuid   = _group.uuid;
					_group.type = "group";
					
					if(!has(attributes.element_visible, _uuid))
						attributes.element_visible[$ _uuid] = true;
					
					_group._position = _group[$ "position"] ?? [0,0,0];
					_group._origin   = _group[$ "origin"]   ?? [0,0,0];
					_group._rotation = _group[$ "rotation"] ?? [0,0,0];
					_group._scale    = _group[$ "scale"]    ?? [1,1,1];
					
					array_push(groups, _group);
					idMap[$ _uuid] = _group;
				}
			}
		#endregion
		
		#region material
			readMaterial(_data);
			generateTexture();
		#endregion
		
		#region animation
			var _animations = _data[$ "animations"];
			animations = [];
			
			for( var i = 0, n = array_length(_animations); i < n; i++ ) {
				var _animation = _animations[i];
				
				if(has(_animation, "animators")) {
					array_push(animations, _animation);
					
					var _uuid = _animation[$ "uuid"] ?? $"anim{i}";
					_animation.uuid = _uuid;
					idMap[$ _uuid]  = _animation;
					
					var _animators = _animation.animators;
					var _animKeys  = struct_get_names(_animators);
					
					for( var j = 0, m = array_length(_animKeys); j < m; j++ ) {
						var _uuid = _animKeys[j];
						var _anim = _animators[$ _uuid];
						var _keyframes = _anim[$ "keyframes"];
						
						var _channels = {};
						_anim.channel = _channels;
						
						for( var k = 0, p = array_length(_keyframes); k < p; k++ ) {
							var _key = _keyframes[k];
							var _chan = _key[$ "channel"];
							var _datp = _key[$ "data_points"][0];
							
							_datp.x = real(_datp[$ "x"]) ?? 0;
							_datp.y = real(_datp[$ "y"]) ?? 0;
							_datp.z = real(_datp[$ "z"]) ?? 0;
							
							if(!has(_channels, _chan)) _channels[$ _chan] = [];
							array_push(_channels[$ _chan], _key);
						}
						
						var _chanKeys = struct_get_names(_channels);
						for( var k = 0, p = array_length(_chanKeys); k < p; k++ ) 
							array_sort(_channels[$ _chanKeys[k]], function(a,b) /*=>*/ {return sign(a.time - b.time)});
							
					}
				}
			}
			
			if(array_empty(animations)) anim_section[1] = true;
		#endregion
	}
	
	static generateTexture = function() {
		use_texture = !array_empty(material_key);
		if(LOADING || CLONING) return;
		
		var _in = [];
		
		if(use_texture) {
			var renderAgain = false;
			
			for( var i = 0, n = array_length(material_key); i < n; i++ ) {
				var _tname = material_key[i];
				var _tpath = material_map[$ _tname];
				
				if(is_struct(_tpath) && (_tpath[$ "path"] ?? "") != "")
					_tpath = _tpath.path;
				
				var _inp = array_safe_get(inputs, input_fix_len + i, noone);
				if(_inp == noone) _inp = createNewInput();
				_inp.setName(_tname);
				array_push(_in, _inp);
				
				if(_inp.value_from != noone) continue;
				
				if(is_string(_tpath)) {
					var _fpath = filename_combine(_rootPath, _tpath) + ".png";
					if(NOT_LOAD && file_exists_empty(_fpath)) {
						var sol = Node_create_Image_path(x - (w + 32), y + i * (128 + 32), _fpath);
						_inp.setFrom(sol.outputs[0]);
						renderAgain = true;
					}
				} else if(is_struct(_tpath)) {
					var _src = _tpath[$ "source"] ?? "";
					
					if(_src != "") {
						var nod = nodeBuild("Node_Image_Base64", x - (w + 32), y + i * (128 + 32));
				    	nod.skipDefault();
				    	nod.inputs[0].setValue(_src);
				    	
				    	_inp.setFrom(nod.outputs[0]);
					}
				}
			}
			
			if(renderAgain) run_in(1, function() /*=>*/ {return triggerRender()});
			
		} else {
			var _inp = array_safe_get(inputs, input_fix_len, noone);
			if(_inp == noone) _inp = createNewInput();
			array_push(_in, _inp);
		}
		
		array_resize(inputs, input_fix_len);
		for( var i = 0, n = array_length(_in); i < n; i++ ) {
			_in[i].index = input_fix_len + i;
			array_push(inputs, _in[i]);
		}
		
		input_display_list = array_clone(input_display_list_raw, 1);
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ )
			array_push(input_display_list, i);
		
	}
	
	////- Model
	
	static applyAnimation = function(_out, _par = undefined, _visible = true) {
		if(is_string(_out)) {
			var _ele = idMap[$ _out];
			if(_ele) {
				_ele.visible   = _visible;
				_ele.transform = _par? _par.transform : undefined;
			}
			return;
		}
		
		var _uuid = _out.uuid;
		if(!has(idMap, _uuid)) return;
		
		var _grop = idMap[$ _uuid];
		var _orig = _grop[$ "origin"] ?? [0,0,0];
		var _tran = new BBMOD_Matrix()
		var ox, oy, oz;
		
		_grop.visible = _visible && (attributes.element_visible[$ _uuid] ?? true);
		_visible = _visible && _grop.visible;
		
		if(model_axis == 0) {
			ox = _orig[0];
			oy = _orig[1];
			oz = _orig[2];
			
		} else if(model_axis == 1) {
			ox =  _orig[0];
			oy = -_orig[2];
			oz =  _orig[1];
		}
		
		ox *= model_scale;
		oy *= model_scale;
		oz *= model_scale;
		
		_tran = _tran.Translate(-ox,-oy,-oz);
		
		if(has(_grop, "rotation")) {
			var _rota  = _grop.rotation;
			var rx, ry, rz;
			
			if(model_axis == 0) {
				rx = _rota[0];
				ry = _rota[1];
				rz = _rota[2];
				
			} else if(model_axis == 1) {
				rx =  _rota[0];
				ry = -_rota[2];
				rz =  _rota[1];
			}
			
			_tran = _tran.RotateZ(-rz);
			_tran = _tran.RotateY(-ry);
			_tran = _tran.RotateX(-rx);
			
		}
		
		if(has(_grop, "scale")) {
			var _scal = _grop.scale;
			_tran = _tran.Scale(_scal[0], _scal[1], _scal[2]);
		}
		
		_tran = _tran.Translate( ox, oy, oz);
		
		if(has(_grop, "position")) {
			var _posi = _grop.position;
			var px, py, pz;
			
			if(model_axis == 0) {
				px = _posi[0];
				py = _posi[1];
				pz = _posi[2];
				
			} else if(model_axis == 1) {
				px =  _posi[0];
				py = -_posi[2];
				pz =  _posi[1];
			}
			
			px *= model_scale;
			py *= model_scale;
			pz *= model_scale;
		
			_tran = _tran.Translate( px, py, pz);
		}
		
		_grop.transform = _par? _tran.Mul(_par.transform) : _tran;
		
		for( var i = 0, n = array_length(_out.children); i < n; i++ )
			applyAnimation(_out.children[i], _grop, _visible);
	}
	
	////- Node
	
	static step = function() {
		var _path = getInputSingle(in_mesh);
		if(attributes.file_checker && file_get_modify_s(_path) > edit_time) {
			readJson(_path); 
			triggerRender();
		}
	}
	
	static processData_prebatch = function() {
		var _path = getInputSingle(in_mesh);
		if(_path != current_path) readJson(_path);
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		if(object == noone) return;
		
		#region data
			var i = in_mesh;
			
			var _astr = _data[i+8];
			var _aspd = _data[i+7];
			var _loop = _data[i+9];
			var _anim = _data[i+6];
			
			var _flip = _data[i+1];
			var _texd = _data[i+5];
		#endregion
		
		var matAmo  = getInputAmount();
		var baseTex = matAmo > 0? material_map[$ material_key[0]] : noone;
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ )
			material_map[$ inputs[i].name].material = _data[i];
		
		#region animation
			var _animActive = has(idMap, _anim);
			animCurrent = undefined;
			
			update_on_frame = _animActive;
			if(attributes.show_timeline != _animActive) {
				attributes.show_timeline = _animActive;
				refreshTimeline();
			}
				
			if(_animActive) {
				animCurrent = idMap[$ _anim];
				
				var _length    = animCurrent.length;
				var _animators = animCurrent.animators;
				var _animKeys  = struct_get_names(_animators);
				
				var currFrame  = _astr? CURRENT_FRAME / TOTAL_FRAMES * _length * _aspd : 
				                        CURRENT_FRAME / project.animator.framerate * _aspd;
				
				if(_loop) currFrame = safe_mod(currFrame, _length);
				
				////- =Reset
				for( var i = 0, n = array_length(elements); i < n; i++ ) elements[i].transform = undefined;
				for( var i = 0, n = array_length(groups);   i < n; i++ ) {
					var gro = groups[i];
					
					gro.position  = array_clone(gro._position);
					gro.origin    = array_clone(gro._origin);
					gro.rotation  = array_clone(gro._rotation);
					gro.scale     = array_clone(gro._scale);
					gro.transform = undefined;
				}
				
				////- =Set
				for( var i = 0, n = array_length(_animKeys); i < n; i++ ) {
					var _uuid = _animKeys[i];
					if(!has(idMap, _uuid)) continue;
					
					var _obj  = idMap[$ _uuid];
					var _anim = _animators[$ _uuid];
					
					var _channels = _anim.channel;
					var _chanKeys = struct_get_names(_channels);
					
					for( var j = 0, m = array_length(_chanKeys); j < m; j++ ) {
						var _chan = _chanKeys[j];
						var _val  = undefined;
						
						var _keyframes = _channels[$ _chan];
						var _prevFrame = 0;
						var _prevData  = 0;
						
						for( var k = 0, p = array_length(_keyframes); k < p; k++ ) {
							var _key = _keyframes[k];
							
							var _datp = _key[$ "data_points"];
							var _time = _key[$ "time"];
							var _intp = _key[$ "interpolation"];
							
							if(k == 0 && currFrame <= _time) {
								_val = _datp[0];
								break;
								
							} else if(k == p - 1 && currFrame >= _time) {
								_val = _datp[0];
								break;
								
							} else if(currFrame >= _prevFrame && currFrame < _time) {
								var d0 = _prevData[0];
								var d1 = _datp[0];
								
								if(_intp == "catmullrom" || (_prevFrame && _prevFrame[$ "interpolation"] == "catmullrom")) {
									var v0 = _keyframes[max(k-2,0  )];
									var v1 = _keyframes[max(k-1,0  )];
									var v2 = _keyframes[max(k      )];
									var v3 = _keyframes[min(k+1,p-1)];
									_val = interpolate_catmul(v0, v1, v2, v3, currFrame);
									
								} else 
									_val = interpolate_lin(d0, d1, (currFrame - _prevFrame) / (_time - _prevFrame));
								break;
							}
							
							_prevData  = _datp;
							_prevFrame = _time;
						}
						
						if(_val == undefined) continue;
						
						_obj[$ _chan] = [_val.x, _val.y, _val.z];
					}
				}
			}
			
			if(outliner != undefined) {
				for( var i = 0, n = array_length(outliner); i < n; i++ )
					applyAnimation(outliner[i]);
			}
		#endregion
		
		#region elements
			var _materials = [];
			var _matrices  = [];
			var _vertices  = [];
			var _edges     = [];
			var _vbs       = [];
			
			for( var i = 0, n = array_length(elements); i < n; i++ ) {
				var _ele  = elements[i];
				var _uuid = _ele[$ "uuid"] ?? "";
				var _vis  = _ele.visible && (attributes.element_visible[$ _uuid] ?? true);
				
				_ele.visible = true;
				if(!_vis) continue;
				
				var _trans = _ele.transform;
				
				if(_trans == undefined) {
					for( var j = 0, m = array_length(_ele.matrix); j < m; j++ )
						array_push( _matrices, _ele.matrix[j]);
						
				} else {
					for( var j = 0, m = array_length(_ele.matrix); j < m; j++ )
						array_push( _matrices, matrix_multiply(_ele.matrix[j], _trans.Raw));
				}
				
				if(matAmo > 1) array_append( _materials, _ele.material );
				array_append( _vertices,  _ele.vertex   );
				array_append( _edges,     _ele.edges    );
				array_append( _vbs,       _ele.VB       );
			}
			
			object.object_counts = array_length(_vertices);
			object.vertex = _vertices;
			object.edges  = _edges;
			object.VBM    = _matrices;
			object.VB     = _vbs;
		#endregion
		
		#region material
			var materials = [];
			
			if(matAmo == 1) {
				var _matData = baseTex;
				if(_matData != noone) {
					var _mat = _matData[$ "material"] ?? noone;
					
					if(!is(_mat, __d3dMaterial)) 
						_mat = new __d3dMaterial(_mat);
						
					_matData[$ "material"] = _mat;
					_mat.texScale = [1,1];
					
					if(_texd) {
						var sw = _matData[$ "uv_width"]  ?? 1;
						var sh = _matData[$ "uv_height"] ?? 1;
						_mat.texScale = [1/sw, 1/sh];
					}
					materials = [_mat];
				}
				
			} else for( var i = 0, n = array_length(_materials); i < n; i++ ) {
				var _mat = baseTex;
				
				if(use_texture) {
					var _matData = material_map[$ _materials[i]] ?? noone;
					if(_matData == noone) {
						materials[i] = noone;
						continue;
					}
					
					var _mat = _matData[$ "material"] ?? noone;
					
					if(!is(_mat, __d3dMaterial))
						_mat = new __d3dMaterial(_mat);
					
					_matData[$ "material"] = _mat;
					_mat.texScale = [1,1];
					
					if(_texd) {
						var sw = _matData[$ "uv_width"]  ?? 1;
						var sh = _matData[$ "uv_height"] ?? 1;
						_mat.texScale = [1/sw, 1/sh];
						
					}
				}
				
				materials[i] = _mat;
			}
		#endregion
		
		object.materials	= materials;
		object.texture_flip = _flip;
		setTransform(object, _data);
		
		return object;
	}
	
	////- Draw
	
	static onDrawNodeOver = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		
	}
	
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function timelineItemNode_3D_Json(_node) : timelineItemNode(_node) constructor {
	static drawDopesheetOver = function(_x, _y, _s, _msx, _msy, _hover, _focus) {
		if(!is(node, Node_3D_Mesh_Json))   return;
		if(!node.attributes.show_timeline) return;
		if(node.animCurrent == undefined)  return;
		
		var i = node.in_mesh;
		var _astr = node.getInputData(i+8);
		var _aspd = node.getInputData(i+7);
		var _anim = node.getInputData(i+6);
		
		var _animCurr  = node.animCurrent;
		var _length    = _animCurr.length;
		var _animators = _animCurr.animators;
		var _animKeys  = struct_get_names(_animators);
				
		var _keyScale  = _astr? (node.project.animator.frames_total / node.project.animator.framerate) / _length : 1;
		    _keyScale /= _aspd;
		    _keyScale *= node.project.animator.framerate;
		
		lh = ui(10);
		
    	var _h  = ui(10);
		var _yc = _y + ui(10);
		var ky  = _yc;
    	
		for( var i = 0, n = array_length(_animKeys); i < n; i++ ) {
			var _uuid = _animKeys[i];
			if(!has(node.idMap, _uuid)) continue;
			
			var _obj  = node.idMap[$ _uuid];
			var _anim = _animators[$ _uuid];
			
			var _channels = _anim.channel;
			var _chanKeys = struct_get_names(_channels);
			
			for( var j = 0, m = array_length(_chanKeys); j < m; j++ ) {
				var _chan = _chanKeys[j];
				var _val  = undefined;
				
				var _keyframes = _channels[$ _chan];
				
				for( var k = 0, p = array_length(_keyframes); k < p; k++ ) {
					var _key = _keyframes[k];
					
					var _datp = _key[$ "data_points"];
					var _time = _key[$ "time"] ;
					var _intp = _key[$ "interpolation"];
					
					_time *= _keyScale;
					
					var kx = _x + _time * _s;
					
					draw_sprite_uniform(THEME.timeline_keyframe, 0, kx, ky, .35, COLORS._main_icon, 1);
				}
				
				if(show) {
					_h += lh;
					ky += lh;
				}
			}
		}
		
		h  = max(_h + ui(10), ui(20));
		return true;
	}
}