function Node_Path_Projectile(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Projectile Path";
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 4, nodeValueSeed());
	
	////- =Path
	newInput( 0, nodeValue_Int(   "Amount", 6 ));
	newInput( 1, nodeValue_Vec2(  "Origin", [.5,.5] )).setUnitSimple();
	newInput( 3, nodeValue_Range( "Length", [8,16]  ));
	
	////- =Direction
	newInput( 7, nodeValue_EButton(  "Distribution", 0, ["Random", "Uniform"] ));
	newInput( 2, nodeValue_RotRange( "Direction", [0,360] ));
	
	////- =Projectile
	newInput( 5, nodeValue_Range( "Height", [8,16]  ));
	newInput( 6, nodeValue_Vec2(  "Offset", [0,0]   )).setUnitSimple();
	// 8
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	input_display_list = [  4,  0, 
		[ "Path",       false ],  0,  1,  3,  
		[ "Direction",  false ],  7,  2, 
		[ "Projectile", false ],  5,  6, 
	];
	
	////- Nodes
	
	function _pathProjectile(_node) : Path(_node) constructor {
		amount  = 1;
		lengths	= [];
		direct	= [];
		height	= [];
		
		ofx = 0;
		ofy = 0;
		
		ox = 0; 
		oy = 0;
		
		static getLineCount		= function()  /*=>*/ {return amount};
		static getSegmentCount	= function()  /*=>*/ {return 1};
		static getBoundary		= function()  /*=>*/ {return boundary};
		static getLength		= function(i) /*=>*/ {return lengths[i]};
		static getAccuLength	= function(i) /*=>*/ {return [0,lengths[i]]};
		
		static getPointRatio    = function(_rat, _ind = 0, out = undefined) { 
		    out ??= new __vec2P();
		    
		    var len = lengths[_ind];
		    var dir = direct[_ind];
		    var hei = height[_ind]
		    
		    var hPrg = 1 - 4 * sqr(_rat - .5);
		    
		    var ix  = lengthdir_x(1, dir);
		    var iy  = lengthdir_y(1, dir);
		    
		    var px = ox;
		    var py = oy;
		    
		    px += _rat * len * ix;
		    py += _rat * len * iy;
		    
		    px += _rat * ofx;
		    py += _rat * ofy;
		    
		    py -= hPrg * hei;
		    
		    out.x = px;
		    out.y = py;
		    
	        return out;
		}
		
		static getPointDistance = function(_dist, _ind = 0, out = undefined) {
		    return getPointRatio(_dist / lengths[_ind], _ind, out);
		}
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _outPath = outputs[0].getValue();
		if(is(_outPath, Path)) _outPath.drawUI(_x, _y, _s);
		
		drawOverlayInput(inputs[ 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
	}
	
	static update = function() {
		#region data
			var _seed = getInputData( 4);
			
			var _amo  = getInputData( 0);
			var _ori  = getInputData( 1);
			var _len  = getInputData( 3);
			
			var _dist = getInputData( 7);
			var _dir  = getInputData( 2);
			
			var _hei  = getInputData( 5);
			var _off  = getInputData( 6);
		#endregion
		
		var _path = outputs[0].getValue();
		if(!is(_path, _pathProjectile)) 
			_path = new _pathProjectile();
		
		random_set_seed(_seed);
		var len = array_create(_amo);
		var ang = array_create(_amo);
		var hei = array_create(_amo);
		
		for( var i = 0; i < _amo; i++ ) {
			len[i] = random_range(_len[0], _len[1]);
			hei[i] = random_range(_hei[0], _hei[1]);
			
			if(_dist == 0) ang[i] = random_range(_dir[0], _dir[1]);
			else           ang[i] = lerp(_dir[0], _dir[1], i/_amo);
		}
		
		_path.amount  = _amo;
		_path.lengths =  len;
		_path.direct  =  ang;
		_path.height  =  hei;
		
		_path.ofx = _off[0];
		_path.ofy = _off[1];
		
		_path.ox  = _ori[0];
		_path.oy  = _ori[1];
		
		outputs[0].setValue(_path);
	}
}
