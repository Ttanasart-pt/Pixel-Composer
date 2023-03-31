#region data
	global.EQUATION_PRES    = ds_map_create();
	global.EQUATION_PRES[? "+"]     = 1;
	global.EQUATION_PRES[? "-"]     = 1;
	global.EQUATION_PRES[? "*"]     = 2;
	global.EQUATION_PRES[? "/"]     = 2;
	global.EQUATION_PRES[? "^"]     = 3;
	global.EQUATION_PRES[? "sin"]   = 5;
	global.EQUATION_PRES[? "cos"]   = 5;
	global.EQUATION_PRES[? "tan"]   = 5;
	global.EQUATION_PRES[? "abs"]   = 5;
	global.EQUATION_PRES[? "round"] = 5;
	global.EQUATION_PRES[? "ceil"]  = 5;
	global.EQUATION_PRES[? "floor"] = 5;
#endregion

#region evaluator
	function evaluateFunction(fx, params = {}) {
		var pres = global.EQUATION_PRES;
		var vl   = ds_stack_create();
		var op   = ds_stack_create();
		
		fx = string_replace_all(fx,  " ", "");
		fx = string_replace_all(fx, "\n", "");
		
		var len = string_length(fx);
		var l   = 1;
		var ch, cch;
		
		while(l <= len) {
			ch = string_char_at(fx, l);
			
			if(ds_map_exists(pres, ch)) {
				if(ds_stack_empty(op)) ds_stack_push(op, ch);
				else {
					if(pres[? ch] > pres[? ds_stack_top(op)] || ds_stack_top(op) == "(") ds_stack_push(op, ch);
					else {
						while(pres[? ch] <= pres[? ds_stack_top(op)] && !ds_stack_empty(op)) {
							ds_stack_push(vl, evalToken(ds_stack_pop(op), vl));
						}
						ds_stack_push(op, ch);
					}
				}
				
				l++;
			} else if (ch == "(") {
				ds_stack_push(op, ch);
				l++;
			} else if (ch == ")") {
				while(ds_stack_top(op) != "(" && !ds_stack_empty(op)) {
					ds_stack_push(vl, evalToken(ds_stack_pop(op), vl));
				}
				ds_stack_pop(op);
				l++;
			} else {
				var vsl = "";
				
				while(l <= len) {
					cch = string_char_at(fx, l);
					if(ds_map_exists(pres, cch) || cch == ")" || cch == "(") break;
					
					vsl += cch;
					l++;
				}
				
				if(vsl == "") continue;
				
				if(ds_map_exists(pres, vsl)) {
					ds_stack_push(op, vsl);
				} else {
					switch(vsl) {
						case "e":  ds_stack_push(vl, 2.71828); break;
						case "pi": ds_stack_push(vl, pi); break;
						
						default :  
							if(variable_struct_exists(params, vsl)) 
								ds_stack_push(vl, variable_struct_get(params, vsl));
							else 
								ds_stack_push(vl, toNumber(vsl));
						break;
					}
				}
			}
		}
		
		while(!ds_stack_empty(op)) {
			ds_stack_push(vl, evalToken(ds_stack_pop(op), vl));
		}
		ds_stack_destroy(op);
		
		return ds_stack_empty(vl)? 0 : ds_stack_pop(vl);
	}
	
	function evalToken(operator, vl) {
		if(ds_stack_empty(vl)) return 0;
		switch(operator) {
			case "+": 
				if(ds_stack_size(vl) >= 2)
					return ds_stack_pop(vl) + ds_stack_pop(vl);	
			case "-": 
				if(ds_stack_size(vl) >= 2)
					return -ds_stack_pop(vl) + ds_stack_pop(vl);
				else
					return -ds_stack_pop(vl);
			case "*": 
				if(ds_stack_size(vl) >= 2) 
					return ds_stack_pop(vl) * ds_stack_pop(vl);	
			case "^": 
				if(ds_stack_size(vl) < 2) return 1;
				var ex = ds_stack_pop(vl);
				var bs = ds_stack_pop(vl);
				return power(bs, ex);
			case "/": 
				if(ds_stack_size(vl) < 2) return 0;
				var _d = ds_stack_pop(vl);
				if(_d == 0) return 0;
				return ds_stack_pop(vl) / _d;
			
			case "sin"   : if(ds_stack_size(vl) >= 1) return sin(ds_stack_pop(vl));
			case "cos"   : if(ds_stack_size(vl) >= 1) return cos(ds_stack_pop(vl));
			case "tan"   : if(ds_stack_size(vl) >= 1) return tan(ds_stack_pop(vl));
			case "abs"	 : if(ds_stack_size(vl) >= 1) return abs(ds_stack_pop(vl));
			case "round" : if(ds_stack_size(vl) >= 1) return round(ds_stack_pop(vl));
			case "ceil"	 : if(ds_stack_size(vl) >= 1) return ceil(ds_stack_pop(vl));
			case "floor" : if(ds_stack_size(vl) >= 1) return floor(ds_stack_pop(vl));
		}
		
		return 0;
	}
#endregion