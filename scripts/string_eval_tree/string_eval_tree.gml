#region evaluator
	function __fucnTree(symbol, l = noone, r = noone) constructor {
		self.symbol = symbol;
		self.l = l;
		self.r = r;
		isFunc = false;
		
		static eval = function() {
			var v1 = is_struct(l)? l.eval() : l;
			var v2 = is_struct(r)? r.eval() : r;
			
			switch(symbol) {
				case "+": return v1 + v2;
				case "-": return v1 - v2;
				case "*": return v1 * v2;	
				case "^": return power(v1, v2);
				case "/": return v1 / v2;	
				
				case "sin"   : return sin(v1);
				case "cos"   : return cos(v1);
				case "tan"   : return tan(v1);
				case "abs"	 : return abs(v1);
				case "round" : return round(v1);
				case "ceil"	 : return ceil(v1);
				case "floor" : return floor(v1);
			}
			
			return 0;
		}
	}

	function evaluateFunctionTree(fx, params = {}) {
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
#endregion