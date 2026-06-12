/*
#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("", " > Set", KEY_GROUP.numeric, MOD_KEY.none, () => { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
		addHotkey("", " > ", "", MOD_KEY.none, () => { GRAPH_FOCUS _n.inputs[1].setValue(); });
		addHotkey("", " > Toggle", "", MOD_KEY.none, () => { GRAPH_FOCUS _n.inputs[1].setValue((_n.inputs[1].getValue() + 1) % 2); });
	});
#endregion
*/

function Node_Line_2Points(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Draw Line 2 Points";
	
	newInput( 1, nodeValueSeed());
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput(12, nodeValue_Surface( "BG Surface" ));
	
	////- =Points
	newInput( 2, nodeValue_Vec2( "Start Point",   [0,.5] )).setUnitSimple();
	newInput( 3, nodeValue_Vec2( "End Point",     [1,.5] )).setUnitSimple();
	
	////- =Line
	newInput( 4, nodeValue_Bool(    "1px Mode", false       )).setTooltip("Render pixel perfect 1px line.");
	newInput( 5, nodeValue_Range(   "Width",    [2,2], true )).setCurvable( 6, CURVE_DEF_11);
	newInput( 9, nodeValue_Toggle(  "Cap",      0, [ "Start", "End" ] ));
	newInput(11, nodeValue_Int(     "Segment",  1           ));
	
	////- =Rendering
	newInput(10, nodeValue_EScroll(  "Blend Mode", 0, [ "Normal", "Additive", "Maximum" ] ));
	
		////- =/Colors
	newInput( 7, nodeValue_Gradient( "Base Color",        gra_white ));
	newInput( 8, nodeValue_Gradient( "Color Over Length", gra_white ));
	
		////- =/Texture
	newInput(13, nodeValue_Surface(  "Texture" ));
	newInput(14, nodeValue_Vec2(     "UV Position", [0,0] ));
	newInput(15, nodeValue_Vec2(     "UV Scale",    [1,1] ));
	// 16
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  1,
		[ "Output",       false ],  0, 12, 
		[ "Points",       false ],  2,  3,  
		[ "Line",         false ],  4,  5,  6,  9, 11, 
		[ "Rendering",    false ], 10, 
			[ "/Colors",  false ],  7,  8, 
			[ "/Texture", false ], 13, 14, 15, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		InputDrawOverlay(inputs[ 2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		InputDrawOverlay(inputs[ 3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
	}
	
	static update = function() {
		#region data
			var _seed  = getInputData( 1);
			
			var _dim   = getInputData( 0);
			var _bgS   = getInputData(12);
			
			var _p0    = getInputData( 2);
			var _p1    = getInputData( 3);
			
			var _1px   = getInputData( 4);
			var _wid   = getInputData( 5);
			var _widC  = getInputData( 6), widthCurve = inputs[ 5].attributes.curved? new curveMap(_widC) : undefined;
			var _cap   = getInputData( 9);
			var _segs  = getInputData(11);
			
			var _blnd  = getInputData(10);
			var _cBase = getInputData( 7); _cBase.cache();
			var _cLen  = getInputData( 8); _cLen.cache();
			
			var _text  = getInputData(13);
			var _tpos  = getInputData(14);
			var _tsca  = getInputData(15);
			
			inputs[ 5].setVisible(!_1px);
		#endregion
		
		random_set_seed(_seed);
		
		var outSurf = outputs[0].getValue();
		    outSurf = surface_verify(outSurf, _dim[0], _dim[1], attrDepth());
		
		var d0 = array_get_depth(_p0);
		var d1 = array_get_depth(_p1);
		
		if(d0 > 2 || d1 > 2) return;
		
		if(d0 == 1) _p0 = [_p0];
		if(d1 == 1) _p1 = [_p1];
		
		var l0 = array_length(_p0);
		var l1 = array_length(_p1);
		var lineAmo = max(l0,l1);
		
		var _subSt = 1 / _segs;
		
		surface_set_shader(outSurf, _1px? noone : sh_draw_line_width);
			draw_surface_safe(_bgS);
			
			if(!_1px) {
				shader_set_2( "uvPosition", _tpos );
				shader_set_2( "uvScale",    _tsca );
				
				shader_set_i( "capStart",   bool(_cap & 0b01) );
				shader_set_i( "capEnd",     bool(_cap & 0b10) );
			}
			
			switch(_blnd) {
				case 0 : BLEND_NORMAL; break;
				case 1 : BLEND_ADD;    break;
				case 2 : BLEND_MAX;    break;
			}
			
			for( var i = 0; i < lineAmo; i++ ) {
				var i0 = i % l0;
				var i1 = i % l1;
				
				var p0 = _p0[i0];
				var p1 = _p1[i1];
				
				var _len = point_distance(p0[0], p0[1], p1[0], p1[1]);
				
				var baseColor = _cBase.evalFast(random(1));
				var _thk = random_range(_wid[0], _wid[1]);
				
				if(!_1px) {
					shader_set_f( "lineThickness", _thk );
					shader_set_f( "lineLength",    _len );
				}
				
				draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_text));
				for( var j = 0; j < _segs; j++ ) {
					var j0 = _subSt *  j;
					var j1 = _subSt * (j + 1);
					
					var c0 = colorMultiply(baseColor, _cLen.evalFast(j0));
					var c1 = colorMultiply(baseColor, _cLen.evalFast(j1));
					
					var p0x = lerp(p0[0], p1[0], j0);
					var p0y = lerp(p0[1], p1[1], j0);
					
					var p1x = lerp(p0[0], p1[0], j1);
					var p1y = lerp(p0[1], p1[1], j1);
					
					if(_1px) draw_line_color(p0x, p0y, p1x, p1y, c0, c1);
					else {
						var t0 = widthCurve? _thk * widthCurve.get(j0) : _thk;
						var t1 = widthCurve? _thk * widthCurve.get(j1) : _thk;
						
						draw_line_width2_prim(p0x, p0y, p1x, p1y, t0, t1, _cap, c0, c1);
					}
				}
				draw_primitive_end();
			}
			
		surface_reset_shader();
		
		outputs[0].setValue(outSurf);
	}
}
