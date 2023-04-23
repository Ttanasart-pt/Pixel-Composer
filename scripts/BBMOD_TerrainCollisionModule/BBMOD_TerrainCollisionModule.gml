/// @func BBMOD_TerrainCollisionModule([_terrain])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that handles collisions with a terrain.
///
/// @param {Struct.BBMOD_Terrain} [_terrain] The terrain to collide with.
/// Defaults to `undefined`.
function BBMOD_TerrainCollisionModule(_terrain=undefined)
	: BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Struct.BBMOD_Terrain} The terrain to collide with. Default value
	/// is `undefined`.
	Terrain = _terrain;

	static on_update = function (_emitter, _deltaTime) {
		var _terrain = Terrain;
		if (!_terrain)
		{
			return;
		}
		var _particles = _emitter.Particles;
		var _particleIndex = 0;
		repeat (_emitter.ParticlesAlive)
		{
			var _positionX = _particles[# BBMOD_EParticle.PositionX, _particleIndex];
			var _positionY = _particles[# BBMOD_EParticle.PositionY, _particleIndex];
			var _terrainZ = _terrain.get_height(_positionX, _positionY);
			if (_terrainZ != undefined)
			{
				var _positionZ = _particles[# BBMOD_EParticle.PositionZ, _particleIndex];
				if (_positionZ < _terrainZ)
				{
					_particles[# BBMOD_EParticle.PositionZ, _particleIndex] = _terrainZ;
					var _normal = _terrain.get_normal(_positionX, _positionY);
					var _velocityX = _particles[# BBMOD_EParticle.VelocityX, _particleIndex];
					var _velocityY = _particles[# BBMOD_EParticle.VelocityY, _particleIndex];
					var _velocityZ = _particles[# BBMOD_EParticle.VelocityZ, _particleIndex];
					var _dot2 = (
						  _velocityX * _normal.X
						+ _velocityY * _normal.Y
						+ _velocityZ * _normal.Z
					) * 2.0;
					var _bounce = _particles[# BBMOD_EParticle.Bounce, _particleIndex];
					_particles[# BBMOD_EParticle.VelocityX, _particleIndex] =
						(_velocityX - (_dot2 * _normal.X)) * _bounce;
					_particles[# BBMOD_EParticle.VelocityY, _particleIndex] =
						(_velocityY - (_dot2 * _normal.Y)) * _bounce;
					_particles[# BBMOD_EParticle.VelocityZ, _particleIndex] =
						(_velocityZ - (_dot2 * _normal.Z)) * _bounce;
					_particles[# BBMOD_EParticle.HasCollided, _particleIndex] =
						true;
				}
			}
			++_particleIndex;
		}
	};
}
