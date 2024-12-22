function Node_Path_Shape(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Shape";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Vec2("Position", self, [ .5, .5 ]))
		.setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	newInput(1, nodeValue_Vec2("Half Size", self, [ .5, .5 ]))
		.setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	newInput(2, nodeValue_Rotation("Rotation", self, 0));
	
	shapeScroll = [ 
	    new scrollItem("Rectangle",     s_node_shape_type,  0), 
	    new scrollItem("Trapezoid",     s_node_shape_type,  2), 
	    new scrollItem("Parallelogram", s_node_shape_type,  3), 
	    -1,
	    new scrollItem("Ellipse",       s_node_shape_type,  5), 
	    new scrollItem("Arc",           s_node_shape_type,  6), 
	    new scrollItem("Squircle",      s_node_shape_type, 11), 
	    -1,
	    new scrollItem("Polygon",       s_node_shape_type, 12), 
	    new scrollItem("Star",          s_node_shape_type, 13), 
    ];
	newInput(3, nodeValue_Enum_Scroll("Shape", self, 0, shapeScroll));
	
	newInput(4, nodeValue_Float("Skew", self, .5))
	    .setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01] });
	
	newInput(5, nodeValue_Rotation_Range("Angle Range", self, [ 0, 90 ]));
	
	newInput(6, nodeValue_Float("Factor", self, 4));
	
	newInput(7, nodeValue_Int("Sides", self, 4));
	
	newInput(8, nodeValue_Float("Inner Radius", self, .5));
	
	newOutput(0, nodeValue_Output("Path data", self, VALUE_TYPE.pathnode, self));
		
	input_display_list = [
		["Transform", false], 0, 2, 1, 
		["Shape",     false], 3, 4, 5, 6, 7, 8, 
	];
	
	points      = [];
	lengths		= [];
	lengthAccs	= [];
	lengthTotal	= 0;
	boundary    = new BoundingBox();
	cached_pos  = ds_map_create();
	
	shape = 0;
	posx  = 0; posy  = 0;
	scax  = 1; scay  = 1;
	rot   = 0;
	
	pa1   = 0;
	pa2x  = 0; pa2y  = 0;
	pa3   = 0;
	
	static getLineCount		= function() /*=>*/ {return 1};
	static getSegmentCount	= function() /*=>*/ {return array_length(lengths)};
	static getBoundary		= function() /*=>*/ {return boundary};
	static getLength		= function() /*=>*/ {return lengthTotal};
	static getAccuLength	= function() /*=>*/ {return lengthAccs};
	
	static getPointRatio    = function(_rat, _ind = 0, out = undefined) { 
	    if(out == undefined) out = new __vec2();
	    _rat = frac(_rat);
	    
		switch(shapeScroll[shape].name) {
            case "Rectangle" : 
            case "Trapezoid" : 
            case "Parallelogram" : 
                if(_rat <= .25) {
                    var r = _rat * 4;
                    out.x = lerp(points[0][0], points[1][0], r);
                    out.y = lerp(points[0][1], points[1][1], r);
                } else if(_rat <= .50) {
                    var r = (_rat - .25) * 4;
                    out.x = lerp(points[1][0], points[2][0], r);
                    out.y = lerp(points[1][1], points[2][1], r);
                } else if(_rat <= .75) {
                    var r = (_rat - .50) * 4;
                    out.x = lerp(points[2][0], points[3][0], r);
                    out.y = lerp(points[2][1], points[3][1], r);
                } else {
                    var r = (_rat - .75) * 4;
                    out.x = lerp(points[3][0], points[0][0], r);
                    out.y = lerp(points[3][1], points[0][1], r);
                }
                break;
                
            case "Ellipse" : 
                var a = 360 * _rat;
                out.x = posx + lengthdir_x(scax, a);
                out.y = posy + lengthdir_y(scay, a);
                break;
                
            case "Arc" : 
                var a = lerp_angle(pa2x, pa2y, _rat);
                out.x = posx + lengthdir_x(scax, a);
                out.y = posy + lengthdir_y(scay, a);
                break;
                
            case "Squircle" : 
                var a = 360 * _rat;
                var r = 1 / power(power(dcos(a % 90), pa3) + power(dsin(a % 90), pa3), 1 / pa3);
                    
                out.x = posx + lengthdir_x(scax * r, a);
                out.y = posy + lengthdir_y(scay * r, a);
                break;
                
            case "Polygon" : 
            case "Star"    : return getPointDistance(_rat * lengthTotal, _ind, out);
                
        }
        
        point_vec2_rotate(out, posx, posy, rot);
        return out;
	}
	    
	static getPointDistance = function(_dist, _ind = 0, out = undefined) {
	    if(out == undefined) out = new __vec2();
	    _dist = safe_mod(_dist, lengthTotal);
	    
	    var _d = _dist, l;
	    var np = array_length(points);
	    
	    for( var i = 0, n = array_length(lengths); i < n; i++ ) {
	        l = lengths[i];
	        if(_d > l) { _d -= l; continue; }
	        
            var p0 = points[(i + 0) % np];
            var p1 = points[(i + 1) % np];
            
            out.x = lerp(p0[0], p1[0], _d / l);
            out.y = lerp(p0[1], p1[1], _d / l);
            break;
	    }
	    
        point_vec2_rotate(out, posx, posy, rot);
        return out;
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
	    if(array_empty(points)) return;
	    
	    var ox = _x + points[0][0] * _s, x0 = ox;
	    var oy = _y + points[0][1] * _s, y0 = oy;
	    var nx, ny;
	    
	    draw_set_color(COLORS._main_accent);
	    for( var i = 1, n = array_length(points); i < n; i++ ) {
	        nx = _x + points[i][0] * _s;
	        ny = _y + points[i][1] * _s;
	        
            draw_line(ox, oy, nx, ny);
	        
	        ox = nx;
	        oy = ny;
	    }
	    
	    draw_line(ox, oy, x0, y0);
	    
	    var _px = _x + posx * _s;
	    var _py = _y + posy * _s;
	    
	    var h = inputs[0].drawOverlay(hover, active,  _x,  _y, _s, _mx, _my, _snx, _sny); hover &= !h;
	    var h = inputs[2].drawOverlay(hover, active, _px, _py, _s, _mx, _my, _snx, _sny); hover &= !h;
	    var h = inputs[1].drawOverlay(hover, active, _px, _py, _s, _mx, _my, _snx, _sny); hover &= !h;
	    
	}
	
	static update = function(frame = CURRENT_FRAME) {
        var _pos  = inputs[0].getValue();
        var _rot  = inputs[2].getValue();
        var _sca  = inputs[1].getValue();
        var _pa1  = inputs[4].getValue();
        var _aran = inputs[5].getValue();
        var _pa3  = inputs[6].getValue();
        var _sid  = inputs[7].getValue();
        var _inn  = inputs[8].getValue();
        
	    shape = inputs[3].getValue();
	    posx  = _pos[0];
        posy  = _pos[1];
        rot   = _rot;
        scax  = _sca[0];
        scay  = _sca[1];
        
        pa1   = _pa1;
        pa2x  = _aran[0];
        pa2y  = _aran[1];
        pa3   = _pa3;
        
        var ox, oy, nx, ny, x0, y0;
        
        inputs[4].setVisible(false);
        inputs[5].setVisible(false);
        inputs[6].setVisible(false);
        inputs[7].setVisible(false);
        inputs[8].setVisible(false);
                
        switch(shapeScroll[shape].name) {
            case "Rectangle" : 
                points  = [ 
                    [ posx - scax, posy - scay ],
                    [ posx + scax, posy - scay ],
                    [ posx + scax, posy + scay ],
                    [ posx - scax, posy + scay ],
                ];
                break;
                
            case "Trapezoid" : 
                inputs[4].setVisible(true);
                
                points  = [ 
                    [ posx - scax * saturate(1 - _pa1), posy - scay ],
                    [ posx + scax * saturate(1 - _pa1), posy - scay ],
                    [ posx + scax * saturate(1 + _pa1), posy + scay ],
                    [ posx - scax * saturate(1 + _pa1), posy + scay ],
                ];
                break;
                
            case "Parallelogram" : 
                inputs[4].setVisible(true);
                
                points  = [ 
                    [ posx - scax * saturate(1 - _pa1), posy - scay ],
                    [ posx + scax * saturate(1 + _pa1), posy - scay ],
                    [ posx + scax * saturate(1 - _pa1), posy + scay ],
                    [ posx - scax * saturate(1 + _pa1), posy + scay ],
                ];
                break;
            
            case "Ellipse" : 
                var _st = 64;
                var _as = 360 / _st;
                points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    nx = posx + lengthdir_x(scax, _as * i);
                    ny = posy + lengthdir_y(scay, _as * i);
                    points[i] = [ nx, ny ];
                }
                break;
                
            case "Arc" : 
                inputs[5].setVisible(true);
                
                var _st = 64;
                var _as = 1 / (_st - 63);
                points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    var a = lerp_angle(_aran[0], _aran[1], i * _as);
                    nx = posx + lengthdir_x(scax, a);
                    ny = posy + lengthdir_y(scay, a);
                    points[i] = [ nx, ny ];
                }
                break;
                
            case "Squircle" :
                inputs[6].setVisible(true);
                
                var _st = 64;
                var _as = 360 / _st;
                points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    var a = _as * i;
                    var r = 1 / power(power(dcos(a % 90), pa3) + power(dsin(a % 90), pa3), 1 / pa3);
                    
                    nx = posx + lengthdir_x(scax * r, a);
                    ny = posy + lengthdir_y(scay * r, a);
                    points[i] = [ nx, ny ];
                }
                break;
                
            case "Polygon" :
                inputs[7].setVisible(true);
                
                var _st = _sid;
                var _as = 360 / _st;
                points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    nx = posx + lengthdir_x(scax, _as * i);
                    ny = posy + lengthdir_y(scay, _as * i);
                    points[i] = [ nx, ny ];
                }
                break;
                
            case "Star" :
                inputs[7].setVisible(true);
                inputs[8].setVisible(true);
                
                var _st = _sid;
                var _as = 360 / _st;
                points  = array_create(_st * 2);
                
                for( var i = 0; i < _st; i++ ) {
                    nx = posx + lengthdir_x(scax, _as * i);
                    ny = posy + lengthdir_y(scay, _as * i);
                    points[i * 2 + 0] = [ nx, ny ];
                    
                    nx = posx + lengthdir_x(scax * _inn, _as * i + _as / 2);
                    ny = posy + lengthdir_y(scay * _inn, _as * i + _as / 2);
                    points[i * 2 + 1] = [ nx, ny ];
                }
                break;
                
        }

        var n   = array_length(points);
        lengths = array_create(n + 1);
        
        if(n) {
            for( var i = 0; i < n; i++ ) {
                nx = points[i][0];
                ny = points[i][1];
                
                if(i) lengths[i - 1] = point_distance(ox, oy, nx, ny);
                else { x0 = nx; y0 = ny; }
                
                ox = nx;
                oy = ny;
            }
            
            lengths[n - 1] = point_distance(ox, oy, x0, y0);
        }
        
        var _len    = array_length(lengths);
    	lengthTotal = 0;
    	lengthAccs  = array_create(_len);
    	
    	for( var i = 0; i < _len; i++ ) {
    	    lengthTotal  += lengths[i];
    	    lengthAccs[i] = lengthTotal;
    	}
    	
    	boundary = new BoundingBox(posx - scax, posy - scay, posx + scax, posy + scay);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
	}
	
	static getPreviewBoundingBox = function() { return BBOX().fromBoundingBox(boundary); }
}