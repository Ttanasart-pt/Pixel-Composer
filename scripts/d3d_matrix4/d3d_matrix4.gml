function __mat4() constructor {
    raw = [ 0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0 ];
	
	static setRaw = function(raw) {
		gml_pragma("forceinline");
		self.raw = raw;
		return self;
	}
	
    static det = function() {
        // Compute and return the determinant of the matrix
        return raw[0]*raw[5]*raw[10]*raw[15] + raw[4]*raw[9]*raw[14]*raw[3] +
               raw[8]*raw[13]*raw[2]*raw[7] + raw[12]*raw[1]*raw[6]*raw[11] -
               raw[12]*raw[9]*raw[6]*raw[3] - raw[8]*raw[5]*raw[14]*raw[11] -
               raw[4]*raw[13]*raw[10]*raw[7] - raw[0]*raw[1]*raw[2]*raw[15];
    };
	
	static transpose = function() {
		var result = new __mat4();
		
		// Transpose the matrix
		for (var i = 0; i < 4; i++)
		for (var j = 0; j < 4; j++) {
			result.raw[i * 4 + j] = raw[j * 4 + i];
		}
		
		return result;
	}
	
	static invert = function() {
		var result = new __mat4();
	    var temp   = clone();
    
	    // Create a copy of the matrix to work with
	    for (var i = 0; i < 16; i++) 
	        result.raw[i] = i % 5 == 0 ? 1 : 0; // Identity matrix
	    
	    for (var i = 0; i < 4; i++) {
	        var pivot = temp.raw[i * 4 + i];
        
	        if (pivot == 0) {
	            // Handle the case when the pivot is zero (singular matrix)
	            // You might want to return an error here or handle it differently
	            return result;
	        }
        
	        // Divide the current row by the pivot value
	        for (var j = 0; j < 4; j++) {
	            temp.raw[i * 4 + j] /= pivot;
	            result.raw[i * 4 + j] /= pivot;
	        }
        
	        // Subtract the current row from other rows to make them 0
	        for (var j = 0; j < 4; j++) {
	            if (j != i) {
	                var factor = temp.raw[j * 4 + i];
	                for (var k = 0; k < 4; k++) {
	                    temp.raw[j * 4 + k] -= factor * temp.raw[i * 4 + k];
	                    result.raw[j * 4 + k] -= factor * result.raw[i * 4 + k];
	                }
	            }
	        }
	    }
    
	    return result;
	}

    
    static multiplyMatrix = function(matrix) {
        var result = new __mat4();
        
        // Perform matrix multiplication
        for (var i = 0; i < 4; i++) {
            for (var j = 0; j < 4; j++) {
                var sum = 0;
                for (var k = 0; k < 4; k++)
                    sum += raw[i * 4 + k] * matrix.raw[k * 4 + j];
                result.raw[i * 4 + j] = sum;
            }
        }
        
        return result;
    };
    
    static multiplyVector = function(vector) {
        var result = new __vec4();
        
        // Perform matrix-vector multiplication
        for (var i = 0; i < 4; i++) {
            result.setIndex(i,  raw[i * 4 + 0] * vector.x +
				                raw[i * 4 + 1] * vector.y +
				                raw[i * 4 + 2] * vector.z +
				                raw[i * 4 + 3] * vector.w);
        }
        
        return result;
    };
    
    static multiplyBBMODVector = function(vector) {
        var result = new BBMOD_Vec4();
        
        // Perform matrix-vector multiplication
        for (var i = 0; i < 4; i++) {
            result.SetIndex(i,  raw[i * 4 + 0] * vector.X +
				                raw[i * 4 + 1] * vector.Y +
				                raw[i * 4 + 2] * vector.Z +
				                raw[i * 4 + 3] * vector.W);
        }
        
        return result;
    };
	
	static clone = function() {
	    var result = new __mat4();
    
	    // Copy the raw values to the cloned matrix
	    for (var i = 0; i < 16; i++)
	        result.raw[i] = raw[i];
    
	    return result;
	}
	
	static toString = function() {
		var s0 = $"[{raw[ 0]}, {raw[ 1]}, {raw[ 2]}, {raw[ 3]}]";
		var s1 = $"[{raw[ 4]}, {raw[ 5]}, {raw[ 6]}, {raw[ 7]}]";
		var s2 = $"[{raw[ 8]}, {raw[ 9]}, {raw[10]}, {raw[11]}]";
		var s3 = $"[{raw[12]}, {raw[13]}, {raw[14]}, {raw[15]}]";
		
		return $"[{s0},\n{s1},\n{s2},\n{s3}]";
	}
}
