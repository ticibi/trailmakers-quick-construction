--- Quick Construction ---
--- created by ticibi, dinoman, 2022 ---

local debug = false
local savedBuildPath = "MyBuilds"
local playerDataTable = {}
local cursorModel = 'PFB_BlockHunt'
local cursorModelGreen = 'PFB_Beacon'
local cursorOffset = 0.08
local cursorSize = tm.vector3.Create(0.2, 0.0075, 0.2)
local defaultCursorScale = tm.vector3.Create(1.5, 2, 1.5)
local cursorBoldness = {
    none = tm.vector3.Create(0.2, 0.0075, 0.2),
    bold = tm.vector3.Create(0.3, 0.0075, 0.3),
    selected = tm.vector3.Create(0.4, 0.0075, 0.4),
}
local utils = {
    signs = {{x=-1, z=1}, {x=1, z=1}, {x=-1, z=-1}, {x=1, z=-1}},
    modes = {
        rotation = {name='rotation'},
        position = {name='position'},
        scale = {name='scale'},
    },
    directions = {
        left = {value=1, name='left', vector=tm.vector3.Left()},
        right = {value=2, name='right', vector=tm.vector3.Right()},
        forward = {value=3, name='forward', vector=tm.vector3.Forward()},
        back = {value=4, name='back', vector=tm.vector3.Back()},
        up = {value=5, name='up', vector=tm.vector3.Up()},
        down = {value=6, name='down', vector=tm.vector3.Down()},
    },
    axes = {
        x = {value = 0, name='x'},
        y = {value = 1, name='y'},
        z = {vaue = 2, name='z'},
    }
}

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

local Materials = {}
local MaterialCategories = {'construction', 'crates', 'barrels', 'tires', 'explosives', 'gold', 'beacons', 'balls', 'ocean', 'trees', 'plants', 'salvage', 'savannah', 'cliffs', 'rocks', 'large props', 'misc'}

function InitializeMaterial(name, model, category, scale, isRigid, isStatic, isVisible)
    category = category or ''
    isRigid = isRigid or false
    isStatic = isStatic or false
    isVisible = isVisible or true
    local _table = {name=name, model=model, category=category, scale=scale, isRigid=isRigid, isStatic=isStatic, isVisible=isVisible}
    table.insert(Materials, _table)
    return _table
end

function GetMaterialByName(name)
    for i, material in ipairs(Materials) do
        if material.name == name then
            return material
        end
    end
end

function GetMaterialsCategory(category)
    local group = {}
    for _, material in ipairs(Materials) do
        if material.category == category then
            table.insert(group, material)
        end
    end
    return group
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

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function AddPlayerData(player)
    playerDataTable[player.playerId] = {
        isBuilding = false,
        buildName = nil,
        help = false,
        pause = false,
        score = 0,
        savedBuilds = {},
        Builder = {
            material = GetMaterialByName("scaffold"),
            height = 1,
            objects = {},
            history = {},
        },
        Cursor = {
            isVisible = true,
            origin = nil,
            pos = nil,
            scale = defaultCursorScale,
            vector = nil,
            points = {},
            lastMove = {
                direction = nil,
                axis = nil,
                scale = nil,
            }
        },
    }
end

function AddKeybinds(player)
    local playerId = player.playerId
    tm.input.RegisterFunctionToKeyDownCallback(playerId, "OnMoveLeft", "left")
    tm.input.RegisterFunctionToKeyDownCallback(playerId, "OnMoveRight", "right")
    tm.input.RegisterFunctionToKeyDownCallback(playerId, "OnMoveForward", "up")
    tm.input.RegisterFunctionToKeyDownCallback(playerId, "OnMoveBack", "down")
    tm.input.RegisterFunctionToKeyDownCallback(playerId, "OnMoveUp", "page up")
    tm.input.RegisterFunctionToKeyDownCallback(playerId, "OnMoveDown", "page down")
    tm.input.RegisterFunctionToKeyDownCallback(playerId, "OnPlaceObject", "enter")
    tm.input.RegisterFunctionToKeyDownCallback(playerId, "rotateLeft", "home")
    tm.input.RegisterFunctionToKeyDownCallback(playerId, "rotateRight", "end")
    tm.input.RegisterFunctionToKeyDownCallback(playerId, "toggleDebug", "`")
    tm.input.RegisterFunctionToKeyDownCallback(playerId, "selectObject", "q")
    tm.input.RegisterFunctionToKeyDownCallback(playerId, "OnRotateOrigin", "e")
    tm.input.RegisterFunctionToKeyDownCallback(playerId, "OnSetOrigin", "o")
    tm.input.RegisterFunctionToKeyDownCallback(playerId, "OnResetCursor", "y")
