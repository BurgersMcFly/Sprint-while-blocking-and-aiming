// SprintWhileBlockingAndAiming, Cyberpunk 2077 mod that enables sprinting while blocking and aiming
// Copyright (C) 2022 BurgersMcFly

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

@replaceMethod(SprintDecisions)

 protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let enterAngleThreshold: Float;
    let isAiming: Bool;
    let isChargingCyberware: Bool;
    let lastShotTime: StateResultFloat;
    let minLinearVelocityThreshold: Float;
    let minStickInputThreshold: Float;
    let superResult: Bool;
    if !this.m_sprintPressed && !this.m_toggleSprintPressed && !stateContext.GetConditionBool(n"SprintToggled") {
      this.EnableOnEnterCondition(false);
      return false;
    };
    superResult = super.EnterCondition(stateContext, scriptInterface) && this.IsTouchingGround(scriptInterface);
    minLinearVelocityThreshold = this.GetStaticFloatParameterDefault("minLinearVelocityThreshold", 0.50);
    minStickInputThreshold = this.GetStaticFloatParameterDefault("minStickInputThreshold", 0.90);
    enterAngleThreshold = this.GetStaticFloatParameterDefault("enterAngleThreshold", -180.00);
    if !scriptInterface.HasStatFlag(gamedataStatType.CanSprint) {
      return false;
    };
    if !scriptInterface.IsMoveInputConsiderable() || AbsF(scriptInterface.GetInputHeading()) > enterAngleThreshold || DefaultTransition.GetMovementInputActionValue(stateContext, scriptInterface) <= minStickInputThreshold || scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) < minLinearVelocityThreshold {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return false;
    };
    isAiming = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim);
    if isAiming {
      return true;
    };
    isChargingCyberware = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware) == EnumInt(gamePSMLeftHandCyberware.Charge);
    if isChargingCyberware {
      return false;
    };
    if DefaultTransition.IsChargingWeapon(scriptInterface) {
      return false;
    };
    if !MeleeTransition.MeleeSprintStateCondition(stateContext, scriptInterface) {
      return false;
    };
    lastShotTime = stateContext.GetPermanentFloatParameter(n"LastShotTime");
    if lastShotTime.valid {
      if EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame())) - lastShotTime.value < this.GetStaticFloatParameterDefault("sprintDisableTimeAfterShoot", -2.00) {
        return false;
      };
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponShootWhileSprinting) && scriptInterface.GetActionValue(n"RangedAttack") > 0.00 {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().CoverAction.coverActionStateId) == 3 {
      return false;
    };
    if this.m_toggleSprintPressed && !stateContext.GetBoolParameter(n"sprintInputLock", true) {
      stateContext.SetConditionBoolParameter(n"SprintToggled", true, true);
    };
    if !superResult {
      return false;
    };
    if stateContext.GetConditionBool(n"SprintToggled") && !stateContext.GetBoolParameter(n"sprintInputLock", true) {
      return true;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponReloadWhileSprinting) && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon) == EnumInt(gamePSMRangedWeaponStates.Reload) {
      if scriptInterface.IsActionJustPressed(n"Sprint") && !stateContext.GetBoolParameter(n"sprintInputLock", true) {
        return true;
      };
    } else {
      if this.m_sprintPressed && !stateContext.GetBoolParameter(n"sprintInputLock", true) {
        return true;
      };
    };
    return false;
  }