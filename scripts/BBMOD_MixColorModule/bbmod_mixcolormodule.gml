/// @func BBMOD_MixColorModule([_property[, _from[, _to]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that randomly mixes particles' color
/// property when they are spawned.
///
/// @param {Real} [_property] The first of the four consecutive properties that
/// together form a color. Use values from {@link BBMOD_EParticle}. Defaults to
/// `undefined`.
/// @param {Struct.BBMOD_Color} [_from] The color to mix from. Defaults to
/// {@link BBMOD_C_WHITE}.
/// @param {Struct.BBMOD_Color} [_to] The value to mix to. Defaults to `_from`.
///
/// @see BBMOD_EParticle
function BBMOD_MixColorModule(
	_property=undefined,
	_from=BBMOD_C_WHITE,
	_to=_from.Clone()
) : BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} The first of the four consecutive properties that together
	/// form a color. Use values from {@link BBMOD_EParticle}. Default value is
	/// `undefined`.
	Property = _property;

	/// @var {Struct.BBMOD_Color} The color to mix from. Default value is
	/// {@link BBMOD_C_WHITE}.
	From = _from;

	/// @var {Struct.BBMOD_Color} The color to mix to. Default value is the
	/// same as {@link BBMOD_MixColorModule.From}.
	To = _to;

	static on_particle_start = function (_emitter, _particleIndex) {
		if (Property != undefined)
		{
			var _from = From;
			var _to = To;
			var _factor = random(1.0);
			_emitter.Particles[# Property, _particleIndex]     = lerp(_from.Red, _to.Red, _factor);
			_emitter.Particles[# Property + 1, _particleIndex] = lerp(_from.Green, _to.Green, _factor);
			_emitter.Particles[# Property + 2, _particleIndex] = lerp(_from.Blue, _to.Blue, _factor);
			_emitter.Particles[# Property + 3, _particleIndex] = lerp(_from.Alpha, _to.Alpha, _factor);
		}
	};
}
