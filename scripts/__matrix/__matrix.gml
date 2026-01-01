function Matrix(_size = 1) constructor {
    size  = [ 1, 1 ];
    isize = 1;
    raw   = [];
    
    static setSize = function(_s) {
    	if(!is_array(_s)) _s = [ _s, _s ];
    	
    	size  = _s;
    	isize = _s[0] * _s[1];
    	array_resize(raw, isize);
    	
    	return self;
    }
    setSize(_size);
    
    static setArray = function(_arr) {
    	var _l = min(array_length(_arr), isize);
    	
    	for( var i = 0; i < _l; i++ )
    		raw[i] = _arr[i];
    		
    	return self;
    }
    
    static setMatrix = function(_mat) {
    	setSize(_mat.size);
    	setArray(_mat.raw);
    	
    	return self;
    }
    
    static set = function(_x, _y, v) { raw[_y * size[0] + _x] = v; return self; }
    static get = function(_x, _y)    { return array_safe_get_fast(raw, _y * size[0] + _x); }
    
	////- Unary
	
	static isSquare = function() { return size[0] == size[1]; }
	
	static det = function() {
		if(!isSquare()) return -1;
		return __matrix_determinant(raw, size[0]);
	}
	
	static invert = function() {
		if(!isSquare()) return self;
		var _inv = __matrix_inverse(raw, size[0]);
		var _mat = new Matrix(size).setArray(_inv);
		return _mat;
	}
	
	static transpose = function() {
		var _trn = __matrix_transpose(raw, size);
		var _mat = new Matrix([size[1], size[0]]).setArray(_trn);
		return _mat;
	}
	
	////- Operations
	
	static add = function(_mat2) {
		var _mat = clone();
		for( var i = 0; i < isize; i++ )
			_mat.raw[i] += array_safe_get(_mat2.raw, i, 0);
		return _mat;
	}
	
	static subtract = function(_mat2) {
		var _mat = clone();
		for( var i = 0; i < isize; i++ )
			_mat.raw[i] -= array_safe_get(_mat2.raw, i, 0);
		return _mat;
	}
	
	static multiplyScalar = function(_sca) {
		var _mat = clone();
		for( var i = 0; i < isize; i++ )
			_mat.raw[i] *= _sca;
		return _mat;
	}
	
	static divideScalar = function(_sca) {
		var _mat = clone();
		for( var i = 0; i < isize; i++ )
			_mat.raw[i] /= _sca;
		return _mat;
	}
	
	static multiplyVector = function(_vec) {
		var result = [];
        var cols = size[0];
        var rows = size[1];
        
        for (var i = 0; i < rows; i++) {
            var sum = 0;
            for (var j = 0; j < cols; j++)
                sum += raw[i * cols + j] * array_safe_get(_vec, j, 1);
            result[i] = sum;
        }
        
        return result;
	}
	
	static multiplyMatrix = function(_mat2) {
		var result = [];
        var rowsA = size[0];
        var colsA = size[1];
        var rowsB = _mat2.size[0];
        var colsB = _mat2.size[1];
        
        if (colsA != rowsB) return self; // Incompatible matrices
        
        for (var i = 0; i < rowsA; i++) {
            for (var j = 0; j < colsB; j++) {
                var sum = 0;
                for (var k = 0; k < colsA; k++) {
                    sum += raw[i * colsA + k] * _mat2.raw[k * colsB + j];
                }
                result[i * colsB + j] = sum;
            }
        }
        
        var _mat = new Matrix([rowsA, colsB]).setArray(result);
		return _mat;
	}
	
	////- Actions
	
	static lerpTo = function(_mat, _t) {
	    if(!is(_mat, Matrix)) return self;
	    if(_mat.size[0] != size[0] || _mat.size[1] != size[1]) return self;
	    
	    var _m = new Matrix();
	    _m.size  = [ size[0], size[1] ];
	    _m.isize = isize;
	    _m.raw   = array_create(isize);
	    
	    for( var i = 0; i < isize; i++ ) 
	        _m.raw[i] = lerp(raw[i], _mat.raw[i], _t);
	        
	    return _m;
	}
	
	static clone = function() { return new Matrix(size).setArray(raw); }
	
	static to_string = function() { return $"{raw}"; }
	
	static to_real = function() { return raw; }
	
	////- Serialize
	
    static serialize = function() {
        return { size, isize, raw };
    }
    
    static deserialize = function(dat) {
        if(is_array(dat)) {
            var _len = array_length(dat);
            var _siz = floor(sqrt(_len));
            size  = [ _siz, _siz ];
            isize = _siz * _siz;
            raw   = dat;
            return self;
        }
        
        size  = dat[$ "size"]  ?? size;
        isize = dat[$ "isize"] ?? isize;
        raw   = dat[$ "raw"]   ?? raw;
        
        return self;
    }
	
}