function Node_3D_Instancer(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "3D Instancer";
	
	newInput(in_mesh + 0, nodeValue_Int("Amounts", self, 1));
	
	newInput(in_mesh + 1, nodeValue_Vec3("Positions", self, [ 0, 0, 0 ]))
		.setArrayDepth(1);
	
	static processData = function(_output, _data, _array_index = 0) {
		var _obj = _data[0];
		if(!is_instanceof(_obj, __3dObject))		return noone;
		if(_obj.VF != global.VF_POS_NORM_TEX_COL)	return noone;
		
		var _amo = _data[in_mesh + 0];
		var _pos = _data[in_mesh + 1];
		
		if(_amo <= 0) return noone;
		var _res = new __3dObjectInstancer();
		
		_res.object_counts  = max(1, _amo);
		_res.positions      = _pos;
		
		_res.vertex = _obj.vertex;
		_res.VB     = _obj.VB;
		_res.render_type    = _obj.render_type;
		_res.custom_shader  = _obj.custom_shader;
		_res.transform      = _obj.transform.clone();
		_res.size           = _obj.size.clone();
		_res.materials      = _obj.materials;
		_res.material_index = _obj.material_index;
		_res.texture_flip   = _obj.texture_flip;
		
		_res.setData();
		
		return _res;
	}
}