end

function LoadSavedBuilds(player)
    local data = ReadDynamicFile(savedBuildPath)
    if data == nil or data == '' then
        return
    end
    playerDataTable[player.playerId].savedBuilds = data
end

function onPlayerJoined(player)
    AddPlayerData(player)
    AddKeybinds(player)
    HomePage(player)
    LoadSavedBuilds(player)
end

tm.players.onPlayerJoined.add(onPlayerJoined)

function update()
    --local playerList = tm.players.CurrentPlayers()
    --for _, player in pairs(playerList) do
    --    --
    --end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Clear(playerId)
    tm.playerUI.ClearUI(playerId)
end

function Label(playerId, key, text)
    tm.playerUI.AddUILabel(playerId, key, text)
end

function Divider(playerId)
    Label(playerId, "divider", "▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬")
end

function Button(playerId, key, text, func)
    tm.playerUI.AddUIButton(playerId, key, text, func)
end

function HomePage(playerId)
    if type(playerId) ~= "number" then
        playerId = playerId.playerId
    end
    local playerData = playerDataTable[playerId]
    Clear(playerId)
    if not playerData.isBuilding then
        Button(playerId, "start building", "start building", StartBuilding)
    else
        Button(playerId, "select material", "select material", MaterialsPage)
        Divider(playerId)
        Button(playerId, "delete last", "delete last", OnDeleteLastObject)
        Button(playerId, "delete all", "delete all", OnDeleteAllObjects)
        Divider(playerId)
        Button(playerId, "save build", "save build", Save)
        Button(playerId, "cancel build", "cancel build", OnCancelBuild)
        Divider(playerId)
        Button(playerId, "show my builds", "my builds", ShowBuilds)
    end
    Button(playerId, "how to use", "how to use", ToggleHowToPage)
    if playerData.help then
        Label(playerId, "how to 1", "use ARROW keys to move Cursor")
        Label(playerId, "how to 2", "use Pg Up/Pg Down to raise/lower")
        Label(playerId, "how to 3", "press ENTER to Place an object")
        Label(playerId, "how to 4", "press E to rotate around Origin")
        Label(playerId, "how to 5", "press O to move Origin to Cursor")
        Label(playerId, "how to 5", "press Y to reset Cursor to Origin")
        Divider(playerId)
    end
    if debug then
        Divider(playerId)
        for i, group in ipairs(MaterialCategories) do
            Button(playerId, group, group, OnDebugSpawnGroup)
        end
    end
end

function ToggleHowToPage(callback)
    local playerId = callback.playerId
    playerDataTable[playerId].help = not playerDataTable[playerId].help
    HomePage(playerId)
end

function MaterialsPage(playerId)
    if type(playerId) ~= "number" then
        playerId = playerId.playerId
    end
    Clear(playerId)
    for i, group in ipairs(MaterialCategories) do
        Button(playerId, group, group, OnExpandGroup)
    end
    Divider(playerId)
    Button(playerId, "back", "back", HomePage)
end

function OnExpandGroup(callback)
    Clear(callback.playerId)
    for i, material in ipairs(GetMaterialsCategory(callback.value)) do
        Button(callback.playerId, material.model, material.name, OnSelectMaterial)
    end
    Divider(callback.playerId)
    Button(callback.playerId, "back", "back", HomePage)
end

