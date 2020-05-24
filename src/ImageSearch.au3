#AutoIt3Wrapper_UseX64=n ; Set to Y or N depending on your situation/preference!!
#include-once
#Region ImageSearch library header
; --------------------------------------------------------------------------------
;
; AutoIt Version: 3.0
; Language:       English
; Description:    ImageSearch v2020.05 library
;                 The set of functions to search images on the screen screen
;                 Require that the ImageSearchDLLx86.dll/ImageSearchDLLx64.dll be loadable
; Original source code downloaded from:
; - http://www.autoitscript.com/forum/topic/65748-image-search-library/?p=746436
; - https://macroforge.wordpress.com/2019/06/08/using-image-search-in-autoit/ 
; Modified by Stanislav Povolotsky (stas.dev[at]povolotsky.info)
; - https://github.com/Stanislav-Povolotsky/ImageSearch-for-AutoIt/releases
;
; --------------------------------------------------------------------------------
#EndRegion

#include <WinAPIFiles.au3> ; for _WinAPI_Wow64EnableWow64FsRedirection

#Region When running compiled script, Install needed DLLs if they don't exist yet
If Not FileExists("ImageSearchDLLx86.dll") Then FileInstall("ImageSearchDLLx86.dll", "ImageSearchDLLx86.dll", 1);FileInstall ( "source", "dest" [, flag = 0] )
If Not FileExists("ImageSearchDLLx64.dll") Then FileInstall("ImageSearchDLLx64.dll", "ImageSearchDLLx64.dll", 1)
#EndRegion

Local $h_ImageSearchDLL = -1; Will become Handle returned by DllOpen() that will be referenced in the _ImageSearch* functions

#Region ImageSearch Startup/Shutdown
Func _ImageSearchStartup()
	_WinAPI_Wow64EnableWow64FsRedirection(True)
	$sOSArch = @OSArch ;Check if running on x64 or x32 Windows ;@OSArch Returns one of the following: "X86", "IA64", "X64" - this is the architecture type of the currently running operating system.
	$sAutoItX64 = @AutoItX64 ;Check if using x64 AutoIt ;@AutoItX64 Returns 1 if the script is running under the native x64 version of AutoIt.
	If $sOSArch = "X86" Or $sAutoItX64 = 0 Then	
		$h_ImageSearchDLL = DllOpen("ImageSearchDLLx86.dll")
		If $h_ImageSearchDLL = -1 Then Return "DllOpen failure"
	ElseIf $sOSArch = "X64" And $sAutoItX64 = 1 Then
		$h_ImageSearchDLL = DllOpen("ImageSearchDLLx64.dll")
		If $h_ImageSearchDLL = -1 Then Return "DllOpen failure"
	Else
		Return "Inconsistent or incompatible Script/Windows/CPU Architecture"
	EndIf
	Return True
EndFunc   ;==>_ImageSearchStartup

Func _ImageSearchShutdown()
	DllClose($h_ImageSearchDLL)
	_WinAPI_Wow64EnableWow64FsRedirection(False)

	Return True
EndFunc   ;==>_ImageSearchShutdown
#EndRegion ImageSearch Startup/Shutdown

#Region ImageSearch UDF; modified version
;===============================================================================
;
; Description:      Find the position of an image on the desktop
; Syntax:           _ImageSearchArea, _ImageSearch
; Parameter(s):
;                   $findImage      - the image to locate on the desktop
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y           - Return the x and y location of the image
;                   $tolerance      - 0 for no tolerance (0-255). Needed when colors of
;                                     image differ from desktop. e.g GIF. 
;                                     optional, can be omitted if not needed
;                   $transparency   - TRANSBLACK, TRANSWHITE or hex value (e.g. 0xffffff) of
;                                     the color to be used as transparency
;                                     optional, can be omitted if not needed
;
; Return Value(s):  On Success - Returns True
;                   On Failure - Returns False
;
; Note: Use _ImageSearch to search the entire desktop, _ImageSearchArea to specify
;       a desktop region to search
;
;===============================================================================

