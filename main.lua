-- Quick Construction Mod for Trailmakers
-- name: Quick Construction
-- author: ticibi
-- version: 2.1 (2025 update)
-- description: Place, save, and load objects using a cursor-based building system

local MOD_VERSION = "2.1"
local debug = false
local savedBuildPath = "MyBuilds"
local playerDataTable = {}

-- Constants
local CURSOR_MODEL = 'PFB_BlockHunt'
local CURSOR_OFFSET = 0.08
local CURSOR_SIZE = tm.vector3.Create(0.2, 0.0075, 0.2)
local DEFAULT_CURSOR_SCALE = tm.vector3.Create(1.5, 2, 1.5)

-- Cursor styling
local cursorBoldness = {
    none = tm.vector3.Create(0.2, 0.0075, 0.2),
    bold = tm.vector3.Create(0.3, 0.0075, 0.3),
    selected = tm.vector3.Create(0.4, 0.0075, 0.4),
}

-- Utility configurations
local utils = {
    signs = {{x=-1, z=1}, {x=1, z=1}, {x=-1, z=-1}, {x=1, z=-1}},
    directions = {
        left = {vector=tm.vector3.Left(), scaleAxis='x'},
        right = {vector=tm.vector3.Right(), scaleAxis='x'},
        forward = {vector=tm.vector3.Forward(), scaleAxis='z'},
        back = {vector=tm.vector3.Back(), scaleAxis='z'},
        up = {vector=tm.vector3.Up(), scaleAxis='y'},
        down = {vector=tm.vector3.Down(), scaleAxis='y'},
    }
}

-- Material Management
local Materials = {}
local MaterialCategories = {
    'construction', 'crates', 'barrels', 'tires', 'explosives', 'gold', 
    'beacons', 'balls', 'ocean', 'trees', 'plants', 'salvage', 
    'savannah', 'cliffs', 'rocks', 'large props', 'misc'
}

-- Material Functions
local function InitializeMaterial(name, model, category, scale, isRigid, isStatic, isVisible)
    assert(name and model, "Material must have name and model")
    local material = {
        name = name,
        model = model,
        category = category or 'misc',
        scale = scale or {x=1, y=1, z=1},
        isRigid = isRigid or false,
        isStatic = isStatic or false,
        isVisible = isVisible ~= false
    }
    table.insert(Materials, material)
    return material
end

local function GetMaterialByName(name)
    for _, material in ipairs(Materials) do
        if material.name == name then return material end
    end
    return nil
end

local function GetMaterialsCategory(category)
    local group = {}
    for _, material in ipairs(Materials) do
        if material.category == category then
            table.insert(group, material)
        end
    end
    return group
end

-- Player Management
local function AddPlayerData(player)
    assert(player and player.playerId, "Invalid player object")
    playerDataTable[player.playerId] = {
        isBuilding = false,
        buildName = nil,
        help = false,
        savedBuilds = {},
        Builder = {
            material = GetMaterialByName("scaffold"),
            height = 1,
            objects = {},
            history = {}
        },
        Cursor = {
            isVisible = true,
            origin = nil,
            pos = nil,
            scale = DEFAULT_CURSOR_SCALE,
            points = {},
            lastMove = {}
        }
    }
end

local function AddKeybinds(player)
    local binds = {
        OnMoveLeft = "left",
        OnMoveRight = "right",
        OnMoveForward = "up",
        OnMoveBack = "down",
        OnMoveUp = "page up",
        OnMoveDown = "page down",
        OnPlaceObject = "\\",
        rotateLeft = "home",
        rotateRight = "end",
        toggleDebug = "`",
        selectObject = "q",
        OnRotateOrigin = "e",
        OnSetOrigin = "o",
        OnResetCursor = "y"
    }
    
    for func, key in pairs(binds) do
        tm.input.RegisterFunctionToKeyDownCallback(player.playerId, func, key)
    end
end

-- UI Functions
local function ClearUI(playerId)
    tm.playerUI.ClearUI(playerId)
end

local function AddLabel(playerId, key, text)
    tm.playerUI.AddUILabel(playerId, key, text)
end

local function AddButton(playerId, key, text, func)
    tm.playerUI.AddUIButton(playerId, key, text, func)
end

