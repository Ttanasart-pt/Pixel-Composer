#region data
    global.EVALUATE_HEAD = noone;
    global.PCX_FUNCTIONS = ds_map_create();
	
	function PXC_FN(key, fn) { global.PCX_FUNCTIONS[? key] = fn; }
	
    PXC_FN("sin",      [ ["radian"], function(r)   /*=>*/ {return sin(r)}   ]);
    PXC_FN("cos",      [ ["radian"], function(r)   /*=>*/ {return cos(r)}   ]);
    PXC_FN("tan",      [ ["radian"], function(r)   /*=>*/ {return tan(r)}   ]);
    
    PXC_FN("dsin",     [ ["degree"], function(d)   /*=>*/ {return dsin(d)}  ]);
    PXC_FN("dcos",     [ ["degree"], function(d)   /*=>*/ {return dcos(d)}  ]);
    PXC_FN("dtan",     [ ["degree"], function(d)   /*=>*/ {return dtan(d)}  ]);
    
    PXC_FN("arcsin",   [ ["x"],      function(v)   /*=>*/ {return arcsin(v)}     ]);
    PXC_FN("arccos",   [ ["x"],      function(v)   /*=>*/ {return arccos(v)}     ]);
    PXC_FN("arctan",   [ ["x"],      function(v)   /*=>*/ {return arctan(v)}     ]);
    PXC_FN("arctan2",  [ ["y","x"],  function(v,w) /*=>*/ {return arctan2(v,w)}  ]);
    
    PXC_FN("darcsin",  [ ["x"],      function(v)   /*=>*/ {return darcsin(v)}    ]);
    PXC_FN("darccos",  [ ["x"],      function(v)   /*=>*/ {return darccos(v)}    ]);
    PXC_FN("darctan",  [ ["x"],      function(v)   /*=>*/ {return darctan(v)}    ]);
    PXC_FN("darctan2", [ ["y","x"],  function(v,w) /*=>*/ {return darctan2(v,w)} ]);
    
    PXC_FN("abs",      [ ["x"],      function(v)   /*=>*/ {return abs(v)}   ]);
    PXC_FN("round",    [ ["x"],      function(v)   /*=>*/ {return round(v)} ]);
    PXC_FN("ceil",     [ ["x"],      function(v)   /*=>*/ {return ceil(v)}  ]);
    PXC_FN("floor",    [ ["x"],      function(v)   /*=>*/ {return floor(v)} ]);
    PXC_FN("fract",    [ ["x"],      function(v)   /*=>*/ {return frac(v)}  ]);
    PXC_FN("sign",     [ ["x"],      function(v)   /*=>*/ {return sign(v)}  ]);
    
    PXC_FN("min",      [ ["x","y"],  function(v,w) /*=>*/ {return min(v,w)} ]);
    PXC_FN("max",      [ ["x","y"],  function(v,w) /*=>*/ {return max(v,w)} ]);
    PXC_FN("clamp",    [ ["x","min = 0","max = 1"], function(v,n=0,m=1) /*=>*/ {return clamp(v, n, m)} ]);
    PXC_FN("lerp",     [ ["x","y","amount"], function(v,w,a) /*=>*/ {return lerp(v, w, a)} ]);
    
    PXC_FN("wiggle",   [ ["time","frequency","octave = 1","seed = 0"], function(t,f,o,s) /*=>*/ {return wiggle(0, 1, GLOBAL_TOTAL_FRAMES / f, t, s, o)} ]);
    PXC_FN("random",   [ ["min = 0","max = 1"],    function(n=0,m=1) /*=>*/  {return random_range(n, m)} ]);
    PXC_FN("irandom",  [ ["min = 0","max = 1"],    function(n=0,m=1) /*=>*/ {return irandom_range(n, m)} ]);
    PXC_FN("range",    [ ["length","start = 0","step = 1"],   
    	function(l=0,s=0,e=1) /*=>*/ { 
			var arr = array_create(l);
			for( var i = 0; i < l; i++ ) arr[i] = s + i * e;
			return arr;
		} ]);
    
    PXC_FN("length",   [ ["value"], 
    	function(a) /*=>*/ { 
			if(is_array(a))  return array_length(a);
			if(is_string(a)) return string_length(a);
			return 0;
		} ]);
    
    PXC_FN("string",   [ ["value"], function(v) /*=>*/ {return string(v)}   ]);
    PXC_FN("number",   [ ["value"], function(v) /*=>*/ {return toNumber(v)} ]);
    PXC_FN("chr",      [ ["x"],     function(v) /*=>*/ {return chr(v)}      ]);
    PXC_FN("ord",      [ ["char"],  function(v) /*=>*/ {return ord(v)}      ]);
         
    PXC_FN("draw", [ ["surface", "x = 0", "y = 0", "xs = 1", "ys = 1", "rot = 0", "color = white", "alpha = 1"], 
        function(s,sx=0,sy=0,xs=1,ys=1,r=0,c=c_white,a=1) /*=>*/ { draw_surface_ext_safe(s, sx, sy, xs, ys, r, c, a); return true; } ]);
    
    PXC_FN("surface_get_dimension", [ ["surface"], function(s) /*=>*/ {return surface_get_dimension(s)}    ]);
    PXC_FN("surface_get_width",     [ ["surface"], function(s) /*=>*/ {return surface_get_width_safe(s)}   ]);
    PXC_FN("surface_get_height",    [ ["surface"], function(s) /*=>*/ {return surface_get_height_safe(s)}  ]);
    
    PXC_FN("color_hex", [ ["char"],                  function(c)     /*=>*/ {return colorFromHex(c)}       ]);
    PXC_FN("color_rgb", [ ["red", "green", "blue"],  function(r,g,b) /*=>*/ {return make_color_rgb(r,g,b)} ]);
    PXC_FN("color_hsv", [ ["hue", "sat", "value"],   function(h,s,v) /*=>*/ {return make_color_hsv(h,s,v)} ]);
    
    PXC_FN("print", [ ["string", "warning = 0"],     function(s,w=0) /*=>*/ { if(w) noti_warning(s); else print(s); return 0; } ]);
    
    globalvar PROJECT_VARIABLES;
    PROJECT_VARIABLES = {};
    
    PROJECT_VARIABLES.Project = {};
    PROJECT_VARIABLES.Project.frame      = [ function() /*=>*/ {return GLOBAL_CURRENT_FRAME},                              EXPRESS_TREE_ANIM.animated ];
    PROJECT_VARIABLES.Project.progress   = [ function() /*=>*/ {return GLOBAL_CURRENT_FRAME / (GLOBAL_TOTAL_FRAMES - 1)},  EXPRESS_TREE_ANIM.animated ];
    PROJECT_VARIABLES.Project.frameTotal = [ function() /*=>*/ {return GLOBAL_TOTAL_FRAMES},                               EXPRESS_TREE_ANIM.none     ];
    PROJECT_VARIABLES.Project.FPS        = [ function() /*=>*/ {return PROJECT.animator.framerate},                        EXPRESS_TREE_ANIM.none     ];
    PROJECT_VARIABLES.Project.time       = [ function() /*=>*/ {return GLOBAL_CURRENT_FRAME / PROJECT.animator.framerate}, EXPRESS_TREE_ANIM.animated ];
    PROJECT_VARIABLES.Project.name       = [ function() /*=>*/ {return filename_name_only(PROJECT.path)},                  EXPRESS_TREE_ANIM.none     ];
    PROJECT_VARIABLES.Project.dimension  = [ function() /*=>*/ {return PROJECT.attributes.surface_dimension},              EXPRESS_TREE_ANIM.none     ];
    
    PROJECT_VARIABLES.Program = {};
    PROJECT_VARIABLES.Program.time         = [ function() /*=>*/ {return current_time / 1000}, EXPRESS_TREE_ANIM.animated ];
    
    PROJECT_VARIABLES.Device = {};
    PROJECT_VARIABLES.Device.timeSecond    = [ function() /*=>*/ {return current_second},  EXPRESS_TREE_ANIM.animated ];
    PROJECT_VARIABLES.Device.timeMinute    = [ function() /*=>*/ {return current_minute},  EXPRESS_TREE_ANIM.animated ];
    PROJECT_VARIABLES.Device.timeHour      = [ function() /*=>*/ {return current_hour},    EXPRESS_TREE_ANIM.animated ];
    PROJECT_VARIABLES.Device.timeDay       = [ function() /*=>*/ {return current_day},     EXPRESS_TREE_ANIM.animated ];
    PROJECT_VARIABLES.Device.timeDayInWeek = [ function() /*=>*/ {return current_weekday}, EXPRESS_TREE_ANIM.animated ];
    PROJECT_VARIABLES.Device.timeMonth     = [ function() /*=>*/ {return current_month},   EXPRESS_TREE_ANIM.animated ];
    PROJECT_VARIABLES.Device.timeYear      = [ function() /*=>*/ {return current_year},    EXPRESS_TREE_ANIM.animated ];
