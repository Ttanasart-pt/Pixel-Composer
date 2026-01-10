#region global
	function Node_create_3D_Obj(_x, _y, _group = noone) {
		var path = "";
		if(NODE_NEW_MANUAL) {
			path = get_open_filename_compat("3d object|*.obj", "");
			key_release();
			if(path == "") return noone;
		}
		
		var node = new Node_3D_Mesh_Obj(_x, _y, _group);
		node.skipDefault();
		node.setPath(path);
		return node;
	}
	
	function Node_create_3D_Obj_path(_x, _y, path) {
		if(!file_exists_empty(path)) return noone;
		
		var node = new Node_3D_Mesh_Obj(_x, _y, PANEL_GRAPH.getCurrentContext());
		node.skipDefault();
		node.setPath(path);
		return node;
	}
#endregion

function Node_3D_Mesh_Obj(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Obj";
	
	////- =Object
	newInput(in_mesh + 0, nodeValue_Path(        "File Path" )).setDisplay(VALUE_DISPLAY.path_load, { filter: "3d object|*.obj" });
	newInput(in_mesh + 2, nodeValue_Float(       "Import Scale", 1 ));
	newInput(in_mesh + 3, nodeValue_Enum_Scroll( "Axis",         0, [ "XYZ", "XZ-Y", "X-ZY" ]));
	
	////- =Material
	newInput(in_mesh + 1, nodeValue_Bool( "Flip UV", true, "Flip UV axis, can be use to fix some texture mapping error."));
		
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Object",	 false], in_mesh + 0, in_mesh + 2, in_mesh + 3,  
		["Material", false], in_mesh + 1, 
	]
	
	array_foreach(inputs, function(i) /*=>*/ {return i.rejectArray()}, in_mesh);
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		newInput(index, nodeValue_D3Material("Material", new __d3dMaterial())).setVisible(true, true);
		
		array_push(input_display_list, inAmo);
		return inputs[index];
	} setDynamicInput(1, false);
	
	////- Nodes
	
	object_data  = noone;
	object_class = __3dObject;
	
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
	
	insp1button = button(function() /*=>*/ { current_path = ""; outputs[0].setValue(noone); }).setTooltip(__txt("Refresh"))
		.setIcon(THEME.refresh_icon, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	function setPath(path) { inputs[in_mesh + 0].setValue(path); }
	
	////- Obj loader
	
	static createMaterial = function(m_index) {
		var index = input_fix_len + m_index;
		if(index < array_length(inputs) || m_index >= array_length(materials)) return;
		
		var matY = y - (array_length(materials) - 1) / 2 * (128 + 32);
		var mat  = materials[m_index];
		var inp  = createNewInput(index);
		var sol  = noone;
		inp.name = materialNames[m_index] + " Material";
		
		if(mat.diff_path == "") {
			var sol = nodeBuild("Node_Solid", x - (w + 64), matY + m_index * (128 + 32));
			sol.inputs[1].setValue(cola(mat.diff));
			
		} else {
			if(file_exists_empty(mat.diff_path)) {
				var sol = Node_create_Image_path(x - (w + 64), matY + m_index * (128 + 32), mat.diff_path);
				
			} else {
				var sol = nodeBuild("Node_Solid", x - (w + 64), matY + m_index * (128 + 32));
				sol.inputs[1].setValue(cola(mat.diff));
				
				noti_warning($"Texture image not found {mat.diff_path}");
			}
			
		}
		
		if(sol != noone) sol.name = mat.name + " texture";
		inp.setFrom(sol.outputs[0]);
	}
	
	static updateObjStart = function(_path) {
		if(!file_exists_empty(_path)) return;
		current_path = _path;
		
		var _scale = inputs[in_mesh + 2].getValue();
		var _axis  = inputs[in_mesh + 3].getValue();
		
		readObj_init(_scale, _axis);
		
		obj_read_time    = get_timer();
		obj_read_file    = file_text_open_read(current_path);
		use_display_list = false;
	}
	
	static updateObjProcess = function() {
		switch(obj_read_progress) {
			case 0 : readObj_file(); break;
			case 1 : readObj_cent(); break;
			case 2 : readObj_buff(); break;
		}
	}
	
	static updateObjComplete = function() {
		use_display_list = true;
		if(obj_raw == noone) return;
		
		var txt =   $"========== OBJ import ==========\n"
		          + $"Vertex counts:   {obj_raw.vertex_count}\n"
		          + $"Object counts:   {obj_raw.object_counts}\n"
		          + $"Material counts: {array_length(obj_raw.materials)}\n"
		          + $"Model BBOX:      {obj_raw.model_size}\n"
		          + $"Load completed in {(get_timer() - obj_read_time) / 1000} ms\n"
		logNode(txt);
		
		var span = max(abs(obj_raw.model_size.x), abs(obj_raw.model_size.y), abs(obj_raw.model_size.z));
		if(span > 10) noti_warning($"The model is tool large to display properly ({span}u). Scale the model down to preview.", noone, self);
		
		if(object_data != noone) object_data.destroy();
		
		object_data = new __3dObject();
		object_data.VB            = obj_raw.vertex_groups;
		object_data.vertex        = obj_raw.vertex;
		object_data.size          = obj_raw.model_size;
		object_data.object_counts = obj_raw.object_counts;
		object_data.edges         = [ obj_raw.edge_data ];
		object_data.buildEdge();
		
		use_normal    = obj_raw.use_normal;
		materialNames = [ "Material" ];
		materialIndex = array_empty(obj_raw.material_index)? undefined : obj_raw.material_index;
		materials     = [ new MTLmaterial("Material") ];
		
		if(obj_raw.use_material) {
			var _dir     = filename_dir(current_path);
			var _pathMtl = string_copy(current_path, 1, string_length(current_path) - 4) + ".mtl";
			if(obj_raw.mtl_path != "") _pathMtl  = $"{_dir}/{obj_raw.mtl_path}";
			materials = readMtl(_pathMtl);
			
			if(array_length(materials) == array_length(obj_raw.materials)) {
				materialNames = array_create(array_length(materials));
				for( var i = 0, n = array_length(materials); i < n; i++ )
					materialNames[i] = materials[i].name;
				
			} else
				noti_warning("Load mtl error: Material amount defined in .mtl file not match the .obj file.", noone, self);
		}
			
		var _overflow = input_fix_len + array_length(materialNames);
		while(array_length(inputs) > _overflow)
			array_delete(inputs, _overflow, 1);
		
		for(var i = 0; i < array_length(materialNames); i++)
			createMaterial(i);
		
		array_resize(input_display_list, input_display_len);	
		for(var i = 0; i < array_length(materialNames); i++)
			array_push(input_display_list, input_fix_len + i);
		
		triggerRender();
	}
	
	////- Update
	
	static step = function() {
		if(obj_reading) {
			updateObjProcess();
			
			if(obj_read_progress == obj_read_prog_tot) {
				updateObjComplete();
				obj_reading = false;
			}
			return;
		}
		
		var _path = getInputData(in_mesh + 0);
		if(_path != current_path) updateObjStart(_path);
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		if(obj_reading) return noone;
		
		var _flip = _data[in_mesh + 1];
		
		if(object_data == noone) return noone;
		var _materials = [];
		for( var i = input_fix_len, n = array_length(_data); i < n; i++ ) 
			_materials[i - input_fix_len] = _data[i];
		
		var _object = getObject(_array_index);
		_object.VF		        = global.VF_POS_NORM_TEX_COL;
		_object.VB		        = object_data.VB;
		_object.EB		        = object_data.EB;
		_object.NVB		        = object_data.NVB;
		_object.vertex          = object_data.vertex;
		_object.size            = object_data.size;
		_object.object_counts	= object_data.object_counts;
		_object.materials		= _materials;
		_object.material_index	= materialIndex;
		_object.texture_flip    = _flip;
		
		setTransform(_object, _data);
		
		return _object;
	}
	
	static onDrawNodeOver = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(!obj_reading) return;
		
		var bbox = draw_bbox;
		var rr   = min(bbox.w - 16, bbox.h - 16) / 2;
		var ast  = current_time / 5;
		var prg  = obj_read_progress / obj_read_prog_tot;
		
		draw_set_color(COLORS._main_icon);
		draw_arc(bbox.xc, bbox.yc, rr, ast, ast + prg * 360, 4 * _s, 90);
	}
}