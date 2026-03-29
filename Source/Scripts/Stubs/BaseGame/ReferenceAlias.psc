; Minimal stub for CI builds
Scriptname ReferenceAlias extends Alias Hidden

Function AddInventoryEventFilter(Form akFilter) native
Function Clear() native
ObjectReference Function GetReference() native
Function ForceRefTo(ObjectReference akNewRef) native
Function RemoveAllInventoryEventFilters() native
Function RemoveInventoryEventFilter(Form akFilter) native

Actor Function GetActorReference()
  return GetReference() as Actor
endFunction

ObjectReference Function GetRef()
  return GetReference()
endFunction

Actor Function GetActorRef()
  return GetActorReference()
endFunction

Event OnActivate(ObjectReference akActionRef)
EndEvent

Event OnInit()
EndEvent

Event OnLoad()
EndEvent

Event OnUnload()
EndEvent

Event OnCellAttach()
EndEvent

Event OnCellDetach()
EndEvent

Event OnReset()
EndEvent
