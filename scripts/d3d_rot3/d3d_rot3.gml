function __rot3(_x = 0, _y = 0, _z = 0) constructor {
	x = _x;
	y = _y;
	z = _z;
	
	static set = function(_x, _y, _z) {
		gml_pragma("forceinline");
		x = _x;
		y = _y;
		z = _z;
		return self;
	}
	
	static toDirection = function() {
		var _x = degtorad( x);
		var _y = degtorad( y);
		var _z = degtorad(-z);
		
		var rotationMatrix = new __mat3();

        var cosX = cos(_x);
        var sinX = sin(_x);
        var cosY = cos(_y);
        var sinY = sin(_y);
        var cosZ = cos(_z);
        var sinZ = sin(_z);

        rotationMatrix.raw[0][0] = cosY * cosZ;
        rotationMatrix.raw[0][1] = -cosX * sinZ + sinX * sinY * cosZ;
        rotationMatrix.raw[0][2] = sinX * sinZ + cosX * sinY * cosZ;
        rotationMatrix.raw[1][0] = cosY * sinZ;
        rotationMatrix.raw[1][1] = cosX * cosZ + sinX * sinY * sinZ;
        rotationMatrix.raw[1][2] = -sinX * cosZ + cosX * sinY * sinZ;
        rotationMatrix.raw[2][0] = -sinY;
        rotationMatrix.raw[2][1] = sinX * cosY;
        rotationMatrix.raw[2][2] = cosX * cosY;

        var initialVector = new __vec3(1, 0, 0);
        var rotatedVector = rotationMatrix.multiplyVector(initialVector);
		rotatedVector.z *= -1;

        return rotatedVector;
	}
	
	static lookAt = function(from, to, up = __vec3_up) {
		var dir = to.subtract(from)._normalize();
		
		var az = arctan2(dir.y, dir.x);
		var ay = arcsin(dir.z);
		
		var w0 = new __vec3( -dir.y, dir.x, 0);
		var u0 = w0.cross(dir);
		var ax = arctan2( w0.dot(up) / w0.length(), u0.dot(up) / u0.length() );
		
		ax = radtodeg(ax);
		ay = radtodeg(ay);
		az = radtodeg(az);
		
		set(ax, -ay, -az);
		
		return self;
	}
	
	static equal = function(to) {
		gml_pragma("forceinline");
		return x == to.x && y == to.y && z == to.z;
	}
	
	static clone = function() {
		gml_pragma("forceinline");
		return new __rot3(x, y, z);
	}
	
	static toString = function() { return $"[{x}, {y}, {z}]"; }
	
	static toArray = function() { return [ x, y, z ]; }
}