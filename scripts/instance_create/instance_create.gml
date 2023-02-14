/// @description Creates an instance of a given object at a given position.
/// @param x The x position the object will be created at.
/// @param y The y position the object will be created at.
/// @param obj The object to create an instance of.
function instance_create(_x, _y, object) {
	var myDepth = object_get_depth( object );
	return instance_create_depth( _x, _y, myDepth, object );
}
