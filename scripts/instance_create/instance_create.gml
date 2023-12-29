function instance_create(_x, _y, object, params = {}) {
	var myDepth = object_get_depth( object );
	return instance_create_depth( _x, _y, myDepth, object, params );
}