function OnDebugSpawnGroup(callback)
    local Cursor = playerDataTable[callback.playerId].Cursor
    local startPos = Cursor.pos
    for i, material in ipairs(GetMaterialsCategory(callback.value)) do
        local newPos = tm.vector3.Create(startPos.x + material.scale.x, startPos.y, startPos.z)
        startPos = newPos
        tm.physics.SpawnObject(newPos, material.model)
    end
end

function Save(callback)
    local playerData = playerDataTable[callback.playerId]
    local Builder = playerData.Builder
    if isEmpty(Builder.objects) then
        return
    end
    if playerData.saveName == nil then
        playerData.saveName = "build "..#playerData.savedBuilds + 1
    end
    playerData.isBuilding = false
    SaveData(playerData.saveName, Builder.objects)
    table.overwrite(playerData.savedBuilds, playerData.saveName)
    WriteDynamicFile(savedBuildPath, playerData.savedBuilds)
    HomePage(callback.playerId)
end

function StartBuilding(callback)
    local playerId = callback.playerId
    local playerData = playerDataTable[playerId]
    playerData.saveName = nil
    if playerData.isBuilding then
        return
    end
    if playerData.Cursor.pos == nil then
        InitializeCursor(playerData.Cursor, GetPlayerPos(playerId))
    end
    playerData.isBuilding = true
    HomePage(playerId)
    DeleteAllObjects(playerData.Builder)
end

function ShowBuilds(callback)
    local playerId = callback.playerId
    local playerData = playerDataTable[playerId]
    Clear(playerId)
    if isEmpty(playerData.savedBuilds) then
        Label(playerId, "warning", "No Saved Builds")
        Button(playerId, "back", "back", HomePage)
        return
    end
    for i, build in ipairs(playerData.savedBuilds) do
        Button(playerId, build, build, LoadBuild)
    end
    Button(playerId, "back", "back", HomePage)
end

function LoadBuild(callback)
    local buildName = callback.value
    local data = ReadDynamicFile(buildName)
    if data == nil or data == '' then
        return
    end
    local playerId = callback.playerId
    local playerData = playerDataTable[playerId]
    local Builder = playerData.Builder
    for i, object in ipairs(data) do
        local model = object.model
        local transform = object.transform
        local spawnedObject = SpawnProp(TableToVector(transform.pos), model)
        local spawnedTransform = spawnedObject.GetTransform()
        spawnedTransform.SetRotation(tm.quaternion.Create(TableToVector(transform.rot)))
        spawnedTransform.SetScale(TableToVector(transform.scale))
        local objectData = MakeObject(spawnedObject, model)
        table.insert(Builder.objects, objectData)
        table.insert(Builder.history, {action="place", object=objectData})
    end
    HomePage(playerId)
    StartBuilding(callback)
end

function OnSelectMaterial(callback)
    local playerData = playerDataTable[callback.playerId]
    playerData.Builder.material = GetMaterialByName(callback.value)
    playerData.Cursor.scale = playerData.Builder.material.scale
    HomePage(callback.playerId)
    ResetCursor(playerData.Cursor, playerData.Cursor.pos, playerData.Builder.material.scale)
end

function OnCancelBuild(callback)
    local playerData = playerDataTable[callback.playerId]
    DeleteAllObjects(playerData.Builder)
    ResetCursor(playerData.Cursor, GetPlayerPos(callback.playerId))
    playerData.isBuilding = false
    playerData.saveName = nil
    HomePage(callback.playerId)
    ToggleCursorVisibility(playerData.Cursor)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function UpdateCursorPosition(cursor, pos)
    cursor.pos = pos
    for i = 1, #cursor.points do
        local pointPos = UpdateCursorPoint(cursor, utils.signs[i])
        cursor.points[i].GetTransform().SetPosition(pointPos)
    end
end

function UpdateCursorPoint(cursor, sign)
    local x = cursor.pos.x + (cursor.scale.x * sign.x / 2) + (cursorOffset * sign.x)
    local y = cursor.pos.y + cursor.scale.y - (cursor.scale.y / 2)
    local z = cursor.pos.z + (cursor.scale.z * sign.z / 2) + (cursorOffset * sign.z)
    return tm.vector3.Create(x, y, z)
