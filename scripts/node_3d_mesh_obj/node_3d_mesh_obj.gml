function Node_create_3D_Obj(_x, _y, _group = noone) { #region
	var path = "";
	if(!LOADING && !APPENDING && !CLONING) {
		path = get_open_filename(".obj", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_3D_Mesh_Obj(_x, _y, _group);
	node.setPath(path);
	return node;
} #endregion

function Node_create_3D_Obj_path(_x, _y, path) { #region
	if(!file_exists(path)) return noone;
	
	var node = new Node_3D_Mesh_Obj(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.setPath(path);
	return node;
} #endregion

function Node_3D_Mesh_Obj(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Obj";
	
	object = noone;
	object_class = __3dObject;
	
	inputs[| in_mesh + 0] = nodeValue("File Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "" )
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "*.obj" })
		.rejectArray();
	
	inputs[| in_mesh + 1] = nodeValue("Flip UV", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Flip UV axis, can be use to fix some texture mapping error.")
		.rejectArray();
	
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Object",	 false], in_mesh + 0, 
		["Material", false], in_mesh + 1, 
	]
	
	setIsDynamicInput(1);
	
	current_path  = "";
	materials     = [];
	materialNames = [];
	materialIndex = [];
	use_normal    = false;
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() {
		var _path = getInputData(in_mesh + 0);
		updateObj(_path);
	}
	
	function setPath(path) {
		inputs[| in_mesh + 0].setValue(path);
		updateObj(path);
	}
	
	static createNewInput = function(index = -1) { #region
		if(index == -1) index = ds_list_size(inputs);
		
		inputs[| index] = nodeValue("Material", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, noone)
							.setVisible(true, true);
	} #endregion
	
	static createMaterial = function(m_index) { #region
		var index = input_fix_len + m_index;
		
		input_display_list[input_display_len + m_index] = index;
		if(index < ds_list_size(inputs)) return;
		
		createNewInput(index);
		
		if(m_index >= array_length(materials)) return;
		
		var matY = y - (array_length(materials) - 1) / 2 * (128 + 32);
		var mat  = materials[m_index];
		inputs[| index].name = materialNames[m_index] + " Material";
		
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
		
		var _dir     = filename_dir(_path);
		var _pathMtl = string_copy(_path, 1, string_length(_path) - 4) + ".mtl";
		
		var _v = readObj(_path);
		if(_v == noone) return;
		
		if(object != noone) object.destroy();
		object = new __3dObject();
		object.VB      = _v.vertex_groups;
		object.vertex  = _v.vertex;
		object.object_counts  = _v.object_counts;
		
		object.size   = _v.model_size;
		materialNames = _v.materials;
		materialIndex = _v.material_index;
		use_normal    = _v.use_normal;
		if(_v.mtl_path != "")
			_pathMtl  = _dir + "/" + _v.mtl_path;
		
		if(array_length(materialNames)) 
			materials = readMtl(_pathMtl);
		else {
			materialNames = [ "Material" ];
			materialIndex = [ 0 ];
			materials = [ new MTLmaterial("Material") ];
		}
			
		array_resize(input_display_list, input_display_len);
			
		var _overflow = input_fix_len + array_length(materialNames);
		while(ds_list_size(inputs) > _overflow)
			ds_list_delete(inputs, _overflow);
		
		for(var i = 0; i < array_length(materialNames); i++) 
			createMaterial(i);
		
		triggerRender();
	} #endregion
	
	static step = function() { #region
		
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _path = _data[in_mesh + 0];
		var _flip = _data[in_mesh + 1];
		
		if(_path != current_path)
			updateObj(_path);
		
		if(object == noone) return noone;
		var materials = [];
		for( var i = input_fix_len, n = array_length(_data); i < n; i++ ) 
			materials[i - input_fix_len] = _data[i];
		
		var _object = getObject(_array_index);
		_object.VF		= global.VF_POS_NORM_TEX_COL;
		_object.VB		= object.VB;
		_object.NVB		= object.NVB;
		_object.vertex  = object.vertex;
		_object.object_counts	= object.object_counts;
		_object.materials		= materials;
		_object.matrial_index	= materialIndex;
		_object.texture_flip    = _flip;
		
		setTransform(_object, _data);
		return _object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get(all_inputs, in_mesh + 2, noone); }
}