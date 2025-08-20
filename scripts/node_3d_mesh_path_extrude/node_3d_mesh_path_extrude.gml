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
		
		var _samp    = _data[in_mesh +  6];
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
		
		if(_loop) _caps = false;
		
		var _pathAmo = _path.getLineCount();
		var _points  = array_create(_pathAmo);
		var _uvProg  = array_create(_pathAmo);
		var _radPath = array_create(_samp);
		
		var _stp = 1 / (_samp - 1);
		var _p   = new __vec3();
		
		for( var p = 0; p < _pathAmo; p++ ) {
			var __points  = array_create(_samp * 3);
			var __uvProg  = array_create(_samp);
			var _distTotal = 0;
			
			for(var i = 0; i < _samp; i++) {
				var _prg = _stp * i;
				if(!_loop) _prg = clamp(_prg, 0, 0.999);
				
				_p = _path.getPointRatio(_prg, p, _p);
				
				var _pointId = i * 3;
				__points[_pointId + 0] = _p.x * _pathSca;
				__points[_pointId + 1] = _p.y * _pathSca;
				__points[_pointId + 2] = _p.z * _pathSca;
				
				if(i) {
					var _d = point_distance_3d(__points[_pointId - 3 + 0], __points[_pointId - 3 + 1], __points[_pointId - 3 + 2], 
					                           __points[_pointId     + 0], __points[_pointId     + 1], __points[_pointId     + 2]);
					_distTotal += _d;
					__uvProg[i] = _distTotal;
				}
			}
			
			for (var i = 0; i < _samp; i++) __uvProg[i]  /= _distTotal;
			__uvProg[_samp] = 1;
			
			_points[p] = __points;
			_uvProg[p] = __uvProg;
		}
		
		for (var i = 0; i < _samp; i++)
			_radPath[i] = eval_curve_x(_radOv, _stp * i);
		
		var object = getObject(_array_index);
		object.checkParameter({ 
			sides  : _sides, 
			endCap : _caps,
			smooth : _smt, 
			
			pathAmount : _pathAmo, 
			points : _points, 
			radius : _rad, 
			radiusOverPath: _radPath, 
			loop   : _loop,
			invert : _invert,
			yaw    : _pfrot,
			
			uvProg  : _uvProg, 
			uvScale : _uvScale,
		});
		
		object.materials = [ _mat_sid, _mat_cap ];
		
		setTransform(object, _data);
		
		return object;
	}
	
	static getPreviewValues = function() { return getSingleValue(in_mesh + 2); }
}