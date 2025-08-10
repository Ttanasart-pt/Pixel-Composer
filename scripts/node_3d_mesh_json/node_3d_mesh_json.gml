function Node_create_3D_Json(_x, _y, _group = noone) {
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename_compat("3d Json|*.json", "");
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
	newInput(i+0, nodeValue_Path(        "File Path" )).setDisplay(VALUE_DISPLAY.path_load, { filter: "Json object|*.json" });
	newInput(i+2, nodeValue_Float(       "Import Scale", 1/16 ));
	newInput(i+3, nodeValue_Enum_Scroll( "Axis",         1, [ "Z up", "Y up" ]));
	
	////- =Material
	newInput(i+1, nodeValue_Bool( "Flip UV", false, "Flip UV axis, can be use to fix some texture mapping error."));
	// input i+5
		
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform, 
		["Object",	 false], i+0, i+2, i+3,  
		["Material", false], i+1, 
	]
	
	array_foreach(inputs, function(i) /*=>*/ {return i.rejectArray()}, in_mesh);
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		newInput(index, nodeValue_D3Material("Material", new __d3dMaterial())).setVisible(true, true);
		
		array_push(input_display_list, inAmo);
		return inputs[index];
	}
	
	setDynamicInput(1, false);
	
	////- Nodes
	
	current_path = "";
	object       = noone;
	material_map = {};
	material_arr = [];
	use_texture  = false;
	
	model_scale  = 1;
	model_axis   = 0;
	model_bbox   = [ 0, 0, 0, 0, 0, 0 ];
	
	tex_width  = 1;
	tex_height = 1;
	
	invertMatrix = noone;
	
	setTrigger(1, __txt("Refresh"), [ THEME.refresh_icon, 1, COLORS._main_value_positive ], function() /*=>*/ { 
		current_path = ""; 
		outputs[0].setValue(noone);
		triggerRender();
	});
	
	edit_time = 0;
	attributes.file_checker = true;
	array_push(attributeEditors, [ "File Watcher", function() /*=>*/ {return attributes.file_checker}, new checkBox(function() /*=>*/ {return toggleAttribute("file_checker")}) ]);
	
	function setPath(path) { inputs[in_mesh + 0].setValue(path); }
	
	////- Update
	
	static readElement = function(_edges, _vertices, _matrices, _element, _mat) {
		var _rx = struct_try_get(_element, "rotationX", 0);
		var _ry = struct_try_get(_element, "rotationY", 0);
		var _rz = struct_try_get(_element, "rotationZ", 0);
		var _ro = struct_try_get(_element, "rotationOrigin", [0, 0, 0]);
		
		var _face = _element.faces; 
		var _tMat = new BBMOD_Matrix().Translate(-_ro[0], -_ro[1], -_ro[2])
								      .Translate(_element.from[0], _element.from[1], _element.from[2])
								      .RotateZ(-_rz)
								      .RotateY(-_ry)
								      .RotateX(-_rx)
								      .Translate(_ro[0], _ro[1], _ro[2])
		
		var _cMat = _tMat.Mul(_mat);
		var _tArr = _cMat.Mul(invertMatrix).ToArray();
		
		var fx = 0;
		var fy = 0;
		var fz = 0;
		var tx = _element.to[0] - _element.from[0];
		var ty = _element.to[1] - _element.from[1];
		var tz = _element.to[2] - _element.from[2];
		
		if(has(_face, "up") && struct_try_get(_face.up, "enabled", true)) {
			var _f  = _face.up;
			var fu = _f.uv[0] / tex_width;
			var fv = _f.uv[1] / tex_height;
			var tu = _f.uv[2] / tex_width;
			var tv = _f.uv[3] / tex_height;
			
			array_push(material_arr, string_trim(_f.texture, ["#"]));
			array_push(_matrices,    _tArr);
			array_push(_vertices, [ // -y
				__vertexA( [ fx, ty, fz ] ).setNormal( 0, 1, 0 ).setUV(fu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 0, 1, 0 ).setUV(tu, tv),
				__vertexA( [ fx, ty, tz ] ).setNormal( 0, 1, 0 ).setUV(fu, tv),
				
				__vertexA( [ tx, ty, fz ] ).setNormal( 0, 1, 0 ).setUV(tu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 0, 1, 0 ).setUV(tu, tv),
				__vertexA( [ fx, ty, fz ] ).setNormal( 0, 1, 0 ).setUV(fu, fv),
			]);
			
			array_push(_edges, [ new __3dObject_Edge([fx, ty, fz], [fx, ty, tz]), 
			                     new __3dObject_Edge([fx, ty, tz], [tx, ty, tz]), 
			                     new __3dObject_Edge([tx, ty, tz], [tx, ty, fz]), 
			                     new __3dObject_Edge([tx, ty, fz], [fx, ty, fz]) ]); 
		}
		
		if(has(_face, "down") && struct_try_get(_face.down, "enabled", true)) {
			var _f = _face.down;
			var fu = _f.uv[0] / tex_width;
			var fv = _f.uv[1] / tex_height;
			var tu = _f.uv[2] / tex_width;
			var tv = _f.uv[3] / tex_height;
			
			array_push(material_arr, string_trim(_f.texture, ["#"]));
			array_push(_matrices,    _tArr);
			array_push(_vertices, [ // +y
				__vertexA( [ fx, fy, fz ] ).setNormal( 0,-1, 0 ).setUV(fu, fv),
				__vertexA( [ fx, fy, tz ] ).setNormal( 0,-1, 0 ).setUV(fu, tv),
				__vertexA( [ tx, fy, tz ] ).setNormal( 0,-1, 0 ).setUV(tu, tv),
				
				__vertexA( [ tx, fy, fz ] ).setNormal( 0,-1, 0 ).setUV(tu, fv),
				__vertexA( [ fx, fy, fz ] ).setNormal( 0,-1, 0 ).setUV(fu, fv),
				__vertexA( [ tx, fy, tz ] ).setNormal( 0,-1, 0 ).setUV(tu, tv),
			]);
			
			array_push(_edges, [ new __3dObject_Edge([fx, fy, fz], [fx, fy, tz]),
			                     new __3dObject_Edge([fx, fy, tz], [tx, fy, tz]),
			                     new __3dObject_Edge([tx, fy, tz], [tx, fy, fz]),
			                     new __3dObject_Edge([tx, fy, fz], [fx, fy, fz]) ]);
		}
		
		if(has(_face, "east") && struct_try_get(_face.east, "enabled", true)) {
			var _f = _face.east;
			var fu = _f.uv[0] / tex_width;
			var fv = _f.uv[1] / tex_height;
			var tu = _f.uv[2] / tex_width;
			var tv = _f.uv[3] / tex_height;
			
			array_push(material_arr, string_trim(_f.texture, ["#"]));
			array_push(_matrices,    _tArr);
			array_push(_vertices, [ // +x
				__vertexA( [ tx, fy, fz ] ).setNormal( 1, 0, 0 ).setUV(tu, fv),
				__vertexA( [ tx, fy, tz ] ).setNormal( 1, 0, 0 ).setUV(fu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 1, 0, 0 ).setUV(fu, tv),
				
				__vertexA( [ tx, ty, fz ] ).setNormal( 1, 0, 0 ).setUV(tu, tv),
				__vertexA( [ tx, fy, fz ] ).setNormal( 1, 0, 0 ).setUV(tu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 1, 0, 0 ).setUV(fu, tv),
			]);
			
			array_push(_edges, [ new __3dObject_Edge([tx, fy, fz], [tx, fy, tz]), 
			                     new __3dObject_Edge([tx, fy, tz], [tx, ty, tz]), 
			                     new __3dObject_Edge([tx, ty, tz], [tx, ty, fz]), 
			                     new __3dObject_Edge([tx, ty, fz], [tx, fy, fz]) ]);
		}
		
		if(has(_face, "west") && struct_try_get(_face.west, "enabled", true)) {
			var _f = _face.west;
			var fu = _f.uv[0] / tex_width;
			var fv = _f.uv[1] / tex_height;
			var tu = _f.uv[2] / tex_width;
			var tv = _f.uv[3] / tex_height;
			
			array_push(material_arr, string_trim(_f.texture, ["#"]));
			array_push(_matrices,    _tArr);
			array_push(_vertices, [ // -x
				__vertexA( [ fx, fy, fz ] ).setNormal(-1, 0, 0 ).setUV(fu, fv),
				__vertexA( [ fx, ty, tz ] ).setNormal(-1, 0, 0 ).setUV(tu, tv),
				__vertexA( [ fx, fy, tz ] ).setNormal(-1, 0, 0 ).setUV(tu, fv),
				
				__vertexA( [ fx, ty, fz ] ).setNormal(-1, 0, 0 ).setUV(fu, tv),
				__vertexA( [ fx, ty, tz ] ).setNormal(-1, 0, 0 ).setUV(tu, tv),
				__vertexA( [ fx, fy, fz ] ).setNormal(-1, 0, 0 ).setUV(fu, fv),
			]);
			
			array_push(_edges, [ new __3dObject_Edge([fx, fy, fz], [fx, fy, tz]), 
			                     new __3dObject_Edge([fx, fy, tz], [fx, ty, tz]), 
			                     new __3dObject_Edge([fx, ty, tz], [fx, ty, fz]), 
			                     new __3dObject_Edge([fx, ty, fz], [fx, fy, fz]) ]);
		}
		
		if(has(_face, "north") && struct_try_get(_face.north, "enabled", true)) {
			var _f = _face.north;
			var fu = 1 - _f.uv[0] / tex_width;
			var fv =     _f.uv[1] / tex_height;
			var tu = 1 - _f.uv[2] / tex_width;
			var tv =     _f.uv[3] / tex_height;
			
			array_push(material_arr, string_trim(_f.texture, ["#"]));
			array_push(_matrices,    _tArr);
			array_push(_vertices, [ // -z
				__vertexA( [ fx, fy, fz ] ).setNormal( 0, 0,-1 ).setUV(fu, fv),
				__vertexA( [ tx, ty, fz ] ).setNormal( 0, 0,-1 ).setUV(tu, tv),
				__vertexA( [ fx, ty, fz ] ).setNormal( 0, 0,-1 ).setUV(fu, tv),
				
				__vertexA( [ tx, fy, fz ] ).setNormal( 0, 0,-1 ).setUV(tu, fv),
				__vertexA( [ tx, ty, fz ] ).setNormal( 0, 0,-1 ).setUV(tu, tv),
				__vertexA( [ fx, fy, fz ] ).setNormal( 0, 0,-1 ).setUV(fu, fv),
			]);
			
			array_push(_edges, [ new __3dObject_Edge([fx, fy, fz], [fx, ty, fz]), 
			                     new __3dObject_Edge([fx, ty, fz], [tx, ty, fz]), 
			                     new __3dObject_Edge([tx, ty, fz], [tx, fy, fz]), 
			                     new __3dObject_Edge([tx, fy, fz], [fx, fy, fz]) ]);
			
		}
		
		if(has(_face, "south") && struct_try_get(_face.south, "enabled", true)) {
			var _f = _face.south;
			var fu = _f.uv[0] / tex_width;
			var fv = _f.uv[1] / tex_height;
			var tu = _f.uv[2] / tex_width;
			var tv = _f.uv[3] / tex_height;
			
			array_push(material_arr, string_trim(_f.texture, ["#"]));
			array_push(_matrices,    _tArr);
			
			array_push(_vertices, [ // +z
				__vertexA( [ fx, fy, tz ] ).setNormal( 0, 0, 1 ).setUV(fu, fv),
				__vertexA( [ fx, ty, tz ] ).setNormal( 0, 0, 1 ).setUV(fu, tv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 0, 0, 1 ).setUV(tu, tv),
				
				__vertexA( [ tx, fy, tz ] ).setNormal( 0, 0, 1 ).setUV(tu, fv),
				__vertexA( [ fx, fy, tz ] ).setNormal( 0, 0, 1 ).setUV(fu, fv),
				__vertexA( [ tx, ty, tz ] ).setNormal( 0, 0, 1 ).setUV(tu, tv),
			]);
			
			array_push(_edges, [ new __3dObject_Edge([fx, fy, tz], [fx, ty, tz]), 
			                     new __3dObject_Edge([fx, ty, tz], [tx, ty, tz]), 
			                     new __3dObject_Edge([tx, ty, tz], [tx, fy, tz]), 
			                     new __3dObject_Edge([tx, fy, tz], [fx, fy, tz]) ]);
		}
		
		if(has(_element, "children"))
		for( var i = 0, n = array_length(_element.children); i < n; i++ )
			readElement(_edges, _vertices, _matrices, _element.children[i], _cMat);
	}
	
	static readJson = function(_path) {
		if(!file_exists_empty(_path)) return;
		current_path = _path;
		edit_time    = file_get_modify_s(_path);
		
		if(object != noone) object.destroy();
		object = noone;
		
		var _data = json_load_struct(_path);
		if(!has(_data, "elements")) return;
		
		model_scale   = getSingleValue(in_mesh + 2);
		model_axis    = getSingleValue(in_mesh + 3);
		var _rootPath = project.getVar("json_asset_dir");
		
		material_map  = has(_data, "textures")? _data.textures : (has(_data, "texture")? _data.texture : {});
		tex_width     = struct_try_get(_data, "textureWidth", 16);
		tex_height    = struct_try_get(_data, "textureHeight", 16);
		
		var _elements = _data.elements;
		var _vertices = [];
		var _edges    = [];
		var _matrices = [];
		material_arr  = [];
		model_bbox    = [ infinity, infinity, infinity, -infinity, -infinity, -infinity ];
		
		var _rMat = [
			1, 0, 0, 0, 
			0, 1, 0, 0, 
			0, 0, 1, 0, 
			0, 0, 0, 1
		];
		
		if(model_axis == 1) {
			_rMat = [
				1, 0, 0, 0, 
				0, 0, 1, 0, 
				0,-1, 0, 0, 
				0, 0, 0, 1
			];
		}
		
		invertMatrix = new BBMOD_Matrix(_rMat).Scale(model_scale, model_scale, model_scale);
		
		for( var i = 0, n = array_length(_elements); i < n; i++ ) {
			var _element = _elements[i];
			var _mat = new BBMOD_Matrix();
			
			readElement(_edges, _vertices, _matrices, _element, _mat);
		}
		
		object = new __3dObject();
		object.object_counts = array_length(_vertices);
		object.vertex = _vertices;
		object.edges  = _edges;
		object.VF     = global.VF_POS_NORM_TEX_COL;
		object.VB     = object.build();
		object.VBM    = _matrices;
		
		var _textureKeys = struct_get_names(material_map);
		use_texture = !array_empty(_textureKeys);
		var _in = [];
		
		if(use_texture) {
			var renderAgain = false;
			
			for( var i = 0, n = array_length(_textureKeys); i < n; i++ ) {
				var _tname = _textureKeys[i];
				var _tpath = material_map[$ _tname];
				
				var _inp = array_safe_get(inputs, input_fix_len + i, noone);
				if(_inp == noone) _inp = createNewInput();
				
				_inp.setName(_tname);
				array_push(_in, _inp);
				
				if(_inp.value_from == noone) {
					var _fpath = filename_combine(_rootPath, _tpath) + ".png";
					if(NOT_LOAD && file_exists_empty(_fpath)) {
						var sol = Node_create_Image_path(x - (w + 128), y + i * (128 + 32), _fpath);
						_inp.setFrom(sol.outputs[0]);
						renderAgain = true;
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
	
	static step = function() {
		var _path = getSingleValue(in_mesh);
		if(attributes.file_checker && file_get_modify_s(_path) > edit_time) {
			readJson(_path); 
			triggerRender();
		}
	}
	
	static processData_prebatch = function() {
		var _path = getSingleValue(in_mesh);
		if(_path != current_path) readJson(_path);
	}
	
	static processData = function(_output, _data, _array_index = 0) {
		if(object == noone) return object;
		
		var _flip = _data[ in_mesh + 1 ];
		
		var materialMap = {};
		var baseTex = noone;
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			var _key = inputs[i].name;
			materialMap[$ _key] = _data[i];
			if(i == input_fix_len) baseTex = _data[i];
		}
		
		var materials = [];
		for( var i = 0, n = array_length(material_arr); i < n; i++ )
			materials[i] = use_texture? struct_try_get(materialMap, material_arr[i], noone) : baseTex;
		
		object.materials	= materials;
		object.texture_flip = _flip;
		setTransform(object, _data);
		
		return object;
	}
	
	static getPreviewValues = function() { return getSingleValue(in_mesh + 3); }
	
	static onDrawNodeOver = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		
	}
}