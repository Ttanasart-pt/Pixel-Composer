#region data
	global.EQUATION_PRES    = ds_map_create();
	global.EQUATION_PRES[? "+"] = 1;
	global.EQUATION_PRES[? "-"] = 1;
	global.EQUATION_PRES[? "_"] = 9; //unary negative
	global.EQUATION_PRES[? "*"] = 2;
	global.EQUATION_PRES[? "/"] = 2;
	global.EQUATION_PRES[? "$"] = 3;
	
	global.EQUATION_PRES[? "&"] = 5;
	global.EQUATION_PRES[? "|"] = 4;
	global.EQUATION_PRES[? "^"] = 3;
	global.EQUATION_PRES[? "<"] = 3;
	global.EQUATION_PRES[? "»"] = 6;
	global.EQUATION_PRES[? "«"] = 6;
	global.EQUATION_PRES[? "~"] = 9;
	
	global.EQUATION_PRES[? "="] = -1; //==
	global.EQUATION_PRES[? "≠"] = -1; //!=
	global.EQUATION_PRES[? "<"] =  0;
	global.EQUATION_PRES[? ">"] =  0;
	global.EQUATION_PRES[? "≤"] =  0;
	global.EQUATION_PRES[? "≥"] =  0;
	
	global.EQUATION_PRES[? "@"] = 5; //array accerssor symbol
	
	global.EQUATION_PRES[? "sin"]   = 5;
	global.EQUATION_PRES[? "cos"]   = 5;
	global.EQUATION_PRES[? "tan"]   = 5;
	global.EQUATION_PRES[? "abs"]   = 5;
	global.EQUATION_PRES[? "round"] = 5;
	global.EQUATION_PRES[? "ceil"]  = 5;
	global.EQUATION_PRES[? "floor"] = 5;
#endregion

function functionStringClean(fx) {
	fx = string_replace_all(fx,  " ", "");
	fx = string_replace_all(fx, "\n", "");
	fx = string_replace_all(fx, "**", "$");
	fx = string_replace_all(fx, "<<", "«");
	fx = string_replace_all(fx, ">>", "»");
	
	fx = string_replace_all(fx, "==", "=");
	fx = string_replace_all(fx, "!=", "≠");
	fx = string_replace_all(fx, "<>", "≠");
	fx = string_replace_all(fx, ">=", "≥");
	fx = string_replace_all(fx, "<=", "≤");
	
	fx = string_replace_all(fx, "[", "@["); //add array accessor symbol arr[i] = arr@[i] = arr @ (i)
	
	return fx;
}

#region evaluator
	function evaluateFunction(fx, params = {}) {
		var pres = global.EQUATION_PRES;
		var vl   = ds_stack_create();
		var op   = ds_stack_create();
		
		fx = functionStringClean(fx);
		
		var len = string_length(fx);
		var l   = 1;
		var ch, cch, _ch;
		
		while(l <= len) {
			ch = string_char_at(fx, l);
			
			if(ds_map_exists(pres, ch)) {
				if(ds_stack_empty(op)) ds_stack_push(op, ch);
				else {
					if(pres[? ch] > pres[? ds_stack_top(op)] || ds_stack_top(op) == "(") ds_stack_push(op, ch);
					else {
						if(ch == "-" && ds_map_exists(pres, _ch)) ch = "_"; //unary negative
						
						while(pres[? ch] <= pres[? ds_stack_top(op)] && !ds_stack_empty(op))
							ds_stack_push(vl, evalToken(ds_stack_pop(op), vl));
						ds_stack_push(op, ch);
					}
				}
				
				l++;
			} else if (ch == "(") {
				ds_stack_push(op, ch);
				l++;
			} else if (ch == ")") {
				while(ds_stack_top(op) != "(" && !ds_stack_empty(op))
					ds_stack_push(vl, evalToken(ds_stack_pop(op), vl));
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
			
			_ch = ch;
		}
		
		while(!ds_stack_empty(op)) {
			ds_stack_push(vl, evalToken(ds_stack_pop(op), vl));
		}
		ds_stack_destroy(op);
		
		return ds_stack_empty(vl)? 0 : ds_stack_pop(vl);
	}
	
	function evalToken(operator, vl) {
		if(ds_stack_empty(vl)) return 0;
		
		var v1 = 0, v2 = 0;
			
		switch(operator) { //binary
			case "+": 
			case "*": 
			case "$": 
			case "/": 
			case "&": 
			case "|": 
			case "^": 
			case "»": 
			case "«": 
			case "=": 
			case "≠": 
			case "<": 
			case ">": 
			case "≤": 
			case "≥": 
				if(ds_stack_size(vl) < 2) return 0;
				
				v1 = ds_stack_pop(vl);
				v2 = ds_stack_pop(vl);
				
				//print($"{v2} {operator} {v1}");
				//print($"symbol : {operator}");
				//print("====================");
		}
		
		switch(operator) {
			case "+": return v2 + v1;
			case "-": 
				if(ds_stack_size(vl) >= 2)
					return -ds_stack_pop(vl) + ds_stack_pop(vl);
				return -ds_stack_pop(vl);
			case "_": return -ds_stack_pop(vl); 
			case "*": return v2 * v1;
			case "$": return power(v2, v1);
			case "/": return v1 == 0? 0 : v2 / v1;
				
			case "&": return v2 & v1;
			case "|": return v2 | v1;
			case "^": return v2 ^ v1;
			case "»": return v2 >> v1;
			case "«": return v2 << v1;
			case "~": 
				if(ds_stack_size(vl) >= 1) 
					return ~ds_stack_pop(vl);
				return 0;
			
			case "=": return v2 == v1;
			case "≠": return v2 != v1;
			case "<": return v2 <  v1;
			case ">": return v2 >  v1;
			case "≤": return v2 <= v1;
			case "≥": return v2 >= v1;
			
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