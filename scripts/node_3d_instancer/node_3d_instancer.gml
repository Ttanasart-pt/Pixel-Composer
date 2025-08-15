function Node_3D_Instancer(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "3D Instancer";
	
	var i = in_mesh;
	newInput(i+0, nodeValue_Int("Amounts", 1));
	
	////- =Transforms
	newInput(i+1, nodeValue_Vec3("Positions", [[0,0,0]] )).setArrayDepth(1);
	
	input_display_list = [ 0, i+0,
		["Transforms", false], i+1,
	];
	
	static processData = function(_output, _data, _array_index = 0) {
		var _obj = _data[0];
		if(!is_instanceof(_obj, __3dObject))		return noone;
		if(_obj.VF != global.VF_POS_NORM_TEX_COL)	return noone;
		
		var _amo  = _data[in_mesh + 0]; if(_amo <= 0) return noone;
		var _poss = _data[in_mesh + 1];
		
		var _res = new __3dObjectInstancer();
		
		#region data
			_res.instance_amount = _amo;
			_res.render_type    = _obj.render_type;
			_res.custom_shader  = _obj.custom_shader;
			_res.transform      = _obj.transform.clone();
			_res.size           = _obj.size.clone();
			_res.materials      = _obj.materials;
			_res.material_index = _obj.material_index;
			_res.texture_flip   = _obj.texture_flip;
			_res.vertex         = _obj.vertex;
			
			_res.VF  = _obj.VF;
			_res.VBM = _obj.VBM;
			
			_res.VB = [];
			for( var i = 0, n = array_length(_obj.VB); i < n; i++ ) {
				_res.VB[i] = vertex_buffer_clone(_obj.VB[i], _obj.VF);
				vertex_freeze(_res.VB[i]);
			}
		#endregion
		
		#region constant buffer
			var _buffer = buffer_create(1, buffer_grow, 1);
			var _i = 0;
			
			repeat(_amo) {
				var _p = array_safe_get_fast(_poss, _i, [0,0,0]);
				
				buffer_write(_buffer, buffer_f32, _p[0]); // pos X 
				buffer_write(_buffer, buffer_f32, _p[1]); // pos Y 
				buffer_write(_buffer, buffer_f32, _p[2]); // pos Z
				buffer_write(_buffer, buffer_f32, 0);
				
				buffer_write(_buffer, buffer_f32, 0); // rot X 
				buffer_write(_buffer, buffer_f32, 0); // rot Y 
				buffer_write(_buffer, buffer_f32, 0); // rot Z
				buffer_write(_buffer, buffer_f32, 0);
				
				buffer_write(_buffer, buffer_f32, 1); // sca X 
				buffer_write(_buffer, buffer_f32, 1); // sca Y 
				buffer_write(_buffer, buffer_f32, 1); // sca Z
				buffer_write(_buffer, buffer_f32, 0);
				
				buffer_write(_buffer, buffer_f32, 0);
				buffer_write(_buffer, buffer_f32, 0);
				buffer_write(_buffer, buffer_f32, 0);
				buffer_write(_buffer, buffer_f32, 0);
				
				_i++;
			}
			
			_res.setBuffer(_buffer);
			buffer_delete(_buffer);
			
		#endregion
		
		return _res;
	}
}