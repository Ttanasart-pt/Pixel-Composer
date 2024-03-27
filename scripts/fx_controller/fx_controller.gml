function spawn_particle(_x, _y, _rad = 4) {
	INLINE
	var _param = { radius: _rad };
	return instance_create(_x, _y, fx_particle_spawner, _param);
}