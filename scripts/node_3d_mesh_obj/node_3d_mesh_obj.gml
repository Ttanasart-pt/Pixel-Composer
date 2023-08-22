function Node_create_3D_Obj(_x, _y, _group = noone) {
	var path = "";
	if(!LOADING && !APPENDING && !CLONING) {
		path = get_open_filename(".obj", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_3D_Mesh_Obj(_x, _y, _group);
	node.setPath(path);
	return node;
}

function Node_create_3D_Obj_path(_x, _y, path) {
	if(!file_exists(path)) return noone;
	
	var node = new Node_3D_Mesh_Obj(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.setPath(path);
	return node;
}

function Node_3D_Mesh_Obj(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Obj";
	
	object = noone;
	object_class = __3dObject;
	
	inputs[| in_mesh + 0] = nodeValue("File Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "" )
		.setDisplay(VALUE_DISPLAY.path_load, [ "*.obj", "" ])
		.rejectArray();
	
	inputs[| in_mesh + 1] = nodeValue("Flip UV", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Flip UV axis, can be use to fix some texture mapping error.")
		.rejectArray();
	
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Object",	false], in_mesh + 0, 
		["Texture",	false], in_mesh + 1, 
	]
	
	input_fix_len = ds_list_size(inputs);
	input_display_len = array_length(input_display_list);
	
	current_path  = "";
	materials     = [];
	materialNames = [];
	materialIndex = [];
	use_normal    = false;
	
	function setPath(path) {
		inputs[| in_mesh + 0].setValue(path);
		updateObj(path);
	}
	
	static createMaterial = function(m_index) { #region
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue(materialNames[m_index] + " Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
							.setVisible(true, true);
		input_display_list[input_display_len + m_index] = index;
		
		if(m_index >= array_length(materials)) return;
		
		var matY = y - (array_length(materials) - 1) / 2 * (128 + 32);
		var mat  = materials[m_index];
		
		if(file_exists(mat.diff_path)) {
			var sol = Node_create_Image_path(x - (w + 128), matY + m_index * (128 + 32), mat.diff_path);
			sol.name = mat.name + " texture";
			
			inputs[| index].setFrom(sol.outputs[| 0]);
		} else {
			var sol = nodeBuild("Node_Solid", x - (w + 128), matY + m_index * (128 + 32));
			sol.name = mat.name + " texture";
			sol.inputs[| 1].setValue(mat.diff);
			
			inputs[| index].setFrom(sol.outputs[| 0]);
		}
	} #endregion
	
	static updateObj = function(_path) { #region
		if(!file_exists(_path)) return;
		current_path = _path;
		
		var _flip    = inputs[| in_mesh + 1].getValue();
		var _dir     = filename_dir(_path);
		var _pathMtl = string_copy(_path, 1, string_length(_path) - 4) + ".mtl";
		
		var _v = readObj(_path, _flip);
		if(_v == noone) return;
		
		if(object != noone) object.destroy();
		object = new __3dObject();
		object.VB      = _v.vertex_groups;
		object.vertex  = _v.vertex_positions;
		object.normals = _v.vertex_normals;
		object.uv      = _v.vertex_textures;
		
		object.size   = _v.model_size;
		materialNames = _v.materials;
		materialIndex = _v.material_index;
		use_normal    = _v.use_normal;
		if(_v.mtl_path != "")
			_pathMtl  = _dir + "/" + _v.mtl_path;
		
		if(array_length(materialNames)) 
			materials = readMtl(_pathMtl);
		else {
			materialNames = ["Material"];
			materialIndex = [0];
			materials = [ new MTLmaterial("Material") ];
		}
			
		array_resize(input_display_list, input_display_len);
			
		while(ds_list_size(inputs) > input_fix_len)
			ds_list_delete(inputs, input_fix_len);
		
		for(var i = 0; i < array_length(materialNames); i++) 
			createMaterial(i);
		
		triggerRender();
	} #endregion
	
	static step = function() { #region
		
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _path = _data[in_mesh + 0];
		if(_path != current_path)
			updateObj(_path);
		
		var textures = [];
		for( var i = input_fix_len, n = array_length(_data); i < n; i++ ) 
			textures[i - input_fix_len] = surface_texture(_data[i]);
		
		var _object = getObject(_array_index);
		if(object == noone)
			return _object;
		
		_object.VF		= global.VF_POS_NORM_TEX_COL;
		_object.VB		= object.VB;
		_object.vertex  = object.vertex;
		_object.normals = object.normals; 
		_object.uv      = object.uv;
		_object.texture = textures;
		
		setTransform(_object, _data);
		return _object;
	} #endregion
	
	//static getPreviewValues = function() { return array_safe_get(all_inputs, in_mesh + 1, noone); }
}