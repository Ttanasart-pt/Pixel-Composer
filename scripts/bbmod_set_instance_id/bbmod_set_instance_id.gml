/// @var {Id.Instance}
/// @private
global.__bbmodInstanceID = 0;

/// @var {Array<Id.Instance>,Undefined}
/// @private
global.__bbmodInstanceIDBatch = undefined;

/// @func bbmod_set_instance_id(_id)
///
/// @desc Sets an instance id for all subsequently rendered models.
///
/// @param {Id.Instance} _id The id of the instance.
function bbmod_set_instance_id(_id)
{
	gml_pragma("forceinline");
	global.__bbmodInstanceID = _id;
}
