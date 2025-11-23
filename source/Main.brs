function regset(key as String, value as String) as Boolean
    reg = CreateObject("roRegistrySection", "app")
    return reg.Write(key, value)
end function

function regget(key as String, defaultValue = "" as String) as String
    reg = CreateObject("roRegistrySection", "app")
    val = reg.Read(key)
    if val = invalid or val = "" then
        return defaultValue
    else
        return val
    end if
end function

function regdet(key as String) as Boolean
    reg = CreateObject("roRegistrySection", "app")
    return reg.Delete(key)
end function

function EncodeKey(name as String) as String
    byteArray = CreateObject("roByteArray")
    byteArray.FromAsciiString(name)
    base64 = byteArray.ToBase64String()
    ? "Base 64: " base64
    return base64
end function

sub handleCommand(info as Dynamic)
    if info.DoesExist("command")
        command = info.command

        if command = "pair" and info.DoesExist("friendlyName")
            m.paired = info.friendlyName
            m.regkey = EncodeKey(m.paired)+"::"
            m.pairLabel.text = "Currently Paired: " + m.paired

            lastMovieUri = regget(m.regkey+"lastMovie","<unset>")
            lastMovieName = regget(m.regkey+"lastMovieName","<unset>")

            if lastMovieUri <> "<unset>" and lastMovieName <> "<unset>"
                m.player.control = "stop"
                m.player.content = invalid
                m.content.url = lastMovieUri
                m.player.content = m.content
                m.player.control = "play"

                m.playingLabel.text = "Playing: " + lastMovieName
            end if 
        end if

        ? info 
        ? command
        ? info.DoesExist("movieUri")

        if command = "upload" and info.DoesExist("movieUri") and info.DoesExist("movieName")
            uri = info.movieUri
            name = info.movieName
            print "Command Upload, MovieUri: " uri
            m.player.control = "stop"
            m.player.content = invalid
            m.content.url = uri
            m.player.content = m.content
            m.player.control = "play"
            m.playingLabel.text = "Playing: " + name

            regset(m.regkey+"lastMovie",uri)
            regset(m.regkey+"lastMovieName",name)
        end if
    end if
end sub

sub Main(args as Dynamic)
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    scene = screen.CreateScene("HelloWorld")
    screen.show()

    m.player = scene.findNode("player")

    m.paired = "<unset>"
    m.pairlabel = scene.findNode("pairLabel")
    m.pairLabel.text = "Currently Paired: " + regget("lastPaired","None")
    m.playingLabel = scene.findNode("playingLabel")
    m.playingLabel.text = ""

    m.content = CreateObject("roSGNode", "ContentNode")
    m.content.streamformat = "hls"
    
    lastMovie = regget("lastMovie","<unset>")
    if lastMovie <> "<unset>"
        m.content.url = lastMovie
        m.player.content = m.content
        m.player.control = "play"
    end if

    inputObject = CreateObject("roInput")
    inputObject.setMessagePort(m.port)

    if args <> invalid
        handleCommand(args)
    endif

    while true
        msg = wait(0, m.port)
        msgType = type(msg)

        if msgType = "roSGScreenEvent" and msg.isScreenClosed()
            return
        else if msgType = "roInputEvent"
            inputData = msg.getInfo()
            handleCommand(inputData)
        else if msgType = "roVideoPlayerEvent"
            if msg.isPlaybackDone()
                regdet("lastPaired")
                regdet("lastMovie")
            end if
        end if
    end while
end sub