local function HomePage(playerId)
    local playerData = playerDataTable[playerId]
    ClearUI(playerId)
    
    if not playerData.isBuilding then
        AddButton(playerId, "start", "Start Building", StartBuilding)
    else
        AddButton(playerId, "materials", "Select Material", MaterialsPage)
        AddLabel(playerId, "divider1", "────────────")
        AddButton(playerId, "delete_last", "Delete Last", OnDeleteLastObject)
        AddButton(playerId, "delete_all", "Delete All", OnDeleteAllObjects)
        AddLabel(playerId, "divider2", "────────────")
        AddButton(playerId, "save", "Save Build", Save)
        AddButton(playerId, "cancel", "Cancel Build", OnCancelBuild)
        AddLabel(playerId, "divider3", "────────────")
        AddButton(playerId, "builds", "My Builds", ShowBuilds)
    end
    
    AddButton(playerId, "help", "How to Use", ToggleHowToPage)
    
    if playerData.help then
        local helpText = {
            "Arrow Keys: Move Cursor",
            "Pg Up/Down: Height",
            "\\: Place Object",
            "E: Rotate Origin",
            "O: Set Origin",
            "Y: Reset Cursor"
        }
        for i, text in ipairs(helpText) do
            AddLabel(playerId, "help_"..i, text)
        end
    end
end

-- Cursor Management
local function InitializeCursor(cursor, pos)
    cursor.pos = pos
    cursor.origin = pos
    cursor.points = {}
    
    for i, sign in ipairs(utils.signs) do
        local spawnPos = tm.vector3.Create(
            pos.x + (cursor.scale.x * sign.x / 2) + (CURSOR_OFFSET * sign.x),
            pos.y + cursor.scale.y - (cursor.scale.y / 2),
            pos.z + (cursor.scale.z * sign.z / 2) + (CURSOR_OFFSET * sign.z)
        )
        local object = tm.physics.SpawnObject(spawnPos, CURSOR_MODEL)
        object.GetTransform().SetScale(CURSOR_SIZE)
        cursor.points[i] = object
    end
end

local function UpdateCursorPosition(cursor, pos)
    cursor.pos = pos
    for i, point in ipairs(cursor.points) do
        local sign = utils.signs[i]
        local pointPos = tm.vector3.Create(
            pos.x + (cursor.scale.x * sign.x / 2) + (CURSOR_OFFSET * sign.x),
            pos.y + cursor.scale.y - (cursor.scale.y / 2),
            pos.z + (cursor.scale.z * sign.z / 2) + (CURSOR_OFFSET * sign.z)
        )
        point.GetTransform().SetPosition(pointPos)
    end
end

local function MoveCursor(builder, cursor, direction)
    local scaleAxis = direction.scaleAxis
    local movement = tm.vector3.op_Multiply(
        direction.vector, 
        builder.material.scale[scaleAxis]
    )
    local newPos = tm.vector3.op_Addition(cursor.pos, movement)
    UpdateCursorPosition(cursor, newPos)
    cursor.lastMove = {direction=direction.vector, scale=builder.material.scale}
end

-- Object Management
local function PlaceObject(builder, cursor)
    if IsPositionOccupied(builder, cursor.pos) then return false end
    
    local object = tm.physics.SpawnObject(cursor.pos, builder.material.model)
    local objectData = {object=object, material=builder.material.model}
    
    table.insert(builder.objects, objectData)
    table.insert(builder.history, {action="place", object=objectData})
    return true
end

local function IsPositionOccupied(builder, pos)
    for _, obj in ipairs(builder.objects) do
        if obj.object.Exists() and 
           tm.vector3.op_Equality(obj.object.GetTransform().GetPosition(), pos) then
            return true
        end
    end
    return false
end

-- Event Handlers
function onPlayerJoined(player)
    AddPlayerData(player)
    AddKeybinds(player)
    HomePage(player.playerId)
end

tm.players.onPlayerJoined.add(onPlayerJoined)

function OnMoveLeft(playerId)
    if not playerDataTable[playerId].isBuilding then return end
    MoveCursor(
        playerDataTable[playerId].Builder,
        playerDataTable[playerId].Cursor,
        utils.directions.left
    )
end

function OnMoveRight(playerId)
    if not playerDataTable[playerId].isBuilding then return end
    MoveCursor(
        playerDataTable[playerId].Builder,
        playerDataTable[playerId].Cursor,
        utils.directions.right
    )
