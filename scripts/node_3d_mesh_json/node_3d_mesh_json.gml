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
	
	////- =Transform
	newInput(in_mesh + 4, nodeValue_Vec3( "Origin Offset", [0,0,0] ));
	
	////- =Object
	newInput(in_mesh + 0, nodeValue_Path(        "File Path" )).setDisplay(VALUE_DISPLAY.path_load, { filter: "Json object|*.json" });
	newInput(in_mesh + 2, nodeValue_Float(       "Import Scale", 1/16 ));
	newInput(in_mesh + 3, nodeValue_Enum_Scroll( "Axis",         0, [ "Z up", "Y up" ]));
	
	////- =Material
	newInput(in_mesh + 1, nodeValue_Bool( "Flip UV", true, "Flip UV axis, can be use to fix some texture mapping error."));
		
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform, in_mesh + 4, 
		["Object",	 false], in_mesh + 0, in_mesh + 2, in_mesh + 3,  
		["Material", false], in_mesh + 1, 
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
	model_offset = [ 0, 0, 0 ];
	
	tex_width  = 1;
	tex_height = 1;
	
	setTrigger(1, __txt("Refresh"), [ THEME.refresh_icon, 1, COLORS._main_value_positive ], function() /*=>*/ { 
		current_path = ""; 
		outputs[0].setValue(noone);
		triggerRender();
	});
	
	function setPath(path) { inputs[in_mesh + 0].setValue(path); }
	
	////- Update
	
	static readElement = function(_vertices, _element, _x = 0, _y = 0, _z = 0) {
		var _fx = _x + _element.from[0], fx;
		var _fy = _y + _element.from[1], fy;
		var _fz = _z + _element.from[2], fz;
		var _tx = _x + _element.to[0],   tx;
		var _ty = _y + _element.to[1],   ty;
		var _tz = _z + _element.to[2],   tz;
		var _s  = model_scale;
		
		switch(model_axis) {
			case 0 : 
				fx = _fx * _s; tx = _tx * _s;
				fy = _fy * _s; ty = _ty * _s;
				fz = _fz * _s; tz = _tz * _s;
				break;
				
			case 1 : 
				fx = _fx * _s; tx = _tx * _s;
				fy = _fz * _s; ty = _tz * _s;
				fz = _fy * _s; tz = _ty * _s;
				break;
				
		}
		
		fx -= model_offset[0] * _s;
		fy -= model_offset[1] * _s;
		fz -= model_offset[2] * _s;
		tx -= model_offset[0] * _s;
		ty -= model_offset[1] * _s;
		tz -= model_offset[2] * _s;
		
		var _face = _element.faces; 
		
		var _f  = _face.up;
		var fu = _f.uv[0] / tex_width;
		var fv = _f.uv[1] / tex_height;
		var tu = _f.uv[2] / tex_width;
		var tv = _f.uv[3] / tex_height;
		
		array_push(material_arr, string_trim(_f.texture, ["#"]));
		array_push(_vertices, [ // +z
			__vertexA( [ fx, fy, tz ] ).setNormal( 0, 0, 1 ).setUV(fu, fv),
			__vertexA( [ fx, ty, tz ] ).setNormal( 0, 0, 1 ).setUV(fu, tv),
			__vertexA( [ tx, ty, tz ] ).setNormal( 0, 0, 1 ).setUV(tu, tv),
			
			__vertexA( [ tx, fy, tz ] ).setNormal( 0, 0, 1 ).setUV(tu, fv),
			__vertexA( [ fx, fy, tz ] ).setNormal( 0, 0, 1 ).setUV(fu, fv),
			__vertexA( [ tx, ty, tz ] ).setNormal( 0, 0, 1 ).setUV(tu, tv),
		]);
		
		var _f = _face.down;
		var fu = _f.uv[0] / tex_width;
		var fv = _f.uv[1] / tex_height;
		var tu = _f.uv[2] / tex_width;
		var tv = _f.uv[3] / tex_height;
		
		array_push(material_arr, string_trim(_f.texture, ["#"]));
		array_push(_vertices, [ // -z
			__vertexA( [ fx, fy, fz ] ).setNormal( 0, 0,-1 ).setUV(fu, fv),
			__vertexA( [ tx, ty, fz ] ).setNormal( 0, 0,-1 ).setUV(tu, tv),
			__vertexA( [ fx, ty, fz ] ).setNormal( 0, 0,-1 ).setUV(fu, tv),
			
			__vertexA( [ tx, fy, fz ] ).setNormal( 0, 0,-1 ).setUV(tu, fv),
			__vertexA( [ tx, ty, fz ] ).setNormal( 0, 0,-1 ).setUV(tu, tv),
			__vertexA( [ fx, fy, fz ] ).setNormal( 0, 0,-1 ).setUV(fu, fv),
		]);
		
		var _f = _face.east;
		var fu = _f.uv[0] / tex_width;
		var fv = _f.uv[1] / tex_height;
		var tu = _f.uv[2] / tex_width;
		var tv = _f.uv[3] / tex_height;
		
		array_push(material_arr, string_trim(_f.texture, ["#"]));
		array_push(_vertices, [ // +x
			__vertexA( [ tx, fy, fz ] ).setNormal( 1, 0, 0 ).setUV(fu, fv),
			__vertexA( [ tx, fy, tz ] ).setNormal( 1, 0, 0 ).setUV(fu, tv),
			__vertexA( [ tx, ty, tz ] ).setNormal( 1, 0, 0 ).setUV(tu, tv),
			
			__vertexA( [ tx, ty, fz ] ).setNormal( 1, 0, 0 ).setUV(tu, fv),
			__vertexA( [ tx, fy, fz ] ).setNormal( 1, 0, 0 ).setUV(fu, fv),
			__vertexA( [ tx, ty, tz ] ).setNormal( 1, 0, 0 ).setUV(tu, tv),
		]);
		
		var _f = _face.west;
		var fu = _f.uv[0] / tex_width;
		var fv = _f.uv[1] / tex_height;
		var tu = _f.uv[2] / tex_width;
		var tv = _f.uv[3] / tex_height;
		
		array_push(material_arr, string_trim(_f.texture, ["#"]));
		array_push(_vertices, [ // -x
			__vertexA( [ fx, fy, fz ] ).setNormal(-1, 0, 0 ).setUV(fu, fv),
			__vertexA( [ fx, ty, tz ] ).setNormal(-1, 0, 0 ).setUV(tu, tv),
			__vertexA( [ fx, fy, tz ] ).setNormal(-1, 0, 0 ).setUV(fu, tv),
			
			__vertexA( [ fx, ty, fz ] ).setNormal(-1, 0, 0 ).setUV(tu, fv),
			__vertexA( [ fx, ty, tz ] ).setNormal(-1, 0, 0 ).setUV(tu, tv),
			__vertexA( [ fx, fy, fz ] ).setNormal(-1, 0, 0 ).setUV(fu, fv),
		]);
		
		var _f = _face.north;
		var fu = _f.uv[0] / tex_width;
		var fv = _f.uv[1] / tex_height;
		var tu = _f.uv[2] / tex_width;
		var tv = _f.uv[3] / tex_height;
		
		array_push(material_arr, string_trim(_f.texture, ["#"]));
		array_push(_vertices, [ // +y
			__vertexA( [ fx, ty, fz ] ).setNormal( 0, 1, 0 ).setUV(fu, fv),
			__vertexA( [ tx, ty, tz ] ).setNormal( 0, 1, 0 ).setUV(tu, tv),
			__vertexA( [ fx, ty, tz ] ).setNormal( 0, 1, 0 ).setUV(fu, tv),
			
			__vertexA( [ tx, ty, fz ] ).setNormal( 0, 1, 0 ).setUV(tu, fv),
			__vertexA( [ tx, ty, tz ] ).setNormal( 0, 1, 0 ).setUV(tu, tv),
			__vertexA( [ fx, ty, fz ] ).setNormal( 0, 1, 0 ).setUV(fu, fv),
		]);
		
		var _f = _face.south;
		var fu = _f.uv[0] / tex_width;
		var fv = _f.uv[1] / tex_height;
		var tu = _f.uv[2] / tex_width;
		var tv = _f.uv[3] / tex_height;
		
		array_push(material_arr, string_trim(_f.texture, ["#"]));
		array_push(_vertices, [ // -y
			__vertexA( [ fx, fy, fz ] ).setNormal( 0,-1, 0 ).setUV(fu, fv),
			__vertexA( [ fx, fy, tz ] ).setNormal( 0,-1, 0 ).setUV(fu, tv),
			__vertexA( [ tx, fy, tz ] ).setNormal( 0,-1, 0 ).setUV(tu, tv),
			
			__vertexA( [ tx, fy, fz ] ).setNormal( 0,-1, 0 ).setUV(tu, fv),
			__vertexA( [ fx, fy, fz ] ).setNormal( 0,-1, 0 ).setUV(fu, fv),
			__vertexA( [ tx, fy, tz ] ).setNormal( 0,-1, 0 ).setUV(tu, tv),
		]);
		
		if(has(_element, "children"))
		for( var i = 0, n = array_length(_element.children); i < n; i++ )
			readElement(_vertices, _element.children[i], _fx, _fy, _fz);
	}
	
	static readJson = function(_path) {
		if(!file_exists_empty(_path)) return;
		current_path = _path;
		
		if(object != noone) object.destroy();
		object = noone;
		
		var _data = json_load_struct(_path);
		if(!has(_data, "elements")) return;
		
		model_scale   = getSingleValue(in_mesh + 2);
		model_axis    = getSingleValue(in_mesh + 3);
		model_offset  = getSingleValue(in_mesh + 4);
		
		material_map  = _data.textures;
		tex_width     = struct_try_get(_data, "textureWidth", 16);
		tex_height    = struct_try_get(_data, "textureHeight", 16);
	
		var _elements = _data.elements;
		var _vertices = [];
		material_arr  = [];
		
		for( var i = 0, n = array_length(_elements); i < n; i++ ) {
			var _element = _elements[i];
			readElement(_vertices, _element);
		}
		
		object = new __3dObject();
		object.vertex = _vertices;
		object.object_counts = array_length(_vertices);
		object.VF = global.VF_POS_NORM_TEX_COL;
		object.VB = object.build();
		
			
		var _textureKeys = struct_get_names(material_map);
		use_texture = !array_empty(_textureKeys);
		var _in = [];
		
		if(use_texture) {
			for( var i = 0, n = array_length(_textureKeys); i < n; i++ ) {
				var _tname = _textureKeys[i];
				
				var _inp = array_safe_get(inputs, input_fix_len + i, noone);
				if(_inp == noone) _inp = createNewInput();
				
				_inp.setName(_tname);
				array_push(_in, _inp);
			}
			
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