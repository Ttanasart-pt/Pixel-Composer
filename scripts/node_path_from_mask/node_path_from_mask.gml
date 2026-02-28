function Node_Path_From_Mask(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path from Mask";
	
	newInput(0, nodeValue_Surface("Mask"));
	
	newInput(2, nodeValue_Bool("Smooth",   false));
	newInput(1, nodeValue_Float("Smoothness", 2));
		
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	input_display_list = [ 0, 
		["Smooth", false, 2], 1, 
	];
	
	////- Nodes
	
	temp_surface = [ noone ];
	
	anchors     = [];
	lengthTotal = 0;
	lengths     = [];
	lengthAccs  = [];
	boundary    = new BoundingBox();
	loop		= true;
	cached_pos  = ds_map_create();
	
	attributes.maximum_dim    = 64;
	attributes.maximum_points = 4096;
	array_push(attributeEditors, Node_Attribute("Max Points", function() /*=>*/ {return attributes.maximum_points}, 
		function() /*=>*/ {return textBox_Number(function(v) /*=>*/ {return setAttribute("maximum_points", clamp(v, 8, 10000))})}));
	
	static getBoundary		= function() /*=>*/ {return boundary};
	static getAccuLength	= function() /*=>*/ {return lengthAccs};
	static getLength		= function() /*=>*/ {return lengthTotal};
	static getSegmentCount  = function() /*=>*/ {return 1};
	static getLineCount     = function() /*=>*/ {return 1};
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		if(array_empty(anchors)) return out;
		
		var _cKey = $"{string_format(_dist, 0, 6)},{_ind}";
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			out.weight = _p.weight;
			return out;
		}
		
		var _aid = 0;
		var _dst = _dist;
		
		for( var i = 0, n = array_length(lengthAccs); i < n; i++ ) {
			if(_dist == lengthAccs[i]) {
				out.x = anchors[i + 1][0];
				out.y = anchors[i + 1][1];
				return out;
			}
				
			if(_dist < lengthAccs[i]) {
				_aid = i;
				if(i) _dst = _dist - lengthAccs[i - 1];
				break;
			}
		}
		
		var _ll  = array_length(anchors);
		var _a0  = anchors[ (i  ) % _ll ];
		var _a1  = anchors[ (i+1) % _ll ];
		var _rat = _dst / lengths[_aid];
		
		out.x = lerp(_a0[0], _a1[0], _rat);
		out.y = lerp(_a0[1], _a1[1], _rat);
		
		cached_pos[? _cKey] = new __vec2P(out.x, out.y, out.weight);
		
		return out;
	}
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) { return getPointDistance(frac(_rat) * lengthTotal, _ind, out); }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
		draw_set_color(COLORS._main_accent);
		var ox, oy, nx, ny, sx, sy;
		
		for( var i = 0, n = array_length(anchors); i < n; i++ ) {
			nx = _x + anchors[i][0] * _s;
			ny = _y + anchors[i][1] * _s;
			
			if(i) draw_line(ox, oy, nx, ny);
			else {
				sx = nx;
				sy = ny;
			}
			
			draw_circle(nx, ny, 3, false);
			
			ox = nx;
			oy = ny;
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		ds_map_clear(cached_pos);
		var _surf = getInputData(0);
		
		var _smt   = getInputData(2);
		var _smtEp = getInputData(1);
		
		anchors = [];
		if(!is_surface(_surf)) return;
		
		var _dim = surface_get_dimension(_surf);
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
		
		surface_set_shader(temp_surface[0], sh_image_trace);
			shader_set_f("dimension", _dim);
			draw_surface_stretched(_surf, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		var _amo  = attributes.maximum_points;
		var _sbuf = buffer_from_surface(temp_surface[0], false);
		var _obuf = buffer_create(_amo * 2 * 4, buffer_fixed, 4);
		var _args = buffer_create(1, buffer_grow, 1);
		buffer_to_start(_args);
		
		buffer_write(_args, buffer_u64, buffer_get_address(_sbuf));
		buffer_write(_args, buffer_u64, buffer_get_address(_obuf));
		
		buffer_write(_args, buffer_u16, _dim[0]);
		buffer_write(_args, buffer_u16, _dim[1]);
		buffer_write(_args, buffer_u16, _amo);
		
		buffer_write(_args, buffer_bool, bool(_smt));
		buffer_write(_args, buffer_bool, 0);
		buffer_write(_args, buffer_f64,  _smtEp);
		
		var _ancAmo = path_from_mask(buffer_get_address(_args));
		
		var ox, oy, nx, ny;
		var _lind = 0;
		
		lengthTotal = 0;
		lengths     = array_verify(lengths,    _ancAmo - 1);
		lengthAccs  = array_verify(lengthAccs, _ancAmo - 1);
		boundary    = new BoundingBox();
		
		buffer_to_start(_obuf);
		for( var i = 0; i < _ancAmo; i++ ) {
			nx = buffer_read(_obuf, buffer_u16) + .5;
			ny = buffer_read(_obuf, buffer_u16) + .5;
			
			anchors[i][0] = nx;
			anchors[i][1] = ny;
			
			boundary.addPoint(nx, ny);
			
			if(i) {
				var ds = point_distance(ox, oy, nx, ny);
				
				lengthTotal      += ds;
				lengths[_lind]    = ds;
				lengthAccs[_lind] = lengthTotal;
				_lind++;
			}
			
			ox = nx;
			oy = ny;
		}
		
		buffer_delete(_sbuf);
		buffer_delete(_obuf);
		
	}
	
	static getGraphPreviewSurface = function() /*=>*/ {return getInputData(0)};
	static getPreviewValues       = function() /*=>*/ {return getInputData(0)};
}

