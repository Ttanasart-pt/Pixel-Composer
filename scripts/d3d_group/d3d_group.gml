function __3dGroup() constructor {
	objects = [];
	transform = new __transform();
	
	static getCenter = function() { #region
		var _v = new __vec3();
		var _i = 0;
		
		for( var i = 0, n = array_length(objects); i < n; i++ ) {
			var _c = objects[i].getCenter();
			if(_c == noone) continue;
			_v._add(objects[i].getCenter());
			_i++;
		}
		
		if(_i) _v = _v.multiply(1 / _i);
		_v.add(transform.position);
		
		return _v;
	} #endregion
	
	static getBBOX   = function() { #region
		if(array_empty(objects)) return new __bbox3D(new __vec3(-0.5), new __vec3(0.5));
		var _m0 = noone;
		var _m1 = noone;
		var _cc = getCenter();
		
		for( var i = 0, n = array_length(objects); i < n; i++ ) {
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
	} #endregion
	
	static submit       = function(scene = {}, shader = noone) { 
		transform.submitMatrix();
		for( var i = 0, n = array_length(objects); i < n; i++ )
			objects[i].submit(scene, shader);
		transform.clearMatrix();
	}
	
	static submitUI     = function(scene = {}, shader = noone) {
		transform.submitMatrix();
		for( var i = 0, n = array_length(objects); i < n; i++ )
			objects[i].submitUI(scene, shader);
		transform.clearMatrix();
	}
	static submitSel    = function(scene = {}, shader = noone) { 
		transform.submitMatrix();
		for( var i = 0, n = array_length(objects); i < n; i++ )
			objects[i].submitSel(scene, shader);
		transform.clearMatrix();
	}
	static submitShader = function(scene = {}, shader = noone) { 
		transform.submitMatrix();
		for( var i = 0, n = array_length(objects); i < n; i++ )
			objects[i].submitShader(scene, shader);
		transform.clearMatrix();
	}
	
	static submitShadow = function(scene = {}, object = noone) { 
		for( var i = 0, n = array_length(objects); i < n; i++ )
			objects[i].submitShadow(scene, object.objects);
	}
	
	static map = function(callback, scene = {}) { #region
		for( var i = 0, n = array_length(objects); i < n; i++ ) 
			callback(objects[i], scene);
	} #endregion
}