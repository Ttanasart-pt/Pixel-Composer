/// @macro {Real} Maximum number of bones that a single model can have.
/// Equals to 128.
#macro BBMOD_MAX_BONES 128

/// @macro {String} An event triggered when an animation player changes to a
/// different animation. The event data will contain the previous animation.
/// You can retrieve the new animation using
/// {@link BBMOD_AnimationPlayer.Animation}.
/// @see BBMOD_AnimationPlayer.on_event
#macro BBMOD_EV_ANIMATION_CHANGE "bbmod_ev_animation_change"

/// @macro {String} An event triggered when an animation finishes playing. The
/// event data will contain the animation that ended.
/// @see BBMOD_AnimationPlayer.on_event
#macro BBMOD_EV_ANIMATION_END "bbmod_ev_animation_end"

/// @macro {String} An event triggered when an animation loops and continues
/// playing from the start. The event data will contain the animation that
/// looped.
/// @see BBMOD_AnimationPlayer.on_event
#macro BBMOD_EV_ANIMATION_LOOP "bbmod_ev_animation_loop"

#macro __BBMOD_EV_ALL "__bbmod_ev_all"

/// @func BBMOD_AnimationPlayer(_model[, _paused])
///
/// @extends BBMOD_Class
///
/// @implements {BBMOD_IEventListener}
/// @implements {BBMOD_IRenderable}
///
/// @desc An animation player. Each instance of an animated model should have
/// its own animation player.
///
/// @param {Struct.BBMOD_Model} _model A model that the animation player
/// animates.
/// @param {Bool} [_paused] If `true` then the animation player is created
/// as paused. Defaults to `false`.
///
/// @example
/// Following code shows how to load models and animations in a resource manager
/// object and then play animations in multiple instances of another object.
///
/// ```gml
/// /// @desc Create event of OResourceManager
/// modCharacter = new BBMOD_Model("character.bbmod");
/// animIdle = new BBMOD_Animation("idle.bbanim");
///
/// /// @desc Create event of OCharacter
/// model = OResourceManager.modCharacter;
/// animationPlayer = new BBMOD_AnimationPlayer(model);
/// animationPlayer.play(OResourceManager.animIdle, true);
///
/// /// @desc Step event of OCharacter
/// animationPlayer.update(delta_time);
///
/// /// @desc Draw event of OCharacter
/// bbmod_material_reset();
/// animationPlayer.render();
/// bbmod_material_reset();
/// ```
///
/// @see BBMOD_Animation
/// @see BBMOD_IEventListener
/// @see BBMOD_Model
function BBMOD_AnimationPlayer(_model, _paused=false)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	implement(BBMOD_IEventListener);

	static Class_destroy = destroy;

	/// @var {Struct.BBMOD_Model} A model that the animation player animates.
	/// @readonly
	Model = _model;

	/// @var {Id.DsList<Struct.BBMOD_Animation>} List of animations to play.
	/// @private
	__animations = ds_list_create();

	/// @var {Struct.BBMOD_Animation} The currently playing animation or
	/// `undefined`.
	/// @readonly
	Animation = undefined;

	/// @var {Bool} If true then {@link BBMOD_AnimationPlayer.Animation} loops.
	/// @readonly
	AnimationLoops = false;

	/// @var {Struct.BBMOD_Animation}
	/// @private
	__animationLast = undefined;

	/// @var {Struct.BBMOD_AnimationInstance}
	/// @private
	__animationInstanceLast = undefined;

	/// @var {Array<Struct.BBMOD_Vec3>} Array of node position overrides.
	/// @private
	__nodePositionOverride = array_create(BBMOD_MAX_BONES, undefined);

	/// @var {Array<Struct.BBMOD_Quaternion>} Array of node rotation
	/// overrides.
	/// @private
	__nodeRotationOverride = array_create(BBMOD_MAX_BONES, undefined);

	/// @var {Array<Struct.BBMOD_Quaternion>} Array of node post-rotations.
	/// @private
	__nodeRotationPost = array_create(BBMOD_MAX_BONES, undefined);

	/// @var {Bool} If `true`, then the animation playback is paused.
	Paused = _paused;

	/// @var {Real} The current animation playback time.
	/// @readonly
	Time = 0;

	/// @var {Array<Real>}
	/// @private
	__frame = undefined;

	/// @var {Real} Number of frames (calls to {@link BBMOD_AnimationPlayer.update})
	/// to skip. Defaults to 0 (frame skipping is disabled). Increasing the
	/// value increases performance. Use `infinity` to disable computing
	/// animation frames entirely.
	/// @note This does not affect animation events. These are still triggered
	/// even if the frame is skipped.
	Frameskip = 0;

	/// @var {Real}
	/// @private
	__frameskipCurrent = 0;

	/// @var {Real} Controls animation playback speed. Must be a positive
	/// number!
	PlaybackSpeed = 1;

	/// @var {Array<Real>} An array of node transforms in world space.
	/// Useful for attachments.
	/// @see BBMOD_AnimationPlayer.get_node_transform
	/// @private
	__nodeTransform = array_create(BBMOD_MAX_BONES * 8, 0.0);

	/// @var {Array<Real>} An array containing transforms of all bones.
	/// Used to pass current model pose as a uniform to a vertex shader.
	/// @see BBMOD_AnimationPlayer.get_transform
	/// @private
	__transformArray = array_create(BBMOD_MAX_BONES * 8, 0.0);

	static animate = function (_animationInstance, _animationTime) {
		var _model = Model;
		var _animation = _animationInstance.Animation;
		var _frame = _animation.__framesParent[_animationTime];
		__frame = _frame;
		var _transformArray = __transformArray;
		var _offsetArray = _model.__offsetArray;
		var _nodeTransform = __nodeTransform;
		var _positionOverrides = __nodePositionOverride;
		var _rotationOverrides = __nodeRotationOverride;
		var _rotationPost = __nodeRotationPost;

		static _animStack = [];
		if (array_length(_animStack) < _model.NodeCount)
		{
			array_resize(_animStack, _model.NodeCount);
		}

		_animStack[@ 0] = _model.RootNode;
		var _stackNext = 1;

		repeat (_model.NodeCount)
		{
			if (_stackNext == 0)
			{
				break;
			}

			var _node = _animStack[--_stackNext];

			// TODO: Separate skeleton from the rest of the nodes to save on
			// iterations here.

			var _nodeIndex = _node.Index;
			var _nodeOffset = _nodeIndex * 8;
			var _nodePositionOverride = _positionOverrides[_nodeIndex];
			var _nodeRotationOverride = _rotationOverrides[_nodeIndex];
			var _nodeRotationPost = _rotationPost[_nodeIndex];
			var _nodeParent = _node.Parent;
			var _parentIndex = (_nodeParent != undefined) ? _nodeParent.Index : -1;

			if (_nodePositionOverride != undefined
				|| _nodeRotationOverride != undefined
				|| _nodeRotationPost != undefined)
			{
				var _dq = new BBMOD_DualQuaternion().FromArray(_frame, _nodeOffset);
				var _position = (_nodePositionOverride != undefined)
					? _nodePositionOverride
					: _dq.GetTranslation();
				var _rotation = (_nodeRotationOverride != undefined)
					? _nodeRotationOverride
					: _dq.GetRotation();
				if (_nodeRotationPost != undefined)
				{
					_rotation = _nodeRotationPost.Mul(_rotation);
				}
				_dq.FromTranslationRotation(_position, _rotation);
				if (_parentIndex != -1)
				{
					_dq = _dq.Mul(new BBMOD_DualQuaternion()
						.FromArray(_nodeTransform, _parentIndex * 8));
				}
				_dq.ToArray(_nodeTransform, _nodeOffset);
			}
			else
			{
				if (_parentIndex == -1)
				{
					// No parent transform -> just copy the node transform
					array_copy(_nodeTransform, _nodeOffset, _frame, _nodeOffset, 8);
				}
				else
				{
					// Multiply node transform with parent's transform
					__bbmod_dual_quaternion_array_multiply(
						_frame, _nodeOffset, _nodeTransform, _parentIndex * 8,
						_nodeTransform, _nodeOffset);
				}
			}

			if (_node.IsBone)
			{
				__bbmod_dual_quaternion_array_multiply(
					_offsetArray, _nodeOffset,
					_nodeTransform, _nodeOffset,
					_transformArray, _nodeOffset);
			}

			var _children = _node.Children;
			var i = 0;
			repeat (array_length(_children))
			{
				_animStack[_stackNext++] = _children[i++];
			}
		}
	}

	/// @func update(_deltaTime)
	///
	/// @desc Updates the animation player. This should be called every frame in
	/// the step event.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	///
	/// @return {Struct.BBMOD_AnimationPlayer} Returns `self`.
	static update = function (_deltaTime) {
		if (!Model.IsLoaded)
		{
			return self;
		}

		if (Paused)
		{
			return self;
		}

		Time += _deltaTime * 0.000001 * PlaybackSpeed;

		repeat (ds_list_size(__animations))
		{
			var _animInst = __animations[| 0];
			var _animation = _animInst.Animation;

			if (!_animation.IsLoaded)
			{
				break;
			}

			var _animationTime = _animation.get_animation_time(Time);

			if (_animationTime >= _animation.Duration)
			{
				if (_animInst.Loop)
				{
					Time %= (_animation.Duration / _animation.TicsPerSecond);
					_animationTime %= _animation.Duration;
					_animInst.__eventExecuted = -1;
					trigger_event(BBMOD_EV_ANIMATION_LOOP, _animation);
				}
				else
				{
					Time = 0.0;
					ds_list_delete(__animations, 0);
					if (!_animation.__isTransition)
					{
						Animation = undefined;
						trigger_event(BBMOD_EV_ANIMATION_END, _animation);
					}
					continue;
				}
			}

			_animInst.__animationTime = _animationTime;

			var _nodeSize = Model.NodeCount * 8;
			if (array_length(__nodeTransform) < _nodeSize)
			{
				array_resize(__nodeTransform, _nodeSize);
			}

			var _boneSize = Model.BoneCount * 8;
			if (array_length(__transformArray) != _boneSize)
			{
				array_resize(__transformArray, _boneSize);
			}

			var _animEvents = _animation.__events;
			var _eventIndex = 0;
			var _eventExecuted = _animInst.__eventExecuted;

			repeat (array_length(_animEvents) / 2)
			{
				var _eventFrame = _animEvents[_eventIndex];
				if (_eventFrame <= _animationTime && _eventExecuted < _eventFrame)
				{
					trigger_event(_animEvents[_eventIndex + 1], _animation);
				}
				_eventIndex += 2;
			}

			_animInst.__eventExecuted = _animationTime;

			//static _iters = 0;
			//static _sum = 0;
			//var _t = get_timer();

			if (__frameskipCurrent == 0)
			{
				if (_animation.__spaces & BBMOD_BONE_SPACE_BONE)
				{
					if (_animation.__spaces & BBMOD_BONE_SPACE_WORLD)
					{
						array_copy(__nodeTransform, 0,
							_animation.__framesWorld[_animationTime], 0, _nodeSize);
					}

					// TODO: Just use the animation's array right away?
					array_copy(__transformArray, 0,
						_animation.__framesBone[_animationTime], 0, _boneSize);
				}
				else if (_animation.__spaces & BBMOD_BONE_SPACE_WORLD)
				{
					var _frame = _animation.__framesWorld[_animationTime];
					var _transformArray = __transformArray;
					var _offsetArray = Model.__offsetArray;

					array_copy(__nodeTransform, 0, _frame, 0, _nodeSize);
					array_copy(_transformArray, 0, _frame, 0, _boneSize);

					var _index = 0;
					repeat (Model.BoneCount)
					{
						__bbmod_dual_quaternion_array_multiply(
							_offsetArray, _index,
							_frame, _index,
							_transformArray, _index);
						_index += 8;
					}
				}
				else if (_animation.__spaces & BBMOD_BONE_SPACE_PARENT)
				{
					animate(_animInst, _animationTime);
				}

				array_copy(__transformArray, _boneSize, __nodeTransform, _boneSize,
					_nodeSize - _boneSize);
			}

			if (Frameskip == infinity)
			{
				__frameskipCurrent = -1;
			}
			else if (++__frameskipCurrent > Frameskip)
			{
				__frameskipCurrent = 0;
			}

			//var _current = get_timer() - _t;
			//_sum += _current;
			//++_iters;
			//show_debug_message("Current: " + string(_current) + "μs");
			//show_debug_message("Average: " + string(_sum / _iters) + "μs");

			__animationInstanceLast = _animInst;
		}

		return self;
	};

	/// @func play(_animation[, _loop])
	///
	/// @desc Starts playing an animation from its start.
	///
	/// @param {Struct.BBMOD_Animation} _animation An animation to play.
	/// @param {Bool} [_loop] If `true` then the animation will be looped.
	/// Defaults to `false`.
	///
	/// @return {Struct.BBMOD_AnimationPlayer} Returns `self`.
	static play = function (_animation, _loop=false) {
		Animation = _animation;
		AnimationLoops = _loop;

		if (__animationLast != _animation)
		{
			trigger_event(BBMOD_EV_ANIMATION_CHANGE, Animation);
			__animationLast = _animation;
		}

		Time = 0;

		var _animationList = __animations;
		var _animationLast = __animationInstanceLast;

		ds_list_clear(_animationList);

		if (_animationLast != undefined
			&& _animationLast.Animation.TransitionOut + _animation.TransitionIn > 0)
		{
			var _transition = _animationLast.Animation.create_transition(
				_animationLast.__animationTime,
				_animation,
				0);

			if (_transition != undefined)
			{
				ds_list_add(_animationList, new BBMOD_AnimationInstance(_transition));
			}
		}

		var _animationInstance = new BBMOD_AnimationInstance(_animation);
		_animationInstance.Loop = AnimationLoops;
		ds_list_add(_animationList, _animationInstance);

		return self;
	};

	/// @func change(_animation[, _loop])
	///
	/// @desc Starts playing an animation from its start, only if it is a
	/// different one that the last played animation.
	///
	/// @param {Struct.BBMOD_Animation} _animation The animation to change to,
	/// @param {Bool} [_loop] If `true` then the animation will be looped.
	/// Defaults to `false`.
	///
	/// @return {Struct.BBMOD_AnimationPlayer} Returns `self`.
	///
	/// @see BBMOD_AnimationPlayer.Animation
	static change = function (_animation, _loop=false) {
		gml_pragma("forceinline");
		if (Animation != _animation)
		{
			play(_animation, _loop);
		}
		return self;
	};

	/// @func get_transform()
	///
	/// @desc Returns an array of current transformations of all bones. This
	/// should be passed to a vertex shader.
	///
	/// @return {Array<Real>} The transformation array.
	static get_transform = function () {
		gml_pragma("forceinline");
		return __transformArray;
	};

	/// @func get_node_transform(_nodeIndex)
	///
	/// @desc Returns a transformation (dual quaternion) of a node, which can be
	/// used for example for attachments.
	///
	/// @param {Real} _nodeIndex An index of a node.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The transformation.
	///
	/// @see BBMOD_Model.find_node_id
	static get_node_transform = function (_nodeIndex) {
		gml_pragma("forceinline");
		return new BBMOD_DualQuaternion().FromArray(__nodeTransform, _nodeIndex * 8);
	};

	/// @func get_node_transform_from_frame(_nodeIndex)
	///
	/// @desc Returns a transformation (dual quaternion) of a node from the last
	/// animation frame. This is useful if you want to add additional
	/// transformations onto an animated bone, instead of competely replacing it.
	///
	/// @param {Real} _nodeIndex An index of a node.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The transformation.
	///
	/// @see BBMOD_Model.find_node_id
	/// @see BBMOD_AnimationPlayer.get_node_transform
	static get_node_transform_from_frame = function (_nodeIndex) {
		gml_pragma("forceinline");
		if (__frame == undefined)
		{
			return new BBMOD_DualQuaternion();
		}
		return new BBMOD_DualQuaternion().FromArray(__frame, _nodeIndex * 8);
	};

	/// @func set_node_position(_nodeIndex, _position)
	///
	/// @desc Overrides a position of a node.
	///
	/// @param {Real} _nodeIndex An index of a node.
	/// @param {Struct.BBMOD_Vec3} _position A new position of a node. Use
	/// `undefined` to unset the position override.
	///
	/// @return {Struct.BBMOD_AnimationPlayer} Returns `self`.
	static set_node_position = function (_nodeIndex, _position) {
		gml_pragma("forceinline");
		__nodePositionOverride[@ _nodeIndex] = _position;
		return self;
	};

	/// @func set_node_rotation(_nodeIndex, _rotation)
	///
	/// @desc Overrides a rotation of a node.
	///
	/// @param {Real} _nodeIndex An index of a node.
	/// @param {Struct.BBMOD_Quaternion} _rotation A new rotation of a node.
	/// Use `undefined` to unset the rotation override.
	///
	/// @return {Struct.BBMOD_AnimationPlayer} Returns `self`.
	static set_node_rotation = function (_nodeIndex, _rotation) {
		gml_pragma("forceinline");
		__nodeRotationOverride[@ _nodeIndex] = _rotation;
		return self;
	};

	/// @func set_node_rotation_post(_nodeIndex, _rotation)
	///
	/// @desc Sets a post-rotation of a node.
	///
	/// @param {Real} _nodeIndex An index of a node.
	/// @param {Struct.BBMOD_Quaternion} _rotation A rotation applied after the
	/// node is rotated using frame data. Use `undefined` to unset the post-rotation.
	///
	/// @return {Struct.BBMOD_AnimationPlayer} Returns `self`.
	static set_node_rotation_post = function (_nodeIndex, _rotation) {
		gml_pragma("forceinline");
		__nodeRotationPost[@ _nodeIndex] = _rotation;
		return self;
	};

	/// @func submit([_materials])
	///
	/// @desc Immediately submits the animated model for rendering.
	///
	/// @param {Array<Struct.BBMOD_Material>} [_materials] An array of materials,
	/// one for each material slot of the model. If not specified, then
	/// {@link BBMOD_Model.Materials} is used. Defaults to `undefined`.
	///
	/// @return {Struct.BBMOD_AnimationPlayer} Returns `self`.
	static submit = function (_materials=undefined) {
		gml_pragma("forceinline");
		Model.submit(_materials, get_transform());
		return self;
	};

	/// @func render([_materials])
	///
	/// @desc Enqueues the animated model for rendering.
	///
	/// @param {Array<Struct.BBMOD_Material>} [_materials] An array of materials,
	/// one for each material slot of the model. If not specified, then
	/// {@link BBMOD_Model.Materials} is used. Defaults to `undefined`.
	///
	/// @return {Struct.BBMOD_AnimationPlayer} Returns `self`.
	static render = function (_materials=undefined) {
		gml_pragma("forceinline");
		Model.render(_materials, get_transform());
		return self;
	};

	static destroy = function () {
		Class_destroy();
		ds_list_destroy(__animations);
		__nodePositionOverride = undefined;
		__nodeRotationOverride = undefined;
		__nodeRotationPost = undefined;
		return undefined;
	};
}
