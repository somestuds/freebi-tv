'*************************************************************
'** Hello World example 
'** Copyright (c) 2015 Roku, Inc.  All rights reserved.
'** Use of the Roku Platform is subject to the Roku SDK License Agreement:
'** https://docs.roku.com/doc/developersdk/en-us
'*************************************************************


' sub updateMovie()
'     phone_port = CreateObject("roMessagePort")

'     request = CreateObject("roUrlTransfer")
'     request.setMessagePort(phone_port)
'     request.setUrl("http://192.168.1.100:8080/status")

'     currentVersion = 0



'     if request.AsyncGetToString()
'         while true
'             msg = wait(0,phone_port)
'             if type(msg) = "roUrlEvent"
'                 code = msg.getResponseCode()
'                 if code = 200
'                     response = msg.GetString()
'                     data = ParseJson(response)

'                     if data <> invalid and data.status = "ready" and data.version <> currentVersion
'                         request.setUrl("http://192.168.1.100:8080/data")
'                         if request.AsyncGetToString()
'                             while true
'                                 msg = wait(0,phone_port)
'                                 if type(msg) = "roUrlEvent"
'                                     code = msg.getResponseCode()
'                                     if code = 200
'                                         response = msg.GetString()
'                                         data = ParseJson(response)

'                                         if data <> invalid and data.status = "ok" and data.uri <> invalid
'                                             m.player.control = "stop"
'                                             content = CreateObject("roSGNode", "ContentNode")
'                                             content.streamformat = "mp4"
'                                             content.url = data.uri
'                                             m.player.content = content
'                                             m.player.control = "play"
                                            
'                                         endif
'                                         exit while
'                                     else
'                                         ? code 
'                                         exit while
'                                     end if

'                                 else if msg = invalid
'                                     ? "Was an invalid message and nothing lol"
'                                     exit while
'                                 end if
'                             end while
'                         else
'                         end if
'                     endif
'                     exit while
'                 else
'                     ? code 
'                     exit while
'                 end if

'             else if msg = invalid
'                 ? "Was an invalid message and nothing lol"
'                 exit while
'             end if
'         end while
'     else
'     end if
' end sub

sub updateMovie()
    ' reuse the existing request and port
    m.request.setMessagePort(m.phone_port)
    m.request.setUrl("http://192.168.1.100:8080/status")

    if m.request.AsyncGetToString()
        while true
            msg = wait(0, m.phone_port)
            if type(msg) = "roUrlEvent" and msg.getResponseCode() = 200
                data = ParseJson(msg.GetString())
                ?"Data Status ";data.status
                ?"Data Version ";data.version
                if data <> invalid and data.status = "ready" and data.version <> m.currentVersion
                    m.currentVersion = data.version
                    ' fetch actual data
                    m.request.setUrl("http://192.168.1.100:8080/data")
                    if m.request.AsyncGetToString()
                        while true
                            msg2 = wait(0, m.phone_port)
                            if type(msg2) = "roUrlEvent" and msg2.getResponseCode() = 200
                                data2 = ParseJson(msg2.GetString())
                                ?"Data2 Uri ";data2.uri
                                ?"Data2 Status ";data2.status
                                if data2 <> invalid and data2.status = "ok" and data2.uri <> invalid
                                    m.player.control = "stop"
                                    content = CreateObject("roSGNode", "ContentNode")
                                    content.streamformat = "mp4"
                                    content.url = data2.uri
                                    m.player.content = content
                                    m.player.control = "play"
                                end if
                                exit while
                            end if
                        end while
                    end if
                end if
                exit while
            end if
        end while
    end if
end sub

sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    scene = screen.CreateScene("HelloWorld")
    scene.messagePort = m.port
    scene.portReady = "true"  ' <-- this will trigger observer

    screen.show()

    m.player = scene.findNode("player")

    m.phone_port = CreateObject("roMessagePort")
    m.request = CreateObject("roUrlTransfer")
    m.currentVersion = 0

    

    while true
        msg = wait(20, m.port)
        updateMovie()

        ?"Video state: "; m.player.state
        if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() return
    end while
end sub

function onKeyEvent(key as String, press as boolean) as boolean
    ? "Key ";key
    ? "Press"; press
endfunction