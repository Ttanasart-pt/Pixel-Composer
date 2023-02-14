/// @description Returns the depth of the specified object.
/// @param {Real} obj The index of the object to check
/// @return {Real} depth of the object
function object_get_depth(objID) {
	var ret = 0;
	if (objID >= 0) && (objID < array_length(global.__objectID2Depth)) {
		ret = global.__objectID2Depth[objID];
	} // end if
	return ret;
}
