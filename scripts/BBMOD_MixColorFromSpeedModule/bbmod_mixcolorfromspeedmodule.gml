/// @func BBMOD_MixColorFromSpeedModule([_property[, _from[, _to[, _min[, _max]]]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that mixes particles' color property
/// between two values based on the magnitude of their velocity vector.
///
/// @param {Real} [_property] The first of the four consecutive properties that
/// together form a color. Use values from {@link BBMOD_EParticle}. Defaults to
/// `undefined`.
/// @param {Struct.BBMOD_Color} [_from] The color when the particle has full
/// health. Defaults to {@link BBMOD_C_WHITE}.
/// @param {Struct.BBMOD_Color} [_to] The color when the particle has no health
/// left. Defaults to `_from`.
/// @param {Real} [_min] If the particles' speed is less than this, then the
/// property is equal to `_from`. Defaults to 0.0.
/// @param {Real} [_max] If the particles' speed is greater than this, then the
/// property is equal to `_to`. Defaults to 1.0.
///
/// @see BBMOD_EParticle
function BBMOD_MixColorFromSpeedModule(
	_property=undefined,
	_from=BBMOD_C_WHITE,
	_to=_from.Clone(),
	_min=0.0,
	_max=1.0
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
	/// left. Default value is the same as {@link BBMOD_MixColorFromSpeedModule.From}.
	To = _to;

	/// @var {Real} If the particles' speed is less than this, then the property
	/// is equal to {@link BBMOD_ColorFromSpeedModule.From}. Default value is 0.0.
	Min = _min;

	/// @var {Real} If the particles' speed is greater than this, then the property
	/// is equal to {@link BBMOD_ColorFromSpeedModule.To}. Default value is 1.0.
	Max = _max;

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
			var _min = Min;
			var _max = Max;
			var _div = _max - _min;

			var _particleIndex = 0;
			repeat (_emitter.ParticlesAlive)
			{
				var _velX = _particles[# BBMOD_EParticle.VelocityX, _particleIndex];
				var _velY = _particles[# BBMOD_EParticle.VelocityY, _particleIndex];
				var _velZ = _particles[# BBMOD_EParticle.VelocityZ, _particleIndex];
				var _speed = sqrt((_velX * _velX) + (_velY + _velY) + (_velZ * _velZ));
				var _factor = clamp((_speed - _min) / _div, 0.0, 1.0);
				_particles[# _property, _particleIndex]     = lerp(_toR, _fromR, _factor);
				_particles[# _property + 1, _particleIndex] = lerp(_toG, _fromG, _factor);
				_particles[# _property + 2, _particleIndex] = lerp(_toB, _fromB, _factor);
				_particles[# _property + 3, _particleIndex] = lerp(_toA, _fromA, _factor);
				++_particleIndex;
			}
		}
	};
}
