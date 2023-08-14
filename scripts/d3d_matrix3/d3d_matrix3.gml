function __mat3() constructor {
    raw = [ 0, 0, 0, 0, 0, 0, 0, 0, 0 ];
    
    static det = function() {
        return raw[0]*raw[4]*raw[8] + raw[1]*raw[5]*raw[6] + raw[2]*raw[3]*raw[7]
             - raw[2]*raw[4]*raw[6] - raw[0]*raw[5]*raw[7] - raw[1]*raw[3]*raw[8];
    };
    
    static multiplyMatrix = function(matrix) {
        var result = new __mat3();
        
        for (var i = 0; i < 3; i++) {
            for (var j = 0; j < 3; j++) {
                var sum = 0;
                for (var k = 0; k < 3; k++) {
                    sum += raw[i * 3 + k] * matrix.raw[k * 3 + j];
                }
                result.raw[i * 3 + j] = sum;
            }
        }
        
        return result;
    };
    
    static multiplyVector = function(vector) {
        var result = new __vec3();
        
        for (var i = 0; i < 3; i++) {
            result.setIndex(i,	raw[i * 3 + 0] * vector.x +
								raw[i * 3 + 1] * vector.y +
								raw[i * 3 + 2] * vector.z);
        }
        
        return result;
    };
}
