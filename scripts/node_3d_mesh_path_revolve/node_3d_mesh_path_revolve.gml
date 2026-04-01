function Node_3D_Mesh_Path_Revolve(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "Path Revolve";
	object_class = __3dPathRevolve;
	
	var i = in_mesh;
	
	////- =Path
	newInput(i+ 0, nodeValue_PathNode( "Path" ));
	newInput(i+ 9, nodeValue_Float(    "Path Scale",    .25    ));
	newInput(i+10, nodeValue_EButton(  "Project Normal", 2, [ "X", "Y", "Z" ]    ));
	newInput(i+11, nodeValue_Bool(     "Invert Y",       false ));
	
	////- =Mesh
	newInput(i+ 1, nodeValue_EButton(  "Revolve Axis",     0, [ "X", "Y" ]       ));
	newInput(i+ 2, nodeValue_Vec2(     "Revolve Origin",  [0,0]                  ));
	newInput(i+ 3, nodeValue_Toggle(   "Caps",             0, [ "Start", "End" ] ));
	
	newInput(i+ 4, nodeValue_Int(      "Path Sample",     8 )).setValidator(VV_min(2));
	newInput(i+ 5, nodeValue_Int(      "Revolve Sample",  8 )).setValidator(VV_min(3));
	
	////- =Material
	newInput(i+ 6, nodeValue_Bool(       "Smooth",        false ));
	newInput(i+12, nodeValue_Bool(       "Invert Normal", false ));
	newInput(i+ 7, nodeValue_D3Material( "Material Side", new __d3dMaterial() ));
	newInput(i+ 8, nodeValue_D3Material( "Material Cap",  new __d3dMaterial() ));
	// input i+13
	
	input_display_list = [
		[ "Path",     false ], i+ 0, i+ 9, i+10, i+11, 
		__d3d_input_list_mesh, i+ 3, i+ 4, i+ 5, 
		__d3d_input_list_transform,
		[ "Material", false ], i+ 6, i+12, i+ 7, i+ 8, 
	]
	
	////- Nodes
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var i = in_mesh;
			
			var _path = _data[i+ 0];
			var _pSca = _data[i+ 9];
			var _pAxs = _data[i+10];
			var _yInv = _data[i+11];
			
			var _axis = _data[i+ 1];
			var _orig = _data[i+ 2];
			var _caps = _data[i+ 3];
			
			var _psam = _data[i+ 4];
			var _rsam = _data[i+ 5];
			
			var _smt  = _data[i+ 6];
			var _nInv = _data[i+12];
			var _mSid = _data[i+ 7];
			var _mCap = _data[i+ 8];
			
			if(_path == noone) return noone;
		#endregion
		
		var _stp    = 1 / (_psam - 1);
		var _points = array_create(_psam + 1);
		var _p      = new __vec3();
		
		for( var i = 0; i <= _psam; i++ ) {
			var _prg = _stp * i;
			_p = _path.getPointRatio(_prg, 0, _p);
			
			switch(_pAxs) {
				case 0: _points[i] = [ _p.y * _pSca, _p.z * _pSca ]; break;
				case 1: _points[i] = [ _p.x * _pSca, _p.z * _pSca ]; break;
				case 2: _points[i] = [ _p.x * _pSca, _p.y * _pSca ]; break;
			}
			
			if(_yInv) _points[i][1] = -_points[i][1];
		}
		
		if(_nInv) _points = array_reverse(_points);
		var object = getObject(_array_index);
		object.checkParameter({ 
			origin: _orig, 
			points: _points,
			sides:  _rsam, 
			caps:   _caps, 
			axis:   _axis, 
			
			smooth: _smt,
		});
		
		object.materials = [ _mSid ];
		if(_caps & 0b01) array_push(object.materials, _mCap);
		if(_caps & 0b10) array_push(object.materials, _mCap);
		
		setTransform(object, _data);
		
		return object;
	}
	
}