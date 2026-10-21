function Node_Path_Pathfind(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Pathfinding";
	
	newInput( 0, nodeValue_Surface( "Mask" ));
	
	////- =Pathfinding
	newInput( 1, nodeValue_Vec2( "Start",    [0,0] )).setUnitSimple();
	newInput( 2, nodeValue_Vec2( "End",      [1,1] )).setUnitSimple();
	newInput( 3, nodeValue_Bool( "Diagonal", false ));
	
	////- =Path
	newInput( 4, nodeValue_Bool( "Simplify",  true ));
	
	////- =Rendering
	
		////- =/Mask
	newInput( 7, nodeValue_Bool(     "Draw Mask",   true     ));
	
		////- =/Path
	newInput( 5, nodeValue_Bool(     "Draw Path",  false     ));
	newInput( 8, nodeValue_SliRange( "Range",      [0,1]     ));
	newInput( 6, nodeValue_Gradient( "Color",      gra_white ));
	// 9
		
	newOutput( 0, nodeValue_Output( "Rendered", VALUE_TYPE.surface,   noone ));
	newOutput( 1, nodeValue_Output( "Path",     VALUE_TYPE.pathnode,  self  ));
	newOutput( 2, nodeValue_Output( "Reached",  VALUE_TYPE.boolean,   false ));
	
	input_display_list = [ 
		[ "Surfaces",    false ],  0, 
		[ "Pathfinding", false ],  1,  2,  3, 
		[ "Path",        false ],  4, 
		[ "Rendering",   false ],  
			[ "/Mask",   false ],  7,  
			[ "/Path",   false ],  5,  8,  6, 
	];
	
	////- Path
	
	anchors     = [];
	lengthTotal = 0;
	lengths     = [];
	lengthAccs  = [];
	boundary    = new BoundingBox();
	loop		= true;
	cached_pos  = ds_map_create();
	
	attributes.maximum_points = 4096;
	array_push(attributeEditors, Node_Attribute("Max Points", function() /*=>*/ {return attributes.maximum_points}, 
		function() /*=>*/ {return textBox_Number(function(v) /*=>*/ {return setAttribute("maximum_points", clamp(v, 8, 10000))})}));
	
	static getBoundary		= function() /*=>*/ {return boundary};
	static getAccuLength	= function() /*=>*/ {return lengthAccs};
	static getLength		= function() /*=>*/ {return lengthTotal};
	static getSegmentCount  = function() /*=>*/ {return 1};
	static getLineCount     = function() /*=>*/ {return 1};
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) {
		if(out == undefined) out = new PathPoint(); else out.reset();
		if(array_empty(anchors)) return out;
		
		var _cKey = $"{string_format(_dist, 0, 6)},{_ind}";
		if(ds_map_exists(cached_pos, _cKey))
			return out.apply(cached_pos[? _cKey]);
		
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
		
		cached_pos[? _cKey] = out.clone();
		
		return out;
	}
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) { return getPointDistance(frac(_rat) * lengthTotal, _ind, out); }
	
	////- Nodes
	
	temp_surface = [ noone, noone ];
	
	bOutput = undefined;
	bMask   = undefined;
	bDraw   = undefined;
	
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
			
			draw_circle(nx, ny, ui(3), false);
			
			ox = nx;
			oy = ny;
		}
		
		drawOverlayInput(inputs[ 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, 1));
		drawOverlayInput(inputs[ 2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, 1));
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			ds_map_clear(cached_pos);
			var _surf = getInputData( 0);
			
			var _psta = getInputData( 1);
			var _pend = getInputData( 2);
			var _diag = getInputData( 3);
			
			var _simp = getInputData( 4);
			
			var _dmsk = getInputData( 7);
			
			var _dpth = getInputData( 5);
			var _drng = getInputData( 8);
			var _grad = getInputData( 6);
			
			anchors = [];
			if(!is_surface(_surf)) return;
		#endregion
		
		var _dim = surface_get_dimension(_surf);
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], surface_r32float);
		temp_surface[1] = surface_verify(temp_surface[1], _dim[0], _dim[1], surface_r32float);
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[0].setValue(_outSurf);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE
			if(_dmsk) draw_surface(_surf, 0, 0);
		surface_reset_target();
			
		surface_set_shader(temp_surface[0], sh_path_pathfind_mask);
			draw_surface_stretched(_surf, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		////- =Pathfind
		
		var _amo = attributes.maximum_points;
		bOutput  = buffer_verify( bOutput, _amo * 2 * 4,          buffer_fixed, 4 );
		bMask    = buffer_verify( bMask,   _dim[0] * _dim[1] * 4, buffer_grow,  1 );
		bDraw    = buffer_verify( bDraw,   _dim[0] * _dim[1] * 4, buffer_grow,  1 );
		
		buffer_get_surface(bMask, temp_surface[0], 0);
		
		pathfinding_set_output(buffer_get_address(bOutput));
		pathfinding_set_wall(buffer_get_address(bMask));
		pathfinding_set_draw(buffer_get_address(bDraw));
		
		pathfinding_set_dimension(_dim[0], _dim[1]);
		pathfinding_set_diagonal(_diag);
		pathfinding_set_simplify(_simp);

		var _ancAmo = pathfinding(_psta[0], _psta[1], _pend[0], _pend[1]);
		if(_ancAmo < 0) {
			outputs[2].setValue(false);
			return;
		}
		
		var ox, oy, nx, ny;
		var _lind = 0;
		
		lengthTotal = 0;
		lengths     = array_verify(lengths,    _ancAmo - 1);
		lengthAccs  = array_verify(lengthAccs, _ancAmo - 1);
		boundary    = new BoundingBox();
		
		buffer_to_start(bOutput);
		for( var i = 0; i < _ancAmo; i++ ) {
			nx = buffer_read(bOutput, buffer_u16) + .5;
			ny = buffer_read(bOutput, buffer_u16) + .5;
			
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
		
		outputs[2].setValue(true);
		
		////- =Render
		
		if(_dpth) {
			var dLen = pathfinding_get_draw_length();
			
			buffer_set_surface(bDraw, temp_surface[1], 0);
			surface_set_shader(_outSurf, sh_path_pathfile_draw, false);
				shader_set_f( "pathLength",  dLen );
				shader_set_2( "pathRange",  _drng );
				shader_set_gradient( _grad );
				
				draw_surface(temp_surface[1], 0, 0);
			surface_reset_shader();
		}
		
	}
	
}

