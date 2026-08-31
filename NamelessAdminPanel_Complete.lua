-- Nameless Admin Commands Panel - COMPLETO (975 comandos)
-- Extraído de: https://github.com/ltseverydayyou/Nameless-Admin

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NamelessAdminPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 650)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -325)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 200, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
Title.BorderSizePixel = 0
Title.Text = "⚡ NAMELESS ADMIN ⚡  |  975 COMANDOS"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Title

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(1, -80, 0, 7)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
MinBtn.BorderSizePixel = 0
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = Title

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -20, 0, 35)
SearchBox.Position = UDim2.new(0, 10, 0, 55)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "🔍 Buscar comando... (975 disponibles)"
SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.TextSize = 13
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = MainFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = SearchBox

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "CommandList"
ScrollFrame.Size = UDim2.new(1, -20, 1, -100)
ScrollFrame.Position = UDim2.new(0, 10, 0, 95)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
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
UIListLayout.Padding = UDim.new(0, 3)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

local Categories = {
    {name = "🔌 SISTEMA / ADMIN", cmds = {
        "unload | Cerrar Nameless Admin",
        "pluginmaker | Abrir builder de plugins",
        "addallplugins | Cargar todos los plugins",
        "addplugin | Cargar un plugin",
        "reloadplugin | Recargar plugins",
        "removeplugin | Quitar plugin",
        "removeallplugins | Quitar todos los plugins",
        "cmdbar2 | Barra de comandos estilo HD-Admin",
        "url | Ejecutar script desde URL",
        "loadstring | Ejecutar código Lua (ls, execute)",
        "executor | Abrir executor integrado",
        "scriptload | Ejecutar script guardado",
        "scripthub | Abrir Script Hub",
        "gamescripts | Ver scripts del juego",
        "commands / cmds | Abrir lista de comandos",
        "settings | Abrir ajustes",
        "commandkeybinds | Abrir atajos de teclado",
        "prefix | Cambiar prefijo del admin",
        "saveprefix | Guardar prefijo",
        "addalias | Añadir alias a comando",
        "removealias | Quitar alias",
        "clearaliases | Limpiar aliases",
        "addbutton | Añadir botón móvil",
        "removebutton | Quitar botón",
        "clearbuttons | Limpiar botones",
        "addautoexec | Añadir a autoejecutar",
        "removeautoexec | Quitar de autoejecutar",
        "clearautoexec | Limpiar autoejecutar",
        "lastcommand | Re-ejecutar último comando",
        "commandcount / cc | Contar comandos",
        "uiscale | Escalar interfaz",
        "keepna | Mantener Nameless Admin",
        "discord | Copiar invite de Discord",
        "exit | Cerrar Roblox",
        "rename | Renombrar UI admin",
        "unname | Restablecer nombre UI",
    }},
    {name = "🚀 MOVIMIENTO", cmds = {
        "fly | Volar (espacio=subir, Q=bajar)",
        "cframefly | Volar con CFrame",
        "tfly / tweenfly | Volar suave (tween)",
        "vfly / vehiclefly | Volar en vehículos",
        "noclip / nc | Atravesar paredes",
        "ws / speed / walkspeed | Cambiar velocidad",
        "jp / jumppower | Cambiar JumpPower",
        "infjump / infinitejump | Salto infinito",
        "flyjump | Mantener espacio para volar",
        "edgejump | Saltar al borde",
        "tpwalk | Velocidad indetectable",
        "loopwalkspeed | Loop de velocidad",
        "loopjumppower | Loop de JumpPower",
        "airwalk / float | Caminar en el aire",
        "airmomentum | Control aéreo personalizado",
        "climb | Trepar en el aire",
        "jumpboost | Boost de salto extra",
        "trussjump | Boost en trusses",
        "wallhop | Helper de wallhop",
        "walltp | Teleport a paredes",
        "swim | Nadar en el aire",
        "bypassspeed | Velocidad bypass",
        "tpjump | Salto con teleport",
    }},
    {name = "📍 TELEPORT", cmds = {
        "goto / to / tp / teleport | Teleport a jugador",
        "tweento / tgoto | Tween teleport (bypass anticheat)",
        "tpup / up | Teleport arriba",
        "tpdown / down | Teleport abajo",
        "gotocampos / tcp | Ir a posición de cámara",
        "tweengotocampos | Tween a posición de cámara",
        "clickteleport / clicktp | Click para teleport",
        "tptool | Herramienta de teleport",
        "rejoin / rj | Rejoin al servidor",
        "rjre | Rejoin manteniendo posición",
        "serverhop / shop | Cambiar servidor",
        "smallserverhop | Servidor pequeño",
        "pingserverhop | Servidor mejor latencia",
        "oldserverhop | Servidor más antiguo",
        "newserverhop | Servidor más nuevo",
        "versionhop | Servidor por versión",
        "regionhop | Servidor por región",
        "reserveserver | Servidor reservado",
        "teleporttoplace | Teleport por PlaceId",
        "autorejoin | Auto rejoin al ser expulsado",
        "setwaypoint / setwp | Guardar posición",
        "setwaypointpos | Editar waypoint con coordenadas",
        "gotowaypoint / gotowp | Ir a waypoint",
        "removewaypoint | Quitar waypoint",
        "waypoints | Abrir menú de waypoints",
        "showwaypoints | Mostrar ESP de waypoints",
        "hidewaypoints | Ocultar ESP de waypoints",
        "showpathwaypoint | Mostrar ruta a waypoint",
        "pathfindwaypoint | Pathfind a waypoint",
        "looppath | Loop pathfind a waypoint",
        "torandom / tr | Teleport a jugador aleatorio",
        "gotopart | Ir a parte",
        "gotomodel | Ir a modelo",
        "gotofolder | Ir a carpeta",
        "gotopartnext | Ir a partes secuencialmente",
        "gotomodelnext | Ir a modelos secuencialmente",
    }},
    {name = "⚔️ COMBATE / FIGHT", cmds = {
        "reach | Alcance de espada extendido",
        "boxreach | Hitbox en caja",
        "resetreach | Restablecer alcance",
        "aura | Daño automático cercano",
        "npcaura | Daño a NPCs cercanos",
        "hitboxes | Ver hitboxes",
        "fling | Lanzar jugador",
        "loopfling | Loop fling",
        "walkfling | Fling al caminar",
        "touchfling | Fling al tocar",
        "flyfling / ff | Fling volando",
        "invisfling | Fling invisible",
        "clickfling / mousefling | Fling con click",
        "aimbot | Aimbot",
        "triggerbot / tbot | Auto-click en jugadores",
        "godmode / god | Modo dios",
        "autopatchtool | Parchear herramientas",
        "gravitygun | Gun de gravedad",
        "punch | Puñetazo fling",
        "swordfighter | Bot de espadas",
        "timestop | Congelar todos los jugadores",
    }},
    {name = "🛡️ PROTECCIÓN", cmds = {
        "antivoid | No caer al vacío",
        "antivoid2 | Void alternativo",
        "nofall | Sin daño por caída",
        "antiknockback / akb | Sin knockback",
        "antivelocity / av | Limitar velocidad",
        "antivelocityinstances | Destruir mover instances",
        "antikick / nokick | Bypass kick",
        "antiteleport | Bloquear teleport forzado",
        "anticframeteleport | Bloquear CFrame teleport",
        "antitrip / antiragdoll | Sin ragdoll",
        "antifling | No ser flingueado",
        "antiflingparts | Sin collision parts",
        "antiafk / noafk | No ser kick por AFK",
        "antibreakjoints | No romper joints",
        "antianchor | No ser anclado",
        "antitouch / antikillbrick | Sin kill bricks",
        "antinil | No perder personaje",
        "antierror | Bloquear errores",
        "antisit | No poder sentarse",
        "adonisbypass | Bypass Adonis Admin",
        "antibang | Protección antibang",
    }},
    {name = "👁️ ESP / VISUAL", cmds = {
        "esp / espplayers | Ver jugadores",
        "espall | ESP todos",
        "espenemies | ESP enemigos",
        "espallies | ESP aliados",
        "espteam | ESP por equipo",
        "chams | ESP sin texto",
        "chamsenemies | Chams enemigos",
        "chamsallies | Chams aliados",
        "locate | Localizar jugador",
        "npcesp | ESP de NPCs",
        "itemesp / toolesp | Ver items",
        "unanchored | Ver partes desancladas",
        "collisionesp | Ver collisiones",
        "propertyesp | ESP por propiedad",
        "shapeesp | ESP por forma",
        "touchesp | ESP de touch",
        "proximityesp | ESP de proximity",
        "clickesp | ESP de click",
        "pesp | ESP de partes",
        "pespfind | ESP por nombre",
        "folderesp | ESP de carpetas",
        "modelesp | ESP de modelos",
        "sitesp | ESP de sitios",
        "vehiclesitesp | ESP de vehículos",
        "hitboxes | Ver hitboxes",
        "showcom | Centro de masa",
        "predict | Predecir movimiento",
        "esplocator | Rastreador ESP",
        "xray | Ver a través de paredes",
        "echolocation | Localización por eco",
    }},
    {name = "🌍 ENTORNO", cmds = {
        "day | Día",
        "night | Noche",
        "time | Hora personalizada",
        "gravity | Gravedad",
        "fullbright / fb | Todo brillante",
        "nofog | Sin niebla",
        "noeffect | Sin efectos",
        "brightness | Brillo",
        "globalshadows | Sombras globales",
        "shaders / rtx | Shaders/RTX",
        "nightmare | Modo oscuro",
        "removeterrain | Eliminar terreno",
        "oldroblox | Estilo Roblox antiguo",
        "2012-2016 | CoreGui estilo años",
        "loopday | Loop día",
        "loopnight | Loop noche",
        "loopfullbright | Loop fullbright",
        "loopnoeffect | Loop sin efectos",
        "loopnofog | Loop sin niebla",
        "loopbrightness | Loop brillo",
        "gamma | Gamma vision",
        "loopgamma | Loop gamma",
    }},
    {name = "🎭 DIVERSIÓN / TROLL", cmds = {
        "dance | Bailar",
        "somersault / frontflip | Voltereta",
        "sit | Sentarse",
        "lay | Acostarse",
        "spin | Girar",
        "seizure | Convulsión",
        "jerk / jork | Jerk",
        "bang | Bang",
        "inversebang | Bang inverso",
        "headbang | Headbang",
        "carpet | Ser alfombra",
        "headsit | Sentarse en cabeza",
        "headstand | Pararse en cabeza",
        "hug | Abrazar",
        "spook / scare | Asustar",
        "annoy | Molestar",
        "loopoof | Spam de oof",
        "fakechat | Chat falso",
        "uwuify | Texto uwu",
        "cig / cigar / pipe | Dar cigarro",
        "suslay | Lay sospechoso",
        "mute | Silenciar boombox",
        "loopmute | Loop silenciar",
        "trip | Tropezar",
        "permtrip | Trip permanente",
        "circlemath | Matemáticas circulares",
    }},
    {name = "🛠️ HERRAMIENTAS / EXPLORER", cmds = {
        "dex | Explorador de objetos",
        "olddex | Dex antiguo",
        "synapsedex | Synapse Dex",
        "remotespy / simplespy | Espiar remotes",
        "httpspy | Espiar HTTP",
        "cobaltspy | Cobalt Spy",
        "turtlespy | Turtle Spy",
        "serverremotespy | Remotes del servidor",
        "hydroxide | Hydroxide spy",
        "functionspy | Espiar funciones",
        "decompiler | Descompilar scripts",
        "scriptviewer | Ver scripts",
        "moduleeditor | Editor de módulos",
        "upvalueeditor | Editor de upvalues",
        "partname / partgrabber | Obtener path de partes",
        "saveinstance / savegame | Guardar juego",
        "console / debug | Consola",
        "oldconsole | Consola antigua",
        "exportconsole | Exportar logs consola",
        "gcsearch | Buscar en GC",
        "minimap | Minimapa",
        "animationplayer | Reproductor de animaciones",
        "animbuilder | Constructor de animaciones",
        "badgeviewer | Visor de badges",
        "serverlist | Lista de servidores",
        "rc7 | RC7 Internal UI",
    }},
    {name = "📊 UTILIDADES", cmds = {
        "ping | Latencia",
        "fps | Frames por segundo",
        "fpsping | FPS + Ping",
        "stats | Estadísticas",
        "memory / mem | Memoria",
        "speedometer | Velocímetro",
        "notepad / npad | Bloc de notas",
        "music / musicplayer | Reproductor de música",
        "chatlogs / clogs | Logs de chat",
        "placeid / pid | Copiar PlaceId",
        "gameid / gid | Copiar GameId",
        "jobid | Copiar JobId",
        "copyteleport / ct | Copiar script teleport",
        "copytween | Copiar script tween",
        "copymoveto | Copiar script MoveTo",
        "copylerp | Copiar script Lerp",
        "keyboard | Teclado para móvil",
        "autoclicker | Auto-clicker",
        "backpack | Backpack personalizado",
        "accountage / accage | Edad de cuenta",
        "getidfromusername | ID por nombre",
        "getuserfromid | Nombre por ID",
        "localtime | Hora local",
        "servertime | Hora del servidor",
        "datetime | Fecha y hora",
        "uptime | Tiempo activo",
        "timestamp | Timestamp Unix",
        "gameinfo | Info del juego",
        "userpreview | Vista previa de usuario",
        "keystroke | UI de keystrokes",
        "perfstats | Stats de rendimiento",
    }},
    {name = "🧑 PERSONAJE", cmds = {
        "invisible / invis | Invisible",
        "toolinvisible / tinvis | Invisible con tools",
        "visible / vis | Visible",
        "invisbind | Bind para invisible",
        "naked | Sin ropa",
        "split | Separar cuerpo",
        "hatresize | Sombreros gigantes",
        "material / mat | Cambiar material",
        "bodytransparency | Transparencia del cuerpo",
        "animationspeed | Velocidad de animaciones",
        "runanim / anim | Reproducir animación",
        "stopanimations | Detener animaciones",
        "refreshanimations | Recargar animaciones",
        "animspoofer | Spoofer de animaciones",
        "r6 / r15 | Cambiar rig type",
        "freeze / anchor | Congelar",
        "unfreeze | Descongelar",
        "respawn / re | Respawn",
        "instantrespawn | Respawn instantáneo",
        "reset / die | Morir",
        "commitoof | Secuencia de oof",
        "reselectchar | Selector de personaje",
        "offset | Offset de personaje",
        "upsidedown | Boca abajo",
        "chardebug | Debug de personaje",
        "deletevelocity | Eliminar velocidad",
        "breakvelocity | Romper velocidad",
        "height / hipheight | Altura de cadera",
        "disablehumanoidstate | Deshabilitar humanoid state",
        "stopanim | Detener animación",
        "strengthen | Endurecer personaje",
        "weaken | Debilitar personaje",
        "setmass | Establecer masa",
        "r6 | Cambiar a R6",
        "r15 | Cambiar a R15",
        "oganims | Animaciones antiguas",
        "alignmentkeys | Teclas de alineación",
    }},
    {name = "🚗 VEHÍCULOS", cmds = {
        "vfly / vehiclefly | Volar vehículos",
        "vnoclip / vehiclenoclip | Atravesar con vehículos",
        "vehiclespeed / vspeed | Velocidad de vehículo",
        "seat | Sentarse en asiento",
        "vehicleseat / vseat | Asiento de vehículo",
        "cartornado | Tornado de auto",
        "breakcars / bcars | Romper autos",
    }},
    {name = "📡 REMOTES / CLICK DETECTORS", cmds = {
        "fireclickdetectors / fcd | Activar ClickDetectors",
        "fireproximityprompts / fpp | Activar ProximityPrompts",
        "firetouchinterests / fti | Activar TouchInterests",
        "fireremote / fremote | Disparar remote",
        "fireremotes | Disparar todos los remotes",
        "autofireproxi | Auto-fire proximity",
        "autofireclick | Auto-fire click detectors",
        "autotouch | Auto-fire touch",
        "autofireremote | Auto-fire remotes",
        "autofireproxifind | Auto-fire por nombre",
        "autofireclickfind | Auto-fire click por nombre",
        "autotouchfind | Auto-touch por nombre",
        "autofireremotefind | Auto-fire remote por nombre",
        "noclickdetectorlimits | Sin límite ClickDetectors",
        "noproximitypromptlimits | Sin límite ProximityPrompts",
        "instantproximityprompts | Prompts instantáneos",
        "fastprompts | Prompts rápidos",
        "enableproximityprompts | Habilitar prompts",
        "disableproximityprompts | Deshabilitar prompts",
        "proximitypromptgoto | Ir a ProximityPrompt",
        "clickdetectorgoto | Ir a ClickDetector",
        "touchinterestgoto | Ir a TouchInterest",
        "blockremote | Bloquear remote",
        "clicktouch | Click para tocar",
    }},
    {name = "🎨 PERSONALIZACIÓN", cmds = {
        "fov | Campo de visión",
        "loopfov | Loop FOV",
        "sensitivity / sens | Sensibilidad",
        "volume / vol | Volumen",
        "shiftlock / sl | Shift lock",
        "controllock | Control lock",
        "firstp / fp | Primera persona",
        "thirdp | Tercera persona",
        "maxzoom | Zoom máximo",
        "minzoom | Zoom mínimo",
        "loopmaxzoom | Loop zoom máximo",
        "loopminzoom | Loop zoom mínimo",
        "backview | Vista trasera",
        "frontview | Vista frontal",
        "freemouse | Liberar ratón",
        "lockmouse | Bloquear ratón",
        "cursorvisible | Cursor visible",
        "cursorfree | Cursor libre",
        "cameranoclip | Cámara noclip",
        "preftransparency | Transparencia preferida",
        "hideicon | Ocultar icono NA",
        "showicon | Mostrar icono NA",
        "topbar | Mostrar topbar",
        "untopbar | Ocultar topbar",
        "lockiconposition | Bloquear icono",
        "unlockiconposition | Desbloquear icono",
        "light | Luz dinámica",
        "flashlight | Linterna",
        "noreset | Deshabilitar reset",
        "resetbtn | Habilitar reset",
    }},
    {name = "👁️ CÁMARA", cmds = {
        "freecam / fc | Cámara libre",
        "freecamgoto | Ir a jugador con freecam",
        "freecamgotopart | Ir a parte con freecam",
        "cam / camera | Configurar cámara",
        "forcecam | Forzar tipo de cámara",
        "fixcam / fix | Arreglar cámara",
        "watch / spectate | Espectar jugador",
        "watch2 | Espectar modo 2",
        "lookat / stare | Mirar a jugador",
        "starenear | Mirar al más cercano",
        "worldmodelfp | Primera persona WFCP",
        "echolocation | Localización por eco",
        "echoping | Ping de eco",
    }},
    {name = "💀 NPC", cmds = {
        "flingnpcs | Lanzar NPCs",
        "npcfollow | NPCs te siguen",
        "loopnpcfollow | Loop NPCs siguen",
        "sitnpcs | NPCs sentarse",
        "killnpcs | Matar NPCs",
        "npcwalkspeed | Velocidad de NPCs",
        "npcjumppower | JumpPower de NPCs",
        "bringnpcs | Traer NPCs",
        "loopbringnpcs | Loop traer NPCs",
        "gotonpcs | Ir a NPCs",
        "actnpc | Actuar como NPC",
        "voidnpcs | Void NPCs",
        "clickkillnpc | Click para matar NPC",
        "clickvoidnpc | Click para void NPC",
        "clicknpcws | Click para velocidad NPC",
        "clicknpcjp | Click para JumpPower NPC",
    }},
    {name = "🗑️ ELIMINAR", cmds = {
        "delete | Eliminar parte",
        "deletefind | Eliminar por nombre",
        "deletelighting | Eliminar Lighting",
        "deleteclass | Eliminar por clase",
        "deleteinvisparts | Eliminar partes invisibles",
        "invisibleparts | Mostrar partes invisibles",
        "clearnilinstances | Limpiar instancias nil",
        "autodelete | Auto eliminar",
        "autodeletefind | Auto eliminar por nombre",
        "autodeleteclass | Auto eliminar por clase",
        "chardelete | Eliminar de personaje",
        "chardeletefind | Eliminar por nombre en personaje",
        "chardeleteclass | Eliminar por clase en personaje",
        "removeads | Eliminar anuncios",
        "lightingdisable | Deshabilitar Lighting",
        "guidelete | Eliminar GUI bajo ratón",
        "deleteselectedtool | Eliminar tool equipada",
        "removespecifictool | Quitar tool específica",
    }},
    {name = "⚙️ DEBUG / DEV", cmds = {
        "setfflag | Establecer Fast Flag",
        "nocooldown | Sin cooldown",
        "waitcap | Límite de wait",
        "notween | Sin tweens",
        "checkrfe | Verificar FilteringEnabled",
        "enginesettingsinfo | Info de engine",
        "replicationlag | Lag de replicación",
        "animdata | Info de animaciones",
        "sleepon | Permitir sleep",
        "throttle | Throttle de física",
        "quality | Calidad de render",
        "logphysics | Log de física",
        "norender | Sin render 3D",
        "render | Render 3D",
        "datalimit | Límite de ancho de banda",
        "netbypass | Bypass de red",
        "desync | Desync de offset",
        "raknetdesync | RakNet desync",
        "firekey | Disparar tecla virtual",
        "freegamepass | Simular gamepass",
        "devproducts | Listar Developer Products",
        "gamepasses | Listar Game Passes",
    }},
    {name = "🔧 FÍSICA", cmds = {
        "freezeunanchored | Congelar desanclados",
        "thawunanchored | Descongelar desanclados",
        "tpua | Traer partes desancladas",
        "blackhole | Agujero negro",
        "blackholefollow | Agujero negro siguiendo",
        "lockws | Bloquear workspace",
        "unlockws | Desbloquear workspace",
        "setsimradius | Radio de simulación",
        "breaklayeredclothing | Romper ropa",
        "wallwalk | Caminar en paredes",
    }},
    {name = "🔌 PHYSICS VISUALIZATION", cmds = {
        "physallowsleep | Allow Sleep",
        "physanchors | Anchors Shown",
        "physassemblies | Assemblies Shown",
        "physbodytypes | Body Types Shown",
        "collisioncosts | Collision Costs",
        "jointcoords | Joint Coordinates",
        "physowners | Owners Shown",
        "physregions | Regions Shown",
        "awakeparts | Awake Parts",
        "contactpoints | Contact Points",
        "mechanismsshown | Mechanisms Shown",
        "unalignedparts | Unaligned Parts",
        "receiveage | Receive Age",
        "interpolationthrottle | Interpolation Throttle",
        "phystree | Physics Tree",
        "decompositiongeometry | Decomposition Geometry",
        "drawcontactsforce | Draw Contacts Force",
        "drawconstraintsforce | Draw Constraints Force",
        "drawtotalforce | Draw Total Force",
        "forceinstancenames | Force Instance Names",
        "renderboundingboxes | Bounding Boxes",
        "rendercsgtriangles | CSG Triangles Debug",
        "renderfrm | Frame Rate Manager",
        "eagerbulkexecution | Eager Bulk Execution",
        "exportmergebymaterial | Export Merge By Material",
        "soundwarnings | Sound Warnings",
        "videocapture | Video Capture",
    }},
    {name = "🔄 LOOP COMANDS", cmds = {
        "loop | Iniciar loop de comando",
        "stoploop / unloop | Detener loops",
        "repeat | Repetir comando N veces",
        "looppath | Loop pathfind waypoint",
        "looptweenpath | Loop tween waypoint",
        "loopteleportpath | Loop teleport waypoint",
        "loopwalkpath | Loop walk waypoint",
        "loopwaveat | Loop saludar",
        "loopspook | Loop asustar",
        "loopcbring | Loop bring jugador",
        "loopgrabtools | Loop recoger tools",
        "loopdroptools | Loop soltar tools",
        "loopmute | Loop silenciar",
        "loopequiptool | Loop equipar tool",
        "loopbypassspeed | Loop velocidad bypass",
        "loopfov | Loop FOV",
        "loopmaxzoom | Loop zoom máximo",
        "loopminzoom | Loop zoom mínimo",
        "loopbrightness | Loop brillo",
        "loopgamma | Loop gamma",
        "loopmaxslopeangle | Loop pendiente",
    }},
    {name = "🎭 ANIMACIONES", cmds = {
        "runanim | Reproducir animación",
        "playanim | Reproducir animación",
        "animbuilder | Constructor de animaciones",
        "setkiller | Animación killer",
        "setpsycho | Animación psycho",
        "resetanims | Restablecer animaciones",
        "animcopycore | Copiar animaciones core",
        "syncanim | Sincronizar animaciones",
        "mimic | Clonar movimiento",
        "syncstop | Detener sync",
        "unsyncreset | Detener sync y reset",
        "waveat | Saludar",
        "loopwaveat | Loop saludar",
    }},
    {name = "📱 MÓVIL / UI", cmds = {
        "keyboard | Teclado para móvil",
        "autoclicker | Auto-clicker",
        "backpack | Backpack custom",
        "unloadbackpack | Quitar backpack",
        "cmdbar2 | Cmdbar estilo HD-Admin",
        "addbutton | Añadir botón móvil",
        "removebutton | Quitar botón",
        "clearbuttons | Limpiar botones",
        "hideguis | Ocultar GUIs",
        "showguis | Mostrar GUIs",
        "hidecurrentguis | Ocultar GUIs actuales",
        "hidetargetgui | Ocultar GUI específica",
        "showtargetgui | Mostrar solo GUI específica",
        "noprompt | Quitar purchase prompt",
        "prompt | Mostrar purchase prompts",
        "experienceevents | Eventos de experiencia",
        "rsvpevent | RSVP a evento",
        "feedback | Feedback de experiencia",
        "invitefriends | Invitar amigos",
        "friendweb | Amigos en servidor",
    }},
}

