function Node_3D_Mesh_Path_Extrude(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "Path Extrude";
	object_class = __3dPathExtrude;
	
	var i = in_mesh;
	
	////- =Path
	newInput(i+ 0, nodeValue_PathNode(   "Path"              ));
	newInput(i+13, nodeValue_Float(      "Path Scale", .1    ));
	newInput(i+10, nodeValue_Bool(       "Loop",       false ));
	
	////- =Mesh
	newInput(i+ 6, nodeValue_Int(        "Subdivision",       8                   )).setValidator(VV_min(2));
	newInput(i+ 1, nodeValue_Int(        "Side",              8                   )).setValidator(VV_min(2));
	newInput(i+12, nodeValue_Rotation(   "Profile Angle",     0                   ));
	newInput(i+ 7, nodeValue_Float(      "Radius",           .25                  ));
	newInput(i+ 8, nodeValue_Curve(      "Radius Over Path",  CURVE_DEF_11        ));
	newInput(i+ 5, nodeValue_Bool(       "End caps",          true                ));
	newInput(i+11, nodeValue_Bool(       "Inverted",          false               ));
	
	////- =Material
	newInput(i+ 4, nodeValue_Bool(       "Smooth",            false               ));
	newInput(i+ 2, nodeValue_D3Material( "Material Side",     new __d3dMaterial() ));
	newInput(i+ 3, nodeValue_D3Material( "Material Cap",      new __d3dMaterial() ));
	newInput(i+ 9, nodeValue_Vec2(       "Texture Scale",    [1,1]                ));
	// input i+14
	
	input_display_list = [
		["Path",		false], 	i+0, i+13,i+10,
		__d3d_input_list_mesh,		i+6, i+1, i+12, i+7, i+8, i+5, i+11, 
		__d3d_input_list_transform,
		["Material",	false], 	i+4, i+2, i+3, i+9, 
	]
	
	////- Nodes
	
	static processData = function(_output, _data, _array_index = 0) {
		var _path    = _data[in_mesh +  0];
		var _pathSca = _data[in_mesh + 13];
		var _loop    = _data[in_mesh + 10];
		
		var _samp    = _data[in_mesh +  6] + 1;
		var _sides   = _data[in_mesh +  1];
		var _pfrot   = _data[in_mesh + 12];
		var _rad     = _data[in_mesh +  7];
		var _radOv   = _data[in_mesh +  8];
		var _caps    = _data[in_mesh +  5];
		var _invert  = _data[in_mesh + 11];
		
		var _smt     = _data[in_mesh +  4];
		var _mat_sid = _data[in_mesh +  2];
		var _mat_cap = _data[in_mesh +  3];
		var _uvScale = _data[in_mesh +  9];
		
		inputs[in_mesh + 3].setVisible(_caps, _caps);
		if(_path == noone) return noone;
		
		var _points  = array_create(_samp * 3);
		var _radPath = array_create(_samp);
		var _uvProg  = array_create(_samp);
		
		var _distTotal = 0;
		var _stp = 1 / (_samp - 1);
		var _p   = new __vec3();
		
		for(var i = 0; i < _samp; i++) {
			var _prg = _stp * i;
			_p = _path.getPointRatio(_prg, 0, _p);
			
			_points[i * 3 + 0] = _p.x * _pathSca;
			_points[i * 3 + 1] = _p.y * _pathSca;
			_points[i * 3 + 2] = _p.z * _pathSca;
			
			_radPath[i] = eval_curve_x(_radOv, _prg);
			
			if(i) {
				var _d = point_distance_3d(_points[i * 3 - 3 + 0], _points[i * 3 - 3 + 1], _points[i * 3 - 3 + 2], 
				                           _points[i * 3 + 0], _points[i * 3 + 1], _points[i * 3 + 2]);
				_distTotal += _d;
				_uvProg[i]  = _distTotal;
			}
		}
		
		for (var i = 0; i < _samp; i++) 
			_uvProg[i] /= _distTotal;
		_uvProg[_samp] = 1;
		
		var object = getObject(_array_index);
		object.checkParameter({ 
			sides  : _sides, 
			endCap : _caps,
			smooth : _smt, 
			points : _points, 
			radius : _rad, 
			radiusOverPath: _radPath, 
			loop   : _loop,
			invert : _invert,
			yaw    : _pfrot,
			
			uvProg  : _uvProg, 
			uvScale : _uvScale,
		});
		
		object.materials = _caps? [ _mat_sid, _mat_cap, _mat_cap ] : [ _mat_sid ];
		
		setTransform(object, _data);
		
		return object;
	}
	
	static getPreviewValues = function() { return getSingleValue(in_mesh + 2); }
}