#endregion

#region evaluator
    enum EXPRESS_TREE_ANIM {
        none,
        base_value,
        animated
    }
    
    function __funcList() constructor {
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
        
        static isDynamic = function() {
            var anim = EXPRESS_TREE_ANIM.none;
            for( var i = 0, n = array_length(funcTrees); i < n; i++ )
                anim = max(anim, funcTrees[i].isDynamic());
            return anim;
        }
        
        static eval = function(params = {}) {
            var val = 0;
            
            for( var i = 0, n = array_length(funcTrees); i < n; i++ )
                val = funcTrees[i].eval(params);
                
            return val;
        }
    }
    
    function __funcIf() constructor {
        condition = noone;
        if_true   = new __funcList();
        if_false  = new __funcList();
        
        static validate = function() {
            if(condition != noone && !condition.validate())    return false;
            if(if_true != noone && !if_true.validate())        return false;
            if(if_false != noone && !if_false.validate())    return false;
            return true;
        }
        
        static isDynamic = function() {
            var anim = EXPRESS_TREE_ANIM.none;
            
            if(condition != noone) anim = max(anim, condition.isDynamic());
            if(if_true   != noone) anim = max(anim, if_true.isDynamic());
            if(if_false  != noone) anim = max(anim, if_false.isDynamic());
            
            return anim;
        }
        
        static eval = function(params = {}) {
            if(condition == noone) return 0;
            
            var res = condition.eval(params);
            printIf(global.LOG_EXPRESSION, $"<<<<<< IF {res} >>>>>>");
            
            if(res) return if_true == noone? 0  : if_true.eval(params);
            else    return if_false == noone? 0 : if_false.eval(params);
        }
    }
    
    function __funcFor() constructor {
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
                if(cond_term == noone || !cond_term.validate())    return false;
            }
            
            if(action != noone && !action.validate())        return false;
            
            return true;
        }
        
        static isDynamic = function() {
            var anim = EXPRESS_TREE_ANIM.none;
            
            if(itr_array) {
                if(cond_arr == noone) anim = max(anim, cond_arr.isDynamic())
            } else {
                if(cond_init == noone) anim = max(anim, cond_init.isDynamic())
                if(cond_term == noone) anim = max(anim, cond_term.isDynamic())
            }
            
            if(action != noone) anim = max(anim, action.isDynamic())
            
            return anim;
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
    }
    
    function __funcTree(symbol, l = noone, r = noone) constructor {
        self.symbol = symbol;
        self.l = l;
        self.r = r;
        dependency = [];
        anim_stat  = undefined;
        
        static _string = function(str) {
            return string_char_at(str, 1) == "\"" &&  string_char_at(str, string_length(str)) == "\"";
        }
        
        static _string_trim = function(str) {
            return string_trim(str, [ "\"" ]);
        }
        
        static getVal = function(val, params = {}, getRaw = false) {
            if(is_struct(val))    return val.eval(params, getRaw);
            if(is_real(val))    return val;
            if(getRaw)            return val;
            
            if(is_string(val)) val = string_trim(val);
            
            if(struct_has(params, val))
                return struct_try_get(params, val);
            
            val = string_trim(val);
            if(_string(val)) return _string_trim(val);
            
            var _str = string_splice(val, ".");
            if(array_length(_str) > 1 && _str[0] == "self" && struct_has(params, "node_values"))
                return struct_try_get(params.node_values, _str[1]);
            
            return nodeGetData(val);
        }
        
        static _validate = function(val) {
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
        }
        
        static validate = function() {
            dependency = [];
            
            if(ds_map_exists(global.PCX_FUNCTIONS, symbol)) {
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
        }
        
        static _isAnimated = function(val) {
            if(is_real(val))   return EXPRESS_TREE_ANIM.none;
            if(is_struct(val)) return val.isDynamic();
            if(is_array(val)) {
                var anim = EXPRESS_TREE_ANIM.none;
                for( var i = 0, n = array_length(val); i < n; i++ ) 
                    anim = max(anim, _isAnimated(val[i]));
                return anim;
            }
            
            if(val == "value") return EXPRESS_TREE_ANIM.base_value;
            //var anim = nodeGetDataAnim(val);
            return EXPRESS_TREE_ANIM.animated;
        }
        
        static isDynamic = function() {
            anim_stat = EXPRESS_TREE_ANIM.none;
            anim_stat = max(anim_stat, _isAnimated(l));
            if(symbol != "@") anim_stat = max(anim_stat, _isAnimated(r));
            
            return anim_stat;
        }
        
        static eval = function(params = {}, isLeft = false) {
            // print($"[eval] {symbol}, {l} | {r}");
            
            if(ds_map_exists(global.PCX_FUNCTIONS, symbol)) {
                if(!is_array(l)) return 0;
                
                var _pfn = global.PCX_FUNCTIONS[? symbol];
                var _fn  = _pfn[1];
                var _ln  = array_length(l);
                var _l   = array_create(_ln);
                
                for( var i = 0; i < _ln; i++ )
                    _l[i] = getVal(l[i], params);
                
                printIf(global.LOG_EXPRESSION, $"Function {symbol}{_l}");
                
                var res = 0;
                switch(_ln) {
                	case 0  : res = _fn(); break;
                	case 1  : res = _fn(_l[0]); break;
                	case 2  : res = _fn(_l[0], _l[1]); break;
                	case 3  : res = _fn(_l[0], _l[1], _l[2]); break;
                	case 4  : res = _fn(_l[0], _l[1], _l[2], _l[3]); break;
                	case 5  : res = _fn(_l[0], _l[1], _l[2], _l[3], _l[4]); break;
                	case 6  : res = _fn(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5]); break;
                	case 7  : res = _fn(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5], _l[6]); break;
                	case 8  : res = _fn(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5], _l[6], _l[7]); break;
                	case 9  : res = _fn(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5], _l[6], _l[7], _l[8]); break;
                	case 10 : res = _fn(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5], _l[6], _l[7], _l[8], _l[9]); break;
                	case 11 : res = _fn(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5], _l[6], _l[7], _l[8], _l[9], _l[10]); break;
                	case 12 : res = _fn(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5], _l[6], _l[7], _l[8], _l[9], _l[10], _l[11]); break;
                	case 13 : res = _fn(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5], _l[6], _l[7], _l[8], _l[9], _l[10], _l[11], _l[12]); break;
                	case 14 : res = _fn(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5], _l[6], _l[7], _l[8], _l[9], _l[10], _l[11], _l[12], _l[13]); break;
                	case 15 : res = _fn(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5], _l[6], _l[7], _l[8], _l[9], _l[10], _l[11], _l[12], _l[13], _l[14]); break;
                	case 16 : res = _fn(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5], _l[6], _l[7], _l[8], _l[9], _l[10], _l[11], _l[12], _l[13], _l[14], _l[15]); break;
                }
                
                printIf(global.LOG_EXPRESSION, $"              = {res}");
                printIf(global.LOG_EXPRESSION, "====================");
                
                return res;
            }
            
            var getRaw = false;
            switch(symbol) {
                case "=":    
                case "≔":    
                case "【":    
                    getRaw = true;
            }
            
            var v1  = getVal(l, params, getRaw || isLeft);
            var v2  = getVal(r, params);
            var res = 0;
            
            switch(symbol) {
                case "" : 
                    res = v1;
                    break;
                    
                case "【" : // array builder
                    res = array_create(array_length(v1));
                    for( var i = 0, n = array_length(v1); i < n; i++ )
                        res[i] = getVal(v1[i], params);
                    break;
                    
                case "@" : // array getter
                    if(isLeft)    
                        res = [ v1, v2 ];
                    else if(is_real(v2)) {
                        if(is_array(v1)) {
                            if(v2 < 0) v2 = array_length(v1) + v2;
                            res = aGetF(v1, v2);
                        } else if(is_string(v1)) {
                            if(v2 < 0) v2 = string_length(v1) + v2;
                            res = string_char_at(v1, v2 + 1);
                        }
                    }
                    break;
                    
                case "=" : // value assignment
                    if(is_array(v1)) { 
                        var val = params[$ v1[0]];
                        val = array_safe_set(val, v1[1], v2);
                        params[$ v1[0]] = val;
                        res = val;
                    } else {
                        params[$ v1] = v2;
                        res = v2;
                    }
                    break;
                    
                case "≔" : // function default replacement
                    if(!struct_exists(params, v1))
                        params[$ v1] = v2;
                    res = params[$ v1];
                    break;
                    
                default :
                    if(is_array(v1) && !is_array(v2)) {                                    // evaluate value
                        res = array_create(array_length(v1));
                        for( var i = 0, n = array_length(res); i < n; i++ )
                            res[i] = eval_real(aGetF(v1, i), v2);
                            
                    } else if(!is_array(v1) && is_array(v2)) {
                        res = array_create(array_length(v2));
                        for( var i = 0, n = array_length(res); i < n; i++ )
                            res[i] = eval_real(v1, aGetF(v2, i));
                            
                    } else if(is_array(v1) && is_array(v2)) {
                        res = array_create(max(array_length(v1), array_length(v2)));
                        for( var i = 0, n = array_length(res); i < n; i++ )
                            res[i] = eval_real(aGetF(v1, i), aGetF(v2, i));
                            
                    } else 
                        res = eval_real(v1, v2);
                    break;
            }
            
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
                    printIf(global.LOG_EXPRESSION, $"params : {params}");
                    printIf(global.LOG_EXPRESSION, "====================");
                    break;
            }
            
            return res;
        }
        
        static eval_real = function(v1, v2, _symbol = symbol) {
            switch(_symbol) {
                case "+": 
                case "⊕": 
                    if(is_string(v1) || is_string(v2))    return string(v1) + string(v2);
                    if(is_real(v1) && is_real(v2))        return v1 + v2;
                    return 0;
                case "-": 
                case "∸": 
                case "⊖": return (is_real(v1) && is_real(v2))? v1 - v2         : 0;
                case "*": 
                case "⊗": return (is_real(v1) && is_real(v2))? v1 * v2         : 0;
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
        }
            
        static toString = function() { return $"[PCX funcTree] \{ symbol: {symbol}, l: {l}, r: {r}\}"; }
    }
    
    function evaluateFunction(fx, params = {}) {
        if(isNumber(fx)) return toNumber(fx);
        return evaluateFunctionList(fx).eval(params);
    }
#endregion