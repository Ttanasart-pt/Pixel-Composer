/// @func BBMOD_MixColorFromHealthModule([_property[, _from[, _to]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that mixes particles' color property
/// between two values based on their remaining health.
///
/// @param {Real} [_property] The first of the four consecutive properties that
/// together form a color. Use values from {@link BBMOD_EParticle}. Defaults to
/// `undefined`.
/// @param {Struct.BBMOD_Color} [_from] The color when the particle has full
/// health. Defaults to {@link BBMOD_C_WHITE}.
/// @param {Struct.BBMOD_Color} [_to] The color when the particle has no health
/// left. Defaults to `_from`.
///
/// @see BBMOD_EParticle
function BBMOD_MixColorFromHealthModule(
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

	/// @var {Struct.BBMOD_Color} The color when the particle has full
	/// health. Default value is {@link BBMOD_C_WHITE}.
	From = _from;

	/// @var {Struct.BBMOD_Color} The color when the particle has no health
	/// left. Default value is the same as {@link BBMOD_MixColorFromHealthModule.From}.
	To = _to;

	static on_update = function (_emitter, _deltaTime) {
		var _property = Property;
		if (_property != undefined)
		{
			var _particles = _emitter.Particles;
			var _from = From;
			var _fromR = _from.Red;
			var _fromG = _from.Green;
			var _fromB = _from.Blue;
			var _fromA = _from.Alpha;
			var _to = To;
			var _toR = _to.Red;
			var _toG = _to.Green;
			var _toB = _to.Blue;
			var _toA = _to.Alpha;

			var _particleIndex = 0;
			repeat (_emitter.ParticlesAlive)
			{
				var _factor = clamp(_particles[# BBMOD_EParticle.HealthLeft, _particleIndex]
					/ _particles[# BBMOD_EParticle.Health, _particleIndex], 0.0, 1.0);
				_particles[# _property, _particleIndex]     = lerp(_toR, _fromR, _factor);
				_particles[# _property + 1, _particleIndex] = lerp(_toG, _fromG, _factor);
				_particles[# _property + 2, _particleIndex] = lerp(_toB, _fromB, _factor);
				_particles[# _property + 3, _particleIndex] = lerp(_toA, _fromA, _factor);
				++_particleIndex;
			}
		}
	};
}
