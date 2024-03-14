function Node_Strand_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Strand Render";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	use_cache = CACHE_USE.auto;
	
	manual_ungroupable	 = false;
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Strand", self, JUNCTION_CONNECT.input, VALUE_TYPE.strands, noone)
		.setVisible(true, true);
	
	inputs[| 2] = nodeValue("Thickness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 3] = nodeValue("Thickness over length", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	inputs[| 4] = nodeValue("Random color", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white));
	
	inputs[| 5] = nodeValue("Color over length", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white));
	
	inputs[| 6] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom_range(10000, 99999));
	
	inputs[| 7] = nodeValue("Child", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0, "Render extra strands between the real strands.");
	
	inputs[| 8] = nodeValue("Update quality", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 6, 8, 
		["Output",  false], 0,
		["Strand",  false], 7, 1, 2, 3, 
		["Color",   false], 4, 5, 
	];
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _str = getInputData(1);
		if(_str == noone) return;
		if(!is_array(_str)) _str = [ _str ];
		
		for( var i = 0, n = array_length(_str); i < n; i++ )
			_str[i].draw(_x, _y, _s);
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) {
		if(!PROJECT.animator.is_playing && recoverCache()) return;
			
		var _dim = getInputData(0);
		var _str = getInputData(1);
		var _thk = getInputData(2);
		var _tln = getInputData(3);
		var _bld = getInputData(4);
		var _col = getInputData(5);
		var _sed = getInputData(6);
		var _chd = getInputData(7);
		var _stp = getInputData(8);
		
		var _surf = outputs[| 0].getValue();
		_surf = surface_verify(_surf, _dim[0], _dim[1]);
		outputs[| 0].setValue(_surf);
		
		if(_str == noone) return;
		if(!is_array(_str)) _str = [ _str ];
		
		random_set_seed(_sed);
		var _sedIndex = 0;
		
		surface_set_target(_surf);
			DRAW_CLEAR
			var h0 = [], h1 = [];
			
			for( var h = 0; h < array_length(_str); h++ ) {
				var _strand = _str[h];
				var hairs   = _strand.hairs;
				
				if(_stp) _strand.step(_stp);
				
				for( var i = 0, n = array_length(hairs); i < n; i++ ) {
					var hair = hairs[i];
					var os, ns, ot, nt;
				
					var len = array_length(hair.points);
					var bld = _bld.eval(random1D(_sed + _sedIndex)); _sedIndex++;
					var clr = c_black;
				
					for( var j = 0; j < len; j++ ) {
						ns = hair.points[j];
						nt = eval_curve_x(_tln, j / (len - 1));
						nt *= random1D(_sed + _sedIndex, _thk[0], _thk[1]); _sedIndex++;
					
						if(j) {
							clr = _col.eval(j / (len - 1));
							clr = colorMultiply(bld, clr);
							draw_set_color(clr);
							draw_line_width2(os.x, os.y, ns.x, ns.y, ot, nt, 3);
						}
					
						ot = nt;
						os = ns;
					
						h1[j] = [ nt, clr ];
					}
				
					if(_chd && (i > 0 || _strand.loop)) {
						var hair0 = i == 0? hairs[array_length(hairs) - 1] : hairs[i - 1];
					
						for( var j = 1; j < _chd + 1; j++ ) {
							var lrp = j / (_chd + 1);
						
							var ox, oy, nx, ny, ot, nt, oc, nc;
							for( var k = 0; k < len; k++ ) {
								var nx0 = hair0.points[k].x;
								var ny0 = hair0.points[k].y;
							
								var nx1 = hair.points[k].x;
								var ny1 = hair.points[k].y;
							
								nx = lerp(nx0, nx1, lrp);
								ny = lerp(ny0, ny1, lrp);
							
								if(k) {
									ot = i == 0? h1[k][0] : h0[k][0];
									nt = h1[k][0];
							
									oc = i == 0? h1[k][1] : h0[k][1];
									nc = h1[k][1];
							
									draw_set_color(merge_color(oc, nc, lrp));
									draw_line_width2(ox, oy, nx, ny, ot, nt, 3);
								}
							
								ox = nx;
								oy = ny;
							}
						}
					}
				
					h0 = array_clone(h1);
				}
			}
		surface_reset_target();
		cacheCurrentFrame(_surf);
	}
}