/// @func BBMOD_ParticleSystem(_model, _material, _particleCount[, _batchSize])
///
/// @extends BBMOD_Class
///
/// @desc A collection of particle modules that together define behavior of
/// particles.
///
/// @param {Struct.BBMOD_Model} _model The particle model.
/// @param {Struct.BBMOD_Material} _material The material used by the particle
/// system.
/// @param {Real} _particleCount Maximum number of particles alive in the
/// system.
/// @param {Real} [_batchSize] Number of particles rendered in a single draw
/// call. Default value is 32.
///
/// @see BBMOD_ParticleModule
/// @see BBMOD_ParticleEmitter
/// @see BBMOD_MODEL_PARTICLE
/// @see BBMOD_MATERIAL_PARTICLE_LIT
/// @see BBMOD_MATERIAL_PARTICLE_UNLIT
function BBMOD_ParticleSystem(_model, _material, _particleCount, _batchSize=32)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Class_destroy = destroy;

	/// @var {Struct.BBMOD_Material} _material The material used by the particle
	/// system.
	Material = _material;

	/// @var {Real} Maximum number of particles alive in the system.
	/// @readonly
	ParticleCount = _particleCount;

	/// @var {Bool} Use `true` to sort particles back to front. This should be
	/// enabled if you would like to use alpha blending. Default value is `false`.
	Sort = false;

	/// @var {Real} How long in seconds is the system emitting particles for.
	/// Default value is 5s.
	Duration = 5.0;

	/// @var {Bool} If `true` then the emission cycle repeats after the duration.
	/// Default value is `false`.
	Loop = false;

	/// @var {Struct.BBMOD_DynamicBatch}
	/// @private
	__dynamicBatch = new BBMOD_DynamicBatch(_model, _batchSize).freeze();

	/// @var {Array<Struct.BBMOD_ParticleModule>} An array of modules
	/// affecting individual particles in this system.
	/// @readonly
	Modules = [];

	/// @func add_modules(_module...)
	///
	/// @desc Adds modules to the particle system.
	///
	/// @param {Struct.BBMOD_ParticleModule} _module The module to add.
	///
	/// @return {Struct.BBMOD_ParticleSystem} Returns `self`.
	///
	/// @see BBMOD_ParticleModule
	static add_modules = function (_module) {
		gml_pragma("forceinline");
		var i = 0;
		repeat (argument_count)
		{
			array_push(Modules, argument[i++]);
		}
		return self;
	};

	static destroy = function () {
		Class_destroy();
		__dynamicBatch = __dynamicBatch.destroy();
		return undefined;
	};
}
