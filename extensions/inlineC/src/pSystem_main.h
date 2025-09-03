#include <cstdint>

struct Particle {
bool active;
uint32_t flag;
int spawnIndex;

double x;
double y;
double z;

double sx;
double sy;
double sz;

double rx;
double ry;
double rz;

double life;
double lifeMax;

double  surfaceIndex;
uint8_t blendR;
uint8_t blendG;
uint8_t blendB;
uint8_t blendA;

uint8_t draw_blendR;
uint8_t draw_blendG;
uint8_t draw_blendB;
uint8_t draw_blendA;

double x_start;
double y_start;
double z_start;

double x_prev;
double y_prev;
double z_prev;

double vx;
double vy;
double vz;

double draw_x;
double draw_y;
double draw_z;

double draw_sx;
double draw_sy;
double draw_sz;

double draw_rx;
double draw_ry;
double draw_rz;
};
