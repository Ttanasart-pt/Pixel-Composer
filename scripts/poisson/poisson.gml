/*[cpp]
#include <vector>
#include <cstdlib>
#include <cmath>

using namespace std;

struct args {
	void* _output;

	double x;
	double y;
	double width;
	double height;
	double type;

	double distance;
	double seed;

	double max_points;
};

struct Point {
	double x;
	double y;
};

double random_range(double min, double max) { return min + (rand() / (RAND_MAX / (max - min))); }

cfunction double poisson_get_points(void* _args) {
	args* area = (args*)_args;

	double x0 = area->x - area->width;
	double y0 = area->y - area->height;
	double x1 = area->x + area->width;
	double y1 = area->y + area->height;
	double ww = x1 - x0;
	double hh = y1 - y0;

	double _distance   = area->distance;
	double _seed       = area->seed;
	double _max_points = area->max_points;

	double cs = floor(_distance / sqrt(2));

	int cell_nw = ceil(ww / cs) + 1;
	int cell_nh = ceil(hh / cs) + 1;

	vector<int> grid(cell_nw * cell_nh, -1);
	vector<Point> points;
	vector<Point> active;

	srand((unsigned int)_seed);

	int i = 0;
	Point _p = { random_range(x0, x1), random_range(y0, y1) };

	int cell_x = floor((_p.x - x0) / cs);
	int cell_y = floor((_p.y - y0) / cs);
	int cell = cell_x + (cell_y * cell_nw);

	points.emplace_back(_p);
	active.emplace_back(_p);
	grid[cell] = i++;

	while (!active.empty()) {
		int j = rand() % active.size();
		Point p = active[j];
		bool found = false;

		for (int k = 0; k < 32; ++k) {
			double _dir = random_range(0, 360);
			double _rad = random_range(_distance, _distance * 2);
			double _px = p.x + cos(_dir) * _rad;
			double _py = p.y + sin(_dir) * _rad;
			if (_px < x0 || _px > x1 || _py < y0 || _py > y1) continue;

			int cell_x = floor((_px - x0) / cs);
			int cell_y = floor((_py - y0) / cs);
			int cell = cell_x + (cell_y * cell_nw);
			if (grid[cell] != -1) continue;

			bool cull = false;
			for (int k = -1; k <= 1; ++k)
			for (int l = -1; l <= 1; ++l) {
				int _cell_x = cell_x + k;
				int _cell_y = cell_y + l;
				if (_cell_x < 0 || _cell_x >= cell_nw) continue;
				if (_cell_y < 0 || _cell_y >= cell_nh) continue;
				int _cell = _cell_x + (_cell_y * cell_nw);
				if (grid[_cell] != -1) {
					Point p2 = points[grid[_cell]];
					if (sqrt(pow(_px - p2.x, 2) + pow(_py - p2.y, 2)) < _distance)
						cull = true;
				}
			}

			if (cull) continue;

			Point new_point = { _px, _py };
			points.emplace_back(new_point);
			active.emplace_back(new_point);
			grid[cell] = i++;
			found = true;
			break;
		}

		if (!found)
			active.erase(active.begin() + j);
	}

	if (area->type == 1) {
		for (int i = points.size() - 1; i >= 0; --i) {
			Point p = points[i];
			double px = p.x;
			double py = p.y;

			double _dir = atan2(py - area->y, px - area->x);
			double _epx = area->x + cos(_dir) * area->width;
			double _epy = area->y + sin(_dir) * area->height;

			if (pow(area->x - px, 2) + pow(area->y - py, 2) > pow(area->x - _epx, 2) + pow(area->y - _epy, 2))
				points.erase(points.begin() + i);
		}
	}

	double* _output = (double*)area->_output;
	size_t writtable_size = min(points.size(), (size_t)area->max_points);

	for (size_t i = 0; i < writtable_size; ++i) {
		int indx = (int)i * 2;

		((double*)_output)[indx + 0] = points[i].x;
		((double*)_output)[indx + 1] = points[i].y;
	}

	return writtable_size;
}