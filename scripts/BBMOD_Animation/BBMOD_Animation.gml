#macro BBMOD_BONE_SPACE_PARENT (1 << 0)
#macro BBMOD_BONE_SPACE_WORLD (1 << 1)
#macro BBMOD_BONE_SPACE_BONE (1 << 2)

/// @func BBMOD_Animation([_file[, _sha1]])
///
/// @extends BBMOD_Resource
///
/// @desc An animation which can be played using {@link BBMOD_AnimationPlayer}.
///
/// @param {String} [_file] A "*.bbanim" animation file to load. If not
/// specified, then an empty animation is created.
/// @param {String} [_sha1] Expected SHA1 of the file. If the actual one does
/// not match with this, then the model will not be loaded.
///
/// @example
/// Following code loads an animation from a file `Walk.bbanim`:
///
/// ```gml
/// try
/// {
///     animWalk = new BBMOD_Animation("Walk.bbanim");
/// }
/// catch (_exception)
/// {
///     // The animation failed to load!
/// }
/// ```
///
/// You can also load animations from buffers like so:
///
/// ```gml
/// var _buffer = buffer_load("Walk.anim");
/// try
/// {
///     animWalk = new BBMOD_Animation().from_buffer(_buffer);
/// }
/// catch (_exception)
/// {
///     // Failed to load an animation from the buffer!
/// }
/// buffer_delete(_buffer);
/// ```
///
/// @throws {BBMOD_Exception} When the animation fails to load.
function BBMOD_Animation(_file=undefined, _sha1=undefined)
	: BBMOD_Resource() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Bool} If `false` then the animation has not been loaded yet.
	/// @readonly
	IsLoaded = false;

	/// @var {Real} The major version of the animation file.
	VersionMajor = BBMOD_VERSION_MAJOR;

	/// @var {Real} The minor version of the animation file.
	VersionMinor = BBMOD_VERSION_MINOR;

	/// @var {Real} The transformation spaces included in the animation file.
	/// @private
	__spaces = 0;

	/// @var {Real} The duration of the animation (in tics).
	/// @readonly
	Duration = 0;

	/// @var {Real} Number of animation tics per second.
	/// @readonly
	TicsPerSecond = 0;

	/// @var {Real}
	/// @private
	__modelNodeCount = 0;

	/// @var {Real}
	/// @private
	__modelBoneCount = 0;

	/// @var {Array<Array<Real>>}
	/// @private
	__framesParent = [];

	/// @var {Array<Array<Real>>}
	/// @private
	__framesWorld = [];

	/// @var {Array<Array<Real>>}
	/// @private
	__framesBone = [];

	/// @var {Bool}
	/// @private
	__isTransition = false;

	/// @var {Real} Duration of transition into this animation (in seconds).
	/// Must be a value greater or equal to 0!
	TransitionIn = 0.1;

	/// @var {Real} Duration of transition out of this animation (in seconds).
	/// Must be a value greater or equal to 0!
	TransitionOut = 0;

	/// @var {Array} Custom animation events in form of `[frame, name, ...]`.
	/// @private
	__events = [];

	/// @func add_event(_frame, _name)
	///
	/// @desc Adds a custom animation event.
	///
	/// @param {Real} _frame The frame at which should be the event triggered.
	/// @param {String} _name The name of the event.
	///
	/// @return {Struct.BBMOD_Animation} Returns `self`.
	///
	/// @example
	/// ```gml
	/// animWalk = new BBMOD_Animation("Data/Character_Walk.bbanim");
	/// animWalk.add_event(0, "Footstep")
	///     .add_event(16, "Footstep");
	/// animationPlayer.on_event("Footstep", method(self, function () {
	///     // Play footstep sound...
	/// }));
	/// ```
	static add_event = function (_frame, _name) {
		gml_pragma("forceinline");
		array_push(__events, _frame, _name);
		return self;
	};

	/// @func supports_attachments()
	///
	/// @desc Checks whether the animation supports bone attachments.
	///
	/// @return {Bool} Returns true if the animation supports bone attachments.
	static supports_attachments = function () {
		gml_pragma("forceinline");
		return ((__spaces & (BBMOD_BONE_SPACE_PARENT | BBMOD_BONE_SPACE_WORLD)) != 0);
	};

	/// @func supports_bone_transform()
	///
	/// @desc Checks whether the animation supports bone transformation through
	/// code.
	///
	/// @return {Bool} Returns true if the animation supports bone
	/// transformation through code.
	static supports_bone_transform = function () {
		gml_pragma("forceinline");
		return ((__spaces & BBMOD_BONE_SPACE_PARENT) != 0);
	};

	/// @func supports_transitions()
	///
	/// @desc Checks whether the animation supports transitions.
	///
	/// @return {Bool} Returns true if the animation supports transitions.
	static supports_transitions = function () {
		gml_pragma("forceinline");
		return ((__spaces & (BBMOD_BONE_SPACE_PARENT | BBMOD_BONE_SPACE_WORLD)) != 0);
	};

	/// @func get_animation_time(_timeInSeconds)
	///
	/// @desc Calculates animation time from current time in seconds.
	///
	/// @param {Real} _timeInSeconds The current time in seconds.
	///
	/// @return {Real} The animation time.
	static get_animation_time = function (_timeInSeconds) {
		gml_pragma("forceinline");
		return round(_timeInSeconds * TicsPerSecond);
	};

	/// @func from_buffer(_buffer)
	///
	/// @desc Loads animation data from a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to load the data from.
	///
	/// @return {Struct.BBMOD_Animation} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If loading fails.
	static from_buffer = function (_buffer) {
		var _hasMinorVersion = false;

		var _type = buffer_read(_buffer, buffer_string);
		if (_type == "bbanim")
		{
		}
		else if (_type == "BBANIM")
		{
			_hasMinorVersion = true;
		}
		else
		{
			throw new BBMOD_Exception("Buffer does not contain a BBANIM!");
		}

		VersionMajor = buffer_read(_buffer, buffer_u8);
		if (VersionMajor != BBMOD_VERSION_MAJOR)
		{
			throw new BBMOD_Exception(
				"Invalid BBANIM major version " + string(VersionMajor) + "!");
		}

		if (_hasMinorVersion)
		{
			VersionMinor = buffer_read(_buffer, buffer_u8);
			if (VersionMinor > BBMOD_VERSION_MINOR)
			{
				throw new BBMOD_Exception(
					"Invalid BBANIM minor version " + string(VersionMinor) + "!");
			}
		}
		else
		{
			VersionMinor = 0;
		}

		__spaces = buffer_read(_buffer, buffer_u8);
		Duration = buffer_read(_buffer, buffer_f64);
		TicsPerSecond = buffer_read(_buffer, buffer_f64);

		__modelNodeCount = buffer_read(_buffer, buffer_u32);
		var _modelNodeSize = __modelNodeCount * 8;
		__modelBoneCount = buffer_read(_buffer, buffer_u32);
		var _modelBoneSize = __modelBoneCount * 8;

		__framesParent = (__spaces & BBMOD_BONE_SPACE_PARENT) ? [] : undefined;
		__framesWorld = (__spaces & BBMOD_BONE_SPACE_WORLD) ? [] : undefined;
		__framesBone = (__spaces & BBMOD_BONE_SPACE_BONE) ? [] : undefined;

		repeat (Duration)
		{
			if (__spaces & BBMOD_BONE_SPACE_PARENT)
			{
				array_push(__framesParent,
					bbmod_array_from_buffer(_buffer, buffer_f32, _modelNodeSize));
			}

			if (__spaces & BBMOD_BONE_SPACE_WORLD)
			{
				array_push(__framesWorld,
					bbmod_array_from_buffer(_buffer, buffer_f32, _modelNodeSize));
			}

			if (__spaces & BBMOD_BONE_SPACE_BONE)
			{
				array_push(__framesBone,
					bbmod_array_from_buffer(_buffer, buffer_f32, _modelBoneSize));
			}
		}

		if (VersionMinor >= 4)
		{
			var _eventCount = buffer_read(_buffer, buffer_u32);
			repeat (_eventCount)
			{
				array_push(__events, buffer_read(_buffer, buffer_f64)); // Frame
				array_push(__events, buffer_read(_buffer, buffer_string)); // Event name
			}
		}

		IsLoaded = true;

		return self;
	};

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes animation data to a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to write the data to.
	///
	/// @return {Struct.BBMOD_Animation} Returns `self`.
	static to_buffer = function (_buffer) {
		buffer_write(_buffer, buffer_string, "BBANIM");
		buffer_write(_buffer, buffer_u8, VersionMajor);
		buffer_write(_buffer, buffer_u8, VersionMinor);

		buffer_write(_buffer, buffer_u8, __spaces);
		buffer_write(_buffer, buffer_f64, Duration);
		buffer_write(_buffer, buffer_f64, TicsPerSecond);

		buffer_write(_buffer, buffer_u32, __modelNodeCount);
		buffer_write(_buffer, buffer_u32, __modelBoneCount);

		var d = 0;
		repeat (Duration)
		{
			if (__spaces & BBMOD_BONE_SPACE_PARENT)
			{
				bbmod_array_to_buffer(__framesParent[d], _buffer, buffer_f32);
			}

			if (__spaces & BBMOD_BONE_SPACE_WORLD)
			{
				bbmod_array_to_buffer(__framesWorld[d], _buffer, buffer_f32);
			}

			if (__spaces & BBMOD_BONE_SPACE_BONE)
			{
				bbmod_array_to_buffer(__framesBone[d], _buffer, buffer_f32);
			}

			++d;
		}

		var _eventCount = array_length(__events) / 2;
		buffer_write(_buffer, buffer_u32, _eventCount);

		var i = 0;
		repeat (_eventCount)
		{
			buffer_write(_buffer, buffer_f64, __events[i]);
			buffer_write(_buffer, buffer_string, __events[i + 1]);
			i += 2;
		}

		return self;
	};

	if (_file != undefined)
	{
		from_file(_file, _sha1);
	}

	/// @func create_transition(_timeFrom, _animTo, _timeTo)
	///
	/// @desc Creates a new animation transition.
	///
	/// @param {Real} _timeFrom Animation time of this animation that we are
	/// transitioning from.
	/// @param {Struct.BBMOD_Animation} _animTo The animation to transition to.
	/// @param {Real} _timeTo Animation time of the target animation.
	///
	/// @return {Struct.BBMOD_Animation} The created transition or `undefined`
	/// if the animations have different optimization levels or if they do not
	/// support transitions.
	static create_transition = function (_timeFrom, _animTo, _timeTo) {
		if ((__spaces & (BBMOD_BONE_SPACE_PARENT | BBMOD_BONE_SPACE_WORLD)) == 0
			|| __spaces != _animTo.__spaces)
		{
			return undefined;
		}

		var _transition = new BBMOD_Animation();
		_transition.IsLoaded = true;
		_transition.VersionMajor = VersionMajor;
		_transition.VersionMinor = VersionMinor;
		_transition.__spaces = (__spaces & BBMOD_BONE_SPACE_PARENT)
			? BBMOD_BONE_SPACE_PARENT
			: BBMOD_BONE_SPACE_WORLD;
		_transition.Duration = round((TransitionOut + _animTo.TransitionIn)
			* TicsPerSecond);
		_transition.TicsPerSecond = TicsPerSecond;
		_transition.__isTransition = true;

		var _frameFrom, _frameTo, _framesDest;

		if (__spaces & BBMOD_BONE_SPACE_PARENT)
		{
			_frameFrom = __framesParent[_timeFrom];
			_frameTo = _animTo.__framesParent[_timeTo];
			_framesDest = _transition.__framesParent;
		}
		else
		{
			_frameFrom = __framesWorld[_timeFrom];
			_frameTo = _animTo.__framesWorld[_timeTo];
			_framesDest = _transition.__framesWorld;
		}

		var _time = 0;
		repeat (_transition.Duration)
		{
			var _frameSize = array_length(_frameFrom);
			var _frame = array_create(_frameSize);

			var i = 0;
			repeat (_frameSize / 8)
			{
				var _factor = _time / _transition.Duration;

				// First dual quaternion
				var _dq10 = _frameFrom[i];
				var _dq11 = _frameFrom[i + 1];
				var _dq12 = _frameFrom[i + 2];
				var _dq13 = _frameFrom[i + 3];
				// (* 2 since we use this only in the translation reconstruction)
				var _dq14 = _frameFrom[i + 4] * 2;
				var _dq15 = _frameFrom[i + 5] * 2;
				var _dq16 = _frameFrom[i + 6] * 2;
				var _dq17 = _frameFrom[i + 7] * 2;

				// Second dual quaternion
				var _dq20 = _frameTo[i];
				var _dq21 = _frameTo[i + 1];
				var _dq22 = _frameTo[i + 2];
				var _dq23 = _frameTo[i + 3];
				// (* 2 since we use this only in the translation reconstruction)
				var _dq24 = _frameTo[i + 4] * 2;
				var _dq25 = _frameTo[i + 5] * 2;
				var _dq26 = _frameTo[i + 6] * 2;
				var _dq27 = _frameTo[i + 7] * 2;

				// Lerp between reconstructed translations
				var _pos0 = lerp(
					_dq17 * (-_dq10) + _dq14 * _dq13 + _dq15 * (-_dq12) - _dq16 * (-_dq11),
					_dq27 * (-_dq20) + _dq24 * _dq23 + _dq25 * (-_dq22) - _dq26 * (-_dq21),
					_factor
				);

				var _pos1 = lerp(
					_dq17 * (-_dq11) + _dq15 * _dq13 + _dq16 * (-_dq10) - _dq14 * (-_dq12),
					_dq27 * (-_dq21) + _dq25 * _dq23 + _dq26 * (-_dq20) - _dq24 * (-_dq22),
					_factor
				);

				var _pos2 = lerp(
					_dq17 * (-_dq12) + _dq16 * _dq13 + _dq14 * (-_dq11) - _dq15 * (-_dq10),
					_dq27 * (-_dq22) + _dq26 * _dq23 + _dq24 * (-_dq21) - _dq25 * (-_dq20),
					_factor
				);

				// Slerp rotations and store result into _dq1
				var _norm;

				_norm = 1 / sqrt(_dq10 * _dq10
					+ _dq11 * _dq11
					+ _dq12 * _dq12
					+ _dq13 * _dq13);

				_dq10 *= _norm;
				_dq11 *= _norm;
				_dq12 *= _norm;
				_dq13 *= _norm;

				_norm = sqrt(_dq20 * _dq20
					+ _dq21 * _dq21
					+ _dq22 * _dq22
					+ _dq23 * _dq23);

				_dq20 *= _norm;
				_dq21 *= _norm;
				_dq22 *= _norm;
				_dq23 *= _norm;

				var _dot = _dq10 * _dq20
					+ _dq11 * _dq21
					+ _dq12 * _dq22
					+ _dq13 * _dq23;

				if (_dot < 0)
				{
					_dot = -_dot;
					_dq20 *= -1;
					_dq21 *= -1;
					_dq22 *= -1;
					_dq23 *= -1;
				}

				if (_dot > 0.9995)
				{
					_dq10 = lerp(_dq10, _dq20, _factor);
					_dq11 = lerp(_dq11, _dq21, _factor);
					_dq12 = lerp(_dq12, _dq22, _factor);
					_dq13 = lerp(_dq13, _dq23, _factor);
				}
				else
				{
					var _theta0 = arccos(_dot);
					var _theta = _theta0 * _factor;
					var _sinTheta = sin(_theta);
					var _sinTheta0 = sin(_theta0);
					var _s2 = _sinTheta / _sinTheta0;
					var _s1 = cos(_theta) - (_dot * _s2);

					_dq10 = (_dq10 * _s1) + (_dq20 * _s2);
					_dq11 = (_dq11 * _s1) + (_dq21 * _s2);
					_dq12 = (_dq12 * _s1) + (_dq22 * _s2);
					_dq13 = (_dq13 * _s1) + (_dq23 * _s2);
				}

				// Create new dual quaternion from translation and rotation and
				// write it into the frame
				_frame[@ i]     = _dq10;
				_frame[@ i + 1] = _dq11;
				_frame[@ i + 2] = _dq12;
				_frame[@ i + 3] = _dq13;
				_frame[@ i + 4] = (+_pos0 * _dq13 + _pos1 * _dq12 - _pos2 * _dq11) * 0.5;
				_frame[@ i + 5] = (+_pos1 * _dq13 + _pos2 * _dq10 - _pos0 * _dq12) * 0.5;
				_frame[@ i + 6] = (+_pos2 * _dq13 + _pos0 * _dq11 - _pos1 * _dq10) * 0.5;
				_frame[@ i + 7] = (-_pos0 * _dq10 - _pos1 * _dq11 - _pos2 * _dq12) * 0.5;

				i += 8;
			}

			array_push(_framesDest, _frame);
			++_time;
		}

		return _transition;
	};
}