Func _ImageSearch($findImage, $resultPosition, ByRef $x, ByRef $y, $tolerance = 0, $transparency = 0)
   Local $result = _ImageSearchArea($findImage, $resultPosition, 0, 0, @DesktopWidth, @DesktopHeight, $x, $y, $tolerance, $transparency)
   If @error Then return SetError(@error, @extended, $result)
   return $result
EndFunc   ;==>_ImageSearch

Func _ImageSearchArea($findImage, $resultPosition, $x1, $y1, $right, $bottom, ByRef $x, ByRef $y, $tolerance = 0, $transparency = 0)
   Local $results = False
   Local $result = _ImageSearchEx1($results, $findImage, $resultPosition, $x1, $y1, $right, $bottom, $tolerance, $transparency, False)
   If @error Then 
     return SetError(@error, @extended, $result)
   EndIf
   if($result) Then
     $x = $results[0][0]
     $y = $results[0][1]
   EndIf
   return $result
EndFunc   ;==>_ImageSearchArea

;===============================================================================
;
; Description:      Find the all positions of an image on the desktop
; Syntax:           _ImageSearchMultiResults, _ImageSearchAreaMultiResults
; Parameter(s):
;                   $results        - output parameter, on success array of x and y coordinates
;                                     of the image ($results[<number_of_results>, 2])
;                                     $results[0][0] - 'x' coordinate of first match
;                                     $results[0][1] - 'y' coordinate of first match
;                                     $results[UBound($results)][0] - 'x' coordinate of the last match
;                                     $results[UBound($results)][1] - 'y' coordinate of the last match
;                   $findImage      - the image to locate on the desktop
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $tolerance      - 0 for no tolerance (0-255). Needed when colors of
;                                     image differ from desktop. e.g GIF. 
;                                     optional, can be omitted if not needed
;                   $transparency   - TRANSBLACK, TRANSWHITE or hex value (e.g. 0xffffff) of
;                                     the color to be used as transparency
;                                     optional, can be omitted if not needed
;
; Return Value(s):  On Success - Returns True
;                   On Failure - Returns False
;
; Note: Use _ImageSearchMultiResults to search the entire desktop, 
;       _ImageSearchAreaMultiResults to specify a desktop region to search
;
;===============================================================================

Func _ImageSearchMultiResults(ByRef $results, $findImage, $resultPosition, $tolerance = 0, $transparency = 0)
   Local $result = _ImageSearchAreaMultiResults($results, $findImage, $resultPosition, 0, 0, @DesktopWidth, @DesktopHeight, $tolerance, $transparency)
   If @error Then return SetError(@error, @extended, $result)
   return $result
EndFunc   ;==>_ImageSearch

Func _ImageSearchAreaMultiResults(ByRef $results, $findImage, $resultPosition, $x1, $y1, $right, $bottom, $tolerance = 0, $transparency = 0)
   Local $result = _ImageSearchEx1($results, $findImage, $resultPosition, $x1, $y1, $right, $bottom, $tolerance, $transparency, True)
   If @error Then 
     return SetError(@error, @extended, $result)
   EndIf
   return $result
EndFunc   ;==>_ImageSearchAreaMultiResults

