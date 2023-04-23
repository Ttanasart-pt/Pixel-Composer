/// @func BBMOD_MixQuaternionModule([_property[, _from[, _to]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that randomly mixes particles' quaternion
/// property when they are spawned.
///
/// @param {Real} [_property] The first of the four consecutive properties that
/// together form a quaternion. Use values from {@link BBMOD_EParticle}. Defaults
/// to `undefined`.
/// @param {Struct.BBMOD_Quaternion} [_from] The quaternion to mix from. Defaults to
/// an identity quaternion.
/// @param {Struct.BBMOD_Quaternion} [_to] The quaternion to mix to. Defaults to `_from`.
///
/// @see BBMOD_EParticle
function BBMOD_MixQuaternionModule(
	_property=undefined,
	_from=new BBMOD_Quaternion(),
	_to=_from.Clone()
) : BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} The first of the four consecutive properties that together
	/// form a quaternion. Use values from {@link BBMOD_EParticle}. Default value
	/// is `undefined`.
	Property = _property;

	/// @var {Struct.BBMOD_Quaternion} The quaternion to mix from. Default value is
	/// an identity quaternion.
	From = _from;

	/// @var {Struct.BBMOD_Quaternion} The quaternion to mix to. Default value is the
	/// same as {@link BBMOD_MixQuaternionModule.From}.
	To = _to;

	static on_particle_start = function (_emitter, _particleIndex) {
		if (Property != undefined)
		{
			var _quat = From.Slerp(To, random(1.0));
			_emitter.Particles[# Property, _particleIndex]     = _quat.X;
			_emitter.Particles[# Property + 1, _particleIndex] = _quat.Y;
			_emitter.Particles[# Property + 2, _particleIndex] = _quat.Z;
			_emitter.Particles[# Property + 3, _particleIndex] = _quat.W;
		}
	};
}
