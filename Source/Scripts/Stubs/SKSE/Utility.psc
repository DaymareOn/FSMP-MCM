; Minimal stub for CI builds - SKSE Utility
Scriptname Utility Hidden

string[] Function CreateStringArray(int size, string fill = "") global native
string[] Function ResizeStringArray(string[] source, int size, string fill = "") global native
float Function Wait(float afSeconds) native global
Function WaitMenuMode(float afSeconds) native global
float Function RandomFloat(float afMin = 0.0, float afMax = 1.0) native global
int Function RandomInt(int aiMin = 0, int aiMax = 100) native global
float Function GetCurrentRealTime() global native
float Function GetCurrentGameTime() global native
float Function GetINIFloat(string ini) global native
int Function GetINIInt(string ini) global native
Function SetINIFloat(string ini, float value) global native
Function SetINIInt(string ini, int value) global native
bool Function IsInMenuMode() global native
