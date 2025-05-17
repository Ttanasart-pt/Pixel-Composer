function __Box2DObject(_objId = undefined, _texture = undefined) constructor {
	objId   = _objId;
	texture = _texture;
	
	xscale  = 1;
	yscale  = 1;
	
	xoffset = 0;
	yoffset = 0;
	
	blend   = ca_white;
	alpha   = 1;
}

function __Box2DVec2(b) constructor {
	x = buffer_read(b, buffer_f32);
	y = buffer_read(b, buffer_f32);
}

function __Box2DManifoldPoint(b) constructor {
	point   = new __Box2DVec2(b);
	anchorA = new __Box2DVec2(b);
	anchorB = new __Box2DVec2(b);
	
	separation      = buffer_read(b, buffer_f32);
	normal_impulse  = buffer_read(b, buffer_f32);
	tangent_impulse = buffer_read(b, buffer_f32);
	total_normal_impulse = buffer_read(b, buffer_f32);
	normal_velocity = buffer_read(b, buffer_f32);
	
	manifold_point  = buffer_read(b, buffer_u16);
	persisted       = buffer_read(b, buffer_bool);
	
	buffer_seek(b, buffer_seek_relative, 1);
}

function __Box2DCollisionData(b) constructor {
	shapeA_id    = buffer_read(b, buffer_s32);
	shapeA_world = buffer_read(b, buffer_u16);
	shapeA_gen   = buffer_read(b, buffer_u16);
	
	shapeB_id    = buffer_read(b, buffer_s32);
	shapeB_world = buffer_read(b, buffer_u16);
	shapeB_gen   = buffer_read(b, buffer_u16);
	
	mani_normal  = new __Box2DVec2(b);
	mani_roll    = buffer_read(b, buffer_f32);
	
	mani_points_0 = new __Box2DManifoldPoint(b);
	mani_points_1 = new __Box2DManifoldPoint(b);
	
	point_count = buffer_read(b, buffer_s32);
}

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

function gmlBox2D_Object_Get_Collision_Data(objectId) {
	static COLLISION_MAX_CAPACITY = 64;
	
	var b      = buffer_create(COLLISION_MAX_CAPACITY * 128, buffer_fixed, 1);
	var _count = gmlBox2D_Object_Get_Contact_Data(objectId, buffer_get_address(b), COLLISION_MAX_CAPACITY);
	
	var _coll  = array_create(_count);
	buffer_to_start(b);
	
	for( var i = 0; i < _count; i++ ) {
		buffer_seek(b, buffer_seek_start, i * 128);
		_coll[i] = new __Box2DCollisionData(b);
	}
	
	buffer_delete(b);
	return _coll;
}

function gmlBox2D_Joint_Weld(worldIndex, objectAIndex, objectBIndex, anchorX, anchorY, _jstif, _jdamp, _jbrek) {
	var b = buffer_pack_doubles(worldIndex, objectAIndex, objectBIndex, anchorX, anchorY, _jstif, _jdamp, _jbrek);
	var j = gmlBox2D_Joint_Weld_Create(buffer_get_address(b));
	buffer_delete_safe(b);
	
	return j;
}

function gmlBox2D_Joint_Motor(worldIndex, objectAIndex, objectBIndex, offsetX, offsetY, maxForce, maxTorque, breakForce) {
	var b = buffer_pack_doubles(worldIndex, objectAIndex, objectBIndex, offsetX, offsetY, maxForce, maxTorque, breakForce);
	var j = gmlBox2D_Joint_Motor_Create(buffer_get_address(b));
	buffer_delete_safe(b);
	
	return j;
}