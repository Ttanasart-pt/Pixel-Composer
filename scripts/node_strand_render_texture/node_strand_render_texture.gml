function Node_Strand_Render_Texture(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Strand Render Texture";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	use_cache = CACHE_USE.auto;
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue("Strand", self, CONNECT_TYPE.input, VALUE_TYPE.strands, noone))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Range("Thickness", self, [ 8, 8 ], { linked : true }));
	
	newInput(3, nodeValue_Gradient("Random color", self, new gradientObject(cola(c_white))));
	
	newInput(4, nodeValue_Surface("Texture", self));
	
	newInput(5, nodeValueSeed(self));
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 5, 
		["Output",  false], 0,
		["Strand",  false], 1, 2,  
		["Texture", false], 4, 3, 
	];
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _str = getInputData(1);
		if(instanceof(_str) != "StrandMesh") return;
		
		_str.draw(_x, _y, _s);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(!PROJECT.animator.is_playing && recoverCache()) return;
			
		var _dim = getInputData(0);
		var _str = getInputData(1);
		
		var _thk = getInputData(2);
		var _bld = getInputData(3);
		var _tex = getInputData(4);
		var _sed = getInputData(5);
		
		var _surf = outputs[0].getValue();
		_surf = surface_verify(_surf, _dim[0], _dim[1]);
		outputs[0].setValue(_surf);
		
		if(_str == noone) 
			return;
		if(!is_array(_str)) 
			_str = [ _str ];
		if(inputs[4].value_from == noone) 
			return;
			
		if(!is_array(_tex)) _tex = [ _tex ];
		
		random_set_seed(_sed);
		var _sedIndex = 0;
		
		surface_set_target(_surf);
			DRAW_CLEAR
			
			for( var k = 0; k < array_length(_str); k++ ) {
				var hairs = _str[k].hairs;
				
				for( var i = 0, n = array_length(hairs); i < n; i++ ) {
					var hair = hairs[i];
					var ox0, oy0, ox1, oy1;
					var nx0, ny0, nx1, ny1;
				
					var len = array_length(hair.points);
					var bld = _bld.eval(random1D(_sed + _sedIndex)); _sedIndex++;
					var clr = c_black;
					var tt  = random1D(_sed + _sedIndex, _thk[0], _thk[1]); _sedIndex++;
					
					var txr = _tex[round(random1D(_sedIndex, 0, array_length(_tex) - 1))]; _sedIndex++;
					var tex = surface_get_texture(txr);
					draw_primitive_begin_texture(pr_trianglestrip, tex);
				
					for( var j = 0; j < len; j++ ) {
						var nn  = hair.points[j];
						var dir = j? point_direction(hair.points[j - 1].x, hair.points[j - 1].y, hair.points[j].x, hair.points[j].y) : 
									 point_direction(hair.points[j].x, hair.points[j].y, hair.points[j + 1].x, hair.points[j + 1].y);
					
						nx0 = nn.x + lengthdir_x(tt, dir + 90);
						ny0 = nn.y + lengthdir_y(tt, dir + 90);
						nx1 = nn.x + lengthdir_x(tt, dir - 90);
						ny1 = nn.y + lengthdir_y(tt, dir - 90);
					
						if(j) {
							draw_vertex_texture_color(ox0, oy0, 0, (j - 1) / (len - 1), bld, 1);
							draw_vertex_texture_color(ox1, oy1, 1, (j - 1) / (len - 1), bld, 1);
							draw_vertex_texture_color(nx0, ny0, 0, (j - 0) / (len - 1), bld, 1);
							draw_vertex_texture_color(nx1, ny1, 1, (j - 0) / (len - 1), bld, 1);
						}
					
						ox0 = nx0; oy0 = ny0;
						ox1 = nx1; oy1 = ny1;
					}
					draw_primitive_end();
				}
			}
		surface_reset_target();
		cacheCurrentFrame(_surf);
	}
}