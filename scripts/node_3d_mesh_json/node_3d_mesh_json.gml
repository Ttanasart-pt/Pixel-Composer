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
	
	var i = in_mesh;
	
	////- =Transform
	newInput(i+4, nodeValue_Bool( "Reset Origin", true ));
	
	////- =Object
	newInput(i+0, nodeValue_FPath(   "File Path" )).setDisplay(VALUE_DISPLAY.path_load, { filter: "Json Object (.json)|*.json" });
	newInput(i+2, nodeValue_Float(   "Import Scale", 1/16 ));
	newInput(i+3, nodeValue_EScroll( "Axis",         1, [ "Z up", "Y up" ]));
	
	////- =Material
	newInput(i+1, nodeValue_Bool( "Flip UV", false, "Flip UV axis, can be use to fix some texture mapping error."));
	newInput(i+5, nodeValue_Bool( "Use Texture Dimension", true ));
	// input i+6
		
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
		
		if(_typ == "") return hh;
		
		var tx = _x + ui(12);
		var yc = _y + hg / 2;
		
		if(!isGroup) {
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
			
		} else {
			var _opn = _ele[$ "isOpen"] ?? true;
			var vhover = _hover && point_in_circle(_m[0], _m[1], tx + bs / 2, yc, bs / 2);
			
			draw_sprite_ui_uniform(THEME.folder_content, _opn, tx + bs / 2, yc, .5, vhover? COLORS._main_icon_light : COLORS._main_icon);
			if(vhover) {
				if(mouse_lpress(_focus))
					_ele[$ "isOpen"] = !_opn;
			}
			
		}
		tx += bs;
		
		if(!isGroup) {
			draw_sprite_ui_uniform(THEME.addon_icon, 0, tx + bs / 2, yc, .6, COLORS._main_icon, .5);
			tx += bs;
		}
		
		tx += ui(4);
		draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
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
	
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform, 
		[ "Elements", false ], element_renderer,
		[ "Object",   false ], i+0, i+2, i+3,  
		[ "Material", false ], i+1, i+5, 
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
	
	idMap        = {};
	
	current_path = "";
	object       = noone;
	material_map = {};
	material_key = [];
	use_texture  = false;
	
	elements     = [];
	groups       = [];
	
	model_scale  = 1;
	model_axis   = 0;
	model_bbox   = [ 0, 0, 0, 0, 0, 0 ];
	
	tex_width    = 1;
	tex_height   = 1;
	
	outliner     = undefined;
	
	invertMatrix = noone;
	
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
	
	////- Update
	
	__edgeA = __3dObject_Edge;
	
	static readElement = function(_element, _matrix) {
		array_push(elements, _element);
		
		var _rx = _element[$ "rotationX"]      ??  0;
		var _ry = _element[$ "rotationY"]      ??  0;
		var _rz = _element[$ "rotationZ"]      ??  0;
		var _ro = _element[$ "rotationOrigin"] ?? [0,0,0];
		
		var _face = _element.faces; 
		var _tMat = new BBMOD_Matrix().Translate(-_ro[0], -_ro[1], -_ro[2]);
		
		if(has(_element, "from"))
			_tMat = _tMat.Translate(_element.from[0], _element.from[1], _element.from[2]);
			
		_tMat = _tMat.RotateZ(-_rz);
		_tMat = _tMat.RotateY(-_ry);
		_tMat = _tMat.RotateX(-_rx);
		_tMat = _tMat.Translate(_ro[0], _ro[1], _ro[2]);
		
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
		var _mtx = [];
		var _vrt = [];
		var _edg = [];
		var _vbs = [];
		
		_element.type     = "element";
		_element.material = _mat;
		_element.matrix   = _mtx;
		_element.vertex   = _vrt;
		_element.edges    = _edg;
		_element.VB       = _vbs;
		
		var _uuid = _element.uuid;
		if(!has(attributes.element_visible, _uuid))
			attributes.element_visible[$ _uuid] = true;
		idMap[$ _uuid] = _element;
		
		if(has(_face, "up") && (_face.up[$ "enabled"] ?? true)) {
			var _f  = _face.up;
			var fu = _f.uv[0], fv = _f.uv[3];
			var tu = _f.uv[2], tv = _f.uv[1];
			
			array_push(_mat, string_trim(_f[$ "texture"] ?? "", ["#"]));
			array_push(_mtx, _tArr);
			
			var _v = [ // -y
				__vertexA( [ fx, ty, fz ] ).setNormal( 0, 1, 0 ).setUV(fu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 0, 1, 0 ).setUV(tu, tv),
				__vertexA( [ fx, ty, tz ] ).setNormal( 0, 1, 0 ).setUV(fu, tv),
				
				__vertexA( [ tx, ty, fz ] ).setNormal( 0, 1, 0 ).setUV(tu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 0, 1, 0 ).setUV(tu, tv),
				__vertexA( [ fx, ty, fz ] ).setNormal( 0, 1, 0 ).setUV(fu, fv),
			];
			
			array_push(_vrt, _v);
			array_push(_edg, [ new __edgeA([fx, ty, fz], [fx, ty, tz]), new __edgeA([fx, ty, tz], [tx, ty, tz]), 
			                   new __edgeA([tx, ty, tz], [tx, ty, fz]), new __edgeA([tx, ty, fz], [fx, ty, fz]) ]); 
			                     
			array_push(_vbs, object.buildVertex(_v));
		}
		
		if(has(_face, "down") && (_face.down[$ "enabled"] ?? true)) {
			var _f = _face.down;
			var fu = _f.uv[0], fv = _f.uv[3];
			var tu = _f.uv[2], tv = _f.uv[1];
			
			array_push(_mat, string_trim(_f[$ "texture"] ?? "", ["#"]));
			array_push(_mtx, _tArr);
			
			var _v = [ // +y
				__vertexA( [ fx, fy, fz ] ).setNormal( 0,-1, 0 ).setUV(fu, fv),
				__vertexA( [ fx, fy, tz ] ).setNormal( 0,-1, 0 ).setUV(fu, tv),
				__vertexA( [ tx, fy, tz ] ).setNormal( 0,-1, 0 ).setUV(tu, tv),
				
				__vertexA( [ tx, fy, fz ] ).setNormal( 0,-1, 0 ).setUV(tu, fv),
				__vertexA( [ fx, fy, fz ] ).setNormal( 0,-1, 0 ).setUV(fu, fv),
				__vertexA( [ tx, fy, tz ] ).setNormal( 0,-1, 0 ).setUV(tu, tv),
			];
			
			array_push(_vrt, _v);
			array_push(_edg, [ new __edgeA([fx, fy, fz], [fx, fy, tz]), new __edgeA([fx, fy, tz], [tx, fy, tz]),
			                   new __edgeA([tx, fy, tz], [tx, fy, fz]), new __edgeA([tx, fy, fz], [fx, fy, fz]) ]);
			                     
			array_push(_vbs, object.buildVertex(_v));
		}
		
		if(has(_face, "east") && (_face.east[$ "enabled"] ?? true)) {
			var _f = _face.east;
			var fu = _f.uv[0], fv = _f.uv[3];
			var tu = _f.uv[2], tv = _f.uv[1];
			
			array_push(_mat, string_trim(_f[$ "texture"] ?? "", ["#"]));
			array_push(_mtx, _tArr);
			
			var _v = [ // +x
				__vertexA( [ tx, fy, fz ] ).setNormal( 1, 0, 0 ).setUV(tu, fv),
				__vertexA( [ tx, fy, tz ] ).setNormal( 1, 0, 0 ).setUV(fu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 1, 0, 0 ).setUV(fu, tv),
				
				__vertexA( [ tx, ty, fz ] ).setNormal( 1, 0, 0 ).setUV(tu, tv),
				__vertexA( [ tx, fy, fz ] ).setNormal( 1, 0, 0 ).setUV(tu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 1, 0, 0 ).setUV(fu, tv),
			];
			
			array_push(_vrt, _v);
			array_push(_edg, [ new __edgeA([tx, fy, fz], [tx, fy, tz]), new __edgeA([tx, fy, tz], [tx, ty, tz]), 
			                   new __edgeA([tx, ty, tz], [tx, ty, fz]), new __edgeA([tx, ty, fz], [tx, fy, fz]) ]);
			                     
			array_push(_vbs, object.buildVertex(_v));
		}
		
		if(has(_face, "west") && (_face.west[$ "enabled"] ?? true)) {
			var _f = _face.west;
			var fu = _f.uv[0], fv = _f.uv[3];
			var tu = _f.uv[2], tv = _f.uv[1];
			
			array_push(_mat, string_trim(_f[$ "texture"] ?? "", ["#"]));
			array_push(_mtx, _tArr);
			
			var _v = [ // -x
				__vertexA( [ fx, fy, fz ] ).setNormal(-1, 0, 0 ).setUV(fu, fv),
				__vertexA( [ fx, ty, tz ] ).setNormal(-1, 0, 0 ).setUV(tu, tv),
				__vertexA( [ fx, fy, tz ] ).setNormal(-1, 0, 0 ).setUV(tu, fv),
				
				__vertexA( [ fx, ty, fz ] ).setNormal(-1, 0, 0 ).setUV(fu, tv),
				__vertexA( [ fx, ty, tz ] ).setNormal(-1, 0, 0 ).setUV(tu, tv),
				__vertexA( [ fx, fy, fz ] ).setNormal(-1, 0, 0 ).setUV(fu, fv),
			];
			
			array_push(_vrt, _v);
			array_push(_edg, [ new __edgeA([fx, fy, fz], [fx, fy, tz]), new __edgeA([fx, fy, tz], [fx, ty, tz]), 
			                   new __edgeA([fx, ty, tz], [fx, ty, fz]), new __edgeA([fx, ty, fz], [fx, fy, fz]) ]);
			                     
			array_push(_vbs, object.buildVertex(_v));
		}
		
		if(has(_face, "north") && (_face.north[$ "enabled"] ?? true)) {
			var _f = _face.north;
			var fu = _f.uv[0], fv = _f.uv[3];
			var tu = _f.uv[2], tv = _f.uv[1];
			
			array_push(_mat, string_trim(_f[$ "texture"] ?? "", ["#"]));
			array_push(_mtx, _tArr);
			
			var _v = [ // -z
				__vertexA( [ fx, fy, fz ] ).setNormal( 0, 0,-1 ).setUV(fu, fv),
				__vertexA( [ tx, ty, fz ] ).setNormal( 0, 0,-1 ).setUV(tu, tv),
				__vertexA( [ fx, ty, fz ] ).setNormal( 0, 0,-1 ).setUV(fu, tv),
				
				__vertexA( [ tx, fy, fz ] ).setNormal( 0, 0,-1 ).setUV(tu, fv),
				__vertexA( [ tx, ty, fz ] ).setNormal( 0, 0,-1 ).setUV(tu, tv),
				__vertexA( [ fx, fy, fz ] ).setNormal( 0, 0,-1 ).setUV(fu, fv),
			];
			
			array_push(_vrt, _v);
			array_push(_edg, [ new __edgeA([fx, fy, fz], [fx, ty, fz]), new __edgeA([fx, ty, fz], [tx, ty, fz]), 
			                   new __edgeA([tx, ty, fz], [tx, fy, fz]), new __edgeA([tx, fy, fz], [fx, fy, fz]) ]);
			                     
			array_push(_vbs, object.buildVertex(_v));
			
		}
		
		if(has(_face, "south") && (_face.south[$ "enabled"] ?? true)) {
			var _f = _face.south;
			var fu = _f.uv[0], fv = _f.uv[3];
			var tu = _f.uv[2], tv = _f.uv[1];
			
			array_push(_mat, string_trim(_f[$ "texture"] ?? "", ["#"]));
			array_push(_mtx, _tArr);
			
			var _v = [ // +z
				__vertexA( [ fx, fy, tz ] ).setNormal( 0, 0, 1 ).setUV(fu, fv),
				__vertexA( [ fx, ty, tz ] ).setNormal( 0, 0, 1 ).setUV(fu, tv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 0, 0, 1 ).setUV(tu, tv),
				
				__vertexA( [ tx, fy, tz ] ).setNormal( 0, 0, 1 ).setUV(tu, fv),
				__vertexA( [ fx, fy, tz ] ).setNormal( 0, 0, 1 ).setUV(fu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 0, 0, 1 ).setUV(tu, tv),
			];
			
			array_push(_vrt, _v);
			array_push(_edg, [ new __edgeA([fx, fy, tz], [fx, ty, tz]), new __edgeA([fx, ty, tz], [tx, ty, tz]), 
			                   new __edgeA([tx, ty, tz], [tx, fy, tz]), new __edgeA([tx, fy, tz], [fx, fy, tz]) ]);
			                     
			array_push(_vbs, object.buildVertex(_v));
		}
		
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
		
		if(object != noone) object.destroy();
		object    = new __3dObject();
		object.VF = global.VF_POS_NORM_TEX_COL;
		
		var _data = json_load_struct(_path);
		if(!has(_data, "elements")) return;
		
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
					_group.type = "group";
					
					array_push(groups, _group);
					idMap[$ _group.uuid] = _group;
				}
			}
		#endregion
		
		#region material
			readMaterial(_data);
			generateTexture();
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
			var _flip = _data[i+1];
			var _texd = _data[i+5];
		#endregion
		
		var materialMap = {};
		var baseTex     = noone;
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			var _key = inputs[i].name;
			materialMap[$ _key] = _data[i];
			if(i == input_fix_len) baseTex = _data[i];
		}
		
		#region elements
			var _materials = [];
			var _matrices  = [];
			var _vertices  = [];
			var _edges     = [];
			var _vbs       = [];
			
			for( var i = 0, n = array_length(elements); i < n; i++ ) {
				var _ele  = elements[i];
				var _uuid = _ele[$ "uuid"] ?? "";
				var _vis  = attributes.element_visible[$ _uuid] ?? true;
				if(!_vis) continue;
				
				array_append( _materials, _ele.material );
				array_append( _matrices,  _ele.matrix   );
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
		
		var materials = [];
		for( var i = 0, n = array_length(_materials); i < n; i++ ) {
			var _mat = baseTex;
			
			if(use_texture) {
				var _mat = materialMap[$ _materials[i]] ?? noone;
				
				if(!is(_mat, __d3dMaterial)) {
					_mat = new __d3dMaterial(_mat);
					
					if(_texd) {
						var _dim = surface_get_dimension(_mat);
						_mat.texScale = [1/_dim[0], 1/_dim[1]];
					}
					
				} else if(_texd) {
					var _dim = surface_get_dimension(_mat.surface);
					_mat.texScale = [1/_dim[0], 1/_dim[1]];
				}
				
			}
			
			materials[i] = _mat;
		}
		
		object.materials	= materials;
		object.texture_flip = _flip;
		setTransform(object, _data);
		
		return object;
	}
	
	////- Draw
	
	static onDrawNodeOver = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		
	}
}