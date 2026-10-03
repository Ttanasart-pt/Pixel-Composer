function Node_grainSim_Test(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "grainSim Test";
	update_on_frame = true;
	
	newOutput(0, nodeValue_Output("Output", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	grainSimTest_init();
	outpBuff = undefined;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {}
	
	static update = function() {
		if(IS_FIRST_FRAME) grainSimTest_init();
		
		// if(CURRENT_FRAME % 2 == 0)
		grainSimTest_addObject(16, 8, 3, make_color_hsv(random(255), 200, 255), 4);
		grainSimTest_step(32);
		
		var partAmo = grainSimTest_getParticleCount();
		outpBuff = buffer_verify(outpBuff, partAmo * 8 * 3, buffer_grow);
		grainSimTest_output(buffer_get_address(outpBuff));
		
		var _gridSize = 32;
		var _outSurf  = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, _gridSize, _gridSize);
		outputs[0].setValue(_outSurf);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_NORMAL
			
			buffer_to_start(outpBuff);
			var i = 0;
			
			repeat(partAmo) {
				var px = buffer_read(outpBuff, buffer_f64);
				var py = buffer_read(outpBuff, buffer_f64);
				var pc = buffer_read(outpBuff, buffer_u32);
				var _  = buffer_read(outpBuff, buffer_u32);
				
				draw_point_color(px, py, pc);
				i++;
			}
			
			BLEND_NORMAL
		surface_reset_target();
	}
}

/*[cpp] grainSim_Test

// Simplified version of Yuanming Hu's 88-Line 2D Moving Least Squares Material Point Method (MLS-MPM)

#include <cstdint>
#include <iostream>
#include <vector>
#include <cmath>
#include <cstring>
#include <algorithm>
#include <fstream>
#include <iomanip>

struct Vec2 {
    double x, y;
    Vec2(double x = 0, double y = 0) : x(x), y(y) {}

    Vec2 operator+(const Vec2& o) const { return Vec2(x + o.x, y + o.y); }
    Vec2 operator-(const Vec2& o) const { return Vec2(x - o.x, y - o.y); }
    Vec2 operator*(double s) const { return Vec2(x * s, y * s); }
    Vec2 operator/(double s) const { return Vec2(x / s, y / s); }
    Vec2& operator+=(const Vec2& o) { x += o.x; y += o.y; return *this; }
    Vec2& operator/=(double s) { x /= s; y /= s; return *this; }
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

// 2D Polar Decomposition: F = R * S
void polar_decomp(const Mat2& m, Mat2& R, Mat2& S) {
    double x = m.m[0][0] + m.m[1][1];
    double y = m.m[1][0] - m.m[0][1];
    double scale = 1.0 / std::sqrt(x * x + y * y);
    double c = x * scale;
    double s = y * scale;
    R = Mat2(c, -s, s, c);
    S = R.transpose() * m;
}

// 2D Singular Value Decomposition (SVD): F = U * Sig * V^T
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

// Simple linear pseudo-random generator
double rand_double() {
    static unsigned int seed = 123456789;
    seed = (1103515245 * seed + 12345) & 0x7fffffff;
    return (double)seed / 0x7fffffff;
}

int abgr_to_int(int a, int b, int g, int r) {
    return (a << 24) | (b << 16) | (g << 8) | r;
}

// ============================================================================
// Simulation Parameters & Structures
// ============================================================================
const int n = 32; // Grid resolution

const double dt     = 1e-4;
const double dx     = 1.0 / n;
const double inv_dx = 1.0 / dx;

const double particle_mass = 1.0;
const double vol           = 1.0;
const double hardening     = 10.0;

const double E             = 1e4;
const double nu            = 0.2;
const double mu_0          = E / (2.0 * (1.0 + nu));
const double lambda_0      = E * nu / ((1.0 + nu) * (1.0 - 2.0 * nu));
const bool plastic         = true;

const double gravity       = -800.;

struct Particle {
    Vec2 x, v;
    Mat2 F, C;
    double Jp;
    int c;
    
    Particle(Vec2 x, int c, Vec2 v = Vec2(0, 0)) : x(x), v(v), F(1.0), C(0.0), Jp(1.0), c(c) {}
};

struct ParticleData {
	double x;
	double y;
	uint32_t c;
	uint32_t _;
};

std::vector<Particle> particles;
Vec3 grid[n + 1][n + 1];

// ============================================================================
// Core MLS-MPM Physics Engine Step
// ============================================================================
void advance(double dt) {
    std::memset(grid, 0, sizeof(grid));

    // --- P2G: Particle to Grid ---
    for (auto &p : particles) {
        int base_x = (int)(p.x.x * inv_dx - 0.5);
        int base_y = (int)(p.x.y * inv_dx - 0.5);
        Vec2 fx = p.x * inv_dx - Vec2(base_x, base_y);

        // Quadratic B-Spline Weights
        Vec2 w[3]{
            0.5 * sqr(Vec2(1.5, 1.5) - fx),
            Vec2(0.75, 0.75) - sqr(fx - Vec2(1.0, 1.0)),
            0.5 * sqr(fx - Vec2(0.5, 0.5))
        };

        double e = std::exp(hardening * (1.0 - p.Jp));
        double mu = mu_0 * e, lambda = lambda_0 * e;
        double J = p.F.det();

        Mat2 r(1.0), s(0.0);
        polar_decomp(p.F, r, s);

        Mat2 stress = -4.0 * inv_dx * inv_dx * dt * vol * 
                      (2.0 * mu * (p.F - r) * p.F.transpose() + lambda * (J - 1.0) * J);
        Mat2 affine = stress + particle_mass * p.C;

        for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++) {
            Vec2 dpos = (Vec2(i, j) - fx) * dx;
            Vec3 mv(p.v * particle_mass, particle_mass);
            double weight = w[i].x * w[j].y;
            
            int gx = base_x + i;
            int gy = base_y + j;
            if(gx < 0 || gx > n || gy < 0 || gy > n) continue;
            grid[gx][gy] += weight * (mv + Vec3(affine * dpos, 0.0));
        }
    }

    // --- Grid Operations (Gravity & Boundary Conditions) ---
    for (int i = 0; i <= n; i++)
    for (int j = 0; j <= n; j++) {
        auto &g = grid[i][j];
        if (g.z > 0) {
            g /= g.z;                       // Convert momentum to velocity
            g += dt * Vec3(0, gravity, 0);  // Gravity

            double boundary = 0.05, x = (double)i / n, y = (double)j / n;
            if (x < boundary || x > 1 - boundary || y > 1 - boundary) g = Vec3(0, 0, 0); // Sticky
            if (y < boundary) g.y = std::max(0.0, g.y);                                  // Separate
        }
    }

    // --- G2P: Grid to Particle & Plasticity Update ---
    for (auto &p : particles) {
        int base_x = (int)(p.x.x * inv_dx - 0.5);
        int base_y = (int)(p.x.y * inv_dx - 0.5);
        Vec2 fx = p.x * inv_dx - Vec2(base_x, base_y);

        Vec2 w[3]{
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

        p.x += dt * p.v;
        Mat2 F = (Mat2(1.0) + dt * p.C) * p.F;

        Mat2 svd_u, sig, svd_v;
        svd(F, svd_u, sig, svd_v);

        if (plastic) {
            sig.m[0][0] = std::clamp(sig.m[0][0], 1.0 - 2.5e-2, 1.0 + 7.5e-3);
            sig.m[1][1] = std::clamp(sig.m[1][1], 1.0 - 2.5e-2, 1.0 + 7.5e-3);
        }

        double oldJ = F.det();
        F = svd_u * sig * svd_v.transpose();
        p.Jp = std::clamp(p.Jp * oldJ / F.det(), 0.6, 20.0);
        p.F = F;
    }
}

cfunction double grainSimTest_init() {
	particles.clear();
	return 0;
}

cfunction double grainSimTest_addObject(double x, double y, double r, double c, double amount) {
	double px = x / static_cast<double>(n);
	double py = y / static_cast<double>(n);
	double rr = r / static_cast<double>(n);
	
	py = 1. - py;
	
	int cc  = static_cast<int>(c);
	int amo = static_cast<int>(amount);
	
	for (int i = 0; i < amo; i++) {
    	double rx = rand_double() * 2. - 1.; 
    	double ry = rand_double() * 2. - 1.;
    	
    	double ppx = px + rx * rr;
    	double ppy = py + ry * rr;
    	
    	ppx = std::clamp(ppx, -1., 1.);
    	ppy = std::clamp(ppy, -1., 1.);
    	
        particles.push_back(Particle(Vec2(ppx, ppy), cc));
    }
    
	return 0;
}

cfunction double grainSimTest_step(double iteration) {
	int itr = static_cast<int>(iteration);
	for (int i = 0; i < itr; i++) 
		advance(dt);
	return 0;
}

cfunction double grainSimTest_getParticleCount() {
	return particles.size();
}

cfunction double grainSimTest_output(void* outputBuffer) {
	ParticleData* outputBufferVec = static_cast<ParticleData*>(outputBuffer);
	double nn = static_cast<double>(n);
	
	for (size_t i = 0; i < particles.size(); i++) {
		double px = particles[i].x.x;
		double py = particles[i].x.y;
		
		outputBufferVec[i].x = px        * nn;
		outputBufferVec[i].y = (1. - py) * nn;
		outputBufferVec[i].c = particles[i].c;
	}
	
	return 0;
}

*/