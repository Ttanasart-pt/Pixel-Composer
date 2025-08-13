function Node_3D_Affector(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name = "3D Scene Affector";
	
	gizmo_sphere = [ new __3dGizmoSphere(,, 0.75), new __3dGizmoSphere(,, 0.5) ];
	gizmo_plane  = [ new __3dGizmoPlaneFalloff(,, 0.75) ];
	gizmo_object = noone;
	
	var i = in_d3d;
	newInput(i+0, nodeValue_D3Scene("Scene")).setVisible(true, true);
	
	////- =Affectors
	newInput(i+1, nodeValue_Enum_Scroll( "Shape", 0, [ new scrollItem("Sphere", s_node_3d_affector_shape, 0), 
	                                                          new scrollItem("Plane",  s_node_3d_affector_shape, 1), ]));
	newInput(i+2, nodeValue_Float( "Falloff distance",   0.5    ));
	newInput(i+3, nodeValue_Curve( "Falloff curve",      CURVE_DEF_01 ));
	
	////- =Transform
	newInput(i+4, nodeValue_Vec3(        "Affect Position", [0,0,0]    ));
	newInput(i+5, nodeValue_Quaternion(  "Affect Rotation", [0,0,0,1 ] ));
	newInput(i+6, nodeValue_Vec3(        "Affect Scale",    [1,1,1]    ));
	// i+7
	
	newOutput(0, nodeValue_Output("Scene", VALUE_TYPE.d3Scene, noone));
	
	input_display_list = [ i+0, 
		["Affectors", false], i+1, 0, 1, 2, i+2, i+3, 
		["Transform", false], i+4, i+5, i+6, 
	];
	
	curve_falloff = noone;
	plane_normal  = [ 0, 0, 1 ];
	
	static processData = function(_output, _data, _array_index = 0) {
		#region data
			var _pos  = _data[0];
			var _rot  = _data[1];
			var _sca  = _data[2];
			var _maxs = max(_sca[0], _sca[1], _sca[2]);
			
			var _scn  = _data[in_d3d + 0];
			var _ftyp = _data[in_d3d + 1];
			var _fald = _data[in_d3d + 2];
			var _fcrv = _data[in_d3d + 3];
			
			var _apos = _data[in_d3d + 4];
			var _arot = _data[in_d3d + 5], _qrot = new BBMOD_Quaternion(_arot[0], _arot[1], _arot[2], _arot[3]);
			var _asca = _data[in_d3d + 6];
			
			if(!is(_scn, __3dGroup)) return noone;
			
			var _nscn  = _scn.clone(false);
		#endregion
		
		if(_ftyp == 0) {
			gizmo_object = gizmo_sphere;
			
			setTransform(gizmo_sphere[0], _data);
			setTransform(gizmo_sphere[1], _data);
			
			gizmo_sphere[0].transform.scale.set(_maxs + _fald, _maxs + _fald, _maxs + _fald);
			gizmo_sphere[1].transform.scale.set(_maxs - _fald, _maxs - _fald, _maxs - _fald);
			
			gizmo_sphere[0].transform.applyMatrix();
			gizmo_sphere[1].transform.applyMatrix();
		
		} else if(_ftyp == 1) {
			gizmo_object = gizmo_plane;
			
			setTransform(gizmo_plane[0], _data);
			gizmo_plane[0].transform.scale.set(1, 1, 1);
			gizmo_plane[0].transform.applyMatrix();
			
			gizmo_plane[0].checkParameter({ distance: _fald });
			
			var _prot    = new BBMOD_Quaternion(_rot[0], _rot[1], _rot[2], _rot[3]);
			plane_normal = _prot.Rotate(new BBMOD_Vec3(0, 0, 1)).ToArray();
		}
		
		if(IS_FIRST_FRAME) curve_falloff = new curveMap(_fcrv, 100);
		
		var _dis = 0;
		var _inR = 0;
		var _ouR = 1;
		
		for( var i = 0, n = array_length(_nscn.objects); i < n; i++ ) {
			var _obj = _nscn.objects[i];
			if(!is(_obj, __3dInstance)) continue;
			
			var _cen = _obj.getCenter().toArray();
			
			if(_ftyp == 0) {
				_dis = point_distance_3d(_pos[0], _pos[1], _pos[2], _cen[0], _cen[1], _cen[2]);
				_inR = (_maxs - _fald) / 2;
				_ouR = (_maxs + _fald) / 2;
				
			} else if(_ftyp == 1) {
				_dis = d3d_point_to_plane(_pos, plane_normal, _cen);
				_inR = -_fald / 2;
				_ouR =  _fald / 2;
			}
			
			var _inf = 0;
			     if(_dis >= _ouR) _inf = 0;
			else if(_dis <= _inR) _inf = 1;
			else {
				_inf = 1 - (_dis - _inR) / _fald;
				_inf = curve_falloff == noone? _inf : curve_falloff.get(_inf);
			}
			
			if(_inf == 0) continue;
			
			_obj.transform.position.x += _apos[0] * _inf;
			_obj.transform.position.y += _apos[1] * _inf;
			_obj.transform.position.z += _apos[2] * _inf;
			
			_obj.transform.rotation = _obj.transform.rotation.Slerp(_obj.transform.rotation.Mul(_qrot), _inf);
			
			_obj.transform.scale.x *= 1 + (_asca[0] - 1) * _inf;
			_obj.transform.scale.y *= 1 + (_asca[1] - 1) * _inf;
			_obj.transform.scale.z *= 1 + (_asca[2] - 1) * _inf;
			
			_obj.transform.applyMatrix();
		}
			
		return _nscn;
	}
	
	static getPreviewObjects		= function() /*=>*/ {return array_append([getPreviewObject()], gizmo_object)};
	static getPreviewObjectOutline  = function() /*=>*/ {return gizmo_object};
}