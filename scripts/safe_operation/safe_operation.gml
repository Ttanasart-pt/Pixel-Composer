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