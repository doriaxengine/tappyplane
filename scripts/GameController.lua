local GameController = {
    properties = {
        { name = "flapStrength", displayName = "Flap Strength", type = "float", default = 520.0 },
        { name = "gravity", displayName = "Gravity", type = "float", default = -1650.0 },
        { name = "scrollSpeed", displayName = "Scroll Speed", type = "float", default = 240.0 },
        { name = "gapSize", displayName = "Gap Size", type = "float", default = 210.0 },
        { name = "pipeSpacing", displayName = "Pipe Spacing", type = "float", default = 430.0 },
        { name = "background1", displayName = "Background 1", type = "Sprite" },
        { name = "background2", displayName = "Background 2", type = "Sprite" },
        { name = "ground1", displayName = "Ground 1", type = "Sprite" },
        { name = "ground2", displayName = "Ground 2", type = "Sprite" },
        { name = "rockBottom1", displayName = "Rock Bottom 1", type = "Sprite" },
        { name = "rockTop1", displayName = "Rock Top 1", type = "Sprite" },
        { name = "rockBottom2", displayName = "Rock Bottom 2", type = "Sprite" },
        { name = "rockTop2", displayName = "Rock Top 2", type = "Sprite" },
        { name = "rockBottom3", displayName = "Rock Bottom 3", type = "Sprite" },
        { name = "rockTop3", displayName = "Rock Top 3", type = "Sprite" },
        { name = "rockBottom4", displayName = "Rock Bottom 4", type = "Sprite" },
        { name = "rockTop4", displayName = "Rock Top 4", type = "Sprite" },
        { name = "plane", displayName = "Plane", type = "Sprite" },
        { name = "planeAnimation", displayName = "Plane Animation", type = "SpriteAnimation" },
        { name = "scoreText", displayName = "Score", type = "Text" },
        { name = "bestText", displayName = "Best Score", type = "Text" },
        { name = "hintText", displayName = "Hint", type = "Text" },
        { name = "getReady", displayName = "Get Ready", type = "Image" },
        { name = "gameOver", displayName = "Game Over", type = "Image" },
        { name = "tapHint", displayName = "Tap Hint", type = "Image" },
        { name = "flapSound", displayName = "Flap", type = "Sound" },
        { name = "scoreSound", displayName = "Score Sound", type = "Sound" },
        { name = "hitSound", displayName = "Hit", type = "Sound" },
        { name = "gameOverSound", displayName = "Game Over Sound", type = "Sound" }
    }
}

local BEST_SCORE_KEY = "tappyplane_best_score"

local function clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function lerp(from, to, t)
    return from + (to - from) * clamp(t, 0.0, 1.0)
end

