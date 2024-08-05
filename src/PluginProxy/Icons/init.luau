local Icons = {}

local Atlas = require(script.Atlas)
local BaseAtlas = Atlas.BaseAtlas
local StudioIconAtlas = Atlas.StudioIconAtlas

export type ImageProps = Atlas.ImageProps
export type Size = Atlas.AtlasSize

Icons.InsertableObjects = StudioIconAtlas.new("Standard",
    Atlas.new({
        Accessory=0, Actor=1, AdGui=2, AdPortal=3, AirController=4, AlignOrientation=5, AlignPosition=6, AngularVelocity=7, Animation=8, AnimationConstraint=9, AnimationController=10, AnimationFromVideoCreatorService=11, Animator=12, ArcHandles=13, Atmosphere=14, Attachment=15, AudioAnalyzer=16, AudioChorus=17, AudioCompressor=18, AudioDeviceInput=19, AudioDeviceOutput=20, AudioDistortion=21, AudioEcho=22, AudioEmitter=23, AudioEqualizer=24, AudioFader=25, AudioFilter=26, AudioFlanger=27, AudioListener=28, AudioPitchShifter=29, AudioPlayer=30, AudioReverb=31, AvatarEditorService=32, Backpack=33, BallSocketConstraint=34, BasePlate=35, Beam=36, BillboardGui=37, BindableEvent=38, BindableFunction=39, BlockMesh=40, BloomEffect=41, BlurEffect=42, BodyAngularVelocity=43, BodyColors=44, BodyForce=45, BodyGyro=46, BodyPosition=47, BodyThrust=48, BodyVelocity=49, Bone=50, BoolValue=51, BoxHandleAdornment=52, Breakpoint=53, BrickColorValue=54, BubbleChatConfiguration=55, Buggaroo=56, Camera=57, CanvasGroup=58, CFrameValue=59, CharacterControllerManager=60, CharacterMesh=61, Chat=62, ChatInputBarConfiguration=63, ChatWindowConfiguration=64, ChorusSoundEffect=65, Class=66, Cleanup=67, ClickDetector=68, ClientReplicator=69, ClimbController=70, Clouds=71, 
        Color=72, ColorCorrectionEffect=73, CompressorSoundEffect=74, ConeHandleAdornment=75, Configuration=76, Constant=77, Constructor=78, CoreGui=79, CornerWedgePart=80, CylinderHandleAdornment=81, CylindricalConstraint=82, Decal=83, DepthOfFieldEffect=84, Dialog=85, DialogChoice=86, DistortionSoundEffect=87, DragDetector=88, EchoSoundEffect=89, EditableImage=90, EditableMesh=91, Enum=92, EnumMember=93, EqualizerSoundEffect=94, Event=95, Explosion=96, FaceControls=97, Field=98, File=99, Fire=100, FlangeSoundEffect=101, Folder=102, ForceField=103, Frame=104, Function=105, GameSettings=106, GroundController=107, Handles=108, HapticService=109, HeightmapImporterService=110, Highlight=111, HingeConstraint=112, Humanoid=113, HumanoidDescription=114, IKControl=115, ImageButton=116, ImageHandleAdornment=117, ImageLabel=118, Interface=119, IntersectOperation=120, Keyword=121, Lighting=122, LinearVelocity=123, LineForce=124, LineHandleAdornment=125, LocalFile=126, LocalizationService=127, LocalizationTable=128, LocalScript=129, MaterialService=130, MaterialVariant=131, MemoryStoreService=132, MeshPart=133, Meshparts=134, MessagingService=135, Method=136, Model=137, Modelgroups=138, Module=139, ModuleScript=140, Motor6D=141, NegateOperation=142, NetworkClient=143, 
        NoCollisionConstraint=144, Operator=145, Pants=146, Part=147, ParticleEmitter=148, Path2D=149, PathfindingLink=150, PathfindingModifier=151, PathfindingService=152, PitchShiftSoundEffect=153, Place=154, Plane=155, PlaneConstraint=156, Player=157, Players=158, PluginGuiService=159, PointLight=160, PrismaticConstraint=161, Property=162, ProximityPrompt=163, PublishService=164, Reference=165, RemoteEvent=166, RemoteFunction=167, RenderingTest=168, ReplicatedFirst=169, ReplicatedScriptService=170, ReplicatedStorage=171, ReverbSoundEffect=172, RigidConstraint=173, RobloxPluginGuiService=174, RocketPropulsion=175, RodConstraint=176, RopeConstraint=177, Rotate=178, ScreenGui=179, Script=180, ScrollingFrame=181, Seat=182, Selected_Workspace=183, SelectionBox=184, SelectionSphere=185, ServerScriptService=186, ServerStorage=187, Shirt=188, ShirtGraphic=189, SkinnedMeshPart=190, Sky=191, Smoke=192, Snap=193, Snippet=194, SocialService=195, Sound=196, SoundEffect=197, SoundGroup=198, SoundService=199, Sparkles=200, SpawnLocation=201, SpecialMesh=202, SphereHandleAdornment=203, SpotLight=204, SpringConstraint=205, StandalonePluginScripts=206, StarterCharacterScripts=207, StarterGui=208, StarterPack=209, StarterPlayer=210, StarterPlayerScripts=211, Struct=212, StyleDerive=213, StyleLink=214, StyleRule=215, 
        StyleSheet=216, SunRaysEffect=217, SurfaceAppearance=218, SurfaceGui=219, SurfaceLight=220, SurfaceSelection=221, SwimController=222, TaskScheduler=223, Team=224, Teams=225, Terrain=226, TerrainDetail=227, TestService=228, TextBox=229, TextBoxService=230, TextButton=231, TextChannel=232, TextChatCommand=233, TextChatService=234, TextLabel=235, TextString=236, Texture=237, Tool=238, Torque=239, TorsionSpringConstraint=240, Trail=241, TremoloSoundEffect=242, TrussPart=243, TypeParameter=244, UGCValidationService=245, UIAspectRatioConstraint=246, UICorner=247, UIDragDetector=248, UIFlexItem=249, UIGradient=250, UIGridLayout=251, UIListLayout=252, UIPadding=253, UIPageLayout=254, UIScale=255, UISizeConstraint=256, UIStroke=257, UITableLayout=258, UITextSizeConstraint=259, UnionOperation=260, Unit=261, UniversalConstraint=262, UnreliableRemoteEvent=263, UpdateAvailable=264, UserService=265, Value=266, Variable=267, VectorForce=268, VehicleSeat=269, VideoFrame=270, ViewportFrame=271, VirtualUser=272, VoiceChannel=273, Voicechat=274, VoiceChatService=275, VRService=276, WedgePart=277, Weld=278, WeldConstraint=279, Wire=280, WireframeHandleAdornment=281, Workspace=282, WorldModel=283, WrapLayer=284, WrapTarget=285
    },
    BaseAtlas.new("rbxassetid://18737911961", 512, 16))
        :AddScale(3, BaseAtlas.new("rbxassetid://18740233249", 1024, 48):Extend("rbxassetid://18740235883", 1024))
)
:AddSize("Large",
    Atlas.new({
        AlignOrientation=0, AlignPosition=1, AngularVelocity=2, Attachment=3, Beam=4, Cleanup=5, Explosion=6, Fire=7, Frame=8, 
        GameSettings=9, ImageButton=10, ImageLabel=11, IntersectOperation=12, LinearVelocity=13, LineForce=14, NegateOperation=15, ParticleEmitter=16, PlaneConstraint=17, 
        Player=18, PointLight=19, Rotate=20, ScreenGui=21, ScrollingFrame=22, Smoke=23, Sparkles=24, SpotLight=25, SurfaceLight=26, 
        TaskScheduler=27, TextBox=28, TextButton=29, TextLabel=30, Torque=31, Trail=32, UnionOperation=33, VectorForce=34
    },
    BaseAtlas.new("rbxassetid://18743462980", 1024, 64))
        :AddScale(3, BaseAtlas.new("rbxassetid://18739086116", 1024, 96))
)



