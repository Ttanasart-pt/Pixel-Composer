enum MOD_NEG {
	_default,
	wrap
}

function safe_mod(numb, modd, _neg = MOD_NEG._default) {
	INLINE
	
	var _md = modd == 0? 0 : numb % modd;
	if(_md < 0)
	switch(_neg) {
		case MOD_NEG.wrap : _md += modd; break;
	}
	
	return _md;
}

//!#mfunc mod_inc {"args":["val"," range"],"order":[0,0,1]}
#macro mod_inc_mf0  //
#macro mod_inc_mf1  = (
#macro mod_inc_mf2  + 1) % 
#macro mod_inc_mf3 ;
//!#mfunc mod_dec {"args":["val"," range"],"order":[0,0,1,1]}
#macro mod_dec_mf0  //
#macro mod_dec_mf1  = (
#macro mod_dec_mf2  - 1 + 
#macro mod_dec_mf3 ) % 
#macro mod_dec_mf4 ;
//!#mfunc mod_del {"args":["val"," range"],"order":[0,0,1,1]}
#macro mod_del_mf0  //
#macro mod_del_mf1  = (
#macro mod_del_mf2  + d + 
#macro mod_del_mf3 ) % 
#macro mod_del_mf4 ;