local function rectsOverlap(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and ax + aw > bx and ay < by + bh and ay + ah > by
end

function GameController:listSprites(...)
    local list = {}
    for i = 1, select("#", ...) do
        local sprite = select(i, ...)
        if sprite then
            list[#list + 1] = sprite
        end
    end
    return list
end

function GameController:addPipe(bottom, top)
    if not bottom or not top then
        return
    end
    self.pipes[#self.pipes + 1] = {
        bottom = bottom,
        top = top,
        x = 0,
        scored = false,
        bottomHeight = 200,
        topHeight = 200
    }
end

function GameController:init()
    self.time = 0
    RegisterEngineEvent(self, "onUpdate")

    Engine.callMouseInTouchEvent = true

    self.canvasW = Engine.canvasWidth
    self.canvasH = Engine.canvasHeight
    if self.canvasW <= 0 then self.canvasW = 1280 end
    if self.canvasH <= 0 then self.canvasH = 720 end

    self.groundHeight = 118
    self.planeWidth = 88
    self.planeHeight = 73
    self.pipeWidth = 140
    self.spawnX = self.canvasW * 0.28
    self.spawnY = self.canvasH * 0.55
    self.firstPipeX = self.canvasW + self.pipeWidth * 0.5 + 40

    self:bindScene()
    -- Overlap tiles by 2px so adjacent quads cannot leave a 1px crack
    -- that shows the scene clear color while they scroll.
    self.tileOverlap = 2
    self.bgWidth = (self.backgrounds[1] and self.backgrounds[1].width)
        or math.ceil(self.canvasH * (800 / 480))
    self.groundWidth = (self.grounds[1] and self.grounds[1].width)
        or math.ceil(self.groundHeight * (808 / 71))
    self.tapHintBaseY = self.tapHintBaseY or -38
    self:resetGame(true)
end

function GameController:bindScene()
    self.backgrounds = self:listSprites(self.background1, self.background2)
    self.grounds = self:listSprites(self.ground1, self.ground2)
    self.pipes = {}
    self:addPipe(self.rockBottom1, self.rockTop1)
    self:addPipe(self.rockBottom2, self.rockTop2)
    self:addPipe(self.rockBottom3, self.rockTop3)
    self:addPipe(self.rockBottom4, self.rockTop4)

    if self.tapHint then
        self.tapHintBaseY = self.tapHint.positionYOffset
    end
end

function GameController:playSound(sound)
    if not sound then return end
    sound:stop()
    sound:play()
end

function GameController:layoutPipe(pipe, x)
    local minBottom = 90
    local minTop = 90
    local maxGapCenter = self.canvasH - minTop - self.gapSize * 0.5
    local minGapCenter = self.groundHeight + minBottom + self.gapSize * 0.5
    local gapCenter = minGapCenter + math.random() * math.max(8.0, maxGapCenter - minGapCenter)

    local gapBottom = gapCenter - self.gapSize * 0.5
    local gapTop = gapCenter + self.gapSize * 0.5
    local bottomHeight = math.max(64, math.floor(gapBottom + 8))
    local topHeight = math.max(64, math.floor(self.canvasH - gapTop + 8))

    pipe.x = x
    pipe.scored = false
    pipe.bottomHeight = bottomHeight
    pipe.topHeight = topHeight
    pipe.bottom:setSize(self.pipeWidth, bottomHeight)
    pipe.top:setSize(self.pipeWidth, topHeight)
    pipe.bottom.position = Vector3(x, 0, 0)
    pipe.top.position = Vector3(x, self.canvasH, 0)
end

function GameController:resetPipes()
    for i = 1, #self.pipes do
        self:layoutPipe(self.pipes[i], self.firstPipeX + (i - 1) * self.pipeSpacing)
    end
end

function GameController:resetGame(initial)
    self.state = "ready"
    self.score = 0
    self.bestScore = UserSettings.getIntegerForKey(BEST_SCORE_KEY, 0)
    self.planeY = self.spawnY
    self.planeV = 0
    self.planeAngle = 0
    self.bgOffset = 0
    self.groundOffset = 0
    self.time = 0
    self.flapHeld = false
    self.restartDelay = 0

    self.plane.position = Vector3(self.spawnX, self.planeY, 3)
    self.plane:setRotation(0, 0, 0)
    if self.planeAnimation then
        self.planeAnimation:start()
    end

    self:resetPipes()
    self:syncHud()

    if not initial then
        self:playSound(self.flapSound)
    end
end

function GameController:syncHud()
    self.scoreText.text = tostring(self.score)
    self.gameOver.visible = self.state == "dead"
    self.getReady.visible = self.state == "ready"
    self.tapHint.visible = self.state == "ready"
    self.hintText.visible = self.state ~= "playing"
    self.bestText.visible = self.state == "dead"

    if self.state == "ready" then
        self.hintText.text = "Space, click or tap to fly"
    elseif self.state == "dead" then
        self.hintText.text = "Press again to retry"
        self.bestText.text = "Best  " .. tostring(self.bestScore)
    else
        self.hintText.text = ""
    end
end

function GameController:isFlapDown()
    return Input.isKeyPressed(Input.KEY_SPACE)
        or Input.isKeyPressed(Input.KEY_UP)
        or Input.isMousePressed(Input.MOUSE_BUTTON_LEFT)
        or Input.isTouch()
end

function GameController:flap()
    self.planeV = self.flapStrength
    self:playSound(self.flapSound)
end

function GameController:startRun()
    self.state = "playing"
    self:flap()
    self:syncHud()
end

function GameController:die()
    if self.state ~= "playing" then return end

    self.state = "dead"
    self.restartDelay = 0.45
    if self.score > self.bestScore then
        self.bestScore = self.score
        UserSettings.setIntegerForKey(BEST_SCORE_KEY, self.bestScore)
    end
    if self.planeAnimation then
        self.planeAnimation:pause()
    end
    self:playSound(self.hitSound)
    self:playSound(self.gameOverSound)
    self:syncHud()
end

function GameController:updateScrolling(dt, speed)
    local bgStep = math.max(1, self.bgWidth - self.tileOverlap)
    local groundStep = math.max(1, self.groundWidth - self.tileOverlap)
    self.bgOffset = (self.bgOffset + speed * 0.35 * dt) % bgStep
    self.groundOffset = (self.groundOffset + speed * dt) % groundStep

    for i = 1, #self.backgrounds do
        self.backgrounds[i].position = Vector3((i - 1) * bgStep - self.bgOffset, 0, -8)
    end
    for i = 1, #self.grounds do
        self.grounds[i].position = Vector3((i - 1) * groundStep - self.groundOffset, 0, 2)
    end
end

function GameController:rightmostPipeX()
    local maxX = self.pipes[1].x
    for i = 2, #self.pipes do
        if self.pipes[i].x > maxX then
            maxX = self.pipes[i].x
        end
    end
    return maxX
end

function GameController:updatePipes(dt)
    local recycleX = -self.pipeWidth
    for i = 1, #self.pipes do
        local pipe = self.pipes[i]
        pipe.x = pipe.x - self.scrollSpeed * dt
        if pipe.x < recycleX then
            self:layoutPipe(pipe, self:rightmostPipeX() + self.pipeSpacing)
        else
            pipe.bottom.position = Vector3(pipe.x, 0, 0)
            pipe.top.position = Vector3(pipe.x, self.canvasH, 0)
        end

        if not pipe.scored and pipe.x + self.pipeWidth * 0.15 < self.spawnX then
            pipe.scored = true
            self.score = self.score + 1
            self.scoreText.text = tostring(self.score)
            self:playSound(self.scoreSound)
        end
    end
end

function GameController:planeHitbox()
    local insetX = 16
    local insetY = 14
    return self.spawnX - self.planeWidth * 0.5 + insetX,
        self.planeY - self.planeHeight * 0.5 + insetY,
        self.planeWidth - insetX * 2,
        self.planeHeight - insetY * 2
end

function GameController:checkCollisions()
    local px, py, pw, ph = self:planeHitbox()
    if py <= self.groundHeight then
        return true
    end
    if py + ph >= self.canvasH then
        return true
    end

    local inset = 18
    for i = 1, #self.pipes do
        local pipe = self.pipes[i]
        local bx = pipe.x - self.pipeWidth * 0.5 + inset
        local bw = self.pipeWidth - inset * 2
        if rectsOverlap(px, py, pw, ph, bx, 0, bw, pipe.bottomHeight - 6) then
            return true
        end
        if rectsOverlap(px, py, pw, ph, bx, self.canvasH - pipe.topHeight + 6, bw, pipe.topHeight - 6) then
            return true
        end
    end

    return false
end

function GameController:updatePlaneVisuals()
    self.plane.position = Vector3(self.spawnX, self.planeY, 3)
    self.plane:setRotation(0, 0, self.planeAngle)
end

function GameController:onUpdate()
    if not self.plane or not self.scoreText then return end

    local dt = Engine.deltatime
    if dt > 0.05 then dt = 0.05 end
    self.time = self.time + dt

    local flapDown = self:isFlapDown()
    local flapPressed = flapDown and not self.flapHeld
    self.flapHeld = flapDown

    if self.state == "ready" then
        self.planeY = self.spawnY + math.sin(self.time * 3.2) * 14
        self.planeAngle = math.sin(self.time * 3.2) * 8
        if self.tapHint then
            self.tapHint.positionYOffset = self.tapHintBaseY + math.sin(self.time * 5.0) * 8
        end
        self:updateScrolling(dt, self.scrollSpeed * 0.35)
        self:updatePlaneVisuals()
        if flapPressed then
            self:startRun()
        end
        return
    end

    if self.state == "dead" then
        self.restartDelay = math.max(0, self.restartDelay - dt)
        self.planeV = self.planeV + self.gravity * dt
        self.planeY = math.max(self.groundHeight + self.planeHeight * 0.35, self.planeY + self.planeV * dt)
        self.planeAngle = lerp(self.planeAngle, -70, dt * 6)
        self:updatePlaneVisuals()
        if flapPressed and self.restartDelay <= 0 then
            self:resetGame(false)
        end
        return
    end

    if flapPressed then
        self:flap()
    end

    self.planeV = self.planeV + self.gravity * dt
    self.planeV = clamp(self.planeV, -900, 620)
    self.planeY = self.planeY + self.planeV * dt

    local targetAngle = clamp(self.planeV * 0.08, -35, 42)
    self.planeAngle = lerp(self.planeAngle, targetAngle, dt * 10)

    self:updateScrolling(dt, self.scrollSpeed)
    self:updatePipes(dt)
    self:updatePlaneVisuals()

    if self:checkCollisions() then
        self.planeY = math.max(self.planeY, self.groundHeight + self.planeHeight * 0.35)
        self:die()
    end
end

return GameController
