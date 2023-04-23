/// @func BBMOD_MixRealFromSpeedModule([_property[, _from[, _to[, _min[, _max]]]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that mixes value of particles'
/// property between two values based on the magnitude of their velocity vector.
///
/// @param {Real} [_property] The property to set initial value of. Use values
/// from {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Real} [_from] The value when the particle has full health.
/// Defaults to 0.0.
/// @param {Real} [_to] The value when the particle has no health left.
/// Defaults to `_from`.
/// @param {Real} [_min] If the particles' speed is less than this, then the
/// property is equal to `_from`. Defaults to 0.0.
/// @param {Real} [_max] If the particles' speed is greater than this, then the
/// property is equal to `_to`. Defaults to 1.0.
///
/// @see BBMOD_EParticle
function BBMOD_MixRealFromSpeedModule(
	_property=undefined,
	_from=0.0,
	_to=_from,
	_min=0.0,
	_max=1.0
) : BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} The property to set initial value of. Use values from
	/// {@link BBMOD_EParticle}. Default value is `undefined`.
	Property = _property;

	/// @var {Real} The value when the particle has full health. Default value
	/// is 0.0.
	From = _from;

	/// @var {Real} The value when the particle has no health left. Default value
	/// is the same as {@link BBMOD_MixRealFromSpeedModule.From}.
	To = _to;

	/// @var {Real} If the particles' speed is less than this, then the property
	/// is equal to {@link BBMOD_MixRealFromSpeedModule.From}. Default value is 0.0.
	Min = _min;

	/// @var {Real} If the particles' speed is greater than this, then the property
	/// is equal to {@link BBMOD_MixRealFromSpeedModule.To}. Default value is 1.0.
	Max = _max;

	static on_update = function (_emitter, _deltaTime) {
		var _property = Property;
		if (_property != undefined)
		{
			var _to = To;
			var _from = From;
			var _particles = _emitter.Particles;
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
				_particles[# _property, _particleIndex] = lerp(_to, _from, _factor);
				++_particleIndex;
			}
		}
	};
}
