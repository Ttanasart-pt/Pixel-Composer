#region grainSim
	global.GRAINSIM_JUNC = {
		icon:  function() /*=>*/ {return THEME.node_junction_grain},
		color: function() /*=>*/ {return COLORS.node_blend_grain},
		widg:  function() /*=>*/ {return new mkgrainBox()},
	}

	function GrainSim_Domain() constructor {
		index = 0;
		size  = 1;
	}
#endregion

/*[cpp] grainSim
#define DOMAIN_CHECK(d) if (d < 0 || d >= domains.size()) return -1; GrainSimDomain& domain = domains[static_cast<int>(d)];

#include <cstring>
#include <cstdint>
#include <vector>
#include <cmath>
#include <algorithm>

	////- Util

struct Vec2 {
    double x, y;
    Vec2(double x = 0, double y = 0) : x(x), y(y) {}

    Vec2 operator+(const Vec2& o) const { return Vec2(x + o.x, y + o.y); }
    Vec2 operator-(const Vec2& o) const { return Vec2(x - o.x, y - o.y); }
    Vec2 operator*(double s) const { return Vec2(x * s, y * s); }
    Vec2 operator/(double s) const { return Vec2(x / s, y / s); }
    Vec2& operator+=(const Vec2& o) { x += o.x; y += o.y; return *this; }
    Vec2& operator/=(double s) { x /= s; y /= s; return *this; }

    double norm() const { return std::sqrt(x * x + y * y); }
};

inline Vec2 operator*(double s, const Vec2& v) { return Vec2(v.x * s, v.y * s); }
inline Vec2 sqr(const Vec2& v) { return Vec2(v.x * v.x, v.y * v.y); }

struct Mat2 {
    double m[2][2];
    Mat2(double diag = 0) {
        m[0][0] = diag; m[0][1] = 0;
        m[1][0] = 0;    m[1][1] = diag;
    }
    Mat2(double m00, double m01, double m10, double m11) {
        m[0][0] = m00; m[0][1] = m01;
        m[1][0] = m10; m[1][1] = m11;
    }

    Mat2 operator+(const Mat2& o) const {
        return Mat2(m[0][0] + o.m[0][0], m[0][1] + o.m[0][1],
                    m[1][0] + o.m[1][0], m[1][1] + o.m[1][1]);
    }
    Mat2 operator-(const Mat2& o) const {
        return Mat2(m[0][0] - o.m[0][0], m[0][1] - o.m[0][1],
                    m[1][0] - o.m[1][0], m[1][1] - o.m[1][1]);
    }
    Mat2 operator*(double s) const {
        return Mat2(m[0][0] * s, m[0][1] * s, m[1][0] * s, m[1][1] * s);
    }
    Mat2 operator*(const Mat2& o) const {
        return Mat2(
            m[0][0] * o.m[0][0] + m[0][1] * o.m[1][0], m[0][0] * o.m[0][1] + m[0][1] * o.m[1][1],
            m[1][0] * o.m[0][0] + m[1][1] * o.m[1][0], m[1][0] * o.m[0][1] + m[1][1] * o.m[1][1]
        );
    }
    Vec2 operator*(const Vec2& v) const {
        return Vec2(m[0][0] * v.x + m[0][1] * v.y, m[1][0] * v.x + m[1][1] * v.y);
    }

    Mat2 transpose() const { return Mat2(m[0][0], m[1][0], m[0][1], m[1][1]); }
    double det() const { return m[0][0] * m[1][1] - m[0][1] * m[1][0]; }

    static Mat2 outer_product(const Vec2& a, const Vec2& b) {
        return Mat2(a.x * b.x, a.x * b.y, a.y * b.x, a.y * b.y);
    }
};

inline Mat2 operator*(double s, const Mat2& m) { return m * s; }

struct Vec3 {
    double x, y, z;
    Vec3(double x = 0, double y = 0, double z = 0) : x(x), y(y), z(z) {}
    Vec3(const Vec2& v2, double z = 0) : x(v2.x), y(v2.y), z(z) {}

    Vec3 operator+(const Vec3& o) const { return Vec3(x + o.x, y + o.y, z + o.z); }
    Vec3 operator*(double s) const { return Vec3(x * s, y * s, z * s); }
    Vec3& operator+=(const Vec3& o) { x += o.x; y += o.y; z += o.z; return *this; }
    Vec3& operator/=(double s) { x /= s; y /= s; z /= s; return *this; }
    double& operator[](int i) { return (i == 0) ? x : (i == 1 ? y : z); }
    double operator[](int i) const { return (i == 0) ? x : (i == 1 ? y : z); }
};

inline Vec3 operator*(double s, const Vec3& v) { return Vec3(v.x * s, v.y * s, v.z * s); }

void polar_decomp(const Mat2& m, Mat2& R, Mat2& S) {
    double x = m.m[0][0] + m.m[1][1];
    double y = m.m[1][0] - m.m[0][1];
    double scale = 1.0 / std::sqrt(x * x + y * y);
    double c = x * scale;
    double s = y * scale;
    R = Mat2(c, -s, s, c);
    S = R.transpose() * m;
}

void svd(const Mat2& m, Mat2& U, Mat2& Sig, Mat2& V) {
    polar_decomp(m, U, Sig);
    double c = 1.0, s = 0.0;
    if (std::abs(Sig.m[0][1]) > 1e-6) {
        double tau = (Sig.m[0][0] - Sig.m[1][1]) / (2.0 * Sig.m[0][1]);
        double t = (tau >= 0 ? 1.0 : -1.0) / (std::abs(tau) + std::sqrt(1.0 + tau * tau));
        c = 1.0 / std::sqrt(1.0 + t * t);
        s = t * c;
    }
    Mat2 V_rot(c, -s, s, c);
    Sig = V_rot.transpose() * Sig * V_rot;
    U = U * V_rot;
    V = V_rot;
}

int abgr_to_int(int a, int b, int g, int r) {
    return (a << 24) | (b << 16) | (g << 8) | r;
}

int grey_to_color(float grey) {
    int grey_int = static_cast<int>(grey * 255.0f);
    grey_int = std::clamp(grey_int, 0, 255);
    return (0xFF << 24) | (grey_int << 16) | (grey_int << 8) | grey_int;
}

uint32_t color_blend(uint32_t c1, uint32_t c2, double alpha) {
    double r1 = (c1 >>  0) & 0xFF;
    double g1 = (c1 >>  8) & 0xFF;
    double b1 = (c1 >> 16) & 0xFF;
    double a1 = (c1 >> 24) & 0xFF;

    double r2 = (c2 >>  0) & 0xFF;
    double g2 = (c2 >>  8) & 0xFF;
    double b2 = (c2 >> 16) & 0xFF;
    double a2 = (c2 >> 24) & 0xFF;

    a2 *= alpha;

    double a = a1 + (1.0 - a1 / 255.0) * a2;
    double r = (r1 * a1 + r2 * a2 * (1.0 - a1 / 255.0)) / a;
    double g = (g1 * a1 + g2 * a2 * (1.0 - a1 / 255.0)) / a;
    double b = (b1 * a1 + b2 * a2 * (1.0 - a1 / 255.0)) / a;

    return (static_cast<uint32_t>(a) << 24) |
           (static_cast<uint32_t>(b) << 16) |
           (static_cast<uint32_t>(g) << 8) |
            static_cast<uint32_t>(r);
}

	////- GrainSim

// ============================================================================
// Simulation Parameters & Structures
// ============================================================================

struct Particle {
    Vec2 x, v;
    Mat2 F, C;
    Vec2 force;

    double Jp;
    int c;

	bool active = true;
    bool sleep  = false;
    
    Particle(Vec2 x, int c, Vec2 v = Vec2(0, 0)) : x(x), v(v), F(1.0), C(0.0), Jp(1.0), c(c) {}
};

struct ParticleData {
	double x;
	double y;
	uint32_t c;
	uint32_t _;
};

struct GrainSimDomain {
	int n = 32; // Grid resolution

	double dt     = 1e-4;
	double dx     = 1.0 / n;
	double inv_dx = 1.0 / dx;

	double particle_mass = 1.0;
	double vol           = 1.0;
	double hardening     = 10.0;
	double gravity       = -800.;
	
	double granular = 1;
	uint8_t wall    = 0b11111111;

    bool   sleepable       = false;
    double sleep_threshold = 0.01;
    
    double E        = 1e4;
    double nu       = 0.2;
	double mu_0     = E / (2.0 * (1.0 + nu));
	double lambda_0 = E * nu / ((1.0 + nu) * (1.0 - 2.0 * nu));

	std::vector<Particle> particles;
	std::vector<std::vector<Vec3>> grid;
    std::vector<std::vector<bool>> solid;

    Vec2 normalize(Vec2 v) { 
        double xx = v.x * dx;
        double yy = v.y * dx;

        xx = std::clamp(xx, 0.0, 1.0);
        yy = std::clamp(yy, 0.0, 1.0);
        yy = 1 - yy;

        return Vec2(xx, yy); 
    }

    Vec2 denormalize(Vec2 v) {
        double xx = v.x * inv_dx;
        double yy = (1 - v.y) * inv_dx;

        return Vec2(xx, yy);
    }
};

std::vector<GrainSimDomain> domains;

// ============================================================================
// Core MLS-MPM Physics Engine Step
// ============================================================================
void advance(double domain_id) {
    if (domain_id < 0 || domain_id >= domains.size()) return;

    auto &domain     = domains[domain_id];
    int  n           = domain.n;
    auto &grid       = domain.grid;
    auto &solid      = domain.solid;
    auto &particles  = domain.particles;

    double dt        = domain.dt;
    double dx        = domain.dx;
    double inv_dx    = domain.inv_dx;

    double pmass     = domain.particle_mass;
    double vol       = domain.vol;
    double hardening = domain.hardening;
    double gravity   = domain.gravity;

    double granular  = domain.granular;
    
    double E         = domain.E;
    double nu        = domain.nu;
    double mu_0      = domain.mu_0;
    double lambda_0  = domain.lambda_0;

    bool   sleepable       = domain.sleepable;
    double sleep_threshold = domain.sleep_threshold;

    uint8_t wall = domain.wall;
    bool wt = (wall & 0b0001) > 0;
    bool wb = (wall & 0b0010) > 0;
    bool wl = (wall & 0b0100) > 0;
    bool wr = (wall & 0b1000) > 0;
    
	int bt = wt?   0 :   1;
	int bb = wb? n-2 : n-3;
	int bl = wl?   0 :   1;
	int br = wr? n-2 : n-3;
	
    for (int i = 0; i <= n; i++)
    for (int j = 0; j <= n; j++)
        grid[i][j] = Vec3(0, 0, 0);
	
    // --- P2G: Particle to Grid ---
    for (auto &p : particles) {
    	// if(p.sleep) continue;
    	
    	int base_x = (int)(p.x.x * inv_dx - 0.5);
        int base_y = (int)(p.x.y * inv_dx - 0.5);
        
        if(base_x < bl || base_y < bt || base_x > br || base_y > bb) {
        	p.active = false;
        	continue;
        }
        
        Vec2 fx = p.x * inv_dx - Vec2(base_x, base_y);

        // Quadratic B-Spline Weights
        Vec2 w[3]{
            0.5 * sqr(Vec2(1.5, 1.5) - fx),
            Vec2(0.75, 0.75) - sqr(fx - Vec2(1.0, 1.0)),
            0.5 * sqr(fx - Vec2(0.5, 0.5))
        };

        double e  = std::exp(hardening * (1.0 - p.Jp));
        double mu = mu_0 * e, lambda = lambda_0 * e;
        double J  = p.F.det();

        Mat2 r(1.0), s(0.0);
        polar_decomp(p.F, r, s);

        Mat2 stress = -4.0 * inv_dx * inv_dx * dt * vol * 
                      (2.0 * mu * (p.F - r) * p.F.transpose() + lambda * (J - 1.0) * J);
        Mat2 affine = stress + pmass * p.C;

        for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++) {
            Vec2 dpos = (Vec2(i, j) - fx) * dx;
            Vec3 mv(p.v * pmass, pmass);
            double weight = w[i].x * w[j].y;
            
            int gx = base_x + i;
            int gy = base_y + j;
            if(gx < 0 || gx > n || gy < 0 || gy > n) continue;
            if(solid[gx][gy]) continue; // Skip solid cells

            grid[gx][gy] += weight * (mv + Vec3(affine * dpos, 0.0));
        }
    }

    // --- Grid Operations (Gravity & Boundary Conditions) ---
    int b = 2;
    
    for (int i = 0; i <= n; i++)
    for (int j = 0; j <= n; j++) {
        auto &g = grid[i][j];
		
        if (g.z > 0) g /= g.z;
        g += dt * Vec3(0, gravity, 0);  // Gravity
    }

    // --- Collision ---
    for (int i = 0; i <= n; i++)
    for (int j = 0; j <= n; j++) {
        if(solid[i][j]) grid[i][j] = Vec3(0, 0, 0);
    }

    // --- No wall Boundary ---
    if(wl) {
        for(int i = 0; i < b; i++)
        for(int j = 0; j <= n; j++)
            grid[i][j].x = std::max(0., grid[i][j].x);
    }

    if(wr) {
        for(int i = n-b+1; i <= n; i++)
        for(int j = 0; j <= n; j++)
            grid[i][j].x = std::min(0., grid[i][j].x);
    }

    if(wt) {
        for(int j = n-b+1; j <= n; j++)
        for(int i = 0; i <= n; i++)
            grid[i][j].y = std::min(0., grid[i][j].y);
    }

    if(wb) {
        for(int j = 0; j < b; j++)
        for(int i = 0; i <= n; i++)
            grid[i][j].y = std::max(0., grid[i][j].y);
    }
    
    double gra_min = granular > 0.? 1. - 2.5e-2 / (.3 + granular * .7) : 1.;
    double gra_max = granular > 0.? 1. + 7.5e-3 / (.3 + granular * .7) : 1.;
    
    // --- G2P: Grid to Particle & Plasticity Update ---
    for (auto &p : particles) {
        int base_x = (int)(p.x.x * inv_dx - 0.5);
        int base_y = (int)(p.x.y * inv_dx - 0.5);
        
        if(!p.active) {
        	p.v.y  += dt * gravity;
        	p.x    += dt * p.v;
        	
        	p.C     = Mat2(0.);
        	p.force = Vec2(0., 0.);
        	continue;
        }
        
        Vec2 fx = p.x * inv_dx - Vec2(base_x, base_y);

        Vec2 w[3] {
            0.5 * sqr(Vec2(1.5, 1.5) - fx),
            Vec2(0.75, 0.75) - sqr(fx - Vec2(1.0, 1.0)),
            0.5 * sqr(fx - Vec2(0.5, 0.5))
        };

        p.C = Mat2(0.0);
        p.v = Vec2(0.0, 0.0);

        for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++) {
            Vec2 dpos = Vec2(i, j) - fx;
            
            int gx = base_x + i;
            int gy = base_y + j;
            if(gx < 0 || gx > n || gy < 0 || gy > n) continue;
            Vec2 grid_v(grid[gx][gy].x, grid[gx][gy].y);
            
            double weight = w[i].x * w[j].y;
            p.v += weight * grid_v;
            p.C = p.C + 4.0 * inv_dx * Mat2::outer_product(weight * grid_v, dpos);
        }

        p.v += dt * p.force;
        if (sleepable && p.v.norm() < sleep_threshold) 
            p.v = Vec2(0.0, 0.0);
        
        p.x += dt * p.v;
        
        p.force = Vec2(0.0, 0.0);
        Mat2 F = (Mat2(1.0) + dt * p.C) * p.F;

        Mat2 svd_u, sig, svd_v;
        svd(F, svd_u, sig, svd_v);

        if (granular > 0.) {
            sig.m[0][0] = std::clamp(sig.m[0][0], gra_min, gra_max);
            sig.m[1][1] = std::clamp(sig.m[1][1], gra_min, gra_max);
        }

        double oldJ = F.det();
        F = svd_u * sig * svd_v.transpose();
        p.Jp = std::clamp(p.Jp * oldJ / F.det(), 0.6, 20.0);
        p.F = F;
    }
    
}

	////- Domain

cfunction double grainSim_init(double size) {
	int isize = static_cast<int>(size);
    GrainSimDomain domain;

    domain.n = isize;
    domain.dx = 1.0 / domain.n;
    domain.inv_dx = 1.0 / domain.dx;
    domain.grid.resize(  domain.n + 1, std::vector<Vec3>(domain.n + 1, Vec3(0,0,0) ));
    domain.solid.resize( domain.n + 1, std::vector<bool>(domain.n + 1, false       ));
    domains.push_back(domain);

	return domains.size() - 1;
}

cfunction double grainSim_refresh(double domain_id) {
	DOMAIN_CHECK(domain_id)
	int  n = domain.n;
	auto &solid = domain.solid;
	
    for (int i = 0; i <= n; i++)
    for (int j = 0; j <= n; j++)
        solid[i][j] = false;
        
   return 0;
}

cfunction double grainSim_destroy(double domain_id) { DOMAIN_CHECK(domain_id) domains.erase(domains.begin() + domain_id); return 0; }

cfunction double grainSim_getGridSize(double domain_id) { DOMAIN_CHECK(domain_id) return static_cast<double>(domain.n); }
cfunction double grainSim_getParticleCount(double domain_id) { DOMAIN_CHECK(domain_id) return domain.particles.size(); }

cfunction double grainSim_getTimestep(double domain_id) { DOMAIN_CHECK(domain_id) return domain.dt; }
cfunction double grainSim_setTimestep(double domain_id, double dt) { DOMAIN_CHECK(domain_id) domain.dt = dt / 10000.; return dt; }

cfunction double grainSim_setStiffness(double domain_id, double young, double poisson) { 
	DOMAIN_CHECK(domain_id) 
	
	double E  = young;
	double nu = poisson;
	
	domain.E  = E; 
	domain.nu = nu; 
	
	domain.mu_0     = E / (2.0 * (1.0 + nu));
	domain.lambda_0 = E * nu / ((1.0 + nu) * (1.0 - 2.0 * nu));
	
	return 0; 
}

cfunction double grainSim_getPartMass(double domain_id) { DOMAIN_CHECK(domain_id) return domain.particle_mass; }
cfunction double grainSim_setPartMass(double domain_id, double pmass) { DOMAIN_CHECK(domain_id) domain.particle_mass = pmass; return 0; }

cfunction double grainSim_getVol(double domain_id) { DOMAIN_CHECK(domain_id) return domain.vol; }
cfunction double grainSim_setVol(double domain_id, double vol) { DOMAIN_CHECK(domain_id) domain.vol = vol; return 0; }

cfunction double grainSim_getHardening(double domain_id) { DOMAIN_CHECK(domain_id) return domain.hardening; }
cfunction double grainSim_setHardening(double domain_id, double hardening) { DOMAIN_CHECK(domain_id) domain.hardening = hardening; return 0; }

cfunction double grainSim_getGravity(double domain_id) { DOMAIN_CHECK(domain_id) return domain.gravity; }
cfunction double grainSim_setGravity(double domain_id, double gravity) { DOMAIN_CHECK(domain_id) domain.gravity = gravity; return 0; }

cfunction double grainSim_getGranular(double domain_id) { DOMAIN_CHECK(domain_id) return domain.granular; }
cfunction double grainSim_setGranular(double domain_id, double granular) { DOMAIN_CHECK(domain_id) domain.granular = granular; return 0; }

cfunction double grainSim_setWall(double domain_id, double wall) { DOMAIN_CHECK(domain_id) domain.wall = static_cast<uint8_t>(wall); return 0; }

cfunction double grainSim_setSleep(double domain_id, double sleepable, double sleep_threshold) { 
    DOMAIN_CHECK(domain_id) 
    domain.sleepable = static_cast<bool>(sleepable); 
    domain.sleep_threshold = sleep_threshold; 
    return 0; 
}

cfunction double grainSim_step(double domain_id, double iteration) {
	int itr = static_cast<int>(iteration);
	for (int i = 0; i < itr; i++) 
		advance(domain_id);
	return 0;
}

cfunction double grainSim_output(double domain_id, void* outputBuffer) {
    DOMAIN_CHECK(domain_id)
	
	ParticleData* outputBufferVec = static_cast<ParticleData*>(outputBuffer);
	
	for (size_t i = 0; i < domain.particles.size(); i++) {
		Particle& p = domain.particles[i];
		// if(!p.active) continue;
		
        Vec2 pN = domain.denormalize(p.x);

		outputBufferVec[i].x = pN.x;
		outputBufferVec[i].y = pN.y;
		outputBufferVec[i].c = p.c;
	}
	
	return 0;
}

cfunction double grainSim_render(double domain_id, void* surfaceBuffer) {
	DOMAIN_CHECK(domain_id)
	
	uint32_t* outputBufferVec = static_cast<uint32_t*>(surfaceBuffer);
    memset(outputBufferVec, 0, domain.n * domain.n * sizeof(uint32_t));
	
    for (size_t i = 0; i < domain.particles.size(); i++) {
        Particle& p = domain.particles[i];
		// if(!p.active) continue;
		
        Vec2   pN = domain.denormalize(p.x);
        double px = pN.x;
        double py = pN.y;

        int x = static_cast<int>(px);
        int y = static_cast<int>(py);
		
        if (x >= 0 && x < domain.n && y >= 0 && y < domain.n)
            outputBufferVec[y * domain.n + x] = p.c;
    }

	return 0;
}

cfunction double grainSim_render_aa(double domain_id, void* surfaceBuffer) {
	DOMAIN_CHECK(domain_id)
	
	uint32_t* outputBufferVec = static_cast<uint32_t*>(surfaceBuffer);
    memset(outputBufferVec, 0, domain.n * domain.n * sizeof(uint32_t));
	
    for (size_t i = 0; i < domain.particles.size(); i++) {
        Particle& p = domain.particles[i];
        // if(!p.active) continue;
		
        Vec2   pN = domain.denormalize(p.x);
        double px = pN.x;
        double py = pN.y;

        double fx = std::floor(px);
        double fy = std::floor(py);

        double dx = px - fx;
        double dy = py - fy;

        int x = static_cast<int>(fx);
        int y = static_cast<int>(fy);
        
        double g00 = (1.0 - dx) * (1.0 - dy);
        double g10 = dx * (1.0 - dy);
        double g01 = (1.0 - dx) * dy;
        double g11 = dx * dy;

        if (x >= 0 && x < domain.n && y >= 0 && y < domain.n)
            outputBufferVec[y * domain.n + x] = color_blend(outputBufferVec[y * domain.n + x], p.c, g00);

        if (x + 1 >= 0 && x + 1 < domain.n && y >= 0 && y < domain.n)
            outputBufferVec[y * domain.n + (x + 1)] = color_blend(outputBufferVec[y * domain.n + (x + 1)], p.c, g10);

        if (x >= 0 && x < domain.n && y + 1 >= 0 && y + 1 < domain.n)
            outputBufferVec[(y + 1) * domain.n + x] = color_blend(outputBufferVec[(y + 1) * domain.n + x], p.c, g01);

        if (x + 1 >= 0 && x + 1 < domain.n && y + 1 >= 0 && y + 1 < domain.n)
            outputBufferVec[(y + 1) * domain.n + (x + 1)] = color_blend(outputBufferVec[(y + 1) * domain.n + (x + 1)], p.c, g11);

    }

	return 0;
}

cfunction double grainSim_render_grid_velocity(double domain_id, double scale, void* surfaceBuffer) {
    DOMAIN_CHECK(domain_id)

    uint32_t* outputBufferVec = static_cast<uint32_t*>(surfaceBuffer);
    memset(outputBufferVec, 0, domain.n * domain.n * sizeof(uint32_t));

    auto& grid = domain.grid;
	int  n     = domain.n;

    for (int y = 0; y < n; y++)
    for (int x = 0; x < n; x++) {
        Vec3   gr  = grid[x][n-y-1];
        double vel = sqrt(gr.x * gr.x + gr.y * gr.y) * scale;

        outputBufferVec[y * n + x] = grey_to_color(vel);
    }

    return 0;
}

cfunction double grainSim_render_grid_density(double domain_id, double scale, void* surfaceBuffer) {
    DOMAIN_CHECK(domain_id)

    uint32_t* outputBufferVec = static_cast<uint32_t*>(surfaceBuffer);
    memset(outputBufferVec, 0, domain.n * domain.n * sizeof(uint32_t));

    auto& grid = domain.grid;
	int  n     = domain.n;

    for (int y = 0; y < n; y++)
    for (int x = 0; x < n; x++) {
        double den = grid[x][n-y-1].z * scale;

        outputBufferVec[y * n + x] = grey_to_color(den);
    }

    return 0;
}

	////- Particle

struct SpawnParam {
	uint32_t color = 0;
    bool sleep = false;
    
}; SpawnParam spawnParam;

cfunction double grainSim_setSpawnParam(double color, double sleep) {
    spawnParam.color = static_cast<uint32_t>(color);
    spawnParam.sleep = (sleep != 0.);
    return 0;
}

cfunction double grainSim_Particle_Add_Rectangle(double domain_id, double x, double y, double width, double height, double spacing) {
    DOMAIN_CHECK(domain_id)
    
    int nx = static_cast<int>(width / spacing);
    int ny = static_cast<int>(height / spacing);

    for (int i = -nx; i < nx; i++)
    for (int j = -ny; j < ny; j++) {
        double px = x + i * spacing;
        double py = y + j * spacing;
        Vec2 pN = domain.normalize(Vec2(px, py));   

        Particle p(pN, spawnParam.color);
        p.sleep = spawnParam.sleep;
        
        domain.particles.push_back(p);
    }

    return 0;
}
cfunction double grainSim_Particle_Add_Circle(double domain_id, double x, double y, double rx, double ry, double spacing) {
    DOMAIN_CHECK(domain_id)

    int nx = static_cast<int>(rx / spacing);
    int ny = static_cast<int>(ry / spacing);
    double r2x = rx * rx;
    double r2y = ry * ry;

    for (int i = -nx; i <= nx; i++)
    for (int j = -ny; j <= ny; j++) {
        double px = x + i * spacing;
        double py = y + j * spacing;
        if ((px - x) * (px - x) / r2x + (py - y) * (py - y) / r2y > 1.0) 
            continue;

        Vec2 pN = domain.normalize(Vec2(px, py));
        
        Particle p(pN, spawnParam.color);
        p.sleep = spawnParam.sleep;

        domain.particles.push_back(p);
    }

    return 0;
}
cfunction double grainSim_Particle_Add_Buffer(double domain_id, void* inputBuffer) {
    DOMAIN_CHECK(domain_id)

    int n = domain.n;
    int i = 0;
    uint32_t* inputBufferVal = static_cast<uint32_t*>(inputBuffer);
    
    for (int y = 0; y < n; y++) 
    for (int x = 0; x < n; x++) {
    	uint32_t col = inputBufferVal[i++];
        uint8_t alpha = (col >> 24) & 0xFF;

        if(alpha == 0) continue;

        double px = static_cast<double>(x);
        double py = static_cast<double>(y);

        Vec2 pN = domain.normalize(Vec2(px, py));

        Particle p(pN, col);
        p.sleep = spawnParam.sleep;
        
        domain.particles.push_back(p);
    }

    return 0;
}

cfunction double grainSim_Particle_Delete_Rectangle(double domain_id, double x, double y, double width, double height) {
    DOMAIN_CHECK(domain_id)
    
    for (auto it = domain.particles.begin(); it != domain.particles.end(); ) {
    	Vec2 pN = domain.denormalize(it->x);
        double px = pN.x;
        double py = pN.y;
        if (px >= x - width && px <= x + width && py >= y - height && py <= y + height)
            it = domain.particles.erase(it);
        else
            it++;
    }

    return 0;
}
cfunction double grainSim_Particle_Delete_Circle(double domain_id, double x, double y, double rx, double ry) {
    DOMAIN_CHECK(domain_id)

    double r2x = rx * rx;
    double r2y = ry * ry;

    for (auto it = domain.particles.begin(); it != domain.particles.end(); ) {
    	Vec2 pN = domain.denormalize(it->x);
        double px = pN.x;
        double py = pN.y;
        if ((px - x) * (px - x) / r2x + (py - y) * (py - y) / r2y <= 1.0)
            it = domain.particles.erase(it);
        else
            it++;
    }

    return 0;
}
cfunction double grainSim_Particle_Delete_Buffer(double domain_id, void* inputBuffer) {
    DOMAIN_CHECK(domain_id)

    int n = domain.n;
    uint8_t* inputBufferVal = static_cast<uint8_t*>(inputBuffer);

    for (auto it = domain.particles.begin(); it != domain.particles.end(); ) {
        Vec2 pN = domain.denormalize(it->x);
        int ind = static_cast<int>(pN.x) * n + static_cast<int>(pN.y);
        if (inputBufferVal[ind] == 0)
            it++;
        else
            it = domain.particles.erase(it);
    }

    return 0;
}

cfunction double grainSim_Particle_Wake_Rectangle(double domain_id, double x, double y, double width, double height) {
    DOMAIN_CHECK(domain_id)

    for (auto& p : domain.particles) {
    	Vec2 pN = domain.denormalize(p.x);
    	double px = pN.x;
        double py = pN.y;
        
        if (px >= x - width && px <= x + width && py >= y - height && py <= y + height)
            p.sleep = false;
    }

    return 0;
}
cfunction double grainSim_Particle_Wake_Circle(double domain_id, double x, double y, double rx, double ry) {
    DOMAIN_CHECK(domain_id)

    double r2x = rx * rx;
    double r2y = ry * ry;

    for (auto& p : domain.particles) {
        Vec2 pN = domain.denormalize(p.x);
    	double px = pN.x;
        double py = pN.y;
        
        if ((px - x) * (px - x) / r2x + (py - y) * (py - y) / r2y <= 1.0)
            p.sleep = false;
    }

    return 0;
}
cfunction double grainSim_Particle_Wake_Buffer(double domain_id, void* inputBuffer) {
    DOMAIN_CHECK(domain_id)

    int n = domain.n;
    uint8_t* inputBufferVal = static_cast<uint8_t*>(inputBuffer);

    for (auto& p : domain.particles) {
        Vec2 pN = domain.denormalize(p.x);
        int ind = (static_cast<int>(pN.y)) * n + static_cast<int>(pN.x);
        
        double f = inputBufferVal[ind] / 255.;
        if (f > 0) p.sleep = false;
    }

    return 0;
}

    ////- Force

struct ForceParam {
    double fx;
    double fy;
}; ForceParam forceParam;

cfunction double grainSim_setForceParam(double force_x, double force_y) {
    forceParam.fx = force_x;
    forceParam.fy = force_y;
    return 0;
}

cfunction double grainSim_Force_Apply_Rectangle(double domain_id, double x, double y, double width, double height) {
    DOMAIN_CHECK(domain_id)

    for (auto& p : domain.particles) {
    	Vec2 pN = domain.denormalize(p.x);
    	double px = pN.x;
        double py = pN.y;
        
        if (px >= x - width && px <= x + width && py >= y - height && py <= y + height) {
            p.sleep = false;
            p.force.x += forceParam.fx;
            p.force.y += forceParam.fy;
        }
    }

    return 0;
}
cfunction double grainSim_Force_Apply_Circle(double domain_id, double x, double y, double rx, double ry) {
    DOMAIN_CHECK(domain_id)

    double r2x = rx * rx;
    double r2y = ry * ry;

    for (auto& p : domain.particles) {
        Vec2 pN = domain.denormalize(p.x);
    	double px = pN.x;
        double py = pN.y;
        
        if ((px - x) * (px - x) / r2x + (py - y) * (py - y) / r2y <= 1.0) {
            p.sleep = false;
            p.force.x += forceParam.fx;
            p.force.y += forceParam.fy;
        }
    }

    return 0;
}
cfunction double grainSim_Force_Apply_Buffer(double domain_id, void* inputBuffer) {
    DOMAIN_CHECK(domain_id)

    int n = domain.n;
    uint8_t* inputBufferVal = static_cast<uint8_t*>(inputBuffer);

    for (auto& p : domain.particles) {
        Vec2 pN = domain.denormalize(p.x);
        int ind = (static_cast<int>(pN.y)) * n + static_cast<int>(pN.x);
        
        double f = inputBufferVal[ind] / 255.;
        if (f > 0) {
        	p.sleep = false;
            p.force.x += forceParam.fx * f;
            p.force.y += forceParam.fy * f;
        }
    }

    return 0;
}

cfunction double grainSim_Force_Apply_Surface(double domain_id, double strength, void* surfaceBuffer) {
    DOMAIN_CHECK(domain_id)

    int n = domain.n;
    uint32_t* surfaceBufferVal = static_cast<uint32_t*>(surfaceBuffer);

    for (auto& p : domain.particles) {
        Vec2 pN = domain.denormalize(p.x);
        int ind = (static_cast<int>(pN.y)) * n + static_cast<int>(pN.x);
        
        uint32_t force = surfaceBufferVal[ind];
        
        int fa = (force >> 24) & 0xFF;
        if(fa <= 0) continue;

        double fx = (double)((force >>  0) & 0xFF) / 255.;
        double fy = (double)((force >>  8) & 0xFF) / 255.;
		
		fx = fx * 2. - 1.;
		fy = fy * 2. - 1.;
		
        p.sleep = false;
        p.force.x += fx * strength;
        p.force.y -= fy * strength;
    }

    return 0;
}

    ////- Collision

cfunction double grainSim_Solid_Rectangle(double domain_id, double x, double y, double width, double height) {
    DOMAIN_CHECK(domain_id)

	int n = domain.n;

    for(int i = 0; i <= n; i++)
    for(int j = 0; j <= n; j++) {
        int _x = i;
        int _y = n - j;
        
        if (_x >= x - width && _x <= x + width && _y >= y - height && _y <= y + height)
            domain.solid[i][j] = true;
    }

    return 0;
}
cfunction double grainSim_Solid_Circle(double domain_id, double x, double y, double rx, double ry) {
    DOMAIN_CHECK(domain_id)

	int n = domain.n;

    double r2x = rx * rx;
    double r2y = ry * ry;

    for(int i = 0; i <= n; i++)
    for(int j = 0; j <= n; j++) {
        int _x = i;
        int _y = n - j;
        
        if ((_x - x) * (_x - x) / r2x + (_y - y) * (_y - y) / r2y <= 1.0)
            domain.solid[i][j] = true;
    }

    return 0;
}
cfunction double grainSim_Solid_Buffer(double domain_id, void* buffer) {
    DOMAIN_CHECK(domain_id)

	int n = domain.n;

    uint8_t* solid_buffer = static_cast<uint8_t*>(buffer);

    for(int i = 0; i < n; i++)
    for(int j = 0; j < n; j++) {
        int _x = i;
        int _y = n - j - 1;
        
        domain.solid[i][j] = solid_buffer[_y * n + _x] != 0;
    }
    
    return 0;
}

*/