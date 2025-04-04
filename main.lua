local suits = {"hearts", "diamonds", "clubs", "spades"}
local ranks = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}

local cardValues = {
    ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6, ["7"] = 7,
    ["8"] = 8, ["9"] = 9, ["10"] = 10, ["J"] = 11, ["Q"] = 12, ["K"] = 13, ["A"] = 14
}

local deck = {}
local cardImages = {}
local hand = {}
local setCards = {}
local firstHandSetValues = {2, 3, 4, 5, 6, 7}
local opponentHand = {}

local canRunAway = false
local fillHand = false
local dragginPresent = false

local draggingCard = nil

local offsetX, offsetY = 0, 0
local setValue = 0
love.graphics.setDefaultFilter("nearest", "nearest")

function loadCardImages()
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            local cardName = rank .. suit 
            cardImages[cardName] = love.graphics.newImage("sprites/cardImages/" .. cardName .. ".png")
        end
    end
end

function createDeck()
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            local cardName = rank .. suit
            local cardValue = cardValues[rank]
            table.insert(deck, {name = cardName, value = cardValue})
        end
    end
end


function shuffleDeck()
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end

end

function pickCards()
    local xOffset = 150
    local yOffset = 300
    local spacing = 50
    local card
    for i = 1, 10 do
        card = table.remove(deck)
        card.x = xOffset
        card.y = yOffset
        card.originalX = xOffset
        card.originalY = yOffset
        card.width = 50
        card.height = 150
        card.xText = card.originalX + 5
        card.yText = card.originalY - 15
        table.insert(hand, card)
        xOffset = xOffset + spacing
        table.remove(card)
    end
end

function setOpponentHand()
    local xOffset = 150
    local yOffset = 150
    local spacing = 50
    local card
    for i = 1, 10 do
        card = table.remove(deck)
        card.x = xOffset
        card.y = yOffset
        card.originalX = xOffset
        card.originalY = yOffset
        card.width = 50
        card.height = 150
        card.xText = card.originalX + 5
        card.yText = card.originalY - 15
        table.insert(opponentHand, card)
        xOffset = xOffset + spacing
        table.remove(card)
    end
end

function callCard()
    local cardCheck = "2diamonds"
    for i, card in ipairs(opponentHand) do
        if card.name == cardCheck then
            card.x = 150 + (#hand * 50)
            card.y = 300
            card.originalX = card.x
            card.originalY = card.y
            card.width = 50
            card.height = 150
            card.xText = card.x + 5
            card.yText = card.y - 15

            table.insert(hand, card)
            table.remove(opponentHand, i)

            print("Card added to hand:", card.name)
            return
        end
    end
end

function setCheck(value, list)
    for _, v in ipairs(list) do
        if value == v then
            return true
        end
    end
    return false
end
function setDrop()
    local cardCheck = "diamonds"
    if dragginPresent then
        if draggingCard.y > 400 and string.find(draggingCard.name, cardCheck, 1, true) then
            setValue = draggingCard.value
        end
    end
end

function setCardManagement()
    local cardCheck = "diamonds"
    if dragginPresent then
        for i, card in ipairs(hand) do
            if draggingCard.y > 400 and string.find(draggingCard.name, cardCheck, 1, true) and setCheck(draggingCard.value, firstHandSetValues) then
                if card == draggingCard then
                    local oldX, oldY = draggingCard.originalX, draggingCard.originalY
                    table.insert(setCards, card)
                    table.remove(hand, i)
                    local newCard = table.remove(deck)
                    if newCard then
                        newCard.x = oldX
                        newCard.y = oldY
                        newCard.originalX = oldX
                        newCard.originalY = oldY
                        newCard.width = 50
                        newCard.height = 150
                        newCard.xText = oldX + 5
                        newCard.yText = oldY - 15
                        table.insert(hand, i, newCard)
                    end
                    showSetCard()
                break
                end
            end
        end
    end
end

function showSetCard()
    local isEmpty = true
    for _ in pairs(setCards) do
        isEmpty = false
        break
    end
    if not isEmpty then
        local xOffset = 200
        local yOffset = 400
        local spacing = 50
        for i, card in ipairs(setCards) do
            card.x = xOffset
            card.y = yOffset
            card.originalX = xOffset
            card.originalY = yOffset
            card.width = 50
            card.height = 150
            card.xText = card.originalX + 5
            card.yText = card.originalY - 15
            xOffset = xOffset + spacing
        end
    end
end

function runAway()
    canRunAway = false

    for i = #hand, 1, -1 do
        local card = hand[i]
        table.insert(deck, card)
        table.remove(hand, i)
    end
    for i = #opponentHand, 1, -1 do
        local card = opponentHand[i]
        table.insert(deck, card)
        table.remove(opponentHand, i)
    end

    shuffleDeck()
    fillHand = true

    if fillHand then
        pickCards()
        setOpponentHand()
    end
end

function love.load()
    math.randomseed(os.time())
    loadCardImages()
    createDeck()
    shuffleDeck()
    pickCards()
    setOpponentHand()
end

function love.update(dt)
    if love.keyboard.isDown('s') and canRunAway then
        runAway()
        print("working")
    end
    if love.keyboard.isDown('r') and not canRunAway then
        canRunAway = true
    end
    if draggingCard then
        local mouseX, mouseY = love.mouse.getPosition()
        draggingCard.x = mouseX - offsetX
        draggingCard.y = mouseY - offsetY
    end
    if love.keyboard.isDown('2') and not dragginPresent then
        callCard()
    end
end

function love.draw()
    for i, card in ipairs(hand) do
        local cardImage = cardImages[card.name]
        love.graphics.draw(cardImage, card.x, card.y, nil, 3, 3)
        love.graphics.print(card.value, card.xText, card.yText)
        love.graphics.print("setCard Index: " .. #setCards, 10, 25)
    end
    for i, card in ipairs(opponentHand) do
        local cardImage = cardImages[card.name]
        love.graphics.draw(cardImage, card.x, card.y, nil, 3, 3)
        love.graphics.print(card.value, card.xText, card.yText)
    end
    for i, card in ipairs(setCards) do
        local cardImage = cardImages[card.name]
        love.graphics.draw(cardImage, card.x, card.y, nil, 3, 3)
        love.graphics.print(card.value, card.xText, card.yText)
    end
    love.graphics.print(setValue, 10, 10)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        dragginPresent = true
        for i, card in ipairs(hand) do
            if x >= card.x and x <= card.x + card.width and y >= card.y and y <= card.y + card.height then
                draggingCard = card
                offsetX = x - card.x
                offsetY = y - card.y
                break
            end
        end
    end
end
function love.mousereleased(x, y, button)
    if button == 1 and draggingCard then
        setDrop()
        setCardManagement()
        dragginPresent = false
        draggingCard.x = draggingCard.originalX
        draggingCard.y = draggingCard.originalY
        draggingCard = nil
    end
end
