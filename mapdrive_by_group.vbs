On Error Resume Next
' Initialize
Set objSysInfo = CreateObject("ADSystemInfo")
Set oNET = CreateObject("Wscript.Network")
strUserPath = "LDAP://" & objSysInfo.UserName
Set objUser = GetObject(strUserPath)

' Map drive by group members
For Each strGroup in objUser.MemberOf ' For each group
    strGroupPath = "LDAP://" & strGroup
    Set objGroup = GetObject(strGroupPath)
    strGroupName = objGroup.CN
    Select Case strGroupName ' Map 
        Case "groups 1" oNET.MapNetworkDrive "X:", "\\server\share"
        Case "groups 2" oNET.MapNetworkDrive "X:", "\\server\share"
        Case "groups 3" oNET.MapNetworkDrive "X:", "\\server\share"
        Case "groups 4" oNET.MapNetworkDrive "X:", "\\server\share"
    End Select
Next

