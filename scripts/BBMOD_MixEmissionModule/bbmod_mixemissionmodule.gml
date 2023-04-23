/// @func BBMOD_MixEmissionModule([_from[, _to]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that spawns random number of particles at the start
/// of a particle emitter's life.
///
/// @param {Real} [_from] The minimum number of particles to spawn. Defaults to 1.
/// @param {Real} [_to] The maxmimum particles to spawn. Defaults to `_from`.
function BBMOD_MixEmissionModule(_from=1, _to=_from)
	: BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} The minimum number of particles to spawn. Default value is 1.
	From = _from;

	/// @var {Real} The maximum particles to spawn. Default value is the same as
	/// {@link BBMOD_MixEmissionModule.From}.
	To = _to;

	static on_start = function (_emitter) {
		repeat (irandom_range(From, To))
		{
			_emitter.spawn_particle();
		}
	};
}
