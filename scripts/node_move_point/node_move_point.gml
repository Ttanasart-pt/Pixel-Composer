function Node_Move_Point(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Transform Point";
	color = COLORS.node_blend_number;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 5, nodeValue_Seed());
	
	////- =Points
	newInput( 0, nodeValue_Vec2( "Point",  [ 0, 0] )).setVisible(true, true);
	newInput( 1, nodeValue_Vec2( "Anchor", [.5,.5] )).setUnitSimple();
	
	////- =Position
	newInput( 2, nodeValue_Range2(  "Position", [0,0,0,0], true )).setUnitSimple(false).setMappableConst(6);
	
	////- =Rotation
	newInput( 3, nodeValue_RotRand( "Rotation",  ROTRAN_DEF_0   ));
	
	////- =Scale
	newInput( 4, nodeValue_Range2(  "Scale",    [1,1,1,1], true ));
	// 7
	
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.float, [ 0, 0 ])).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 5, 
		[ "Points",   false ],  0,  1, 
		[ "Position", false ],  2,  6, 
		[ "Rotation", false ],  3, 
		[ "Scale",    false ],  4, 
	];
	
	////- Node
	
	sampPos = new Surface_Sampler_Grey();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _anc = getInputData(1);
		var _px  = _x + _anc[0] * _s;
		var _py  = _y + _anc[1] * _s;
		
		drawOverlayInput(inputs[2].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my    ));
		drawOverlayInput(inputs[1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, 1 ));
		drawOverlayInput(inputs[3].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my    ));
		
		return w_hovering;
	}
	
	static update = function() {
		#region data
			var _seed = getInputData( 5);
			
			var _pnts = getInputData( 0);
			var _anc  = getInputData( 1);
			
			var _pos  = getInputData( 2);
			var _posS = getInputData( 6), posSamp = inputs[ 2].attributes.mapped? sampPos.setSurface(_posS) : undefined;
			
			var _rot  = getInputData( 3);
			
			var _sca  = getInputData( 4);
		#endregion
		
		var _d = array_get_depth(_pnts);
		if(_d != 2) return;
		
		var pAmo = array_length(_pnts);
		var pOut = outputs[0].getValue();
		    pOut = array_verify(pOut, pAmo);
		
		outputs[0].setValue(pOut);
		outputs[0].setTypeSignature(array_create(pAmo, VALUE_TYPE.float));
		
		random_set_seed(_seed);
		for( var i = 0; i < pAmo; i++ ) {
			var _px  = _pnts[i][0];
			var _py  = _pnts[i][1];
			var _pnt = [_px,_py];
			pOut[i]  = _pnt;
			
			var _posFac = posSamp? posSamp.getPixelDirectClamp(round(_px), round(_py)) : 1;
			
			var _psx = random_range(_pos[0], _pos[1]) * _posFac;
			var _psy = random_range(_pos[2], _pos[3]) * _posFac;
			
			var _ang = rotation_random_eval(_rot);
			
			var _scx = random_range(_sca[0], _sca[1]);
			var _scy = random_range(_sca[2], _sca[3]);
			
			point_rotate_array(_pnt, _anc, _ang);
			_pnt[0]  = _anc[0] + (_pnt[0] - _anc[0]) * _scx;
			_pnt[1]  = _anc[1] + (_pnt[1] - _anc[1]) * _scy;
			
			_pnt[0] += _psx;
			_pnt[1] += _psy;
		}
		
	}
}