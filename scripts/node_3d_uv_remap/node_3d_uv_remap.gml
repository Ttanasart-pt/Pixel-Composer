function Node_3D_UV_Remap(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name  = "UV Remap";
	gizmo = new __3dGizmoPlane();
	
	newInput(in_d3d + 0, nodeValue_D3Mesh("Mesh" ));
	newInput(in_d3d + 1, nodeValue_Int("Target subobject", -1)).setArrayDepth(1);
	
	newInput(in_d3d + 2, nodeValue_Int("Bake UV", 0));
	b_bake_uv = button(function() /*=>*/ { attributes.bakedUV = !attributes.bakedUV; triggerRender(); }).setText("Bake UV");
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.d3Mesh, noone));
	
	input_display_list = [ 
		["Transform", false], 0, 1, 2,
		["UV",		  false], in_d3d + 0, in_d3d + 1,
		["Bake",	  false], b_bake_uv,
	];
	
	remap_position = [ 0, 0, 0 ];
	remap_normal   = [ 0, 0, 0 ];
	remap_normal_x = [ 0, 0, 0 ];
	remap_normal_y = [ 0, 0, 0 ];
	remap_scale    = [ 1, 1, 1 ];
	
	attributes.bakedUV     = false;
	attributes.bakedUVdata = [];
	
	modify_object_index = 0;
	
	static modify_object = function(_object, _data, _matrix) {
		if(_object.VF != global.VF_POS_NORM_TEX_COL) return _object;
		
		var _obj = _object.clone(false, false);
		_obj.VB  = [];
		_obj.transform.submitMatrix();
		_obj.transform.clearMatrix();
		
		var _mat = _matrix.Mul(_obj.transform.matrix);
		var _fil = _data[in_d3d + 1];
		if(_fil != -1 && !is_array(_fil)) _fil = [ _fil ];
		
		var _vertex_index = 0;
		if(!attributes.bakedUV) attributes.bakedUVdata[modify_object_index] = [];
		var _baked_vertex = attributes.bakedUVdata[modify_object_index];
		
		for( var i = 0, n = array_length(_object.VB); i < n; i++ ) {
			if(_fil != -1 && !array_exists(_fil, i)) {
				_obj.VB[i] = _object.VB[i];
				continue;
			}
			
			var vb   = _object.VB[i];
			var len  = vertex_get_number(vb);
			var buff = buffer_create_from_vertex_buffer(vb, buffer_grow, 1);
			buffer_seek(buff, buffer_seek_start, 0);
			
			for( var j = 0; j < len; j++ ) {
				var _x = buffer_read(buff, buffer_f32); // 4
				var _y = buffer_read(buff, buffer_f32); // 4
				var _z = buffer_read(buff, buffer_f32); // 4
				
				var _nx = buffer_read(buff, buffer_f32); // 4
				var _ny = buffer_read(buff, buffer_f32); // 4
				var _nz = buffer_read(buff, buffer_f32); // 4
				
				var _u = buffer_read(buff, buffer_f32); // 4
				var _v = buffer_read(buff, buffer_f32); // 4
				
				var _r = buffer_read(buff, buffer_u8); // 1
				var _g = buffer_read(buff, buffer_u8); // 1
				var _b = buffer_read(buff, buffer_u8); // 1
				var _a = buffer_read(buff, buffer_u8); // 1
				
				var _v4 = new BBMOD_Vec4(_x, _y, _z, 1);
				var _vt = _mat.Transform(_v4);
				
				if(attributes.bakedUV) {
					_posOnMap = _baked_vertex[_vertex_index];
				} else {
					var _posOnMap = d3d_point_project_plane_uv(remap_position, remap_normal, [_vt.X, _vt.Y, _vt.Z], remap_normal_x, remap_normal_y);
					_posOnMap[0] = _posOnMap[0] / remap_scale[0] + 0.5;
					_posOnMap[1] = _posOnMap[1] / remap_scale[1] + 0.5;
					_baked_vertex[_vertex_index] = _posOnMap;
				}
				
				buffer_seek(buff, buffer_seek_relative, -12);
				
				buffer_write(buff, buffer_f32, _posOnMap[0]);
				buffer_write(buff, buffer_f32, _posOnMap[1]);
				
				buffer_seek(buff, buffer_seek_relative, 4);
				_vertex_index++;
			}
			
			_obj.VB[i] = vertex_create_buffer_from_buffer(buff, global.VF_POS_NORM_TEX_COL);
		}
		
		modify_object_index++;
		return _obj;
	}
	
	static modify_group = function(_group, _data, _matrix) {
		var _gr = new __3dGroup();
		
		_gr.transform = _group.transform.clone();
		_gr.transform.submitMatrix();
		_gr.transform.clearMatrix();
		_matrix = _matrix.Mul(_gr.transform.matrix);
		
		for( var i = 0, n = array_length(_group.objects); i < n; i++ )
			_gr.objects[i] = modify(_group.objects[i], _data, _matrix);
		
		return _gr;
	}
	
	static modify = function(_object, _data, _matrix = new BBMOD_Matrix()) {
		if(is_instanceof(_object, __3dObject)) return modify_object(_object, _data, _matrix);
		if(is_instanceof(_object, __3dGroup))  return modify_group(_object, _data, _matrix);
		
		return noone;
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		b_bake_uv.text = attributes.bakedUV? "Unbake UV" : "Bake UV";
		setTransform(gizmo, _data);
		
		var _rot     = _data[1];
		var _prot    = new BBMOD_Quaternion(_rot[0], _rot[1], _rot[2], _rot[3]);
		remap_normal   = _prot.Rotate(new BBMOD_Vec3(0, 0, 1)).ToArray();
		remap_normal_x = _prot.Rotate(new BBMOD_Vec3(1, 0, 0)).ToArray();
		remap_normal_y = _prot.Rotate(new BBMOD_Vec3(0, -1, 0)).ToArray();
				
		remap_position = _data[0];
		remap_scale    = _data[2];
		
		modify_object_index = 0;
		return modify(_data[in_d3d + 0], _data);
	}
	
	static getPreviewObjects       = function() { return [ getPreviewObject(), gizmo ]; } 
	static getPreviewObjectOutline = function() { return [ gizmo ]; } 
}