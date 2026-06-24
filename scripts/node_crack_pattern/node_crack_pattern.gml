function Node_Crack_Pattern(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Crack Pattern";
	
	newInput( 2, nodeValueSeed());
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	
	////- =Origin
	newInput( 1, nodeValue_EButton(  "Pattern",        1, [ "Anisotropic", "Circular" ]));
	newInput( 3, nodeValue_Int(      "Amount",         5      ));
	newInput( 5, nodeValue_Vec2(     "Origin",       [.5,.5]  )).setUnitSimple();
	newInput(16, nodeValue_Rotation( "Pattern Angle",  0      ));
	newInput(21, nodeValue_RotRange( "Angle Range",   [0,360] ));
	
	////- =Pattern
	newInput( 4, nodeValue_Range(    "Segments",    [ 3, 6] ));
	newInput(11, nodeValue_Range(    "Scale",       [.5, 1] ));
	newInput( 6, nodeValue_Range(    "Length",      [ 8,10] ));
	newInput(15, nodeValue_Float(    "Length Scale",  1.1   ));
	
	////- =Crack
	newInput( 7, nodeValue_Range(    "Width",   [ 4, 8] )).setCurvable(17, CURVE_DEF_10);
	newInput( 8, nodeValue_Slider(   "Branch",  .25    ));
	newInput(12, nodeValue_RotRange( "Angle",   [15,45] ));
	newInput(22, nodeValue_Slider(   "Inter Crack", 0   )).setCurvable(23, CURVE_DEF_10);
	
	////- =Trim
	newInput(18, nodeValue_Slider(   "Trim",      0     ));
	
	////- =Thickness
	newInput(10, nodeValue_Range(    "Thickness",    [4,4], true    )).setCurvable(14, CURVE_DEF_10);
	
	////- =Rendering
	newInput(20, nodeValue_EButton(  "Blend Mode",    0, [ "Nornal", "Addtive", "Maximum" ]));
	newInput( 9, nodeValue_Gradient( "Color",        gra_white      ));
	newInput(13, nodeValue_Color(    "Branch Blend", cola(c_ltgray) ));
	newInput(19, nodeValue_Surface(  "Texture"                      ));
	// 24
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 2, 
		[ "Output",     true ],  0, 
		[ "Origin",    false ],  1,  3,  5, 16, 21, 
		[ "Pattern",   false ],  4, 11,  6, 15, 
		[ "Crack",     false ],  7, 17,  8, 12, 22, 23, 
		[ "Trim",       true ], 18, 
		[ "Thickness", false ], 10, 14,  
		[ "Rendering", false ], 20,  9, 13, 19, 
	];
	
	////- Nodes
	
	scaRange = [.5,1];
	lenScale = 1;
	crkAngle = [0,0];
	crkBlend = ca_white;
	texture  = -1;
	
	globalTrim = 1;
	
	widthCurve     = undefined;
	thicknessCurve = undefined;
	
	interConnect   = [];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _patt = getInputSingle( 1);
		if(_patt == 1) drawOverlayInput(inputs[5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
	}
	
	function drawCrack(_seed, _x, _y, _dir, _ang, _len, _crks, _thk, _segs, _crkChn, _clr, _depth = 0, _range = [0,1]) {
		if(_thk <= 1) return;
		
		random_set_seed(_seed);
		
		var ox = _x, nx = _x, fx;
		var oy = _y, ny = _y, fy;
		var ot = _thk;
		var nt = _thk;
		var oa = _ang;
		var na = _ang;
		var fa = _ang;
		
		var sca = random_range(scaRange[0], scaRange[1]);
		var seg = irandom_range(_segs[0], _segs[1]);
		var dir = _dir;
		
		var ang = _ang;
		var len = sca * _len;
		var crk = [_crks[0] * sca, _crks[1] * sca];
		
		var rSt = _range[0];
		var rEd = _range[1];
		var trimR = rEd == rSt? 1 : seg * (globalTrim - rSt) / (rEd - rSt);
		
		var rangeO = _range[0];
		var rangeN = _range[1];
		
		for( var i = 0; i < seg; i++ ) {
			var prg  = (i + 1) / seg;
			
			rangeN   = lerp(rSt, rEd, prg);
			var trmR = clamp((globalTrim - rangeO) / (rangeN - rangeO), 0, 1);
			var cPrg = (i + 1) / trimR;
			
			var crkInf = widthCurve? widthCurve.get(cPrg) : 1;
			
			if(i == 0) {
				var crkSiz = random_range(crk[0], crk[1]) * dir * crkInf;
				nx  = ox + (lengthdir_x(len, ang) + lengthdir_x(crkSiz, ang + 90)) * trmR;
				ny  = oy + (lengthdir_y(len, ang) + lengthdir_y(crkSiz, ang + 90)) * trmR;
				dir *= -1;
			} 
			
			var crkSiz = random_range(crk[0], crk[1]) * dir * crkInf;
			fx  = nx + (lengthdir_x(len, ang) + lengthdir_x(crkSiz, ang + 90)) * trmR;
			fy  = ny + (lengthdir_y(len, ang) + lengthdir_y(crkSiz, ang + 90)) * trmR;
			
			na  = point_direction(ox, oy, nx, ny);
			fa  = point_direction(nx, ny, fx, fy);
			
			na = na + angle_difference(fa, na) * .5;
			
			len *= lenScale;
			dir *= -1;
			
			nt = _thk * (thicknessCurve? thicknessCurve.get(cPrg) : 1);
			nt = max(1, nt);
			
			if(trmR > 0) {
				var doa = oa + 90;
				var dna = na + 90;
				
				draw_primitive_begin_texture(pr_trianglelist, texture);
				draw_line_width2_angle(ox, oy, nx, ny, ot, nt, doa, dna, _clr, _clr);
				draw_primitive_end();
			}
			
			if(_depth == 0) {
				var _intArr = array_safe_get(interConnect, i);
				if(!is_array(_intArr)) _intArr = [];
				
				array_push(_intArr, [nx, ny, nt, _clr]);
				interConnect[i] = _intArr;
			}
			
			var _crkChan = _crkChn * (1 - prg);
			if(random(1) < _crkChan) {
				var crAng = na + sign(angle_difference(na, _ang)) * random_range(crkAngle[0], crkAngle[1]);
				var crLen = _len * .75;
				var crCrk = [_crks[0] * .75, _crks[1] * .75];
				var crThk = nt;
				var crSeg = [_segs[0] - 1, _segs[1] - 1];
				var crChn = _crkChn * .5;
				var crClr = colorMultiply(_clr, crkBlend);
				
				var crRange = [rangeN,_range[1]];
				
				drawCrack(_seed + i * 100, nx, ny, -dir, crAng, crLen, crCrk, crThk, crSeg, crChn, crClr, _depth + 1, crRange);
			}
			
			rangeO = rangeN;
			
			ox = nx;
			oy = ny;
			
			nx = fx;
			ny = fy;

			oa = na;
			ot = nt;
		}
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _seed  = _data[ 2];
			
			var _dim   = _data[ 0];
			
			var _patt  = _data[ 1];
			var _amou  = _data[ 3];
			var _orig  = _data[ 5];
			var _phas  = _data[16];
			var _arng  = _data[21];
			
			var _segs  = _data[ 4];
			scaRange   = _data[11];
			var _lens  = _data[ 6];
			lenScale   = _data[15];
			
			var _crck  = _data[ 7];
			var _widCr = _data[17], _widC = inputs[ 7].attributes.curved? new curveMap(_widCr) : undefined;
			var _chan  = _data[ 8];
			crkAngle   = _data[12];
			var _intc  = _data[22];
			var _intCr = _data[23], _intC = inputs[22].attributes.curved? new curveMap(_intCr) : undefined;
			
			globalTrim = 1 - _data[18];
			
			var _blnd  = _data[20];
			var _colr  = _data[ 9];
			var _thck  = _data[10];
			var _thkCr = _data[14], _thkC = inputs[10].attributes.curved? new curveMap(_thkCr) : undefined;
			crkBlend   = _data[13];
			var _surf  = _data[19];
			
			inputs[ 5].setVisible(_patt == 1);
			inputs[16].setVisible(_patt == 1);
			inputs[21].setVisible(_patt == 1);
			
			texture = is_just_surface(_surf)? surface_get_texture(_surf) : -1;
			widthCurve     = _widC;
			thicknessCurve = _thkC;
			random_set_seed(_seed);
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		interConnect = [];
		
		surface_set_shader(_outSurf, noone);
			draw_set_color(c_white);
			
			switch(_blnd) {
				case 0 : BLEND_NORMAL; break;
				case 1 : BLEND_ADD;    break;
				case 2 : BLEND_MAX;    break;
			}
			
			if(_patt == 0) {
				for( var i = 0; i < _amou; i++ ) {
					var ox   = 0;
					var oy   = _dim[1] * i / (_amou - 1);
					var ang  = 0;
					
					var len  = random_range(_lens[0], _lens[1]);
					var thk  = random_range(_thck[0], _thck[1]);
					var clr  = _colr.eval(random(1));
					
					var dir  = choose(-1,1); 
					
					_seed += pi * 100;
					drawCrack(_seed, ox, oy, dir, ang, len, _crck, thk, _segs, _chan, clr);
				}
					
			} else if(_patt == 1) {
				for( var i = 0; i < _amou; i++ ) {
					var ox   = _orig[0];
					var oy   = _orig[1];
					var ang  = _phas + lerp(_arng[0], _arng[1], i / _amou);
					
					var len  = random_range(_lens[0], _lens[1]);
					var thk  = random_range(_thck[0], _thck[1]);
					var clr  = _colr.eval(random(1));
					
					var dir  = choose(-1,1); 
					
					_seed += pi * 100;
					drawCrack(_seed, ox, oy, dir, ang, len, _crck, thk, _segs, _chan, clr);
				}
				
			}
			
			for( var i = 0, n = array_length(interConnect); i < n; i++ ) {
				var _intArr = interConnect[i];
				var _chan   = _intc * (_intC? _intC.get(i/max(1,n-1)) : 1);
				
				for( var j = 1, m = array_length(_intArr); j < m; j++ ) {
					var op = _intArr[(j-1+m)%m];
					var np = _intArr[(j  +m)%m];
					
					if(random(1) >= _chan) continue;
					
					var ox = op[0];
					var oy = op[1];
					var ot = op[2];
					var oc = op[3];
					
					var nx = np[0];
					var ny = np[1];
					var nt = np[2];
					var nc = np[3];
					
					var dir = point_direction(ox, oy, nx, ny);
					
					draw_primitive_begin_texture(pr_trianglelist, texture);
					draw_line_width2_angle(ox, oy, nx, ny, ot, nt, dir + 90, dir + 90, oc, nc);
					draw_primitive_end();
				}
			}
		surface_reset_shader();
		
		return _outSurf; 
	}
}