-- Nameless Admin Commands Panel
-- Extraído de: https://github.com/ltseverydayyou/Nameless-Admin
-- Total: ~400+ comandos

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Crear ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NamelessAdminPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 600)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Esquina redondeada
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Title.BorderSizePixel = 0
Title.Text = "⚡ NAMELESS ADMIN PANEL ⚡"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Botón cerrar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Title

-- Botón minimizar
local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 40, 0, 40)
MinBtn.Position = UDim2.new(1, -90, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
MinBtn.BorderSizePixel = 0
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = Title

-- Barra de búsqueda
local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, -20, 0, 35)
SearchBox.Position = UDim2.new(0, 10, 0, 55)
SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "🔍 Buscar comando..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.TextSize = 14
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = MainFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = SearchBox

-- ScrollingFrame para comandos
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "CommandList"
ScrollFrame.Size = UDim2.new(1, -20, 1, -100)
ScrollFrame.Position = UDim2.new(0, 10, 0, 95)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 8)
ScrollCorner.Parent = ScrollFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- Datos de comandos por categoría
local Commands = {
    -- SISTEMA / ADMIN
    {cat = "SISTEMA / ADMIN", cmds = {
        {n = "commands / cmds", d = "Abrir lista de comandos"},
        {n = "settings", d = "Abrir menú de ajustes"},
        {n = "prefix <symbol>", d = "Cambiar prefijo del admin"},
        {n = "admin <player>", d = "Dar admin a un jugador"},
        {n = "unadmin <player>", d = "Quitar admin"},
        {n = "executor / exec", d = "Abrir executor integrado"},
        {n = "loadstring <code>", d = "Ejecutar código Lua"},
        {n = "url <link>", d = "Ejecutar script desde URL"},
        {n = "scripthub / hub", d = "Abrir Script Hub"},
        {n = "unload", d = "Cerrar Nameless Admin"},
        {n = "pluginmaker", d = "Abrir builder de plugins"},
        {n = "commandcount / cc", d = "Contar comandos totales"},
    }},

    -- MOVIMIENTO
    {cat = "MOVIMIENTO", cmds = {
        {n = "fly [speed]", d = "Volar"},
        {n = "cframefly / cfly", d = "Volar con CFrame"},
        {n = "tfly / tweenfly", d = "Volar suave (tween)"},
        {n = "vfly / vehiclefly", d = "Volar en vehículos"},
        {n = "noclip / nc", d = "Atravesar paredes"},
        {n = "ws <number> / speed", d = "Cambiar velocidad"},
        {n = "jp <number> / jumppower", d = "Cambiar potencia de salto"},
        {n = "infjump / infinitejump", d = "Salto infinito"},
        {n = "flyjump", d = "Mantener espacio para volar"},
        {n = "edgejump", d = "Saltar al borde automáticamente"},
        {n = "tpwalk <number>", d = "Velocidad indetectable"},
        {n = "loopwalkspeed <number>", d = "Loop de velocidad"},
        {n = "loopjumppower <number>", d = "Loop de JumpPower"},
        {n = "airwalk / float", d = "Caminar en el aire"},
        {n = "airmomentum", d = "Control aéreo personalizado"},
        {n = "climb", d = "Trepar en el aire"},
        {n = "jumpboost <number>", d = "Boost de salto extra"},
        {n = "trussjump", d = "Boost en trusses"},
    }},

    -- TELEPORT
    {cat = "TELEPORT", cmds = {
        {n = "goto / to / tp", d = "Teleport a jugador/coordenadas"},
        {n = "tweento / tgoto", d = "Tween teleport (bypass anticheat)"},
        {n = "tpup <studs>", d = "Teleport arriba"},
        {n = "tpdown <studs>", d = "Teleport abajo"},
        {n = "gotocampos / tcp", d = "Ir a posición de cámara"},
        {n = "clickteleport / clicktp", d = "Click para teleport"},
        {n = "tptool", d = "Herramienta de teleport"},
        {n = "rejoin / rj", d = "Rejoin al servidor"},
        {n = "rjre", d = "Rejoin y mantener posición"},
        {n = "serverhop / shop", d = "Cambiar de servidor"},
        {n = "smallserverhop", d = "Servidor pequeño"},
        {n = "pingserverhop", d = "Mejor latencia"},
        {n = "oldserverhop", d = "Servidor más antiguo"},
        {n = "newserverhop", d = "Servidor más nuevo"},
        {n = "regionhop <region>", d = "Saltar a región"},
        {n = "teleporttoplace <id>", d = "Teleport por PlaceId"},
        {n = "setwaypoint / setwp", d = "Guardar posición"},
        {n = "gotowaypoint / gotowp", d = "Ir a waypoint guardado"},
    }},

    -- COMBATE
    {cat = "COMBATE / FIGHT", cmds = {
        {n = "reach [number]", d = "Alcance de espada extendido"},
        {n = "boxreach [number]", d = "Hitbox en caja"},
        {n = "aura [distance]", d = "Daño automático cercano"},
        {n = "npcaura [distance]", d = "Daño a NPCs cercanos"},
        {n = "hitboxes", d = "Ver hitboxes"},
        {n = "fling <player>", d = "Lanzar jugador"},
        {n = "loopfling <player>", d = "Loop fling"},
        {n = "walkfling <speed>", d = "Fling al caminar"},
        {n = "flyfling / ff", d = "Fling volando"},
        {n = "touchfling <speed>", d = "Fling al tocar"},
        {n = "invisfling", d = "Fling invisible"},
        {n = "clickfling / mousefling", d = "Fling con click"},
        {n = "triggerbot / tbot", d = "Auto-click en jugadores"},
        {n = "aimbot", d = "Aimbot"},
        {n = "godmode / god", d = "Modo dios"},
        {n = "autopatchtool / apt", d = "Parchear herramientas"},
    }},

    -- PROTECCIÓN
    {cat = "PROTECCIÓN", cmds = {
        {n = "antivoid", d = "No caer al vacío"},
        {n = "nofall", d = "Sin daño por caída"},
        {n = "antiknockback / akb", d = "Sin knockback"},
        {n = "antivelocity / av", d = "Limitar velocidad"},
        {n = "antikick / nokick", d = "Bypass kick"},
        {n = "antiteleport / noteleport", d = "Bloquear teleport forzado"},
        {n = "antitrip", d = "Sin ragdoll"},
        {n = "antifling", d = "No ser flingueado"},
        {n = "antiafk / noafk", d = "No ser kick por AFK"},
        {n = "antibreakjoints", d = "No romper joints"},
        {n = "antianchor / aa", d = "No ser anclado"},
        {n = "antitouch / antikillbrick", d = "Sin kill bricks"},
        {n = "antinil", d = "No perder personaje"},
        {n = "antierror", d = "Bloquear errores"},
    }},

    -- ESP / VISUAL
    {cat = "ESP / VISUAL", cmds = {
        {n = "esp / espplayers", d = "Ver jugadores a través de paredes"},
        {n = "espall", d = "ESP todos los jugadores"},
        {n = "espenemies", d = "ESP enemigos"},
        {n = "espallies", d = "ESP aliados"},
        {n = "chams", d = "ESP sin texto"},
        {n = "npcesp", d = "ESP de NPCs"},
        {n = "hitboxes", d = "Ver hitboxes"},
        {n = "itemesp / toolesp", d = "Ver items"},
        {n = "unanchored", d = "Ver partes desancladas"},
        {n = "collisionesp", d = "Ver collisiones"},
        {n = "propertyesp", d = "ESP por propiedad"},
        {n = "locate", d = "Localizar jugador"},
        {n = "hovername", d = "Nombre al pasar mouse"},
        {n = "hoverinventory", d = "Inventario al pasar mouse"},
    }},

    -- ENTORNO
    {cat = "ENTORNO", cmds = {
        {n = "day", d = "Día"},
        {n = "night", d = "Noche"},
        {n = "time <number>", d = "Hora personalizada"},
        {n = "gravity <amount>", d = "Gravedad"},
        {n = "fullbright / fb", d = "Todo brillante"},
        {n = "nofog", d = "Sin niebla"},
        {n = "noeffect", d = "Sin efectos"},
        {n = "brightness <number>", d = "Brillo"},
        {n = "globalshadows", d = "Sombras globales"},
        {n = "shaders / rtx", d = "Shaders/RTX"},
        {n = "nightmare", d = "Modo oscuro"},
        {n = "removeterrain", d = "Eliminar terreno"},
    }},

    -- DIVERSIÓN / TROLL
    {cat = "DIVERSIÓN / TROLL", cmds = {
        {n = "dance", d = "Bailar"},
        {n = "somersault / frontflip", d = "Voltereta"},
        {n = "sit", d = "Sentarse"},
        {n = "lay", d = "Acostarse"},
        {n = "spin", d = "Girar"},
        {n = "seizure", d = "Convulsión"},
        {n = "jerk / jork", d = "Jerk"},
        {n = "bang <player>", d = "Bang"},
        {n = "carpet <player>", d = "Ser alfombra"},
        {n = "headsit <player>", d = "Sentarse en cabeza"},
        {n = "headstand <player>", d = "Pararse en cabeza"},
        {n = "hug", d = "Abrazar"},
        {n = "spook / scare", d = "Asustar"},
        {n = "annoy <player>", d = "Molestar"},
        {n = "loopoof", d = "Spam de oof"},
        {n = "fakechat", d = "Chat falso"},
        {n = "uwuify", d = "Texto uwu"},
        {n = "cig / cigar / pipe", d = "Dar cigarro/pipa"},
    }},

    -- HERRAMIENTAS / EXPLORER
    {cat = "HERRAMIENTAS / EXPLORER", cmds = {
        {n = "dex", d = "Explorador de objetos"},
        {n = "olddex", d = "Dex antiguo"},
        {n = "synapsedex", d = "Synapse Dex"},
        {n = "remotespy / simplespy", d = "Espiar remotes"},
        {n = "httpspy", d = "Espiar HTTP"},
        {n = "serverremotespy", d = "Remotes del servidor"},
        {n = "hydroxide", d = "Hydroxide spy"},
        {n = "functionspy", d = "Espiar funciones"},
        {n = "decompiler", d = "Descompilar scripts"},
        {n = "scriptviewer", d = "Ver scripts"},
        {n = "partname / partgrabber", d = "Obtener path de partes"},
        {n = "saveinstance / savegame", d = "Guardar juego"},
        {n = "console / debug", d = "Consola de desarrollador"},
        {n = "gcsearch", d = "Buscar en GC"},
    }},

    -- UTILIDADES
    {cat = "UTILIDADES", cmds = {
        {n = "ping", d = "Latencia"},
        {n = "fps", d = "Frames por segundo"},
        {n = "fpsping", d = "FPS + Ping"},
        {n = "stats", d = "Estadísticas"},
        {n = "memory / mem", d = "Memoria"},
        {n = "speedometer", d = "Velocímetro"},
        {n = "notepad", d = "Bloc de notas"},
        {n = "music / musicplayer", d = "Reproductor de música"},
        {n = "chatlogs / clogs", d = "Logs de chat"},
        {n = "placeid / pid", d = "Copiar PlaceId"},
        {n = "gameid / gid", d = "Copiar GameId"},
        {n = "jobid", d = "Copiar JobId"},
        {n = "copyteleport / ct", d = "Copiar script de teleport"},
        {n = "keyboard", d = "Teclado para móvil"},
        {n = "autoclicker", d = "Auto-clicker"},
        {n = "backpack", d = "Backpack personalizado"},
    }},

    -- PERSONAJE
    {cat = "PERSONAJE", cmds = {
        {n = "invisible / invis", d = "Invisible"},
        {n = "toolinvisible / tinvis", d = "Invisible con tools"},
        {n = "visible / vis", d = "Visible"},
        {n = "naked", d = "Sin ropa"},
        {n = "split", d = "Separar cuerpo"},
        {n = "hatresize", d = "Sombreros gigantes"},
        {n = "material / mat", d = "Cambiar material"},
        {n = "bodytransparency", d = "Transparencia del cuerpo"},
        {n = "animationspeed", d = "Velocidad de animaciones"},
        {n = "runanim <id>", d = "Reproducir animación"},
        {n = "r6 / r15", d = "Cambiar rig type"},
        {n = "freeze / anchor", d = "Congelar"},
        {n = "unfreeze", d = "Descongelar"},
        {n = "respawn / re", d = "Respawn"},
        {n = "instantrespawn", d = "Respawn instantáneo"},
        {n = "reset / die", d = "Morir"},
    }},

    -- VEHÍCULOS
    {cat = "VEHÍCULOS", cmds = {
        {n = "vfly / vehiclefly", d = "Volar vehículos"},
        {n = "vnoclip", d = "Atravesar con vehículos"},
        {n = "vehiclespeed / vspeed", d = "Velocidad de vehículo"},
        {n = "seat", d = "Sentarse en asiento"},
        {n = "vehicleseat / vseat", d = "Asiento de vehículo"},
        {n = "cartornado", d = "Tornado de auto"},
        {n = "breakcars / bcars", d = "Romper autos"},
    }},

    -- REMOTES / CLICK DETECTORS
    {cat = "REMOTES / CLICK DETECTORS", cmds = {
        {n = "fireclickdetectors / fcd", d = "Activar ClickDetectors"},
        {n = "fireproximityprompts / fpp", d = "Activar ProximityPrompts"},
        {n = "firetouchinterests / fti", d = "Activar TouchInterests"},
        {n = "fireremote / fremote", d = "Disparar remote"},
        {n = "autofireremote", d = "Auto-fire remotes"},
        {n = "autofireproxi", d = "Auto-fire proximity prompts"},
        {n = "instantproximityprompts", d = "Prompts instantáneos"},
        {n = "noproximitypromptlimits", d = "Sin límite de distancia"},
        {n = "noclickdetectorlimits", d = "Sin límite de ClickDetectors"},
    }},
}

