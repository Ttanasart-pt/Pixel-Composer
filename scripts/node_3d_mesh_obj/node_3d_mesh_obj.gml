function Node_create_3D_Obj(_x, _y, _group = noone) {
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename_pxc("3d object|*.obj", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_3D_Mesh_Obj(_x, _y, _group).skipDefault();
	node.setPath(path);
	return node;
}

function Node_create_3D_Obj_path(_x, _y, path) {
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_3D_Mesh_Obj(_x, _y, PANEL_GRAPH.getCurrentContext()).skipDefault();
	node.setPath(path);
	return node;
}

function Node_3D_Mesh_Obj(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Obj";
	
	object = noone;
	object_class = __3dObject;
	
	newInput(in_mesh + 0, nodeValue_Path("File Path", self, "" ))
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "3d object|*.obj" })
		.rejectArray();
	
	newInput(in_mesh + 1, nodeValue_Bool("Flip UV", self, true, "Flip UV axis, can be use to fix some texture mapping error."))
		.rejectArray();
	
	newInput(in_mesh + 2, nodeValue_Float("Import Scale", self, 1))
		.rejectArray();
		
	newInput(in_mesh + 3, nodeValue_Enum_Scroll("Axis", self, 0, [ "XYZ", "XZ-Y", "X-ZY" ]))
		.rejectArray();
		
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Object",	 false], in_mesh + 0, in_mesh + 2, in_mesh + 3,  
		["Material", false], in_mesh + 1, 
	]
	
	setDynamicInput(1, false);
	
	obj_reading       = false;
	obj_raw			  = noone;
	obj_read_progress = 0;
	obj_read_prog_sub = 0;
	obj_read_prog_tot = 3;
	obj_read_time     = 0;
	
	current_path  = "";
	materials     = [];
	materialNames = [];
	materialIndex = [];
	use_normal    = false;
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh_icon, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { 
		current_path = ""; 
		outputs[0].setValue(noone);
	}

	function setPath(path) { inputs[in_mesh + 0].setValue(path); }
	
	static createNewInput = function(index = -1) { #region
		if(index == -1) index = array_length(inputs);
		
		newInput(index, nodeValue_D3Material("Material", self, new __d3dMaterial()))
							.setVisible(true, true);
	} #endregion
	
	static createMaterial = function(m_index) { #region
		var index = input_fix_len + m_index;
		
		input_display_list[input_display_len + m_index] = index;
		if(index < array_length(inputs)) return;
		
		createNewInput(index);
		
		if(m_index >= array_length(materials)) return;
		
		var matY = y - (array_length(materials) - 1) / 2 * (128 + 32);
		var mat  = materials[m_index];
		inputs[index].name = materialNames[m_index] + " Material";
		
		if(file_exists_empty(mat.diff_path)) {
			var sol = Node_create_Image_path(x - (w + 128), matY + m_index * (128 + 32), mat.diff_path);
			sol.name = mat.name + " texture";
			
			inputs[index].setFrom(sol.outputs[0]);
		} else {
			var sol = nodeBuild("Node_Solid", x - (w + 128), matY + m_index * (128 + 32));
			sol.name = mat.name + " texture";
			sol.inputs[1].setValue(cola(mat.diff));
			
			inputs[index].setFrom(sol.outputs[0]);
		}
	} #endregion
	
	static updateObj = function(_path) { #region
		if(!file_exists_empty(_path)) return;
		current_path = _path;
		
		var _scale = inputs[in_mesh + 2].getValue();
		var _axis  = inputs[in_mesh + 3].getValue();
		
		readObj_init(_scale, _axis);
		
		obj_read_time    = get_timer();
		obj_read_file    = file_text_open_read(current_path);
		use_display_list = false;
	} #endregion
	
	static updateObjProcess = function() { #region
		switch(obj_read_progress) {
			case 0 : readObj_file(); break;
			case 1 : readObj_cent(); break;
			case 2 : readObj_buff(); break;
		}
	} #endregion
	
	static updateObjComplete = function() { #region
		use_display_list = true;
		if(obj_raw == noone) return;
		
		var txt = $"========== OBJ import ==========\n";
		txt += $"Vertex counts:   {obj_raw.vertex_count}\n";
		txt += $"Object counts:   {obj_raw.object_counts}\n";
		txt += $"Material counts: {array_length(obj_raw.materials)}\n";
		txt += $"Model BBOX:      {obj_raw.model_size}\n";
		txt += $"Load completed in {(get_timer() - obj_read_time) / 1000} ms\n";
		logNode(txt);
		
		var span = max(abs(obj_raw.model_size.x), abs(obj_raw.model_size.y), abs(obj_raw.model_size.z));
		if(span > 10) {
			var _txt = $"The model is tool large to display properly ({span}u). Scale the model down to preview.";
			logNode(_txt); noti_warning(_txt);
		}
		
		if(object != noone) object.destroy();
		
		object = new __3dObject();
		object.VB     = obj_raw.vertex_groups;
		object.vertex = obj_raw.vertex;
		object.size   = obj_raw.model_size;
		object.object_counts  = obj_raw.object_counts;
		use_normal    = obj_raw.use_normal;
		
		materialNames = [ "Material" ];
		materialIndex = obj_raw.material_index;
		materials     = [ new MTLmaterial("Material") ];
		
		if(obj_raw.use_material) {
			var _dir     = filename_dir(current_path);
			var _pathMtl = string_copy(current_path, 1, string_length(current_path) - 4) + ".mtl";
			if(obj_raw.mtl_path != "") _pathMtl  = _dir + "/" + obj_raw.mtl_path;
			materials = readMtl(_pathMtl);
			
			if(array_length(materials) == array_length(obj_raw.materials)) {
				materialNames = array_create(array_length(materials));
				for( var i = 0, n = array_length(materials); i < n; i++ )
					materialNames[i] = materials[i].name;
				
			} else {
				var _txt = "Load mtl error: Material amount defined in .mtl file not match the .obj file.";
				logNode(_txt); noti_warning(_txt);
			}
		}
		
		array_resize(input_display_list, input_display_len);
			
		var _overflow = input_fix_len + array_length(materialNames);
		while(array_length(inputs) > _overflow)
			array_delete(inputs, _overflow, 1);
		
		for(var i = 0; i < array_length(materialNames); i++) 
			createMaterial(i);
		
		triggerRender();
	} #endregion
	
	static step = function() { #region
		if(obj_reading) {
			updateObjProcess();
			
			if(obj_read_progress == obj_read_prog_tot) {
				updateObjComplete();
				obj_reading = false;
				
				triggerRender();
			}
			return;
		}
		
		var _path = getInputData(in_mesh + 0);
		if(_path != current_path) updateObj(_path);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		if(obj_reading) return noone;
		
		var _flip = _data[in_mesh + 1];
		
		if(object == noone) return noone;
		var materials = [];
		for( var i = input_fix_len, n = array_length(_data); i < n; i++ ) 
			materials[i - input_fix_len] = _data[i];
		
		var _object = getObject(_array_index);
		_object.VF		= global.VF_POS_NORM_TEX_COL;
		_object.VB		= object.VB;
		_object.NVB		= object.NVB;
		_object.vertex  = object.vertex;
		_object.size    = object.size;
		_object.object_counts	= object.object_counts;
		_object.materials		= materials;
		_object.material_index	= materialIndex;
		_object.texture_flip    = _flip;
		
		setTransform(_object, _data);
		return _object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get_fast(all_inputs, in_mesh + 3, noone); }
	
	static onDrawNodeOver = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		if(!obj_reading) return;
		
		var bbox = drawGetBbox(xx, yy, _s);
		var rr   = min(bbox.w - 16, bbox.h - 16) / 2;
		var ast  = current_time / 5;
		var prg  = obj_read_progress / obj_read_prog_tot;
		
		draw_set_color(COLORS._main_icon);
		draw_arc(bbox.xc, bbox.yc, rr, ast, ast + prg * 360, 4 * _s, 90);
	} #endregion
}