/// @func BBMOD_AnimationStateMachine(_animationPlayer)
///
/// @extends BBMOD_StateMachine
///
/// @desc A state machine that controls animation playback.
///
/// @param {Struct.BBMOD_AnimationPlayer} _animationPlayer The animation player
/// to control.
///
/// @example
/// Following code shows an animation state machine which goes to the "Idle"
/// state on start and independently on the current state switches to "Dead"
/// state when variable `hp` meets 0. After the death animation ends, the state
/// machine enters the final state and the instance is destroyed.
///
/// ```gml
/// // Create event
/// destroy = false;
/// animationPlayer = new BBMOD_AnimationPlayer(model);
///
/// animationStateMachine = new BBMOD_AnimationStateMachine(animationPlayer);
/// animationStateMachine.OnEnter = method(self, function () {
///     animationStateMachine.change_state(stateIdle);
/// });
/// animationStateMachine.OnExit = method(self, function () {
///     destroy = true;
/// });
/// animationStateMachine.OnPreUpdate = method(self, function () {
///     if (hp <= 0 && animationStateMachine.State != stateDead)
///     {
///         animationStateMachine.change_state(stateDead);
///     }
/// });
///
/// stateIdle = new BBMOD_AnimationState("Idle", animIdle);
/// animationStateMachine.add_state(stateIdle);
///
/// stateDead = new BBMOD_AnimationState("Dead", animDead);
/// stateDead.on_event(BBMOD_EV_ANIMATION_END, method(self, function () {
///     animationStateMachine.finish();
/// }));
/// animationStateMachine.add_state(stateDead);
///
/// animationStateMachine.start();
/// 
/// // Step event
/// animationStateMachine.update();
/// if (destroy)
/// {
///     instance_destroy();
/// }
/// 
/// // Clean Up event
/// animationPlayer = animationPlayer.destroy();
/// animationStateMachine = animationStateMachine.destroy();
/// ```
///
/// @see BBMOD_AnimationPlayer
/// @see BBMOD_AnimationState
function BBMOD_AnimationStateMachine(_animationPlayer)
	: BBMOD_StateMachine() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static StateMachine_update = update;

	/// @var {Struct.BBMOD_AnimationPlayer} The state machine's animation player.
	/// @readonly
	AnimationPlayer = _animationPlayer;

	AnimationPlayer.on_event(method(self, function (_data, _event) {
		if (State != undefined)
		{
			State.trigger_event(_event, _data);
		}
	}));

	static update = function (_deltaTime) {
		StateMachine_update(_deltaTime);
		if (State != undefined)
		{
			AnimationPlayer.change(State.Animation, State.Loop);
		}
		AnimationPlayer.update(_deltaTime);
		return self;
	};
}
