/// @func BBMOD_CollisionKillModule()
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that kills all particles that had a collision.
///
/// @note Make sure to add this *after* a collision module, otherwise no
/// collision will be detected!
///
/// @see BBMOD_EParticle.HasCollided
function BBMOD_CollisionKillModule()
	: BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static on_update = function (_emitter, _deltaTime) {
		var _y2 = _emitter.ParticlesAlive - 1;
		if (_y2 >= 0)
		{
			var _particles = _emitter.Particles;
			var _gridCompute = _emitter.GridCompute;

			ds_grid_set_grid_region(
				_gridCompute,
				_particles,
				BBMOD_EParticle.HealthLeft, 0,
				BBMOD_EParticle.HealthLeft, _y2,
				0, 0);

			ds_grid_multiply_region(
				_gridCompute,
				0, 0,
				0, _y2,
				-1);

			ds_grid_multiply_grid_region(
				_gridCompute,
				_particles,
				BBMOD_EParticle.HasCollided, 0,
				BBMOD_EParticle.HasCollided, _y2,
				0, 0);

			ds_grid_add_grid_region(
				_particles,
				_gridCompute,
				0, 0,
				0, _y2,
				BBMOD_EParticle.HealthLeft, 0);
		}
	};
}