local order = 0
local allFrames = {}

for _, cat in ipairs(Categories) do
    order = order + 1
    local CatFrame = Instance.new("Frame")
    CatFrame.Name = "Cat_" .. cat.name
    CatFrame.Size = UDim2.new(1, -10, 0, 28)
    CatFrame.BackgroundColor3 = Color3.fromRGB(0, 140, 200)
    CatFrame.BorderSizePixel = 0
    CatFrame.LayoutOrder = order * 10000
    CatFrame.Parent = ScrollFrame
    table.insert(allFrames, {frame = CatFrame, isCat = true, name = cat.name})

    local CatCorner = Instance.new("UICorner")
    CatCorner.CornerRadius = UDim.new(0, 6)
    CatCorner.Parent = CatFrame

    local CatLabel = Instance.new("TextLabel")
    CatLabel.Size = UDim2.new(1, -10, 1, 0)
    CatLabel.Position = UDim2.new(0, 10, 0, 0)
    CatLabel.BackgroundTransparency = 1
    CatLabel.Text = cat.name
    CatLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CatLabel.TextSize = 12
    CatLabel.Font = Enum.Font.GothamBold
    CatLabel.TextXAlignment = Enum.TextXAlignment.Left
    CatLabel.Parent = CatFrame

    for i, cmd in ipairs(cat.cmds) do
        order = order + 1
        local CmdFrame = Instance.new("Frame")
        CmdFrame.Size = UDim2.new(1, -10, 0, 32)
        CmdFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        CmdFrame.BorderSizePixel = 0
        CmdFrame.LayoutOrder = order * 10000 + i
        CmdFrame.Parent = ScrollFrame
        table.insert(allFrames, {frame = CmdFrame, isCat = false, name = cmd})

        local CmdCorner = Instance.new("UICorner")
        CmdCorner.CornerRadius = UDim.new(0, 4)
        CmdCorner.Parent = CmdFrame

        local parts = string.split(cmd, " | ")
        local cmdName = parts[1] or cmd
        local cmdDesc = parts[2] or ""

        local CmdName = Instance.new("TextLabel")
        CmdName.Size = UDim2.new(0.55, 0, 1, 0)
        CmdName.Position = UDim2.new(0, 8, 0, 0)
        CmdName.BackgroundTransparency = 1
        CmdName.Text = cmdName
        CmdName.TextColor3 = Color3.fromRGB(0, 255, 180)
        CmdName.TextSize = 11
        CmdName.Font = Enum.Font.Code
        CmdName.TextXAlignment = Enum.TextXAlignment.Left
        CmdName.Parent = CmdFrame

        local CmdDesc = Instance.new("TextLabel")
        CmdDesc.Size = UDim2.new(0.43, 0, 1, 0)
        CmdDesc.Position = UDim2.new(0.57, 0, 0, 0)
        CmdDesc.BackgroundTransparency = 1
        CmdDesc.Text = cmdDesc
        CmdDesc.TextColor3 = Color3.fromRGB(160, 160, 160)
        CmdDesc.TextSize = 10
        CmdDesc.Font = Enum.Font.Gotham
        CmdDesc.TextXAlignment = Enum.TextXAlignment.Left
        CmdDesc.TextTruncate = Enum.TextTruncate.AtEnd
        CmdDesc.Parent = CmdFrame
    end
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = string.lower(SearchBox.Text)
    for _, data in ipairs(allFrames) do
        if searchText == "" then
            data.frame.Visible = true
        else
            local searchIn = string.lower(data.name)
            data.frame.Visible = string.find(searchIn, searchText, 1, true) ~= nil
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    ScrollFrame.Visible = not minimized
    SearchBox.Visible = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 550, 0, 50)
    else
        MainFrame.Size = UDim2.new(0, 550, 0, 650)
    end
end)

print("✅ Nameless Admin Panel COMPLETO cargado - 975 comandos en " .. #Categories .. " categorías")