Icons.Other = StudioIconAtlas.new("Standard",
    Atlas.new({
		Error=0, Information=1, Question=2, Success=3, Warning=4, Copy=5, Cut=6, Duplicate=7, Paste=8, Redo=9, Undo=10, AddWatch=11, ConditionalBreakpoint=12, ConditionalBreakpointDisabled=13, DeleteAllBreakpoints=14, DeleteSelectedBreakpoints=15, DisableAllBreakpoints=16, InvalidBreakpoint=17, InvalidLogpoint=18, Logpoint=19, LogpointDisabled=20, StepInto=21, StepOut=22, StepOver=23, Move=24, 
		Move_P=25, Rotate_P=26, Scale=27, Scale_P=28, Select=29, Select_P=30, Transform=31, Material=32, AddNoBorder=33, ArrowDown=34, ArrowLeft=35, ArrowRight=36, ArrowUp=37, Back=38, CloseWidget=39, Collapse=40, DropdownArrow=41, Expand=42, ExpandAll=43, Fwd=44, HorizontalDoubleArrow=45, More=46, ScrollbarDown=47, ScrollbarTriangle=48, ScrollbarUp=49, 
		Settings=50, ZoomIn=51, ZoomOut=52, ZoomTo=53, NotificationBell=54, Placeholder=55, CheckboxOff=56, CheckboxOn=57, Group=58, Recent=59, User=60, AccessoryFittingTool=61, ActivityHistory=62, AddCollaborator=63, AlignTool=64, AnimationEditor=65, AssetManager=66, Assistant=67, AvatarImporter=68, Breakpoints=69, CallStack=70, CollisionGroups=71, CommandBar=72, CompositorDebugger=73, DeviceSafeArea=74, 
		Draft=75, Explorer=76, GlobalWindControl=77, InsertObject=78, ManagePlugins=79, ObjectBrowser=80, Output=81, Performance=82, PluginsFolder=83, Properties=84, RunScript=85, ScriptAnalysis=86, ScriptPerformance=87, ScriptRecovery=88, Service=89, StyleEditor=90, TagEditor=91, TeamCreate=92, TerrainEditor=93, Toolbox=94, VisualizationModes=95, Watch=96
	},
	BaseAtlas.new("rbxassetid://18738073488", 256, 16))
        :AddScale(3, BaseAtlas.new("rbxassetid://18739833197", 1024, 48)))
