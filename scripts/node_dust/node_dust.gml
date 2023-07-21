function __Dust(x, y, size = 8) constructor {
	self.x = x;
	self.y = y;
	
	self.size = size;
	rad		  = size * 2;
	
	ang = 270;
	
	px = array_create(5,    x);
	py = array_create(5,    y);
	ps = array_create(5, size);
	pr = array_create(5,  rad);
	pa = array_create(5,  ang);
	
	vx =  2.8;
	vy = -0.2;
	
	av = 64;
	
	afr = 0.9;
	vfr = 0.9;
	
	static step = function() {
		for( var i = array_length(px) - 1; i >= 1; i-- ) {
			px[i] = px[i - 1];
			py[i] = py[i - 1];
			ps[i] = ps[i - 1];
			pr[i] = pr[i - 1];
			pa[i] = pa[i - 1];
		}
		
		x += vx;
		y += vy;
		
		var dist = point_distance(0, 0, vx, vy);
		var dirr = point_direction(0, 0, vx, vy);
		
		dist *= vfr;
		av   *= afr;
		ang  += av / dist;
		rad   = lerp(rad, clamp(dist * 6, 1, 8), 0.5);
		size *= 0.9;
		
		vx = lengthdir_x(dist, dirr);
		vy = lengthdir_y(dist, dirr);
		
		px[0] = x;
		py[0] = y;
		ps[0] = size;
		pr[0] = rad;
		pa[0] = ang;
	}
	
	static draw = function() {
		draw_set_color(c_grey);
		
		for( var i = 0; i < array_length(px) - 1; i++ ) {
			var dist = ceil(point_distance(px[i], py[i], px[i + 1], px[i + 1]));
			for( var j = 0; j < dist; j++ ) {
				var _x = lerp(px[i], px[i + 1], j / dist);
				var _y = lerp(py[i], py[i + 1], j / dist);
				var _s = lerp(ps[i], ps[i + 1], j / dist);
				var _r = lerp(pr[i], pr[i + 1], j / dist);
				var _a = lerp(pa[i], pa[i + 1], j / dist);
				
				var _px = _x + lengthdir_x(_r, _a);
				var _py = _y + lengthdir_y(_r, _a);
				
				if(size <= 1) draw_point(_px, _py);
				else		  draw_circle(_px, _py, _s / 2, false);
			}
			
			//draw_circle(px[i], py[i], pr[i], true);
		}
	}
}

function Node_Dust(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Dust";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output",	false], 0,
		["Solid",	false], 
	];
	
	attribute_surface_depth();
	
	dusts = [ ];
		
	static update = function() {
		var _dim = inputs[| 0].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[| 0].setValue(_outSurf);
		
		if(PROJECT.animator.current_frame == 0) {
			dusts = [ new __Dust( 0, _dim[1] / 2 ) ];
		} else {
			for( var i = 0; i < array_length(dusts); i++ ) 
				dusts[i].step();
		}
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			for( var i = 0; i < array_length(dusts); i++ ) 
				dusts[i].draw();
		surface_reset_target();
	}
}