end

function OnMoveForward(playerId)
    if not playerDataTable[playerId].isBuilding then return end
    MoveCursor(
        playerDataTable[playerId].Builder,
        playerDataTable[playerId].Cursor,
        utils.directions.forward
    )
end

function OnMoveBack(playerId)
    if not playerDataTable[playerId].isBuilding then return end
    MoveCursor(
        playerDataTable[playerId].Builder,
        playerDataTable[playerId].Cursor,
        utils.directions.back
    )
end

function OnMoveUp(playerId)
    if not playerDataTable[playerId].isBuilding then return end
    MoveCursor(
        playerDataTable[playerId].Builder,
        playerDataTable[playerId].Cursor,
        utils.directions.up
    )
end

function OnMoveDown(playerId)
    if not playerDataTable[playerId].isBuilding then return end
    MoveCursor(
        playerDataTable[playerId].Builder,
        playerDataTable[playerId].Cursor,
        utils.directions.down
    )
end

function OnPlaceObject(playerId)
    if not playerDataTable[playerId].isBuilding then return end
    PlaceObject(
        playerDataTable[playerId].Builder,
        playerDataTable[playerId].Cursor
    )
end

function StartBuilding(callback)
    local playerData = playerDataTable[callback.playerId]
    if playerData.isBuilding then return end
    
    if not playerData.Cursor.pos then
        local playerPos = tm.players.GetPlayerTransform(callback.playerId).GetPosition()
        InitializeCursor(playerData.Cursor, playerPos)
    end
    
    playerData.isBuilding = true
    HomePage(callback.playerId)
end

