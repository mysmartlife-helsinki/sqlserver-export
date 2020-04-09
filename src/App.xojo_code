#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  mMyApplication = New MyApplication
		  
		  mMyApplication.Initialize( args )
		  
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
