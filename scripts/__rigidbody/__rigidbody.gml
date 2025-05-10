function gmlBox2D_Object_Get_AABB_arr(objectId, worldScale = 1) {
	var b = buffer_create(8*4, buffer_fixed, 8);
	gmlBox2D_Object_Get_AABB(objectId, buffer_get_address(b));
	var aabb = [0, 0, 0, 0];
	
	buffer_to_start(b);
	aabb[0] = buffer_read(b, buffer_f64) * worldScale;
	aabb[1] = buffer_read(b, buffer_f64) * worldScale;
	aabb[2] = buffer_read(b, buffer_f64) * worldScale;
	aabb[3] = buffer_read(b, buffer_f64) * worldScale;
	buffer_delete(b);
	
	return aabb;
}