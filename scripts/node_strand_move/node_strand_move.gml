function Node_Strand_Move(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Strand Move";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);
	setDrawIcon();
	
	manual_ungroupable	 = false;
	var i = input_fix_len;
	
	newInput( 0, nodeValue_Strand());
	
	////- =Move
	newInput( 1, nodeValue_Vec2( "Position", [0,0]   )).setUnitSimple();
	newInput( 2, nodeValue_Vec2( "Anchor",   [.5,.5] )).setUnitSimple();
	
	////- =Physics
	newInput( 3, nodeValue_Bool( "Jump",      true   ));
	// 4
	
	newOutput(0, nodeValue_Output("Strands", VALUE_TYPE.strands, noone));
	
	input_display_list = [ 0, 
		[ "Move",    false ],  1,  2, 
		[ "Physics", false ],  3,
	];
	
	////- Node
	
	px = 0;
	py = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _anc = getInputData( 2);
		var ax = _x + _anc[0] * _s;
		var ay = _y + _anc[1] * _s;
		
		drawOverlayInput(inputs[ 1].drawOverlay(w_hoverable, active, ax, ay, _s, _mx, _my));
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _str  = getInputData( 0);
			
			var _pos  = getInputData( 1);
			var _anc  = getInputData( 2);
			
			var _jump = getInputData( 3);
			
			if(_str == noone) return;
			
			outputs[0].setValue(_str);
		#endregion
		
		var __str = _str;
		var _setp = false;
		if(!is_array(_str)) __str = [ _str ];
		
		if(IS_FIRST_FRAME) {
			var dx = _pos[0]// - _anc[0];
			var dy = _pos[1]// - _anc[1];
			
			if(_jump)
				_setp = true;
			
		} else {
			var dx = _pos[0] - px;
			var dy = _pos[1] - py;
		}
		
		for( var k = 0; k < array_length(__str); k++ )
		for( var i = 0, n = array_length(__str[k].hairs); i < n; i++ ) {
			var h = __str[k].hairs[i];
			if(array_empty(h.points)) continue;
			
			if(_setp) {
				for( var j = 0, m = array_length(h.points); j < m; j++ ) {
					var p = h.points[j];
					p.x += dx;
					p.y += dy;
					
					p.px = p.x;
					p.py = p.y;
					
					p.dx = 0;
					p.dy = 0;
					
				}
				
			} else {
				var p = h.points[0];
				p.x += dx;
				p.y += dy;
				
			}
		}
		
		px = _pos[0];
		py = _pos[1];

	}
	
}