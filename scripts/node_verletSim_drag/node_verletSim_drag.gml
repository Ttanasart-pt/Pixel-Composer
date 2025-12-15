function Node_VerletSim_Drag(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Drag Mesh";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	update_on_frame = true;
	setDrawIcon(s_node_verletsim_drag);
	setDimension(96, 48);
	
	newActiveInput(1);
	newInput(0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	////- =Anchor
	newInput(3, nodeValue_Bool( "Auto Anchor",  true ));
	newInput(4, nodeValue_Vec2( "Anchor",      [0,0] ));
	
	////- =Transform
	newInput(2, nodeValue_Vec2(     "Drag",    [0,0] )).setUnitSimple();
	newInput(5, nodeValue_Rotation( "Rotation", 0    ));
	// input 6
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 1, 0, 
		[ "Anchor",    false ], 3, 4, 
		[ "Transform", false ], 2, 5, 
	];
	
	prev_x = 0;
	prev_y = 0;
	prev_a = 0;
	
	move_x = 0;
	move_y = 0;
	
	draw_x = 0;
	draw_y = 0;
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _msh = getInputData(0);
		
		if(is(_msh, Mesh)) {
			draw_set_color(COLORS._main_icon);
			_msh.draw(_x, _y, _s);
		}
		
		var _pos  = getInputData(2);
		var _aAnc = getInputData(3);
		var _anc  = getInputData(4);
		
		var _dx = _aAnc? draw_x : _anc[0];
		var _dy = _aAnc? draw_y : _anc[1];
		
		var _ox = _x + _dx * _s;
		var _oy = _y + _dy * _s;
		
		var _px = _ox + _pos[0] * _s;
		var _py = _oy + _pos[1] * _s;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _ox, _oy, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
		
		if(!_aAnc) InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, 1));
		
		return w_hovering;
	}
	
	static update = function() {
		var _active = getInputData(1);
		var _mesh   = getInputData(0);
		
		var _aAnc   = getInputData(3);
		var _anc    = getInputData(4);
		
		var _drag   = getInputData(2);
		var _rota   = getInputData(5);
		
		outputs[0].setValue(_mesh);
		
		if(!_active) return;
		if(!is(_mesh, __verlet_Mesh)) {
			draw_x = 0;
			draw_y = 0;
			return;
		}
		
		var _dx = _drag[0];
		var _dy = _drag[1];
		var _da = _rota;
		
		if(IS_FIRST_FRAME) {
			_dx = _drag[0];
			_dy = _drag[1];
			
			var _cenx = 0;
			var _ceny = 0;
			var _cena = 0;
			
			for( var i = 0, n = array_length(_mesh.points); i < n; i++ ) {
				var  p  = _mesh.points[i];
				if(!is(p, __vec2)) continue;
				
				if(p.pin) {
					_cenx += p.x;
					_ceny += p.y;
					_cena++;
				}
				
				p.x += _dx;
				p.y += _dy;
			}
			
			move_x = 0;
			move_y = 0;
			
			draw_x = _cenx / _cena;
			draw_y = _ceny / _cena;
			
			var _ax = _aAnc? draw_x : _anc[0];
			var _ay = _aAnc? draw_y : _anc[1];
			
			if(_da != 0)
			for( var i = 0, n = array_length(_mesh.points); i < n; i++ ) {
				var  p  = _mesh.points[i];
				if(!is(p, __vec2)) continue;
				
				var dis = point_distance(  _ax, _ay, p.x, p.y );
				var dir = point_direction( _ax, _ay, p.x, p.y );
				
				p.x = _ax + lengthdir_x(dis, dir + _da);
				p.y = _ay + lengthdir_y(dis, dir + _da);
			}
			
			array_foreach(_mesh.points, function(p) /*=>*/ { p.px = p.x; p.py = p.y; });
			
		} else {
			_dx = _drag[0] - prev_x;
			_dy = _drag[1] - prev_y;
			_da = _rota    - prev_a;
			
			move_x += _dx;
			move_y += _dy;
			
			var _ax = move_x + (_aAnc? draw_x : _anc[0]);
			var _ay = move_y + (_aAnc? draw_y : _anc[1]);
			
			for( var i = 0, n = array_length(_mesh.points); i < n; i++ ) {
				var  p  = _mesh.points[i];
				if(!is(p, __vec2) || !p.pin) continue;
				
				p.x += _dx;
				p.y += _dy;
				
				if(_da == 0) continue;
				
				var dis = point_distance(  _ax, _ay, p.x, p.y );
				var dir = point_direction( _ax, _ay, p.x, p.y );
				
				p.x = _ax + lengthdir_x(dis, dir + _da);
				p.y = _ay + lengthdir_y(dis, dir + _da);
			}
			
		}
		
		prev_x = _drag[0];
		prev_y = _drag[1];
		prev_a = _rota;
	}
	
}
