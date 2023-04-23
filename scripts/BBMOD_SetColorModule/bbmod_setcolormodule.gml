/// @func BBMOD_SetColorModule([_property[, _value]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that sets initial value of particles'
/// color property when they are spawned.
///
/// @param {Real} [_property] The first of the four properties that together
/// form a color. Use values from {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Struct.BBMOD_Color} [_value] The initial value of the color
/// property. Defaults to {@link BBMOD_C_WHITE}.
///
/// @see BBMOD_EParticle
function BBMOD_SetColorModule(_property=undefined, _value=BBMOD_C_WHITE)
	: BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} The first of the four properties that together form a color.
	/// Use values from {@link BBMOD_EParticle}. Default value is `undefined`.
	Property = _property;

	/// @var {Struct.BBMOD_Color} The initial value of the color
	/// property. Default value is {@link BBMOD_C_WHITE}.
	Value = _value;

	static on_particle_start = function (_emitter, _particleIndex) {
		if (Property != undefined)
		{
			var _value = Value;
			_emitter.Particles[# Property, _particleIndex]     = _value.Red;
			_emitter.Particles[# Property + 1, _particleIndex] = _value.Green;
			_emitter.Particles[# Property + 2, _particleIndex] = _value.Blue;
			_emitter.Particles[# Property + 3, _particleIndex] = _value.Alpha;
		}
	};
}
