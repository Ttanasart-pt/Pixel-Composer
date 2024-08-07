function __Node_3D_Obj(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "3D Object";
	
	inputs[| 0] = nodeValue_Text("Path", self, "")
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "3d object|*.obj" })
		.rejectArray();
	
	inputs[| 1] = nodeValue_Trigger("Generate", self, false )
		.setDisplay(VALUE_DISPLAY.button, { name: "Generate", UI : true, onClick: function() { 
			updateObj();
			doUpdate(); 
		} });
	
	inputs[| 2] = nodeValue_Dimension(self);
	
	inputs[| 3] = nodeValue_Vector("Render position", self, [ 0.5, 0.5 ])
		.setUnitRef( function() { return getInputData(2); }, VALUE_UNIT.reference);
		
	inputs[| 4] = nodeValue_Vector("Render rotation", self, [ 0, 0, 0 ]);
	
	inputs[| 5] = nodeValue_Vector("Render scale", self, [ 1, 1 ]);
		
	inputs[| 6] = nodeValue_Rotation("Light direction", self, 0)
		.rejectArray();
		
	inputs[| 7] = nodeValue_Float("Light height", self, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] })
		.rejectArray();
		
	inputs[| 8] = nodeValue_Float("Light intensity", self, 1)
		.setDisplay(VALUE_DISPLAY.slider)
		.rejectArray();
	
	inputs[| 9] = nodeValue_Color("Light color", self, c_white)
		.rejectArray();
	
	inputs[| 10] = nodeValue_Color("Ambient color", self, c_grey)
		.rejectArray();
	
	inputs[| 11] = nodeValue_Vector("Object scale", self, [ 1, 1, 1 ]);
		
	inputs[| 12] = nodeValue_Bool("Flip UV", self, true, "Flip UV axis, can be use to fix some texture mapping error.")
		.rejectArray();
	
	inputs[| 13] = nodeValue_Vector("Object rotation", self, [ 0, 0, 180 ]);
		
	inputs[| 14] = nodeValue_Vector("Object position", self, [ 0, 0, 0 ]);
	
	inputs[| 15] = nodeValue_Enum_Button("Projection", self,  0, [ "Orthographic", "Perspective" ])
		.rejectArray();
		
	inputs[| 16] = nodeValue_Float("Field of view", self, 60)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 90, 0.1 ] })
		.rejectArray();
	
	inputs[| 17] = nodeValue_Bool("Scale view with dimension", self, true)
	
	input_display_list = [ 
		["Output", 				false], 2, 17, 
		["Geometry",			false], 0, 1, 
		["Object transform",	false], 14, 13, 11,
		["Camera",				false], 15, 16, 3, 5, 
		["Light",				false], 6, 7, 8, 9, 10,
		["Textures",			 true], 12,
	];
	input_length = ds_list_size(inputs);
	input_display_len = array_length(input_display_list);
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue_Output("3D scene", self, VALUE_TYPE.d3object, function() { return submit_vertex(); });
	
	outputs[| 2] = nodeValue_Output("Normal pass", self, VALUE_TYPE.surface, noone);
	
	output_display_list = [
		0, 2, 1
	]
	
	_3d_node_init(2, /*Transform*/ 3, 5, 14, 13, 11);
	
	tex_surface = surface_create(1, 1);
	
	materialNames = [];
	materialIndex = [];
	materials = [];
		
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
		inputs[| index] = nodeValue_Surface(materialNames[m_index] + " texture", self, tex_surface);
		inputs[| index].setVisible(true);
		
		input_display_list[input_display_len + m_index] = index;
		
		if(m_index >= array_length(materials)) return;
		
		var matY = y - (array_length(materials) - 1) / 2 * (128 + 32);
		var mat = materials[m_index];
		
		if(file_exists_empty(mat.diff_path)) {
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
	
	static updateObj = function(updateMat = true) {
		var _path = getInputData(0);
		if(!file_exists_empty(_path)) return;
		
		var _flip = getInputData(12);
		var _dir  = filename_dir(_path);
		var _pathMtl = string_copy(_path, 1, string_length(_path) - 4) + ".mtl";
		
		var _v = readObj(_path, _flip);
	
		if(_v != noone) {
			VB = _v.vertex_groups;
			materialNames = _v.materials;
			materialIndex = _v.material_index;
			use_normal    = _v.use_normal;
			if(_v.mtl_path != "")
				_pathMtl  = _dir + "/" + _v.mtl_path;
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
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function() {
		var _lpos = getInputData(14);
		var _lrot = getInputData(13);
		var _lsca = getInputData(11);
		
		_3d_local_transform(_lpos, _lrot, _lsca);
		
		for(var i = 0; i < array_length(VB); i++) {
			if(i >= array_length(materialIndex)) continue;
				
			var mIndex = materialIndex[i];
			var tex = getInputData(input_length + mIndex);
						
			if(!is_surface(tex)) continue;
			vertex_submit(VB[i], pr_trianglelist, surface_get_texture(tex));
		}
		
		_3d_clear_local_transform();
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(!surface_exists(tex_surface)) reset_tex();
		
		if(do_reset_material) {
			array_resize(input_display_list, input_display_len);
			
			while(ds_list_size(inputs) > input_length)
				ds_list_delete(inputs, input_length);
		
			for(var i = 0; i < array_length(materialNames); i++) 
				createMaterial(i);
			do_reset_material = false;
		}
		
		var _dim  = getInputData(2);
		var _pos  = getInputData(3);
		//var _rot  = getInputData(4);
		var _sca  = getInputData(5);
		
		var _ldir = getInputData(6);
		var _lhgt = getInputData(7);
		var _lint = getInputData(8);
		var _lclr = getInputData(9);
		var _aclr = getInputData(10);
							  
		var _lpos = getInputData(14);
		var _lrot = getInputData(13);
		var _lsca = getInputData(11);
		
		var _proj = getInputData(15);
		var _fov  = getInputData(16);
		var _dimS = getInputData(17);
		
		inputs[| 16].setVisible(_proj == 1);
		
		for( var i = 0, n = array_length(output_display_list) - 1; i < n; i++ ) {
			var ind = output_display_list[i];
			var _outSurf = outputs[| ind].getValue();
			
			var pass = "diff";
			switch(ind) {
				case 0 : pass = "diff" break;
				case 2 : pass = "norm" break;
			}
			
			var _transform = new __3d_transform(_pos,, _sca, _lpos, _lrot, _lsca, true, _dimS );
			var _light     = new __3d_light(_ldir, _lhgt, _lint, _lclr, _aclr);
			var _cam	   = new __3d_camera(_proj, _fov);
			
			_outSurf = _3d_pre_setup(_outSurf, _dim, _transform, _light, _cam, pass);
				for(var j = 0; j < array_length(VB); j++) {
					if(j >= array_length(materialIndex)) continue;
					
					var mIndex = materialIndex[j];
					var tex = getInputData(input_length + mIndex);
						
					if(!is_surface(tex)) continue;
					vertex_submit(VB[j], pr_trianglelist, surface_get_texture(tex));
				}
			_3d_post_setup();
			
			outputs[| ind].setValue(_outSurf);
		}
	}
	
	static onCleanUp = function() {
		surface_free(tex_surface);	
	}
}