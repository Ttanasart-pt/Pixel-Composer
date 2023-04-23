/// @func BBMOD_SphereEmissionModule([_radius[, _inside]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that positions spawned particles into a sphere
/// shape.
///
/// @param {Real} [_radius] The radius of the sphere. Defaults to 0.5.
/// @param {Bool} [_inside] Whether the particles can be spawned inside the
/// sphere.
/// Defaults to `true`.
///
/// @see BBMOD_EParticle.PositionX
/// @see BBMOD_EParticle.PositionY
/// @see BBMOD_EParticle.PositionZ
function BBMOD_SphereEmissionModule(_radius=0.5, _inside=true)
	: BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} The radius of the sphere. Default value is 0.5.
	Radius = _radius;

	/// @var {Bool} If `true`, then the particles can be spawned inside the sphere.
	/// Default value is `true`.
	Inside = _inside;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _offsetX = random_range(-1.0, 1.0);
		var _offsetY = random_range(-1.0, 1.0);
		var _offsetZ = random_range(-1.0, 1.0);
		var _scale = (Inside ? random(Radius) : Radius)
			/ point_distance_3d(0.0, 0.0, 0.0, _offsetX, _offsetY, _offsetZ);
		var _particles = _emitter.Particles;

		_particles[# BBMOD_EParticle.PositionX, _particleIndex] += _offsetX * _scale;
		_particles[# BBMOD_EParticle.PositionY, _particleIndex] += _offsetY * _scale;
		_particles[# BBMOD_EParticle.PositionZ, _particleIndex] += _offsetZ * _scale;
	};
}
