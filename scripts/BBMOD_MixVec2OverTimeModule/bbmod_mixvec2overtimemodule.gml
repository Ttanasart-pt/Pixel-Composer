/// @func BBMOD_MixVec2OverTimeModule([_property[, _from[, _to[, _duration]]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that mixes values of particles' two
/// consecutive properties between two values based on their time alive.
///
/// @param {Real} [_property] The first of the two consecutive properties. Use
/// values from {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Struct.BBMOD_Vec2} [_from] The value when the particle has full health.
/// Defaults to `(0.0, 0.0)`.
/// @param {Struct.BBMOD_Vec2} [_to] The value when the particle has no health left.
/// Defaults to `_from`.
/// @param {Real} [_duration] How long in seconds it takes to mix between the
/// two values. Defaults to 1.0.
///
/// @see BBMOD_EParticle
function BBMOD_MixVec2OverTimeModule(
	_property=undefined,
	_from=new BBMOD_Vec2(),
	_to=_from.Clone(),
	_duration=1.0
) : BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} The first of the two consecutive properties. Use values from
	/// {@link BBMOD_EParticle}. Default value is `undefined`.
	Property = _property;

	/// @var {Struct.BBMOD_Vec2} The value when the particle has full health.
	/// Default value is `(0.0, 0.0)`.
	From = _from;

	/// @var {Struct.BBMOD_Vec2} The value when the particle has no health left.
	/// Default value is the same as {@link BBMOD_MixVec2OverTimeModule.From}.
	To = _to;

	/// @var {Real} How long in seconds it takes to mix between the two values.
	/// Default value is 1.0.
	Duration = _duration;

	static on_update = function (_emitter, _deltaTime) {
		var _property = Property;
		if (_property != undefined)
		{
			var _to = To;
			var _toX = _to.X;
			var _toY = _to.Y;
			var _from = From;
			var _fromX = _from.X;
			var _fromY = _from.Y;
			var _particles = _emitter.Particles;
			var _duration = Duration;

			var _particleIndex = 0;
			repeat (_emitter.ParticlesAlive)
			{
				var _factor = clamp(_particles[# BBMOD_EParticle.TimeAlive, _particleIndex] / _duration, 0.0, 1.0);
				_particles[# _property, _particleIndex]     = lerp(_toX, _fromX, _factor);
				_particles[# _property + 1, _particleIndex] = lerp(_toY, _fromY, _factor);
				++_particleIndex;
			}
		}
	};
}