end

function InitializeCursor(cursor, pos)
    cursor.pos = pos
    cursor.origin = pos
    for i = 1, 4 do
        local spawnPos = UpdateCursorPoint(cursor, utils.signs[i])
        local object = SpawnProp(spawnPos, cursorModel)
        object.GetTransform().SetScale(cursorSize)
        table.insert(cursor.points, i, object)
    end
end

function AdvanceCursor(cursor)
    local vector = tm.vector3.op_Multiply(cursor.lastMove.direction, cursor.lastMove.axis)
    local pos = tm.vector3.op_Addition(cursor.pos, vector)
    UpdateCursorPosition(cursor, pos)
end

function ToggleCursorVisibility(cursor)
    cursor.isVisible = not cursor.isVisible
end

function SetCursorPointScale(cursor, scale)
    for _, point in ipairs(cursor.points) do
        point.GetTransform().SetScale(scale)
    end
end

function ResetCursor(cursor, pos, scale)
    cursor.pos = pos or cursor.origin
    cursor.scale = scale or defaultCursorScale
    UpdateCursorPosition(cursor, pos)
end

function UpdateCursorLastMove(cursor, vector, axis, scale)
    cursor.lastMove.direction = vector or cursor.vector
    cursor.lastMove.axis = axis or cursor.axis
    cursor.lastMove.scale = scale or cursor.scale
end

function UpdateCursorBoldness(builder, cursor)
    if IsPositionOccupied(builder, cursor.pos) then
        SetCursorPointScale(cursor, cursorBoldness.bold)
    else
        SetCursorPointScale(cursor, cursorBoldness.none)
    end
end

