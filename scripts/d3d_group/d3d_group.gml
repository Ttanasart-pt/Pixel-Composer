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
	
	function __d3d_flattern(_objs, _obj) {
		if(is(_obj, __3dObject)) {
			array_append( _objs.VB,  _obj.VB  );
			array_append( _objs.VBM, _obj.VBM == undefined? array_create(array_length(_obj.VB), undefined) : _obj.VBM );
			
		} else if(is(_obj, __3dGroup)) {
			for( var i = 0, n = array_length(_obj.objects); i < n; i++ )
				__d3d_flattern(_objs, _obj.objects[i]);
			
		} else if(is(_obj, __3dTransformed)) {
			__d3d_flattern(_objs, _obj.object);
			
		}
	}
	
	function d3d_flattern(_obj) {
		if(!is(_obj, __3dInstance)) return _obj;
		
		var _objs = { VB: [], VBM: [] };
		
		__d3d_flattern(_objs, _obj);
		
		return _objs;
	}
	
#endregion