:AddSize("Large", Atlas.new({
        Error=0, Information=1, Question=2, Success=3, Warning=4, Copy=5, Cut=6, Duplicate=7, Paste=8, Redo=9, Undo=10, AddWatch=11, StepInto=12, StepOut=13, StepOver=14, Move=15, Move_P=16, Rotate_P=17, Scale=18, Scale_P=19, 
        Select=20, Select_P=21, Transform=22, Material=23, ArrowDown=24, ArrowRight=25, Back=26, CollapseAll=27, ExpandAll=28, Fwd=29, Help=30, Share=31, ZoomIn=32, ZoomOut=33, ZoomTo=34, Group=35, User=36, AccessoryFittingTool=37, ActivityHistory=38, AlignTool=39, 
        AnimationEditor=40, AssetManager=41, Assistant=42, AvatarImporter=43, AvatarPreviewer=44, Breakpoints=45, BuildRig=46, BulkCreateAccessories=47, CallStack=48, CollisionGroups=49, CommandBar=50, CompositorDebugger=51, CreateAccessory=52, DeviceSafeArea=53, Draft=54, Explorer=55, GlobalWindControl=56, InsertObject=57, LocalizationTools=58, ManagePlugins=59, 
        MaterialGenerator=60, MeshImporter=61, MeshTextureTool=62, ObjectBrowser=63, Output=64, Performance=65, PluginsFolder=66, Properties=67, RunScript=68, ScriptAnalysis=69, ScriptPerformance=70, ScriptRecovery=71, Service=72, StyleEditor=73, TagEditor=74, TeamCreate=75, TerrainEditor=76, Toolbox=77, ViewSounds=78, Watch=79
    },
    BaseAtlas.new("rbxassetid://18739082763", 1024, 64)
))

--- Attempts to process a provided asset path ("rbxasset://studio_svg_textures/Shared/InsertableObjects/Dark/Standard/Color@2x.png")
--- Returns ImageProps if the path and image exists
function Icons.ProcessStudioAssetPath(path: string): ImageProps?
    local Prefix_S, Prefix_E = string.find(path, "^rbxasset://studio_svg_textures/")
    if not Prefix_S then return end

    local SplitPath = path:sub(Prefix_S, Prefix_E):split("/")
    if #SplitPath ~= 5 then
        error(`Studio texture path '{path}' is incorrect length, contains '{#SplitPath+1}' directories, when it should be '{6}'`, 2)
    end
    if SplitPath[1] ~= "Shared" then
        error(`Studio texture path '{path}' is not supported, because it contains directory '{SplitPath[1]}' and only 'Shared' is available`, 2)
    end

    local Category = SplitPath[2]
    local Theme = SplitPath[3]
    local Size = SplitPath[4]

    local ScaleSplit = SplitPath[5]:split("@")
    local Scale
    if ScaleSplit[2] then
        Scale = string.match(ScaleSplit[2], "%d")
    end

    local Name = ScaleSplit[1]:split(".")[1]

    if Category == "InsertableObjects" then
        return Icons.InsertableObjects:Get(Name, Theme, Size, Scale)
    end
    return Icons.Other:Get(Name, Theme, Size, Scale)
end

return Icons