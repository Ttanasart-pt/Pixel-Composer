/// @func BBMOD_EmissionOverTimeModule([_count[, _interval]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that emits particles over time.
///
/// @param {Real} [_count] Number of particles to spawn each time. Defaults
/// to 1.
/// @param {Real} [_interval] Number of seconds to wait before spawning
/// next particles. Defaults to 1.0.
function BBMOD_EmissionOverTimeModule(_count=1, _interval=1.0)
	: BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} Number of particles to spawn each time. Default
	/// value is 1.
	Count = _count;

	/// @var {Real} Number of seconds to wait before spawning
	/// next particles. Default value is 1.0.
	Interval = _interval;

	/// @var {Real}
	/// @private
	__timer = 0.0;

	static on_update = function (_emitter, _deltaTime) {
		__timer += _deltaTime * 0.000001;
		if (__timer >= Interval)
		{
			repeat (Count)
			{
				_emitter.spawn_particle();
			}
			__timer = 0.0;
		}
	};
}
