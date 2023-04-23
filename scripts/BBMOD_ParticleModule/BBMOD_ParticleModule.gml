/// @func BBMOD_ParticleModule()
///
/// @desc BBMOD_Class
///
/// @desc Base struct for particle modules. These are composed into particle
/// system to define behavior of their particles.
///
/// @see BBMOD_ParticleSystem
function BBMOD_ParticleModule()
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Bool} If `true` then the module is enabled. Defaults value
	/// is `true`.
	Enabled = true;

	/// @func on_start(_emitter)
	/// @desc Executed at the beginning of the emitter's emission cycle and
	/// every time it loops.
	/// @param {Struct.BBMOD_ParticleEmitter} _emitter The emitter.
	static on_start = undefined;

	/// @func on_update(_emitter, _deltaTime)
	/// @desc Executed every time the emitter is updated.
	/// @param {Struct.BBMOD_ParticleEmitter} _emitter The emitter.
	/// @param {Real} _deltaTime How much time in microseconds has passed since
	/// the last frame.
	static on_update = undefined;

	/// @func on_finish(_emitter)
	/// @desc Executed once at the end of the emitter's emission cycle. Never
	/// executed if the emitted particle system is looping!
	/// @param {Struct.BBMOD_ParticleEmitter} _emitter The emitter.
	static on_finish = undefined;

	/// @func on_particle_start(_emitter, _particleIndex)
	/// @desc Executed when a new particle is spawned.
	/// @param {Struct.BBMOD_ParticleEmitter} _emitter The emitter.
	/// @param {Real} _particleIndex The row within
	/// {@link BBMOD_ParticleEmitter.Particles} at which is the particle stored.
	static on_particle_start = undefined;

	/// @func (_emitter, _particleIndex)
	/// @desc Executed when a particle dies.
	/// @param {Struct.BBMOD_ParticleEmitter} _emitter The emitter.
	/// @param {Real} _particleIndex The row within
	/// {@link BBMOD_ParticleEmitter.Particles} at which is the particle stored.
	static on_particle_finish = undefined;
}
