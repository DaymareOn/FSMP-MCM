; Minimal stub for CI builds - SKSE StringUtil
Scriptname StringUtil Hidden

int Function GetLength(string s) global native
string Function GetNthChar(string s, int index) global native
int Function Find(string s, string toFind, int startIndex = 0) global native
string Function Substring(string s, int startIndex, int len = 0) global native
int Function AsOrd(string c) global native
string Function AsChar(int c) global native
string[] Function Split(string s, string delim) global native
