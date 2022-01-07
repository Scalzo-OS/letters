function love.load()
    gamestart()
end

function gamestart()
    level1 = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z'}
    level2 = {'`', '-', '=', '[', ']', '\\', ';', "'", ',', '.', '/'}
    level3 = {'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12'}
    level4 = {'tab', 'capslock', 'lshift', 'lctrl', 'lalt', 'space', 'ralt', 'left',
    'right', 'up', 'down', 'rshift', 'return', 'backspace', 'delete'}

    letter_list = {} --x, y, speed, hide
    window = {}
    love.window.setFullscreen(true)
    window.x, window.y = love.graphics.getDimensions()
    timer = 0
    bgfont = love.graphics.newFont(20)
    mainfont = love.graphics.newFont(100)
    letters = level1
    level = 1

    particles = {} --x, y, size, direction, speed
    prev_boxes = {} --x, y, w, h, line

    love.audio.play(love.audio.newSource('gamesound.mp3', 'static'))

    word_box = {}
    word_box.y = window.y/2 - 120
    word_box.h = 150
    word_box.w = 120
    word_box.x = window.x/2 - word_box.w/2

    gameover = false

    score = {}
    score.s = 0
    score.x = window.x/2 - (50 * #tostring(score.s))
    score.xg = math.random(-50, 50)
    score.y = 30

    gametimer = 0

    timerstarted = false

    mainletter = {}
    mainletter.x = 0
    mainletter.letter = 'a'
    mainletter.xg = math.random(-50, 50)
    mainletter.y = window.y/2-100

    levelfont = love.graphics.newFont(250)
end

function mergetables(table1, table2)
    t = {}
    n = 0
    for _,v in ipairs(table1) do n=n+1; t[n]=v end
    for _,v in ipairs(table2) do n=n+1; t[n]=v end
    return t
end

function love.update(dt)
    timer = timer + dt
    if not gameover then
        if timerstarted then
            gametimer = gametimer + dt
        end
        x = level
        if score.s == 20 then level = 2
        elseif score.s == 40 then level = 3
        elseif score.s == 60 then level = 4 end
        if x < level then
            levelup = true
            leveltimer = 0
            levelshow = true
            flashing = false
            flashed = 0
            for i=1, math.random(100, 200) do
                table.insert(particles, {math.random(0, window.x), math.random(0, window.y), math.random(3, 8), math.random(0, 360), math.random(5, 10)})
            end
            love.audio.play(love.audio.newSource('level.wav', 'static'))
        end

        if levelup then
            leveltimer = leveltimer + dt
            if leveltimer >= 0.3 and not flashing then
                leveltimer = 0
                flashing = true
            end
            if flashing then
                if leveltimer >= 0.3 - (0.05 * flashed) and flashed <= 20 then
                    if levelshow then levelshow = false
                    else levelshow = true end
                    leveltimer = 0
                    flashed = flashed + 1
                end
            end
            if flashed >= 20 then
                levelup = false
            end
        end

        if level == 1 then letters = level1
        elseif level == 2 then letters = mergetables(level1, level2)
        elseif level == 3 then letters = mergetables(mergetables(level1, level2), level3)
        elseif level == 4 then letters = mergetables(mergetables(level1, level2), mergetables(level3, level4)) end

        for i=#letter_list, 1, -1 do
            letter_list[i][2] = letter_list[i][2] + (letter_list[i][3]*level)
            if letter_list[i][2] > window.y then
                table.remove(letter_list, i)
            end
            if not (letter_list[i][1] - (20*#mainletter.letter) <= word_box.x + word_box.w and letter_list[i][1] + 20*#mainletter.letter >= word_box.x
            and letter_list[i][2] >= word_box.y and letter_list[i][2] <= word_box.y + word_box.h) then
                letter_list[i][4] = true
            else letter_list[i][4] = false end
        end

        if timer >= (0.03 - level * 0.01) then
            timer = 0
            table.insert(letter_list, {math.random(0, window.x), 0, math.random(2, 6), false})
        end

        for i=#particles, 1, -1 do
            if particles[i][3] <= 0.1 then
                table.remove(particles, i)
            else
                particles[i][3] = particles[i][3] - particles[i][3]/15
                particles[i][1] = particles[i][1] + math.cos(particles[i][4])*particles[i][5]
                particles[i][2] = particles[i][2] + math.sin(particles[i][4])*particles[i][5]
            end
        end

        for i=#prev_boxes, 1, -1 do
            if prev_boxes[i][5] <= 0.1 then
                table.remove(prev_boxes, i)
            else
                prev_boxes[i][1] = prev_boxes[i][1] - 10
                prev_boxes[i][2] = prev_boxes[i][2] - 10
                prev_boxes[i][3] = prev_boxes[i][3] + 20
                prev_boxes[i][4] = prev_boxes[i][4] + 20
                prev_boxes[i][5] = prev_boxes[i][5] - prev_boxes[i][5]/10
            end
        end
      
        if score.s >= 100 then
            gameover = true
            win = true
            for i=1, math.random(100, 200) do
                table.insert(particles, {math.random(0, window.x), math.random(0, window.y), math.random(3, 8), math.random(0, 360), math.random(5, 10)})
            end
        end
    end
    if win then
        if timer >= 0.03 then
            timer = 0
            table.insert(letter_list, {math.random(0, window.x), 0, math.random()*math.random(6, 30)})
        end
        for i=#letter_list, 1, -1 do
            letter_list[i][2] = letter_list[i][2] + letter_list[i][3]
            if letter_list[i][2] > window.y then
                table.remove(letter_list, i)
            end
        end
        for i=#particles, 1, -1 do
            if particles[i][3] <= 0.1 then
                table.remove(particles, i)
            else
                particles[i][3] = particles[i][3] - particles[i][3]/15
                particles[i][1] = particles[i][1] + math.cos(particles[i][4])*particles[i][5]
                particles[i][2] = particles[i][2] + math.sin(particles[i][4])*particles[i][5]
            end
        end
    end
end

function love.draw()
    if gameover then
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.print('Type R to restart and esc to quit', window.x/2-240, window.y - 50)
        if lose then
            love.graphics.setFont(mainfont)
            love.graphics.print('YOU LOSE', window.x/2 -250, 100)
            love.graphics.print('Score: '..score.s, window.x/2-300, window.y/2)
            love.graphics.print('Time: '..round(gametimer, 3), window.x/2-300, window.y - 300)
        end
        if win then
            love.graphics.setFont(mainfont)
            love.graphics.print('YOU WIN!', window.x/2-250, 100)
            love.graphics.print('Time: '..round(gametimer, 3), window.x/2-300, window.y - 500)
            love.graphics.setFont(love.graphics.newFont(40))
            love.graphics.print('Letters per second: '..round(score.s/gametimer,2), window.x/2-280, window.y/2+200)
            love.graphics.setFont(bgfont)
            for i=1, #letter_list do
                love.graphics.print('YOU WIN!', letter_list[i][1], letter_list[i][2])
            end
        end
    else
        love.graphics.setFont(bgfont)
        for i=1, #letter_list do
            if letter_list[i][4] == true then
                love.graphics.print(mainletter.letter, letter_list[i][1], letter_list[i][2])
            end
        end
        love.graphics.setFont(mainfont)
        love.graphics.printf(mainletter.letter, mainletter.x, mainletter.y, window.x, 'center')
        love.graphics.setLineWidth(10)
        love.graphics.rectangle('line', word_box.x, word_box.y, word_box.w, word_box.h)
        love.graphics.print(score.s, score.x, score.y)
        love.graphics.print(round(gametimer, 3), window.x/2-130, window.y-200)

        for i=1, #particles do
            love.graphics.circle('fill', particles[i][1], particles[i][2], particles[i][3])
        end

        for i=1, #prev_boxes do
            love.graphics.setLineWidth(prev_boxes[i][5])
            love.graphics.rectangle('line', prev_boxes[i][1], prev_boxes[i][2], prev_boxes[i][3], prev_boxes[i][4])
        end

        if levelup then
            if levelshow then
                love.graphics.setFont(levelfont)
                love.graphics.print('LEVEL', window.x/2-390, window.y/2-300)
                love.graphics.print('UP', window.x/2-180, window.y/2-70)
            end
        end
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    if key == mainletter.letter then
        love.audio.play(love.audio.newSource('use.wav', 'static'))
        timerstarted = true
        next_letter = letters[math.random(1, #letters)]
        while next_letter == mainletter.letter do
            next_letter = letters[math.random(1, #letters)]
        end
        mainletter.letter = next_letter
        score.s = score.s + 1

        for _=1, math.random(15*level, 25*level) do
            edge = math.random(1, 4)
            if edge == 1 then
                x = math.random(word_box.x, word_box.x+word_box.w)
                y = word_box.y
                direction = math.random(270, 450)
            elseif edge == 2 then
                x = math.random(word_box.x, word_box.x+word_box.w)
                y = word_box.y + word_box.h
                direction = math.random(90, 270)
            elseif edge == 3 then
                x = word_box.x
                y = math.random(word_box.y, word_box.y+word_box.h)
                direction = math.random(180, 360)
            else
                x = word_box.x + word_box.w
                y = math.random(word_box.y, word_box.y+word_box.h)
                direction = math.random(0, 180)
            end
            table.insert(particles, {x, y, math.random(8, 15), direction, math.random(10, 20)})
        end

        for i=0, level-1 do
            table.insert(prev_boxes, {word_box.x+i*50, word_box.y+i*50, word_box.w-100*i, word_box.h-100*i, 10-i})
        end

        if #mainletter.letter == 1 then word_box.w = 120 else word_box.w = 80*#mainletter.letter end
        word_box.x = window.x/2 - word_box.w/2

    elseif not gameover then
        gameover = true
        lose = true
    end
    if gameover then
        if key == 'r' then
            gameover = false
            lose = false
            win = false
            love.audio.stop()
            gamestart()
        end
    end
end

function round(num, dp)
    mult = 10^(dp or 0)
    return math.floor(mult*num + 0.5)/mult
end