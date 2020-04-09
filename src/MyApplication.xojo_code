#tag Class
Protected Class MyApplication
	#tag Method, Flags = &h0
		Function ConnectDatabase() As boolean
		  dim s as string
		  
		  dbcon = new SQLConnectionMBS
		  
		  try
		    
		    dbcon.Option("OLEDBProvider") = "SQLNCLI"
		    
		    dbcon.Connect("localhost\SQLEXPRESS@i96X2019","","",SQLConnectionMBS.kSQLServerClient)
		    
		    dbcon.Scrollable = false
		    
		    print "Database i96X2019 connected."
		    
		    print dbcon.LastStatement
		    
		    // fetch the rowcount to verify connection
		    
		    print "Fetching rowcount of pointvalue -table, this might take a while:"
		    
		    s = dbcon.SQLSelect("SELECT COUNT(*) FROM dbo.pointvalue;")
		    
		    print "[DB] dbo.pointvalue: "+s+" rows."
		    
		  catch r as RuntimeException
		    
		    print r.message
		    
		    try
		      
		      dbcon.Rollback
		      
		    catch rr as RuntimeException
		      
		      print rr.message
		      
		    end try
		    
		  end try
		  
		  return true
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Finalize() As Integer
		  if dbcon<>nil then
		    dbcon.Disconnect
		  end
		  
		  Print "We're done running now!"
		  
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Idle() As Boolean
		  dim rs as recordset
		  dim sql as string
		  
		  sql = "SELECT dbo.Outstations.theLabel AS OSLabel, dbo.StrategyList.theLabel AS PointLabel, dbo.StrategyList.item, dbo.StrategyList.theIndex AS pointID, dbo.PointValue.DataValue, dbo.PointValue.DataTime, dbo.PointValue.DataValueType, dbo.Lans.DeviceType FROM dbo.SiteDetails INNER JOIN dbo.Lans INNER JOIN dbo.Outstations ON dbo.Lans.lanID = dbo.Outstations.lanID ON dbo.SiteDetails.siteID = dbo.Lans.siteID INNER JOIN dbo.StrategyList ON dbo.Outstations.outstationID = dbo.StrategyList.outstationID INNER JOIN dbo.PointValue ON dbo.StrategyList.theIndex = dbo.PointValue.PointID ORDER BY dbo.PointValue.PointID OFFSET "
		  // offset value goes here
		  sql = sql + str(dbOffset) + " FETCH NEXT 1000 ROWS ONLY;"
		  
		  dbOffset = dbOffset + 1
		  
		  try
		    
		    if dbcon<>nil then
		      
		      if dbcon.isConnected then
		        
		        rs = dbcon.SQLSelectAsRecordSet(sql)
		        
		        if rs<>nil then
		          
		          print "Fetching rows "+str(dbOffset * 1000)+" - "+str(dboffset+1 * 1000)
		          
		          while not rs.eof
		            
		            // append to CSV
		            
		            rs.MoveNext
		            
		          wend
		          
		        end
		        
		      else
		        print dbcon.ErrorMessage
		      end
		      
		      return true
		      
		    end
		    
		  catch r as RuntimeException
		    
		    print r.Message
		    
		    return false
		    
		  end try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Initialize(args() as String)
		  Print "SQLServer Large Table Export"
		  Print "============================"
		  Print ""
		  Print "Created for Horizon2020 mySMARTLife Project."
		  Print "Grant agreement No. 731297"
		  Print ""
		  Print "Export job preset:"
		  Print "Trend Building Automation System pointvalues export."
		  Print ""
		  Print "Initializing the database connection..."
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		dbcon As SQLConnectionMBS
	#tag EndProperty

	#tag Property, Flags = &h0
		dbOffset As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLoopForAWhile As Integer
	#tag EndProperty


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
