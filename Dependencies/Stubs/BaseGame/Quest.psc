; Minimal stub for CI builds
Scriptname Quest extends Form Hidden

Function CompleteAllObjectives() native
Function CompleteQuest() native
Function FailAllObjectives() native
Alias Function GetAlias(int aiAliasID) native
int Function GetCurrentStageID() native
bool Function IsActive() native
bool Function IsCompleted() native
bool Function IsObjectiveCompleted(int aiObjective) native
bool Function IsObjectiveDisplayed(int aiObjective) native
bool Function IsObjectiveFailed(int aiObjective) native
bool Function IsRunning() native
bool Function IsStageDone(int aiStage) native
bool Function IsStarting() native
bool Function IsStopping() native
bool Function IsStopped() native
Function Reset() native
Function SetActive(bool abActive = true) native
bool Function SetCurrentStageID(int aiStageID) native
Function SetObjectiveCompleted(int aiObjective, bool abCompleted = true) native
Function SetObjectiveDisplayed(int aiObjective, bool abDisplayed = true, bool abForce = false) native
Function SetObjectiveFailed(int aiObjective, bool abFailed = true) native
bool Function Start() native
Function Stop() native
bool Function UpdateCurrentInstanceGlobal(GlobalVariable aUpdateGlobal) native

int Function GetStage()
  return GetCurrentStageID()
EndFunction

bool Function GetStageDone(int aiStage)
  return IsStageDone(aiStage)
EndFunction

bool Function SetStage(int aiStage)
  return SetCurrentStageID(aiStage)
EndFunction
