﻿#MaxMem 256
#Include <CLR>
SetBatchLines, -1
FileEncoding, UTF-8-RAW


ini := A_ScriptDir "\combo list.ini"
cs := A_ScriptDir "\Filter.cs"
comboListDir := "..\Combo Lists"
tldListDir := "..\TLD Lists"
fileName := "DD900 AGH Combo List"
theBigListFile := comboListDir "\The Big List.txt"
theBigCleanListFile := comboListDir "\The Big Clean List.txt"
regexOutFile := "..\" fileName " - Regex Blocklist.txt"
whitelistOutFile := "..\" fileName " - Whitelist.txt"
iplistOutFile := "..\" fileName " - IP Blocklist.txt"
thirdpartylistOutFile := "..\" fileName " - Third-Party Blocklist.txt"
asm := CLR_CompileC#(FileToVar(cs), "System.dll | System.Linq.dll | System.Collections.dll | System.Core.dll")
filter := CLR_CreateObject(asm, "Filter")


wwwList := ""
bigList := ""
whitelistOutText := ""
regexOutText := ""
ipOutText := ""
thirdpartyOutText := ""
outArray := []
outTextArray := []
outTextArrayIndex := 1
tldObj := {}


doNotCopyList := Sort2(UrlToVar("https://abp.oisd.nl/"), UrlToVar("https://block.energized.pro/basic/formats/filter"))
doNotCopyList := Sort2(doNotCopyList, UrlToVar("https://abl.arapurayil.com/filters/main.txt"))
doNotCopyList := Sort2(doNotCopyList, UrlToVar("https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt"))
doNotCopyList := Sort2(doNotCopyList, FileToVar("..\AdGuard_DNS_Blocklist.txt"))
doNotCopyList := Sort2(doNotCopyList, FileToVar("..\AdGuard_DNS_Whitelist.txt"))

Loop, Files, % comboListDir "\*.txt"
{
	if (A_LoopFileName = "The Big List.txt")
		continue
	
	bigList .= FileToVar(A_LoopFilePath)
	
	if (A_Index > 1)
		Sort, bigList, U
}

bigList := filter.FilterList(bigList, doNotCopyList)
doNotCopyList := ""

Loop, Parse, bigList, `n, `r
{
	if (!StartsWith(A_LoopField, "||www."))
		wwwList .= StrReplace(A_LoopField, "||www.", "||") "`n"
}

bigList := Sort2(bigList, wwwList)
wwwList := ""

Loop, Parse, bigList, `n, `r
{
	if (StartsWith(A_LoopField, "@@"))
		whitelistOutText .= A_LoopField "`n"
	else if (StartsWith(A_LoopField, "/"))
		regexOutText .= A_LoopField "`n"
	else if (IsIPEntry(A_LoopField))
		ipOutText .= A_LoopField "`n"
	else if (InStr(A_LoopField, "^$") && InStr(A_LoopField, "third-party"))
		thirdpartyOutText .= StrReplace(A_LoopField, StrSplit(A_LoopField, "$")[2], "third-party,script,popup") "`n"
	else {
		if (!StartsWith(A_LoopField, "||") || !EndsWith(A_LoopField, "^"))
			continue
		
		if (StartsWith(A_LoopField, "||www."))
			continue
		
		/*
		_Array := StrSplit(A_LoopField, ".", "|^")
		_l := _Array.Length()
		if (_l > 1) {
			tld := _Array[_l - 1] "." _Array[_l]
		
			if (!tldObj.HasKey(tld))
				tldObj[tld] := []
		}
	
		tldObj[tld].Push(A_LoopField)
		*/
		
		outTextArray[outTextArrayIndex] := A_LoopField
		
		if (outTextArrayIndex = 300000) {
			outArray.Push(outTextArray)
			outTextArray := []
			outTextArrayIndex := 1
		} else
			outTextArrayIndex += 1
	}
}

outArray.Push(outTextArray)
_l := outTextArray.Length()
outTextArray := ""

FileDelete, % theBigListFile
FileAppend, % bigList, % theBigListFile
bigList := ""

FileDelete, % whitelistOutFile
FileAppend, % whitelistOutText, % whitelistOutFile
whitelistOutText := ""

FileDelete, % regexOutFile
FileAppend, % regexOutText, % regexOutFile
regexOutText := ""

FileDelete, % iplistOutFile
FileAppend, % ipOutText, % iplistOutFile
ipOutText := ""

Sort, thirdpartyOutText, U
FileDelete, % thirdpartylistOutFile
FileAppend, % thirdpartyOutText, % thirdpartylistOutFile
thirdpartyOutText := ""

/*
for key, arr in tldObj {
	if (arr.Length() < 100) {
		tldObj.Delete(key)
		continue
	}

	outText := ""
	outFile := tldListDir "\" fileName " (" key ").txt"

	for i, v in arr
		outText .= v "`n"
	
	FileDelete, % outFile
	FileAppend, % outText, % outFile
	tldObj.Delete(key)
}
*/

FileDelete, % theBigCleanListFile

for index, arr in outArray {
	outText := ""
	outFile := "..\" fileName " (" index ").txt"

	for i, v in arr
		outText .= v "`n"
	
	FileDelete, % outFile
	FileAppend, % outText, % outFile
	FileAppend, % outText, % theBigCleanListFile
	outArray[index] := ""
}

ExitApp


Sort2(list1, list2) {
	list := list1 list2
	Sort, list, U
	return list
}
