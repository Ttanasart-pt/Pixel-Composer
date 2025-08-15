function Node_3D_Instancer(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "3D Instancer";
	
	var i = in_mesh;
	newInput(i+8, nodeValueSeed());
	newInput(i+0, nodeValue_Int("Amounts", 1));
	
	////- =Transform Data
	newInput(i+1, nodeValue_Vec3("Positions", [[0,0,0]] )).setArrayDepth(1);
	newInput(i+2, nodeValue_Vec3("Rotations", [[0,0,0]] )).setArrayDepth(1);
	newInput(i+3, nodeValue_Vec3("Scales",    [[1,1,1]] )).setArrayDepth(1);
	newInput(i+4, nodeValue_Vec3("Normal",    [[0,0,0]] )).setArrayDepth(1);
	
	////- =Scatter
	newInput(i+5, nodeValue_Vec3_Range("Position Scatter", array_create(6,0) ));
	newInput(i+6, nodeValue_Vec3_Range("Rotation Scatter", array_create(6,0) ));
	newInput(i+7, nodeValue_Vec3_Range("Scale Scatter",    array_create(6,1) ));
	newInput(i+9, nodeValue_Bool("Scale Uniform",    true ));
	
	////- =Scatter
	newInput(i+10, nodeValue_Gradient("Colors", new gradientObject(ca_white) ));
	// i+11
	
	input_display_list = [ 0, i+8, i+0,
		[ "Transform Data", false ], i+1, i+2, i+3, i+4, 
		[ "Scatter", false ], i+5, i+6, i+7, i+9, 
		[ "Render",  false ], i+10, 
	];
	
	static processData = function(_output, _data, _array_index = 0) {
		var _obj = _data[0];
		if(!is_instanceof(_obj, __3dObject))		return noone;
		if(_obj.VF != global.VF_POS_NORM_TEX_COL)	return noone;
		
		#region data
			var _seed = _data[in_mesh + 8];
			var _amo  = _data[in_mesh + 0]; if(_amo <= 0) return noone;
			
			var _poss = _data[in_mesh + 1];
			var _rots = _data[in_mesh + 2];
			var _scas = _data[in_mesh + 3];
			var _nors = _data[in_mesh + 4];
			
			var _posh = _data[in_mesh + 5];
			var _roth = _data[in_mesh + 6];
			var _scah = _data[in_mesh + 7];
			var _scauni = _data[in_mesh + 9];
			
			var _grad = _data[in_mesh + 10]; _grad.cache();
		#endregion
			
		#region base instancer
			var _res = new __3dObjectInstancer();
			
			_res.instance_amount = _amo;
			_res.render_type     = _obj.render_type;
			_res.custom_shader   = _obj.custom_shader;
			_res.size            = _obj.size.clone();
			_res.materials       = _obj.materials;
			_res.material_index  = _obj.material_index;
			_res.texture_flip    = _obj.texture_flip;
			_res.vertex          = _obj.vertex;
			_res.objectTransform = _obj.transform;
			
			_res.objectTransform.applyMatrix();
			
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
			
			var _posl = array_length(_poss);
			var _rotl = array_length(_rots);
			var _scal = array_length(_scas);
			var _norl = array_length(_nors);
			
			random_set_seed(_seed);
			
			repeat(_amo) {
				random_set_seed(_seed + _i * 78);
				
				var gradI = random(1);
				var cc = _grad.evalFast(gradI);
				
				var _p = array_safe_get_fast(_poss, _i % _posl, [0,0,0]);
				var _r = array_safe_get_fast(_rots, _i % _rotl, [0,0,0]);
				var _s = array_safe_get_fast(_scas, _i % _scal, [1,1,1]);
				var _n = array_safe_get_fast(_nors, _i % _norl, [0,0,0]);
				
				buffer_write(_buffer, buffer_f32, _p[0] + random_range(_posh[0], _posh[3])); // pos X 
				buffer_write(_buffer, buffer_f32, _p[1] + random_range(_posh[1], _posh[4])); // pos Y 
				buffer_write(_buffer, buffer_f32, _p[2] + random_range(_posh[2], _posh[5])); // pos Z
				buffer_write(_buffer, buffer_f32, _color_get_r(cc));
				
				buffer_write(_buffer, buffer_f32, _r[0] + random_range(_roth[0], _roth[3])); // rot X 
				buffer_write(_buffer, buffer_f32, _r[1] + random_range(_roth[1], _roth[4])); // rot Y 
				buffer_write(_buffer, buffer_f32, _r[2] + random_range(_roth[2], _roth[5])); // rot Z
				buffer_write(_buffer, buffer_f32, _color_get_g(cc));
				
				var _sx = random_range(_scah[0], _scah[3]);
				var _sy = _scauni? _sx : random_range(_scah[1], _scah[4]);
				var _sz = _scauni? _sx : random_range(_scah[2], _scah[5]);
				
				buffer_write(_buffer, buffer_f32, _s[0] * _sx); // sca X 
				buffer_write(_buffer, buffer_f32, _s[1] * _sy); // sca Y 
				buffer_write(_buffer, buffer_f32, _s[2] * _sz); // sca Z
				buffer_write(_buffer, buffer_f32, _color_get_b(cc));
				
				buffer_write(_buffer, buffer_f32, _n[0]); // norm X
				buffer_write(_buffer, buffer_f32, _n[1]); // norm Y
				buffer_write(_buffer, buffer_f32, _n[2]); // norm Z
				buffer_write(_buffer, buffer_f32, 0);
				
				_i++;
			}
			
			_res.setBuffer(_buffer);
			buffer_delete(_buffer);
			
		#endregion
		
		return _res;
	}
}