function OnResetCursor(playerId)
    local Cursor = playerDataTable[playerId].Cursor
    local Builder = playerDataTable[playerId].Builder
    ResetCursor(Cursor, Cursor.origin, Builder.material.scale)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function DeleteLastObject(Builder)
    if isEmpty(Builder.objects) then
        return
    end
    local object = Builder.objects[#Builder.objects]
    if object ~= nil and object.object.Exists() then
        object.object.Despawn()
    end
    table.remove(Builder.objects, #Builder.objects)
end

function OnDeleteLastObject(callback)
    local Builder = playerDataTable[callback.playerId].Builder
    DeleteLastObject(Builder)
end

function DeleteAllObjects(Builder)
    while #Builder.objects > 0 do
        DeleteLastObject(Builder)
    end
end

function OnDeleteAllObjects(callback)
    local Cursor = playerDataTable[callback.playerId].Cursor
    local Builder = playerDataTable[callback.playerId].Builder
    DeleteAllObjects(Builder)
    ResetCursor(Cursor, Cursor.origin, Builder.material.scale)
end

function RotateMatrix(Builder)
    if isEmpty(Builder.objects) then
        return
    end
    local angle = 45
    local theta = angle * math.pi / 180
    local origin = Builder.objects[1].object.GetTransform().GetPosition()
    for i = 2, #Builder.objects do
        local object = Builder.objects[i].object
        if not isObjectValid(object) then
            return
        end
        local pos = object.GetTransform().GetPosition()
        local delta = tm.vector3.op_Subtraction(pos, origin)
        local x = delta.x * math.cos(theta) - delta.z * math.sin(theta)
        local y = pos.y
        local z = delta.x * math.sin(theta) + delta.z * math.cos(theta)
        local deltaPos = tm.vector3.Create(x, y, z)
        local newPos = tm.vector3.op_Addition(deltaPos, tm.vector3.Create(origin.x, 0, origin.z))
        object.GetTransform().SetPosition(newPos)
    end
end

function OnRotateOrigin(playerId)
    local Builder = playerDataTable[playerId].Builder
    RotateMatrix(Builder)
end

function TransformMatrix(Builder, pos)
    if isEmpty(Builder.objects) then
        return
    end
    local originObject = Builder.objects[1].object
    local originPos = originObject.GetTransform().GetPosition()
    originObject.GetTransform().SetPosition(pos)
    local deltaPos = tm.vector3.op_Subtraction(pos, originPos)
    for i = 2, #Builder.objects do
        local object = Builder.objects[i].object
        if not isObjectValid(object) then
            return
        end
        local currentPos = object.GetTransform().GetPosition()
        local newPos = tm.vector3.op_Addition(deltaPos, currentPos)
        object.GetTransform().SetPosition(newPos)
    end
end

function OnSetOrigin(playerId)
    local Builder = playerDataTable[playerId].Builder
    local Cursor = playerDataTable[playerId].Cursor
    TransformMatrix(Builder, Cursor.pos)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function IsPositionOccupied(Builder, pos)
    for _, object in ipairs(Builder.objects) do
        if object.object.GetTransform().GetPosition() == pos then
            return true
        end
    end
    return false
end

function GetObjectAtPosition(Builder, pos)
    for _, object in ipairs(Builder.objects) do
        if object.object.GetTransform().GetPosition() == pos then
            return object.object
        end
    end
    return nil
end

function SpawnProp(pos, model)
    return tm.physics.SpawnObject(
            pos,
            model
        )
end

function PlaceObject(Builder, Cursor)
    if IsPositionOccupied(Builder, Cursor.pos) then
        return
    end
    for i = 1, Builder.height do
        local object = SpawnProp(Cursor.pos, Builder.material.model)
        local objectData = MakeObject(object, Builder.material.model)
        table.insert(Builder.objects, objectData)
        table.insert(Builder.history, {action="place", object=objectData})
    end
end

function OnPlaceObject(playerId)
    local playerData = playerDataTable[playerId]
    if not playerData.isBuilding then
        return
    end
    PlaceObject(playerData.Builder, playerData.Cursor)
    UpdateCursorBoldness(playerData.Builder, playerData.Cursor)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function isBuilding(playerId)
    return playerDataTable[playerId].isBuilding
end

function MoveCursor(builder, cursor, vector, axis)
    local directionVector = tm.vector3.op_Multiply(vector, axis)
    local newPosition = tm.vector3.op_Addition(cursor.pos, directionVector)
    UpdateCursorPosition(cursor, newPosition)
    UpdateCursorLastMove(cursor, vector, axis)
    UpdateCursorBoldness(builder, cursor)
end

function OnMoveLeft(playerId)
    local Builder = playerDataTable[playerId].Builder
    local Cursor = playerDataTable[playerId].Cursor
    if not isBuilding(playerId) then
        return
    end
    MoveCursor(Builder, Cursor, utils.directions.left.vector, Builder.material.scale.x)
end

function OnMoveRight(playerId)
    local Builder = playerDataTable[playerId].Builder
    local Cursor = playerDataTable[playerId].Cursor
    if not isBuilding(playerId) then
        return
    end
    MoveCursor(Builder, Cursor, utils.directions.right.vector, Builder.material.scale.x)
end

function OnMoveForward(playerId)
    local Builder = playerDataTable[playerId].Builder
    local Cursor = playerDataTable[playerId].Cursor
    if not isBuilding(playerId) then
        return
    end
    MoveCursor(Builder, Cursor, utils.directions.forward.vector, Builder.material.scale.z)
end

function OnMoveBack(playerId)
    local Builder = playerDataTable[playerId].Builder
    local Cursor = playerDataTable[playerId].Cursor
    if not isBuilding(playerId) then
        return
    end
    MoveCursor(Builder, Cursor, utils.directions.back.vector, Builder.material.scale.z)
end

function OnMoveUp(playerId)
    local Builder = playerDataTable[playerId].Builder
    local Cursor = playerDataTable[playerId].Cursor
    if not isBuilding(playerId) then
        return
    end
    MoveCursor(Builder, Cursor, utils.directions.up.vector, Builder.material.scale.y)
end

function OnMoveDown(playerId)
    local Builder = playerDataTable[playerId].Builder
    local Cursor = playerDataTable[playerId].Cursor
    if not isBuilding(playerId) then
        return
    end
    MoveCursor(Builder, Cursor, utils.directions.down.vector, Builder.material.scale.y)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function MakeObject(object, material)
    return {object=object, material=material}
end

function UnpackTransform(transform)
    return {
        pos = VectorToTable(transform.GetPosition()),
        rot = VectorToTable(transform.GetRotation()),
        scale = VectorToTable(transform.GetScale())
    }
end

function PackData(data)
    local struct = {}
    for _, object in ipairs(data) do
        if not isObjectValid(object.object) then
            return
        end
        local transform = object.object.GetTransform()
        local transformData = UnpackTransform(transform)
        local objectData = {model=object.material, transform=transformData}
        table.insert(struct, objectData)
    end
    return struct
end

function SaveData(filename, data)
    local packedData = PackData(data)
    local jsonData = json.serialize(packedData)
    tm.os.WriteAllText_Dynamic(filename, jsonData)
end

function LoadData(filename)
    local file = tm.os.ReadAllText_Dynamic(filename)
    if not isFileValid(file) then
        return
    end
    return json.parse(file)
end

function UnpackData(data)
    --
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function ReadDynamicFile(path)
    local file = tm.os.ReadAllText_Dynamic(path)
    if isFileValid(file) then
        return json.parse(file)
    end
end

function WriteDynamicFile(path, data)
    local jsonData = json.serialize(data)
    tm.os.WriteAllText_Dynamic(path, jsonData)
end

function GetPlayerPos(playerId)
    return tm.players.GetPlayerTransform(playerId).GetPosition()
end

function CreateRandomizedVector(limitX, limitY, limitZ, value)
    value = value or 0.1
    return tm.vector3.Create(
        math.random(-limitX, limitX) * value,
        math.random(-limitY, limitY) * value,
        math.random(-limitZ, limitZ) * value
    )
end

function isEmpty(list)
    return #list < 1
end

function isFileValid(file)
    if file == nil or file == '' then
        return false
    end
    return true
end

function isObjectValid(object)
    return object.Exists() and object ~= nil
end

function VectorToTable(vector)
    return {
        x = vector.x,
        y = vector.y,
        z = vector.z
    }
end

function TableToVector(table)
    return tm.vector3.Create(table.x, table.y, table.z)
end

function PrintVector(vector)
    return 'x: '..vector.x..', y: '..vector.y..', z: '..vector.z
end

function Log(text)
    tm.os.log(text)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

-- returns index of item
function table.index(_table, _item)
    for i, v in ipairs(_table) do
        if _item == v then
            return i
        end
    end
end

-- removes item from table if it exists
function table.pop(_table, _item)
    if not table.contains(_table, _item) then return end
    for i, v in ipairs(_table) do
        if _item == v then
            table.remove(_table, i)
        end
    end
end

-- checks if item is in table
function table.contains(_table, _item)
    for _, v in ipairs(_table) do
        if _item == v then
            return true
        end
    end
    return false
end

-- overwrites item in table if item already exists, or appends item
function table.overwrite(_table, _item)
    if table.contains(_table, _item) then
        local index = table.index(_table, _item)
        _table[index] = _item
    else
        table.insert(_table, _item)
    end
end

-- returns a reversed copy of a table
function table.reversed(_table)
    local copy = _table
    local len = #copy
    local i = 1
    while i < len do
        copy[i], copy[len] = copy[len], copy[i]
        i = i + 1
        len = len - 1
    end
    return copy
end

-- inserts item into table if not in table already
function table.insertUnique(_table, _item)
    if table.contains(_table, _item) then
        return
    end
    table.insert(_table, _item)
end

-- returns the last element of a table
function table.last(_table)
    if #_table < 1 then
        error('table empty', 2)
    end
    return _table[#_table]
end

-- splits string by delimiter
function string.split(_string, delimiter)
    delimiter = delimiter or '%S+'
    local output = {}
    for char in string.gmatch(_string, '%S+') do
        table.insert(output, char)
    end
    return output
end
