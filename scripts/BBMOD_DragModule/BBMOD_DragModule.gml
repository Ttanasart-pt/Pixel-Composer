/// @func BBMOD_DragModule()
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that applies drag force to particles.
///
/// @see BBMOD_EParticle.Drag
function BBMOD_DragModule()
	: BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static on_update = function (_emitter, _deltaTime) {
		var _particles = _emitter.Particles;
		var _particleIndex = 0;
		repeat (_emitter.ParticlesAlive)
		{
			var _mass = _particles[# BBMOD_EParticle.Mass, _particleIndex];
			if (_mass != 0.0)
			{
				var _dragHalf = _particles[# BBMOD_EParticle.Drag, _particleIndex] * 0.5;
				var _velocityX = _particles[# BBMOD_EParticle.VelocityX, _particleIndex];
				var _velocityY = _particles[# BBMOD_EParticle.VelocityY, _particleIndex];
				var _velocityZ = _particles[# BBMOD_EParticle.VelocityZ, _particleIndex];
				_particles[# BBMOD_EParticle.AccelerationX, _particleIndex] -=
					(_dragHalf * _velocityX * abs(_velocityX)) / _mass;
				_particles[# BBMOD_EParticle.AccelerationY, _particleIndex] -=
					(_dragHalf * _velocityY * abs(_velocityY)) / _mass;
				_particles[# BBMOD_EParticle.AccelerationZ, _particleIndex] -=
					(_dragHalf * _velocityZ * abs(_velocityZ)) / _mass;
			}
			++_particleIndex;
		}
	};
}
