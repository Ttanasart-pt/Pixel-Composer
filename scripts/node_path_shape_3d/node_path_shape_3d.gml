function Node_Path_Shape_3D(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Shape Path 3D";
	is_3D = NODE_3D.polygon;
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Vec3("Position", [ 0, 0, 0 ]));
	
	newInput(1, nodeValue_Vec3("Half Size", [ .5, .5, .5 ]));
	
	shapeScroll = [ 
	    new scrollItem("Rectangle",       s_node_path_3d_shape,  0),
	    new scrollItem("Ellipse",         s_node_path_3d_shape,  1),
	    new scrollItem("Regular Polygon", s_node_path_3d_shape,  2),
	    -1, 
	    new scrollItem("Star",            s_node_path_3d_shape,  3),
	    -1,
	    new scrollItem("Spring",          s_node_path_3d_shape,  4),
	    new scrollItem("Spring Sphere",   s_node_path_3d_shape,  5),
	    new scrollItem("Spiral",          s_node_path_3d_shape,  6),
    ];
	newInput(2, nodeValue_Enum_Scroll("Shape", 0, { data: shapeScroll, horizontal: true, text_pad: ui(8) }));
	
	newInput(3, nodeValue_Enum_Button("Up Axis", 2, [ "X", "Y", "Z" ]));
	
	newInput(4, nodeValue_Rotation("Rotation", 0));
	
	newInput(5, nodeValue_Int("Sides", 6));
	
	newInput(6, nodeValue_Float("Revolution", 4));
	
	newInput(7, nodeValue_Float("Pitch", .2));
	
	newInput(8, nodeValue_Float("Inner Radius", .5))
	    .setDisplay(VALUE_DISPLAY.slider);
	
	newOutput(0, nodeValue_Output("Path data", VALUE_TYPE.pathnode, self));
	
	input_display_list = [
		["Transform", false], 0, 1, 3, 4, 
		["Shape",     false], 2, 5, 6, 7, 8, 
	];
	
	points      = [];
	lengths		= [];
	lengthAccs	= [];
	lengthTotal	= 0;
	boundary    = new BoundingBox();
	cached_pos  = ds_map_create();
	
	loop  = true;
	shape = 0;
	posx  = 0; posy = 0; posz = 0;
	scax  = 1; scay = 1; scaz = 1;
	
	preview_surf = noone;
	
	static getLineCount		= function() /*=>*/ {return 1};
	static getSegmentCount	= function() /*=>*/ {return array_length(lengths)};
	static getBoundary		= function() /*=>*/ {return boundary};
	static getLength		= function() /*=>*/ {return lengthTotal};
	static getAccuLength	= function() /*=>*/ {return lengthAccs};
	
	static getPointRatio    = function(_rat, _ind = 0, out = undefined) { 
	    out ??= new __vec3P();
	    _rat = frac(_rat);
	    
		switch(shapeScroll[shape].name) {
            default : return getPointDistance(_rat * lengthTotal, _ind, out);
        }
        
        return out;
	}
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) {
	    out ??= new __vec3P();
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
            out.z = lerp(p0[2], p1[2], _d / l);
            break;
	    }
	    
        return out;
	}
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {
	    
		var _camera = params.camera;
		var _v3 = new __vec3();
		
		var _ox = 0, _oy = 0; 
		var _nx = 0, _ny = 0; 
		
		draw_set_color(COLORS._main_accent);
		for( var j = 0, m = array_length(points); j < m; j++ ) {
			_v3.x = points[j][0];
			_v3.y = points[j][1];
			_v3.z = points[j][2];
			
			var _posView = _camera.worldPointToViewPoint(_v3);
			_nx = _posView.x;
			_ny = _posView.y;
			
			if(j) draw_line(_ox, _oy, _nx, _ny);
			
			_ox = _nx;
			_oy = _ny;
		}
		
	}
	
	static update = function(frame = CURRENT_FRAME) {
        var _pos  = getInputData(0);
        var _sca  = getInputData(1);
        var _up   = getInputData(3);
        var _rot  = getInputData(4);
        
	    shape = getInputData(2);
	    posx  = _pos[0]; posy  = _pos[1]; posz  = _pos[2];
        scax  = _sca[0]; scay  = _sca[1]; scaz  = _sca[2];
        
        var ox, oy, oz, nx, ny, nz;
        var x0, y0, z0;
        var x1, y1, z1;
        
        inputs[5].setVisible(false);
        inputs[6].setVisible(false);
        inputs[7].setVisible(false);
        inputs[8].setVisible(false);
        
        switch(shapeScroll[shape].name) {
            case "Rectangle" : 
            	loop = true;
            	
            	x0 = posx - scax;
            	y0 = posy - scay;
            	
            	x1 = posx + scax;
            	y1 = posy + scay;
            	
            	var p  = [
					[ x0, y0, posz ],
					[ x1, y0, posz ],
					[ x1, y1, posz ],
					[ x0, y1, posz ]
        		];
            	
            	points = p;
                break;
                
            case "Ellipse" : 
            	loop = true;
            	var _st = 64;
                var _as = 360 / _st;
                points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    nx = posx + lengthdir_x(scax, _as * i);
                    ny = posy + lengthdir_y(scay, _as * i);
                    points[i] = [ nx, ny, posz ];
                }
                break;
                
            case "Regular Polygon" : 
                inputs[5].setVisible(true);
                var _sid  = getInputData(5);
                
            	loop = true;
            	var _st = max(3, _sid);
                var _as = 360 / _st;
                points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    nx = posx + lengthdir_x(scax, _as * i);
                    ny = posy + lengthdir_y(scay, _as * i);
                    points[i] = [ nx, ny, posz ];
                }
                break;
            
            case "Star" : 
                inputs[5].setVisible(true);
                inputs[8].setVisible(true);
                var _sid  = getInputData(5);
                var _inn  = getInputData(8);
                
            	loop = true;
            	var _st = max(3, _sid);
                var _as = 360 / _st;
                points  = array_create(_st * 2);
                
                for( var i = 0; i < _st; i++ ) {
                    points[i * 2 + 0] = [ posx + lengthdir_x(scax,        _as *  i),       posy + lengthdir_y(scay,        _as *  i),       posz ];
                    points[i * 2 + 1] = [ posx + lengthdir_x(scax * _inn, _as * (i + .5)), posy + lengthdir_y(scay * _inn, _as * (i + .5)), posz ];
                }
                break;
                
            case "Spring" : 
                inputs[6].setVisible(true);
                inputs[7].setVisible(true);
                var _rev = getInputData(6);
                var _pit = getInputData(7);
                
                loop = false;
                var _st = 64 * _rev;
                var _as = 360 / 64;
                points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    nx = posx + lengthdir_x(scax, _as * i);
                    ny = posy + lengthdir_y(scay, _as * i);
                    nz = posz + i / 64 * _pit;
                    
                    points[i] = [ nx, ny, nz ];
                }
                
                break;
                
            case "Spring Sphere" : 
                inputs[6].setVisible(true);
                var _rev = getInputData(6);
                
                z0 = posz - scaz;
                z1 = posz + scaz;
                
                loop = false;
                var _st = 64 * _rev;
                var _as = 360 / 64;
                points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    var t = i / _st;
                    var r = t * 2 - 1;
                        r = sqrt(1 - r * r);
                    
                    nx = posx + lengthdir_x(scax * r, _as * i);
                    ny = posy + lengthdir_y(scay * r, _as * i);
                    nz = lerp(z0, z1, t);
                    
                    points[i] = [ nx, ny, nz ];
                }
                
                break;
            
            case "Spiral" : 
                inputs[6].setVisible(true);
                inputs[7].setVisible(true);
                var _rev = getInputData(6);
                var _pit = getInputData(7);
                
                loop = false;
                var _st = 64 * _rev;
                var _as = 360 / 64;
                var _pp = 1 / 64 * _pit;
                points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    nx = posx + lengthdir_x(scax * i * _pp, _as * i);
                    ny = posy + lengthdir_y(scay * i * _pp, _as * i);
                    
                    points[i] = [ nx, ny, posz ];
                }
                
                break;
        }
        
        if(array_empty(points)) return;
        if(loop) array_push(points, [ points[0][0], points[0][1], points[0][2] ]);
        
        #region preview 
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
    			    
    		    }
        	surface_reset_target();
        #endregion
        
        for( var i = 0, n = array_length(points); i < n; i++ ) {
            var p = points[i];
            point_rotate(p[0], p[1], posx, posy, -_rot, p);
            
            var _x = p[0];
            var _y = p[1];
            var _z = p[2];
            
            switch(_up) {
                case 0 : points[i] = [ _z, _y, _x ]; break;
                case 1 : points[i] = [ _x, _z, _y ]; break;
            }
        }
		
        var n   = array_length(points);
        lengths = array_create(n);
        
        for( var i = 0; i < n; i++ ) {
            nx = points[i][0];
            ny = points[i][1];
            nz = points[i][2];
            
            if(i) lengths[i - 1] = point_distance_3d(ox, oy, oz, nx, ny, nz);
            else { x0 = nx; y0 = ny; z0 = nz; }
            
            ox = nx;
            oy = ny;
            oz = nz;
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
		draw_surface_bbox(preview_surf, bbox);
	}
	
	static getPreviewObject 		= function() /*=>*/ {return noone};
	static getPreviewObjects		= function() /*=>*/ {return []};
	static getPreviewObjectOutline  = function() /*=>*/ {return []};
	static getPreviewBoundingBox    = function() /*=>*/ {return BBOX().fromBoundingBox(boundary)};
}