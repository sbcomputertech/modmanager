Set oWS = WScript.CreateObject("WScript.Shell")
sLinkFile = WScript.Arguments.Item(0)
Set oLink = oWS.CreateShortcut(sLinkFile)
oLink.TargetPath = WScript.Arguments.Item(1)
oLink.WorkingDirectory = WScript.Arguments.Item(2)
oLink.Save