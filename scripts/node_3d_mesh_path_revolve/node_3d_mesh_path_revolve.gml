function Node_3D_Mesh_Path_Revolve(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "Path Revolve";
	object_class = __3dPathRevolve;
	
	var i = in_mesh;
	
	////- =Path
	
	newInput(i+ 0, nodeValue_PathNode( "Path" ));
	newInput(i+ 9, nodeValue_Float(    "Path Scale", .25 ));
	
	////- =Mesh
	
	newInput(i+ 1, nodeValue_Enum_Button( "Revolve Axis",      0, [ "X", "Y", ]      ));
	newInput(i+ 2, nodeValue_Vec2(        "Revolve Origin",   [0,0]                  ));
	newInput(i+ 3, nodeValue_Toggle(      "Caps",              0, [ "Start", "End" ] ));
	
	newInput(i+ 4, nodeValue_Int(         "Path Sample",       8 )).setValidator(VV_min(2));
	newInput(i+ 5, nodeValue_Int(         "Revolve Sample",    8 )).setValidator(VV_min(3));
	
	////- =Material
	
	newInput(i+ 6, nodeValue_Bool(       "Smooth",            false               ));
	newInput(i+ 7, nodeValue_D3Material( "Material Side",     new __d3dMaterial() ));
	newInput(i+ 8, nodeValue_D3Material( "Material Cap",      new __d3dMaterial() ));
	
	// input i + 10
	
	input_display_list = [
		["Path",		false], 	i+0, i+9, 
		__d3d_input_list_mesh,		i+3, i+4, i+5, 
		__d3d_input_list_transform,
		["Material",	false], 	i+6, i+7, i+8, 
	]
	
	////- Nodes
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _path = _data[in_mesh +  0];
		var _pSca = _data[in_mesh +  9];
		
		var _axis = _data[in_mesh +  1];
		var _orig = _data[in_mesh +  2];
		var _caps = _data[in_mesh +  3];
		
		var _psam = _data[in_mesh +  4];
		var _rsam = _data[in_mesh +  5];
		
		var _smt  = _data[in_mesh +  6];
		var _mSid = _data[in_mesh +  7];
		var _mCap = _data[in_mesh +  8];
		
		if(_path == noone) return noone;
		
		var _stp    = 1 / (_psam - 1);
		var _points = array_create(_psam + 1);
		var _p      = new __vec2();
		
		for( var i = 0; i <= _psam; i++ ) {
			var _prg = _stp * i;
			_p = _path.getPointRatio(_prg, 0, _p);
			_points[i] = [ _p.x * _pSca, _p.y * _pSca ];
		}
		
		var object = getObject(_array_index);
		object.checkParameter({ 
			origin: _orig, 
			points: _points,
			sides:  _rsam, 
			caps:   _caps, 
			
			smooth: _smt,
		});
		
		
		object.materials = [ _mSid ];
		if(_caps & 0b01) array_push(object.materials, _mCap);
		if(_caps & 0b10) array_push(object.materials, _mCap);
		
		setTransform(object, _data);
		
		return object;
	}
	
}