/// @func BBMOD_ParticleEmitter(_position, _system)
///
/// @desc Emits particles at a specific position in the world. The behavior of
/// the emitted particles is defined by a particle system.
///
/// @param {Struct.BBMOD_Vec3} _position The emitter's position in world-space.
/// @param {Struct.BBMOD_ParticleSystem} _system The particle system that
/// defines behavior of emitted particles.
///
/// @see BBBMOD_ParticleSystem
function BBMOD_ParticleEmitter(_position, _system)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Class_destroy = destroy;

	/// @var {Struct.BBMOD_Vec3} The emitter's position in world-space.
	Position = _position;

	/// @var {Struct.BBMOD_ParticleSystem} The system of particles that this
	/// emitter emits.
	/// @readonly
	System = _system;

	/// @var {Id.DsGrid} Grid of particle data. Particles are stored in rows and
	/// particle data in columns. The order of particle data is defined in
	/// {@link BBMOD_EParticle}. Particles alive are stored first, followed by
	/// dead particles.
	Particles = ds_grid_create(BBMOD_EParticle.SIZE, System.ParticleCount);

	/// @var {Id.DsGrid} Grid used to do fast computations on all particles at
	/// once. Its dimensions are 4 x `System.ParticleCount`, i.e. sufficient for
	/// processing vec4s.
	GridCompute = ds_grid_create(4, System.ParticleCount);

	/// @var {Real} Number of particles that are alive.
	/// @readonly
	ParticlesAlive = 0;

	/// @var {Real} The index of the particle that will be spawned next if all
	/// particles are already alive.
	/// @private
	__particleSpawnNext = 0;

	/// @var {Real}
	/// @private
	__time = 0.0;

	// Initialize particle index
	ds_grid_clear(Particles, 0.0);

	for (var _particleIndex = 0;
		_particleIndex < System.ParticleCount;
		++_particleIndex)
	{
		Particles[# BBMOD_EParticle.Id, _particleIndex] = _particleIndex;
	}

	/// @func spawn_particle([_position])
	///
	/// @desc If the particle system has not reached the end of the emit cycle
	/// yet or if it is looping, then a new particle is spawned. If the maximum
	/// number of particles has already been reached, then an existing particle
	/// is used, without calling {@link BBMOD_ParticleModule.on_particle_finish}.
	///
	/// @param {Struct.BBMOD_Vec3} [_position] The position to spawn the particle
	/// at. Defaults to the emitter's position.
	///
	/// @return {Bool} Returns `true` if a particle was spawned.
	static spawn_particle = function (_position=undefined) {
		gml_pragma("forceinline");
		if (__time >= System.Duration && !System.Loop)
		{
			return false;
		}
		
		var _particleIndex;

		if (System.ParticleCount - ParticlesAlive > 0)
		{
			_particleIndex = ParticlesAlive++;
		}
		else
		{
			_particleIndex = __particleSpawnNext;
			if (++__particleSpawnNext >= System.ParticleCount)
			{
				__particleSpawnNext = 0;
			}
		}

		_position ??= Position;

		Particles[# BBMOD_EParticle.IsAlive, _particleIndex] = true;
		Particles[# BBMOD_EParticle.TimeAlive, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.Health, _particleIndex] = 1.0;
		Particles[# BBMOD_EParticle.HealthLeft, _particleIndex] = 1.0;
		Particles[# BBMOD_EParticle.PositionX, _particleIndex] = _position.X;
		Particles[# BBMOD_EParticle.PositionY, _particleIndex] = _position.Y;
		Particles[# BBMOD_EParticle.PositionZ, _particleIndex] = _position.Z;
		Particles[# BBMOD_EParticle.VelocityX, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.VelocityY, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.VelocityZ, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.AccelerationX, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.AccelerationY, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.AccelerationZ, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.Mass, _particleIndex] = 1.0;
		Particles[# BBMOD_EParticle.Drag, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.Bounce, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.HasCollided, _particleIndex] = false;
		Particles[# BBMOD_EParticle.AccelerationRealX, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.AccelerationRealY, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.AccelerationRealZ, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.RotationX, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.RotationY, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.RotationZ, _particleIndex] = 0.0;
		Particles[# BBMOD_EParticle.RotationW, _particleIndex] = 1.0;
		Particles[# BBMOD_EParticle.ScaleX, _particleIndex] = 1.0;
		Particles[# BBMOD_EParticle.ScaleY, _particleIndex] = 1.0;
		Particles[# BBMOD_EParticle.ScaleZ, _particleIndex] = 1.0;
		Particles[# BBMOD_EParticle.ColorR, _particleIndex] = 255.0;
		Particles[# BBMOD_EParticle.ColorG, _particleIndex] = 255.0;
		Particles[# BBMOD_EParticle.ColorB, _particleIndex] = 255.0;
		Particles[# BBMOD_EParticle.ColorA, _particleIndex] = 1.0;

		var _modules = System.Modules;
		var m = 0;
		repeat (array_length(_modules))
		{
			var _module = _modules[m++];
			if (_module.Enabled && _module.on_particle_start)
			{
				_module.on_particle_start(self, _particleIndex);
			}
		}

		return true;
	};

	/// @func update(_deltaTime)
	///
	/// @desc Updates the emitter and all its particles.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	///
	/// @return {Struct.BBMOD_ParticleEmitter} Returns `self`.
	static update = function (_deltaTime) {
		if (finished(true))
		{
			return self;
		}

		var _deltaTimeS = _deltaTime * 0.000001;
		var _modules = System.Modules;

		var _timeStart = (__time == 0.0 && _deltaTime != 0.0);
		__time += _deltaTimeS;
		var _timeOut = (__time >= System.Duration);
		if (_timeOut && System.Loop)
		{
			__time = 0.0;
		}

		var _temp1 = _deltaTimeS * 0.5;
		var _temp2 = _deltaTimeS * _deltaTimeS * 0.5;

		////////////////////////////////////////////////////////////////////////
		// Kill particles
		for (var _particleIndex = 0;
			_particleIndex < ParticlesAlive;
			++_particleIndex)
		{
			if (Particles[# BBMOD_EParticle.HealthLeft, _particleIndex] <= 0.0)
			{
				var m = 0;
				repeat (array_length(_modules))
				{
					var _module = _modules[m++];
					if (_module.Enabled && _module.on_particle_finish)
					{
						_module.on_particle_finish(self, _particleIndex);
					}
				}

				// Swap with alive particle that is stored last
				var _lastAlive = ParticlesAlive - 1;
				var _particleId = Particles[# BBMOD_EParticle.Id, _particleIndex];
				ds_grid_set_grid_region(
					Particles,
					Particles,
					0, _lastAlive,
					BBMOD_EParticle.SIZE - 1, _lastAlive,
					0, _particleIndex);
				Particles[# BBMOD_ERenderPass.Id, _lastAlive] = _particleId;
				Particles[# BBMOD_EParticle.IsAlive, _lastAlive] = false;

				--ParticlesAlive;
				--_particleIndex;
			}
		}

		////////////////////////////////////////////////////////////////////////
		// Particle pre-simulation
		if (ParticlesAlive > 0)
		{
			////////////////////////////////////////////////////////////////////
			// Clear HasCollided
			ds_grid_set_region(
				Particles,
				BBMOD_EParticle.HasCollided, 0,
				BBMOD_EParticle.HasCollided, ParticlesAlive - 1,
				false);

			////////////////////////////////////////////////////////////////////
			// Time alive
			ds_grid_add_region(
				Particles,
				BBMOD_EParticle.TimeAlive, 0,
				BBMOD_EParticle.TimeAlive, ParticlesAlive - 1,
				_deltaTimeS);

			////////////////////////////////////////////////////////////////////
			// Physics

			// position += velocity * _deltaTimeS:
			ds_grid_set_grid_region(
				GridCompute,
				Particles,
				BBMOD_EParticle.VelocityX, 0,
				BBMOD_EParticle.VelocityZ, ParticlesAlive - 1,
				0, 0);

			ds_grid_multiply_region(
				GridCompute,
				0, 0,
				2, ParticlesAlive - 1,
				_deltaTimeS);

			ds_grid_add_grid_region(
				Particles,
				GridCompute,
				0, 0,
				2, ParticlesAlive - 1,
				BBMOD_EParticle.PositionX, 0);

			// position += accelerationReal * _temp2:
			ds_grid_set_grid_region(
				GridCompute,
				Particles,
				BBMOD_EParticle.AccelerationRealX, 0,
				BBMOD_EParticle.AccelerationRealZ, ParticlesAlive - 1,
				0, 0);

			ds_grid_multiply_region(
				GridCompute,
				0, 0,
				2, ParticlesAlive - 1,
				_temp2);

			ds_grid_add_grid_region(
				Particles,
				GridCompute,
				0, 0,
				2, ParticlesAlive - 1,
				BBMOD_EParticle.PositionX, 0);

			// acceleration = (0, 0, 0)
			ds_grid_set_region(
				Particles,
				BBMOD_EParticle.AccelerationX, 0,
				BBMOD_EParticle.AccelerationZ, ParticlesAlive - 1,
				0.0);
		}

		////////////////////////////////////////////////////////////////////////
		// Execute modules
		var m = 0;
		repeat (array_length(_modules))
		{
			var _module = _modules[m++];
			if (_module.Enabled)
			{
				// Emitter start
				if (_timeStart && _module.on_start)
				{
					_module.on_start(self);
				}

				// Emitter update
				if (_module.on_update)
				{
					_module.on_update(self, _deltaTime);
				}

				// Emitter finish
				if (_timeOut && _module.on_finish)
				{
					_module.on_finish(self);
				}
			}
		}

		////////////////////////////////////////////////////////////////////////
		// Particle simulate physics
		if (ParticlesAlive > 0)
		{
			// velocity += (accelerationReal + acceleration) * _temp1
			ds_grid_set_grid_region(
				GridCompute,
				Particles,
				BBMOD_EParticle.AccelerationRealX, 0,
				BBMOD_EParticle.AccelerationRealZ, ParticlesAlive - 1,
				0, 0);

			ds_grid_add_grid_region(
				GridCompute,
				Particles,
				BBMOD_EParticle.AccelerationX, 0,
				BBMOD_EParticle.AccelerationZ, ParticlesAlive - 1,
				0, 0);

			ds_grid_multiply_region(
				GridCompute,
				0, 0,
				2, ParticlesAlive - 1,
				_temp1);

			ds_grid_add_grid_region(
				Particles,
				GridCompute,
				0, 0,
				2, ParticlesAlive - 1,
				BBMOD_EParticle.VelocityX, 0);

			// accelerationReal = acceleration
			ds_grid_set_grid_region(
				Particles,
				Particles,
				BBMOD_EParticle.AccelerationX, 0,
				BBMOD_EParticle.AccelerationZ, ParticlesAlive - 1,
				BBMOD_EParticle.AccelerationRealX, 0);
		}

		return self;
	};

	/// @func finished([_particlesDead])
	///
	/// @desc Checks if the emitter cycle has finished.
	///
	/// @param {Bool} [_particlesDead] Also check if there are no particles
	/// alive. Defaults to `false.`
	///
	/// @return {Bool} Returns `true` if the emitter cycle has finished
	/// (and there are no particles alive). Aalways returns `false` if the
	/// emitted particle system is looping.
	static finished = function (_particlesDead=false) {
		gml_pragma("forceinline");
		if (System.Loop)
		{
			return false;
		}
		if (__time >= System.Duration)
		{
			if (!_particlesDead || ParticlesAlive == 0)
			{
				return true;
			}
		}
		return false;
	};

	static _draw = function (_method, _material=undefined) {
		gml_pragma("forceinline");

		var _dynamicBatch = System.__dynamicBatch;
		var _batchSize = _dynamicBatch.Size;
		_material ??= System.Material;

		var _particleCount = ParticlesAlive;
		var _particlesSorted;

		if (System.Sort)
		{
			_particlesSorted = array_create(_particleCount);
			var i = 0;
			repeat (_particleCount)
			{
				_particlesSorted[@ i] = i;
				++i;
			}

			array_sort(_particlesSorted, method(self, function (_p1, _p2) {
				var _camPos = global.__bbmodCameraPosition;
				var _particles = Particles;
				var _d1 = point_distance_3d(
					_particles[# BBMOD_EParticle.PositionX, _p1],
					_particles[# BBMOD_EParticle.PositionY, _p1],
					_particles[# BBMOD_EParticle.PositionZ, _p1],
					_camPos.X,
					_camPos.Y,
					_camPos.Z);
				var _d2 = point_distance_3d(
					_particles[# BBMOD_EParticle.PositionX, _p2],
					_particles[# BBMOD_EParticle.PositionY, _p2],
					_particles[# BBMOD_EParticle.PositionZ, _p2],
					_camPos.X,
					_camPos.Y,
					_camPos.Z);
				if (_d2 > _d1) return +1;
				if (_d2 < _d1) return -1;
				return 0;
			}));
		}

		var _particles = Particles;
		//var _color = new BBMOD_Color();
		var _particleIndex = 0;
		var _batchCount = ceil(_particleCount / _batchSize);
		var _batchData = array_create(_batchCount);
		var _batchIndex = 0;

		repeat (_batchCount)
		{
			var _data = array_create(_batchSize * 16, 0);
			var d = 0;
			repeat (min(_particleCount, _batchSize))
			{
				var i = System.Sort
					? _particlesSorted[_particleIndex++]
					: _particleIndex++;

				_data[d + 0] = _particles[# BBMOD_EParticle.PositionX, i];
				_data[d + 1] = _particles[# BBMOD_EParticle.PositionY, i];
				_data[d + 2] = _particles[# BBMOD_EParticle.PositionZ, i];

				_data[d + 4] = _particles[# BBMOD_EParticle.RotationX, i];
				_data[d + 5] = _particles[# BBMOD_EParticle.RotationY, i];
				_data[d + 6] = _particles[# BBMOD_EParticle.RotationZ, i];
				_data[d + 7] = _particles[# BBMOD_EParticle.RotationW, i];

				_data[d + 8]  = _particles[# BBMOD_EParticle.ScaleX, i];
				_data[d + 9]  = _particles[# BBMOD_EParticle.ScaleY, i];
				_data[d + 10] = _particles[# BBMOD_EParticle.ScaleZ, i];

				_data[d + 12] = _particles[# BBMOD_EParticle.ColorR, i] / 255.0;
				_data[d + 13] = _particles[# BBMOD_EParticle.ColorG, i] / 255.0;
				_data[d + 14] = _particles[# BBMOD_EParticle.ColorB, i] / 255.0;
				_data[d + 15] = _particles[# BBMOD_EParticle.ColorA, i];

				d += 16;
			}
			_particleCount -= _batchSize;
			_batchData[@ _batchIndex++] = _data;
		}

		if (_batchCount > 0)
		{
			_method(_material, _batchData);
		}
	};

	/// @func submit([_material])
	///
	/// @desc Immediately submits particles for rendering.
	///
	/// @param {Struct.BBMOD_Material} [_material] The material to use instead
	/// of the one defined in the particle system or `undefined`.
	///
	/// @return {Struct.BBMOD_ParticleEmitter} Returns `self`.
	static submit = function (_material=undefined) {
		var _dynamicBatch = System.__dynamicBatch;
		_draw(method(_dynamicBatch, _dynamicBatch.submit), _material);
		return self;
	};

	/// @func render([_material])
	///
	/// @desc Enqueus particles for rendering.
	///
	/// @param {Struct.BBMOD_Material} [_material] The material to use instead
	/// of the one defined in the particle system or `undefined`.
	///
	/// @return {Struct.BBMOD_ParticleEmitter} Returns `self`.
	static render = function (_material=undefined) {
		var _dynamicBatch = System.__dynamicBatch;
		_draw(method(_dynamicBatch, _dynamicBatch.render), _material);
		return self;
	};

	static destroy = function () {
		Class_destroy();
		ds_grid_destroy(Particles);
		ds_grid_destroy(GridCompute);
		return undefined;
	};
}
