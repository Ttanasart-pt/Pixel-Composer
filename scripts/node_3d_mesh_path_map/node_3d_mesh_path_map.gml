function Node_3D_Mesh_Path_Map(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "Path Map 3D";
	object_class = __3dPathMap;
	
	var i = in_mesh;
	
	////- =Mesh
	newInput(i+ 1, nodeValue_Int(   "Path Sample",   8     )).setValidator(VV_min(2));
	newInput(i+ 2, nodeValue_Int(   "Subdivision",   1     )).setValidator(VV_min(1));
	
	////- =Material
	newInput(i+ 3, nodeValue_Bool(  "Smooth",        false ));
	newInput(i+ 5, nodeValue_3DMat( "Material"             ));
	newInput(i+ 4, nodeValue_Bool(  "Invert Normal", false ));
	
	////- =Path
	newInput(i+ 0, nodeValue_Float( "Path Scale",    .25   ));
	newInput(i+ 6, nodeValue_Bool(  "Path Loop",     false ));
	// input i+ 6
	
	input_display_list = [
		__d3d_input_list_mesh, i+ 1, i+ 2, 
		__d3d_input_list_transform,
		[ "Material", false ], i+ 5, i+ 4,  
		[ "Path",     false ], i+ 0, i+ 6, 
	]
	
	function createNewInput(index = array_length(inputs)) {
		newInput(index, nodeValue_Path( "Path" )).setVisible(true, true);
		
		array_push(input_display_list, index);
		postCreateNewInput(index);
		return inputs[index];
	} setDynamicInput(1);
	
	////- Nodes
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var i = in_mesh;
			
			var _psam = _data[i+ 1];
			var _subd = _data[i+ 2];
			
			var _smth = _data[i+ 3];
			var _mat  = _data[i+ 5];
			var _invn = _data[i+ 4];
			
			var _psca = _data[i+ 0];
			var _loop = _data[i+ 6];
			
		#endregion
		
		var _pamo = getInputAmount();
		if(_pamo < 2) return noone;
		
		var _p  = new __vec3P();
		var stp = 1 / (_psam - !_loop);
		var ind = 0;
		
		var _points = array_create(_psam * _pamo);
		
		for( var p = 0; p < _pamo; p++ ) {
			var _path = _data[input_fix_len + p];
			var  sind = ind;
			
			for( var i = 0; i < _psam; i++ ) {
				var _prg = stp * i;
				    _prg = clamp(_prg, 0., .99);
				
				_p = _path.getPointRatio(_prg, 0, _p);
				_points[ind++] = [ _p.x * _psca, _p.y * _psca, _p.z * _psca ]; 
			}
			
			if(_loop) _points[ind++] = _points[sind]; 
		}
		
		var object = getObject(_array_index);
		object.checkParameter({ 
			points:    _points,
			pathCount: _pamo,
			pathSubd:  _psam + _loop,
			subdivide: _subd,
			
			invertNorm:_invn,
			smooth:    _smth,
		});
		
		object.materials = [ _mat ];
		
		setTransform(object, _data);
		
		return object;
	}
	
}