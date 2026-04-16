; Minimal stub for CI builds - PapyrusUtil MiscUtil
scriptname MiscUtil Hidden

string[] function FilesInFolder(string directory, string extension="*") global native
string function ReadFromFile(string fileName) global native
bool function WriteToFile(string fileName, string text, bool append = true, bool timestamp = false) global native
