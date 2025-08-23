#macro __3D_GROUP_PRESUB transform.submitMatrix(); for( var i = 0, n = array_length(objects); i < n; i++ )
#macro __3D_GROUP_POSSUB transform.clearMatrix();

function __3dGroup() : __3dInstance() constructor {
	objects = [];
	
	static getCenter = function() {
		var _v = new __vec3();
		var _i = 0;
		
		for( var i = 0, n = array_length(objects); i < n; i++ ) {
			if(!is_struct(objects[i])) continue;
			var _c = objects[i].getCenter();
			if(_c == noone) continue;
			_v._add(objects[i].getCenter());
			_i++;
		}
		
		if(_i) _v = _v.multiply(1 / _i);
		_v.add(transform.position);
		
		return _v;
	}
	
	static getBBOX   = function() {
		if(array_empty(objects)) return new __bbox3D(new __vec3(-0.5), new __vec3(0.5));
		var _m0 = noone;
		var _m1 = noone;
		var _cc = getCenter();
		
		for( var i = 0, n = array_length(objects); i < n; i++ ) {
			if(!is_struct(objects[i])) continue;
			var _c = objects[i].getCenter();
			var _b = objects[i].getBBOX();
			
			if(_c == noone || _b == noone) continue;
			
			_b.first.multiplyVec(transform.scale);
			_b.second.multiplyVec(transform.scale);
			
			var _n0 = _b.first.add(_c);
			var _n1 = _b.second.add(_c);
			
			_m0 = _m0 == noone? _n0 : _m0.minVal(_n0);
			_m1 = _m1 == noone? _n1 : _m1.maxVal(_n1);
		}
		
		if(_m0 == noone) return new __bbox3D(new __vec3(-0.5), new __vec3(0.5));
		
		_m0._subtract(_cc);
		_m1._subtract(_cc);
		
		return new __bbox3D(_m0, _m1); 
	}
	
	static addObject = function(_obj) { array_push(objects, _obj); }
	
	static submit       = function(_sc = {}, _sh = noone)    /*=>*/ { __3D_GROUP_PRESUB objects[i].submit(_sc, _sh);       __3D_GROUP_POSSUB }
	static submitSel    = function(_sc = {}, _sh = noone)    /*=>*/ { __3D_GROUP_PRESUB objects[i].submitSel(_sc, _sh);    __3D_GROUP_POSSUB }
	static submitShader = function(_sc = {}, _sh = noone)    /*=>*/ { __3D_GROUP_PRESUB objects[i].submitShader(_sc, _sh); __3D_GROUP_POSSUB }
	static submitShadow = function(_sc = {}, _ob = noone) /*=>*/ { for( var i = 0, n = array_length(objects); i < n; i++ ) objects[i].submitShadow(_sc, _ob); }
	static map = function(callback, _sc = {}) /*=>*/ { for( var i = 0, n = array_length(objects); i < n; i++ ) callback(objects[i], _sc); }
	
	static clone = function(vertex = true, cloneBuffer = false) {
		var _new = new __3dGroup();
		
		_new.transform = transform.clone();
		_new.objects   = array_create(array_length(objects));
		
		for( var i = 0, n = array_length(objects); i < n; i++ )
			_new.objects[i] = objects[i].clone(vertex, cloneBuffer);
		
		return _new;
	}
}

function __3dTransformed(_object = noone) : __3dInstance() constructor {
	object = _object;
	
	static getCenter = function() { return object.getCenter().add(transform.position); }
	
	static getBBOX   = function() {
		var _b = object.getBBOX().clone();
		
		_b.first.multiplyVec(transform.scale);
		_b.first.add(transform.position);
		
		_b.second.multiplyVec(transform.scale);
		_b.second.add(transform.position);
		
		return _b;
	}
	
	static submit       = function(_sc = {}, _sh = noone) /*=>*/ { transform.submitMatrix(); object.submit(_sc, _sh);       transform.clearMatrix(); }
	static submitSel    = function(_sc = {}, _sh = noone) /*=>*/ { transform.submitMatrix(); object.submitSel(_sc, _sh);    transform.clearMatrix(); }
	static submitShader = function(_sc = {}, _sh = noone) /*=>*/ { transform.submitMatrix(); object.submitShader(_sc, _sh); transform.clearMatrix(); }
	static submitShadow = function(_sc = {}, _ob = noone) /*=>*/ { object.submitShadow(_sc, _ob); }
	
	static clone = function(vertex = true, cloneBuffer = false) {
		var _new = new __3dTransformed();
		
		_new.transform = transform.clone();
		_new.object    = object.clone(vertex, cloneBuffer);
		
		return _new;
	}
}

#region actions
	
	function __d3d_flattern(_objs, _obj, _transMat, _vf = global.VF_POS_NORM_TEX_COL) {
		if(!is(_obj, __3dInstance)) return;
		
		var _objMat = matrix_multiply(_transMat, _obj.transform.matTran);
		
		if(is(_obj, __3dGroup)) {
			for( var i = 0, n = array_length(_obj.objects); i < n; i++ )
				__d3d_flattern(_objs, _obj.objects[i], _objMat, _vf);
			return;
		} 
		
		if(is(_obj, __3dTransformed)) {
			__d3d_flattern(_objs, _obj.object, _objMat, _vf);
			return;
		}
		
		if(!is(_obj, __3dObject)) return;
		if(_obj.VF != _vf) return;
		
		var _vbs = [];
		
		for( var i = 0, n = array_length(_obj.VB); i < n; i++ ) {
			var _vb = vertex_buffer_clone(_obj.VB[i], _vf, _transMat);
			vertex_freeze(_vb);
			
			_vbs[i] = _vb;
		}
		
		array_append( _objs.VB,  _vbs  );
		
		var _mat = [];
		for( var i = 0, n = array_length(_obj.VB); i < n; i++ ) {
			var _m = array_safe_get_fast(_obj.materials, _obj.material_index == undefined? i : _obj.material_index[i], noone);
			var _uMat = is(_m, __d3dMaterial);
			var _mdat;
			
			if(_uMat) {
				_mdat = {
					texture:         _m.getTexture(),  
					use_normal:      is_surface(_m.normal),
					normal_map:      surface_get_texture_safe(_m.normal),
					normal_strength: _m.normalStr,
					
					mat_diffuse:    _m.diffuse,
					mat_specular:   _m.specular,
					mat_shine:      _m.shine,
					mat_metalic:    _m.metalic,
					mat_reflective: _m.reflective,
		
					mat_texScale:   _m.texScale,
					mat_texShift:   _m.texShift,
					tex_filter:     _m.texFilter, 
				};
				
			} else {
				_mdat = {
					texture:         -1, 
					use_normal:       0, 
					normal_map:      -1,
					normal_strength:  0,
					
					mat_diffuse:    1,
					mat_specular:   0,
					mat_shine:      1,
					mat_metalic:    0,
					mat_reflective: 0,
					
					mat_texScale:   [1,1], 
					mat_texShift:   [0,0], 
					tex_filter:     false, 
				};
			}
			
			_mat[i] = _mdat;
		}
		
		array_append( _objs.materials, _mat );
		
	}
	
	function d3d_flattern(_obj, _vf = global.VF_POS_NORM_TEX_COL) {
		if(!is(_obj, __3dInstance)) return _obj;
		
		var _objs = { 
			VB : [], 
			materials : [],
		};
		
		__d3d_flattern(_objs, _obj, matrix_build_identity(), _vf);
		
		return _objs;
	}
	
#endregion