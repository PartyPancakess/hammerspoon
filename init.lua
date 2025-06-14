local IMAGE_PATH = "./keyboard_layout.png"

local imageCanvas = nil
local cachedImage = nil

local function hideImage()
    if imageCanvas then
        -- Clear all canvas elements first
        imageCanvas:replaceElements()
        imageCanvas:hide()
        imageCanvas:delete()
        imageCanvas = nil
        -- Force garbage collection
        collectgarbage("collect")
    end
end

local function loadImageOnce()
    if not cachedImage then
        cachedImage = hs.image.imageFromPath(IMAGE_PATH)
        if not cachedImage then
            hs.alert.show("Could not load image: " .. IMAGE_PATH)
            return nil
        end
    end
    return cachedImage
end

local function showImage()
    if imageCanvas then
        hideImage() -- Hide existing canvas first
    end

    -- Get the cached image
    local image = loadImageOnce()
    if not image then
        return
    end

    -- Get the main screen dimensions
    -- local screen = hs.screen.mainScreen()
    -- local screenFrame = screen:frame()
    local screenFrame = {
        w = 1728.0,
        h = 994.0,
    }

    local imageSize = image:size()
    -- Resize for my use-cases
    imageSize = {
        w = imageSize.w * 2 / 3,
        h = imageSize.h * 2 / 3,
    }

    -- Calculate position to center the image
    local x = (screenFrame.w - imageSize.w) / 2
    local y = (screenFrame.h - imageSize.h) / 2

    -- Create canvas
    imageCanvas = hs.canvas.new({
        x = x,
        y = y,
        w = imageSize.w,
        h = imageSize.h
    })

    -- Add the image to canvas
    imageCanvas:appendElements({
        type = "image",
        image = image,
        frame = { x = 0, y = 0, w = imageSize.w, h = imageSize.h }
    })

    imageCanvas:level(hs.canvas.windowLevels.overlay)
    imageCanvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    imageCanvas:show()
end

local function keyEventHandler(event)
    local keyCode = event:getKeyCode()
    local eventType = event:getType()

    if keyCode == 79 then -- F18
        if eventType == hs.eventtap.event.types.keyDown then
            showImage()
            return true -- Consume the event
        elseif eventType == hs.eventtap.event.types.keyUp then
            hideImage()
            return true -- Consume the event
        end
    end
    return false -- Don't consume other events
end

local keyTap = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp
}, keyEventHandler)

keyTap:start()


-- disable command + q behavior of MacOS
hs.hotkey.bind({ "cmd" }, "q", function() end)


local function cleanup()
    if keyTap then
        keyTap:stop()
        keyTap = nil
    end
    hideImage()
    -- Release the cached image
    if cachedImage then
        cachedImage = nil
    end
    -- Force garbage collection
    collectgarbage("collect")
end

-- Register cleanup for when Hammerspoon reloads
hs.shutdownCallback = cleanup