/*[cpp]
#include <cstdint>
#include <vector>
#include <cmath>
#include <cstring>   // for memset
#include <algorithm> // for reverse

struct pixel {
	uint8_t r;
	uint8_t g;
	uint8_t b;
	uint8_t a;
};

struct vec2 {
	int32_t x;
	int32_t y;
};

int    surface_w, surface_h;
float* f;
float* g;
int*   successors;
int*   closed;
int    diagonal;
int    simplify;
int    reached;

float* mask;
vec2*  output;
float* draw;
float  drawLength;

float maskStart;
float maskEnd;

std::vector<int> open_list;
std::vector<int> path_list;

int   getIndex(int x, int y) { return y * surface_w + x; }
vec2  getVec2(int index)     { return {index % surface_w, index / surface_w}; }
float getWall(int x, int y)  { return mask[getIndex(x, y)]; }

int getSuccessor(int index, int* succ, float* dist) {
	vec2 v = getVec2(index);
	int  x = v.x;
	int  y = v.y;
	int  count = 0;

	int  w = surface_w;
	int  h = surface_h;

	if(x > 0)   { succ[count] = getIndex(x - 1, y); dist[count++] = 1.0f; }
	if(x < w-1) { succ[count] = getIndex(x + 1, y); dist[count++] = 1.0f; }
	if(y > 0)   { succ[count] = getIndex(x, y - 1); dist[count++] = 1.0f; }
	if(y < h-1) { succ[count] = getIndex(x, y + 1); dist[count++] = 1.0f; }

	if(diagonal) {
		if(x > 0   && y > 0)   { succ[count] = getIndex(x - 1, y - 1); dist[count++] = 1.4142f; }
		if(x < w-1 && y > 0)   { succ[count] = getIndex(x + 1, y - 1); dist[count++] = 1.4142f; }
		if(x > 0   && y < h-1) { succ[count] = getIndex(x - 1, y + 1); dist[count++] = 1.4142f; }
		if(x < w-1 && y < h-1) { succ[count] = getIndex(x + 1, y + 1); dist[count++] = 1.4142f; }
	}

	return count;
}

cfunction double pathfinding_set_wall(   void* _p)  { mask     = (float*)_p; return 0.; }
cfunction double pathfinding_set_output( void* _o)  { output   = (vec2*)_o;  return 0.; }
cfunction double pathfinding_set_draw(   void* _d)  { draw     = (float*)_d; return 0.; }
cfunction double pathfinding_set_diagonal(double d) { diagonal = (int)d;     return 0.; }
cfunction double pathfinding_set_simplify(double s) { simplify = (int)s;     return 0.; }

cfunction double pathfinding_set_dimension(double sw, double sh) { 
	surface_w = (int)sw;
	surface_h = (int)sh;
	return 0.; 
}

cfunction double pathfinding_get_draw_length() { return drawLength; }
cfunction double pathfinding_get_reached()     { return reached;    }

cfunction double pathfinding(double startx, double starty, double endx, double endy) {
	int pixels = surface_w * surface_h;
	int startIndex = getIndex((int)startx, (int)starty);
	int endIndex   = getIndex((int)endx, (int)endy);

	maskStart = getWall((int)startx, (int)starty);
	maskEnd   = getWall((int)endx,   (int)endy);
	if(maskStart != maskEnd) return -2;

	int   succ[8];
	float dist[8];

	f          = new float[pixels];
	g          = new float[pixels];
	successors = new int[pixels];
	closed     = new int[pixels];

	memset(f,          0, sizeof(float) * pixels);
	memset(g,          0, sizeof(float) * pixels);
	memset(successors, 0, sizeof(int)   * pixels);
	memset(closed,     0, sizeof(int)   * pixels);
	memset(output,     0, sizeof(vec2)  * pixels);
	memset(draw,       0, sizeof(float) * pixels);

	open_list.clear();
	path_list.clear();
	open_list.push_back(startIndex);

	int reach = 0;

	while(!open_list.empty()) {
		int minW     = 99999;
		int minIndex = -1;
		int minPos   = -1;

		for(int i = 0; i < open_list.size(); i++) {
			int index = open_list[i];
			if(f[index] < minW) {
				minW     = f[index];
				minIndex = index;
				minPos   = i;
			}
		}

		if(minIndex == -1)       break;
		if(minIndex == endIndex) { reach = 1; break; }
		
		open_list.erase(open_list.begin() + minPos);
		int succCount = getSuccessor(minIndex, succ, dist);
		for(int i = 0; i < succCount; i++) {
			int s = succ[i];
			if(mask[s] != maskStart || closed[s]) continue;
			
			vec2  suc2 = getVec2(s);
			float gNew = g[minIndex] + dist[i];
			float h    = std::abs((double)suc2.x - endx) + std::abs((double)suc2.y - endy);
			float fNew = gNew + h;

			if(fNew < f[s] || f[s] == 0) {
				f[s] = fNew;
				g[s] = gNew;
				successors[s] = minIndex;

				open_list.push_back(s);
			}
			
			if(s == endIndex) { reach = 1; break; }
		}

		closed[minIndex] = 1;
		if(reach) break;
	}

	reached = reach;
	if(reach == 0) return -1;

	// path
	drawLength = 1;
	int current = endIndex;

	while(current != startIndex) {
		draw[current] = drawLength;
		drawLength += 1.0;

		path_list.push_back(current);
		current = successors[current];
	}

	path_list.push_back(startIndex);
	std::reverse(path_list.begin(), path_list.end());

	int length = 0;

	if(simplify) {
		vec2 prev = getVec2(path_list[0]);
		int  dirr = -1;
		int  size = path_list.size();

		output[length] = prev;
		length++;

		for(int i = 1; i < size; i++) {
			vec2 curr = getVec2(path_list[i]);
			int newDir = (curr.x - prev.x) + (curr.y - prev.y) * surface_w;

			if(newDir != dirr) {
				output[length] = prev;
				dirr = newDir;
				length++;
			}

			if(i == size - 1) {
				output[length] = curr;
				length++;
			}

			prev = curr;
		}

	} else {	
		for(int i = 0; i < path_list.size(); i++) {
			int index = path_list[i];
			output[i] = getVec2(index);
			length++;
		}
	}

	return length;
}

*/