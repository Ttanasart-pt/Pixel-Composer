function __3dGroup() constructor {
	objects = [];
	
	static _submit = function(callback, params = {}, shader = noone) {
		for( var i = 0, n = array_length(objects); i < n; i++ )
			callback(objects[i], params, shader);
	}
	
	static submitShader = function(params = {}) { _submit(function(_obj, params) { _obj.submitShader(params); }, params); }
	static submitSel    = function(params = {}) { _submit(function(_obj, params) { _obj.submitSel(params); }, params); }
	static submitUI     = function(params = {}, shader = noone) { _submit(function(_obj, params, shader) { _obj.submitUI(params, shader); }, params); }
	static submit       = function(params = {}, shader = noone) { _submit(function(_obj, params, shader) { _obj.submit(params, shader);   }, params); }
}