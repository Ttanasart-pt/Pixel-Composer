function Node_Random(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Random";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	inputs   = array_create(22);
	distList = [ "Uniform", "Gaussian", "Bernoulli (True/False)", "Binomial", "Custom" ];
	
	////- =Random
	newInput( 0, nodeValueSeed(VALUE_TYPE.integer));
	newInput( 9, nodeValue_EScroll( "Distribution",    0, distList  ));
	newInput(10, nodeValue_Curve(   "Dist. Curve",     CURVE_DEF_11 )).setAnimable(false);
	newInput( 1, nodeValue_Float(   "From",            0            ));
	newInput( 2, nodeValue_Float(   "To",              1            ));
	newInput(11, nodeValue_Float(   "Mean",            0            ));
	newInput(12, nodeValue_Float(   "Variance",        1            ));
	newInput(13, nodeValue_Slider(  "p",              .5            ));
	newInput(14, nodeValue_Float(   "t",               1            ));
	newInput(22, nodeValue_Bool(    "Deterministic",   true         ));
	
	////- =Shuffle
	newInput( 3, nodeValue_Bool(    "Shuffle",         false        ));
	newInput( 4, nodeValue_EScroll( "Mode", 0, [ "Per Frame", "Periordic", "Trigger", "Probabilistic", "Accumulative", "Per Animation" ]));
	newInput( 5, nodeValue_Int(     "Period",          1            ));
	newInput( 6, nodeValue_Int(     "Period Shift",    0            ));
	newInput( 7, nodeValue_Trigger( "Trigger"                       ));
	newInput( 8, nodeValue_Slider(  "Probability",     1            ));
	newInput(20, nodeValue_Float(   "Average Period",  4            ));
	newInput(21, nodeValue_Float(   "Period Variance", 2            ));
	
	////- =Smooth
	newInput(15, nodeValue_EScroll( "Smoothing",       0, [ "None", "Moving Average", "Convolution", "Lerp" ] ));
	newInput(16, nodeValue_Int(     "Window Size",     5            ));
	newInput(17, nodeValue_Int(     "Kernel Span",     3            ));
	newInput(18, nodeValue_Curve(   "Kernel",          CURVE_DEF_11 ));
	newInput(19, nodeValue_Slider(  "Lerp Ratio",     .5            ));
	
	// inputs 23
	
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.float, 0));
	
	input_display_list = [ 
		["Random",  false   ], 0, 9, 10, 1, 2, 11, 12, 13, 14, 22, 
		["Shuffle", false, 3], 4, 5, 6, 7, 8, 20, 21, 
		["Smooth",  false   ], 15, 16, 17, 18, 19, 
	];
	
	////- Nodes
	
	accPool    = [];
	seed       = [];
	moving_Avg = [];
	kernels    = [[]];
	
	distCurveCMF = {
		curve : [],
		cmf   : {},
	};
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var _seed    = _data[ 0];
			var _distTyp = _data[ 9];
			var _distCrv = _data[10];
			var _from    = _data[ 1];
			var _to      = _data[ 2];
			var _mean    = _data[11];
			var _var     = _data[12];
			var _p       = _data[13];
			var _t       = _data[14];
			
			var _shuffle = _data[ 3];
			var _shfMode = _data[ 4];
			var _shfPer  = _data[ 5];
			var _shfSft  = _data[ 6];
			var _shfTrig = _data[ 7];
			var _shfProb = _data[ 8];
			var _shfAcAg = _data[20];
			var _shfAcVa = _data[21];
			
			var _smtTyp  = _data[15];
			var _smtWin  = _data[16];
			var _smtKrs  = _data[17];
			var _smtKer  = _data[18];
			var _smtLrp  = _data[19];
			
			var _deter   = _data[22];
			
			update_on_frame = _shuffle;
			
			inputs[ 1].setVisible(_distTyp == 0 || _distTyp == 4);
			inputs[ 2].setVisible(_distTyp == 0 || _distTyp == 4);
			inputs[11].setVisible(_distTyp == 1);
			inputs[12].setVisible(_distTyp == 1);
			inputs[13].setVisible(_distTyp == 2 || _distTyp == 3);
			inputs[14].setVisible(_distTyp == 3);
			inputs[10].setVisible(_distTyp == 4);
			
			inputs[ 5].setVisible(_shfMode == 1);
			inputs[ 6].setVisible(_shfMode == 1);
			inputs[ 7].setVisible(_shfMode == 2);
			inputs[ 8].setVisible(_shfMode == 3);
			inputs[20].setVisible(_shfMode == 4);
			inputs[21].setVisible(_shfMode == 4);
			
			inputs[16].setVisible(_smtTyp == 1);
			inputs[17].setVisible(_smtTyp == 2);
			inputs[18].setVisible(_smtTyp == 2);
			inputs[19].setVisible(_smtTyp == 3);
		#endregion
			
		seed       = array_verify_min(seed,       _array_index);
		accPool    = array_verify_min(accPool,    _array_index);
		moving_Avg = array_verify_min(moving_Avg, _array_index);
			
		if(CURRENT_FRAME == 0 || !_shuffle) {
			if(!_deter) _seed += current_time % 100_000;
			
			seed[_array_index]       = _seed;
			accPool[_array_index]    = 0;
			moving_Avg[_array_index] = 0;
		}
		
		random_set_seed(seed[_array_index]);
		
		if(_shuffle) {
			var reshuffle = false;
			
			switch(_shfMode) {
				case 0 : reshuffle = true;                                     break;
				case 1 : reshuffle = (CURRENT_FRAME - _shfSft) % _shfPer == 0; break;
				case 2 : reshuffle = bool(_shfTrig);                           break;
				
				case 3 : 
					random_set_seed(seed[_array_index] + CURRENT_FRAME);
					if(random(1) <= _shfProb) reshuffle = true;
					break;
					
				case 4 : 
					random_set_seed(seed[_array_index] + CURRENT_FRAME);
					var _acfr = random_gaussian(_shfAcAg, _shfAcVa);
					if(_acfr > 0) accPool[_array_index] += 1 / _acfr;
					
					if(accPool[_array_index] > 1) reshuffle = true;
					accPool[_array_index] = frac(accPool[_array_index]);
					break;
					
				case 5 : reshuffle = IS_FIRST_FRAME; break;
			}
			
			if(reshuffle) {
				randomize();
				seed[_array_index] = seed_random();
			}
		}
		
		random_set_seed(seed[_array_index]);
		var _r;
		
		switch(_distTyp) {
			case 0 : _r = random_range(_from, _to);     break;
			case 1 : _r = random_gaussian(_mean, _var); break;
			case 2 : _r = random(1) <= _p;              break;
			
			case 3 : 
				_r = 0;
				repeat(_t) _r += random(1) <= _p;
				break;
				
			case 4 : 
				if(!array_equals(distCurveCMF.curve, _distCrv)) {
					distCurveCMF.curve = _distCrv;
					distCurveCMF.cmf   = eval_curve_cmf(_distCrv);
				}
				
				var _len = array_length(distCurveCMF.cmf) - 1;
				var _st = 0;
				var _ed = _len;
				var _cr = random(1);
				
				while(_ed - _st > 1) {
					if(distCurveCMF.cmf[_st] == _cr) break;
					if(distCurveCMF.cmf[_ed] == _cr) break;
					
					var _m = round(_st + _ed) / 2;
					if(distCurveCMF.cmf[_m] > _cr) _ed = _m;
					else _st = _m;
				}
				
				var _ast = lerp(_st, _ed, (_cr - distCurveCMF.cmf[_st]) / (distCurveCMF.cmf[_ed] - distCurveCMF.cmf[_st]));
				_r = lerp(_from, _to, _ast / _len);
				break;
		}
		
		var _res = _r;
		
		switch(_smtTyp) {
			case 0 : break;
			
			case 1 : 
				var _moving_Avg  = moving_Avg[_array_index] * clamp(CURRENT_FRAME, 0, _smtWin - 1) + _r;
				    
			    moving_Avg[_array_index] = _moving_Avg / clamp(CURRENT_FRAME + 1, 1, _smtWin);
			    _res = moving_Avg[_array_index];
			    break;
			    
		    case 2 : 
		    	kernels[_array_index] = array_verify(kernels[_array_index], TOTAL_FRAMES);
		    	
		    	var _k = kernels[_array_index];
	    	        _k[CURRENT_FRAME] = _r;
		    	
		    	if(_smtKrs <= 0) break;
		    	var _tot = 0;
		    	var _wei = 0;
		    	
		    	for( var i = -_smtKrs; i <= _smtKrs; i++ ) {
		    		var _fr  = CURRENT_FRAME + i;
		    		if(_fr < 0 || _fr >= TOTAL_FRAMES) continue;
		    		
		    		var _x   = abs(i) / _smtKrs;
		    		var _inf = eval_curve_x(_smtKer, _x);
		    		
		    		_tot += _inf * _k[_fr];
					_wei += _inf;
		    	}
		    	
		    	_res = _tot / _wei;
		    	break;
		    	
		    case 3 : _res = lerp(_output, _res, _smtLrp); break;
		}
		
		return _res;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = outputs[0].getValue();
		
		var bbox = draw_bbox;
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}