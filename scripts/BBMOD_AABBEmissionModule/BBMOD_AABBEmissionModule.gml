/// @func BBMOD_AABBEmissionModule([_min[, _max[, _inside]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that positions spawned particles into an AABB shape.
///
/// @param {Struct.BBMOD_Vec3} [_min] The minimum coordinate of the AABB.
/// Defaults to `(-0.5, -0.5, -0.5)`.
/// @param {Struct.BBMOD_Vec3} [_max] The maximum coordinate of the AABB.
/// Defaults to `(0.5, 0.5, 0.5)`.
/// @param {Bool} [_inside] If `true` then the particles can be spawned inside
/// of the AABB. Defaults to `true`.
///
/// @see BBMOD_EParticle.PositionX
/// @see BBMOD_EParticle.PositionY
/// @see BBMOD_EParticle.PositionZ
function BBMOD_AABBEmissionModule(
	_min=new BBMOD_Vec3(-0.5),
	_max=new BBMOD_Vec3(0.5),
	_inside=true
) : BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} The minimum coordinate of the AABB. Default value is
	/// to `(-0.5, -0.5, -0.5)`.
	Min = _min;

	/// @var {Real} The maximum coordinate of the AABB. Default value is
	/// to `(0.5, 0.5, 0.5)`.
	Max = _max;

	/// @var {Bool} If `true` then the particles can be spawned inside of
	/// the AABB. Default value is `true`.
	Inside = _inside;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _side = choose(0, 1, 2);
		_emitter.Particles[# BBMOD_EParticle.PositionX, _particleIndex] +=
			(Inside || _side != 0) ? random_range(Min.X, Max.X) : choose(Min.X, Max.X);
		_emitter.Particles[# BBMOD_EParticle.PositionY, _particleIndex] +=
			(Inside || _side != 1) ? random_range(Min.Y, Max.Y) : choose(Min.Y, Max.Y);
		_emitter.Particles[# BBMOD_EParticle.PositionZ, _particleIndex] +=
			(Inside || _side != 2) ? random_range(Min.Z, Max.Z) : choose(Min.Z, Max.Z);
	};
}