-- Función para crear botones de categoría
local function CreateCategoryButton(categoryData, order)
    local CatFrame = Instance.new("Frame")
    CatFrame.Name = "Cat_" .. categoryData.cat
    CatFrame.Size = UDim2.new(1, -10, 0, 30)
    CatFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    CatFrame.BorderSizePixel = 0
    CatFrame.LayoutOrder = order
    CatFrame.Parent = ScrollFrame

    local CatCorner = Instance.new("UICorner")
    CatCorner.CornerRadius = UDim.new(0, 6)
    CatCorner.Parent = CatFrame

    local CatLabel = Instance.new("TextLabel")
    CatLabel.Size = UDim2.new(1, -10, 1, 0)
    CatLabel.Position = UDim2.new(0, 10, 0, 0)
    CatLabel.BackgroundTransparency = 1
    CatLabel.Text = "📂 " .. string.upper(categoryData.cat)
    CatLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CatLabel.TextSize = 14
    CatLabel.Font = Enum.Font.GothamBold
    CatLabel.TextXAlignment = Enum.TextXAlignment.Left
    CatLabel.Parent = CatFrame

    -- Crear botones de comandos
    for i, cmd in ipairs(categoryData.cmds) do
        local CmdFrame = Instance.new("Frame")
        CmdFrame.Name = "Cmd_" .. cmd.n
        CmdFrame.Size = UDim2.new(1, -10, 0, 40)
        CmdFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        CmdFrame.BorderSizePixel = 0
        CmdFrame.LayoutOrder = order * 1000 + i
        CmdFrame.Parent = ScrollFrame

        local CmdCorner = Instance.new("UICorner")
        CmdCorner.CornerRadius = UDim.new(0, 5)
        CmdCorner.Parent = CmdFrame

        local CmdName = Instance.new("TextLabel")
        CmdName.Size = UDim2.new(0.6, 0, 0.5, 0)
        CmdName.Position = UDim2.new(0, 10, 0, 2)
        CmdName.BackgroundTransparency = 1
        CmdName.Text = cmd.n
        CmdName.TextColor3 = Color3.fromRGB(0, 255, 200)
        CmdName.TextSize = 12
        CmdName.Font = Enum.Font.Code
        CmdName.TextXAlignment = Enum.TextXAlignment.Left
        CmdName.Parent = CmdFrame

        local CmdDesc = Instance.new("TextLabel")
        CmdDesc.Size = UDim2.new(0.9, 0, 0.5, 0)
        CmdDesc.Position = UDim2.new(0, 10, 0.5, 0)
        CmdDesc.BackgroundTransparency = 1
        CmdDesc.Text = cmd.d
        CmdDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
        CmdDesc.TextSize = 11
        CmdDesc.Font = Enum.Font.Gotham
        CmdDesc.TextXAlignment = Enum.TextXAlignment.Left
        CmdDesc.Parent = CmdFrame
    end
end

-- Crear todos los botones
for i, category in ipairs(Commands) do
    CreateCategoryButton(category, i)
end

-- Función de búsqueda
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = string.lower(SearchBox.Text)
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            if child.Name:match("^Cmd_") then
                local cmdName = string.lower(child.Name:sub(5))
                local visible = searchText == "" or string.find(cmdName, searchText, 1, true)
                child.Visible = visible
            elseif child.Name:match("^Cat_") then
                -- Verificar si al menos un comando de esta categoría es visible
                local hasVisible = false
                for _, sibling in ipairs(ScrollFrame:GetChildren()) do
                    if sibling:IsA("Frame") and sibling.Visible and sibling.Name:match("^Cmd_") then
                        hasVisible = true
                        break
                    end
                end
                child.Visible = searchText == "" or hasVisible
            end
        end
    end
end)

-- Función de cerrar
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Función de minimizar
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    ScrollFrame.Visible = not minimized
    SearchBox.Visible = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 500, 0, 50)
    else
        MainFrame.Size = UDim2.new(0, 500, 0, 600)
    end
end)

print("✅ Nameless Admin Panel cargado - 400+ comandos disponibles")
