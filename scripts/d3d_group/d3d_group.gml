function __3dGroup() constructor {
	objects = [];
	
	static getCenter = function() {
		var _v = new __vec3();
		var _i = 0;
		
		for( var i = 0, n = array_length(objects); i < n; i++ ) {
			var _c = objects[i].getCenter();
			if(_c == noone) continue;
			_v._add(objects[i].getCenter());
			_i++;
		}
		
		return _i == 0? new __vec3() : _v.multiply(1 / _i);
	}
	
	static getBBOX   = function() { 
		if(array_empty(objects)) return new __bbox3D(new __vec3(-0.5), new __vec3(0.5));
		var _m0 = noone;
		var _m1 = noone;
		var _cc = getCenter();
		
		for( var i = 0, n = array_length(objects); i < n; i++ ) {
			var _c = objects[i].getCenter();
			var _b = objects[i].getBBOX();
			
			if(_c == noone || _b == noone) continue;
			
			var _n0 = _b.first.add(_c);
			var _n1 = _b.second.add(_c);
			
			_m0 = _m0 == noone? _n0 : _m0.minVal(_n0);
			_m1 = _m1 == noone? _n1 : _m1.maxVal(_n1);
		}
		
		_m0._subtract(_cc);
		_m1._subtract(_cc);
		
		return new __bbox3D(_m0, _m1); 
	}
	
	static _submit = function(callback, params = {}, shader = noone) {
		for( var i = 0, n = array_length(objects); i < n; i++ )
			callback(objects[i], params, shader);
	}
	
	static submitShader = function(params = {}) { _submit(function(_obj, params) { _obj.submitShader(params); }, params); }
	static submitSel    = function(params = {}) { _submit(function(_obj, params) { _obj.submitSel(params); }, params); }
	static submitUI     = function(params = {}, shader = noone) { _submit(function(_obj, params, shader) { _obj.submitUI(params, shader); }, params, shader); }
	static submit       = function(params = {}, shader = noone) { _submit(function(_obj, params, shader) { _obj.submit(params, shader);   }, params, shader); }
	
	static map = function(callback, params = {}) {
		for( var i = 0, n = array_length(objects); i < n; i++ ) 
			callback(objects[i], params);
	}
}