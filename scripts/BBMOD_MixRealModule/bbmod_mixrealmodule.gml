/// @func BBMOD_MixRealModule([_property[, _from[, _to]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that randomly mixes initial value of
/// particles' property between two values when they are spawned.
///
/// @param {Real} [_property] The property to set initial value of. Use values
/// from {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Real} [_from] The value to mix from. Defaults to 0.0.
/// @param {Real} [_to] The value to mix to. Defaults to `_from`.
///
/// @see BBMOD_EParticle
function BBMOD_MixRealModule(_property=undefined, _from=0.0, _to=_from)
	: BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} The property to set initial value of. Use values from
	/// {@link BBMOD_EParticle}. Default value is `undefined`.
	Property = _property;

	/// @var {Real} The initial value to mix from. Default value is 0.0.
	From = _from;

	/// @var {Real} The initial value to mix to. Default value is the same as
	/// {@link BBMOD_MixRealModule.From}.
	To = _to;

	static on_particle_start = function (_emitter, _particleIndex) {
		if (Property != undefined)
		{
			_emitter.Particles[# Property, _particleIndex] = lerp(From, To, random(1.0));
		}
	};
}
