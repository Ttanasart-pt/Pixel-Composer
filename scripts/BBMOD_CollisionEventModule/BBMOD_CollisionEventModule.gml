/// @func BBMOD_CollisionEventModule([_callback])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that executes a callback on particle collision.
///
/// @param {Function} [_callback] The function to execute. Must take the emitter
/// as the first argument and the particle's index as the second argument.
/// Defaults to `undefined`.
///
/// @see BBMOD_EParticle.HasCollided
/// @see BBMOD_ParticleEmitter
/// @see BBMOD_ParticleEmitter.Particles
function BBMOD_CollisionEventModule(_callback=undefined)
	: BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Function} The function to execute on particle collision. Must take
	/// the emitter as the first argument and the particle's index as the second
	/// argument. Default value is `undefined`.
	/// @see BBMOD_ParticleEmitter
	/// @see BBMOD_ParticleEmitter.Particles
	Callback = _callback;

	static on_update = function (_emitter, _deltaTime) {
		var _callback = Callback;
		if (!_callback)
		{
			return;
		}
		var _particles = _emitter.Particles;
		var _particleIndex = 0;
		repeat (_emitter.ParticlesAlive)
		{
			if (_particles[# BBMOD_EParticle.HasCollided, _particleIndex])
			{
				_callback(_emitter, _particleIndex);
			}
			++_particleIndex;
		}
	};
}
