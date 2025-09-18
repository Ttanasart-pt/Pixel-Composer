/// @description Insert description here
#region params
	domain           = -1;
	particlePosBuff  = noone;
	particleVelBuff  = noone;

	width            = 0;
	height           = 0;
	particleSize     = 0;
	density          = 0;
	viscosity        = 0;
	friction         = 0;
	maxParticles     = 0;
	
	numParticles     = 0;
	velocityDamping  = 0.9;

	dt               = 0.1;
	iteration        = 8;
	numPressureIters = 2;
	numParticleIters = 2;
	
	g                = 1;
	gDirection       = 270;
	flipRatio        = 0.8;
	overRelaxation   = 1.5;
	
	obstracles       = [];
	wallCollide      = 0b1111;
	wallElasticity   = 1;
	
	skip_incompressible = false;
	
	particleRadius   = 0;
	
	domain_preview   = noone;
#endregion

function init(_width, _height, _particleSize, _density, _maxParticles) {
	particlePos  = array_create(_maxParticles * 2);
	particleVel  = array_create(_maxParticles * 2);
	particleHist = array_create(_maxParticles * 2 * GLOBAL_TOTAL_FRAMES);
	particleLife = array_create(_maxParticles);
	obstracles   = [];
	numParticles = 0;
	
	if(domain       != -1            && 
	   width        == _width        && 
	   height       == _height       && 
	   particleSize == _particleSize && 
	   density      == _density      && 
	   maxParticles == _maxParticles) { FLIP_resetDomain(domain); return; }
	
	width        = _width;
	height       = _height;
	particleSize = _particleSize;
	density      = _density;
	maxParticles = _maxParticles;
	
	particlePosBuff   = buffer_create(maxParticles * 2 * 8, buffer_grow, 8);
	particleVelBuff   = buffer_create(maxParticles * 2 * 8, buffer_grow, 8);
	particleLifeBuff  = buffer_create(maxParticles * 8, buffer_grow, 8);
	
	aPosBuff  = buffer_get_address(particlePosBuff);
	aVelBuff  = buffer_get_address(particleVelBuff);
	aLifeBuff = buffer_get_address(particleLifeBuff);
	
	domain            = FLIP_initDomain(width, height, particleSize, density, maxParticles);
	particleRadius    = FLIP_getParticleRadius(domain);
	
	cellX = floor(width  / particleSize) + 1;
	cellY = floor(height / particleSize) + 1;
	
	domain_preview = surface_verify(domain_preview, width, height);
}

function update() {
	FLIP_setQuality(		 domain, iteration, numPressureIters, numParticleIters);
	FLIP_setGravity(		 domain, g, gDirection);
	FLIP_setViscosity(		 domain, viscosity);
	FLIP_setFriction(		 domain, friction);
	FLIP_setFlipRatio(		 domain, flipRatio);
	FLIP_setVelocityDamping( domain, velocityDamping);
	FLIP_setOverRelaxation(	 domain, overRelaxation);
	FLIP_setWallCollisions(  domain, wallCollide, wallElasticity);
}

function step() {
	FLIP_resetDensity(domain);
	
	if(skip_incompressible) { 
		FLIP_setTimeStep(domain, dt);
		repeat(iteration) {
			FLIP_simulate_integrateParticles(domain);
			FLIP_simulate_pushParticlesApart(domain);
			FLIP_simulate_handleParticleCollisions(domain);
			//FLIP_simulate_transferVelocities(domain, 1);
			//FLIP_simulate_updateParticleDensity(domain);
			//FLIP_simulate_solveIncompressibility(domain);
			//FLIP_simulate_transferVelocities(domain, 0);
		}
	} else {
		FLIP_simulate(domain, dt);
		
		//FLIP_setTimeStep(domain, dt);
		//repeat(iteration) {
		//	FLIP_simulate_integrateParticles(domain);
		//	FLIP_simulate_pushParticlesApart(domain);
		//	FLIP_simulate_handleParticleCollisions(domain);
		//	FLIP_simulate_transferVelocities(domain, 1);
		//	FLIP_simulate_updateParticleDensity(domain);
		//	FLIP_simulate_solveIncompressibility(domain);
		//	FLIP_simulate_transferVelocities(domain, 0);
		//}
	}
	
	FLIP_setParticleBuffer(domain, aPosBuff, aLifeBuff);
	FLIP_setParticleVelocityBuffer(domain, aVelBuff);
	
	buffer_seek(particlePosBuff,  buffer_seek_start, 0);	
	buffer_seek(particleVelBuff,  buffer_seek_start, 0);	
	buffer_seek(particleLifeBuff, buffer_seek_start, 0);
	
	for(var i = 0; i < maxParticles * 2; i++) {
		particleHist[maxParticles * 2 * GLOBAL_CURRENT_FRAME + i] = particlePos[i];
		particlePos[i]  = buffer_read(particlePosBuff, buffer_f64);
		particleVel[i]  = buffer_read(particleVelBuff, buffer_f64);
	}
	
	for(var i = 0; i < maxParticles; i++)
		particleLife[i] = buffer_read(particleLifeBuff, buffer_f64);
		
	domain_preview = surface_verify(domain_preview, width, height);
}