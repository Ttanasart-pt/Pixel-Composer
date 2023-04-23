/// @func BBMOD_MixSpeedModule([_from[, _to]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that randomly sets initial magnitude of particles'
/// velocity vector.
///
/// @param {Real} [_from] The minimum velocity vector magnitude. Defaults to 1.0.
/// @param {Real} [_to] The maximum velocity vector magnitude. Defaults to `_from`.
///
/// @see BBMOD_EParticle.VelocityX
/// @see BBMOD_EParticle.VelocityY
/// @see BBMOD_EParticle.VelocityZ
function BBMOD_MixSpeedModule(_from=1.0, _to=_from)
	: BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} The minimum velocity vector magnitude. Default value is 1.0.
	From = _from;

	/// @var {Real} The maximum velocity vector magnitude. Default value is the
	/// same as {@link BBMOD_MixSpeedModule.From}.
	To = _to;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _particles = _emitter.Particles;
		var _velocityX = _particles[# BBMOD_EParticle.VelocityX, _particleIndex];
		var _velocityY = _particles[# BBMOD_EParticle.VelocityY, _particleIndex];
		var _velocityZ = _particles[# BBMOD_EParticle.VelocityZ, _particleIndex];
		var _norm = sqrt((_velocityX * _velocityX) + (_velocityY * _velocityY) + (_velocityZ * _velocityZ));
		var _factor = lerp(From, To, random(1.0)) / max(_norm, 0.001);
		_particles[# BBMOD_EParticle.VelocityX, _particleIndex] = _velocityX * _factor;
		_particles[# BBMOD_EParticle.VelocityY, _particleIndex] = _velocityY * _factor;
		_particles[# BBMOD_EParticle.VelocityZ, _particleIndex] = _velocityZ * _factor;
	};
}
