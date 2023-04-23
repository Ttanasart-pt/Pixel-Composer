/// @func BBMOD_MixVec4Module([_property[, _from[, _to[, _separate]]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that randomly mixes initial values of
/// particles' four consecutive properties between two values  when they are
/// spawned.
///
/// @param {Real} [_property] The first of the four consecutive properties. Use
/// values from {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Struct.BBMOD_Vec4} [_from] The value to mix from. Defaults to
/// `(0.0, 0.0, 0.0, 0.0)`.
/// @param {Struct.BBMOD_Vec4} [_to] The value to mix to. Defaults to `_from`.
/// @param {Bool} [_separate] If `true`, then each component is mixed independently
/// on other components, otherwise all components are mixed using the same factor.
/// Defaults to `true`.
///
/// @see BBMOD_EParticle
function BBMOD_MixVec4Module(
	_property=undefined,
	_from=new BBMOD_Vec4(),
	_to=_from.Clone(),
	_separate=true
) : BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} The first of the four consecutive properties. Use values
	/// from {@link BBMOD_EParticle}. Default value is `undefined`.
	Property = _property;

	/// @var {Struct.BBMOD_Vec4} The initial value to mix from. Default value is
	/// `(0.0, 0.0, 0.0, 0.0)`.
	From = _from;

	/// @var {Struct.BBMOD_Vec4} The initial value to mix to. Default value is the
	/// same as {@link BBMOD_MixVec4Module.From}.
	To = _to;

	/// @var {Bool} If `true`, then each component is mixed independently on other
	/// components. Default value is `true`.
	Separate = _separate;

	static on_particle_start = function (_emitter, _particleIndex) {
		if (Property != undefined)
		{
			var _separate = Separate;
			var _factor = random(1.0);
			_emitter.Particles[# Property, _particleIndex]     = lerp(From.X, To.X, _factor);
			_emitter.Particles[# Property + 1, _particleIndex] = lerp(From.Y, To.Y, _separate ? random(1.0) : _factor);
			_emitter.Particles[# Property + 2, _particleIndex] = lerp(From.Z, To.Z, _separate ? random(1.0) : _factor);
			_emitter.Particles[# Property + 3, _particleIndex] = lerp(From.W, To.W, _separate ? random(1.0) : _factor);
		}
	};
}
