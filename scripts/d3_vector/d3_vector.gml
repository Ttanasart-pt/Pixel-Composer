function d3_normalize(vec) {
	var vx = vec[0], vy = vec[1], vz = vec[2];
	var mag = sqrt(vx * vx + vy * vy + vz * vz);
	vec[0] = vx / mag;
	vec[1] = vy / mag;
	vec[2] = vz / mag;
	
	return vec;
}

function d3_cross_product(a, b) {
	var ax = a[0], ay = a[1], az = a[2],
		bx = b[0], by = b[1], bz = b[2];
	var result = [];
	result[0] = ay * bz - az * by;
	result[1] = az * bx - ax * bz;
	result[2] = ax * by - ay * bx;
	return result;
}
