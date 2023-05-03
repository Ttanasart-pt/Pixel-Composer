function rotate3d_axis_angle(point, axis, angle) {
	var pitch = point[0];
    var yaw   = point[1];
    var roll  = point[2];
    
    var s = dsin(angle);
    var c = dcos(angle);
    var t = 1 - c;
    
    var _x = axis[0];
    var _y = axis[1];
    var _z = axis[2];
    
    var pitch_prime = pitch * c +   _z * s;
    var yaw_prime   = yaw   * c + (-_z * _x * t + _y * s);
    var roll_prime  = roll  * c + ( _z * _y * t + _x * s);
    
    return [ pitch_prime, yaw_prime, roll_prime ];
}