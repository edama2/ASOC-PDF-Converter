--
--  AppDelegate.applescript
--  ASOC PDF Converter
--
--  Created by zzz on 2021/04/29.
--  Copyright ý 2021 zzz. All rights reserved.
--
#MARK: NSUserDefaults keys
property _k_compatibility : "Compatibility"
property _k_AutoRotatePages : "AutoRotatePages"
property _k_AutoFilterColorImages : "AutoFilterColorImages"
property _k_AutoFilterGrayImages : "AutoFilterGrayImages"
property _k_ColorImageDownsampleType : "ColorImageDownsampleType"
property _k_ColorImageResolution : "ColorImageResolution"
property _k_EmbedAllFonts : "EmbedAllFonts"
property _k_GrayImageDownsampleType : "GrayImageDownsampleType"
property _k_GrayImageResolution : "GrayImageResolution"
property _k_MonoImageDownsampleType : "MonoImageDownsampleType"
property _k_MonoImageResolution : "MonoImageResolution"
property _k_SubsetFonts : "SubsetFonts"
property _k_DetectDuplicateImages : "DetectDuplicateImages"
property _k_FastWebView : "FastWebView"
property _k_CompressPages : "CompressPages"
property _k_ColorSpace : "ColorSpace"
property _k_PDFSettings : "PDFSettings"
property _k_whenDone : "WhenDone"
property _k_showInFinder : "ShowInFinder"
property _k_PlaySound : "PlaySound"
property _k_QuitApp : "QuitApp"


