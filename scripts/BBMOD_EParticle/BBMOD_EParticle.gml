/// @enum Enumeration of particle properties.
/// @see BBMOD_ParticleEmitter.Particles
enum BBMOD_EParticle
{
	/// @member The ID of the particle, unique within the emitter which spawned
	/// it.
	Id,
	/// @member Whether the particle is alive. If not, then the rest of the data
	/// can be nonsense. All particles within a particle system are dead at the
	/// start.
	IsAlive,
	/// @member How long in seconds has the particle been alive for. This is set
	/// to 0 on spawn and increases on every update.
	TimeAlive,
	/// @member The particle's initial health value. Default value is 1.
	Health,
	/// @member The particle's remaining health. The particle dies when this
	/// reaches 0. Default value is 1, same as for {@link BBMOD_EParticle.Health}.
	HealthLeft,
	/// @member The particle's X position in world-space. This is set to the
	/// emitter's X position on spawn.
	PositionX,
	/// @member The particle's Y position in world-space. This is set to the
	/// emitter's Y position on spawn.
	PositionY,
	/// @member The particle's Z position in world-space. This is set to the
	/// emitter's Z position on spawn.
	PositionZ,
	/// @member The particle's velocity on the X axis. Default value is 0.
	VelocityX,
	/// @member The particle's velocity on the Y axis. Default value is 0.
	VelocityY,
	/// @member The particle's velocity on the Z axis. Default value is 0.
	VelocityZ,
	/// @member The particle's acceleration on the X axis. Default value is 0.
	AccelerationX,
	/// @member The particle's acceleration on the Y axis. Default value is 0.
	AccelerationY,
	/// @member The particle's acceleration on the Z axis. Default value is 0.
	AccelerationZ,
	/// @member The mass of the particle. Default value is 1 unit.
	Mass,
	/// @member The particle's resistance to motion. Default value is 0.
	Drag,
	/// @member Modulates particle velocity on collision. Default value is 0.
	Bounce,
	/// @member If `true` then the particle has collided. This is set to
	/// `false` at the beginning of every update.
	HasCollided,
	/// @member Internal use only!
	AccelerationRealX,
	/// @member Internal use only!
	AccelerationRealY,
	/// @member Internal use only!
	AccelerationRealZ,
	/// @member The first component of the particle's quaternion rotation.
	/// Default value is 0.
	RotationX,
	/// @member The second component of the particle's quaternion rotation.
	/// Default value is 0.
	RotationY,
	/// @member The third component of the particle's quaternion rotation.
	/// Default value is 0.
	RotationZ,
	/// @member The fourth component of the particle's quaternion rotation.
	/// Default value is 1.
	RotationW,
	/// @member The particle's scale on the X axis. Default value is 1.
	ScaleX,
	/// @member The particle's scale on the Y axis. Default value is 1.
	ScaleY,
	/// @member The particle's scale on the Z axis. Default value is 1.
	ScaleZ,
	/// @member The red value of the particle's color. Default value is 255.
	ColorR,
	/// @member The green value of the particle's color. Default value is 255.
	ColorG,
	/// @member The blue value of the particle's color. Default value is 255.
	ColorB,
	/// @member The alpha value of the particle's color. Default value is 1.
	ColorA,
	/// @member Total number of members of this enum.
	SIZE,
};
