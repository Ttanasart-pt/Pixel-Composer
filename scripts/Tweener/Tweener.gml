enum TWEEN_TYPE {
	linear,
	log
}

enum TWEEN_VALUE {
	number,
	color
}

function Tween(value, valType = TWEEN_VALUE.number, twType = TWEEN_TYPE.log, twSpeed = 2) constructor {
	array_push(TWEEN_VALUES, self);
	
	realVal = value;
	showVal = value;
	self.valType = valType;
	
	tweenType  = twType;
	tweenSpeed = twSpeed;
	colTrans   = 0;
	
	static set = function(value) { 
		if(valType == TWEEN_VALUE.color) {
			showVal = get();
			colTrans = 0;
		}
		
		realVal = value; 
	} 
	static get = function(value) { 
		if(valType == TWEEN_VALUE.color)
			return colTrans == 1? realVal : merge_color(showVal, realVal, colTrans); 
		else 
			return showVal; 
	} 
	
	static step = function() {
		if(valType == TWEEN_VALUE.color) {
			if(tweenType == TWEEN_TYPE.linear) 
				colTrans = lerp_linear(colTrans, 1, 1 / tweenSpeed);
			else if(tweenType == TWEEN_TYPE.log) 
				colTrans = lerp_float(colTrans, 1, tweenSpeed);
			if(colTrans == 1)
				showVal = realVal;
		} else if(valType == TWEEN_VALUE.number) {
			if(tweenType == TWEEN_TYPE.linear) 
				showVal = lerp_linear(showVal, realVal, 1 / tweenSpeed);
			else if(tweenType == TWEEN_TYPE.log) 
				showVal = lerp_float(showVal, realVal, tweenSpeed);
		}
	}
	
	static destroy = function() { array_remove(TWEEN_VALUES, self); }
}

function tweenInit() {
	globalvar TWEEN_VALUES;
	TWEEN_VALUES = [];
}

function tweenStep() {
	for( var i = 0; i < array_length(TWEEN_VALUES); i++ ) 
		TWEEN_VALUES[i].step();
}