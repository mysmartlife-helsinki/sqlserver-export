#tag Class
Protected Class MyApplication
	#tag Method, Flags = &h0
		Function Finalize() As Integer
		  Print "We're done running now!"
		  
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Idle() As Boolean
		  mLoopForAWhile = mLoopForAWhile + 1
		  
		  Print "In the idle event"
		  
		  If mLoopForAWhile = 10 Then
		    Return True
		  Else
		    Return False
		  End
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Initialize(args() as String)
		  Print "Initializing the application"
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected mLoopForAWhile As Integer
	#tag EndProperty


	#tag Constant, Name = sql, Type = String, Dynamic = False, Default = \"SELECT dbo.Outstations.theLabel AS OSLabel\x2C dbo.StrategyList.theLabel AS PointLabel\x2C dbo.StrategyList.item\x2C dbo.StrategyList.theIndex AS pointID\x2C dbo.PointValue.DataValue\x2C dbo.PointValue.DataTime\x2C dbo.PointValue.DataValueType\x2C dbo.Lans.DeviceType FROM dbo.SiteDetails INNER JOIN dbo.Lans INNER JOIN dbo.Outstations ON dbo.Lans.lanID \x3D dbo.Outstations.lanID ON dbo.SiteDetails.siteID \x3D dbo.Lans.siteID INNER JOIN dbo.StrategyList ON dbo.Outstations.outstationID \x3D dbo.StrategyList.outstationID INNER JOIN dbo.PointValue ON dbo.StrategyList.theIndex \x3D dbo.PointValue.PointID", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
