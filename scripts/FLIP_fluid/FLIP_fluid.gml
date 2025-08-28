/*[cpp] flip
#define _USE_MATH_DEFINES
#include <cmath>
#include <cstring>
#include <algorithm>
#include <vector>

using namespace std;

enum CELL {
	solid,
	fluid,
	air
};

enum COLLISION_SHAPE {
	circle,
	rectangle
};

struct Obstacle {
	double x;
	double y;
	double velX;
	double velY;

	COLLISION_SHAPE type;

	double radius;
	double width;
	double height;
};

struct Domain {
	double width;
	double height;
	double spacing;
	double density;
	double viscosity;

	double friction = 1;

	double fNumX;
	double fNumY;
	double fNumX1;
	double fNumY1;
	double h;
	double fInvSpacing;
	double fNumCells;

	int    collideWall;
	double wallElasticity = 1;

	double* u;
	double* v;
	double* du;
	double* dv;
	double* prevU;
	double* prevV;
	double* p;
	double* s;

	double* cellType;
	double* particlePos;
	double* particleVel;
	double* particleDensity;
	double* particleLife;

	double particleRestDensity;

	double particleRadius;
	double pInvSpacing;
	double pNumX;
	double pNumY;
	double pNumCells;

	double velocityDamping = 0.9;

	double* numCellParticles;
	double* firstCellParticle;
	double* cellParticleIds;

	double maxParticles;
	double numParticles;

	double dt = 0.5;
	double globalIteration = 4;

	double gravity = 50;
	double gravityDirection = 270;
	double flipRatio = 0.5;
	double numPressureIterations = 4;
	double numParticleIterations = 8;
	double overRelaxation = 1.8;

	vector<Obstacle> obstacles;
};

vector<Domain> domains;

double clamp(double x, double min, double max) { return x < min ? min : x > max ? max : x; }

static inline int getIndex (int x, int y, int n) { return x * n + y; }

////////////////////////////////////////////////////////////////////// DOMAINS //////////////////////////////////////////////////////////////////////

cfunction double FLIP_cleanDomain(double dindex) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	delete[] domain.u;
	delete[] domain.v;
	delete[] domain.du;
	delete[] domain.dv;
	delete[] domain.prevU;
	delete[] domain.prevV;
	delete[] domain.p;
	delete[] domain.s;

	delete[] domain.cellType;
	delete[] domain.particlePos;
	delete[] domain.particleVel;
	delete[] domain.particleDensity;
	delete[] domain.particleLife;

	delete[] domain.numCellParticles;
	delete[] domain.firstCellParticle;
	delete[] domain.cellParticleIds;

	return 0;
}

cfunction double FLIP_resetDomain(double dindex) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	domain.obstacles.clear();
	domain.numParticles = 0;

	memset(domain.u, 0, sizeof(double) * domain.fNumCells);
	memset(domain.v, 0, sizeof(double) * domain.fNumCells);
	memset(domain.du, 0, sizeof(double) * domain.fNumCells);
	memset(domain.dv, 0, sizeof(double) * domain.fNumCells);
	memset(domain.prevU, 0, sizeof(double) * domain.fNumCells);
	memset(domain.prevV, 0, sizeof(double) * domain.fNumCells);
	memset(domain.p, 0, sizeof(double) * domain.fNumCells);
	memset(domain.s, 0, sizeof(double) * domain.fNumCells);

	memset(domain.cellType, 0, sizeof(double) * domain.fNumCells);
	memset(domain.particlePos, 0, sizeof(double) * domain.maxParticles * 2);
	memset(domain.particleVel, 0, sizeof(double) * domain.maxParticles * 2);
	memset(domain.particleDensity, 0, sizeof(double) * domain.fNumCells);
	memset(domain.particleLife, 0, sizeof(double) * domain.maxParticles);

	memset(domain.numCellParticles, 0, sizeof(double) * domain.pNumCells);
	memset(domain.firstCellParticle, 0, sizeof(double) * (domain.pNumCells + 1));
	memset(domain.cellParticleIds, 0, sizeof(double) * domain.maxParticles);

	return 0;
}

cfunction double FLIP_updateDomain(double dindex, double _width, double _height, double _spacing, double _density, double _maxParticle) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];
	
	domain.width        = _width;
	domain.height       = _height;
	domain.spacing      = _spacing;
	domain.density      = _density;
	domain.maxParticles = _maxParticle;

	domain.collideWall  = 0b1111;

	domain.fNumX  = floor(domain.width / domain.spacing) + 1;
	domain.fNumY  = floor(domain.height / domain.spacing) + 1;
	domain.fNumX1 = domain.fNumX - 1;
	domain.fNumY1 = domain.fNumY - 1;

	domain.h           = max(domain.width / domain.fNumX, domain.height / domain.fNumY);
	domain.fInvSpacing = 1.0 / domain.h;
	domain.fNumCells   = domain.fNumX * domain.fNumY;
	int iNumCells = (size_t)domain.fNumCells;

	domain.u     = new double[iNumCells];
	domain.v     = new double[iNumCells];
	domain.du    = new double[iNumCells];
	domain.dv    = new double[iNumCells];
	domain.prevU = new double[iNumCells];
	domain.prevV = new double[iNumCells];
	domain.p     = new double[iNumCells];
	domain.s     = new double[iNumCells];

	domain.cellType            = new double[(size_t)domain.fNumCells];
	domain.particlePos		   = new double[(size_t)domain.maxParticles * 2];
	domain.particleVel         = new double[(size_t)domain.maxParticles * 2];
	domain.particleDensity     = new double[(size_t)domain.fNumCells];
	domain.particleLife		   = new double[(size_t)domain.maxParticles];
	domain.particleRestDensity = 0;

	domain.particleRadius      = domain.h * 0.3;
	domain.pInvSpacing         = 1.0 / (2.2 * domain.particleRadius);
	domain.pNumX               = floor(domain.width * domain.pInvSpacing) + 1;
	domain.pNumY               = floor(domain.height * domain.pInvSpacing) + 1;
	domain.pNumCells           = domain.pNumX * domain.pNumY;
							   
	domain.numCellParticles    = new double[(size_t)domain.pNumCells];
	domain.firstCellParticle   = new double[(size_t)domain.pNumCells + 1];
	domain.cellParticleIds     = new double[(size_t)domain.maxParticles];

	return dindex;
}

cfunction double FLIP_initDomain(double _width, double _height, double _spacing, double _density, double _maxParticle) {
	Domain domain;
	double size = domains.size();
	domains.push_back(domain);

	FLIP_updateDomain(size, _width, _height, _spacing, _density, _maxParticle);

	return size;
}

////////////////////////////////////////////////////////////////////// SETTERS //////////////////////////////////////////////////////////////////////

cfunction double FLIP_setParticleBuffer(double dindex, double* _particlePos, double* _particleLife) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];
	
	memcpy(_particlePos, domain.particlePos, sizeof(double) * domain.maxParticles * 2);
	memcpy(_particleLife, domain.particleLife, sizeof(double) * domain.maxParticles);

	return 0;
}

cfunction double FLIP_setParticleVelocityBuffer(double dindex, double* _particleVel) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	memcpy(_particleVel, domain.particleVel, sizeof(double) * domain.maxParticles * 2);

	return 0;
}

cfunction double FLIP_setQuality(double dindex, double _globalIteration, double _numPressureIterations, double _numParticleIterations) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	domain.globalIteration       = _globalIteration;
	domain.numPressureIterations = _numPressureIterations;
	domain.numParticleIterations = _numParticleIterations;

	return 0;
}

cfunction double FLIP_setViscosity(double dindex, double _viscosity) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	domain.viscosity = _viscosity;
	return 0;
}

cfunction double FLIP_setFriction(double dindex, double _friction) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	domain.friction = _friction;
	return 0;
}

cfunction double FLIP_setGravity(double dindex, double _gravity, double _gravityDirection) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	domain.gravity = _gravity;
	domain.gravityDirection = _gravityDirection;
	return 0;
}

cfunction double FLIP_setFlipRatio(double dindex, double _flipRatio) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	domain.flipRatio = _flipRatio;
	return 0;
}

cfunction double FLIP_setVelocityDamping(double dindex, double _velocityDamping) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	domain.velocityDamping = _velocityDamping;
	return 0;
}

cfunction double FLIP_setOverRelaxation(double dindex, double _overRelaxation) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	domain.overRelaxation = _overRelaxation;
	return 0;
}

cfunction double FLIP_setTimeStep(double dindex, double _dt) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	domain.dt = _dt;
	return 0;
}

cfunction double FLIP_setWallCollisions(double dindex, double _collideWall, double _wallElasticity) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	domain.collideWall    = (int)_collideWall;
	domain.wallElasticity = _wallElasticity;
	return 0;
}

cfunction double FLIP_resetDensity(double dindex) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	int n = domain.fNumY;
	double* s = domain.s;

	for (int i = 1; i < domain.fNumX1; i++)
		for (int j = 1; j < domain.fNumY1; j++) {
			s[i * n + j] = 1.0;
		}

	return 0;
}

//////////////////////////////////////////////////////////////////// SIMULATION ////////////////////////////////////////////////////////////////////

void setBoundary(Domain domain, double* a) {
	int x = domain.fNumX;
	int y = domain.fNumY;
	int c = domain.collideWall;

	if((c & 0b0001) == 0) for (int j = 0; j < y; j++) { a[getIndex(j, 1, y)]     = a[getIndex(j, 2, y)]; 
														a[getIndex(j, 0, y)]	 = a[getIndex(j, 1, y)]; }
	if((c & 0b0010) == 0) for (int j = 0; j < y; j++) { a[getIndex(j, y - 1, y)] = a[getIndex(j, y - 2, y)]; }
	if((c & 0b0100) == 0) for (int i = 0; i < x; i++) { a[getIndex(1, i, y)]     = a[getIndex(2, i, y)]; 
														a[getIndex(0, i, y)]	 = a[getIndex(1, i, y)]; }
	if((c & 0b1000) == 0) for (int i = 0; i < x; i++) { a[getIndex(x - 1, i, y)] = a[getIndex(x - 2, i, y)]; }

	a[0]               = 0.5 * (a[1] + a[y]);
	a[y - 1]           = 0.5 * (a[y - 2] + a[2 * y - 1]);
	a[(x - 1) * y]     = 0.5 * (a[(x - 2) * y] + a[(x - 1) * y + 1]);
	a[x * y - 1]       = 0.5 * (a[(x - 1) * y - 1] + a[x * y - 2]);
}

void integrateParticles(Domain domain) {
	double* particleVel  = domain.particleVel;
	double* particlePos  = domain.particlePos;
	double* particleLife = domain.particleLife;

	double dt = domain.dt;

	double gx = dt * domain.gravity * cos(domain.gravityDirection * M_PI / 180);
	double gy = dt * domain.gravity * sin(domain.gravityDirection * M_PI / 180);

	double _itr = 1 / domain.globalIteration;

	for (int i = 0; i < domain.numParticles; i++) {
		if(isnan(particleVel[2 * i + 1])) 
			particleVel[2 * i + 1] = 0;
		particleVel[2 * i + 1] = clamp(particleVel[2 * i + 1], -1000, 1000);

		if(particlePos[2 * i] == 0 && particlePos[2 * i + 1] == 0) continue;

		particleVel[2 * i]     += gx;
		particleVel[2 * i + 1] -= gy;

		particlePos[2 * i]     += particleVel[2 * i] * dt;
		particlePos[2 * i + 1] += particleVel[2 * i + 1] * dt;

		particleLife[i] += _itr;
	}
}
cfunction double FLIP_simulate_integrateParticles(double dindex) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	integrateParticles(domain);
	return 0;
}

void pushParticlesApart(Domain domain) {
	int pNumCells = (int)domain.pNumCells;
	
	double* numCellParticles  = domain.numCellParticles;
	double* firstCellParticle = domain.firstCellParticle;
	double* particlePos       = domain.particlePos;
	double* particleVel       = domain.particleVel;
	double* cellParticleIds   = domain.cellParticleIds;

	double numParticles = domain.numParticles;
	double pInvSpacing  = domain.pInvSpacing;
	double pNumX        = domain.pNumX;
	double pNumY        = domain.pNumY;

	double pNumX1 = pNumX - 1;
	double pNumY1 = pNumY - 1;
	
	int c = domain.collideWall;
	bool cnTop = (c & 0b0001) == 0;
	bool cnBot = (c & 0b0010) == 0;
	bool cnLef = (c & 0b0100) == 0;
	bool cnRig = (c & 0b1000) == 0;

	// count particles per cell
	for (int i = 0; i < pNumCells; i++)
		numCellParticles[i] = 0;

	for (int i = 0; i < numParticles; i++) {
		double _x  = particlePos[2 * i];
		double _y  = particlePos[2 * i + 1];

		if(_x == 0 && _y == 0) continue;

		double xi  = floor(_x * pInvSpacing);
		double yi  = floor(_y * pInvSpacing);

		if (cnTop) { if(yi < 0)			continue; } else yi = max(yi, 0.);	
		if (cnBot) { if(yi >= pNumY1)	continue; } else yi = min(yi, pNumY1);
		if (cnLef) { if(xi < 0)			continue; } else xi = max(xi, 0.);	
		if (cnRig) { if(xi >= pNumX1)	continue; } else xi = min(xi, pNumX1);

		int cellNr = xi * pNumY + yi;
		numCellParticles[cellNr]++;
	}

	// partial sums

	double first = 0;

	for (int i = 0; i < pNumCells; i++) {
		first += numCellParticles[i];
		firstCellParticle[i] = first;
	}
	firstCellParticle[pNumCells] = first;		// guard

	// fill particles into cells

	for (int i = 0; i < numParticles; i++) {
		double _x  = particlePos[2 * i];
		double _y  = particlePos[2 * i + 1];
		
		if(_x == 0 && _y == 0) continue;

		double xi  = floor(_x * pInvSpacing);
		double yi  = floor(_y * pInvSpacing);
		
		if (cnTop) { if(yi < 0)			continue; } else yi = max(yi, 0.);	
		if (cnBot) { if(yi >= pNumY1)	continue; } else yi = min(yi, pNumY1);
		if (cnLef) { if(xi < 0)			continue; } else xi = max(xi, 0.);	
		if (cnRig) { if(xi >= pNumX1)	continue; } else xi = min(xi, pNumX1);

		int cellNr = xi * pNumY + yi;
		firstCellParticle[cellNr]--;
		cellParticleIds[(int)firstCellParticle[cellNr]] = i;
	}

	// push particles apart

	double minDist     = 2.0 * domain.particleRadius;
	double minDist2    = minDist * minDist;
	double minDistHalf = minDist * 0.5;
	double viscosity   = domain.viscosity;
	double invvisc     = clamp(viscosity + 1., 0., 1.);

	for (int _m = 0; _m < domain.numParticleIterations; _m++) {
		for (int i = 0; i < numParticles; i++) {
			double px = particlePos[2 * i];
			double py = particlePos[2 * i + 1];

			if(px == 0 && py == 0) continue;

			double pxi = floor(px * pInvSpacing);
			double pyi = floor(py * pInvSpacing);
			
			if (cnTop && pyi < 0)		continue;
			if (cnBot && pyi >= pNumY1) continue;
			if (cnLef && pxi < 0)		continue;
			if (cnRig && pxi >= pNumX1 )continue;

			double x0  = max(pxi - 1, 0.);
			double y0  = max(pyi - 1, 0.);
			double x1  = min(pxi + 1, pNumX1);
			double y1  = min(pyi + 1, pNumY1);

			int _i2 = i * 2;

			for (double  xi = x0; xi <= x1; xi++)
			for (double  yi = y0; yi <= y1; yi++) {
				int cellNr   = xi * pNumY + yi;
				double first = firstCellParticle[cellNr];
				double last  = firstCellParticle[cellNr + 1];

				for (int j = first; j < last; j++) {
					int _id = cellParticleIds[j];
					if (_id == i) continue;

					int _id2 = _id * 2;

					double qx = particlePos[_id2];
					double qy = particlePos[_id2 + 1];
					
					if(qx == 0 && qy == 0) continue;

					double dx = qx - px;
					double dy = qy - py;
					double d2 = dx * dx + dy * dy;

					if(d2 == 0) continue;
					if (d2 > minDist2 * 2) continue;

					if (d2 > minDist2) { // viscosity calculation: attract nearby particle from r/2 to r
						if(viscosity == 0) continue;

						double d = sqrt(d2) - minDistHalf;
						double s = max(0., minDistHalf / d - 0.5);
						dx *= s * viscosity;
						dy *= s * viscosity;

						particlePos[_i2]      += dx;
						particlePos[_i2 + 1]  += dy;
						particlePos[_id2]     -= dx;
						particlePos[_id2 + 1] -= dy;
						continue;
					} 

					double d = sqrt(d2);
					double s = minDistHalf / d - 0.5;
					dx *= s * invvisc;
					dy *= s * invvisc;

					particlePos[_i2]      -= dx;
					particlePos[_i2 + 1]  -= dy;
					particlePos[_id2]     += dx;
					particlePos[_id2 + 1] += dy;
				}
			}
		}
	}
}
cfunction double FLIP_simulate_pushParticlesApart(double dindex) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	pushParticlesApart(domain);
	return 0;
}

void handleParticleCollisions(Domain domain) {
	double h = 1.0 / domain.fInvSpacing;
	double r = domain.particleRadius;

	double dt = domain.dt;

	double minX = h + r;
	double maxX = (domain.fNumX - 1) * h - r;
	double minY = h + r;
	double maxY = (domain.fNumY - 1) * h - r;

	double* particlePos = domain.particlePos;
	double* particleVel = domain.particleVel;

	double numParticles = domain.numParticles;
	
	for (int o = 0; o < domain.obstacles.size(); o++) {
		Obstacle& obstacle = domain.obstacles[o];

		double _or      = obstacle.radius;
		double minDist  = obstacle.radius + r;
		double minDist2 = minDist * minDist;

		double _ow = obstacle.width;
		double _oh = obstacle.height;

		switch (obstacle.type) {
			case circle :
				
				for (int i = 0; i < numParticles; i++) {
					int i2 = i * 2;

					double _x = particlePos[i2];
					double _y = particlePos[i2 + 1];

					if(_x == 0 && _y == 0) continue;

					double dx = _x - obstacle.x;
					double dy = _y - obstacle.y;
					double d2 = dx * dx + dy * dy;

					// obstacle collision
					if (d2 < minDist2) {
						particlePos[i2]     = obstacle.x + dx * minDist / sqrt(d2);
						particlePos[i2 + 1] = obstacle.y + dy * minDist / sqrt(d2);

						particleVel[i2]     = obstacle.velX;
						particleVel[i2 + 1] = obstacle.velY;

						if(dy < 0) {
							if(dx < 0) {
								particleVel[i2]     +=  dy * 0.25;
								particleVel[i2 + 1] += -dx * 0.25;
							}
							else {
								particleVel[i2]     += -dy * 0.25;
								particleVel[i2 + 1] += -dx * 0.25;
							}
						}
					}
				}
			break;

			case rectangle :
				for (int i = 0; i < numParticles; i++) {
					int i2 = i * 2;

					double _x = particlePos[i2];
					double _y = particlePos[i2 + 1];
					
					if(_x == 0 && _y == 0) continue;

					double dx = _x - obstacle.x;
					double dy = _y - obstacle.y;

					// obstacle collision
					if (abs(dx) < _ow && abs(dy) < _oh) {
						double _ex = _ow - abs(dx);
						double _ey = _oh - abs(dy);

						if (_ex < _ey) {
							if (dx < 0) {
								particlePos[i2] = obstacle.x - _ow - r;
								particleVel[i2] = obstacle.velX;
							}
							else {
								particlePos[i2] = obstacle.x + _ow + r;
								particleVel[i2] = obstacle.velX;
							}
						} else {
							if (dy < 0) {
								particlePos[i2 + 1] = obstacle.y - _oh - r;
								particleVel[i2 + 1] = obstacle.velY;
							}
							else {
								particlePos[i2 + 1] = obstacle.y + _oh + r;
								particleVel[i2 + 1] = obstacle.velY;
							}
						}
					}
				}
			break;
		}
	}

	// wall collisions
	double wallElasticity = domain.wallElasticity;
	int c = domain.collideWall;
	bool cTop = c & 0b0001;
	bool cBot = c & 0b0010;
	bool cLef = c & 0b0100;
	bool cRig = c & 0b1000;

	for (int i = 0; i < numParticles; i++) {
		int i2 = i * 2;

		double _x = particlePos[i2];
		double _y = particlePos[i2 + 1];
		
		if(_x == 0 && _y == 0) continue;

		if (cTop && _y < minY) {
			_y = minY;
			particleVel[i2 + 1] *= -wallElasticity;
		}
		if (cBot && _y > maxY) {
			_y = maxY;
			particleVel[i2 + 1] *= -wallElasticity;
		}
		if (cLef && _x < minX) {
			_x = minX;
			particleVel[i2] *= -wallElasticity;
		}
		if (cRig && _x > maxX) {
			_x = maxX;
			particleVel[i2] *= -wallElasticity;
		}
		
		particlePos[i2] = _x;
		particlePos[i2 + 1] = _y;
	}
}
cfunction double FLIP_simulate_handleParticleCollisions(double dindex) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	handleParticleCollisions(domain);

	return 0;
}

void updateParticleDensity(Domain domain) {
	double* particlePos = domain.particlePos;
	double* d           = domain.particleDensity;
	double* cellType    = domain.cellType;

	double n      = domain.fNumY;
	double h      = domain.h;
	double h1     = domain.fInvSpacing;
	double h2     = 0.5 * domain.h;
	double fNumX  = domain.fNumX;
	double fNumY  = domain.fNumY;
	double fNumX1 = domain.fNumX1;
	double fNumY1 = domain.fNumY1;
	double fNumCells = domain.fNumCells;

	double numParticles        = domain.numParticles;
	double particleRestDensity = domain.particleRestDensity;
	
	int c = domain.collideWall;
	bool cnTop = (c & 0b0001) == 0;
	bool cnBot = (c & 0b0010) == 0;
	bool cnLef = (c & 0b0100) == 0;
	bool cnRig = (c & 0b1000) == 0;

	for (int i = 0; i < fNumCells; i++)
		d[i] = 0;

	for (int i = 0; i < numParticles; i++) {
		int i2 = i * 2;

		double _x = particlePos[i2];
		double _y = particlePos[i2 + 1];

		if(_x == 0 && _y == 0) continue;

		if (cnTop) { if(_y < h)				continue; } else _y = max(_y, h);	
		if (cnBot) { if(_y > fNumY1 * h)	continue; } else _y = min(_y, fNumY1 * h);
		if (cnLef) { if(_x < h)				continue; } else _x = max(_x, h);	
		if (cnRig) { if(_x > fNumX1 * h)	continue; } else _x = min(_x, fNumX1 * h);

		double x0 = floor((_x - h2) * h1);
		double tx = ((_x - h2) - x0 * h) * h1;
		double x1 = min(x0 + 1, fNumX1);

		double y0 = floor((_y - h2) * h1);
		double ty = ((_y - h2) - y0 * h) * h1;
		double y1 = min(y0 + 1, fNumY1);

		double sx = 1.0 - tx;
		double sy = 1.0 - ty;

		if (x0 < fNumX && y0 < fNumY) d[(int)(x0 * n + y0)] += sx * sy;
		if (x1 < fNumX && y0 < fNumY) d[(int)(x1 * n + y0)] += tx * sy;
		if (x1 < fNumX && y1 < fNumY) d[(int)(x1 * n + y1)] += tx * ty;
		if (x0 < fNumX && y1 < fNumY) d[(int)(x0 * n + y1)] += sx * ty;
	}

	if (particleRestDensity == 0) {
		double sum = 0;
		double numFluidCells = 0;

		for (int i = 0; i < fNumCells; i++) {
			if (cellType[i] == fluid) {
				sum += d[i];
				numFluidCells++;
			}
		}

		if (numFluidCells > 0)
			particleRestDensity = sum / numFluidCells;
	}
}
cfunction double FLIP_simulate_updateParticleDensity(double dindex) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	updateParticleDensity(domain);
	return 0;
}

void transferVelocities(Domain domain, bool toGrid) {
	double* u	  = domain.u;
	double* v	  = domain.v;
	double* du	  = domain.du;
	double* dv	  = domain.dv;
	double* prevU = domain.prevU;
	double* prevV = domain.prevV;
	double* s	  = domain.s;
	double* cellType    = domain.cellType;
	double* particlePos = domain.particlePos;
	double* particleVel = domain.particleVel;

	int n            = domain.fNumY;
	double h         = domain.h;
	double h1        = domain.fInvSpacing;
	double h2        = 0.5 * domain.h;
	double fNumX     = domain.fNumX;
	double fNumY     = domain.fNumY;
	double fNumX1    = domain.fNumX1;
	double fNumY1    = domain.fNumY1;
	double fNumCells = domain.fNumCells;
	double flipRatio = domain.flipRatio;
	double friction  = domain.friction;

	double numParticles    = domain.numParticles;
	double velocityDamping = domain.velocityDamping;

	int c = domain.collideWall;
	bool cnTop = (c & 0b0001) == 0;
	bool cnBot = (c & 0b0010) == 0;
	bool cnLef = (c & 0b0100) == 0;
	bool cnRig = (c & 0b1000) == 0;

	if (toGrid) {
		for (int i = 0; i < fNumCells; i++) {
			prevU[i] = u[i] * velocityDamping;
			prevV[i] = v[i] * velocityDamping;

			du[i] = 0;
			dv[i] = 0;
			u[i]  = 0;
			v[i]  = 0;

			cellType[i] = s[i] == 0 ? solid : air;
		}	

		for (int i = 0; i < numParticles; i++) {
			int i2 = i * 2;

			double _x  = particlePos[i2];
			double _y  = particlePos[i2 + 1];

			if(_x == 0 && _y == 0) continue;

			int xi     = floor(_x * h1);
			int yi     = floor(_y * h1);
			
			if (cnTop) { if(yi < 0)			continue; } else yi = max(yi, 0);	
			if (cnBot) { if(yi > fNumY1)	continue; } else yi = min(yi, (int)fNumY1);
			if (cnLef) { if(xi < 0)			continue; } else xi = max(xi, 0);	
			if (cnRig) { if(xi > fNumX1)	continue; } else xi = min(xi, (int)fNumX1);

			int cellNr = xi * n + yi;
			if (cellType[cellNr] == air)
				cellType[cellNr] = fluid;
		}
	}

	double _fNxH = fNumX1 * h;
	double _fNyH = fNumY1 * h;
	double invFlipRatio = 1.0 - flipRatio;

	for (int _com = 0; _com < 2; _com++) {
		double dx = _com == 0 ? 0 : h2;
		double dy = _com == 0 ? h2 : 0;

		double* f     = _com == 0 ? u     : v;
		double* prevF = _com == 0 ? prevU : prevV;
		double* d     = _com == 0 ? du    : dv;

		for (int i = 0; i < numParticles; i++) {
			int i2 = i * 2;

			double _x = particlePos[i2];
			double _y = particlePos[i2 + 1];

			if(_x == 0 && _y == 0) continue;
			
			if (cnTop) { if(_y < h)		continue; } else _y = max(_y, h);	
			if (cnBot) { if(_y > _fNyH)	continue; } else _y = min(_y, _fNyH);
			if (cnLef) { if(_x < h)		continue; } else _x = max(_x, h);	
			if (cnRig) { if(_x > _fNxH)	continue; } else _x = min(_x, _fNxH);

			double x0 = clamp(floor((_x - dx) * h1), 0, fNumX1);
			double tx = ((_x - dx) - x0 * h) * h1;
			double x1 = clamp(x0 + 1, 0, fNumX1);

			double y0 = clamp(floor((_y - dy) * h1), 0, fNumY1);
			double ty = ((_y - dy) - y0 * h) * h1;
			double y1 = clamp(y0 + 1, 0, fNumY1);

			double sx = 1.0 - tx;
			double sy = 1.0 - ty;

			double d0 = sx * sy;
			double d1 = tx * sy;
			double d2 = tx * ty;
			double d3 = sx * ty;

			int nr0 = x0 * n + y0;
			int nr1 = x1 * n + y0;
			int nr2 = x1 * n + y1;
			int nr3 = x0 * n + y1;

			if (toGrid) {
				double pv = particleVel[i2 + _com];
				f[nr0] += pv * d0; d[nr0] += d0;
				f[nr1] += pv * d1; d[nr1] += d1;
				f[nr2] += pv * d2; d[nr2] += d2;
				f[nr3] += pv * d3; d[nr3] += d3;
			} else {
				int offset = _com == 0 ? n : 1;
				double valid0 = cellType[nr0] != air || cellType[nr0 - offset] != air ? 1.0 : 0;
				double valid1 = cellType[nr1] != air || cellType[nr1 - offset] != air ? 1.0 : 0;
				double valid2 = cellType[nr2] != air || cellType[nr2 - offset] != air ? 1.0 : 0;
				double valid3 = cellType[nr3] != air || cellType[nr3 - offset] != air ? 1.0 : 0;

				double _v = particleVel[i2 + _com];
				double _d = valid0 * d0 + valid1 * d1 + valid2 * d2 + valid3 * d3;

				if (_d > 0) {
					double picV = (valid0 * d0 * f[nr0] +
						           valid1 * d1 * f[nr1] +
						           valid2 * d2 * f[nr2] +
						           valid3 * d3 * f[nr3]) / _d;

					double corr = (valid0 * d0 * (f[nr0] - prevF[nr0]) +
						           valid1 * d1 * (f[nr1] - prevF[nr1]) +
						           valid2 * d2 * (f[nr2] - prevF[nr2]) +
						           valid3 * d3 * (f[nr3] - prevF[nr3])) / _d;

					double flipV = _v + corr;
					double vel   = (invFlipRatio * picV + flipRatio * flipV) * friction;
					vel = clamp(vel, -1000, 1000);

					particleVel[i2 + _com] = isnan(vel)? 0 : vel;
				}
			}
		}

		if (toGrid) {
			for (int i = 0; i < fNumCells; i++)
				if (d[i] > 0) f[i] /= d[i];

			for (int i = 0; i < fNumX; i++)
			for (int j = 0; j < fNumY; j++) {

				int index   = i * n + j;
				bool _solid = cellType[index] == solid;

				if (_solid || (i > 0 && cellType[(i - 1) * n + j] == solid))
					u[index] = prevU[index];

				if (_solid || (j > 0 && cellType[i * n + j - 1] == solid))
					v[index] = prevV[index];
			}
		}

		setBoundary(domain, u);
		setBoundary(domain, v);
	}
}
cfunction double FLIP_simulate_transferVelocities(double dindex, double toGrid) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	transferVelocities(domain, toGrid == 1);
	return 0;
}

void solveIncompressibility(Domain domain) {
	double* u = domain.u;
	double* v = domain.v;
	double* p = domain.p;
	double* s = domain.s;
	double* prevU    = domain.prevU;
	double* prevV    = domain.prevV;
	double* cellType = domain.cellType;
	double* particleDensity = domain.particleDensity;

	double fNumX     = domain.fNumX;
	double fNumY     = domain.fNumY;
	double fNumCells = domain.fNumCells;
	double overRelaxation      = domain.overRelaxation;
	double particleRestDensity = domain.particleRestDensity;

	for (int i = 0; i < fNumCells; i++) {
		prevU[i] = u[i];
		prevV[i] = v[i];
		p[i] = 0;
	}

	int n = domain.fNumY;
	double cp = domain.density * domain.h / domain.dt;

	for (int iter = 0; iter < domain.numPressureIterations; iter++) {

		for (int i = 1; i < fNumX - 1; i++)
		for (int j = 1; j < fNumY - 1; j++) {
			if (cellType[i * n + j] != fluid)
				continue;
			
			int left   = (i - 1) * n + j;
			int right  = (i + 1) * n + j;
			int center = i       * n + j;
			int bottom = i       * n + j - 1;
			int top    = i       * n + j + 1;

			double sx0 = s[left]   ;
			double sx1 = s[right]  ;
			double sy0 = s[bottom] ;
			double sy1 = s[top]    ;
			double _s  = sx0 + sx1 + sy0 + sy1;
			if (_s == 0) continue;

			double ux1  = u[right];
			double vy1  = v[top];
			double _div = ux1 - u[center] + vy1 - v[center];

			if (particleRestDensity > 0) {
				double compression = particleDensity[i * n + j] - particleRestDensity;
				if (compression > 0)
					_div = _div - compression;
			}

			double _p = -_div / _s;
			_p *= overRelaxation;
			p[center] += cp * _p;

			u[center] -= sx0 * _p;
			v[center] -= sy0 * _p;

			u[right] += sx1 * _p;
			v[top]   += sy1 * _p;
		}
	}

	setBoundary(domain, p);
	setBoundary(domain, u);
	setBoundary(domain, v);
}
cfunction double FLIP_simulate_solveIncompressibility(double dindex) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	solveIncompressibility(domain);
	return 0;
}

cfunction double FLIP_simulate(double dindex, double _dt) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];
	domain.dt = _dt;

	for (int i = 0; i < domain.globalIteration; i++) {
		integrateParticles(domain);
		pushParticlesApart(domain);
		handleParticleCollisions(domain);
		transferVelocities(domain, true);
		updateParticleDensity(domain);
		solveIncompressibility(domain);
		transferVelocities(domain, false);
	}

	return 0;
}

////////////////////////////////////////////////////////////////////// SPAWNER //////////////////////////////////////////////////////////////////////

cfunction double FLIP_spawnRandomFluid(double dindex, double amount) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	double h = 1.0 / domain.fInvSpacing;
	double r = domain.particleRadius;

	double minX = h + r;
	double maxX = (domain.fNumX - 1) * h - r;
	double minY = h + r;
	double maxY = (domain.fNumY - 1) * h - r;

	domain.numParticles = amount;
	int width = (int)(maxX - minX);
	int height = (int)(maxY - minY);
	double* particlePos = domain.particlePos;

	for (int i = 0; i < amount; i++) {
		double x = minX + (rand() % width);
		double y = minY + (rand() % height);
		particlePos[i * 2] = x;
		particlePos[i * 2 + 1] = y;
	}

	return 0;
}

cfunction double FLIP_spawnParticles(double dindex, double* particles, double* velocities, double amount) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	int index = domain.numParticles * 2;

	amount = min(amount, domain.maxParticles - domain.numParticles);
	domain.numParticles += amount;

	for (int i = 0; i < amount; i++) {
		domain.particlePos[index + i * 2 + 0] = particles[i * 2 + 0];
		domain.particlePos[index + i * 2 + 1] = particles[i * 2 + 1];

		domain.particleVel[index + i * 2 + 0] = velocities[i * 2 + 0];
		domain.particleVel[index + i * 2 + 1] = velocities[i * 2 + 1];
	}

	return 0;
}

///////////////////////////////////////////////////////////////////// DESTROYER /////////////////////////////////////////////////////////////////////

cfunction double FLIP_deleteParticle_circle(double dindex, double x, double y, double r, double rat) {
	if (dindex < 0 || dindex >= domains.size()) return -1;
	
	Domain& domain = domains[dindex];
	double* particlePos = domain.particlePos;

	double r2 = r * r;

	for (int i = 0; i < domain.numParticles; i++) {
		if ((double)(rand() % 100) / 100 > rat) continue;

		double dx = particlePos[i * 2 + 0] - x;
		double dy = particlePos[i * 2 + 1] - y;

		if (dx * dx + dy * dy < r2) {
			particlePos[i * 2 + 0] = 0;
			particlePos[i * 2 + 1] = 0;
		}
	}

	return 0;
}

cfunction double FLIP_deleteParticle_rectangle(double dindex, double x, double y, double w, double h, double rat) {
	if (dindex < 0 || dindex >= domains.size()) return -1;
	
	Domain& domain = domains[dindex];
	double* particlePos = domain.particlePos;

	for (int i = 0; i < domain.numParticles; i++) {
		if ((double)(rand() % 100) / 100 > rat) continue;

		double _x = particlePos[i * 2 + 0];
		double _y = particlePos[i * 2 + 1];

		if (_x > x - w && _x < x + w && _y > y - h && _y < y + h) {
			particlePos[i * 2 + 0] = 0;
			particlePos[i * 2 + 1] = 0;
		}
	}
	
	return 0;
}

//////////////////////////////////////////////////////////////////// EFFECTORS //////////////////////////////////////////////////////////////////////

cfunction double FLIP_resetObstracles(double dindex) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];
	domain.obstacles.clear();
	return 0;
}

cfunction double FLIP_createObstracle(double dindex) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];
	double index = domain.obstacles.size();
	domain.obstacles.push_back(Obstacle());
	return index;
}

cfunction double FLIP_setObstracle_circle(double dindex, double index, double _x, double _y, double _radius) {
	if (dindex < 0 || dindex >= domains.size()) return -1;
	
	Domain& domain = domains[dindex];

	if (index < 0 || index >= domain.obstacles.size()) return -1;
	Obstacle& obstacle = domain.obstacles[index];

	double vx = (_x - obstacle.x) * 5 * domain.dt;
	double vy = (_y - obstacle.y) * 5 * domain.dt;

	obstacle.type = circle;
	obstacle.x = _x;
	obstacle.y = _y;
	obstacle.radius = _radius;

	int n = domain.fNumY;

	double* s = domain.s;
	double* u = domain.u;
	double* v = domain.v;

	double h  = domain.h;
	double r2 = _radius * _radius;

	int i2;

	double* particleVel = domain.particleVel;

	for (int i = 1; i < domain.fNumX1; i++)
	for (int j = 1; j < domain.fNumY1; j++) {
		double dx = (i + 0.5) * h - _x;
		double dy = (j + 0.5) * h - _y;

		i2 = (i * n + j) * 2;

		if (dx * dx + dy * dy < r2) {
			s[i * n + j]       = 0;
			u[i * n + j]       = vx;
			u[(i + 1) * n + j] = vx;
			v[i * n + j]       = vy;
			v[i * n + j + 1]   = vy;
		}
	}

	obstacle.velX = vx;
	obstacle.velY = vy;

	return 0;
}

cfunction double FLIP_setObstracle_rectangle(double dindex, double index, double _x, double _y, double _width, double _height) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];
	
	if (index < 0 || index >= domain.obstacles.size()) return -1;
	Obstacle& obstacle = domain.obstacles[index];

	double vx = (_x - obstacle.x) * 5 * domain.dt;
	double vy = (_y - obstacle.y) * 5 * domain.dt;

	obstacle.type = rectangle;
	obstacle.x = _x;
	obstacle.y = _y;
	obstacle.width  = _width;
	obstacle.height = _height;

	int n = domain.fNumY;

	double* s = domain.s;
	double* u = domain.u;
	double* v = domain.v;

	double h = domain.h;

	double x0 = _x - _width;
	double x1 = _x + _width;
	double y0 = _y - _height;
	double y1 = _y + _height;

	int i0 = clamp(floor(x0 / h), 1, domain.fNumX1 - 1);
	int i1 = clamp(floor(x1 / h), 1, domain.fNumX1 - 1);
	int j0 = clamp(floor(y0 / h), 1, domain.fNumY1 - 1);
	int j1 = clamp(floor(y1 / h), 1, domain.fNumY1 - 1);

	for (int i = i0; i < i1; i++)
		for (int j = j0; j < j1; j++) {
		s[i * n + j]       = 0;
		u[i * n + j]       = vx;
		u[(i + 1) * n + j] = vx;
		v[i * n + j]       = vy;
		v[i * n + j + 1]   = vy;
	}

	obstacle.velX = vx;
	obstacle.velY = vy;

	return 0;
}

cfunction double FLIP_applyVelocity_circle(double dindex, double _x, double _y, double _radius, double _vx, double _vy) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];
	double vx = _vx;
	double vy = _vy;

	int n = domain.fNumY;

	double* u = domain.u;
	double* v = domain.v;

	double r2 = _radius * _radius;

	double* particleVel = domain.particleVel;
	double* particlePos = domain.particlePos;

	for (int i = 1; i < domain.numParticles; i++) {
		int i2 = i * 2;

		double _px = particlePos[i2];
		double _py = particlePos[i2 + 1];

		if(_px == 0 && _py == 0) continue;

		double dx = _px - _x;
		double dy = _py - _y;

		if (dx * dx + dy * dy < r2) {
			particleVel[i2]     += vx;
			particleVel[i2 + 1] += vy;
		}
	}

	return 0;
}

cfunction double FLIP_applyVelocity_rectangle(double dindex, double _x, double _y, double _width, double _height, double _vx, double _vy) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];
	double vx = _vx;
	double vy = _vy;

	int n = domain.fNumY;

	double* u = domain.u;
	double* v = domain.v;

	double h = domain.h;

	double x0 = _x - _width  * 0.5;
	double x1 = _x + _width  * 0.5;
	double y0 = _y - _height * 0.5;
	double y1 = _y + _height * 0.5;

	double* particleVel = domain.particleVel;
	double* particlePos = domain.particlePos;

	for (int i = 1; i < domain.numParticles; i++) {
		int i2 = i * 2;

		double px = particlePos[i2];
		double py = particlePos[i2 + 1];

		if(px == 0 && py == 0) continue;

		if (px > x0 && px < x1 && py > y0 && py < y1) {
			particleVel[i2]     += vx;
			particleVel[i2 + 1] += vy;
		}
	}

	return 0;
}

cfunction double FLIP_setSolid_rectangle(double dindex, double _x, double _y, double _width, double _height) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];

	int n = domain.fNumY;
	double* s = domain.s;

	double h = domain.h;
	double x0 = _x - _width;
	double x1 = _x + _width;
	double y0 = _y - _height;
	double y1 = _y + _height;
	int i0 = clamp(floor(x0 / h), 1, domain.fNumX1 - 1);
	int i1 = clamp(floor(x1 / h), 1, domain.fNumX1 - 1);
	int j0 = clamp(floor(y0 / h), 1, domain.fNumY1 - 1);
	int j1 = clamp(floor(y1 / h), 1, domain.fNumY1 - 1);
	
	for (int i = i0; i < i1; i++)
	for (int j = j0; j < j1; j++)
		s[i * n + j] = 0;
	
	return 0;

}

cfunction double FLIP_repel(double dindex, double _x, double _y, double _rad, double _str) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];
	
	double r2 = _rad * _rad;

	double* particleVel = domain.particleVel;
	double* particlePos = domain.particlePos;

	for (int i = 1; i < domain.numParticles; i++) {
		int i2 = i * 2;

		double _px = particlePos[i2];
		double _py = particlePos[i2 + 1];

		if(_px == 0 && _py == 0) continue;

		double dx = _px - _x;
		double dy = _py - _y;
		double dist = sqrt(dx * dx + dy * dy);
		
		if (dist < _rad) {
			double ang = atan2(dy, dx);

			particleVel[i2]     += (1 - dist / _rad) * cos(ang) * _str;
			particleVel[i2 + 1] += (1 - dist / _rad) * sin(ang) * _str;
		}
	}

	return 0;
}

cfunction double FLIP_vortex(double dindex, double _x, double _y, double _rad, double _str, double _attr) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];
	
	double r2 = _rad * _rad;

	double* particleVel = domain.particleVel;
	double* particlePos = domain.particlePos;

	for (int i = 1; i < domain.numParticles; i++) {
		int i2 = i * 2;

		double _px = particlePos[i2];
		double _py = particlePos[i2 + 1];

		if(_px == 0 && _py == 0) continue;

		double dx = _px - _x;
		double dy = _py - _y;
		double dist = sqrt(dx * dx + dy * dy);
		
		if (dist < _rad) {
			double ang = atan2(dy, dx);

			particleVel[i2]     += (1 - dist / _rad) * (cos(ang + M_PI / 2) * _str) - cos(ang) * _attr;
			particleVel[i2 + 1] += (1 - dist / _rad) * (sin(ang + M_PI / 2) * _str) - sin(ang) * _attr;
		}
	}

	return 0;
}

////////////////////////////////////////////////////////////////////// GETTERS //////////////////////////////////////////////////////////////////////

cfunction double FLIP_getParticleRadius(double dindex) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];
	return domain.particleRadius;
}

cfunction double FLIP_getNumParticles(double dindex) {
	if (dindex < 0 || dindex >= domains.size()) return -1;

	Domain& domain = domains[dindex];
	return domain.numParticles;
}
*/