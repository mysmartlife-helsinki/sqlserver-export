#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  do
		  loop until RegisterPlugins
		  
		  mMyApplication = New MyApplication
		  
		  mMyApplication.Initialize( args )
		  
		  // open database connection
		  
		  do
		  loop until mMyApplication.ConnectDatabase
		  
		  Do
		    DoEvents
		    // Sit in a loop until Idle returns true
		  Loop Until mMyApplication.Idle
		  
		  Return mMyApplication.Finalize
		End Function
	#tag EndEvent


	#tag Property, Flags = &h21
		Private mMyApplication As MyApplication
	#tag EndProperty


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
