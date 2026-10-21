function Node_3D_Mesh_Path_Extrude(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "Path Extrude 3D";
	object_class = __3dPathExtrude;
	
	var i = in_mesh;
	
	////- =Path
	newInput(i+ 0, nodeValue_Path(  "Path"              )).setExtractNode(["Node_Path_3D", "Node_Path_Shape_3D"]);
	newInput(i+13, nodeValue_Float( "Path Scale", .1    ));
	newInput(i+10, nodeValue_Bool(  "Loop",       false ));
	
	////- =Mesh
	newInput(i+ 6, nodeValue_Int(   "Subdivision",    8  )).setValidator(VV_min(2));
	newInput(i+ 1, nodeValue_Int(   "Side",           8  )).setValidator(VV_min(2));
	newInput(i+12, nodeValue_Rot(   "Profile Angle",  0  ));
	newInput(i+ 7, nodeValue_Float( "Radius",        .25 ))
		.setCurvable(i+ 8, CURVE_DEF_11, "Over Path",   "curved",       THEME.curvable)
		.setCurvable(i+15, CURVE_DEF_11, "Over Weight", "curve_weight", THEME.mk_tree_curve_length)
	newInput(i+16, nodeValue_Range( "Weight Range",   [0,1] ));
		
	newInput(i+ 5, nodeValue_Bool(  "End caps",       true  ));
	newInput(i+11, nodeValue_Bool(  "Inverted",       false ));
	
	////- =Material
	newInput(i+ 4, nodeValue_Bool(  "Smooth",         false ));
	newInput(i+ 2, nodeValue_3DMat( "Material Side"         ));
	newInput(i+ 3, nodeValue_3DMat( "Material Cap"          ));
	newInput(i+ 9, nodeValue_Vec2(  "Texture Scale",  [1,1] ));
	newInput(i+14, nodeValue_Bool(  "Use Path Color", false ));
	// input i+17
	
	input_display_list = [
		[ "Path",     false ],      i+0, i+13,i+10,
		__d3d_input_list_mesh,      i+6, i+1, i+12, i+7, i+8, i+15, i+16, i+5, i+11, 
		__d3d_input_list_transform,
		[ "Material", false ],      i+4, i+2, i+3, i+9, i+14, 
	]
	
	////- Nodes
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var i = in_mesh;
			
			var _path    = _data[i+ 0];
			var _pathSca = _data[i+13];
			var _loop    = _data[i+10];
			
			var _samp    = _data[i+ 6];
			var _sides   = _data[i+ 1];
			var _pfrot   = _data[i+12];
			var _rad     = _data[i+ 7];
			var _radOv   = _data[i+ 8], _lenUse = inputs[i+ 7].attributes.curved,       _lenMap = _lenUse? new curveMap(_radOv) : undefined;
			var _radOw   = _data[i+15], _weiUse = inputs[i+ 7].attributes.curve_weight, _weiMap = _weiUse? new curveMap(_radOw) : undefined;
			var _weiRng  = _data[i+16];
			
			var _caps    = _data[i+ 5];
			var _invert  = _data[i+11];
			
			var _smt     = _data[i+ 4];
			var _mat_sid = _data[i+ 2];
			var _mat_cap = _data[i+ 3];
			var _uvScale = _data[i+ 9];
			var _useColr = _data[i+14];
			
			inputs[i+ 3].setVisible(_caps, _caps);
			inputs[i+16].setVisible(_weiUse);
			
			if(_path == noone) return noone;
		#endregion
		
		if(_loop) _caps = false;
		
		var _pathAmo = _path.getLineCount();
		var _points  = array_create(_pathAmo);
		var _uvProg  = array_create(_pathAmo);
		var _colors  = array_create(_pathAmo);
		var _radius  = array_create(_pathAmo);
		var _radPath = array_create(_samp);
		
		var _stp = 1 / (_samp - 1);
		var _p   = new PathPoint();
		var wrng = _weiRng[1] - _weiRng[0];
		
		if(_lenMap) { for (var i = 0; i < _samp; i++) _radPath[i] = _lenMap.get(_stp * i); 
		} else {      for (var i = 0; i < _samp; i++) _radPath[i] = 1; }
		
		for( var p = 0; p < _pathAmo; p++ ) {
			var __points  = array_create(_samp * 3);
			var __uvProg  = array_create(_samp);
			var __colors  = array_create(_samp);
			var __radius  = array_create(_samp);
			var _distTotal = 0;
			
			for(var i = 0; i < _samp; i++) {
				var _prg = _stp * i;
				if(!_loop) _prg = clamp(_prg, 0, 0.999);
				
				_p = _path.getPointRatio(_prg, p, _p);
				
				var _pointId = i * 3;
				__points[_pointId + 0] = _p.x * _pathSca;
				__points[_pointId + 1] = _p.y * _pathSca;
				__points[_pointId + 2] = _p.z * _pathSca;
				__radius[i] = _radPath[i] * (_weiMap? _weiMap.get((_p.w - _weiRng[0]) / wrng) : 1);
				
				if(i) {
					var _d = point_distance_3d(__points[_pointId-3+0], __points[_pointId-3+1], __points[_pointId-3+2], 
					                           __points[_pointId  +0], __points[_pointId  +1], __points[_pointId  +2] );
					_distTotal += _d;
					__uvProg[i] = _distTotal;
				}
				
				__colors[i] = _useColr? _p.w : c_white;
			}
			
			for (var i = 0; i < _samp; i++) __uvProg[i]  /= _distTotal;
			__uvProg[_samp] = 1;
			
			_points[p] = __points;
			_uvProg[p] = __uvProg;
			_colors[p] = __colors;
			_radius[p] = __radius;
		}
		
		var object = getObject(_array_index);
		object.checkParameter({ 
			sides  : _sides, 
			endCap : _caps,
			smooth : _smt, 
			colors : _colors,
			
			pathAmount : _pathAmo, 
			points : _points, 
			radius : _rad, 
			radii  : _radius, 
			
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
	
}