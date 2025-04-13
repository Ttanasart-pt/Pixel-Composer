function Node_Strand_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name      = "Strand Render";
	color     = COLORS.node_blend_strand;
	icon      = THEME.strandSim;
	
	inline_output        = false;
	manual_ungroupable	 = false;
	
	newInput(6, nodeValueSeed(self));
	newInput(8, nodeValue_Int("Update Step", self, 4));
	
	////- Output
	
	newInput(0, nodeValue_Dimension(self));
	
	////- Strand
	
	newInput(1, nodeValue(       "Strand",                self, CONNECT_TYPE.input, VALUE_TYPE.strands, noone)).setVisible(true, true);
	newInput(2, nodeValue_Range( "Thickness",             self, [ 1, 1 ], { linked : true }));
	newInput(3, nodeValue_Curve( "Thickness over length", self, CURVE_DEF_11));
	
	////- Scatter
	
	newInput( 9, nodeValue_Bool(  "Use Scatter",          self, false));
	newInput( 7, nodeValue_Float( "Children Count",       self, 0, "Render extra strands between the real strands."));
	newInput(10, nodeValue_Float( "Scatter Range",        self, 2));
	
	////- Color
	
	newInput(4, nodeValue_Gradient( "Random color",       self, new gradientObject(ca_white)));
	newInput(5, nodeValue_Gradient( "Color over length",  self, new gradientObject(ca_white)));
	
	//// inputs 11
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 6, 8, 
		["Output",   false   ], 0,
		["Strand",   false   ], 1, 2, 3, 
		["Scatter",  false, 9], 7, 10, 
		["Color",    false   ], 4, 5, 
	];
	
	attributes.use_cache   = false;
	attributes.show_strand = true;
	
	array_push(attributeEditors, [ "Cache", function() /*=>*/ {return attributes.use_cache}, new checkBox(function() /*=>*/ { attributes.use_cache = !attributes.use_cache; }) ]);
	
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, [ "Draw Strand", function() /*=>*/ {return attributes.show_strand}, new checkBox(function() /*=>*/ { attributes.show_strand = !attributes.show_strand; }) ]);
	
	setTrigger(2, "Clear cache", [ THEME.cache, 0, COLORS._main_icon ]);
	
	static onInspector2Update = function() /*=>*/ {return clearCache()};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!attributes.show_strand) return;
		
		var _strd = getInputData(1);
		if(_strd == noone) return;
		if(!is_array(_strd)) _strd = [ _strd ];
		
		for( var i = 0, n = array_length(_strd); i < n; i++ )
			_strd[i].draw(_x, _y, _s);
	}
	
	static step = function() {
		use_cache = attributes.use_cache? CACHE_USE.auto : CACHE_USE.none;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _seed       = getInputData(6);
		var _renderStep = getInputData(8);
		
		var _dim = getInputData(0);
		
		var _strd = getInputData(1);
		var _tbas = getInputData(2);
		var _tlen = getInputData(3);
		
		var _chUse = getInputData( 9);
		var _chid  = getInputData( 7);
		var _chRng = getInputData(10);
		
		var _cbas = getInputData(4);
		var _clen = getInputData(5);
		
		var _surf = outputs[0].getValue();
		    _surf = surface_verify(_surf, _dim[0], _dim[1]);
		outputs[0].setValue(_surf);
		
		if(_strd == noone) return;
		if(!is_array(_strd)) _strd = [ _strd ];
		
		random_set_seed(_seed);
		var _sedIndex = 0;
		
		surface_set_target(_surf);
		DRAW_CLEAR
		
		var ox, nx; 
		var oy, ny; 
		var ot, nt;
		var oc, nc;
		
		if(!_chUse) _chid = 0;
		
		for( var h = 0, m = array_length(_strd); h < m; h++ ) {
			var _strand = _strd[h];
			var hairs   = _strand.hairs;
			
			if(_renderStep) _strand.step(_renderStep);
			
			for( var i = 0, n = array_length(hairs); i < n; i++ ) {
				var hair = hairs[i];
				
				var len = array_length(hair.points);
				if(len <= 1) continue;
				
				var bld = _cbas.eval(random1D(_seed + _sedIndex++));
				var st  = 1 / (len - 1);
				var j   = 0;
				var prg = 0;
				
				repeat(len) {
					nx  = hair.points[j].x;
					ny  = hair.points[j].y;
					
					nt  = eval_curve_x(_tlen, prg);
					nt *= random1D(_seed + _sedIndex++, _tbas[0], _tbas[1]);
					
					nc  = _clen.eval(prg);
					nc  = colorMultiply(bld, nc);
					
					if(j) {
						draw_line_width2(ox, oy, nx, ny, ot, nt, 3, oc, nc);
						
						repeat(_chid) {
							var ofx = random_range(-_chRng, _chRng);
							var ofy = random_range(-_chRng, _chRng);
							
							draw_line_width2(ox + ofx, oy + ofy, nx + ofx, ny + ofy, ot, nt, 3, oc, nc);
						}
					}
					
					ox = nx;
					oy = ny;
					ot = nt;
					oc = nc;
					prg += st;
					j++;
				}
				
			}
		}
		surface_reset_target();
		
		if(attributes.use_cache) cacheCurrentFrame(_surf);
	}
}