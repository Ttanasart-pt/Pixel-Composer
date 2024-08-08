function Node_3D_Set_Material(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "Set Material";
	
	inputs[in_mesh + 0] = nodeValue_D3Material("Materials", self, new __d3dMaterial())
		.setVisible(true, true)
		.setArrayDepth(1);
	
	inputs[in_mesh + 1] = nodeValue_Bool("Single material", self, true)
	
	static preGetInputs = function() { #region
		var _sing = inputs[in_mesh + 1].getValue();
		inputs[in_mesh + 0].setArrayDepth(_sing? 0 : 1);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _obj = _data[0];
		var _mat = _data[in_mesh + 0];
		
		if(!is_instanceof(_obj, __3dObject)) return noone;
		if(!is_array(_mat)) _mat = [ _mat ];
		
		var _res = _obj.clone(false);
		
		if(array_length(_mat) != array_length(_obj.materials))
			array_resize(_mat, array_length(_obj.materials));
			
		_res.vertex    = _obj.vertex;
		_res.VB        = _obj.VB;
		_res.materials = _mat;
		
		return _res;
	} #endregion
	
	static getPreviewValues = function() { #region
		var _sing = getSingleValue(in_mesh + 1);
		
		var res = array_safe_get_fast(all_inputs, in_mesh + 0, noone);
		if(_sing) return res; 
		
		var _r = array_create(array_length(res));
		for( var i = 0, n = array_length(res); i < n; i++ ) 
			_r[i] = array_safe_get_fast(res[i], 0);
		return _r;
	} #endregion
}