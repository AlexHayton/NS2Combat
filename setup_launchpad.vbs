Set xmlDoc = CreateObject("Microsoft.XMLDOM")
set WshShell = WScript.CreateObject("WScript.Shell") 
strAppData = WshShell.ExpandEnvironmentStrings("%AppData%")

ScriptPath = ""
  
xmlDoc.Async = "False"
xmlDoc.Load(strAppData & "\Natural Selection 2\Launch Pad\options.xml")

If Not IsNull(xmlDoc) Then
	Set recent_mods = xmlDoc.selectsinglenode ("//options/recent_mods")
	
	IF Not IsNull(recent_mods) Then
		ScriptPath = Replace(WshShell.CurrentDirectory,"\","/") 		
	End If	
End If

If ScriptPath <> "" Then
	Set newModValue = xmlDoc.createElement("recent_mod")
	newModValue.Text = ScriptPath & "/mod.settings"
	recent_mods.appendChild newModValue 

	MsgBox "Mod set in LaunchPad"
	  
	xmlDoc.Save strAppData & "\Natural Selection 2\Launch Pad\options.xml"
Else
	MsgBox "Couldn't find the Mod path, copy this folder into your NS2 directory!"
End If
