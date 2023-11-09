function Node_3D_Point_Affector(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name		= "Point Affector";
	previewable = false;
	
	gizmo_sphere = [ new __3dGizmoSphere(,, 0.75), new __3dGizmoSphere(,, 0.5) ];
	gizmo_plane  = [ new __3dGizmoPlaneFalloff(,, 0.75) ];
	gizmo_object = noone;
	
	inputs[| in_d3d + 0] = nodeValue("Points", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setVisible(true, true)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| in_d3d + 1] = nodeValue("Initial value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| in_d3d + 2] = nodeValue("Final value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| in_d3d + 3] = nodeValue("Falloff distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5);
	
	inputs[| in_d3d + 4] = nodeValue("Falloff curve", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_01);
	
	inputs[| in_d3d + 5] = nodeValue("Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Sphere", "Plane" ]);
	
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 
		["Affectors", false], in_d3d + 5, 0, 1, 2, in_d3d + 3, in_d3d + 4, 
		["Points",    false], in_d3d + 0, in_d3d + 1, in_d3d + 2, 
	];
	
	curve_falloff = noone;
	plane_normal  = [ 0, 0, 1 ];
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) { #region
		var _pos  = _data[0];
		var _rot  = _data[1];
		var _sca  = _data[2];
		var _maxs = max(_sca[0], _sca[1], _sca[2]);
		
		var _p    = _data[in_d3d + 0];
		var _iVal = _data[in_d3d + 1];
		var _fVal = _data[in_d3d + 2];
		var _fald = _data[in_d3d + 3];
		var _fcrv = _data[in_d3d + 4];
		var _ftyp = _data[in_d3d + 5];
		
		if(_array_index == 0) {
			if(_ftyp == 0) {
				gizmo_object = gizmo_sphere;
				
				setTransform(gizmo_sphere[0], _data);
				setTransform(gizmo_sphere[1], _data);
				
				gizmo_sphere[0].transform.scale.set(_maxs + _fald, _maxs + _fald, _maxs + _fald);
				gizmo_sphere[1].transform.scale.set(_maxs - _fald, _maxs - _fald, _maxs - _fald);
			} else if(_ftyp == 1) {
				gizmo_object = gizmo_plane;
				
				setTransform(gizmo_plane[0], _data);
				gizmo_plane[0].transform.scale.set(1, 1, 1);
				gizmo_plane[0].checkParameter({ distance: _fald });
				
				var _prot    = new BBMOD_Quaternion(_rot[0], _rot[1], _rot[2], _rot[3]);
				plane_normal = _prot.Rotate(new BBMOD_Vec3(0, 0, 1));
			}
			
			if(CURRENT_FRAME == 0)
				curve_falloff = new curveMap(_fcrv, 100);
		}
		
		var _res = array_create(array_length(_iVal));
		var _dis = 0, _inR = 0, _ouR = 1;
					  
		if(_ftyp == 0) {
			_dis = point_distance_3d(_pos[0], _pos[1], _pos[2], _p[0], _p[1], _p[2]);
			_inR = (_maxs - _fald) / 2;
			_ouR = (_maxs + _fald) / 2;
		} else if(_ftyp == 1) {
			_dis = d3d_point_to_plane(_pos, plane_normal, _p);
			_inR = -_fald / 2;
			_ouR =  _fald / 2;
		}
		
		if(_dis >= _ouR) _res = _iVal;
		else if(_dis <= _inR) _res = _fVal;
		else {
			var _inf = (_dis - _inR) / (_fald);
			    _inf = curve_falloff == noone? _inf : curve_falloff.get(_inf);
			
			for( var i = 0, n = array_length(_res); i < n; i++ )
				_res[i] = lerp(_fVal[i], _iVal[i], _inf);
		}
		
		return _res;
	} #endregion
	
	static getPreviewObject = function() { return noone; }
	
	static getPreviewObjects       = function() { return gizmo_object; }
	static getPreviewObjectOutline = function() { return gizmo_object; }
}