/// @func BBMOD_EmissionModule([_count])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that spawns particles at the start of a particle
/// emitter's life.
///
/// @param {Real} [_count] Number of particles to spawn. Defaults to 1.
function BBMOD_EmissionModule(_count=1)
	: BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} Number of particles to spawn.
	Count = _count;

	static on_start = function (_emitter) {
		repeat (Count)
		{
			_emitter.spawn_particle();
		}
	};
}
