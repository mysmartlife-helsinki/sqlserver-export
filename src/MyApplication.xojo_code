#tag Class
Protected Class MyApplication
	#tag Method, Flags = &h0
		Function ConnectDatabase() As boolean
		  dim s as string
		  
		  db = new SQLDatabaseMBS
		  
		  try
		    
		    db.Option("OLEDBProvider") = "SQLNCLI"
		    
		    db.Scrollable = false
		    
		    db.DatabaseName = "SQLServer:localhost\SQLEXPRESS@i96X2019"
		    db.UserName = ""
		    db.Password = ""
		    
		    if db.Connect then
		      
		      print "[DB] Database i96X2019 connected."
		      
		      print db.ErrorMessage
		      
		      // fetch the rowcount to verify connection
		      
		      print "[DB] Fetching rowcount of pointvalue -table, this might take a while:"
		      
		      dim rs as RecordSet = db.SQLSelect("SELECT COUNT(*) FROM dbo.pointvalue;")
		      
		      if rs<>nil then
		        while not rs.eof
		          rowcount = rs.IdxField(1).IntegerValue
		          print "[DB] dbo.pointvalue: "+str(rowcount)+" rows."
		          rs.movenext
		        wend
		      end
		    else
		      
		      print "[DB] Failed to connect database."
		      print db.ErrorMessage
		      
		    end
		    
		  catch r as RuntimeException
		    
		    print r.message
		    
		    try
		      
		      db.Rollback
		      
		    catch rr as RuntimeException
		      
		      print rr.message
		      
		    end try
		    
		  end try
		  
		  return true
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Finalize() As Integer
		  if db<>nil then
		    db.Close
		  end
		  
		  outstream.Close
		  
		  Print "We're done running now!"
		  
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Idle() As Boolean
		  Using Xojo.Core
		  Using Xojo.IO
		  
		  dim finalRun as boolean
		  dim rs as recordset
		  dim s,sql as string
		  dim b as double
		  
		  sql = "SELECT dbo.Outstations.theLabel AS OSLabel, dbo.StrategyList.theLabel AS PointLabel, dbo.StrategyList.item, dbo.StrategyList.theIndex AS pointID, dbo.PointValue.DataValue, dbo.PointValue.DataTime, dbo.PointValue.DataValueType, dbo.Lans.DeviceType FROM dbo.SiteDetails INNER JOIN dbo.Lans INNER JOIN dbo.Outstations ON dbo.Lans.lanID = dbo.Outstations.lanID ON dbo.SiteDetails.siteID = dbo.Lans.siteID INNER JOIN dbo.StrategyList ON dbo.Outstations.outstationID = dbo.StrategyList.outstationID INNER JOIN dbo.PointValue ON dbo.StrategyList.theIndex = dbo.PointValue.PointID ORDER BY dbo.PointValue.PointID OFFSET "
		  // offset value goes here
		  sql = sql + str(dbOffset) + " ROWS FETCH NEXT 1000 ROWS ONLY;"
		  
		  dbOffset = dbOffset + 1
		  
		  if dbOffset = floor (rowcount/1000) then
		    FinalRun = true
		  end
		  
		  // end if completed
		  
		  if (dboffset * 1000) > rowcount then
		    
		    print "Fetch completed."
		    
		    return true
		    
		  end
		  
		  // calculate progress
		  
		  dim a as integer
		  
		  a = (dboffset / (rowcount/1000)) * 100
		  
		  if floor(a)>floor(prev) then
		    
		    Print "Fetch progress: "+str(floor(a))+"%"
		    
		  end
		  
		  prev = a
		  
		  // fetch data
		  
		  try
		    
		    if db<>nil then
		      
		      if db.Connection.isConnected then
		        
		        rs = db.SQLSelect(sql)
		        
		        if rs<>nil then
		          
		          print "Fetching rows "+str((dbOffset-1) * 1000)+" - "+str(dboffset * 1000)
		          
		          while not rs.eof
		            
		            // append to CSV
		            
		            if outfile<>nil then
		              
		              
		              
		              // write header
		              
		              if not headerFinished then
		                
		                for i as integer = 1 to rs.FieldCount
		                  
		                  s = s + DefineEncoding(rs.IdxField(i).Name,Encodings.ISOLatin1)
		                  s = s + ";"
		                  
		                next
		                
		                Try
		                  outfile = New Xojo.IO.Folderitem(outfilepath)
		                  if not outfile.Exists then
		                    outstream = Xojo.IO.TextOutputStream.Create(outfile, Xojo.Core.TextEncoding.UTF8)
		                  end
		                  outstream = Xojo.IO.TextOutputStream.Append(outfile, xojo.core.TextEncoding.UTF8)
		                  outstream.Writeline(s.ToText)
		                  outstream.close
		                  
		                  headerFinished = true
		                  
		                Catch e as IOException
		                  print "Unable to write column headers to file."
		                End try
		              else
		                
		              end
		              
		              s = ""
		              
		              for i as integer = 1 to rs.FieldCount
		                s = s + DefineEncoding(rs.IdxField(i).StringValue,Encodings.ISOLatin1)
		                s = s + ";"
		              next
		              
		              Try
		                
		                if not outfile.exists then
		                  outstream = Xojo.IO.TextOutputStream.Create(outfile, Xojo.Core.TextEncoding.UTF8)
		                end
		                outstream = Xojo.IO.TextOutputStream.Append(outfile, xojo.core.TextEncoding.UTF8)
		                
		                outstream.Writeline(s.ToText)
		                
		                outstream.close()
		                
		              Catch e as IOException
		                print "Unable to write column headers to file."
		              End try
		              
		              
		            else
		              print "Error: Output file is not available for writing."
		            end
		            
		            rs.MoveNext
		            
		          wend
		          
		        else
		          
		          print "Database query error: "+db.ErrorMessage
		          
		        end
		        
		      else
		        print "Database disconnected."
		      end
		      
		      return false
		      
		    end
		    
		  catch r as RuntimeException
		    
		    print r.Message
		    
		    return true
		    
		  end try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Initialize(args() as String)
		  
		  dim d as New Date
		  
		  Print "SQLServer Large Table Export"
		  Print "============================"
		  Print ""
		  Print "Created for Horizon2020 mySMARTLife Project."
		  Print "Grant agreement No. 731297"
		  Print "====="
		  Print "Export job preset:"
		  Print "Trend Building Automation System pointvalues export."
		  Print "====="
		  
		  outfilename = "i96X2019_"+d.SQLDate+".CSV"
		  outfilepath = SpecialFolder.Desktop.child(outfilename).NativePath.ToText
		  outfile = New Xojo.IO.Folderitem(outfilepath)
		  
		  Try
		    
		    outstream = Xojo.IO.TextOutputStream.Create(outfile, Xojo.Core.TextEncoding.UTF8)
		    outstream.write("")
		    outstream.close
		    
		  Catch e as IOException
		    print "Unable to create output file."
		  End Try
		  
		  Print "Creating export file "+outfilename+" on Desktop"
		  
		  Print "====="
		  Print "Initializing the database connection..."
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		db As SQLDatabaseMBS
	#tag EndProperty

	#tag Property, Flags = &h0
		dbOffset As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		headerFinished As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLoopForAWhile As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		outfile As Xojo.IO.Folderitem
	#tag EndProperty

	#tag Property, Flags = &h0
		outfilename As String
	#tag EndProperty

	#tag Property, Flags = &h0
		outfilepath As Text
	#tag EndProperty

	#tag Property, Flags = &h0
		outstream As Xojo.IO.TextOutputStream
	#tag EndProperty

	#tag Property, Flags = &h0
		prev As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		rowCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		rowdata As dictionary
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
		#tag ViewProperty
			Name="dbOffset"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="rowCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="headerFinished"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="outfilename"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="outfilepath"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Text"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="prev"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