/*[cpp]
#include <iostream>
#include <cstdint>
#include <vector>
#include <cmath>

struct pixel {
	uint8_t r;
	uint8_t g;
	uint8_t b;
	uint8_t a;
};

struct pathFromMaskArgs {
	void* pixelArrayBuffer;
	void* outputBuffer;

	uint16_t surfaceWidth;
	uint16_t surfaceHeight;
	uint16_t maxOutput;

	bool   useSmooth;
	double smoothEpsilon;
};

struct vec2 {
	int32_t x;
	int32_t y;
};

uint16_t iabs(int16_t value) { return value < 0 ? -value : value; }

double perpendicularDistance(const vec2& a, const vec2& b, const vec2& c) {
	double ax = static_cast<double>(a.x);
	double ay = static_cast<double>(a.y);
	double bx = static_cast<double>(b.x);
	double by = static_cast<double>(b.y);
	double cx = static_cast<double>(c.x);
	double cy = static_cast<double>(c.y);

	double dx = bx - ax;
	double dy = by - ay;
	double lengthSquared = dx * dx + dy * dy;
	if (lengthSquared == 0) return sqrt(((cx - ax) * (cx - ax) + (cy - ay) * (cy - ay)));
	
	double t = ((cx - ax) * dx + (cy - ay) * dy) / lengthSquared;
	
	if (t < 0) return sqrt(((cx - ax) * (cx - ax) + (cy - ay) * (cy - ay)));
	if (t > 1) return sqrt(((cx - bx) * (cx - bx) + (cy - by) * (cy - by)));

	double projX = ax + t * dx;
	double projY = ay + t * dy;

	return static_cast<double>((cx - projX) * (cx - projX) + (cy - projY) * (cy - projY));
}

std::vector<vec2> douglasPeucker(const std::vector<vec2>& points, double epsilon) {
	if (points.size() < 3) return points;
	
	double maxDist    = 0.0;
	size_t index      = 0;
	vec2   pointFront = points.front();
	vec2   pointBack  = points.back();

	for (size_t i = 1; i < points.size() - 1; i++) {
		double dist = perpendicularDistance(pointFront, pointBack, points[i]);
		if (dist > maxDist) {
			maxDist = dist;
			index   = i;
		}
	}

	if (maxDist > epsilon) {
		std::vector<vec2> left(points.begin(), points.begin() + index + 1);
		std::vector<vec2> right(points.begin() + index, points.end());

		auto leftResult  = douglasPeucker(left,  epsilon);
		auto rightResult = douglasPeucker(right, epsilon);

		leftResult.pop_back();
		leftResult.insert(leftResult.end(), rightResult.begin(), rightResult.end());
		return leftResult;
	}
	
	return { pointFront, pointBack };
}

cfunction double path_from_mask(void* args) {
	pathFromMaskArgs* pArgs = (pathFromMaskArgs*)args;

	pixel*   pixels = (pixel*)pArgs->pixelArrayBuffer;
	uint16_t width  = pArgs->surfaceWidth;
	uint16_t height = pArgs->surfaceHeight;

	vec2*    output      = (vec2*)pArgs->outputBuffer;
	vec2*    outputStart = output;
	uint16_t maxOutput   = pArgs->maxOutput;

	uint16_t x = -1;
	uint16_t y = -1;

	for (uint16_t i = 0, n = width * height; i < n; i++) {
		if (pixels[i].a > 0) {
			x = i % width;
			y = i / width;
			break;
		}
	}

	if (x == -1 || y == -1 || x >= width || y >= height) return 0.0; // Empty mask

	vec2 directions[8] = {{1, 0}, {1, -1}, {0, -1}, {-1, -1}, {-1, 0}, {-1, 1}, {0, 1}, {1, 1}};
	uint16_t dir = 3;
	uint16_t pointCount = 0;
	
	bool firstPoint = true;
	uint16_t sx = x;
	uint16_t sy = y;
	maxOutput--;

	pixels[y * width + x].a = 0;
	while (pointCount++ < maxOutput) {
		output->x = x;
		output->y = y;
		output++;

		bool found = false;
		uint16_t startDir = (dir + 7 - (dir % 2)) % 8;
		for (uint16_t i = 0; i < 8; i++) {
			uint16_t checkDir = (startDir + i) % 8;
			uint16_t newX = x + directions[checkDir].x;
			uint16_t newY = y + directions[checkDir].y;
			if (newX >= 0 && newY >= 0 && newX < width && newY < height && pixels[newY * width + newX].a > 0) {
				if (!firstPoint && dir == checkDir) { // Remove the last point if we are still in the same direction
					output--;
					pointCount--;
				}

				x     = newX;
				y     = newY;
				dir   = checkDir;
				found = true;

				pixels[newY * width + newX].a = 0; // Mark as visited
				break;
			}
		}

		firstPoint = false;
		if (!found) break;
	}
	
	if(!pArgs->useSmooth) {
		output->x = sx;
		output->y = sy;

		return static_cast<double>(pointCount + 1);
	}

	std::vector<vec2> points;
	for (uint16_t i = 0; i < pointCount; i++)
		points.push_back(outputStart[i]);
	
	std::vector<vec2> simplified = douglasPeucker(points, pArgs->smoothEpsilon);
	size_t simplifiedSize = simplified.size();

	for (size_t i = 0; i < simplifiedSize - 1; i++) {
		outputStart[i].x = simplified[i].x;
		outputStart[i].y = simplified[i].y;
	}

	outputStart[simplifiedSize - 1].x = sx;
	outputStart[simplifiedSize - 1].y = sy;

	return static_cast<double>(simplifiedSize);
}

*/