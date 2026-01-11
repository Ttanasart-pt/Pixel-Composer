#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Path_Shape", "Shape > Rectangle", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue(0); });
		addHotkey("Node_Path_Shape", "Shape > Ellipse",   "E", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue(4); });
	});
#endregion

function Node_Path_Shape(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Shape";
	always_pad      = true;
	dimension_index = -1;
	setDimension(96, 48);
	
	shape_types = [ 
	        "Rectangle", "Trapezoid", "Parallelogram",
	    -1, "Ellipse", "Arc", "Squircle", "Hypocycloid", "Epitrochoid", 
	    -1, "Polygon", "Star", "Twist", 
	    -1, "Line", "Curve", "Spiral", "Spiral Circle",
    ];
    
    __ind = 0; shapeScroll = array_map(shape_types, function(v, i) /*=>*/ {return v == -1? -1 : new scrollItem(v, s_node_shape_path_type, __ind++)});
    
    ////- =Transform
	newInput( 0, nodeValue_Vec2(     "Position",  [.5,.5] )).setHotkey("G").setUnitSimple();
	newInput( 2, nodeValue_Rotation( "Rotation",    0     )).setHotkey("R");
	newInput( 1, nodeValue_Vec2(     "Half Size", [.5,.5] )).setUnitSimple();
	
    ////- =Shape
	newInput( 3, nodeValue_EScroll(  "Shape",          0, { data: shapeScroll, horizontal: 1, text_pad: ui(16) } ))
		.setHistory([ shape_types, { cond: function() /*=>*/ {return LOADING_VERSION < 1_19_06_0}, list: global.node_path_shape_keys_195 } ]);
		
	newInput( 4, nodeValue_Slider(   "Skew",          .5, [-1,1,.01] ));
	newInput( 5, nodeValue_RotRange( "Angle Range",   [0,90]         ));
	newInput( 6, nodeValue_Float(    "Factor",         4             ));
	newInput( 7, nodeValue_Int(      "Sides",          4             ));
	newInput( 8, nodeValue_Float(    "Inner Radius",  .5             ));
	newInput( 9, nodeValue_Corner(   "Corner Radius", [0,0,0,0]      )).setUnitSimple();
	newInput(12, nodeValue_Rotation( "Angle",          0             ));
	newInput(10, nodeValue_Float(    "Revolution",     4             ));
	newInput(15, nodeValue_Bool(     "Reverse",        false         ));
	newInput(11, nodeValue_Float(    "Pitch",         .2             )).setCurvable(13, CURVE_DEF_01);
	
    ////- =Detail
	newInput(14, nodeValue_Int(      "Resolution",     64            ));
	// input 16
	
	newOutput(0, nodeValue_Output("Path data", VALUE_TYPE.pathnode, noone ));
		
	input_display_list = [
		[ "Transform", false ],  0,  2,  1, 
		[ "Shape",     false ],  3,  4,  5,  6,  7,  8,  9, 12, 10, 15, 11, 13, 
		[ "Detail",    false ], 14, 
	];
	
	////- Path
	
	preview_surf = noone;
	
	function _pathShapeObject(_node) : Path(_node) constructor {
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
		
		static getLineCount		= function() /*=>*/ {return 1};
		static getSegmentCount	= function() /*=>*/ {return array_length(lengths)};
		static getBoundary		= function() /*=>*/ {return boundary};
		static getLength		= function() /*=>*/ {return lengthTotal};
		static getAccuLength	= function() /*=>*/ {return lengthAccs};
		
		static getPointRatio    = function(_rat, _ind = 0, out = undefined) { 
		    out ??= new __vec2P();
		    _rat = frac(_rat);
		    
			switch(node.shape_types[shape]) {
	            case "Ellipse" : 
	                var a = 360 * _rat;
	                out.x = posx + lengthdir_x(scax, a);
	                out.y = posy + lengthdir_y(scay, a);
	                break;
	                
	            case "Arc" : 
	                var a = lerp_angle_direct(pa2x, pa2y, _rat);
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
		        
		        if(l == 0) continue;
		        if(_d > l) { _d -= l; continue; }
		        
	            var p0 = points[(i + 0) % np];
	            var p1 = points[(i + 1) % np];
	            
	            out.x = lerp(p0[0], p1[0], _d / l);
	            out.y = lerp(p0[1], p1[1], _d / l);
	            break;
		    }
		    
	        return out;
		}
	}
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pth = outputs[0].getValue();
		if(!is(_pth, _pathShapeObject)) return;
		
	    if(array_empty(_pth.points)) return w_hovering;
	    
	    var ox = _x + _pth.points[0][0] * _s, x0 = ox;
	    var oy = _y + _pth.points[0][1] * _s, y0 = oy;
	    var nx, ny;
	    
	    draw_set_color(COLORS._main_accent);
	    for( var i = 1, n = array_length(_pth.points); i < n; i++ ) {
	        nx = _x + _pth.points[i][0] * _s;
	        ny = _y + _pth.points[i][1] * _s;
	        
            draw_line(ox, oy, nx, ny);
	        
	        ox = nx;
	        oy = ny;
	    }
	    
	    if(_pth.loop) draw_line(ox, oy, x0, y0);
	    
	    var _px = _x + _pth.posx * _s;
	    var _py = _y + _pth.posy * _s;
	    
	    InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
	    InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
	    InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
	    
	    return w_hovering;
	}
	
	static drawProcessShort = function(cx, cy, cw, ch, _prog) {
		var _pth = outputs[0].getValue();
		if(!is(_pth, _pathShapeObject)) return undefined;
	    if(array_empty(_pth.points))    return undefined;
		
		var rw = DEF_SURF_W;
		var rh = DEF_SURF_H;
		var ss = min(cw / rw, ch / rh);
		var _x = cx - rw * ss / 2;
		var _y = cy - rh * ss / 2;
		
	    var ox = _x + ss * _pth.points[0][0], x0 = ox;
	    var oy = _y + ss * _pth.points[0][1], y0 = oy;
	    var nx, ny;
	    var amo = round(array_length(_pth.points) * _prog);
	    
	    draw_set_color(COLORS._main_accent);
	    for( var i = 1; i < amo; i++ ) {
	        nx = _x + ss * _pth.points[i][0];
	        ny = _y + ss * _pth.points[i][1];
	        
            draw_line_round(ox, oy, nx, ny, 4);
	        
	        ox = nx;
	        oy = ny;
	    }
	    
	    if(_pth.loop && _prog >= 1) draw_line(ox, oy, x0, y0);
	    
	    return rh * ss;
	}
	
	////- Nodes
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
	        var _pos  = getInputData( 0);
	        var _rot  = getInputData( 2);
	        var _sca  = getInputData( 1);
	        
		    var _shap = getInputData( 3);
	        var _pa1  = getInputData( 4);
	        var _aran = getInputData( 5);
	        var _pa3  = getInputData( 6);
	        var _sid  = getInputData( 7);
	        var _inn  = getInputData( 8);
	        var _c    = getInputData( 9);
	        var _rev  = getInputData(10);
	        
	        for( var i = 4, n = array_length(inputs); i < n; i++ ) 
	        	inputs[i].setVisible(false);
		#endregion
    	
		_pth = outputs[0].getValue();
		if(!is(_pth, _pathShapeObject)) _pth = new _pathShapeObject(self);
		outputs[0].setValue(_pth);
		
		_pth.shape = _shap;
		
    	_pth.posx  = _pos[0]; 
    	_pth.posy  = _pos[1];
        _pth.scax  = _sca[0];
        _pth.scay  = _sca[1];
        _pth.rot   = _rot;
        
        _pth.pa1   = _pa1;
        _pth.pa2x  = _aran[0];
        _pth.pa2y  = _aran[1];
        _pth.pa3   = _pa3;
        
        var ox, oy, nx, ny, x0, y0;
        var cind = [ 0, 1, 3, 2 ];
          
        switch(shape_types[_shap]) {
            case "Rectangle" : 
            	inputs[9].setVisible(true);
            	
            	_pth.loop = true;
            	
            	var x0 = _pos[0] - _sca[0];
            	var y0 = _pos[1] - _sca[1];
            	
            	var x1 = _pos[0] + _sca[0];
            	var y1 = _pos[1] + _sca[1];
            	
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
            	
            	_pth.points = array_merge( ar[0], ar[1], ar[2], ar[3] );
                break;
                
            case "Trapezoid" : 
                inputs[4].setVisible(true);
            	inputs[9].setVisible(true);
            	
            	_pth.loop = true;
                
            	var x0 = _pos[0] - _sca[0] * clamp(1 - _pa1, 0, 1);
            	var y0 = _pos[1] - _sca[1];
            	
            	var x1 = _pos[0] + _sca[0] * clamp(1 - _pa1, 0, 1);
            	var y1 = _pos[1] - _sca[1];
            	
            	var x2 = _pos[0] + _sca[0] * clamp(1 + _pa1, 0, 1);
            	var y2 = _pos[1] + _sca[1];
            	
            	var x3 = _pos[0] - _sca[0] * clamp(1 + _pa1, 0, 1);
            	var y3 = _pos[1] + _sca[1];
            	
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
            	
            	_pth.points = array_merge( ar[0], ar[1], ar[2], ar[3] );
                break;
                
            case "Parallelogram" : 
                inputs[4].setVisible(true);
            	inputs[9].setVisible(true);
            	
            	_pth.loop = true;
                
            	var x0 = _pos[0] - _sca[0] * clamp(1 - _pa1, 0, 1);
            	var y0 = _pos[1] - _sca[1];
            	
            	var x1 = _pos[0] + _sca[0] * clamp(1 + _pa1, 0, 1);
            	var y1 = _pos[1] - _sca[1];
            	
            	var x2 = _pos[0] + _sca[0] * clamp(1 - _pa1, 0, 1);
            	var y2 = _pos[1] + _sca[1];
            	
            	var x3 = _pos[0] - _sca[0] * clamp(1 + _pa1, 0, 1);
            	var y3 = _pos[1] + _sca[1];
            	
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
            	
            	_pth.points = array_merge( ar[0], ar[1], ar[2], ar[3] );
                break;
            
            case "Ellipse" : 
            	_pth.loop = true;
                var _st = 64;
                var _as = 360 / _st;
                _pth.points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    nx = _pos[0] + lengthdir_x(_sca[0], _as * i);
                    ny = _pos[1] + lengthdir_y(_sca[1], _as * i);
                    _pth.points[i] = [ nx, ny ];
                }
                break;
                
            case "Arc" : 
                inputs[5].setVisible(true);
                
            	_pth.loop = false;
                
                var _st = 64;
                var _as = 1 / (_st - 1);
                _pth.points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    var a = lerp_angle_direct(_aran[0], _aran[1], i * _as);
                    nx = _pos[0] + lengthdir_x(_sca[0], a);
                    ny = _pos[1] + lengthdir_y(_sca[1], a);
                    _pth.points[i] = [ nx, ny ];
                }
                break;
                
            case "Squircle" :
                inputs[6].setVisible(true);
                
            	_pth.loop = true;
                
                var _st = 64;
                var _as = 360 / _st;
                var _fc = max(_pa3, 0);
                _pth.points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    var a = _as * i;
                    var r = 1 / power(power(dcos(a % 90), _fc) + power(dsin(a % 90), _fc), 1 / _fc);
                    
                    nx = _pos[0] + lengthdir_x(_sca[0] * r, a);
                    ny = _pos[1] + lengthdir_y(_sca[1] * r, a);
                    _pth.points[i] = [ nx, ny ];
                }
                break;
                
            case "Hypocycloid" :
            	inputs[ 6].setVisible(true);
            	inputs[10].setVisible(true);
            	
            	_pth.loop = true;
            	
            	var _k   = _pa3;
            	var _st  = 32 * _k * _rev;
            	var _ast = 360 / (_st - 1) * _rev;
            	_pth.points  = array_create(_st);
            	
            	for( var i = 0; i < _st; i++ ) {
            		var _aa = _ast * i;
            		
            		nx = (_k - 1) * dcos(_aa) + dcos( (_k - 1) * _aa );
            		ny = (_k - 1) * dsin(_aa) - dsin( (_k - 1) * _aa );
            		
            		nx = _pos[0] + nx * _sca[0] / _k;
					ny = _pos[1] + ny * _sca[1] / _k;
            		
            		_pth.points[i] = [ nx, ny ];
            	}
            	break;
        	case "Epitrochoid" :
            	inputs[ 6].setVisible(true);
            	inputs[ 8].setVisible(true);
            	inputs[10].setVisible(true);
            	
            	_pth.loop = true;
            	
            	var _innM = 1 / max(0.1, _inn);
            	var _st   = 64 * _rev / _innM;
            	var _ast  = 360 / (_st - 1) * _rev;
            	_pth.points    = array_create(_st);
            	
            	for( var i = 0; i < _st; i++ ) {
            		var _aa = _ast * i;
            		
            		nx = (1 + _innM) * dcos(_aa) - _pa3 * dcos((1 + _innM) / _innM * _aa);
            		ny = (1 + _innM) * dsin(_aa) - _pa3 * dsin((1 + _innM) / _innM * _aa);
            		
            		nx = _pos[0] + nx * _sca[0] / (1 + _pa3);
					ny = _pos[1] + ny * _sca[1] / (1 + _pa3);
            		
            		_pth.points[i] = [ nx, ny ];
            	}
            	break;
            	
            case "Polygon" :
                inputs[7].setVisible(true);
                
            	_pth.loop = true;
                
                var _st = _sid;
                var _as = 360 / _st;
                _pth.points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                    nx = _pos[0] + lengthdir_x(_sca[0], _as * i);
                    ny = _pos[1] + lengthdir_y(_sca[1], _as * i);
                    _pth.points[i] = [ nx, ny ];
                }
                break;
                
            case "Star" :
                inputs[7].setVisible(true);
                inputs[8].setVisible(true);
                
            	_pth.loop = true;
                
                var _st = _sid;
                var _as = 360 / _st;
                _pth.points  = array_create(_st * 2);
                
                for( var i = 0; i < _st; i++ ) {
                    nx = _pos[0] + lengthdir_x(_sca[0], _as * i);
                    ny = _pos[1] + lengthdir_y(_sca[1], _as * i);
                    _pth.points[i * 2 + 0] = [ nx, ny ];
                    
                    nx = _pos[0] + lengthdir_x(_sca[0] * _inn, _as * i + _as / 2);
                    ny = _pos[1] + lengthdir_y(_sca[1] * _inn, _as * i + _as / 2);
                    _pth.points[i * 2 + 1] = [ nx, ny ];
                }
                break;
                
            case "Twist" :
                inputs[6].setVisible(true);
                
            	_pth.loop = true;
                
                var _fc = max(_pa3, 0);
                var _st = 64 / clamp(_fc, .1, 1);
                _pth.points  = array_create(_st * 2);
                
                for( var i = 0; i <= _st; i++ ) {
                	
                	nx = (i / _st) * 2 - 1;
                	nx = sign(nx) * power(abs(nx), 1 / (_fc + 1));
                	
                	ny = lerp(nx, sign(nx) * sqrt(1 - nx * nx), power(abs(nx), _fc));
                	
                	_pth.points[i]           = [_pos[0] + nx * _sca[0], _pos[1] + ny * _sca[1]];
                	_pth.points[_st * 2 - i] = [_pos[0] + nx * _sca[0], _pos[1] - ny * _sca[1]];
                }
                
            	break;
            case "Line":
            	_pth.loop = false;
            	
            	_pth.points = [
            		[ _pos[0] - _sca[0], _pos[1] ],
            		[ _pos[0] + _sca[0], _pos[1] ],
        		];
            	break;
            	
            case "Curve":
            	inputs[6].setVisible(true);
            	
            	_pth.loop = false;
            	
            	var _st = 64;
                var _as = 180 / (_st - 1);
                var _x0 = _pos[0] - _sca[0];
                var _x1 = _pos[0] + _sca[0];
                var _yy = _pos[1];
                
            	_pth.points = array_create(_st);
            	for( var i = 0; i < _st; i++ ) {
            		_pth.points[i] = [ 
            			lerp(_x0, _x1, i / (_st - 1)),
            			_yy + dsin(i * _as) * _pa3,
        			]
            	}
            	break;
        
        	case "Spiral" : 
                var _ang  = getInputData(12);
                var _revr = getInputData(15);
                var _pit  = getInputData(11);
                var _pitC = getInputData(13), curve_pit = inputs[11].attributes.curved? new curveMap(_pitC) : undefined;
                
                var _rst  = getInputData(14);
                
                inputs[12].setVisible(true);
                inputs[10].setVisible(true);
                inputs[15].setVisible(true);
                inputs[11].setVisible(true);
                inputs[13].setVisible(inputs[11].attributes.curved);
                
                inputs[14].setVisible(true);
                
                _pth.loop = false;
                
                var _st = _rst * abs(_rev);
                var _as = 360 / _rst * sign(_rev);
                var _is = 1 / (_st - 1);
                var _rr = 0;
                if(_revr) {
                	_pit  = 1 / abs(_rev);
                	_ang -= _as * _st;
                }
                
            	var _pp = _pit / _rst;
                _pth.points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                	if(curve_pit)
                		 _rr = _rev * _pit * curve_pit.get(i * _is);
                	else _rr = _pp * i;
                	
                    nx = _pos[0] + lengthdir_x(_sca[0] * _rr, _ang + _as * i);
                    ny = _pos[1] + lengthdir_y(_sca[1] * _rr, _ang + _as * i);
                    
                    _pth.points[i] = [ nx, ny ];
                }
                
                break;
                
            case "Spiral Circle" : 
                inputs[12].setVisible(true);
                inputs[10].setVisible(true);
                inputs[11].setVisible(true);
                inputs[13].setVisible(inputs[11].attributes.curved);
                
                inputs[14].setVisible(true);
                
                var _ang  = getInputData(12);
                var _pit  = getInputData(11); _pit = max(_pit, .01);
                var _pitC = getInputData(13), curve_pit = inputs[11].attributes.curved? new curveMap(_pitC) : undefined;
                
                var _rst  = getInputData(14);
                
                _pth.loop = false;
                var _st = _rst * abs(_rev);
                var _as = 360 / _rst * sign(_rev);
                var _is = 1 / (_st - 1);
                var _pp = 1 / _st;
                _pth.points  = array_create(_st);
                
                for( var i = 0; i < _st; i++ ) {
                	var prg = i * _pp;
                	if(curve_pit) {
	                	prg  = 1 - prg;
	                	prg *= curve_pit.get(i * _is);
                	} else prg = sqrt(1 - power(prg, _pit * 10));
                	
                    nx = _pos[0] + lengthdir_x(_sca[0] * prg, _ang + _as * i);
                    ny = _pos[1] + lengthdir_y(_sca[1] * prg, _ang + _as * i);
                    
                    _pth.points[i] = [ nx, ny ];
                }
                
                break;
        }
		
		_pth.points = array_filter(_pth.points, function(p) /*=>*/ {return is_array(p)});
		array_map_ext(_pth.points, function(p) /*=>*/ {return point_rotate(p[0], p[1], _pth.posx, _pth.posy, _pth.rot, p)});
		
        var n   = array_length(_pth.points);
        _pth.lengths = array_create(n + _pth.loop);
        
        if(n) {
            for( var i = 0; i < n; i++ ) {
                nx = _pth.points[i][0];
                ny = _pth.points[i][1];
                
                if(i) _pth.lengths[i - 1] = point_distance(ox, oy, nx, ny);
                else { x0 = nx; y0 = ny; }
                
                ox = nx;
                oy = ny;
            }
            
            if(_pth.loop) _pth.lengths[n - 1] = point_distance(ox, oy, x0, y0);
        }
        
        var _len    = array_length(_pth.lengths);
    	_pth.lengthTotal = 0;
    	_pth.lengthAccs  = array_create(_len);
    	
    	for( var i = 0; i < _len; i++ ) {
    	    _pth.lengthTotal  += _pth.lengths[i];
    	    _pth.lengthAccs[i] = _pth.lengthTotal;
    	}
    	
    	_pth.boundary = new BoundingBox(_pos[0] - _sca[0], _pos[1] - _sca[1], _pos[0] + _sca[0], _pos[1] + _sca[1]);
    	
    	preview_surf = surface_verify(preview_surf, 128, 128);
    	surface_set_target(preview_surf);
    		DRAW_CLEAR
    		
    		var ox, x0;
		    var oy, y0;
		    var nx, ny;
		    var xx = _pos[0] - _sca[0];
		    var yy = _pos[1] - _sca[1];
		    var ww = _sca[0] * 2;
		    var hh = _sca[1] * 2;
		    draw_set_color(COLORS._main_accent);
		    
		    if(array_length(_pth.points)) {
			    for( var i = 0, n = array_length(_pth.points); i < n; i++ ) {
			        nx = 4 + (_pth.points[i][0] - xx) / ww * 120;
			        ny = 4 + (_pth.points[i][1] - yy) / hh * 120;
			        
		            if(i) draw_line_width(ox, oy, nx, ny, 8);
		            else  { x0 = nx; y0 = ny; }
			        
			        ox = nx;
			        oy = ny;
			    }
			    
			    if(_pth.loop) draw_line_width(ox, oy, x0, y0, 8);
		    }
    	surface_reset_target();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_surface_bbox(preview_surf, bbox);
	}
	
	static getPreviewBoundingBox = function() { 
		var _pth = outputs[0].getValue();
		return is_path(_pth)? BBOX().fromBoundingBox(_pth.boundary) : BBOX().fromWH(0, 0, DEF_SURF_W, DEF_SURF_H); 
	}
}

global.node_path_shape_keys_195 = [ 
        "Rectangle", "Trapezoid", "Parallelogram",
    -1, "Ellipse", "Arc", "Squircle", 
    -1, "Polygon", "Star", 
    -1, "Line", "Curve", "Spiral", "Spiral Circle",
];
