require ("arquivos/menu")

function love.load()
	sprites = {}
	sprites.player = love.graphics.newImage("sprites/gato1.png")
	sprites.bullets = love.graphics.newImage("sprites/star.png")
	sprites.zumbies = love.graphics.newImage("sprites/zumbi1.png")
	sprites.background = love.graphics.newImage("sprites/fundo.png")
	state = 'menu'
	menu.load()
	
	player = {}
	player.x = love.graphics.getWidth()/2 --posicao inicial do player
	player.y = love.graphics.getHeight()/2
	player.speed = 180 -- aqui muda a velocidade do player

	zumbies = {} -- matriz dos zumbis
	bullets = {} -- matriz das balas

	gameState = 2
	maxTime = 2
	timer = maxTime

	score = 0

end

function love.update(dt)

	if(state == 'menu')  then
		menu.update()

	else

		if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then -- movimentação do personagem (baixo)
			player.y = player.y + player.speed * dt --velocidade
		end

		if love.keyboard.isDown("w") and player.y > 0 then -- movimentação do personagem (cima)
			player.y = player.y - player.speed * dt --velocidade
		end

		if love.keyboard.isDown("a") and palyer.x > 0 then -- movimentação do personagem (esquerda)
			player.x = player.x - player.speed * dt --velocidade
		end

		if love.keyboard.isDown("d") and palyer.x < love.graphics.getWidth() then -- movimentação do personagem (direita)
			player.x = player.x + player.speed * dt-- velocidade
		end

		for i,z in ipairs(zumbies) do
			z.x = z.x + math.cos(playerZumbieAngulo(z)) * z.speed * dt
			z.y = z.y + math.sin(playerZumbieAngulo(z)) * z.speed * dt
			
			if distanciaEntre(z.x, z.y, player.x, player.y) < 30 then -- distancia entre o zumbi e o player
				for i,z in ipairs(zumbies) do
					zumbies[i] = nil 
					gameState = 1
					player.x = love.graphics.getWidth()/2
					player.y = love.graphics.getHeight()/2
				end
			end
		end

		for i,b in ipairs(bullets) do -- a bala move aqui
			b.x = b.x + math.cos(b.direction) * b.speed * dt
			b.y = b.y + math.sin(b.direction) * b.speed * dt
		end

		for i=#bullets, 1, -1 do
			local b = bullets[i]
			if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
				table.remove(bullets, i) 
			end
		end

		for i,z in ipairs(zumbies) do
			for j,b in ipairs(bullets) do
				if distanciaEntre(z.x, z.y, b.x, b.y) <28 then
					z.dead=true -- aqui faz desaparecer o zumbi
					b.dead=true -- aqui faz desaparecer a bala
					score = score + 1
				end
			end
		end

		for i=#zumbies,1,-1 do
			local z = zumbies[i]
			if z.dead == true then
				table.remove(zumbies, i)
			end
		end

		for i=#bullets, 1, -1 do
			local b = bullets[i]
			if b.dead == true then
				table.remove(bullets, i)
			end
		end

		if gameState == 2 then
			timer = timer - dt
			if timer <= 0 then
				spawnZumbie()
				maxTime = maxTime * 0.95
				timer = maxTime
			
			end
		end
	end

end

function love.draw()
	if(state == 'menu')  then
		menu.draw()

	else
		love.graphics.draw(sprites.background, 0, 0)
		love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngulo(), 1, 1, sprites.player:getWidth()/2, sprites.player:getHeight()/2)	

		for i,z in ipairs(zumbies) do
			love.graphics.draw(sprites.zumbies, z.x, z.y, playerZumbieAngulo(z), 0.7, 0.7, sprites.zumbies:getWidth()/2, sprites.zumbies:getHeight()/2)
		end

		for i,b in ipairs (bullets) do
			love.graphics.draw(sprites.bullets, b.x, b.y, 1, 0.5, 0.5, sprites.bullets:getWidth()/2, sprites.bullets:getHeight()/2)
		end
	end

	love.graphics.printf("Score =  " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")
end



function playerZumbieAngulo(enemy)
	return math.atan2(player.y - enemy.y, player.x - enemy.x)
end

-- calcula a rotação do personagem
function playerMouseAngulo()
	return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi 
end

-- aqui é para aparecer os zumbis
function spawnZumbie()
	zumbie = {}
	zumbie.x = 0
	zumbie.y = 0
	zumbie.speed = 100 -- aqui muda a velocidade do zumbi
	zumbie.dead = false

	local side = math.random(1,4)

	if side == 1 then -- esquerda
		zumbie.x = -30
		zumbie.y = math.random(0, love.graphics.getHeight())

	elseif side == 2 then -- direita
		zumbie.x = math.random(0, love.graphics.getWidth())
		zumbie.y = -30

	elseif side == 3 then -- top
		zumbie.x = love.graphics.getWidth() + 30
		zumbie.y = math.random(0, love.graphics.getHeight())
	else
		zumbie.x = math.random(0, love.graphics.getWidth())
		zumbie.y = love.graphics.getHeight() + 30
	end

	table.insert(zumbies, zumbie) --aqui eu coloquei a matriz com um zumbi na matriz zumbis para aparecer vários zumbis
end

function spawnBullets()
	bullet = {}
	bullet.x = player.x
	bullet.y = player.y
	bullet.speed = 500
	bullet.direction = playerMouseAngulo()
	bullet.dead = false

	table.insert(bullets, bullet)
end

-- aqui faz aparecer os zumbis quando a tecla espaço é apertada
function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		spawnZumbie()
	end
end

function love.mousepressed(x, y, b, istouch)
	if b == 1 then
		spawnBullets()
	end
end

function distanciaEntre(x1, y1, x2, y2)
	return math.sqrt((y2-y1)^2 + (x2-x1)^2)
end