; Internal function, do not call it direct, its interface can change
Func _ImageSearchEx1(ByRef $results, $findImage, $resultPosition, $x1, $y1, $right, $bottom, $tolerance, $transparency, $flag_find_all)
   $results = False
   If Not FileExists($findImage) Then 
     return SetError(2, 2, False) ; "Image File not found"
   EndIf
   If $tolerance < 0 Or $tolerance > 255 Then $tolerance = 0
   If $h_ImageSearchDLL = -1 Then _ImageSearchStartup()

   Local $ImageFileOptions = ""
   If $tolerance > 0 Then $findImage = "*" & $tolerance & " " & $ImageFileOptions
   If $transparency <> 0 Then $ImageFileOptions = "*Trans" & Hex($transparency) & " " & $ImageFileOptions
   if $flag_find_all Then $ImageFileOptions = "*M " & $ImageFileOptions
   $ImageFileOptions = $ImageFileOptions & $findImage

   Local $result = DllCall($h_ImageSearchDLL, "str", "ImageSearch", "int", $x1, "int", $y1, "int", $right, "int", $bottom, "str", $ImageFileOptions)
   If @error Then 
     return SetError(3, @error, False) ; "DllCall Error=" & @error
   EndIf
   If $result = "0" Or Not IsArray($result) Or $result[0] = "0" Then Return False

   Local $array = StringSplit($result[0], "|")
   If (UBound($array) >= 4) Then
       Local $items = int(UBound($array) / 4)
       Local $results_array[$items][2]
       Local $idx
       For $idx = 0 To ($items - 1)
         Local $bidx = $idx * 4
         Local $x = Int(Number($array[$bidx + 2])); Get the x,y location of the match
         Local $y = Int(Number($array[$bidx + 3]))
         If $resultPosition = 1 Then
             $x = $x + Int(Number($array[$bidx + 4]) / 2); Account for the size of the image to compute the centre of search
             $y = $y + Int(Number($array[$bidx + 5]) / 2)
         EndIf
         $results_array[$idx][0] = $x
         $results_array[$idx][1] = $y
       Next
       $results = $results_array
       Return True
   EndIf
   return False
EndFunc   ;==>_ImageSearchEx1

;===============================================================================
;
; Description:      Wait for a specified number of seconds for an image to appear
;
; Syntax:           _WaitForImageSearch, _WaitForImagesSearch
; Parameter(s):
;                   $waitSecs       - seconds to try and find the image
;                   $findImage      - the image to locate on the desktop
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y           - Return the x and y location of the image
;                   $tolerance      - 0 for no tolerance (0-255). Needed when colors of
;                                     image differ from desktop. e.g GIF
;                   $transparent    - TRANSBLACK, TRANSWHITE or hex value (e.g. 0xffffff) of
;                                     the color to be used as transparent; can be omitted if
;                                     not needed
;
; Return Value(s):  On Success - Returns True
;                   On Failure - Returns False
;
;
;===============================================================================
Func _WaitForImageSearch($findImage, $waitSecs, $resultPosition, ByRef $x, ByRef $y, $tolerance = 0, $transparency = 0)
	$waitSecs = $waitSecs * 1000
	$startTime = TimerInit()
	While TimerDiff($startTime) < $waitSecs
		Sleep(100)
		If _ImageSearch($findImage, $resultPosition, $x, $y, $tolerance, $transparency) Then
			Return True
		EndIf
	WEnd
	Return False
EndFunc   ;==>_WaitForImageSearch



;===============================================================================
;
; Description:      Wait for a specified number of seconds for any of a set of
;                   images to appear
;
; Syntax:           _WaitForImagesSearch
; Parameter(s):
;                   $waitSecs       - seconds to try and find the image
;                   $findImage      - the ARRAY of images to locate on the desktop
;                                   - ARRAY[0] is set to the number of images to loop through
;                                     ARRAY[1] is the first image
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y           - Return the x and y location of the image
;                   $tolerance      - 0 for no tolerance (0-255). Needed when colors of
;                                     image differ from desktop. e.g GIF
;                   $transparent    - TRANSBLACK, TRANSWHITE or hex value (e.g. 0xffffff) of
;                                     the color to be used as transparent; can be omitted if
;                                     not needed
;
; Return Value(s):  On Success - Returns the index of the successful find
;                   On Failure - Returns False
;
;
;===============================================================================
Func _WaitForImagesSearch($findImage, $waitSecs, $resultPosition, ByRef $x, ByRef $y, $tolerance = 0, $transparency = 0)
	$waitSecs = $waitSecs * 1000
	$startTime = TimerInit()
	While TimerDiff($startTime) < $waitSecs
		For $i = 1 To $findImage[0]
			Sleep(100)
			If _ImageSearch($findImage[$i], $resultPosition, $x, $y, $tolerance, $transparency) Then
				Return $i
			EndIf
		Next
	WEnd
	Return False
EndFunc   ;==>_WaitForImagesSearch
#EndRegion ImageSearch UDF;slightly modified


