#region data
	global.EVALUATE_HEAD = noone;

	global.FUNCTIONS    = ds_map_create();
	global.FUNCTIONS[? "sin"]    = [ ["radian"], function(val) { return sin(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "cos"]    = [ ["radian"], function(val) { return cos(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "tan"]    = [ ["radian"], function(val) { return tan(array_safe_get(val, 0)); } ];
	
	global.FUNCTIONS[? "dsin"]    = [ ["degree"], function(val) { return dsin(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "dcos"]    = [ ["degree"], function(val) { return dcos(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "dtan"]    = [ ["degree"], function(val) { return dtan(array_safe_get(val, 0)); } ];
	
	global.FUNCTIONS[? "arcsin"] = [ ["x"],       function(val) { return arcsin(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "arccos"] = [ ["x"],       function(val) { return arccos(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "arctan"] = [ ["x"],       function(val) { return arctan(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "arctan2"] = [ ["y", "x"], function(val) { return arctan2(array_safe_get(val, 0), array_safe_get(val, 1)); } ];
	
	global.FUNCTIONS[? "darcsin"]  = [ ["x"],      function(val) { return darcsin(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "darccos"]  = [ ["x"],      function(val) { return darccos(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "darctan"]  = [ ["x"],      function(val) { return darctan(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "darctan2"] = [ ["y", "x"], function(val) { return darctan2(array_safe_get(val, 0), array_safe_get(val, 1)); } ];
	
	global.FUNCTIONS[? "abs"]    = [ ["x"], function(val) { return abs(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "round"]  = [ ["x"], function(val) { return round(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "ceil"]   = [ ["x"], function(val) { return ceil(array_safe_get(val, 0));  } ];
	global.FUNCTIONS[? "floor"]  = [ ["x"], function(val) { return floor(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "fract"]  = [ ["x"], function(val) { return frac(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "sign"]   = [ ["x"], function(val) { return sign(array_safe_get(val, 0)); } ];
	
	global.FUNCTIONS[? "min"]   = [ ["x", "y"], function(val) { return min(array_safe_get(val, 0), array_safe_get(val, 1)); } ];
	global.FUNCTIONS[? "max"]   = [ ["x", "y"], function(val) { return max(array_safe_get(val, 0), array_safe_get(val, 1)); } ];
	global.FUNCTIONS[? "clamp"] = [ ["x", "min = 0", "max = 1"], function(val) { return clamp(array_safe_get(val, 0), array_safe_get(val, 1, 0), array_safe_get(val, 2, 1)); } ];
	
	global.FUNCTIONS[? "lerp"]   = [ ["x", "y", "amount"], function(val) { return lerp(array_safe_get(val, 0), array_safe_get(val, 1), array_safe_get(val, 2)); } ];
	
	global.FUNCTIONS[? "wiggle"] = [ ["time", "frequency", "octave = 1", "seed = 0"],	function(val) { 
																								return wiggle(0, 1, PROJECT.animator.frameTotal / array_safe_get(val, 1), 
																												array_safe_get(val, 0), 
																												array_safe_get(val, 3, 0), 
																												array_safe_get(val, 2, 1)); 
																						} ];
	global.FUNCTIONS[? "random"] = [ ["min = 0", "max = 1"],	function(val) { 
																	return random_range(array_safe_get(val, 0, 0), 
																					    array_safe_get(val, 1, 1)); 
																} ];
	global.FUNCTIONS[? "irandom"] = [ ["min = 0", "max = 1"],	function(val) { 
																	return irandom_range(array_safe_get(val, 0, 0), 
																					     array_safe_get(val, 1, 1)); 
																} ];
	
	global.FUNCTIONS[? "range"] = [ ["length", "start = 0", "step = 1"],	function(val) { 
																				var arr = array_create(array_safe_get(val, 0, 0));
																				for( var i = 0, n = array_length(arr); i < n; i++ ) 
																					arr[i] = array_safe_get(val, 1, 0) + i * array_safe_get(val, 2, 1);
																				return arr;
																			} ];
	
	global.FUNCTIONS[? "length"] = [ ["value"],	function(val) { 
													if(is_array(val))	return array_length(val);
													if(is_string(val))	return string_length(val);
													return 0;
												} ];
	
	global.FUNCTIONS[? "string"] = [ ["value"], function(val) { return string(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "number"] = [ ["value"], function(val) { return toNumber(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "chr"]    = [ ["x"],		function(val) { return chr(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "ord"]    = [ ["char"],  function(val) { return ord(array_safe_get(val, 0)); } ];
	
	global.FUNCTIONS[? "draw"]    = [ ["surface", "x = 0", "y = 0", "xs = 1", "ys = 1", "rot = 0", "color = white", "alpha = 1"], 
		function(val) { return draw_surface_ext_safe(array_safe_get(val, 0, -1), array_safe_get(val, 1, 0), array_safe_get(val, 2, 0),
													 array_safe_get(val, 3,  1), array_safe_get(val, 4, 1), array_safe_get(val, 5, 0),
													 array_safe_get(val, 6, c_white),  array_safe_get(val, 7, 1)); 
					  } ];
	
	global.FUNCTIONS[? "surface_get_width"]  = [ ["surface"], function(val) { return surface_get_width_safe(array_safe_get(val, 0)); } ];
	global.FUNCTIONS[? "surface_get_height"] = [ ["surface"], function(val) { return surface_get_height_safe(array_safe_get(val, 0)); } ];
	
	globalvar PROJECT_VARIABLES;
	PROJECT_VARIABLES = {};
	
	PROJECT_VARIABLES.Project = {};
	PROJECT_VARIABLES.Project.frame			= function() /*=>*/ {return PROJECT.animator.current_frame};
	PROJECT_VARIABLES.Project.progress		= function() /*=>*/ {return PROJECT.animator.current_frame / (PROJECT.animator.frames_total - 1)};
	PROJECT_VARIABLES.Project.frameTotal	= function() /*=>*/ {return PROJECT.animator.frames_total};
	PROJECT_VARIABLES.Project.fps			= function() /*=>*/ {return PROJECT.animator.framerate};
	PROJECT_VARIABLES.Project.time			= function() /*=>*/ {return PROJECT.animator.current_frame / PROJECT.animator.framerate};
	PROJECT_VARIABLES.Project.name			= function() /*=>*/ {return filename_name_only(PROJECT.path)};
	
	PROJECT_VARIABLES.Program = {};
	PROJECT_VARIABLES.Program.time			= function() /*=>*/ {return current_time / 1000};
	
	PROJECT_VARIABLES.Device = {};
	PROJECT_VARIABLES.Device.timeSecond			= function() /*=>*/ {return current_second};
	PROJECT_VARIABLES.Device.timeMinute			= function() /*=>*/ {return current_minute};
	PROJECT_VARIABLES.Device.timeHour			= function() /*=>*/ {return current_hour};
	PROJECT_VARIABLES.Device.timeDay			= function() /*=>*/ {return current_day};
	PROJECT_VARIABLES.Device.timeDayInWeek		= function() /*=>*/ {return current_weekday};
	PROJECT_VARIABLES.Device.timeMonth			= function() /*=>*/ {return current_month};
	PROJECT_VARIABLES.Device.timeYear			= function() /*=>*/ {return current_year};
#endregion

#region evaluator
	enum EXPRESS_TREE_ANIM {
		none,
		base_value,
		animated
	}
	
	function __funcList() constructor { #region
		funcTrees = [];
		
		static addFunction = function(fn) {
			array_push(funcTrees, fn);
		}
		
		static validate = function() {
			for( var i = 0, n = array_length(funcTrees); i < n; i++ )
				if(!funcTrees[i].validate())
					return false;
				
			return true;
		}
		
		static isAnimated = function() {
			for( var i = 0, n = array_length(funcTrees); i < n; i++ )
				if(!funcTrees[i].isAnimated())
					return false;
				
			return true;
		}
		
		static eval = function(params = {}) {
			//var _params = variable_clone(params);
			var val = 0;
			
			for( var i = 0, n = array_length(funcTrees); i < n; i++ )
				val = funcTrees[i].eval(params);
				
			return val;
		}
	} #endregion
	
	function __funcIf() constructor { #region
		condition = noone;
		if_true   = new __funcList();
		if_false  = new __funcList();
		
		static validate = function() {
			if(condition != noone && !condition.validate())	return false;
			if(if_true != noone && !if_true.validate())		return false;
			if(if_false != noone && !if_false.validate())	return false;
			return true;
		}
		
		static isAnimated = function() {
			if(condition != noone && !condition.isAnimated())	return false;
			if(if_true != noone && !if_true.isAnimated())		return false;
			if(if_false != noone && !if_false.isAnimated())		return false;
			return true;
		}
		
		static eval = function(params = {}) {
			if(condition == noone) return 0;
			
			var res = condition.eval(params);
			printIf(global.LOG_EXPRESSION, $"<<<<<< IF {res} >>>>>>");
			
			if(res) return if_true == noone? 0  : if_true.eval(params);
			else    return if_false == noone? 0 : if_false.eval(params);
		}
	} #endregion
	
	function __funcFor() constructor { #region
		itr_array = false;
		
		cond_init = noone;
		cond_indx = noone;
		cond_iter = noone;
		cond_term = noone;
		
		cond_arr  = noone;
		
		cond_step = 1;
		action    = new __funcList();
		
		static validate = function() {
			if(itr_array) {
				if(cond_arr == noone || !cond_arr.validate()) return false;
			} else {
				if(cond_init == noone || !cond_init.validate()) return false;
				if(cond_term == noone || !cond_term.validate())	return false;
			}
			
			if(action != noone && !action.validate())		return false;
			
			return true;
		}
		
		static isAnimated = function() {
			if(itr_array) {
				if(cond_arr == noone || !cond_arr.isAnimated())	return false;
			} else {
				if(cond_init == noone || !cond_init.isAnimated())	return false;
				if(cond_term == noone || !cond_term.isAnimated())	return false;
			}
			
			if(action != noone && !action.isAnimated())			return false;
			
			return true;
		}
		
		static eval = function(params = {}) {
			if(itr_array) {
				var _arr = cond_arr.eval(params);
				printIf(global.LOG_EXPRESSION, $"<<<<<< FOR EACH {_arr} >>>>>>");
				for( var i = 0, n = array_length(_arr); i < n; i++ ) {
					var val = _arr[i];
					if(cond_indx != noone)
						params[$ cond_indx] = i;
					params[$ cond_iter] = val;
					
					printIf(global.LOG_EXPRESSION, $"<< ITER {i}: {cond_iter} = {val} >>");
					action.eval(params);
				}
			} else {
				printIf(global.LOG_EXPRESSION, "<< FOR >>");
				cond_init.eval(params);
				
				while(cond_term.eval(params)) {
					action.eval(params);
					cond_iter.eval(params);
				}
			}
		}
	} #endregion
	
	function __funcTree(symbol, l = noone, r = noone) constructor { #region
		self.symbol = symbol;
		self.l = l;
		self.r = r;
		dependency = [];
		
		static _string = function(str) { #region
			return string_char_at(str, 1) == "\"" &&  string_char_at(str, string_length(str)) == "\"";
		} #endregion
		
		static _string_trim = function(str) { #region
			return string_trim(str, [ "\"" ]);
		} #endregion
		
		static getVal = function(val, params = {}, getRaw = false) { #region
			if(is_struct(val))	return val.eval(params, getRaw);
			if(is_real(val))	return val;
			if(getRaw)			return val;
			
			if(is_string(val)) val = string_trim(val);
			
			if(struct_has(params, val))
				return struct_try_get(params, val);
			
			val = string_trim(val);
			
			if(_string(val))
				return _string_trim(val);
			
			return nodeGetData(val);
		} #endregion
		
		static _validate = function(val) { #region
			if(is_real(val))   return true;
			if(is_string(val)) return true;
			if(is_struct(val)) return val.validate();

			if(val == "value") return true;
			if(PROJECT.globalNode.inputExist(val)) return true;
			
			var strs = string_splice(val, ".");
			if(array_length(strs) < 2) return false;
			
			if(struct_has(PROJECT_VARIABLES, strs[0]))
				return struct_has(PROJECT_VARIABLES[$ strs[0]], strs[1]);
			
			if(!ds_map_exists(PROJECT.nodeNameMap, strs[0]))
				return false;
			
			array_push_unique(dependency, strs[0]);
			return true;
		} #endregion
		
		static validate = function() { #region
			dependency = [];
			
			if(ds_map_exists(global.FUNCTIONS, symbol)) {
				if(!is_array(l)) return false;
				for( var i = 0, n = array_length(l); i < n; i++ )
					if(!_validate(l[i])) return false;
				return true;
			}
				
			switch(symbol) {
				case "@": return _validate(l);
				case "【": return true;
				case "":  return true;
			}
			
			return _validate(l) && _validate(r);
		} #endregion
		
		static _isAnimated = function(val) { #region
			if(is_real(val))   return EXPRESS_TREE_ANIM.none;
			if(is_struct(val)) return val._isAnimated();
			
			if(val == "value") return EXPRESS_TREE_ANIM.base_value;
			if(PROJECT.globalNode.inputExist(val)) {
				var _inp = PROJECT.globalNode.getInput(val);
				if(_inp.is_anim) return EXPRESS_TREE_ANIM.animated;
			}
			
			return EXPRESS_TREE_ANIM.none;
		} #endregion
		
		static isAnimated = function() { #region
			var anim = EXPRESS_TREE_ANIM.none;
			anim = max(anim, _isAnimated(l));
			if(symbol != "@")
				anim = max(anim, _isAnimated(r));
			
			return anim;
		} #endregion
		
		static eval = function(params = {}, isLeft = false) { #region
			if(ds_map_exists(global.FUNCTIONS, symbol)) {
				if(!is_array(l)) return 0;
				
				var _fn = global.FUNCTIONS[? symbol];
				var _ev = _fn[1];
				var _l  = array_create(array_length(l));
				
				for( var i = 0, n = array_length(l); i < n; i++ )
					_l[i] = getVal(l[i], params);
					
				var res = _ev(_l);
				printIf(global.LOG_EXPRESSION, $"Function {symbol}{_l} = {res}");
				printIf(global.LOG_EXPRESSION, "====================");
				
				return res;
			}
			
			var getRaw = false;
			switch(symbol) {
				case "=":	
				case "【":	
					getRaw = true;
			}
			
			var v1 = getVal(l, params, getRaw || isLeft);
			var v2 = getVal(r, params);
			
			var res = 0;
			
			if(symbol == "") {
				res = v1;
			} else if(symbol == "【") {													// array builder
				res = array_create(array_length(v1));
				for( var i = 0, n = array_length(res); i < n; i++ )
					res[i] = getVal(v1[i], params);
			} else if(symbol == "@") {													// array getter
				if(isLeft)	
					res = [ v1, v2 ];
				else if(is_real(v2)) {
					if(is_array(v1)) {
						if(v2 < 0) v2 = array_length(v1) + v2;
						res = array_safe_get(v1, v2);
					} else if(is_string(v1)) {
						if(v2 < 0) v2 = string_length(v1) + v2;
						res = string_char_at(v1, v2 + 1);
					}
				}
			} else if(symbol == "=") {													// value assignment
				if(is_array(v1)) { 
					var val = params[$ v1[0]];
					val = array_safe_set(val, v1[1], v2);
					params[$ v1[0]] = val;
					res = val;
				} else {
					params[$ v1] = v2;
					res = v2;
				}
			} else if(symbol == "≔") {													// function default replacement
				if(!struct_exists(params, v1))
					params[$ v1] = v2;
				res = params[$ v1];
			} else if(is_array(v1) && !is_array(v2)) {									// evaluate value
				res = array_create(array_length(v1));
				for( var i = 0, n = array_length(res); i < n; i++ )
					res[i] = eval_real(array_safe_get(v1, i), v2);
			} else if(!is_array(v1) && is_array(v2)) {
				res = array_create(array_length(v2));
				for( var i = 0, n = array_length(res); i < n; i++ )
					res[i] = eval_real(v1, array_safe_get(v2, i));
			} else if(is_array(v1) && is_array(v2)) {
				res = array_create(max(array_length(v1), array_length(v2)));
				for( var i = 0, n = array_length(res); i < n; i++ )
					res[i] = eval_real(array_safe_get(v1, i), array_safe_get(v2, i));
			} else 
				res = eval_real(v1, v2);
			
			var _v1_var = getVal(l, params, true);
			switch(symbol) {
				case "⊕": 
				case "⊖": 
				case "⊗": 
				case "⊘": 
					if(is_array(_v1_var)) { 
						var val = params[$ _v1_var[0]];
						val = array_safe_set(val, _v1_var[1], res);
						params[$ _v1_var[0]] = val;
					} else
						params[$ _v1_var] = res;
				
					printIf(global.LOG_EXPRESSION, $"|{_v1_var}| = {v1}|{symbol}|{v2}| = {res}");
					printIf(global.LOG_EXPRESSION, $"symbol : {symbol}");
					printIf(global.LOG_EXPRESSION, $"l      : | {typeof(l)} |{l}|");
					printIf(global.LOG_EXPRESSION, $"r      : | {typeof(r)} |{r}|");
					printIf(global.LOG_EXPRESSION, "====================");
					break;
				default:
					printIf(global.LOG_EXPRESSION, $"|{v1}|{symbol}|{v2}| = {res}");
					printIf(global.LOG_EXPRESSION, $"symbol : {symbol}");
					printIf(global.LOG_EXPRESSION, $"l      : | {typeof(l)} |{l}|");
					printIf(global.LOG_EXPRESSION, $"r      : | {typeof(r)} |{r}|");
					printIf(global.LOG_EXPRESSION, "====================");
					break;
			}
			
			return res;
		} #endregion
		
		static evalFn = function(params) { #region
			if(!ds_map_exists(global.FUNCTIONS, symbol)) return;
			
			if(!is_array(params)) return 0;
				
			var _fn = global.FUNCTIONS[? symbol];
			var _ev = _fn[1];
			var res = _ev(params);
			return res;
		} #endregion
		
		static eval_real = function(v1, v2, _symbol = symbol) { #region
			switch(_symbol) {
				case "+": 
				case "⊕": 
					if(is_string(v1) || is_string(v2))	return string(v1) + string(v2);
					if(is_real(v1) && is_real(v2))		return v1 + v2;
					return 0;
				case "-": 
				case "∸": 
				case "⊖": return (is_real(v1) && is_real(v2))? v1 - v2		 : 0;
				case "*": 
				case "⊗": return (is_real(v1) && is_real(v2))? v1 * v2		 : 0;
				case "$": return (is_real(v1) && is_real(v2))? power(v1, v2) : 0;
				case "/": 
				case "⊘": return (is_real(v1) && is_real(v2) && v2 != 0)? v1 / v2 : 0;
				case "%": return (is_real(v1) && is_real(v2) && v2 != 0)? v1 % v2 : 0;
				
				case "&": return (is_real(v1) && is_real(v2))? v1 & v2       : 0;
				case "|": return (is_real(v1) && is_real(v2))? v1 | v2       : 0;
				case "^": return (is_real(v1) && is_real(v2))? v1 ^ v2       : 0;
				case "«": return (is_real(v1) && is_real(v2))? v1 << v2      : 0;
				case "»": return (is_real(v1) && is_real(v2))? v1 >> v2      : 0;
				case "~": return  is_real(v1)? ~v1 : 0;
				
				case "⩵": return (is_real(v1) && is_real(v2))? v1 == v2     : 0;
				case "≠": return (is_real(v1) && is_real(v2))? v1 != v2      : 0;
				case "≤": return (is_real(v1) && is_real(v2))? v1 <= v2      : 0;
				case "≥": return (is_real(v1) && is_real(v2))? v1 >= v2      : 0;
				case ">": return (is_real(v1) && is_real(v2))? v1 > v2       : 0;
				case "<": return (is_real(v1) && is_real(v2))? v1 < v2       : 0;
			}
			
			return v1;
		} #endregion
	} #endregion
	
	function evaluateFunction(fx, params = {}) { #region
		if(isNumber(fx)) return toNumber(fx);
		return evaluateFunctionList(fx).eval(params);
	} #endregion
#endregion