function Node_3D_Set_Material(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "Set Material";
	
	var i = in_mesh;
	
	newInput( i+4, nodeValueSeed());
	
	////- =Material
	newInput( i+0, nodeValue_3DMat( "Materials" )).setVisible(true, true).setArrayDepth(1);
	
	////- =Array
	newInput( i+1, nodeValue_Bool(    "Single Material", true ));
	newInput( i+3, nodeValue_EScroll( "Select",   0, ["Ordered","Random"]     ));
	newInput( i+2, nodeValue_EScroll( "Overflow", 0, ["Keep Original","Loop"] ));
	// i+5
	
	input_display_list = [ i+4, 0, 
		[ "Material", false ], i+0, 
		[ "Array",    false ], i+1, i+3, i+2, 
	]
	
	////- Node
	
	static preGetInputs = function() {
		var i = in_mesh;
		var _sing = inputs[i+1].getValue();
		
		inputs[i+0].setArrayDepth(_sing? 0 : 1);
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var _obj = _data[0];
			
			var _seed = _data[in_mesh + 4];
			var _mat  = _data[in_mesh + 0];
			
			var _sing = _data[in_mesh + 1];
			var _selt = _data[in_mesh + 3];
			var _over = _data[in_mesh + 2];
			
			inputs[in_mesh + 2].setVisible(_selt == 0);
			if(_selt == 1) _over = -1;
		#endregion
		
		if(!is(_obj, __3dInstance)) return noone;
		if(!is_array(_mat)) _mat = [ _mat ];
		
		random_set_seed(_seed);
		
		var _res = _obj.clone(false);
		var inMatLen = array_length(_mat);
		
		if(is(_res, __3dGroup)) {
			for( var i = 0, n = array_length(_res.objects); i < n; i++ ) {
				var _gobj = _res.objects[i];
				var _gmat = _gobj.getMaterials();
				
				if(!array_empty(_gmat)) {
					var _rmat = undefined;
					
					switch(_over) {
						case -1 : _rmat = array_get_random(_mat);           break;
						case  0 : _rmat = i < inMatLen? _mat[i] : _gmat[0]; break;
						case  1 : _rmat = _mat[i % inMatLen];               break;
					}
					
					if(is_array(_rmat)) {
						for( var j = 0, m = min(array_length(_gmat), array_length(_rmat)); j < m; j++ ) 
							_gmat[j] = _rmat[j];
							
					} else {
						for( var j = 0, m = array_length(_gmat); j < m; j++ ) 
							_gmat[j] = _rmat;
					}
				}
			}
			
		} else {
			var otMatLen = array_length(_obj.materials);
			var _newMat  = [];
			
			for( var i = 0; i < otMatLen; i++ ) {
				_newMat[i] = _obj.materials[i];
				
				switch(_over) {
					case -1 : _newMat[i] = array_get_random(_mat);                    break;
					case  0 : _newMat[i] = i < inMatLen? _mat[i] : _obj.materials[i]; break;
					case  1 : _newMat[i] = _mat[i % inMatLen]                         break;
				}
			}
			
			_res.vertex    = _obj.vertex;
			_res.VB        = _obj.VB;
			_res.materials = _newMat;
		}
		
		return _res;
	}
	
	static getPreviewValues = function() {
		var res = getInputSingle(in_mesh + 0);
		var sng = getInputSingle(in_mesh + 1);
		if(sng) return res; 
		
		var _r = array_create(array_length(res));
		for( var i = 0, n = array_length(res); i < n; i++ ) 
			_r[i] = array_safe_get_fast(res[i], 0);
		return _r;
	}
}