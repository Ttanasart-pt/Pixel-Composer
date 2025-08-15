function Node_3D_Instancer(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "3D Instancer";
	
	newInput(in_mesh + 0, nodeValue_Int("Amounts", 1));
	
	static processData = function(_output, _data, _array_index = 0) {
		var _obj = _data[0];
		if(!is_instanceof(_obj, __3dObject))		return noone;
		if(_obj.VF != global.VF_POS_NORM_TEX_COL)	return noone;
		
		var _amo = _data[in_mesh + 0];
		if(_amo <= 0) return noone;
		
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
			d3d11_cbuffer_begin();
			d3d11_cbuffer_add_float(4 * _amo);
			_res.instance_data = d3d11_cbuffer_end();
			if (!d3d11_cbuffer_exists(_res.instance_data)) noti_warning("Could not create instanceData!");
			
			var _buffer = buffer_create(d3d11_cbuffer_get_size(_res.instance_data), buffer_fixed, 1);
			
			repeat(_amo) {
				buffer_write(_buffer, buffer_f32, random_range(-10, 10)); 
				buffer_write(_buffer, buffer_f32, random_range(-10, 10)); 
				buffer_write(_buffer, buffer_f32, random_range(-10, 10));
				buffer_write(_buffer, buffer_f32, 0);
				
				buffer_write(_buffer, buffer_f32, 0);
				buffer_write(_buffer, buffer_f32, 0);
				buffer_write(_buffer, buffer_f32, random_range(0, 360));
				buffer_write(_buffer, buffer_f32, 0);
				
				var _sc = random_range(.3, 1);
				
				buffer_write(_buffer, buffer_f32, _sc);
				buffer_write(_buffer, buffer_f32, _sc);
				buffer_write(_buffer, buffer_f32, _sc);
				buffer_write(_buffer, buffer_f32, 0);
				
				buffer_write(_buffer, buffer_f32, 0);
				buffer_write(_buffer, buffer_f32, 0);
				buffer_write(_buffer, buffer_f32, 0);
				buffer_write(_buffer, buffer_f32, 0);
			}
			
			d3d11_cbuffer_update(_res.instance_data, _buffer);
			buffer_delete(_buffer);
		#endregion
		
		return _res;
	}
}