function Node_create_3D_Obj_path(_x, _y, path) {
	if(!file_exists(path)) return noone;
	
	var node = new Node_3D_Obj(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.setPath(path);
	return node;
}

function Node_3D_Obj(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "3D Object";
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, [ "*.obj", "" ])
		.rejectArray();
	
	inputs[| 1] = nodeValue("Generate", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() { 
			updateObj();
			doUpdate(); 
		}, "Generate"] );
	
	inputs[| 2] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Render position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef( function() { return inputs[| 2].getValue(); });
		
	inputs[| 4] = nodeValue("Render rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue("Render scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 6] = nodeValue("Light direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation)
		.rejectArray();
		
	inputs[| 7] = nodeValue("Light height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [-1, 1, 0.01])
		.rejectArray();
		
	inputs[| 8] = nodeValue("Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.rejectArray();
	
	inputs[| 9] = nodeValue("Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.rejectArray();
	
	inputs[| 10] = nodeValue("Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey)
		.rejectArray();
	
	inputs[| 11] = nodeValue("Object scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 12] = nodeValue("Flip UV", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Flip UV axis, can be use to fix some texture mapping error.")
		.rejectArray();
	
	inputs[| 13] = nodeValue("Object rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 180 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 14] = nodeValue("Object position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 15] = nodeValue("Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Orthographic", "Perspective" ])
		.rejectArray();
		
	inputs[| 16] = nodeValue("Field of view", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 60)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 90, 1 ])
		.rejectArray();
	
	inputs[| 17] = nodeValue("Scale view with dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
	
	input_display_list = [ 
		["Surface",				false], 2, 17, 
		["Geometry",			false], 0, 1, 
		["Object transform",	false], 14, 13, 11,
		["Camera",				false], 15, 16, 3, 5, 
		["Light",				false], 6, 7, 8, 9, 10,
		["Textures",			 true], 12,
	];
	input_length = ds_list_size(inputs);
	input_display_len  = array_length(input_display_list);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("3D object", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3object, function() { return submit_vertex(); });
	
	outputs[| 2] = nodeValue("Normal pass", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	output_display_list = [
		0, 2, 1
	]
	
	_3d_node_init(2, /*Transform*/ 3, 13, 5);
	
	tex_surface = surface_create(1, 1);
	
	function reset_tex() {
		tex_surface = surface_verify(tex_surface, 1, 1);
		surface_set_target(tex_surface);
			draw_clear(c_black);
		surface_reset_target();
	}
	reset_tex();
	
	static onValueUpdate = function(index = 0) {
		if(index == 12) updateObj(false);
	}
	
	function setPath(path) {
		inputs[| 0].setValue(path);
		updateObj();
	}
	
	function createMaterial(m_index) {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue(materialNames[m_index] + " texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, tex_surface);
		inputs[| index].setVisible(true);
		
		input_display_list[input_display_len + m_index] = index;
		
		if(m_index >= array_length(materials)) return;
		
		var matY = y - (array_length(materials) - 1) / 2 * (128 + 32);
		var mat = materials[m_index];
		
		if(file_exists(mat.diff_path)) {
			var sol = Node_create_Image_path(x - (w + 64), matY + m_index * (128 + 32), mat.diff_path);
			sol.name = mat.name + " texture";
			
			inputs[| index].setFrom(sol.outputs[| 0]);
		} else {
			var sol = nodeBuild("Node_Solid", x - (w + 64), matY + m_index * (128 + 32));
			sol.name = mat.name + " texture";
			sol.inputs[| 1].setValue(mat.diff);
			
			inputs[| index].setFrom(sol.outputs[| 0]);
		}
	}
	
	materialNames = [];
	materialIndex = [];
	materials = [];
		
	static updateObj = function(updateMat = true) {
		var _path = inputs[|  0].getValue();
		var _flip = inputs[| 12].getValue();
		var _dir  = filename_dir(_path);
		var _pathMtl = string_copy(_path, 1, string_length(_path) - 4) + ".mtl";
		
		var _v = readObj(_path, _flip);
	
		if(_v != noone) {
			VB = _v.vertex_groups;
			materialNames = _v.materials;
			materialIndex = _v.material_index;
			use_normal    = _v.use_normal;
			if(_v.mtl_path != "")
				_pathMtl  = _dir + "\\" + _v.mtl_path;
		}
		
		if(updateMat) {
			if(array_length(materialNames)) 
				materials = readMtl(_pathMtl);
			else {
				materialNames = ["Material"];
				materialIndex = [0];
				materials = [ new MTLmaterial("Material") ];
			}
		
			do_reset_material = true;
		}
		update();
	}
	do_reset_material = false;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny, true, false);
	}
	
	static submit_vertex = function() {
		var _lpos = inputs[| 14].getValue();
		var _lrot = inputs[| 13].getValue();
		var _lsca = inputs[| 11].getValue();
		
		_3d_local_transform(_lpos, _lrot, _lsca);
		
		for(var i = 0; i < array_length(VB); i++) {
			if(i >= array_length(materialIndex)) continue;
				
			var mIndex = materialIndex[i];
			var tex = inputs[| input_length + mIndex].getValue();
						
			if(!is_surface(tex)) continue;
			vertex_submit(VB[i], pr_trianglelist, surface_get_texture(tex));
		}
		
		_3d_clear_local_transform();
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		if(!surface_exists(tex_surface)) reset_tex();
		
		if(do_reset_material) {
			array_resize(input_display_list, input_display_len);
		
			while(ds_list_size(inputs) > input_length)
				ds_list_delete(inputs, input_length);
		
			for(var i = 0; i < array_length(materialNames); i++) 
				createMaterial(i);
			do_reset_material = false;
		}
		
		var _dim  = inputs[|  2].getValue();
		var _pos  = inputs[|  3].getValue();
		//var _rot  = inputs[|  4].getValue();
		var _sca  = inputs[|  5].getValue();
		
		var _ldir = inputs[|  6].getValue();
		var _lhgt = inputs[|  7].getValue();
		var _lint = inputs[|  8].getValue();
		var _lclr = inputs[|  9].getValue();
		var _aclr = inputs[| 10].getValue();
							  
		var _lpos = inputs[| 14].getValue();
		var _lrot = inputs[| 13].getValue();
		var _lsca = inputs[| 11].getValue();
		
		var _proj = inputs[| 15].getValue();
		var _fov  = inputs[| 16].getValue();
		var _dimS = inputs[| 17].getValue();
		
		inputs[| 16].setVisible(_proj == 1);
		
		for( var i = 0; i < array_length(output_display_list) - 1; i++ ) {
			var ind = output_display_list[i];
			var _outSurf = outputs[| ind].getValue();
			outputs[| ind].setValue(surface_verify(_outSurf, _dim[0], _dim[1]));
			
			var pass = "diff";
			switch(ind) {
				case 0 : pass = "diff" break;
				case 2 : pass = "norm" break;
			}
			
			var _cam   = { projection: _proj, fov: _fov };
			var _scale = { local: false, dimension: _dimS };
			
			_3d_pre_setup(_outSurf, _dim, _pos, _sca, _ldir, _lhgt, _lint, _lclr, _aclr, _lpos, _lrot, _lsca, _cam, pass, _scale);
				submit_vertex();
			_3d_post_setup();
		}
	}
	
	static onCleanUp = function() {
		surface_free(tex_surface);	
	}
}