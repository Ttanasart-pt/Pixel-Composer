/// @func BBMOD_MixQuaternionFromHealthModule([_property[, _from[, _to]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that mixes particles' quaternion
/// property between two values based on their remaining health.
///
/// @param {Real} [_property] The first of the four consecutive properties that
/// together form a quaternion. Use values from {@link BBMOD_EParticle}.
/// Defaults to `undefined`.
/// @param {Struct.BBMOD_Quaternion} [_from] The quaternion when the particle has
/// a full health. Defaults to an identity quaternion.
/// @param {Struct.BBMOD_Quaternion} [_to] The quaternion when the particle has
/// no health left. Defaults to `_from`.
///
/// @see BBMOD_EParticle
function BBMOD_MixQuaternionFromHealthModule(
	_property=undefined,
	_from=new BBMOD_Quaternion(),
	_to=_from.Clone()
) : BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} The first of the four consecutive properties that together
	/// form a quaternion. Use values from {@link BBMOD_EParticle}. Default
	/// value is `undefined`.
	Property = _property;

	/// @var {Struct.BBMOD_Quaternion} The quaternion when the particle has full
	/// health. Default value is an identity quaternion.
	From = _from;

	/// @var {Struct.BBMOD_Quaternion} The quaternion when the particle has no
	/// health left. Default value is the same as
	/// {@link BBMOD_MixQuaternionFromHealthModule.From}.
	To = _to;

	static on_update = function (_emitter, _deltaTime) {
		var _property = Property;
		if (_property != undefined)
		{
			var _to = To;
			var _from = From;
			var _particles = _emitter.Particles;

			var _particleIndex = 0;
			repeat (_emitter.ParticlesAlive)
			{
				var _factor = clamp(_particles[# BBMOD_EParticle.HealthLeft, _particleIndex]
					/ _particles[# BBMOD_EParticle.Health, _particleIndex], 0.0, 1.0);
				var _quat = _to.Slerp(_from, _factor);
				_particles[# _property, _particleIndex]     = _quat.X;
				_particles[# _property + 1, _particleIndex] = _quat.Y;
				_particles[# _property + 2, _particleIndex] = _quat.Z;
				_particles[# _property + 3, _particleIndex] = _quat.W;
				++_particleIndex;
			}
		}
	};
}