script AppDelegate
	property parent : class "NSObject"
	
	on applicationShouldTerminate:sender
		return current application's NSTerminateNow
	end applicationShouldTerminate:
	
	#MARK: windowðÂ¶½çI¹
	on applicationShouldTerminateAfterLastWindowClosed:sender
		return true
	end applicationShouldTerminateAfterLastWindowClosed:
	
	-- IBOutlets
	property theWindow : missing value
	
	property textFieldInputPath : missing value --> Ï·OÌt@CpXpeLXgtB[h
	property textFieldOutputPath : missing value --> Ï·ãÌt@CpXpeLXgtB[h
	property textViewLog : missing value --> 
	
	property popUpPDFSettings : missing value --> PDF SettingsÌ|bvAbvj[
	
	--> ImageÌ|bvAbvj[
	property popUpDownsampleColor : missing value
	property popUpDownsampleGray : missing value
	property popUpDownsampleMono : missing value
	
	--> ImageÌeLXgtB[h	
	property textFieldColor : missing value
	property textFieldGray : missing value
	property textFieldMono : missing value
	
	--> ImageÌ`FbN{bNX
	property checkboxColor : missing value
	property checkboxGray : missing value
	
	
	
	property isEnabledPopUpControlsIndividually : false
	property isBusy : false
	property strVarsion : "" --> R}hCÌo[W
	property _start_time : ""
	property consoleOutput : ""
	property theTask : missing value
	
	
	property _limit_day : (current date) + (14 * days) -->gpúÀ
	on awakeFromNib()
		if my _limit_day is less than (current date) then
			display dialog "The expiration date has expired." buttons {"Quit"} default button 1
			current application's NSApp's terminate:me
		end if
	end awakeFromNib
	
	#MARK:
	on applicationWillFinishLaunching:aNotification
		#Zbgµ½ÌlðÝè
		set fileURL to current application's NSBundle's mainBundle's URLForResource:"UserDefaults" withExtension:"plist"
		set myUserDefaults to current application's NSDictionary's dictionaryWithContentsOfURL:fileURL |error|:(missing value)
		tell current application's NSUserDefaultsController's sharedUserDefaultsController() --theUserDefaults
			setInitialValues_(myUserDefaults)
			--setAppliesImmediately_(true)
			set theUserDefaults to it
		end tell
		
		#úlÌÝè
		tell myUserDefaults
			(*
			setObject_forKey_(".jpg, .gif, .png", _k_filetype)
			setObject_forKey_(0, _k_depth_level)
			setObject_forKey_(0, _k_select_option)
			setObject_forKey_(false, _k_no_directory)
			setObject_forKey_(false, _k_span_hosts)
			setObject_forKey_(true, _k_is_continue)
			setObject_forKey_("Mozilla/4.0 (compatible; MSIE 4.01; MSN 2.5; Windows 98)", _k_user_agent)
			*)
		end tell
		
		tell current application's NSUserDefaults's standardUserDefaults()
			registerDefaults_(myUserDefaults)
		end tell
		
		#PDF SettingsÌ|bvAbvj[
		my selectPopMenu:popUpPDFSettings
		
		#R}hÌo[Wð²×é
		getVarsion()
		
		#ÊmÌo^
		current application's NSNotificationCenter's defaultCenter()'s addObserver:me selector:"finishedTask:" |name|:"NSTaskDidTerminateNotification" object:(missing value)
		
	end applicationWillFinishLaunching:
	
	#MARK: Ï·µ½¢PDFt@CÌIð
	on chooseInputFile:sender
		
		set mes to "Ï·µ½¢PDFt@CðIðµÄ­¾³¢B"
		set chooseItems to choose file of type {"com.adobe.pdf"} with prompt mes
		--, "public.jpeg", "public.png"
		
		set aPath to chooseItems's POSIX path
		
		textFieldInputPath's setStringValue:aPath
	end chooseInputFile:
	
	#MARK: Ï·PDFt@CÌIð
	on chooseOutputFile:sender
		
		set sourcePath to textFieldInputPath's stringValue()
		tell (current application's NSString's stringWithString:sourcePath)
			set currentPath to stringByDeletingLastPathComponent() -->etH_
			set aSuffix to pathExtension() as text -->g£q
			set longFileName to lastPathComponent() -->g£q èÌ¼O
			set shortFileName to longFileName's stringByDeletingPathExtension() as text -->g£qÈµÌ¼O
			set unkonwnPath to it
		end tell
		
		#
		set aSuffix to "." & aSuffix
		set aSpace to "_"
		set num to 0
		
		repeat while ((current application's NSFileManager's defaultManager)'s fileExistsAtPath:unkonwnPath)
			set num to num + 1
			set tmpName to shortFileName & aSpace & num & aSuffix as text
			set unkonwnPath to (currentPath's stringByAppendingPathComponent:tmpName)
		end repeat
		
		set longFileName to unkonwnPath's lastPathComponent() as text -->g£q èÌ¼O
		log result
		
		set currentPath to currentPath as text
		set currentFolder to currentPath as POSIX file
		
		set mes to "VKt@CÌ¼OÆÛ¶æðwèµÄ­¾³¢B"
		set newFile to choose file name default name longFileName with prompt mes default location currentFolder
		
		set aPath to newFile's POSIX path
		
		textFieldOutputPath's setStringValue:aPath
		
		
	end chooseOutputFile:
	
	
	
	
	#MARK: |bvAbv
	--ComboBoxÌRg[ --oCfBOÅ¤Ü­¢©È¢ÌÅ
	on selectPopMenu:sender
		set aTitle to sender's titleOfSelectedItem() as text
		
		if aTitle is "controls individually" then
			set my isEnabledPopUpControlsIndividually to true
		else
			set my isEnabledPopUpControlsIndividually to false
			
			checkboxColor's setState:true
			checkboxGray's setState:true
			
			if aTitle is "default" then
				popUpDownsampleColor's selectItemWithTitle:"Subsample"
				popUpDownsampleGray's selectItemWithTitle:"Subsample"
				popUpDownsampleMono's selectItemWithTitle:"Subsample"
				textFieldColor's setStringValue:"72"
				textFieldGray's setStringValue:"72"
				textFieldMono's setStringValue:"300"
			else if aTitle is "screen" then
				popUpDownsampleColor's selectItemWithTitle:"Average"
				popUpDownsampleGray's selectItemWithTitle:"Average"
				popUpDownsampleMono's selectItemWithTitle:"Subsample"
				textFieldColor's setStringValue:"72"
				textFieldGray's setStringValue:"72"
				textFieldMono's setStringValue:"300"
			else if aTitle is "ebook" then
				popUpDownsampleColor's selectItemWithTitle:"Average"
				popUpDownsampleGray's selectItemWithTitle:"Bicubic"
				popUpDownsampleMono's selectItemWithTitle:"Subsample"
				textFieldColor's setStringValue:"150"
				textFieldGray's setStringValue:"150"
				textFieldMono's setStringValue:"300"
			else if aTitle is "printer" then
				popUpDownsampleColor's selectItemWithTitle:"Average"
				popUpDownsampleGray's selectItemWithTitle:"Bicubic"
				popUpDownsampleMono's selectItemWithTitle:"Subsample"
				textFieldColor's setStringValue:"300"
				textFieldGray's setStringValue:"300"
				textFieldMono's setStringValue:"1200"
			else if aTitle is "prepress" then
				popUpDownsampleColor's selectItemWithTitle:"Bicubic"
				popUpDownsampleGray's selectItemWithTitle:"Bicubic"
				popUpDownsampleMono's selectItemWithTitle:"Subsample"
				textFieldColor's setStringValue:"300"
				textFieldGray's setStringValue:"300"
				textFieldMono's setStringValue:"1200"
				
			end if
		end if
		
	end selectPopMenu:
	
	#o[Vðæ¾
	on getVarsion()
		--set commandPath to current application's NSBundle's mainBundle()'s pathForResource:"wget" ofType:""
		-- set wgetPath to (current application's NSBundle's mainBundle()'s URLForAuxiliaryExecutable:"wget")'s |path|
		set commandPath to "/usr/local/bin/gs"
		
		set outPipe to current application's NSPipe's pipe()
		
		tell current application's NSTask's new()
			setLaunchPath_(commandPath)
			setArguments_(["-v"])
			setStandardOutput_(outPipe)
			|launch|()
			waitUntilExit()
		end tell
		
		set outData to outPipe's fileHandleForReading()'s readDataToEndOfFile()
		set strStats to current application's NSString's alloc()'s initWithData:outData encoding:(current application's NSUTF8StringEncoding)
		
		set strStats to strStats as text
		log result
		
		set strList to strStats's paragraphs
		set my strVarsion to strList's item 1
		log result
	end getVarsion
	
	#MARK: Jn
	on startTask:sender
		log "startTask"
		
		set sourcePath to textFieldInputPath's stringValue() as text
		if sourcePath is "" then
			beep
			set mes to "üÍPDFªIð³êÄ¢Ü¹ñB"
			set infoText to ""
			
			set bOK to "âè¼µ"
			set bList to {bOK}
			set userAction to display alert mes buttons bList default button bOK message infoText as critical
			--> {button returned:"OK"}
			return
		end if
		
		
		set distPath to textFieldOutputPath's stringValue() as text
		if distPath is "" then
			beep
			set mes to "oÍPDFªIð³êÄ¢Ü¹ñB"
			set infoText to ""
			
			set bOK to "âè¼µ"
			set bList to {bOK}
			set userAction to display alert mes buttons bList default button bOK message infoText as critical
			--> {button returned:"OK"}
			return
		end if
		
		set isExists to ((current application's NSFileManager's defaultManager)'s fileExistsAtPath:distPath)
		
		if isExists then
			
			beep
			set mes to "·ÅÉt@Cª¶ÝµÜ·Bã«µÜ·©H"
			set infoText to distPath
			
			set bOK to "Replace"
			set bCancel to "Cancel"
			set bOther to "Show File"
			set bList to {bOther, bCancel, bOK}
			
			set userAction to display alert mes buttons bList default button bOK cancel button bCancel message infoText as critical
			--> {button returned:"OK"}
			if userAction's button returned is bOther then
				(current application's NSWorkspace's sharedWorkspace)'s selectFile:distPath inFileViewerRootedAtPath:(missing value)
				return
			end if
		end if
		
		#Jn
		set my isBusy to true
		set my _start_time to current date
		
		#
		textViewLog's setString:""
		
		set args to {}
		set args's end to "-sDEVICE=pdfwrite" --oÍfoCXÌIð
		set args's end to "-dNOPAUSE" --ey[WÌÌêâ~ð³øÉ·é
		--set args's end to "-dQUIET" --WoÍÖÌ[`îñÌRgðñ\¦É·é
		set args's end to "-dBATCH" --C^NeBuÈ[vR}hÉüÁ½ãÉI¹·é
		
		tell current application's NSUserDefaults's standardUserDefaults()
			
			#CompatibilityLevel
			set tmpStr to stringForKey_(_k_compatibility) as text
			set args's end to "-dCompatibilityLevel=" & tmpStr as text
			
			#AutoRotatePages
			set tmpStr to stringForKey_(_k_AutoRotatePages) as text
			set args's end to "-dAutoRotatePages=/" & tmpStr as text
			
			#ColorSpace FÌè`
			set tmpStr to stringForKey_(_k_ColorSpace) as text
			if tmpStr is "Gray" then
				
				set args's end to "-sColorConversionStrategy=Gray"
				set args's end to "-dProcessColorModel=/DeviceGray"
				
			else if tmpStr is "RGB" then
				
				set args's end to "-sColorConversionStrategy=sRGB"
				"-sColorConversionStrategyForImages=sRGB"
				set args's end to "-sProcessColorModel=DeviceRGB"
				
			else if tmpStr is "CMYK" then
				
				set args's end to "-sColorConversionStrategy=CMYK"
				set args's end to "-sProcessColorModel=DeviceCMYK"
				
			end if
			
			#tHgßÝ
			set tmpStr to boolForKey_(_k_EmbedAllFonts) as text
			set args's end to "-dEmbedAllFonts=" & tmpStr as text
			
			# -dSubsetFonts
			set tmpStr to boolForKey_(_k_SubsetFonts) as text
			set args's end to "-dSubsetFonts=" & tmpStr as text
			
			#d¡·éæðÅK»
			set tmpStr to boolForKey_(_k_DetectDuplicateImages) as text
			set args's end to "-dDetectDuplicateImages=" & tmpStr as text
			
			#WebÅK»
			set tmpStr to boolForKey_(_k_FastWebView) as text
			set args's end to "-dFastWebView=" & tmpStr as text
			
			#dCompressPages
			set tmpStr to boolForKey_(_k_compatibility) as text
			set args's end to "-dCompressPages=" & tmpStr as text
			
			set tmpStr to stringForKey_(_k_PDFSettings) as text
			if tmpStr is not "controls individually" then
				#è`ÏÝÌvZbg
				set args's end to "-dPDFSETTINGS=/" & tmpStr as text
			else
				
				set args's end to stringForKey_(_k_ColorImageDownsampleType) as text
				set args's end to "-dColorImageDownsampleType=/" & tmpStr as text
				set args's end to stringForKey_(_k_ColorImageResolution) as text
				set args's end to "-dColorImageResolution=" & tmpStr as text
				set args's end to boolForKey_(_k_AutoFilterColorImages) as text
				set args's end to "-dAutoFilterColorImages=" & tmpStr as text
				
				set args's end to stringForKey_(_k_GrayImageDownsampleType) as text
				set args's end to "-dColorImageDownsampleType=/" & tmpStr as text
				set args's end to stringForKey_(_k_GrayImageResolution) as text
				set args's end to "-dColorImageResolution=" & tmpStr as text
				set args's end to boolForKey_(_k_AutoFilterGrayImages) as text
				set args's end to "-dAutoFilterColorImages=" & tmpStr as text
				
				set args's end to stringForKey_(_k_MonoImageDownsampleType) as text
				set args's end to "-dColorImageDownsampleType=/" & tmpStr as text
				set args's end to stringForKey_(_k_MonoImageResolution) as text
				set args's end to "-dColorImageResolution=" & tmpStr as text
				
			end if
			
			set args's end to "-dOptimize=true" as text
			
		end tell
		
		#oÍt@C
		--set args's end to "-sOutputFile=" & distPath's quoted form
		set args's end to "-o"
		set args's end to distPath
		
		#üÍt@C
		set args's end to sourcePath
		
		log args
		
		set commandPath to "/usr/local/bin/gs"
		
		
		set outPipe to current application's NSPipe's pipe()
		
		tell current application's NSTask's new()
			setLaunchPath_(commandPath)
			--setCurrentDirectoryPath_(currentDir)
			setStandardOutput_(outPipe)
			setArguments_(args)
			--|launch|()
			set theTask to it
		end tell
		
		current application's NSNotificationCenter's defaultCenter()'s addObserver:me selector:"getLogData:" |name|:"NSFileHandleReadCompletionNotification" object:(outPipe's fileHandleForReading())
		outPipe's fileHandleForReading()'s readInBackgroundAndNotify()
		
		theTask's |launch|()
		
		log "start -----------------------"
	end startTask:
	
	#MARK: ^XNI¹
	on getLogData:aNotification
		log "getLogData"
		set aData to aNotification's userInfo()'s objectForKey:"NSFileHandleNotificationDataItem"
		log result
		
		if aData is missing value then return my stopProcess:(missing value)
		log "consoleOutput"
		set consoleOutput to current application's NSString's alloc's initWithData:aData encoding:(current application's NSUTF8StringEncoding)
		log consoleOutput
		if consoleOutput as text is "" then
			log 10
			theTask's terminate()
			return
		end if
		
		
		set attr to current application's NSAttributedString's alloc's initWithString:consoleOutput
		textViewLog's textStorage()'s appendAttributedString:attr
		textViewLog's scrollRangeToVisible:(current application's NSMakeRange(textViewLog's |string|()'s |length|(), 0))
		
		aNotification's object()'s readInBackgroundAndNotify()
		
	end getLogData:
	
	#MARK: ^XNI¹
	on finishedTask:aNotification
		log "finishedTask"
		
		#
		theTask's terminate()
		theTask's waitUntilExit()
		
		set aTime to my elapsed_time(my _start_time)
		set distPath to textFieldOutputPath's stringValue() as text
		
		tell current application's NSUserDefaults's standardUserDefaults()
			set isShow to boolForKey_(_k_showInFinder) as boolean
			set isPlay to boolForKey_(_k_PlaySound) as boolean
			set isDone to stringForKey_(_k_whenDone) as text
			set isQuit to boolForKey_(_k_QuitApp) as boolean
		end tell
		
		current application's NSApplication's sharedApplication()'s requestUserAttention:(current application's NSCriticalRequest)
		
		#I¹¹
		if isPlay then beep
		
		if isDone is "Alert" then
			
			set mes to "Ï·ª®¹µÜµ½B"
			set infoText to "Ï·Ô " & aTime
			set infoText to infoText & return & return & distPath
			
			set bOK to "OK"
			set bCancel to "Show File"
			set bList to {bCancel, bOK}
			
			set userAction to display alert mes buttons bList default button bOK cancel button bCancel giving up after 30 message infoText as informational
			--> {button returned:"OK", gave up:true}
			
			if userAction's gave up is false then
				set isShow to true
			end if
			
		else if isDone is "Notification" then
			
			set mes2 to "Ï·ª®¹µÜµ½B"
			set mes to "Ï·Ô " & aTime as text
			display notification distPath with title mes2 subtitle mes sound name ""
		end if
		
		#t@CÌ\¦
		if isShow then
			--try
			(current application's NSWorkspace's sharedWorkspace)'s selectFile:distPath inFileViewerRootedAtPath:(missing value)
			--end try
		end if
		
		#AvÌI¹
		if isQuit then tell me to quit
		
		set my isBusy to false
	end finishedTask:
	
	#Ôvª
	on elapsed_time(startTime) --var.20110425
		set timeEnd to (current date) - startTime
		tell {timeEnd div hours, ((timeEnd mod hours) div minutes), timeEnd mod minutes}
			repeat with i in it
				if i < 10 then set i's contents to "0" & i
			end repeat
			return ("Time " & item 1 & " : " & item 2 & " : " & item 3) as text
		end tell
	end elapsed_time
	
end script











