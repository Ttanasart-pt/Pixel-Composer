/// @description Insert description here
#region params
	domain           = noone;
	particlePosBuff  = noone;

	width            = 0;
	height           = 0;
	particleSize     = 0;
	density          = 0;
	maxParticles     = 0;
	
	numParticles     = 0;
	velocityDamping  = 0.9;

	dt               = 0.1;
	iteration        = 8;

	g                = 1;
	flipRatio        = 0.8;
	numPressureIters = 3;
	numParticleIters = 3;
	overRelaxation   = 1.5;
#endregion

function init(width, height, particleSize, density, maxParticles) { #region domain init
	particlePos     = array_create(2 * maxParticles);
	obstracles      = [];
	numParticles    = 0;
	
	if(domain            != noone        && 
	   self.width        == width        && 
	   self.height       == height       && 
	   self.particleSize == particleSize && 
	   self.density      == density      && 
	   self.maxParticles == maxParticles) {
		
		FLIP_resetDomain(domain);
		return;
	}
	
	self.width        = width       ;
	self.height       = height      ;
	self.particleSize = particleSize;
	self.density      = density     ;
	self.maxParticles = maxParticles;
	
	particlePosBuff   = buffer_create(maxParticles * 2 * 8, buffer_grow, 8);
	domain            = FLIP_initDomain(width, height, particleSize, density, maxParticles);
	particleRadius    = FLIP_getParticleRadius(domain);
} #endregion

function update() { #region
	FLIP_setQuality(		 domain, iteration, numPressureIters, numParticleIters);
	FLIP_setGravity(		 domain, g);
	FLIP_setFlipRatio(		 domain, flipRatio);
	FLIP_setVelocityDamping( domain, velocityDamping);
	FLIP_setOverRelaxation(	 domain, overRelaxation);
} #endregion

function step() { #region
	FLIP_resetDensity(domain);
	
	for( var i = 0, n = array_length(obstracles); i < n; i++ ) 
		obstracles[i].apply();

	FLIP_simulate(domain, dt);
	
	FLIP_setParticleBuffer(domain, buffer_get_address(particlePosBuff));
	buffer_seek(particlePosBuff, buffer_seek_start, 0);
	for(var i = 0; i < 2 * maxParticles; i++)
		particlePos[i] = buffer_read(particlePosBuff, buffer_f64);
} #endregion