/// @func BBMOD_RandomRotationModule([_axis[, _from[, _to]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that randomly sets particles' rotation on their spawn.
///
/// @param {Struct.BBMOD_Vec3} [_axis] The axis of rotation. Defaults to
/// {@link BBMOD_VEC3_UP}.
/// @param {Real} [_from] The minimum angle of rotation. Defaults to 0.
/// @param {Real} [_to] The maximum angle of rotation. Defaults to 360.
///
/// @see BBMOD_EParticle.RotationX
/// @see BBMOD_EParticle.RotationY
/// @see BBMOD_EParticle.RotationZ
/// @see BBMOD_EParticle.RotationW
function BBMOD_RandomRotationModule(_axis=BBMOD_VEC3_UP, _from=0.0, _to=360.0)
	: BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Struct.BBMOD_Vec3} The axis of rotation. Default value is
	/// {@link BBMOD_VEC3_UP}.
	Axis = _axis;

	/// @var {Real} The minimum angle of rotation. Default value is 0.
	From = _from;

	/// @var {Real} The maximum angle of rotation. Default value is 360.
	To = _to;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _rotation = new BBMOD_Quaternion().FromAxisAngle(Axis, random_range(From, To));
		_emitter.Particles[# BBMOD_EParticle.RotationX, _particleIndex] = _rotation.X;
		_emitter.Particles[# BBMOD_EParticle.RotationY, _particleIndex] = _rotation.Y;
		_emitter.Particles[# BBMOD_EParticle.RotationZ, _particleIndex] = _rotation.Z;
		_emitter.Particles[# BBMOD_EParticle.RotationW, _particleIndex] = _rotation.W;
	};
}
