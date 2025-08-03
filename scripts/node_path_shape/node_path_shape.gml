#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Path_Shape", "Shape > Rectangle", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue(0); });
		addHotkey("Node_Path_Shape", "Shape > Ellipse",   "E", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue(4); });
	});
#endregion

function Node_Path_Shape(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Shape";
	setDimension(96, 48);
	
	shape_types = [ 
	        "Rectangle", "Trapezoid", "Parallelogram",
	    -1, "Ellipse", "Arc", "Squircle", "Hypocycloid", "Epitrochoid", 
	    -1, "Polygon", "Star", "Twist", 
	    -1, "Line", "Curve", "Spiral", "Spiral Circle",
    ];
    
    __ind = 0; shapeScroll = array_map(shape_types, function(v, i) /*=>*/ {return v == -1? -1 : new scrollItem(v, s_node_shape_path_type, __ind++)});
    
    ////- =Transform
	newInput( 0, nodeValue_Vec2(     "Position",  [.5,.5] )).setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	newInput( 2, nodeValue_Rotation( "Rotation",    0     ));
	newInput( 1, nodeValue_Vec2(     "Half Size", [.5,.5] )).setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
    ////- =Shape
	newInput( 3, nodeValue_Enum_Scroll(    "Shape",          0, { data: shapeScroll, horizontal: true, text_pad: ui(16) } ))
		.setHistory([ shape_types, { cond: function() /*=>*/ {return LOADING_VERSION < 1_19_06_0}, list: global.node_path_shape_keys_195 } ]);
		
	newInput( 4, nodeValue_Slider(         "Skew",          .5, [-1,1,.01] ));
	newInput( 5, nodeValue_Rotation_Range( "Angle Range",   [0,90]         ));
	newInput( 6, nodeValue_Float(          "Factor",         4             ));
	newInput( 7, nodeValue_Int(            "Sides",          4             ));
	newInput( 8, nodeValue_Float(          "Inner Radius",  .5             ));
	newInput( 9, nodeValue_Corner(         "Corner Radius", [0,0,0,0]      ));
	newInput(12, nodeValue_Rotation(       "Angle",          0             ));
	newInput(10, nodeValue_Float(          "Revolution",     4             ));
	newInput(11, nodeValue_Float(          "Pitch",         .2             )).setCurvable(13, CURVE_DEF_11);
	newInput(14, nodeValue_Int(            "Resolution",     64            ));
	// input 15
	
	newOutput(0, nodeValue_Output("Path data", VALUE_TYPE.pathnode, self));
		
	input_display_list = [
		["Transform", false], 0, 2, 1, 
		["Shape",     false], 3, 4, 5, 6, 7, 8, 9, 12, 10, 11, 13, 14, 
	];
	
	////- Path
	
	points      = [];
	lengths		= [];
	lengthAccs	= [];
	lengthTotal	= 0;
	boundary    = new BoundingBox();
	cached_pos  = ds_map_create();
	
	loop  = true;
	shape = 0;
	posx  = 0; posy  = 0;
	scax  = 1; scay  = 1;
	rot   = 0;
	
	pa1   = 0;
	pa2x  = 0; pa2y  = 0;
	pa3   = 0;
	
	corners = [ 0, 0, 0, 0 ];
	
	preview_surf = noone;
	
	static getLineCount		= function() /*=>*/ {return 1};
	static getSegmentCount	= function() /*=>*/ {return array_length(lengths)};
	static getBoundary		= function() /*=>*/ {return boundary};
	static getLength		= function() /*=>*/ {return lengthTotal};
	static getAccuLength	= function() /*=>*/ {return lengthAccs};
	
	static getPointRatio    = function(_rat, _ind = 0, out = undefined) { 
	    out ??= new __vec2P();
	    _rat = frac(_rat);
	    
		switch(shape_types[shape]) {
            case "Ellipse" : 
                var a = 360 * _rat;
                out.x = posx + lengthdir_x(scax, a);
                out.y = posy + lengthdir_y(scay, a);
                break;
                
            case "Arc" : 
                var a = lerp_float_angle(pa2x, pa2y, _rat);
                out.x = posx + lengthdir_x(scax, a);
                out.y = posy + lengthdir_y(scay, a);
                break;
                
            case "Squircle" : 
                var a = 360 * _rat;
                var r = 1 / power(power(dcos(a % 90), pa3) + power(dsin(a % 90), pa3), 1 / pa3);
                    
                out.x = posx + lengthdir_x(scax * r, a);
                out.y = posy + lengthdir_y(scay * r, a);
                break;
                
			default : return getPointDistance(_rat * lengthTotal, _ind, out);
        }
        
        point_vec2_rotate(out, posx, posy, rot);
        return out;
	}
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) {
	    out ??= new __vec2P();
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
	    
        return out;
	}
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
	    if(array_empty(points)) return w_hovering;
	    
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
	    
	    if(loop) draw_line(ox, oy, x0, y0);
	    
	    var _px = _x + posx * _s;
	    var _py = _y + posy * _s;
	    
	    InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
	    InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
	    InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
	    
	    return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
	        var _pos  = getInputData(0);
	        var _rot  = getInputData(2);
	        var _sca  = getInputData(1);
	        
		    shape     = getInputData(3);
	        var _pa1  = getInputData(4);
	        var _aran = getInputData(5);
	        var _pa3  = getInputData(6);
	        var _sid  = getInputData(7);
	        var _inn  = getInputData(8);
	        var _c    = getInputData(9);
	        var _rev  = getInputData(10);
	        
	        for( var i = 4; i < array_length(inputs); i++ ) 
	        	inputs[i].setVisible(false);
		#endregion
    	
    	posx  = _pos[0]; posy  = _pos[1];
        scax  = _sca[0]; scay  = _sca[1];
        rot   = _rot;
        
        pa1   = _pa1;
        pa2x  = _aran[0];
        pa2y  = _aran[1];
        pa3   = _pa3;
        
        corners   = _c;
        
        var ox, oy, nx, ny, x0, y0;
        var cind = [ 0, 1, 3, 2 ];
          
        switch(shape_types[shape]) {
            case "Rectangle" : 
            	loop = true;
            	inputs[9].setVisible(true);
            	
            	var x0 = posx - scax;
            	var y0 = posy - scay;
            	
            	var x1 = posx + scax;
            	var y1 = posy + scay;
            	
            	var p  = [
					[ x0, y1 ],
					[ x0, y0 ],
            		[ x1, y0 ],
            		
					[ x0, y0 ],
					[ x1, y0 ],
					[ x1, y1 ],
					
					[ x1, y0 ],
					[ x1, y1 ],
					[ x0, y1 ],
					
					[ x1, y1 ],
					[ x0, y1 ],
					[ x0, y0 ],
        		];
            	
            	var ar = array_create(4);
            	for( var i = 0; i < 4; i++ ) {
            		var c = cind[i];
            		ar[i] = _c[c]? get_corner_radius(p[i * 3 + 0][0], p[i * 3 + 0][1], 
            		                                 p[i * 3 + 1][0], p[i * 3 + 1][1], 
            		                                 p[i * 3 + 2][0], p[i * 3 + 2][1], _c[c], 64, 0) : [ p[i * 3 + 1] ];
            	}
            	
            	points = array_merge( ar[0], ar[1], ar[2], ar[3] );
                break;
                
            case "Trapezoid" : 
            	loop = true;
                inputs[4].setVisible(true);
            	inputs[9].setVisible(true);
                
            	var x0 = posx - scax * clamp(1 - _pa1, 0, 1);
            	var y0 = posy - scay;
            	
            	var x1 = posx + scax * clamp(1 - _pa1, 0, 1);
            	var y1 = posy - scay;
            	
            	var x2 = posx + scax * clamp(1 + _pa1, 0, 1);
            	var y2 = posy + scay;
            	
            	var x3 = posx - scax * clamp(1 + _pa1, 0, 1);
            	var y3 = posy + scay;
            	
            	var p  = [
					[ x3, y3 ],
					[ x0, y0 ],
            		[ x1, y1 ],
            		
					[ x0, y0 ],
					[ x1, y1 ],
					[ x2, y2 ],
					
					[ x1, y1 ],
					[ x2, y2 ],
					[ x3, y3 ],
					
					[ x2, y3 ],
					[ x3, y3 ],
					[ x0, y0 ],
        		];
            	
            	var ar = array_create(4);
            	for( var i = 0; i < 4; i++ ) {
            		var c = cind[i];
            		ar[i] = _c[c]? get_corner_radius(p[i * 3 + 0][0], p[i * 3 + 0][1], 
            		                                 p[i * 3 + 1][0], p[i * 3 + 1][1], 
            		                                 p[i * 3 + 2][0], p[i * 3 + 2][1], _c[c], 64, 0) : [ p[i * 3 + 1] ];
            	}
            	
            	points = array_merge( ar[0], ar[1], ar[2], ar[3] );
                break;
                
            case "Parallelogram" : 
            	loop = true;
                inputs[4].setVisible(true);
            	inputs[9].setVisible(true);
                
            	var x0 = posx - scax * clamp(1 - _pa1, 0, 1);
            	var y0 = posy - scay;
            	
            	var x1 = posx + scax * clamp(1 + _pa1, 0, 1);
            	var y1 = posy - scay;
            	
            	var x2 = posx + scax * clamp(1 - _pa1, 0, 1);
            	var y2 = posy + scay;
            	
            	var x3 = posx - scax * clamp(1 + _pa1, 0, 1);
            	var y3 = posy + scay;
            	
            	var p  = [
					[ x3, y3 ],
					[ x0, y0 ],
            		[ x1, y1 ],
            		
					[ x0, y0 ],
					[ x1, y1 ],
					[ x2, y2 ],
					
					[ x1, y1 ],
					[ x2, y2 ],
					[ x3, y3 ],
					
					[ x2, y3 ],
					[ x3, y3 ],
					[ x0, y0 ],
        		];
            	
            	var ar = array_create(4);
            	for( var i = 0; i < 4; i++ ) {
            		var c = cind[i];
            		ar[i] = _c[c]? get_corner_radius(p[i * 3 + 0][0], p[i * 3 + 0][1], 
            		                                 p[i * 3 + 1][0], p[i * 3 + 1][1], 
            		                                 p[i * 3 + 2][0], p[i * 3 + 2][1], _c[c], 64, 0) : [ p[i * 3 + 1] ];
            	}
            	
            	points = array_merge( ar[0], ar[1], ar[2], ar[3] );
                break;
            
            case "Ellipse" : 
            	loop = true;
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
            	loop = false;
                inputs[5].setVisible(true);
                
                var _st = 64;
                var _as = 1 / (_st - 1);
                points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    var a = lerp_float_angle(_aran[0], _aran[1], i * _as);
                    nx = posx + lengthdir_x(scax, a);
                    ny = posy + lengthdir_y(scay, a);
                    points[i] = [ nx, ny ];
                }
                break;
                
            case "Squircle" :
            	loop = true;
                inputs[6].setVisible(true);
                
                var _st = 64;
                var _as = 360 / _st;
                var _fc = max(pa3, 0);
                points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    var a = _as * i;
                    var r = 1 / power(power(dcos(a % 90), _fc) + power(dsin(a % 90), _fc), 1 / _fc);
                    
                    nx = posx + lengthdir_x(scax * r, a);
                    ny = posy + lengthdir_y(scay * r, a);
                    points[i] = [ nx, ny ];
                }
                break;
                
            case "Hypocycloid" :
            	loop = true;
            	inputs[ 6].setVisible(true);
            	inputs[10].setVisible(true);
            	
            	var _k   = _pa3;
            	var _st  = 32 * _k * _rev;
            	var _ast = 360 / (_st - 1) * _rev;
            	points  = array_create(_st);
            	
            	for( var i = 0; i < _st; i++ ) {
            		var _aa = _ast * i;
            		
            		nx = (_k - 1) * dcos(_aa) + dcos( (_k - 1) * _aa );
            		ny = (_k - 1) * dsin(_aa) - dsin( (_k - 1) * _aa );
            		
            		nx = posx + nx * scax / _k;
					ny = posy + ny * scay / _k;
            		
            		points[i] = [ nx, ny ];
            	}
            	break;
        	case "Epitrochoid" :
            	loop = true;
            	inputs[ 6].setVisible(true);
            	inputs[ 8].setVisible(true);
            	inputs[10].setVisible(true);
            	
            	var _innM = 1 / max(0.1, _inn);
            	var _st   = 64 * _rev / _innM;
            	var _ast  = 360 / (_st - 1) * _rev;
            	points    = array_create(_st);
            	
            	for( var i = 0; i < _st; i++ ) {
            		var _aa = _ast * i;
            		
            		nx = (1 + _innM) * dcos(_aa) - _pa3 * dcos((1 + _innM) / _innM * _aa);
            		ny = (1 + _innM) * dsin(_aa) - _pa3 * dsin((1 + _innM) / _innM * _aa);
            		
            		nx = posx + nx * scax / (1 + _pa3);
					ny = posy + ny * scay / (1 + _pa3);
            		
            		points[i] = [ nx, ny ];
            	}
            	break;
            	
            case "Polygon" :
            	loop = true;
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
            	loop = true;
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
                
            case "Twist" :
            	loop = true;
                inputs[6].setVisible(true);
                
                var _fc = max(_pa3, 0);
                var _st = 64 / clamp(_fc, .1, 1);
                points  = array_create(_st * 2);
                
                for( var i = 0; i <= _st; i++ ) {
                	
                	nx = (i / _st) * 2 - 1;
                	nx = sign(nx) * power(abs(nx), 1 / (_fc + 1));
                	
                	ny = lerp(nx, sign(nx) * sqrt(1 - nx * nx), power(abs(nx), _fc));
                	
                	points[i]           = [posx + nx * scax, posy + ny * scay];
                	points[_st * 2 - i] = [posx + nx * scax, posy - ny * scay];
                }
                
            	break;
            case "Line":
            	loop = false;
            	points = [
            		[ posx - scax, posy ],
            		[ posx + scax, posy ],
        		];
            	break;
            	
            case "Curve":
            	loop = false;
            	inputs[6].setVisible(true);
            	
            	var _st = 64;
                var _as = 180 / (_st - 1);
                var _x0 = posx - scax;
                var _x1 = posx + scax;
                var _yy = posy;
                
            	points = array_create(_st);
            	for( var i = 0; i < _st; i++ ) {
            		points[i] = [ 
            			lerp(_x0, _x1, i / (_st - 1)),
            			_yy + dsin(i * _as) * pa3,
        			]
            	}
            	break;
        
        	case "Spiral" : 
                inputs[10].setVisible(true);
                inputs[11].setVisible(true);
                inputs[12].setVisible(true);
                inputs[14].setVisible(true);
                
                var _ang  = getInputData(12);
                var _pit  = getInputData(11);
                var _pitC = getInputData(13), curve_pit   = inputs[11].attributes.curved? new curveMap(_pitC)  : undefined;
                var _rst  = getInputData(14);
                
                loop = false;
                var _st = _rst * abs(_rev);
                var _as = 360 / _rst * sign(_rev);
                var _is = 1 / (_st - 1);
                var _rr = 0;
                points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                	var _pp = _pit / _rst;
                	if(curve_pit) _pp *= curve_pit.get(i * _is);
                	
                    nx = posx + lengthdir_x(scax * _rr, _ang + _as * i);
                    ny = posy + lengthdir_y(scay * _rr, _ang + _as * i);
                    
                    _rr += _pp;
                    points[i] = [ nx, ny ];
                }
                
                break;
                
            case "Spiral Circle" : 
                inputs[10].setVisible(true);
                inputs[12].setVisible(true);
                inputs[14].setVisible(true);
                
                var _rev = getInputData(10);
                var _ang = getInputData(12);
                var _rst = getInputData(14);
                
                loop = false;
                var _st = _rst * abs(_rev);
                var _as = 360 / _rst * sign(_rev);
                var _pp = 1 / _st;
                points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                	var prg = i * _pp;
                	    prg = sqrt(1 - prg * prg);
                	
                    nx = posx + lengthdir_x(scax * prg, _ang + _as * i);
                    ny = posy + lengthdir_y(scay * prg, _ang + _as * i);
                    
                    points[i] = [ nx, ny ];
                }
                
                break;
        }

		array_map_ext(points, function(p) /*=>*/ {return point_rotate(p[0], p[1], posx, posy, rot, p)});
		
        var n   = array_length(points);
        lengths = array_create(n + loop);
        
        if(n) {
            for( var i = 0; i < n; i++ ) {
                nx = points[i][0];
                ny = points[i][1];
                
                if(i) lengths[i - 1] = point_distance(ox, oy, nx, ny);
                else { x0 = nx; y0 = ny; }
                
                ox = nx;
                oy = ny;
            }
            
            if(loop) lengths[n - 1] = point_distance(ox, oy, x0, y0);
        }
        
        var _len    = array_length(lengths);
    	lengthTotal = 0;
    	lengthAccs  = array_create(_len);
    	
    	for( var i = 0; i < _len; i++ ) {
    	    lengthTotal  += lengths[i];
    	    lengthAccs[i] = lengthTotal;
    	}
    	
    	boundary = new BoundingBox(posx - scax, posy - scay, posx + scax, posy + scay);
    	
    	preview_surf = surface_verify(preview_surf, 128, 128);
    	surface_set_target(preview_surf);
    		DRAW_CLEAR
    		
    		var ox, x0;
		    var oy, y0;
		    var nx, ny;
		    var xx = posx - scax;
		    var yy = posy - scay;
		    var ww = scax * 2;
		    var hh = scay * 2;
		    draw_set_color(COLORS._main_accent);
		    
		    if(array_length(points)) {
			    for( var i = 0, n = array_length(points); i < n; i++ ) {
			        nx = 4 + (points[i][0] - xx) / ww * 120;
			        ny = 4 + (points[i][1] - yy) / hh * 120;
			        
		            if(i) draw_line_width(ox, oy, nx, ny, 8);
		            else  { x0 = nx; y0 = ny; }
			        
			        ox = nx;
			        oy = ny;
			    }
			    
			    if(loop) draw_line_width(ox, oy, x0, y0, 8);
		    }
    	surface_reset_target();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_surface_bbox(preview_surf, bbox);
	}
	
	static getPreviewBoundingBox = function() { return BBOX().fromBoundingBox(boundary); }
}

global.node_path_shape_keys_195 = [ 
        "Rectangle", "Trapezoid", "Parallelogram",
    -1, "Ellipse", "Arc", "Squircle", 
    -1, "Polygon", "Star", 
    -1, "Line", "Curve", "Spiral", "Spiral Circle",
];
