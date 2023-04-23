/// @func BBMOD_AddVec4OverTimeModule([_property[, _change[, _period]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that adds a value to four consecutive
/// particle properties over time.
///
/// @param {Real} [_property] The first of the four consecutive properties. Use
/// values from {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Struct.BBMOD_Vec4} [_change] The value added over specified period.
/// Defaults to `(1.0, 1.0, 1.0, 1.0)`.
/// @param {Real} [_period] How long in seconds it takes to add the value to the
/// properties. Defaults to 1.0.
///
/// @see BBMOD_EParticle.HealthLeft
function BBMOD_AddVec4OverTimeModule(
	_property=undefined,
	_change=new BBMOD_Vec4(1.0),
	_period=1.0
) : BBMOD_ParticleModule() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Real} The first of the four consecutive properties. Use values
	/// from {@link BBMOD_EParticle}. Default value is `undefined`.
	Property = _property;

	/// @var {Struct.BBMOD_Vec4} The value added over
	/// {@link BBMOD_AddVec4OverTimeModule.Period}. Default value is
	/// `(1.0, 1.0, 1.0, 1.0)`.
	Change = _change;

	/// @var {Real} How long in seconds it takes to add the value to the
	/// properties. Defaults to 1.0.
	Period = _period;

	static on_update = function (_emitter, _deltaTime) {
		var _property = Property;
		if (_property != undefined)
		{
			var _y2 = _emitter.ParticlesAlive - 1;
			if (_y2 >= 0)
			{
				var _factor = ((_deltaTime * 0.000001) / Period);
				var _change = Change;
				var _changeX = _change.X * _factor;
				var _changeY = _change.Y * _factor;
				var _changeZ = _change.Z * _factor;
				var _changeW = _change.W * _factor;
				ds_grid_add_region(_emitter.Particles, _property,     0, _property,     _y2, _changeX);
				ds_grid_add_region(_emitter.Particles, _property + 1, 0, _property + 1, _y2, _changeY);
				ds_grid_add_region(_emitter.Particles, _property + 2, 0, _property + 2, _y2, _changeZ);
				ds_grid_add_region(_emitter.Particles, _property + 3, 0, _property + 3, _y2, _changeW);
			}
		}
	};
}