function CreateMaterials()
    InitializeMaterial('scaffold', 'PFB_Scaffolding_Section', 'construction', {x=1.5, y=3, z=1.5})
    InitializeMaterial('iron crate', 'PFB_IronCrate', 'crates', {x=2, y=2, z=2}, false, true)
    InitializeMaterial('wood crate', 'PFB_WoodCrate', 'crates', {x=2, y=2, z=2})
    InitializeMaterial('barrel', 'PFB_Barrel', 'barrels', {x=2, y=3, z=2})
    InitializeMaterial('magnetic cube', 'PFB_MagneticCube', 'construction', {x=5, y=1, z=10})
    InitializeMaterial('explosive crate', 'PFB_ExplosiveCrate', 'crates', {x=2, y=2, z=2})
    InitializeMaterial('explosive barrel', 'PFB_ExplosiveBarrel', 'barrels', {x=2, y=3, z=2})
    InitializeMaterial('concrete wall', 'PFB_Dispensable-ConcreteWall', 'construction', {x=2, y=2, z=3.5}, true, true)
    InitializeMaterial('blue shipping container', 'PFB_Container_Blue', 'crates', {x=4, y=1.8, z=9}, false, true)
    InitializeMaterial('dynamic blue shipping container', 'PFB_Container_Blue_Dynamic', 'crates', {x=4, y=1.8, z=9}, false, true)
    InitializeMaterial('orange shipping container', 'PFB_Container_Orange', 'crates', {x=4, y=1.8, z=9}, false, true)
    InitializeMaterial('dynamic orange shipping container', 'PFB_Container_Orange_Dynamic', 'crates', {x=4, y=1.8, z=9}, false, true)
    InitializeMaterial('red shipping container', 'PFB_Container_Red', 'crates', {x=4, y=1.8, z=9}, false, true)
    InitializeMaterial('dynamic red shipping container', 'PFB_Container_Red_Dynamic', 'crates', {x=4, y=1.8, z=9}, false, true)
    InitializeMaterial('beach ball', 'PFB_Dispensable-BeachBall', 'balls', {x=3, y=3, z=3}, false, true)
    InitializeMaterial('boulder', 'PFB_Dispensable-Boulder', 'balls', {x=2.5, y=2.5, z=2.5}, false, true)
    InitializeMaterial('snowball', 'PFB_DispensableSnowball', 'balls', {x=2, y=2, z=2}, false, true)
    InitializeMaterial('cone', 'PFB_Dispensable-Cone', 'construction', {x=0.3, y=0.5, z=0.3}, false, true)
    InitializeMaterial('power core crate', 'PFB_PowerCoreCrate', 'crates', {x=2, y=2, z=2})
    InitializeMaterial('plant mine', 'PFB_Mine', 'explosives', {x=1.5, y=1, z=1.5})
    InitializeMaterial('mine', 'PFB_Dispensable-Mine', 'explosives', {x=0.5, y=0.5, z=0.5})
    InitializeMaterial('tire stack', 'PFB_PropWheelStack', 'tires', {x=1.2, y=7, z=1.2})
    InitializeMaterial('blue tire', 'PFB_RacePropTyre-Blue', 'tires', {x=1.2, y=1, z=1.2})
    InitializeMaterial('thin blue tire', 'PFB_RacePropTyre-Blue_LOWRES', 'tires', {x=1.2, y=0.5, z=1.2})
    InitializeMaterial('yellow tire', 'PFB_RacePropTyre-Yellow', 'tires', {x=1.2, y=1, z=1.2})
    InitializeMaterial('big gold nugget', 'PFB_GoldPickup', 'gold', {x=1.5, y=1, z=1.8})
    InitializeMaterial('small gold nugget', 'PFB_GoldNugget_Small', 'gold', {x=0.5, y=0.5, z=0.5})
    InitializeMaterial('beacon', 'PFB_TreasureBeacon', 'beacons', {x=0.5, y=0.5, z=0.5})
    InitializeMaterial('green beacon beam', 'PFB_Beacon', 'beacons', {x=6, y=50, z=6})

    InitializeMaterial('green bubble weed', 'PFB_WavyBottomPlantGreenBubbleWeed', 'ocean', {x=1.5, y=4, z=1.5})
    InitializeMaterial('green cactus', 'PFB_WavyBottomPlantGreenCactus', 'ocean', {x=1.5, y=4, z=1.5})
    InitializeMaterial('green ladder', 'PFB_WavyBottomPlantGreenLadder', 'ocean', {x=1.5, y=5, z=1.5})
    InitializeMaterial('green leafy plant', 'PFB_WavyBottomPlantGreenLeafy', 'ocean', {x=1.5, y=5, z=1.5})
    InitializeMaterial('red grass', 'PFB_WavyBottomPlantGreenRedGrass', 'ocean', {x=1.5, y=5, z=1.5})
    InitializeMaterial('purple square', 'PFB_WavyBottomPlantPurpleSquareEnd', 'ocean', {x=2, y=5, z=2})
    InitializeMaterial('red bubble', 'PFB_WavyBottomPlantRedBubbleEnds', 'ocean', {x=2, y=5, z=2})
    InitializeMaterial('red shredded', 'PFB_WavyBottomPlantRedShredded', 'ocean', {x=2, y=5, z=2})
    InitializeMaterial('coral reef 1', 'PFB_CoralReef1', 'ocean', {x=35, y=4, z=30})
    InitializeMaterial('coral reef 2', 'PFB_CoralReef2', 'ocean', {x=35, y=4, z=30})
    InitializeMaterial('coral reef 3', 'PFB_CoralReef3', 'ocean', {x=25, y=15, z=25})
    InitializeMaterial('shipwreck', 'PFB_ShipWreck', 'ocean', {x=85, y=25 , z=30})

    InitializeMaterial('desert bush fir', 'PFB_Desert_Bush_Fir', 'trees', {x=3, y=3, z=3})
    InitializeMaterial('lush fat pine', 'PFB_Tall__Lush_FatPine_1', 'trees', {x=1, y=1, z=1})
    InitializeMaterial('slender pine 1', 'PFB_Tall_SlenderPine_1', 'trees', {x=1, y=1, z=1})
    InitializeMaterial('slender pine 2', 'PFB_Tall__Pruny_SlenderPine_2', 'trees', {x=1.5, y=1, z=1.5})
    InitializeMaterial('palm 1', 'PFB_Palm1', 'trees', {x=1, y=1, z=1})
    InitializeMaterial('palm 2', 'PFB_Palm2', 'trees', {x=1, y=1, z=1})
    InitializeMaterial('bulky pine fbx', 'PFB_BulkyPineTree_FBX', 'trees', {x=4, y=1, z=4})
    InitializeMaterial('slender pine fbx', 'PFB_SlenderPineTree-Final_FBX', 'trees', {x=1, y=1, z=1})
    InitializeMaterial('charred stump', 'PFB_CharredStump', 'trees', {x=1.5, y=1, z=1.5})
    InitializeMaterial('charred tree 1', 'PFB_CharredTree', 'trees', {x=1.5, y=1, z=1.5})
    InitializeMaterial('charred tree 2', 'PFB_CharredTree2', 'trees', {x=1.5, y=1, z=1.5})
    InitializeMaterial('charred bush', 'PFB_CharredBush', 'trees', {x=1, y=1, z=1})

    InitializeMaterial('bush', 'PFB_Bushy', 'plants', {x=6, y=1, z=6})
    InitializeMaterial('charred bush', 'PFB_CharredBush', 'plants', {x=1, y=1, z=1})
    InitializeMaterial('big palm fern', 'PFB_PalmFern_Big', 'plants', {x=4.5, y=1, z=4.5})
    InitializeMaterial('medium palm fern', 'PFB_PalmFern_Medium', 'plants', {x=4, y=1, z=4})
    InitializeMaterial('blueberry bush 1', 'PFB_BlueBerryShrub_01', 'plants', {x=7, y=1, z=7})
    InitializeMaterial('blueberry bush 2', 'PFB_BlueBerryShrub_02_Noco', 'plants', {x=5, y=1, z=5})
    InitializeMaterial('pine bush', 'PFB_Pine_Bush', 'plants', {x=3, y=1, z=3})
    InitializeMaterial('pine bush test', 'PFB_Pine_Bush_TEST', 'plants', {x=7.5, y=1, z=8.5})
    InitializeMaterial('mine plant', 'PFB_Mine', 'plants', {x=2, y=1, z=2})
    InitializeMaterial('cactus ball', 'PFB_Cactus_Ball', 'plants', {x=4, y=1, z=4})
    InitializeMaterial('cactus bush', 'PFB_Cactus_Bush', 'plants', {x=4.5, y=1, z=4.5})
    InitializeMaterial('cactus bush populate', 'PFB_Cactus_Bush_Populate', 'plants', {x=4.5, y=1, z=4.5})
    InitializeMaterial('mini cactus', 'PFB_Cactus_Mini', 'plants', {x=0.5, y=1, z=0.5})
    InitializeMaterial('small cactus', 'PFB_Cactus_Small', 'plants', {x=1, y=1, z=1})
    InitializeMaterial('cactus star', 'PFB_Cactus_Star_Plant', 'plants', {x=2, y=1, z=2})
    InitializeMaterial('cactus tree', 'PFB_Cactus_Tree', 'plants', {x=1, y=1, z=1})
    InitializeMaterial('cactus mushroom tree', 'PFB_Cactus_Mushroom_Tree', 'plants', {x=18, y=1, z=18})

    InitializeMaterial('salvage', 'PFB_SalvageItem', 'salvage', {x=1, y=1, z=1})
    InitializeMaterial('small salvage', 'PFB_SalvageItem_Small', 'salvage', {x=1, y=1, z=1})
    InitializeMaterial('salvage ball', 'PFB_SalvageItem_Ball', 'salvage', {x=1.5, y=1, z=1.5})
    InitializeMaterial('medium salvage', 'PFB_SalvageItem_M Variant', 'salvage', {x=2, y=1, z=2})
    InitializeMaterial('medium salvage ball', 'PFB_SalvageItem_Ball_M', 'salvage', {x=3.25, y=1, z=3.25})
    InitializeMaterial('large salvage ball', 'PFB_SalvageItem_Ball_L', 'salvage', {x=6, y=1, z=6})
    InitializeMaterial('extra large salvage', 'PFB_SalvageItem_XL Variant', 'salvage', {x=7, y=1, z=7})
    InitializeMaterial('compound 1', 'PFB_SalvageItem_Compound_Variant_1', 'salvage', {x=6, y=1, z=1})
    InitializeMaterial('compound 2', 'PFB_SalvageItem_Compound_Variant_2', 'salvage', {x=6, y=1, z=1})
    InitializeMaterial('compound 3', 'PFB_SalvageItem_Compound_3', 'salvage', {x=1, y=1, z=2})
    InitializeMaterial('explosive', 'PFB_SalvageItem_Explosive', 'salvage', {x=1, y=1, z=1})
    InitializeMaterial('medium explosive', 'PFB_SalvageItem_Explosive_M', 'salvage', {x=1.5, y=1, z=1.5})
    InitializeMaterial('large salvage', 'PFB_SalvageItem_L Variant', 'salvage', {x=6, y=1, z=6})
    InitializeMaterial('timed salvage', 'PFB_SalvageItem_Timed', 'salvage', {x=1, y=1, z=1})
    InitializeMaterial('power salvage', 'PFB_SalvageItemBuildPower', 'salvage', {x=1, y=1, z=1})

    InitializeMaterial('small bush', 'PFB_INS_Savannah_Bush_Small', 'savannah', {x=2.5, y=1, z=2.5})
    InitializeMaterial('short tree', 'PFB_INS_Savannah_Tree_Short', 'savannah', {x=12, y=1, z=12})
    InitializeMaterial('brown short tree', 'PFB_INS_Savannah_Tree_Short_brown', 'savannah', {x=12, y=1, z=12})
    InitializeMaterial('purple short tree', 'PFB_INS_Savannah_Tree_Short_Purple', 'savannah', {x=1, y=1, z=1})
    InitializeMaterial('yellow short tree', 'PFB_INS_Savannah_Tree_Short_Yellow', 'savannah', {x=1, y=1, z=1})
    InitializeMaterial('tall tree', 'PFB_INS_Savannah_Tree_Tall', 'savannah', {x=12, y=1, z=12})
    InitializeMaterial('tall brown tree', 'PFB_INS_Savannah_Tree_Tall_Brown', 'savannah', {x=12, y=1, z=12})
    InitializeMaterial('tall purple tree', 'PFB_INS_Savannah_Tree_Tall_Purple', 'savannah', {x=12, y=1, z=12})
    InitializeMaterial('tall yellow tree', 'PFB_INS_Savannah_Tree_Tall_Yellow', 'savannah', {x=12, y=1, z=12})
    InitializeMaterial('tree', 'PFB_Savannah_Tree', 'savannah', {x=14, y=1, z=14})

    InitializeMaterial('bottom desert', 'PFB_Cliff_Bottom_Desert', 'cliffs', {x=19, y=7, z=18})
    InitializeMaterial('bottom desert grass', 'PFB_Cliff_Bottom_Desert_Grass', 'cliffs', {x=19, y=1, z=18})
    InitializeMaterial('bottom mud', 'PFB_Cliff_Bottom_Mud', 'cliffs', {x=32, y=1, z=29})
    InitializeMaterial('bottom mud grass', 'PFB_Cliff_Bottom_Mud_Grass', 'cliffs', {x=32, y=1, z=29})
    InitializeMaterial('med desert', 'PFB_Cliff_Med_Desert', 'cliffs', {x=32, y=1, z=32})
    InitializeMaterial('med desert grass', 'PFB_Cliff_Med_Desert_Grass', 'cliffs', {x=32, y=1, z=32})
    InitializeMaterial('med mud', 'PFB_Cliff_Med_Mud', 'cliffs', {x=32, y=1, z=32})
    InitializeMaterial('med mud grass', 'PFB_Cliff_Med_Mud_Grass', 'cliffs', {x=32, y=1, z=32})
    InitializeMaterial('top desert', 'PFB_Cliff_Top_Desert', 'cliffs', {x=32, y=1, z=32})
    InitializeMaterial('top desert grass', 'PFB_Cliff_Top_Desert_Grass', 'cliffs', {x=32, y=1, z=32})
    InitializeMaterial('top desert trees', 'PFB_Cliff_Top_Desert_Trees', 'cliffs', {x=32, y=1, z=32})
    InitializeMaterial('top mud', 'PFB_Cliff_Top_Mud', 'cliffs', {x=40, y=1, z=40})
    InitializeMaterial('top mud grass', 'PFB_Cliff_Top_Mud_Grass', 'cliffs', {x=40, y=1, z=40})
    InitializeMaterial('top mud trees', 'PFB_Cliff_Top_Mud_Trees', 'cliffs', {x=40, y=1, z=40})

    InitializeMaterial('spiky canyon', 'PFB_SpikyCanyon_1', 'rocks', {x=16, y=1, z=10})
    InitializeMaterial('plate canyon', 'PFB_PlateCanyon_01', 'rocks', {x=5, y=1, z=5})
    InitializeMaterial('bush', 'PFB_Rock_Detail_Bush', 'rocks', {x=1, y=1, z=1})
    InitializeMaterial('med desert 1', 'PFB_Rock_Detail_Med_Desert_00', 'rocks', {x=1, y=1, z=1})
    InitializeMaterial('med desert grass 1', 'PFB_Rock_Detail_Med_Desert_00_Grass', 'rocks', {x=1, y=1, z=1})
    InitializeMaterial('med desert 2', 'PFB_Rock_Detail_Med_Desert_01', 'rocks', {x=8, y=1, z=8})
    InitializeMaterial('med desert grass 2', 'PFB_Rock_Detail_Med_Desert_01_Grass', 'rocks', {x=8, y=1, z=8})
    InitializeMaterial('med mud 1', 'PFB_Rock_Detail_Med_Mud_00', 'rocks', {x=1, y=1, z=1})
    InitializeMaterial('med mud grass 1', 'PFB_Rock_Detail_Med_Mud_00_Grass', 'rocks', {x=1, y=1, z=1})
    InitializeMaterial('med mud 2', 'PFB_Rock_Detail_Med_Mud_01', 'rocks', {x=10.5, y=1, z=9.5})
    InitializeMaterial('med mud grass 2', 'PFB_Rock_Detail_Med_Mud_01_Grass', 'rocks', {x=10.5, y=1, z=9.5})
    InitializeMaterial('med mud grass test', 'PFB_Rock_Detail_Med_Mud_01Test', 'rocks', {x=10.5, y=1, z=9.5})
    InitializeMaterial('top desert', 'PFB_Rock_Detail_Top_Desert', 'rocks', {x=1, y=1, z=1})
    InitializeMaterial('top mud 1', 'PFB_Rock_Detail_Top_Mud', 'rocks', {x=1, y=1, z=1})
    InitializeMaterial('top mud 2', 'PFB_Rock_Detail_Top_Mud1', 'rocks', {x=1, y=1, z=1})
    InitializeMaterial('desert arc', 'PFB_Rock_Desert_Arc', 'rocks', {x=1, y=1, z=1})
    InitializeMaterial('med desert', 'PFB_Rock_Desert_Med', 'rocks', {x=1, y=1, z=1})
    InitializeMaterial('small desert', 'PFB_Rock_Desert_VerySmall', 'rocks', {x=40, y=1, z=36})
    InitializeMaterial('large mud', 'PFB_Rock_Mud_Large', 'rocks', {x=12, y=1, z=12})

    InitializeMaterial('puzzle ball', 'PFB_MovePuzzleBall', 'balls', {x=2, y=2, z=2})
    InitializeMaterial('twin flag', 'PFB_FlagTwin', 'misc', {x=1, y=1, z=1})
    InitializeMaterial('kungfu flag', 'PFB_KungfuFlaglol', 'misc', {x=1, y=1, z=1})

    InitializeMaterial('basketball hoop', 'PFB_BasketBallHoop', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('square cannon', 'PFB_SquareCannon', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('catapult', 'PFB_Catapult', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('straight catapult', 'PFB_CatapultStraight', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('grinder 1', 'Grinder', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('grinder 2', 'PFB_Grinderv2', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('hammer', 'PFB_Hammer', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('height jump', 'PFB_Heightjump', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('pusher', 'PFB_Pusher', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('pusher x5', 'PFB_Pushersx5', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('pusher x5 below', 'PFB_Pushersx5_Below', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('spinner', 'PFB_Spinner', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('tube', 'PFB_Tube3-NoHoles2', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('arc collected', 'PFB_ArkCollected', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('windmill', 'PFB_Windmill3', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('big windmill', 'PFB_BigWindMill', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('moveable ramp', 'Moveable_Ramp', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('ramp wedge', 'RampWedge', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('racing checkpoint', 'PFB_RacingCheckPoint', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('racing half circle', 'PFB_RacingCheckPoint_Halfcircle', 'large props', {x=1, y=1, z=1})
    InitializeMaterial('ring of fire', 'PFB_RingofFire', 'large props', {x=1, y=1, z=1})
end

CreateMaterials()
