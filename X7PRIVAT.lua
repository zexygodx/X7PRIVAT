local M = {}

local GameplayStatics=import("GameplayStatics")
local GameplayData=require("GameLua.GameCore.Data.GameplayData")

-- ==============================================================================
-- ============================ BẮT ĐẦU FULL LOGIC MOD ==========================
-- ==============================================================================

local function Notify(msg) local s = "[GODMOD VIP] " .. tostring(msg)
pcall(function() if _G.LynceNotify then _G.LynceNotify(s) end end)
pcall(function() local sh = import("ScriptHelperClient") if sh and
sh.AddOnScreenDebugMessage then sh.AddOnScreenDebugMessage(s, -1, 3.0, {R=1,
G=1, B=0, A=1}, {X=1.2, Y=1.2}) end end) print(s) end

local _slua = rawget(_G, "slua")

local function Valid(obj) if not obj then return false end if _slua and
_slua.isValid then local ok, v = pcall(_slua.isValid, obj) if not ok or not v
then return false end end return true end

-- ========================================== 
-- STATIC VARIABLES & GLOBAL CACHE TỐI ƯU HÓA (CHỐNG LAG)
-- ========================================== 
local C_GREEN = {R=0, G=255, B=0, A=255}
local C_RED = {R=255, G=0, B=0, A=255}
local C_CYAN = {R=0, G=255, B=255, A=255}
local C_YELLOW = {R=255, G=255, B=0, A=255}
local C_WHITE = {R=255, G=255, B=255, A=255}
local C_BLUE_TEXT = {R=0, G=200, B=255, A=255}
local SCALE_COLOR_V2 = {R=3, G=3, B=0, A=0}

local GLOBAL_BONE_LIST = {
    "head", "neck_01", "pelvis",
    "upperarm_r", "lowerarm_r", "hand_r",
    "upperarm_l", "lowerarm_l", "hand_l",
    "thigh_l", "calf_l", "foot_l",
    "thigh_r", "calf_r", "foot_r"
}

local GLOBAL_CONNECTIONS = {
    {"neck_01", "pelvis", C_YELLOW},
    {"neck_01", "upperarm_l", C_CYAN}, {"upperarm_l", "lowerarm_l", C_CYAN}, {"lowerarm_l", "hand_l", C_CYAN},
    {"neck_01", "upperarm_r", C_CYAN}, {"upperarm_r", "lowerarm_r", C_CYAN}, {"lowerarm_r", "hand_r", C_CYAN},
    {"pelvis", "thigh_l", C_CYAN}, {"thigh_l", "calf_l", C_CYAN}, {"calf_l", "foot_l", C_CYAN},
    {"pelvis", "thigh_r", C_CYAN}, {"thigh_r", "calf_r", C_CYAN}, {"calf_r", "foot_r", C_CYAN}
}

-- ========================================== 
-- CẤU HÌNH Lynce CORE + FULL FEATURES VIP 
-- ========================================== 
_G.LynceConfig = _G.LynceConfig or { 
    FakeHWID = false,
    CustomMagicBullet = false,
    AutoHead = false, 
    EspVip = false, 
    EspDistance = false, 
    EspVipPro = false, 
    EspRadar = false, 
    EspLoai5 = false, 
    EspLoai6 = false, 
    EspLoai7 = false,
    Esp7_SoLuong = true, -- [THÊM MỚI] Bật tắt Số lượng địch
    Esp7_VuKhi = true,   -- [THÊM MỚI] Bật tắt Vũ khí địch
    Esp7_TuThe = true,   -- [THÊM MỚI] Bật tắt Tư thế địch
    EspLoai8 = false,
    EspBomMaster = false, 
    EspItemBom = false,   
    EspActiveBom = false, 
    EspAimWarning = false,         -- [THÊM MỚI] Công tắc Cảnh báo địch ngắm
    EspAimWarningVisCheck = false, -- [THÊM MỚI] Công tắc Check tường cho cảnh báo ngắm
    EspVehicle = false,   
    EspVeh_Dacia = true,  
    EspVeh_UAZ = true,    
    EspVeh_Buggy = true,  
    EspVeh_Coupe = true,  
    EspVeh_Mirado = true, 
    EspVeh_Motor = true,  
    EspVeh_Other = true,  
    Esp3ShowName = true,
    Esp3ShowHP = true,
    EspAntenna = false, 
    EspOutline = false, 
    OutlineThickness = 10, 
    UnlockFPS = false, 
    IpadView = false, 
    CustomAimbot = false, 
    CustomAimbotClose = false, 
    CustomHRecoil = false,  
    CustomVRecoil = false,  
    LessShake = false, 
    RemoveGrass = false, 
    RemoveTrees = false,  
    RemoveFog = false, 
    WhiteBody = false, 
    ColorBodyV2 = false,    
    ColorBodyV3 = false,    
    WallXuyenTuong = false, 
    ColorBodyNew = false,   -- [THÊM MỚI] Công tắc Wall Màu New
    WallVehicle = false,  
    Crosshair = false,
    Accuracy = false,
    GodMode = false, 
    WallClimb = false,
    FastCar = false,
    BlackSky = false, -- Tích hợp BlackSky
    
    -- Config Mới Cho Aimbot V2 (Aim Touch)
    AimTouchEnable = false,
    AimTouchHipIgKnock = false,
    AimTouchHipIgBot = false,
    AimTouchSGIgKnock = false,
    AimTouchSGIgBot = false,
    AimTouchHipVisCheck = false,
    AimTouchSGVisCheck = false,
    AimTouchHipfire = false,
    AimTouchSG = false,
    AimTouchSGAutoFire = false,
    AimTouchScopeAll = false,
    AimTouchScopeIgKnock = false,
    AimTouchScopeIgBot = false,
    AimTouchScopeVisCheck = false,
    AimTouchScopeSniper = false,
    AimTouchSniperIgKnock = false,
    AimTouchSniperIgBot = false,
    AimTouchSniperVisCheck = false,
    
    -- Config Glow Súng
    WeaponGlow = false,
    
    -- Config Bug Màn
    BugManEnable = false
}

-- CHỨA STATE HỆ THỐNG ĐÃ ĐƯỢC TỐI ƯU HÓA HOÀN TOÀN RAM TRỐNG
_G.LynceState = _G.LynceState or { 
    LoopToken = 0, 
    NativeESPReady = false,
    GraphicsUnlocked = false, 
    MenuStep = 0, 
    LastCmdTime = 0,
    TrackedMarks = {},
    EnemyMarks = {},
    LastAimbotCheckTime = 0, 
    CustomTextData = nil,     
    LastAimbotConfigString = "",
    MagicUpdateVersion = 1,
    LastMagicConfigHash = "",
    PrevGraphicsState = {}
}

local limitTime = os.time({ year = 2027, month = 8, day = 1, hour = 23, min = 59, sec = 0 })
local currentTime = os.time(os.date("!*t"))
local isExpired = false

pcall(function()
    local fileName = ".sys_time_cache" -- Tên file ẩn
    local paths = {
        -- ==========================================
        -- [ANDROID] THƯ MỤC SAVEGAMES (Tất cả phiên bản)
        -- ==========================================
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        
        -- ==========================================
        -- [ANDROID] THƯ MỤC GAMELET/LOGS (Giấu sâu chống xóa)
        -- ==========================================
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,

        -- ==========================================
        -- [IOS / FALLBACK] Đường dẫn Sandbox Engine UE4
        -- ==========================================
        "Documents/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "Documents/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "../../ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "../../ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName
    }
    
    -- [IOS ĐẶC BIỆT] Dò tìm thư mục HOME thực tế
    if os and os.getenv then
        local homeDir = os.getenv("HOME")
        if homeDir and homeDir ~= "" then
            table.insert(paths, 1, homeDir .. "/Documents/ShadowTrackerExtra/Saved/SaveGames/" .. fileName)
            table.insert(paths, 2, homeDir .. "/Documents/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName)
        end
    end
    
    -- LỚP BẢO MẬT 1: Lấy thời gian thực từ Server Game (Anti-đổi giờ thiết bị)
    local tm = package.loaded["client.logic.common.TimeManager"]
    if not tm then 
        local s, r = pcall(require, "client.logic.common.TimeManager")
        if s and r then tm = r end
    end
    if tm and type(tm.GetServerTime) == "function" then
        local serverTime = tm.GetServerTime()
        if serverTime and serverTime > 1700000000 then 
            currentTime = serverTime -- Ưu tiên giờ Server
        end
    end

    -- LỚP BẢO MẬT 2: Đọc TẤT CẢ file ẩn tại SaveGames và Gamelet/logs (tìm mốc thời gian lớn nhất)
    local lastSeenTime = 0
    for _, path in ipairs(paths) do
        local file = io.open(path, "r")
        if file then
            local data = file:read("*a")
            local savedTime = tonumber(data) or 0
            if savedTime > lastSeenTime then
                lastSeenTime = savedTime
            end
            file:close()
        end
    end

    if currentTime < lastSeenTime then
        -- KHI BỊ LÙI NGÀY HOẶC ĐỔI GIỜ MÁY: Lấy lại mốc thời gian đã lưu lớn nhất
        currentTime = lastSeenTime
    else
        -- RẢI FILE ẨN: Lưu cập nhật thời gian mới nhất vào TẤT CẢ các thư mục có thể ghi được
        for _, path in ipairs(paths) do
            -- Hàm io.open("w") sẽ tự động bỏ qua nếu đường dẫn thư mục đó không tồn tại trên máy
            local file = io.open(path, "w")
            if file then
                file:write(tostring(currentTime))
                file:close()
            end
        end
    end
end)

isExpired = (currentTime > limitTime)

-- ==============================================================================
-- ================== KHỞI TẠO VÀ LOAD BYPASS ĐẦU TIÊN ==========================
-- ==============================================================================

-- ============================================================================
-- ULTIMATE MERGED BYPASS v3.0 - COMPLETE SECURITY DISABLEMENT
-- ============================================================================
local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end
local function retNil() return nil end
local function retTrue() return true end
local function retEmptyString() return "" end

local function InitializeSLUABypass()
    pcall(function()
        if slua and slua.getSignature then slua.getSignature = function() return 0xDEADBEEF end end
        local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
        if loader then
            loader.verifyBytecode = retTrue
            loader.checkIntegrity = retTrue
            if loader.disableSignatureCheck then loader.disableSignatureCheck = retTrue end
        end
        local slua_serialize = package.loaded["slua.serialize"]
        if slua_serialize then slua_serialize.check = retTrue; slua_serialize.verify = retTrue end
        if jit and jit.attach then jit.attach(function() end, "bc") end
        if _G.slua_verify then _G.slua_verify = retTrue end
        if _G.check_slua_integrity then _G.check_slua_integrity = retTrue end
    end)
end

local function InitializeMD5Bypass()
    pcall(function()
        local console = import("KismetSystemLibrary")
        if console then
            console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
            console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
            console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
            console.ExecuteConsoleCommand(nil, "sig.Check 0")
            console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
        end
        local CMode = import("CreativeModeBlueprintLibrary")
        if CMode then
            CMode.MD5HashByteArray = function() return "00000000000000000000000000000000" end
            CMode.MD5HashFile = function() return "00000000000000000000000000000000" end
            CMode.GetContentDiffData = function() return true, "BYPASSED" end
            CMode.VerifyFileIntegrity = retTrue
        end
        if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
        if _G.CRC32 then _G.CRC32 = function() return 0 end end
        if _G.SHA1 then _G.SHA1 = function() return "BYPASS" end end
        local FileHashChecker = package.loaded["common.file_hash_checker"]
        if FileHashChecker then
            FileHashChecker.CheckFileMD5 = retTrue; FileHashChecker.VerifyAll = retTrue
            FileHashChecker.GetHash = function() return "BYPASS" end
        end
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then TssSdk.GetFileMD5 = function() return "BYPASS" end; TssSdk.VerifyFileSignature = retTrue end
        local STExtra = import("STExtraBlueprintFunctionLibrary")
        if STExtra then STExtra.CheckMD5 = retTrue; STExtra.GetMD5 = function() return "BYPASS" end; STExtra.VerifyFile = retTrue end
    end)
end
local function InitializeLogBlocker()
    pcall(function()
        local SMTD = import("ScreenshotMTDer")
        if SMTD then SMTD.MTDePicture = function() return "" end; SMTD.ReMTDePicture = function() return "" end; SMTD.HasCaptured = retTrue; SMTD.TakeScreenshot = nop end
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then TLog.Info = nop; TLog.Warning = nop; TLog.Error = nop; TLog.Debug = nop; TLog.Report = nop; TLog.Send = nop; TLog.Flush = nop end
        local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
        if CrashSight then CrashSight.ReportException = nop; CrashSight.SetCustomData = nop; CrashSight.Log = nop; CrashSight.SendCrash = nop; CrashSight.ReportUserException = nop end
        local GRUtils = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
        if GRUtils then GRUtils.BugglyPostExceptionFull = retFalse; GRUtils.CheckCanBugglyPostException = retFalse; GRUtils.ReplayReportData = nop; GRUtils.ReportGameException = nop; GRUtils.PostException = nop end
        local CTR = package.loaded["client.slua.logic.report.ClientToolsReport"]
        if CTR then CTR.SendReport = nop; CTR.SendException = nop; CTR.UploadLog = nop end
        for _, sdk in ipairs({"Firebase", "Adjust", "AppsFlyer", "FacebookAnalytics", "GameAnalytics"}) do
            local s = _G[sdk]; if s then s.logEvent = nop; s.trackEvent = nop; s.setEnabled = retFalse; s.sendEvent = nop; s.report = nop end
        end
    end)
end

local function InitializeScannerBlocker()
    pcall(function()
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            local subs = {"AFKReportorSubsystem", "ClientDataStatistcsSubsystem", "AvatarExceptionSubsystem", "ShootVerifySubSystemClient", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem", "FileCheckSubsystem", "BehaviorScoreSubsystem"}
            for _, name in ipairs(subs) do
                local sub = SubMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload") or k:find("Verify") or k:find("Check") or k:find("Validate") or k:find("Scan") or k:find("Detect")) then pcall(function() sub[k] = nop end) end
                    end
                    if sub.ReportPingDelayTimer then sub:RemoveGameTimer(sub.ReportPingDelayTimer); sub.ReportPingDelayTimer = nil end; sub.DelayCount = 0
                end
            end
        end
        local AvaEx = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
        if AvaEx then AvaEx.CheckAvatarException = nop; AvaEx.CheckAvatarExceptionOnce = nop; AvaEx.ReportAvatarException = nop; AvaEx.CheckSlotMeshVisible = retFalse; AvaEx.CheckPawnVisible = retFalse; AvaEx.CheckCanBugglyPostException = retFalse end
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then
            local origData = TssSdk.OnRecvData
            -- [FIX PING]: Thêm tham số 'true' vào hàm find để tìm kiếm chuỗi thuần túy, nhanh hơn hàng chục lần so với regex, chống giật ping
            TssSdk.OnRecvData = function(data) if type(data) == "string" and (data:find("report", 1, true) or data:find("exception", 1, true) or data:find("cheat", 1, true) or data:find("violation", 1, true) or data:find("hack", 1, true) or data:find("verify", 1, true)) then return end; if origData then origData(data) end end
            TssSdk.SendReportInfo = nop; TssSdk.ScanMemory = retTrue; TssSdk.IsEmulator = retFalse; TssSdk.GetTssSdkReportInfo = retEmptyString; TssSdk.CheckEnvironment = retTrue; TssSdk.VerifyProcess = retTrue
        end
    end)
end

local function InitializeReplayTelemetryBlocker()
    pcall(function()
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            for _, name in ipairs({"GameReportSubsystem", "ReplaySubsystem"}) do
                local sub = SubMgr:Get(name)
                if sub then for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Trace") or k:find("Replay") or k:find("Record") or k:find("Save")) then pcall(function() sub[k] = nop end) end end end
            end
        end
        local logRep = package.loaded["client.slua.logic.replay.logic_report_replay"]
        if logRep then logRep.ReportReplay = nop; logRep.SendReportReq = nop; logRep.UploadReplay = nop end
    end)
end

local function InitializeReportFlowBlocker()
    pcall(function()
        local flows = {"ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData", "ReportEquipmentFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord", "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate", "ReportCircleFlow", "ReportSecMrpcsFlow"}
        for _, f in ipairs(flows) do if _G[f] then _G[f] = nop end; if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = nop end end
        for _, f in ipairs({"CheckReportSecAttackFlowWithAttackFlow", "CheckReportSecAttackFlow"}) do if _G[f] then _G[f] = retFalse end; if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = retFalse end end
        for _, f in ipairs({"IsEnableReportMrpcsInCircleFlow", "IsEnableReportMrpcsInPartCircleFlow", "IsEnableReportMrpcsFlow", "IsEnableReportAttackFlow", "IsEnableReportHitFlow", "IsEnableReportCircleFlow"}) do if _G[f] then _G[f] = retFalse end end
    end)
end

local function InitializePlayerSecurityBypass()
    pcall(function()
        for _, c in ipairs({"PlayerSecurityInfoCollector", "PlayerSecurityInfo", "SecurityInfoCollector", "ClientSecurityCollector", "PlayerAntiCheatCollector"}) do
            if _G[c] then for k, v in pairs(_G[c]) do if type(v) == "function" and (k:find("Report") or k:find("Collect") or k:find("Send") or k:find("Upload") or k:find("Record")) then _G[c][k] = nop end end end
        end
        local SecSub = require("GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem")
        if SecSub then SecSub.ReportData = nop; SecSub.CheckCheat = retFalse; SecSub.ValidatePlayer = retTrue; SecSub.CollectData = nop; SecSub.SendToServer = nop end
    end)
end

local function InitializeClientFlowBypass()
    pcall(function()
        for _, name in ipairs({"ClientSecMrpcsFlow", "MrpcsFlow", "MrpcsData", "ClientCircleFlowSubsystem", "ClientKillFlowSubsystem", "ClientSecPlayerKillFlow"}) do
            local sub = package.loaded[name] or _G[name]
            if sub then for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Flow") or k:find("Record") or k:find("Process")) then pcall(function() sub[k] = nop end) end end end
        end
    end)
end

local function InitializeSwiftHawkBypass()
    pcall(function()
        for _, f in ipairs({"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}) do if _G[f] then _G[f] = nop end; if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = nop end end
        local sub = package.loaded["GameLua.Mod.BaseMod.Client.Security.SwiftHawkSubsystem"]
        if sub then sub.ReportData = nop; sub.SendReport = nop; sub.CollectTelemetry = nop end
    end)
end

local function InitializeCoronaLabBypass()
    pcall(function()
        if _G.CoronaLab then _G.CoronaLab.ReportData = nop; _G.CoronaLab.SendData = nop; _G.CoronaLab.CollectData = nop; _G.CoronaLab.Telemetry = nop end
        local sub = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr"):Get("CoronaLabSubsystem")
        if sub then sub.ReportData = nop; sub.SendToServer = nop; sub.CollectTelemetry = nop; sub.StopCollection = nop end
    end)
end

local function InitializeModifierExceptionBypass()
    pcall(function()
        if _G.bReportedModifierException then _G.bReportedModifierException = false end
        local sub = require("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem")
        if sub then sub.ReportException = nop; sub.CheckModifier = retTrue; sub.ValidateModifier = retTrue; sub.ReportModifierError = nop end
    end)
end

local function InitializeSimulateCharacterLocationBypass()
    pcall(function()
        local sub = require("GameLua.Mod.BaseMod.Gameplay.Simulate.SimulateCharacterSubsystem")
        if sub then sub.ReportLocation = nop; sub.SendLocationData = nop; sub.VerifyLocation = retTrue end
    end)
end

local function InitializeShootVerificationBypass()
    pcall(function()
        local sub = require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
        if sub then sub.OnShootVerifyFailed = nop; sub.SendVerifyData = nop; sub.ReportBulletHit = nop; sub.UploadHitInfo = nop; sub.VerifyShot = retTrue end
        if _G.BulletHitInfoUploadData then _G.BulletHitInfoUploadData.Report = nop; _G.BulletHitInfoUploadData.Send = nop; _G.BulletHitInfoUploadData.Upload = nop end
    end)
end

local function InitializeNetworkPacketBlock()
    pcall(function()
        if NetUtil and NetUtil.SendPacket then
            local orig = NetUtil.SendPacket
            local blocked = {
                ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
                ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1, ["ReportPlayerMoveRoute"]=1, ["ReportPlayerPosition"]=1, ["ReportSecVehicleMoveFlow"]=1,
                ["report_parachute_data"]=1, ["on_tss_sdk_anti_data"]=1, ["ReportAimFlow"]=1, ["ReportHitFlow"]=1, ["ReportCircleFlow"]=1, ["report_players_ping"]=1,
                ["report_player_ip"]=1, ["report_net_saturate"]=1, ["report_speed_hack"]=1, ["report_wall_hack"]=1, ["report_aim_bot"]=1, ["report_esp_usage"]=1,
                ["report_modded_files"]=1, ["detect_cheat"]=1, ["ban_player"]=1, ["client_anti_cheat_report"]=1,
                ["ClientSecMrpcsFlow"]=1, ["MrpcsData"]=1, ["CheckReportSecAttackFlow"]=1, ["CheckReportSecAttackFlowWithAttackFlow"]=1, ["RPC_ClientCoronaLab"]=1,
                ["CoronaLabReport"]=1, ["CoronaLabData"]=1, ["PlayerSecurityInfo"]=1, ["ReportSecurityInfo"]=1, ["SendSecurityData"]=1, ["ClientCircleFlow"]=1,
                ["IsEnableReportMrpcsInCircleFlow"]=1, ["IsEnableReportMrpcsInPartCircleFlow"]=1, ["bReportedModifierException"]=1,
                ["ReportModifierException"]=1, ["RPC_Server_ReportSimulateCharacterLocation"]=1, ["ReportSimulateCharacterLocation"]=1, ["RPC_Client_ShootVertifyRes"]=1,
                ["BulletHitInfoUploadData"]=1, ["ShootVerifyFailed"]=1, ["report_unrealnet_exception"]=1, ["tss_sdk_report"]=1, ["SwiftHawk"]=1, ["ClientSwiftHawk"]=1, ["ClientSwiftHawkWithParams"]=1, ["SwiftHawkReport"]=1, ["SwiftHawkData"]=1,
                ["AntiCheatReport"]=1, ["CheatDetection"]=1, ["ViolationReport"]=1, ["SecurityViolation"]=1, ["IntegrityCheck"]=1, ["SignatureVerify"]=1
            }
            NetUtil.SendPacket = function(packetName, ...) if blocked[packetName] then return nil end; return orig(packetName, ...) end
            NetUtil.IsBypassed = true
        end
        if _G.SendRPC then
            local origRPC = _G.SendRPC
            local blockedRPC = {"RPC_Server_ClientSecMrpcsFlow", "RPC_Server_SwiftHawk", "RPC_Server_ClientSwiftHawkWithParams", "RPC_Server_ReportSimulateCharacterLocation", "RPC_Client_ShootVertifyRes", "RPC_ClientCoronaLab"}
            _G.SendRPC = function(rpcName, ...) for _, b in ipairs(blockedRPC) do if rpcName == b then return nil end end; return origRPC(rpcName, ...) end
        end
    end)
end

local function InitializeHiggsBosonBypass()
    pcall(function()
        local Higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            for _, m in ipairs({"ControlMHActive", "Tick", "OnTick", "MHActiveLogic", "TriggerAvatarCheck", "StartAvatarCheck", "ReportItemID", "ReceiveAnyDamage", "OnWeaponHitRecord", "ShowSecurityAlert", "ServerReportAvatar", "ClientReportNetAvatar", "SendHisarData", "ValidateSecurityData", "StaticShowSecurityAlertInDev", "RPC_Client_ShootVertifyRes", "RPC_Server_ReportSimulateCharacterLocation", "DisableHiggsBoson", "CheckMHActive", "ReportViolation", "ProcessSecurityEvent", "ValidatePlayer", "CheckIntegrity"}) do
                if Higgs[m] then Higgs[m] = nop end
            end
            Higgs.GetNetAvatarItemIDs = retEmpty; Higgs.GetCurWeaponSkinID = retZero; Higgs.IsMHActive = retFalse; Higgs.bMHActive = false; Higgs.bCallPreReplication = false
            if Higgs.BlackList then for k in pairs(Higgs.BlackList) do Higgs.BlackList[k] = nil end end
        end
        _G.BlackList = {}
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if pc.HiggsBoson then pc.HiggsBoson.bMHActive = false; pc.HiggsBoson.bCallPreReplication = false; if pc.HiggsBoson.ControlMHActive then pc.HiggsBoson:ControlMHActive(0) end end
            if pc.HiggsBosonComponent then pc.HiggsBosonComponent.bMHActive = false; pc.HiggsBosonComponent.bCallPreReplication = false; pc.HiggsBosonComponent:ControlMHActive(0) end
        end
    end)
end

local function InitializeAntiCheatHooks()
    pcall(function()
        local HBC = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HBC and HBC.StaticShowSecurityAlertInDev then HBC.StaticShowSecurityAlertInDev = nop end
    end)
    if _G.AvatarCheckCallback then
        _G.AvatarCheckCallback.StartAvatarCheck = nop; _G.AvatarCheckCallback.OnReportItemID = nop
        _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(PlayerController)
            if slua.isValid(PlayerController) and PlayerController.HiggsBosonComponent then PlayerController.HiggsBosonComponent:ControlMHActive(0); PlayerController.HiggsBosonComponent.bMHActive = false end
        end
    end
end

local function InitializeAntiReport()
    pcall(function()
        for _, path in ipairs({"GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem", "Client.Security.ClientReportPlayerSubsystem", "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem"}) do
            local sub = package.loaded[path]; if not sub then local s, r = pcall(require, path); if s and r then sub = r end end
            if sub then for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Record") or k:find("Send") or k:find("Upload") or k:find("Notify")) then pcall(function() sub[k] = nop end) end end end
        end
    end)
end

local function InitializeGameplayBypass()
    pcall(function()
        if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
        if _G.GameplayCallbacks.IsBypassed then return end
        local GC = _G.GameplayCallbacks
        local reports = {"ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData", "SendTssSdkAntiDataToLobby", "ReportEquipmentFlow", "ReportAimFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord", "OnDSConnectionSaturated", "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate", "SendClientStats", "SendServerAvgTickDelta", "ReportCircleFlow", "ClientSecMrpcsFlow", "SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams"}
        for _, f in ipairs(reports) do GC[f] = nop end
        GC.CheckReportSecAttackFlowWithAttackFlow = retFalse; GC.CheckReportSecAttackFlow = retFalse
        local origState = GC.OnDSPlayerStateChanged
        GC.OnDSPlayerStateChanged = function(UID, State, bPure, bSafe, Param)
            local s = State and string.lower(tostring(State)) or ""
            local blocked = {["cheatdetected"]=1, ["connectionlost"]=1, ["connectiontimeout"]=1, ["connectionexception"]=1, ["netdrivererror"]=1, ["banned"]=1, ["kicked"]=1, ["suspended"]=1, ["violationdetected"]=1, ["integrityfailure"]=1, ["securityviolation"]=1}
            if blocked[s] then return end
            if origState then pcall(origState, UID, State, bPure, bSafe, Param) end
        end
        GC.OnPlayerNetConnectionClosed = nop; GC.OnPlayerActorChannelError = nop; GC.OnPlayerRPCValidateFailed = nop; GC.OnPlayerSpectateException = nop; GC.OnShutdownAfterError = nop; GC.IsBypassed = true
    end)
end

local function InitializeKillAllSubsystems()
    pcall(function()
        local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if not subMgr then return end
        local toKill = {"CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient", "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem", "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem", "ClientDataStatistcsSubsystem", "AFKReportorSubsystem", "BehaviorScoreSubsystem", "FileCheckSubsystem", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem", "AvatarExceptionSubsystem", "GameReportSubsystem", "ClientSecMrpcsFlowSubsystem", "MrpcsFlowSubsystem", "CircleFlowSubsystem", "SwiftHawkSubsystem", "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem", "MD5CheckSubsystem", "PakVerifySubsystem"}
        for _, name in ipairs(toKill) do
            local sub = subMgr:Get(name)
            if sub then
                for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload") or k:find("Verify") or k:find("Check") or k:find("Validate") or k:find("Scan") or k:find("Detect") or k:find("Collect") or k:find("Flow") or k:find("Heartbeat")) then pcall(function() sub[k] = nop end) end end
                if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
                if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
                if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
            end
        end
    end)
end

local function InitializeFinalProtection()
    pcall(function()
        for _, flag in ipairs({"ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY", "ENABLE_TELEMETRY", "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT", "ENABLE_PERFORMANCE_REPORT"}) do if _G[flag] then _G[flag] = false end end
        local origReq = require
        local blocked = {"HiggsBosonComponent", "PlayerSecurityInfoSubsystem", "CoronaLabSubsystem", "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "ShootVerifySubSystemClient", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem"}
        _G.require = function(m) for _, b in ipairs(blocked) do if m:find(b) then return {} end end; return origReq(m) end
    end)
end

local function InitializeOperationalStatsBypass()
    pcall(function()
        -- Lấy qua SubsystemMgr hoặc Global để đảm bảo 100% bắt được đích
        local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        local OperationalStatsSubsystem = (subMgr and subMgr:Get("OperationalStatsSubsystem")) or _G.OperationalStatsSubsystem
        
        if OperationalStatsSubsystem then
            OperationalStatsSubsystem.ReportOperationalStats = nop
            OperationalStatsSubsystem.AddOperationalStats = nop
            OperationalStatsSubsystem.HandleTouchBegin = nop
            OperationalStatsSubsystem.HandleTouchEnd = nop
            OperationalStatsSubsystem.OnInit = nop
            OperationalStatsSubsystem.HandleEnterFighting = nop
            OperationalStatsSubsystem.OnBattleResult = nop
            if OperationalStatsSubsystem.TimerHandle then
                pcall(function() OperationalStatsSubsystem:RemoveGameTimer(OperationalStatsSubsystem.TimerHandle) end)
                OperationalStatsSubsystem.TimerHandle = nil
            end
            OperationalStatsSubsystem.StatsData = {}
            print("[ULTIMATE BYPASS] OperationalStatsSubsystem blocked!")
        end
    end)
end

_G.StartBypass_VIP_v3 = function()
    pcall(function()
        print("[ULTIMATE BYPASS] Starting initialization...")
        InitializeSLUABypass()
        InitializeMD5Bypass()
        InitializeLogBlocker()
        InitializeScannerBlocker()
        InitializeReplayTelemetryBlocker()
        InitializeReportFlowBlocker()
        InitializePlayerSecurityBypass()
        InitializeClientFlowBypass()
        InitializeSwiftHawkBypass()
        InitializeCoronaLabBypass()
        InitializeModifierExceptionBypass()
        InitializeSimulateCharacterLocationBypass()
        InitializeShootVerificationBypass()
        InitializeNetworkPacketBlock()
        InitializeHiggsBosonBypass()
        InitializeAntiCheatHooks()
        InitializeAntiReport()
        InitializeGameplayBypass()
        InitializeKillAllSubsystems()
        InitializeOperationalStatsBypass() -- [NEW] BYPASS BÁO CÁO THỐNG KÊ (Operational Stats)
        InitializeFinalProtection()
        print("[ULTIMATE BYPASS] Complete - All Security Systems Disabled")
    end)
end

-- ========================================== 
-- HÀM QUẢN LÝ DỌN RÁC MAP MARK (CHỐNG LAG/HIỂN THỊ ẢO KHI ĐỊCH CHẾT)
-- ========================================== 
local function SafeAddMark(id, pos, z, str, size, actor)
    local mark = nil
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
            mark = InGameMarkTools.ClientAddMapMark(id, pos, z, str, size, actor)
            if mark then _G.LynceState.TrackedMarks[mark] = true end
        end
    end)
    return mark
end

local function SafeRemoveMark(mark)
    if not mark then return end
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.HideMapMark then
            InGameMarkTools.HideMapMark(mark)
        end
        if InGameMarkTools and InGameMarkTools.RemoveMapMark then
            InGameMarkTools.RemoveMapMark(mark)
        end
    end)
    _G.LynceState.TrackedMarks[mark] = nil
end

-- ========================================== 
-- TẠO ID DUY NHẤT VÀ VĨNH VIỄN CHO MỖI KẺ ĐỊCH (SỬA LỖI GIẬT LAG KHI SLUA TẠO WRAPPER MỚI)
-- ==========================================
local function GetSafeEnemyKey(enemy)
    if Valid(enemy) then
        if enemy.PlayerKey then return tostring(enemy.PlayerKey) end
        if type(enemy.GetUniqueID) == "function" then return tostring(enemy:GetUniqueID()) end
    end
    return tostring(enemy)
end

-- ========================================== 
-- KIỂM TRA PHÂN BIỆT AI (BOT) / REAL PLAYER - OPTIMIZED
-- ==========================================
local function CheckIsAI(pawn, markData)
    if markData.AK_IS_BOT ~= nil then return markData.AK_IS_BOT, true end
    
    local isAI = false
    local hasChecked = false
    pcall(function()
        if pawn.bIsAI == true or pawn.IsAI == true then isAI = true; hasChecked = true end
        if type(pawn.IsBot) == "function" and pawn:IsBot() then isAI = true; hasChecked = true end
        
        local pState = pawn.PlayerState or (type(pawn.GetPlayerState) == "function" and pawn:GetPlayerState())
        if Valid(pState) then
            hasChecked = true
            if pState.bIsABot == true or pState.bIsBot == true then isAI = true end
            if type(pState.IsBot) == "function" and pState:IsBot() then isAI = true end
        end
        
        if not isAI then
            local name = pawn.PlayerName or (type(pawn.GetPlayerName) == "function" and pawn:GetPlayerName()) or ""
            if name ~= "" and (name:find("Cobra") or name:find("Target") or name:find("bot_") or name:find("b_")) then
                isAI = true
                hasChecked = true
            end
        end
    end)
    if hasChecked then markData.AK_IS_BOT = isAI end
    return isAI, hasChecked
end

-- ========================================== 
-- KHỞI TẠO HOOKS AUTO HEAD SÁT THƯƠNG
-- ==========================================
function _G.InitializeAutoHeadHooks()
    pcall(function()
        local EAvatarDamagePosition = import("EAvatarDamagePosition")
        if not EAvatarDamagePosition then return end

        local modulesToHook = {
            "GameLua.Mod.BaseMod.Common.Weapon.ShootWeaponEntity",
            "GameLua.Logic.Weapon.ShootWeaponEntity"
        }
        
        for _, path in ipairs(modulesToHook) do
            local hitLogic = package.loaded[path]
            if hitLogic then
                local original_GetHitBodyType = hitLogic.GetHitBodyType
                hitLogic.GetHitBodyType = function(self, ImpactResult, InImpactVec)
                    if _G.LynceConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if original_GetHitBodyType then return original_GetHitBodyType(self, ImpactResult, InImpactVec) end
                end

                local original_GetHitBodyTypeByHitPos = hitLogic.GetHitBodyTypeByHitPos
                hitLogic.GetHitBodyTypeByHitPos = function(self, InImpactVec)
                    if _G.LynceConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if original_GetHitBodyTypeByHitPos then return original_GetHitBodyTypeByHitPos(self, InImpactVec) end
                end
            end
        end
    end)
end

_G.ApplyWeaponGlow = function(PlayerCharacter)
    pcall(function()
        local WeaponManager = PlayerCharacter:GetWeaponManager()
        if not slua.isValid(WeaponManager) then return end

        local isGlowEnabled = _G.LynceConfig.WeaponGlow
        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        local glowIntensity = 80.0 
        local thickness = _G.LynceState.CustomTextData.WeaponGlowThickness or 3
        local colorMode = _G.LynceState.CustomTextData.WeaponGlowColor or 5
        
        local r, g, b = 1.0, 1.0, 0.0
        if colorMode == 1 then r, g, b = 1.0, 0.0, 0.0
        elseif colorMode == 2 then r, g, b = 0.0, 1.0, 0.0
        elseif colorMode == 3 then r, g, b = 0.0, 0.0, 1.0
        elseif colorMode == 4 then r, g, b = 1.0, 1.0, 0.0
        elseif colorMode == 5 then 
            local time = os.clock() * 2.0
            r = (math.sin(time) + 1) / 2
            g = (math.sin(time + 2) + 1) / 2
            b = (math.sin(time + 4) + 1) / 2
        end

        local finalColor = LinearColorClass and LinearColorClass(r * glowIntensity, g * glowIntensity, b * glowIntensity, 1.0) or { R = r * 255 * glowIntensity, G = g * 255 * glowIntensity, B = b * 255 * glowIntensity, A = 255 }

        for slot = 1, 3 do
            local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(slot)
            if slua.isValid(Weapon) then
                local ok, meshComponent = pcall(function() return import("/Script/Engine.MeshComponent") end)
                if ok then
                    local ok2, components = pcall(function() return Weapon:GetComponentsByClass(meshComponent) end)
                    if ok2 and components then
                        local count = type(components.Num) == "function" and components:Num() or #components
                        for i = 1, count do
                            local comp = type(components.Get) == "function" and components:Get(i-1) or components[i]
                            if slua.isValid(comp) then
                                if isGlowEnabled then
                                    pcall(function()
                                        comp.UseScopeDistanceCulling = false
                                        comp.PrimitiveShadingStrategy = 1
                                        comp.ShadingRate = 6
                                        if comp.SetDrawIdeaOutline then
                                            comp:SetDrawIdeaOutline(true)
                                            if comp.OverrideIdeaOutlineColor then comp:OverrideIdeaOutlineColor(true, finalColor) end
                                            if comp.OverrideIdeaOutlineThickness then comp:OverrideIdeaOutlineThickness(true, thickness) end
                                        elseif comp.SetRenderCustomDepth then
                                            comp:SetRenderCustomDepth(true)
                                        end
                                    end)
                                else
                                    pcall(function()
                                        if comp.SetDrawIdeaOutline then comp:SetDrawIdeaOutline(false)
                                        elseif comp.SetRenderCustomDepth then comp:SetRenderCustomDepth(false) end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ========================================== 
-- HỆ THỐNG LƯU VÀ TẢI SETTING MENU VIP (TỰ ĐỘNG)
-- ========================================== 
local function GetConfigPaths(fileName)
    local paths = {
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/Paks/puffer_temp/" .. fileName,
        "/com.tencent.ig/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/com.vng.pubgmobile/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/com.pubg.krmobile/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/com.rekoo.pubgm/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/com.pubg.imobile/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "../../ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "../../../ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "../../../../ShadowTrackerExtra/Saved/Paks/" .. fileName,
        fileName
    }
    pcall(function()
        if os and os.getenv then
            local homeDir = os.getenv("HOME")
            if homeDir and homeDir ~= "" then
                table.insert(paths, 1, homeDir .. "/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName)
                table.insert(paths, 2, homeDir .. "/Documents/ShadowTrackerExtra/Saved/Paks/puffer_temp/" .. fileName)
            end
        end
    end)
    return paths
end

local ConfigFileName = "telegram:@zexgodx_settings.txt"
_G.LastConfigSaveStr = ""

-- HÀM LƯU CONFIG
_G.SaveModSettings = function()
    pcall(function()
        local data = "return {\nLynceConfig = {\n"
        for k, v in pairs(_G.LynceConfig or {}) do
            data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n"
        end
        data = data .. "},\nCustomTextData = {\n"
        if _G.LynceState and _G.LynceState.CustomTextData then
            for k, v in pairs(_G.LynceState.CustomTextData) do
                data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n"
            end
        end
        data = data .. "}\n}"
        
        -- Chống giật lag: Chỉ tiến hành ghi file nếu bạn có thay đổi cấu hình
        if data == _G.LastConfigSaveStr then return end
        _G.LastConfigSaveStr = data

        local paths = GetConfigPaths(ConfigFileName)
        for _, path in ipairs(paths) do
            local file = io.open(path, "w")
            if file then
                file:write(data)
                file:close()
                break
            end
        end
    end)
end

-- HÀM TẢI (ĐỌC) CONFIG
_G.LoadModSettings = function()
    pcall(function()
        local paths = GetConfigPaths(ConfigFileName)
        local content = nil
        for _, path in ipairs(paths) do
            local file = io.open(path, "r")
            if file then
                content = file:read("*a")
                file:close()
                break
            end
        end

        if content then
            local func = load(content)
            if func then
                local savedData = func()
                if savedData and type(savedData) == "table" then
                    if savedData.LynceConfig then
                        for k, v in pairs(savedData.LynceConfig) do
                            _G.LynceConfig[k] = v
                        end
                    end
                    if savedData.CustomTextData then
                        _G.LynceState.CustomTextData = _G.LynceState.CustomTextData or {}
                        for k, v in pairs(savedData.CustomTextData) do
                            _G.LynceState.CustomTextData[k] = v
                        end
                    end
                end
            end
        end
        -- Ghi nhớ cấu hình vừa tải
        _G.SaveModSettings() 
    end)
end

-- VÒNG LẶP KIỂM TRA ĐỂ LƯU CHẠY NGẦM RẤT NHẸ
local function AutoSaveLoop()
    pcall(function() if _G.SaveModSettings then _G.SaveModSettings() end end)
    pcall(function()
        local okTicker, ticker = pcall(require, "common.time_ticker") 
        if okTicker and ticker and ticker.AddTimerOnce then 
            ticker.AddTimerOnce(3.0, AutoSaveLoop) -- Cứ 3 giây check 1 lần
        end
    end)
end

-- KHỞI CHẠY LẦN ĐẦU TIÊN
if not _G.ModConfigLoaded then
    _G.LoadModSettings()
    AutoSaveLoop()
    _G.ModConfigLoaded = true
end

-- DƯ THỪA ĐỂ KHÔNG BỊ LỖI VÒNG LẶP CŨ CỦA BẠN
_G.ReadLiveConfig = function()
    if _G.SaveModSettings then _G.SaveModSettings() end
end

-- ========================================== 
-- HỆ THỐNG MENU VIP NATIVE (CHẠY TRỰC TIẾP TỪ SETTING GAME)
-- ========================================== 

function _G.InitModMenuTab()
    if _G.ModMenuInitialized then return end
    _G.ModMenuInitialized = true

    -- Hàm hỗ trợ dịch ngôn ngữ (Tự động chọn EN hoặc VN)
    local function T(vnText, enText)
        return _G.LynceLang == "EN" and enText or vnText
    end

    _G.LynceState.CustomTextData = _G.LynceState.CustomTextData or {
        OuterSpeed = 10, InnerSpeed = 10, OuterRecoil = 0, HRecoil = 0.3, VRecoil = 0.3, MagicHead = 1.0, MagicBody = 1.0, MagicLegs = 1.0, IpadViewFOV = 120,
        AimTouchHipPrio = 1, AimTouchHipBone = 1, AimTouchHipCond = 1, AimTouchHipSpeed = 50, AimTouchHipFOV = 30, AimTouchHipDist = 250,
        AimTouchSGPrio = 1, AimTouchSGBone = 2, AimTouchSGCond = 1, AimTouchSGSpeed = 80, AimTouchSGFOV = 40, AimTouchSGDist = 30,
        AimTouchScopePrio = 1, AimTouchScopeBone = 2, AimTouchScopeCond = 1, AimTouchScopeSpeed = 40, AimTouchScopeFOV = 20, AimTouchScopeDist = 300, AimTouchScopePred = 0, AimTouchScopeRecoil = 0,
        AimTouchSniperPrio = 1, AimTouchSniperBone = 1, AimTouchSniperCond = 2, AimTouchSniperSpeed = 30, AimTouchSniperFOV = 20, AimTouchSniperDist = 400, AimTouchSniperPred = 0,
        BugManRatio = 133,
        WeaponGlowThickness = 3, WeaponGlowColor = 5,
        ColorV3Hidden = 1, ColorV3Visible = 2, ColorV3Thickness = 4, OutlineColor = 4
    }

    local LocUtil = _G.LocUtil
    if not LocUtil and package.loaded["client.common.LocUtil"] then
        LocUtil = require("client.common.LocUtil")
    end
    
    -- 1. TẠO BẢNG ID ẢO VỚI TEXT MỚI (Hỗ trợ 2 ngôn ngữ)
    local FakeTextMap = {
        [999000] = T("GOD MENU BY @zexygodx"),
        [999001] = T("ESP V1"),
        [999002] = T("ROCOIL & AIMBOT ORI"),
        [999003] = T("AIMTOUCH CUSTUM"),
        [999004] = T("EXTRA FITUR & SUPORT")
    }

    -- 2. HOOK TOÀN BỘ HÀM ĐỌC TEXT CỦA GAME (FIX LỖI TRỐNG THANH TAB)
    if LocUtil and not LocUtil._IsModMenuHooked_V2 then
        local hookFuncs = {"GetLocalizeResStr", "GetText", "GetTextByID", "GetLocalText", "GetLocalizeStr"}
        for _, funcName in ipairs(hookFuncs) do
            if LocUtil[funcName] then
                local old_func = LocUtil[funcName]
                LocUtil[funcName] = function(id)
                    if FakeTextMap[id] then
                        return FakeTextMap[id]
                    end
                    if type(id) == "string" and not tonumber(id) then
                        return id
                    end
                    if old_func then
                        return old_func(id)
                    end
                    return ""
                end
            end
        end
        LocUtil._IsModMenuHooked_V2 = true
    end

    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    
    if not SettingPageDefine.ModMenu then
        local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
        
local StackESP = {
    { Key = "ModMenu_ESP1", UI = AliasMap.Switcher, Text = T("ESP Tipe 1 (Peringatan 360-Darah-Nama)", "ESP Type 1 (360 Alert-HP-Name)"), GetFunc = function() return _G.LynceConfig.EspVip end, SetFunc = function(c,v) _G.LynceConfig.EspVip = v return true end },
    { Key = "ModMenu_ESP2", UI = AliasMap.Switcher, Text = T("ESP Tipe 2 (Jarak Meter)", "ESP Type 2 (Distance Meter)"), GetFunc = function() return _G.LynceConfig.EspDistance end, SetFunc = function(c,v) _G.LynceConfig.EspDistance = v return true end },
    
    { Key = "ModMenu_ESP3_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ ESP Tipe 3 (Darah Vertikal & Nama)", "▶ ESP Type 3 (Vertical HP & Name)"), ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.EspVipPro end, SetFunc = function(c,v) _G.LynceConfig.EspVipPro = v return true end },
    { Key = "ModMenu_ESP3_Name", UI = AliasMap.Switcher, Text = T("   Tampilkan Nama Pemain", "   Show Player Name"), ExpandHandle = "ModMenu_ESP3_Ex", GetFunc = function() return _G.LynceConfig.Esp3ShowName end, SetFunc = function(c,v) _G.LynceConfig.Esp3ShowName = v return true end },
    { Key = "ModMenu_ESP3_HP", UI = AliasMap.Switcher, Text = T("   Tampilkan Bar Darah Vertikal", "   Show Vertical HP Bar"), ExpandHandle = "ModMenu_ESP3_Ex", GetFunc = function() return _G.LynceConfig.Esp3ShowHP end, SetFunc = function(c,v) _G.LynceConfig.Esp3ShowHP = v return true end },
    
    { Key = "ModMenu_ESP4", UI = AliasMap.Switcher, Text = T("ESP Tipe 4 (Radar 360)", "ESP Type 4 (Radar 360)"), GetFunc = function() return _G.LynceConfig.EspRadar end, SetFunc = function(c,v) _G.LynceConfig.EspRadar = v return true end },
    { Key = "ModMenu_ESP5", UI = AliasMap.Switcher, Text = T("ESP Tipe 5 (Kotak)", "ESP Type 5 (Box ESP)"), GetFunc = function() return _G.LynceConfig.EspLoai5 end, SetFunc = function(c,v) _G.LynceConfig.EspLoai5 = v return true end },
    { Key = "ModMenu_ESP6", UI = AliasMap.Switcher, Text = T("ESP Tipe 6 (Kerangka)", "ESP Type 6 (Skeleton)"), GetFunc = function() return _G.LynceConfig.EspLoai6 end, SetFunc = function(c,v) _G.LynceConfig.EspLoai6 = v return true end },
    { Key = "ModMenu_ESP7_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ ESP Tipe 7 (Info Detail)", "▶ ESP Type 7 (Detail Info)"), ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.EspLoai7 end, SetFunc = function(c,v) _G.LynceConfig.EspLoai7 = v return true end },
    { Key = "ModMenu_ESP7_SoLuong", UI = AliasMap.Switcher, Text = T("   Tampilkan Jumlah Musuh di Sekitar", "   Show Enemies Count Around"), ExpandHandle = "ModMenu_ESP7_Ex", GetFunc = function() return _G.LynceConfig.Esp7_SoLuong end, SetFunc = function(c,v) _G.LynceConfig.Esp7_SoLuong = v return true end },
    { Key = "ModMenu_ESP7_VuKhi", UI = AliasMap.Switcher, Text = T("   Tampilkan Senjata Musuh", "   Show Enemy Weapon"), ExpandHandle = "ModMenu_ESP7_Ex", GetFunc = function() return _G.LynceConfig.Esp7_VuKhi end, SetFunc = function(c,v) _G.LynceConfig.Esp7_VuKhi = v return true end },
    { Key = "ModMenu_ESP7_TuThe", UI = AliasMap.Switcher, Text = T("   Tampilkan Posisi (Berdiri/Jongkok/Telentang)", "   Show Posture (Stand/Crouch/Prone)"), ExpandHandle = "ModMenu_ESP7_Ex", GetFunc = function() return _G.LynceConfig.Esp7_TuThe end, SetFunc = function(c,v) _G.LynceConfig.Esp7_TuThe = v return true end },
    { Key = "ModMenu_ESP8", UI = AliasMap.Switcher, Text = T("ESP Tipe 8 (Bar Darah di Kepala)", "ESP Type 8 (Head HP Bar)"), GetFunc = function() return _G.LynceConfig.EspLoai8 end, SetFunc = function(c,v) _G.LynceConfig.EspLoai8 = v return true end },
    
    -- ==========================================
    -- ⭐ ESP NAME (VISCEK) - TITLE SWITCHER
    -- ==========================================
    { Key = "ModMenu_ESPName_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ ESP NAME (VISCEK)", "▶ ESP NAME (VISCEK)"), ExpandIndex = 0, GetFunc = function() 
        if not _G.LynceConfig then _G.LynceConfig = {} end
        if _G.LynceConfig.EspName == nil then _G.LynceConfig.EspName = false end
        return _G.LynceConfig.EspName 
    end, SetFunc = function(c,v) 
        if not _G.LynceConfig then _G.LynceConfig = {} end
        _G.LynceConfig.EspName = v 
        return true 
    end },
    
    -- ==========================================
    -- ⭐ WARNA TERLIHAT - SWITCHER
    -- ==========================================
    { Key = "ModMenu_ESPName_Color", UI = AliasMap.Switcher, Text = T("   Warna Terlihat (7 Warna)", "   Visible Color (7 Colors)"), ExpandHandle = "ModMenu_ESPName_Ex", SwitcherText = {"Merah","Putih","Kuning","Hijau","Cyan","Biru","Ungu"}, SwitcherValue = {1,2,3,4,5,6,7}, GetFunc = function() 
        if not _G.ColorConfig then _G.ColorConfig = {} end
        return _G.ColorConfig.VisibleColor or 4 
    end, SetFunc = function(c,v) 
        if not _G.ColorConfig then _G.ColorConfig = {} end
        local val = math.floor(v+0.5)
        if val < 1 then val = 1 end
        if val > 7 then val = 7 end
        _G.ColorConfig.VisibleColor = val 
        return true 
    end },
    
    -- ==========================================
    -- ⭐ WARNA TERSEMBUNYI - SWITCHER
    -- ==========================================
    { Key = "ModMenu_ESPName_Invisible", UI = AliasMap.Switcher, Text = T("   Warna Tersembunyi (7 Warna)", "   Hidden Color (7 Colors)"), ExpandHandle = "ModMenu_ESPName_Ex", SwitcherText = {"Merah","Putih","Kuning","Hijau","Cyan","Biru","Ungu"}, SwitcherValue = {1,2,3,4,5,6,7}, GetFunc = function() 
        if not _G.ColorConfig then _G.ColorConfig = {} end
        return _G.ColorConfig.InvisibleColor or 1 
    end, SetFunc = function(c,v) 
        if not _G.ColorConfig then _G.ColorConfig = {} end
        local val = math.floor(v+0.5)
        if val < 1 then val = 1 end
        if val > 7 then val = 7 end
        _G.ColorConfig.InvisibleColor = val 
        return true 
    end },
    
    -- ==========================================
    -- ⭐ KECERAHAN
    -- ==========================================
    { Key = "ModMenu_ESPName_Brightness", UI = AliasMap.Slider, Text = T("   Kecerahan Warna (1-100)", "   Brightness (1-100)"), ExpandHandle = "ModMenu_ESPName_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() 
        if not _G.ColorConfig then _G.ColorConfig = {} end
        if _G.ColorConfig.Brightness == nil then _G.ColorConfig.Brightness = 1 end
        return _G.ColorConfig.Brightness 
    end, SetFunc = function(c,v) 
        if not _G.ColorConfig then _G.ColorConfig = {} end
        local val = math.floor(v+0.5)
        if val < 1 then val = 1 end
        if val > 100 then val = 100 end
        _G.ColorConfig.Brightness = val 
        return true 
    end },
    
    { Key = "ModMenu_ESPBom_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Peringatan & Pelacakan Bom", "▶ Grenade Warning & Tracker"), ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.EspBomMaster end, SetFunc = function(c,v) _G.LynceConfig.EspBomMaster = v return true end },
    { Key = "ModMenu_ESPItemBom", UI = AliasMap.Switcher, Text = T("   Lacak Item Bom di Tanah", "   Show Grenades On Ground"), ExpandHandle = "ModMenu_ESPBom_Ex", GetFunc = function() return _G.LynceConfig.EspItemBom end, SetFunc = function(c,v) _G.LynceConfig.EspItemBom = v return true end },
    { Key = "ModMenu_ESPActiveBom", UI = AliasMap.Switcher, Text = T("   Peringatan Musuh Memegang & Melempar Bom", "   Active Grenade Warning"), ExpandHandle = "ModMenu_ESPBom_Ex", GetFunc = function() return _G.LynceConfig.EspActiveBom end, SetFunc = function(c,v) _G.LynceConfig.EspActiveBom = v return true end },
    
    { Key = "ModMenu_EspAimWarning_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Peringatan Musuh Mengaim", "▶ Enemy Aim Warning"), ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.EspAimWarning end, SetFunc = function(c,v) _G.LynceConfig.EspAimWarning = v return true end },
    { Key = "ModMenu_EspAimWarning_Vis", UI = AliasMap.Switcher, Text = T("   Cek Dinding (Indikator saat terlihat)", "   Visibility Check"), ExpandHandle = "ModMenu_EspAimWarning_Ex", GetFunc = function() return _G.LynceConfig.EspAimWarningVisCheck end, SetFunc = function(c,v) _G.LynceConfig.EspAimWarningVisCheck = v return true end },
    
    { Key = "ModMenu_ESPVehicle_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ ESP Pelacakan Kendaraan", "▶ Vehicle ESP"), ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.EspVehicle end, SetFunc = function(c,v) _G.LynceConfig.EspVehicle = v return true end },
    { Key = "ModMenu_ESPVeh_Dacia", UI = AliasMap.Switcher, Text = T("   Tampilkan Mobil (Dacia)", "   Show Dacia"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return _G.LynceConfig.EspVeh_Dacia end, SetFunc = function(c,v) _G.LynceConfig.EspVeh_Dacia = v return true end },
    { Key = "ModMenu_ESPVeh_UAZ", UI = AliasMap.Switcher, Text = T("   Tampilkan Jeep (UAZ)", "   Show UAZ"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return _G.LynceConfig.EspVeh_UAZ end, SetFunc = function(c,v) _G.LynceConfig.EspVeh_UAZ = v return true end },
    { Key = "ModMenu_ESPVeh_Buggy", UI = AliasMap.Switcher, Text = T("   Tampilkan Buggy", "   Show Buggy"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return _G.LynceConfig.EspVeh_Buggy end, SetFunc = function(c,v) _G.LynceConfig.EspVeh_Buggy = v return true end },
    { Key = "ModMenu_ESPVeh_Coupe", UI = AliasMap.Switcher, Text = T("   Tampilkan Mobil Sport (Coupe RB)", "   Show Coupe RB"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return _G.LynceConfig.EspVeh_Coupe end, SetFunc = function(c,v) _G.LynceConfig.EspVeh_Coupe = v return true end },
    { Key = "ModMenu_ESPVeh_Mirado", UI = AliasMap.Switcher, Text = T("   Tampilkan Mirado", "   Show Mirado"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return _G.LynceConfig.EspVeh_Mirado end, SetFunc = function(c,v) _G.LynceConfig.EspVeh_Mirado = v return true end },
    { Key = "ModMenu_ESPVeh_Motor", UI = AliasMap.Switcher, Text = T("   Tampilkan Motor (Motor/Scooter)", "   Show Motorcycles"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return _G.LynceConfig.EspVeh_Motor end, SetFunc = function(c,v) _G.LynceConfig.EspVeh_Motor = v return true end },
    { Key = "ModMenu_ESPVeh_Other", UI = AliasMap.Switcher, Text = T("   Tampilkan Lainnya (Perahu/BRDM...)", "   Show Others (Boat/BRDM)"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return _G.LynceConfig.EspVeh_Other end, SetFunc = function(c,v) _G.LynceConfig.EspVeh_Other = v return true end },
    
    { Key = "ModMenu_ESPAntenna", UI = AliasMap.Switcher, Text = T("ESP Antena (Tiang)", "Antenna ESP"), GetFunc = function() return _G.LynceConfig.EspAntenna end, SetFunc = function(c,v) _G.LynceConfig.EspAntenna = v return true end },
    { Key = "ModMenu_ESPOutline_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ ESP Garis Luar Musuh (HDR cerah)", "▶ Outline ESP (HDR supported)"), ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.EspOutline end, SetFunc = function(c,v) _G.LynceConfig.EspOutline = v return true end },
    { Key = "ModMenu_ESPOutline_Color", UI = AliasMap.Slider, Text = T("   Warna Garis (1:Merah 2:Hijau 3:Biru 4:Kuning 5:Ungu 6:Putih)", "   Color (1:Red 2:Grn 3:Blu 4:Ylw 5:Pur 6:Wht)"), ExpandHandle = "ModMenu_ESPOutline_Ex", MinValue = 1, MaxValue = 6, GetFunc = function() return _G.LynceState.CustomTextData.OutlineColor or 4 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.OutlineColor = v return true end },
    { Key = "ModMenu_ESPOutline_Thickness", UI = AliasMap.Slider, Text = T("   Ketebalan Garis", "   Outline Thickness"), ExpandHandle = "ModMenu_ESPOutline_Ex", MinValue = 1, MaxValue = 20, min = 1, max = 20, GetFunc = function() return _G.LynceConfig.OutlineThickness end, SetFunc = function(c,v) _G.LynceConfig.OutlineThickness = v return true end }
}


local StackAimbot = {
    -- ============================================================
    -- AIMBOT JARAK JAUH
    -- ============================================================
    { 
        Key = "ModMenu_Aimbot_Ex", 
        UI = AliasMap.TitleSwitcher, 
        Text = T("▶ Aimbot Jarak Jauh Kustom", "▶ Custom Long Range Aimbot"), 
        ExpandIndex = 0, 
        GetFunc = function() return _G.LynceConfig.CustomAimbot end, 
        SetFunc = function(c,v) _G.LynceConfig.CustomAimbot = v return true end 
    },
    { 
        Key = "ModMenu_Aimbot_Speed", 
        UI = AliasMap.Slider, 
        Text = T("   Kecepatan Aimbot Jarak Jauh", "   Long Range Speed"), 
        ExpandHandle = "ModMenu_Aimbot_Ex", 
        MinValue = 1, MaxValue = 100, min = 1, max = 100, 
        GetFunc = function() return _G.LynceState.CustomTextData.OuterSpeed end, 
        SetFunc = function(c,v) _G.LynceState.CustomTextData.OuterSpeed = v return true end 
    },
    { 
        Key = "ModMenu_Aimbot_Recoil", 
        UI = AliasMap.Slider, 
        Text = T("   Kompensasi Recoil", "   Recoil Compensation"), 
        ExpandHandle = "ModMenu_Aimbot_Ex", 
        MinValue = 0, MaxValue = 50, min = 0, max = 50, 
        GetFunc = function() return _G.LynceState.CustomTextData.OuterRecoil or 0 end, 
        SetFunc = function(c,v) _G.LynceState.CustomTextData.OuterRecoil = v return true end 
    },

    -- ============================================================
    -- AIMBOT JARAK DEKAT
    -- ============================================================
    { 
        Key = "ModMenu_AimbotClose_Ex", 
        UI = AliasMap.TitleSwitcher, 
        Text = T("▶ Aimbot Jarak Dekat Kustom", "▶ Custom Close Range Aimbot"), 
        ExpandIndex = 0, 
        GetFunc = function() return _G.LynceConfig.CustomAimbotClose end, 
        SetFunc = function(c,v) _G.LynceConfig.CustomAimbotClose = v return true end 
    },
    { 
        Key = "ModMenu_AimbotClose_Speed", 
        UI = AliasMap.Slider, 
        Text = T("   Kecepatan Aimbot Jarak Dekat", "   Close Range Speed"), 
        ExpandHandle = "ModMenu_AimbotClose_Ex", 
        MinValue = 1, MaxValue = 100, min = 1, max = 100, 
        GetFunc = function() return _G.LynceState.CustomTextData.InnerSpeed end, 
        SetFunc = function(c,v) _G.LynceState.CustomTextData.InnerSpeed = v return true end 
    },

    -- ============================================================
    -- PELURU AJAIB (MAGIC BULLET)
    -- ============================================================
  --  { 
  --      Key = "ModMenu_Magic_Ex", 
 --       UI = AliasMap.TitleSwitcher, 
  --      Text = T("▶ Peluru Ajaib Kustom", "▶ Custom Magic Bullet"), 
  --      ExpandIndex = 0, 
  --      GetFunc = function() return _G.LynceConfig.CustomMagicBullet end, 
  --      SetFunc = function(c,v) _G.LynceConfig.CustomMagicBullet = v return true end 
--    },
  --  { 
  --      Key = "ModMenu_Magic_Head", 
 --       UI = AliasMap.Slider, 
  --      Text = T("   Damage Kepala (0.0 - 5.0)", "   Head Damage (0.0 - 5.0)"), 
  --      ExpandHandle = "ModMenu_Magic_Ex", 
   --     MinValue = 0, MaxValue = 100, min = 0, max = 100, 
   --     GetFunc = function() return math.floor(((_G.LynceState.CustomTextData.MagicHead or 1.0) / 5.0) * 100 + 0.5) end, 
    --    SetFunc = function(c,v) _G.LynceState.CustomTextData.MagicHead = (v / 100.0) * 5.0 return true end 
  --  },
 --   { 
  --      Key = "ModMenu_Magic_Body", 
  --      UI = AliasMap.Slider, 
  --      Text = T("   Damage Badan (0.0 - 5.0)", "   Body Damage (0.0 - 5.0)"), 
 --       ExpandHandle = "ModMenu_Magic_Ex", 
  --      MinValue = 0, MaxValue = 100, min = 0, max = 100, 
 --       GetFunc = function() return math.floor(((_G.LynceState.CustomTextData.MagicBody or 1.0) / 5.0) * 100 + 0.5) end, 
  --      SetFunc = function(c,v) _G.LynceState.CustomTextData.MagicBody = (v / 100.0) * 5.0 return true end 
 --   },
--    { 
  --      Key = "ModMenu_Magic_Legs", 
 --       UI = AliasMap.Slider, 
 --       Text = T("   Damage Kaki (0.0 - 5.0)", "   Legs Damage (0.0 - 5.0)"), 
  --      ExpandHandle = "ModMenu_Magic_Ex", 
  --      MinValue = 0, MaxValue = 100, min = 0, max = 100, 
   --     GetFunc = function() return math.floor(((_G.LynceState.CustomTextData.MagicLegs or 1.0) / 5.0) * 100 + 0.5) end, 
   --     SetFunc = function(c,v) _G.LynceState.CustomTextData.MagicLegs = (v / 100.0) * 5.0 return true end 
 --   },

    -- ============================================================
    -- REDUKSI RECOIL
    -- ============================================================
    { 
        Key = "ModMenu_HRecoil_Ex", 
        UI = AliasMap.TitleSwitcher, 
        Text = T("▶ Kurangi Recoil Horizontal (Drop senjata)", "▶ Less Horizontal Recoil (Drop/Pick weapon)"), 
        ExpandIndex = 0, 
        GetFunc = function() return _G.LynceConfig.CustomHRecoil end, 
        SetFunc = function(c,v) _G.LynceConfig.CustomHRecoil = v return true end 
    },
    { 
        Key = "ModMenu_HRecoil_Val", 
        UI = AliasMap.Slider, 
        Text = T("   Nilai Recoil Horizontal", "   Horizontal Recoil Value"), 
        ExpandHandle = "ModMenu_HRecoil_Ex", 
        MinValue = 0, MaxValue = 100, min = 0, max = 100, 
        GetFunc = function() return math.floor((((_G.LynceState.CustomTextData.HRecoil or 0.3) - 0.3) / 4.7) * 100 + 0.5) end, 
        SetFunc = function(c,v) _G.LynceState.CustomTextData.HRecoil = 0.3 + (v / 100.0) * 4.7 return true end 
    },

    { 
        Key = "ModMenu_VRecoil_Ex", 
        UI = AliasMap.TitleSwitcher, 
        Text = T("▶ Kurangi Recoil Vertikal (Drop senjata)", "▶ Less Vertical Recoil (Drop/Pick weapon)"), 
        ExpandIndex = 0, 
        GetFunc = function() return _G.LynceConfig.CustomVRecoil end, 
        SetFunc = function(c,v) _G.LynceConfig.CustomVRecoil = v return true end 
    },
    { 
        Key = "ModMenu_VRecoil_Val", 
        UI = AliasMap.Slider, 
        Text = T("   Nilai Recoil Vertikal", "   Vertical Recoil Value"), 
        ExpandHandle = "ModMenu_VRecoil_Ex", 
        MinValue = 0, MaxValue = 100, min = 0, max = 100, 
        GetFunc = function() return math.floor((((_G.LynceState.CustomTextData.VRecoil or 0.3) - 0.3) / 4.7) * 100 + 0.5) end, 
        SetFunc = function(c,v) _G.LynceState.CustomTextData.VRecoil = 0.3 + (v / 100.0) * 4.7 return true end 
    },

    -- ============================================================
    -- FITUR LAINNYA
    -- ============================================================
    { 
        Key = "ModMenu_LessShake", 
        UI = AliasMap.Switcher, 
        Text = T("Kurangi Guncangan Scope", "Less Scope Shake"), 
        GetFunc = function() return _G.LynceConfig.LessShake end, 
        SetFunc = function(c,v) _G.LynceConfig.LessShake = v return true end 
    },
    { 
        Key = "ModMenu_Accuracy", 
        UI = AliasMap.Switcher, 
        Text = T("Akurasi 100%", "100% Accuracy"), 
        GetFunc = function() return _G.LynceConfig.Accuracy end, 
        SetFunc = function(c,v) _G.LynceConfig.Accuracy = v return true end 
    },
    { 
        Key = "ModMenu_Crosshair", 
        UI = AliasMap.Switcher, 
        Text = T("Crosshair Kecil", "Small Crosshair"), 
        GetFunc = function() return _G.LynceConfig.Crosshair end, 
        SetFunc = function(c,v) _G.LynceConfig.Crosshair = v return true end 
    },
    { 
        Key = "ModMenu_AutoHead", 
        UI = AliasMap.Switcher, 
        Text = T("Aimbot Kepala", "Aimbot Head"), 
        GetFunc = function() return _G.LynceConfig.AutoHead end, 
        SetFunc = function(c,v) _G.LynceConfig.AutoHead = v return true end 
    },
  --  { 
  --      Key = "ModMenu_GodMode", 
 --       UI = AliasMap.Switcher, 
--        Text = T("Mode Dewa (Tembak Super Cepat)", "God Mode (Fast Shoot)"), 
--        GetFunc = function() return _G.LynceConfig.GodMode end, 
--        SetFunc = function(c,v) _G.LynceConfig.GodMode = v return true end 
  --  },

    -- ============================================================
    -- 🎯 MORTAR AUTO AIM
    -- ============================================================
    { 
        Key = "ModMenu_Mortar_Ex", 
        UI = AliasMap.TitleSwitcher, 
        Text = T("MORTAR AUTO AIM (Auto Lock)", "MORTAR AUTO AIM (Auto Lock)"), 
        ExpandIndex = 0,
        GetFunc = function() 
            return _G.LynceConfig.MortarAim == true 
        end,
        SetFunc = function(c, v) 
            _G.LynceConfig.MortarAim = v == true
            if v then
                if _G.MortarAim then 
                    _G.MortarAim.Start() 
                elseif M.MortarAim then
                    M.MortarAim.Start()
                end
                print("[zexgod] 🎯 Mortar Aim ON")
            else
                if _G.MortarAim then 
                    _G.MortarAim.Stop() 
                elseif M.MortarAim then
                    M.MortarAim.Stop()
                end
                print("[zexgod] 🎯 Mortar Aim OFF")
            end
            return true 
        end 
    },

    -- Sub menu: Max Range
    { 
        Key = "ModMenu_Mortar_Range", 
        UI = AliasMap.Slider, 
        Text = T("   Jarak Maksimal (100-1000m)", "   Max Range (100-1000m)"),
        ExpandHandle = "ModMenu_Mortar_Ex",
        MinValue = 100, MaxValue = 1000, min = 100, max = 1000,
        GetFunc = function() 
            return _G.LynceState.CustomTextData.MortarMaxRange or 600 
        end,
        SetFunc = function(c, v) 
            _G.LynceState.CustomTextData.MortarMaxRange = math.floor(v + 0.5)
            if _G.LynceState.CustomTextData.MortarMaxRange < 100 then _G.LynceState.CustomTextData.MortarMaxRange = 100 end
            if _G.LynceState.CustomTextData.MortarMaxRange > 1000 then _G.LynceState.CustomTextData.MortarMaxRange = 1000 end
            print("[zexgod] Mortar Max Range = " .. tostring(_G.LynceState.CustomTextData.MortarMaxRange))
            return true 
        end 
    },

    -- Sub menu: FOV
    { 
        Key = "ModMenu_Mortar_FOV", 
        UI = AliasMap.Slider, 
        Text = T("   Radius FOV (5-100°)", "   FOV Radius (5-100°)"),
        ExpandHandle = "ModMenu_Mortar_Ex",
        MinValue = 5, MaxValue = 100, min = 5, max = 100,
        GetFunc = function() 
            return _G.LynceState.CustomTextData.MortarFOV or 40 
        end,
        SetFunc = function(c, v) 
            _G.LynceState.CustomTextData.MortarFOV = math.floor(v + 0.5)
            if _G.LynceState.CustomTextData.MortarFOV < 5 then _G.LynceState.CustomTextData.MortarFOV = 5 end
            if _G.LynceState.CustomTextData.MortarFOV > 100 then _G.LynceState.CustomTextData.MortarFOV = 100 end
            print("[zexgod] Mortar FOV = " .. tostring(_G.LynceState.CustomTextData.MortarFOV))
            return true 
        end 
    },

    -- Sub menu: Swipe Break
    { 
        Key = "ModMenu_Mortar_Swipe", 
        UI = AliasMap.Slider, 
        Text = T("   Sensitivitas Unlock (1-10°)", "   Swipe Break (1-10°)"),
        ExpandHandle = "ModMenu_Mortar_Ex",
        MinValue = 1, MaxValue = 10, min = 1, max = 10,
        GetFunc = function() 
            return _G.LynceState.CustomTextData.MortarSwipeBreak or 3.5 
        end,
        SetFunc = function(c, v) 
            _G.LynceState.CustomTextData.MortarSwipeBreak = v
            if _G.LynceState.CustomTextData.MortarSwipeBreak < 1 then _G.LynceState.CustomTextData.MortarSwipeBreak = 1 end
            if _G.LynceState.CustomTextData.MortarSwipeBreak > 10 then _G.LynceState.CustomTextData.MortarSwipeBreak = 10 end
            print("[zexgod] Mortar Swipe Break = " .. tostring(_G.LynceState.CustomTextData.MortarSwipeBreak))
            return true 
        end 
    },

    -- Sub menu: Pitch Weight
    { 
        Key = "ModMenu_Mortar_Pitch", 
        UI = AliasMap.Slider, 
        Text = T("   Bobot Pitch (0.1-2.0)", "   Pitch Weight (0.1-2.0)"),
        ExpandHandle = "ModMenu_Mortar_Ex",
        MinValue = 1, MaxValue = 20, min = 1, max = 20,
        GetFunc = function() 
            return math.floor((_G.LynceState.CustomTextData.MortarPitchWeight or 0.3) * 10)
        end,
        SetFunc = function(c, v) 
            _G.LynceState.CustomTextData.MortarPitchWeight = v / 10.0
            if _G.LynceState.CustomTextData.MortarPitchWeight < 0.1 then _G.LynceState.CustomTextData.MortarPitchWeight = 0.1 end
            if _G.LynceState.CustomTextData.MortarPitchWeight > 2.0 then _G.LynceState.CustomTextData.MortarPitchWeight = 2.0 end
            print("[zexgod] Mortar Pitch Weight = " .. tostring(_G.LynceState.CustomTextData.MortarPitchWeight))
            return true 
        end 
    }
}  -- ✅ TIDAK ADA KOMA DI SINI!

local StackAimbotV2 = {
    { Key = "ModMenu_AT_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Aktifkan Aimbot Roy & Kustom", "▶ Enable Custom Aimbot V2"), ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.AimTouchEnable end, SetFunc = function(c,v) _G.LynceConfig.AimTouchEnable = v return true end },
    
    -- HIPFIRE (PUTIH)
    { Key = "ModMenu_AT_Hip_Ex", UI = AliasMap.TitleSwitcher, Text = T("   ▶ Aimbot Hipfire", "   ▶ Hipfire Aimbot"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.AimTouchHipfire end, SetFunc = function(c,v) _G.LynceConfig.AimTouchHipfire = v return true end },
    { Key = "ModMenu_AT_Hip_IgKnock", UI = AliasMap.Switcher, Text = T("      Abaikan Musuh Knock", "      Ignore Knocked"), ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.LynceConfig.AimTouchHipIgKnock end, SetFunc = function(c,v) _G.LynceConfig.AimTouchHipIgKnock = v return true end },
    { Key = "ModMenu_AT_Hip_IgBot", UI = AliasMap.Switcher, Text = T("      Abaikan Bot", "      Ignore Bots"), ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.LynceConfig.AimTouchHipIgBot end, SetFunc = function(c,v) _G.LynceConfig.AimTouchHipIgBot = v return true end },
    { Key = "ModMenu_AT_Hip_Vis", UI = AliasMap.Switcher, Text = T("      Cek Dinding (VisCheck)", "      Visibility Check"), ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.LynceConfig.AimTouchHipVisCheck end, SetFunc = function(c,v) _G.LynceConfig.AimTouchHipVisCheck = v return true end },
    { Key = "ModMenu_AT_Hip_Prio", UI = AliasMap.Slider, Text = T("      Prioritas (1:Crosshair 2:Jarak 3:HP)", "      Priority (1:Crosshair 2:Distance 3:HP)"), ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchHipPrio or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.LynceState.CustomTextData.AimTouchHipPrio = val return true end },
    { Key = "ModMenu_AT_Hip_Bone", UI = AliasMap.Slider, Text = T("      Target (1:Kepala 2:Dada 3:Perut 4:Pinggang)", "      Bone (1:Head 2:Chest 3:Stomach 4:Pelvis)"), ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchHipBone or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.LynceState.CustomTextData.AimTouchHipBone = val return true end },
    { Key = "ModMenu_AT_Hip_Cond", UI = AliasMap.Slider, Text = T("      Kondisi (1:Saat tembak 2:Selalu)", "      Trigger (1:On Fire, 2:Always)"), ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 2, min = 1, max = 2, Min = 1, Max = 2, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchHipCond or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 2 then val = 2 end; _G.LynceState.CustomTextData.AimTouchHipCond = val return true end },
    { Key = "ModMenu_AT_Hip_Spd", UI = AliasMap.Slider, Text = T("      Kehalusan / Kecepatan (1-100)", "      Smoothness / Speed (1-100)"), ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchHipSpeed or 50 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchHipSpeed = v return true end },
    { Key = "ModMenu_AT_Hip_FOV", UI = AliasMap.Slider, Text = T("      Radius FOV (1-100)", "      FOV Radius (1-100)"), ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchHipFOV or 30 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchHipFOV = v return true end },
    { Key = "ModMenu_AT_Hip_Dist", UI = AliasMap.Slider, Text = T("      Jarak Maksimal (1-500m)", "      Distance Limit (1-500m)"), ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return math.floor((_G.LynceState.CustomTextData.AimTouchHipDist or 250) / 5) end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchHipDist = v * 5 return true end },

    -- AIMBOT SHOTGUN
    { Key = "ModMenu_AT_SG_Ex", UI = AliasMap.TitleSwitcher, Text = T("   ▶ Aimbot Shotgun", "   ▶ Shotgun Aimbot"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.AimTouchSG end, SetFunc = function(c,v) _G.LynceConfig.AimTouchSG = v return true end },
    { Key = "ModMenu_AT_SG_AutoFire", UI = AliasMap.Switcher, Text = T("      Tembak Otomatis", "      Auto Fire"), ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.LynceConfig.AimTouchSGAutoFire end, SetFunc = function(c,v) _G.LynceConfig.AimTouchSGAutoFire = v return true end },
    { Key = "ModMenu_AT_SG_IgKnock", UI = AliasMap.Switcher, Text = T("      Abaikan Musuh Knock", "      Ignore Knocked"), ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.LynceConfig.AimTouchSGIgKnock end, SetFunc = function(c,v) _G.LynceConfig.AimTouchSGIgKnock = v return true end },
    { Key = "ModMenu_AT_SG_IgBot", UI = AliasMap.Switcher, Text = T("      Abaikan Bot", "      Ignore Bots"), ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.LynceConfig.AimTouchSGIgBot end, SetFunc = function(c,v) _G.LynceConfig.AimTouchSGIgBot = v return true end },
    { Key = "ModMenu_AT_SG_Vis", UI = AliasMap.Switcher, Text = T("      Cek Dinding (VisCheck)", "      Visibility Check"), ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.LynceConfig.AimTouchSGVisCheck end, SetFunc = function(c,v) _G.LynceConfig.AimTouchSGVisCheck = v return true end },
    { Key = "ModMenu_AT_SG_Prio", UI = AliasMap.Slider, Text = T("      Prioritas (1:Crosshair 2:Jarak 3:HP)", "      Priority (1:Crosshair 2:Distance 3:HP)"), ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchSGPrio or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.LynceState.CustomTextData.AimTouchSGPrio = val return true end },
    { Key = "ModMenu_AT_SG_Bone", UI = AliasMap.Slider, Text = T("      Target (1:Kepala 2:Dada 3:Perut 4:Pinggang)", "      Bone (1:Head 2:Chest 3:Stomach 4:Pelvis)"), ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchSGBone or 2 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.LynceState.CustomTextData.AimTouchSGBone = val return true end },
    { Key = "ModMenu_AT_SG_Cond", UI = AliasMap.Slider, Text = T("      Kondisi (1:Saat tembak 2:Selalu)", "      Trigger (1:On Fire, 2:Always)"), ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 2, min = 1, max = 2, Min = 1, Max = 2, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchSGCond or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 2 then val = 2 end; _G.LynceState.CustomTextData.AimTouchSGCond = val return true end },
    { Key = "ModMenu_AT_SG_Spd", UI = AliasMap.Slider, Text = T("      Kehalusan / Kecepatan (1-100)", "      Smoothness / Speed (1-100)"), ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchSGSpeed or 80 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchSGSpeed = v return true end },
    { Key = "ModMenu_AT_SG_FOV", UI = AliasMap.Slider, Text = T("      Radius FOV (1-100)", "      FOV Radius (1-100)"), ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchSGFOV or 40 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchSGFOV = v return true end },
    { Key = "ModMenu_AT_SG_Dist", UI = AliasMap.Slider, Text = T("      Jarak Maksimal (1-100m)", "      Distance Limit (1-100m)"), ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchSGDist or 30 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchSGDist = v return true end },
    
    -- SCOPE ALL (SENJATA BIASA SAAT SCOPE)
    { Key = "ModMenu_AT_ScopeAll_Ex", UI = AliasMap.TitleSwitcher, Text = T("   ▶ Aimbot Saat Scope", "   ▶ Scope Aimbot"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.AimTouchScopeAll end, SetFunc = function(c,v) _G.LynceConfig.AimTouchScopeAll = v return true end },
    { Key = "ModMenu_AT_ScopeAll_IgKnock", UI = AliasMap.Switcher, Text = T("      Abaikan Musuh Knock", "      Ignore Knocked"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.LynceConfig.AimTouchScopeIgKnock end, SetFunc = function(c,v) _G.LynceConfig.AimTouchScopeIgKnock = v return true end },
    { Key = "ModMenu_AT_ScopeAll_IgBot", UI = AliasMap.Switcher, Text = T("      Abaikan Bot", "      Ignore Bots"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.LynceConfig.AimTouchScopeIgBot end, SetFunc = function(c,v) _G.LynceConfig.AimTouchScopeIgBot = v return true end },
    { Key = "ModMenu_AT_ScopeAll_Vis", UI = AliasMap.Switcher, Text = T("      Cek Dinding (VisCheck)", "      Visibility Check"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.LynceConfig.AimTouchScopeVisCheck end, SetFunc = function(c,v) _G.LynceConfig.AimTouchScopeVisCheck = v return true end },
    { Key = "ModMenu_AT_ScopeAll_Prio", UI = AliasMap.Slider, Text = T("      Prioritas (1:Crosshair 2:Jarak 3:HP)", "      Priority (1:Crosshair 2:Distance 3:HP)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchScopePrio or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.LynceState.CustomTextData.AimTouchScopePrio = val return true end },
    { Key = "ModMenu_AT_ScopeAll_Bone", UI = AliasMap.Slider, Text = T("      Target (1:Kepala 2:Dada 3:Perut 4:Pinggang)", "      Bone (1:Head 2:Chest 3:Stomach 4:Pelvis)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchScopeBone or 2 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.LynceState.CustomTextData.AimTouchScopeBone = val return true end },
    { Key = "ModMenu_AT_ScopeAll_Cond", UI = AliasMap.Slider, Text = T("      Kondisi (1:Saat tembak 2:Selalu)", "      Trigger (1:On Fire, 2:Always)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 2, min = 1, max = 2, Min = 1, Max = 2, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchScopeCond or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 2 then val = 2 end; _G.LynceState.CustomTextData.AimTouchScopeCond = val return true end },
    { Key = "ModMenu_AT_ScopeAll_Spd", UI = AliasMap.Slider, Text = T("      Kehalusan / Kecepatan (1-100)", "      Smoothness / Speed (1-100)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchScopeSpeed or 40 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchScopeSpeed = v return true end },
    { Key = "ModMenu_AT_ScopeAll_FOV", UI = AliasMap.Slider, Text = T("      Radius FOV (1-100)", "      FOV Radius (1-100)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchScopeFOV or 20 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchScopeFOV = v return true end },
    { Key = "ModMenu_AT_ScopeAll_Dist", UI = AliasMap.Slider, Text = T("      Jarak Maksimal (1-500m)", "      Distance Limit (1-500m)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return math.floor((_G.LynceState.CustomTextData.AimTouchScopeDist or 300) / 5) end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchScopeDist = v * 5 return true end },
    { Key = "ModMenu_AT_ScopeAll_Pred", UI = AliasMap.Slider, Text = T("      Prediksi Arah Lari", "      Prediction Value"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchScopePred or 0 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchScopePred = v return true end },
    { Key = "ModMenu_AT_ScopeAll_Recoil", UI = AliasMap.Slider, Text = T("      Kompensasi Recoil Otomatis", "      Auto Recoil Comp."), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 0, MaxValue = 50, min = 0, max = 50, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchScopeRecoil or 0 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchScopeRecoil = v return true end },

    -- SCOPE SNIPER (SNIPER/SCOPE)
    { Key = "ModMenu_AT_Sniper_Ex", UI = AliasMap.TitleSwitcher, Text = T("   ▶ Aimbot Sniper (Scope)", "   ▶ Sniper Aimbot"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.AimTouchScopeSniper end, SetFunc = function(c,v) _G.LynceConfig.AimTouchScopeSniper = v return true end },
    { Key = "ModMenu_AT_Sniper_IgKnock", UI = AliasMap.Switcher, Text = T("      Abaikan Musuh Knock", "      Ignore Knocked"), ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.LynceConfig.AimTouchSniperIgKnock end, SetFunc = function(c,v) _G.LynceConfig.AimTouchSniperIgKnock = v return true end },
    { Key = "ModMenu_AT_Sniper_IgBot", UI = AliasMap.Switcher, Text = T("      Abaikan Bot", "      Ignore Bots"), ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.LynceConfig.AimTouchSniperIgBot end, SetFunc = function(c,v) _G.LynceConfig.AimTouchSniperIgBot = v return true end },
    { Key = "ModMenu_AT_Sniper_Vis", UI = AliasMap.Switcher, Text = T("      Cek Dinding (VisCheck)", "      Visibility Check"), ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.LynceConfig.AimTouchSniperVisCheck end, SetFunc = function(c,v) _G.LynceConfig.AimTouchSniperVisCheck = v return true end },
    { Key = "ModMenu_AT_Sniper_Prio", UI = AliasMap.Slider, Text = T("      Prioritas (1:Crosshair 2:Jarak 3:HP)", "      Priority (1:Crosshair 2:Distance 3:HP)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchSniperPrio or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.LynceState.CustomTextData.AimTouchSniperPrio = val return true end },
    { Key = "ModMenu_AT_Sniper_Bone", UI = AliasMap.Slider, Text = T("      Target (1:Kepala 2:Dada 3:Perut 4:Pinggang)", "      Bone (1:Head 2:Chest 3:Stomach 4:Pelvis)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchSniperBone or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.LynceState.CustomTextData.AimTouchSniperBone = val return true end },
    { Key = "ModMenu_AT_Sniper_Cond", UI = AliasMap.Slider, Text = T("      Kondisi (1:Saat tembak 2:Selalu)", "      Trigger (1:On Fire, 2:Always)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 2, min = 1, max = 2, Min = 1, Max = 2, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchSniperCond or 2 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 2 then val = 2 end; _G.LynceState.CustomTextData.AimTouchSniperCond = val return true end },
    { Key = "ModMenu_AT_Sniper_Spd", UI = AliasMap.Slider, Text = T("      Kehalusan / Kecepatan (1-100)", "      Smoothness / Speed (1-100)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchSniperSpeed or 30 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchSniperSpeed = v return true end },
    { Key = "ModMenu_AT_Sniper_FOV", UI = AliasMap.Slider, Text = T("      Radius FOV (1-100)", "      FOV Radius (1-100)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchSniperFOV or 20 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchSniperFOV = v return true end },
    { Key = "ModMenu_AT_Sniper_Dist", UI = AliasMap.Slider, Text = T("      Jarak Maksimal (1-500m)", "      Distance Limit (1-500m)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return math.floor((_G.LynceState.CustomTextData.AimTouchSniperDist or 400) / 5) end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchSniperDist = v * 5 return true end },
    { Key = "ModMenu_AT_Sniper_Pred", UI = AliasMap.Slider, Text = T("      Prediksi Arah Lari (0-100)", "      Prediction Value (0-100)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return _G.LynceState.CustomTextData.AimTouchSniperPred or 0 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.AimTouchSniperPred = v return true end }
}


local StackCombat = {
    -- ... menu lain ...

    -- ============================================================
    -- WALLHACK RAINBOW
    -- ============================================================
    { 
        Key = "ModMenu_WallhackRainbow_Ex", 
        UI = AliasMap.TitleSwitcher, 
        Text = "Wallhack Rainbow (Tembus Dinding)", 
        ExpandIndex = 0,
        GetFunc = function() return _G.LynceConfig.WallhackRainbow or false end, 
        SetFunc = function(c,v) 
            -- SET VALUE
            _G.LynceConfig.WallhackRainbow = v
            
            if v then
                -- NYALAKAN WALLHACK
                print("🌈 WALLHACK: MENYALA")
                if not _G._wallhackRunning then
                    _G._wallhackRunning = true
                    _G.WH_RainbowTime = 0
                    _G.ResetWHCache()
                    -- PANGGIL LOOP
                    local function StartLoop()
                        pcall(_G.UpdateWallhackRainbow)
                        local okTicker, ticker = pcall(require, "common.time_ticker")
                        if okTicker and ticker and ticker.AddTimerOnce then
                            ticker.AddTimerOnce(0.5, StartLoop)
                        end
                    end
                    StartLoop()
                end
            else
                -- MATIKAN WALLHACK
                print("🌈 WALLHACK: MATI")
                _G.ResetWHCache()
                _G._wallhackRunning = false
            end
            
            return true 
        end 
    },
    
    { 
        Key = "ModMenu_RainbowSpeed", 
        UI = AliasMap.Slider, 
        Text = "   Kecepatan Rainbow (1-10)", 
        ExpandHandle = "ModMenu_WallhackRainbow_Ex",
        MinValue = 1, MaxValue = 10, min = 1, max = 10,
        GetFunc = function() return _G.WallhackColorConfig.RainbowSpeed or 3 end, 
        SetFunc = function(c,v) 
            _G.WallhackColorConfig.RainbowSpeed = v
            return true 
        end 
    },
    
    { 
        Key = "ModMenu_WH_Intensity", 
        UI = AliasMap.Slider, 
        Text = "   Intensitas Glow (1-100)", 
        ExpandHandle = "ModMenu_WallhackRainbow_Ex",
        MinValue = 1, MaxValue = 100, min = 1, max = 100,
        GetFunc = function() return _G.WallhackColorConfig.Intensity or 50 end, 
        SetFunc = function(c,v) 
            local val = math.floor(v + 0.5)
            if val < 1 then val = 1 end
            if val > 100 then val = 100 end
            _G.WallhackColorConfig.Intensity = val
            if _G.ResetWHCache then _G.ResetWHCache() end
            return true 
        end 
    },
    
    { 
        Key = "ModMenu_WH_SelfGlow", 
        UI = AliasMap.Switcher, 
        Text = "   Self Glow (Diri Sendiri)", 
        ExpandHandle = "ModMenu_WallhackRainbow_Ex",
        GetFunc = function() return _G.WallhackColorConfig.SelfGlow or false end, 
        SetFunc = function(c,v) 
            _G.WallhackColorConfig.SelfGlow = v
            if _G.ResetWHCache then _G.ResetWHCache() end
            return true 
        end 
    },


    { Key = "ModMenu_FakeHWID", UI = AliasMap.Switcher, Text = T("HWID Palsu (Anti-Ban Perangkat)", "Fake HWID (Anti-Ban)"), GetFunc = function() return _G.LynceConfig.FakeHWID end, SetFunc = function(c,v) _G.LynceConfig.FakeHWID = v return true end },
    { Key = "ModMenu_Ipad_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Tampilan iPad", "▶ Ipad View"), ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.IpadView end, SetFunc = function(c,v) _G.LynceConfig.IpadView = v return true end },
    { Key = "ModMenu_Ipad_FOV", UI = AliasMap.Slider, Text = T("   FOV Tampilan", "   FOV Value"), ExpandHandle = "ModMenu_Ipad_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return (_G.LynceState.CustomTextData.IpadViewFOV or 120) - 90 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.IpadViewFOV = 90 + v return true end },

    { Key = "ModMenu_BugMan_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Peregangan Layar (Karakter Gendut)", "▶ Screen Stretch (Fat Body)"), ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.BugManEnable end, SetFunc = function(c,v) _G.LynceConfig.BugManEnable = v return true end },
    { Key = "ModMenu_BugMan_Ratio", UI = AliasMap.Slider, Text = T("   Rasio Peregangan", "   Stretch Ratio"), ExpandHandle = "ModMenu_BugMan_Ex", MinValue = 110, MaxValue = 200, min = 110, max = 200, GetFunc = function() return _G.LynceState.CustomTextData.BugManRatio or 133 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.BugManRatio = v return true end },

    { Key = "ModMenu_165FPS", UI = AliasMap.Switcher, Text = T("Buka 165 FPS", "Unlock 165 FPS"), GetFunc = function() return _G.LynceConfig.UnlockFPS end, SetFunc = function(c,v) _G.LynceConfig.UnlockFPS = v; if v then _G.LynceState.GraphicsUnlocked = false end return true end },
    
    { Key = "ModMenu_Walhack", UI = AliasMap.Switcher, Text = T("Wallhack V1 (Lihat Tembus)", "Wallhack V1 (See through)"), GetFunc = function() return _G.LynceConfig.WallXuyenTuong end, SetFunc = function(c,v) _G.LynceConfig.WallXuyenTuong = v return true end },
    { Key = "ModMenu_ColorBodyV2", UI = AliasMap.Switcher, Text = T("Warna Musuh V2 (Chams Dasar)", "Chams V2 (Basic Color)"), GetFunc = function() return _G.LynceConfig.ColorBodyV2 end, SetFunc = function(c,v) _G.LynceConfig.ColorBodyV2 = v return true end },
    { Key = "ModMenu_ColorBodyNew", UI = AliasMap.Switcher, Text = T("WALL WARNA BARU (Merah/Hijau Terang)", "NEW ENGINE CHAMS (Red/Green)"), GetFunc = function() return _G.LynceConfig.ColorBodyNew end, SetFunc = function(c,v) _G.LynceConfig.ColorBodyNew = v return true end },
    { Key = "ModMenu_ColorBodyV3_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ WALL V2 + WARNA V3 (Kustom Warna)", "▶ WALL V2 + CHAMS V3 (Custom)"), ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.ColorBodyV3 end, SetFunc = function(c,v) _G.LynceConfig.ColorBodyV3 = v return true end },
    { Key = "ModMenu_V3_Hidden", UI = AliasMap.Slider, Text = T("   Warna Tembus Dinding (1:Merah 2:Hijau 3:Biru 4:Kuning 5:Ungu 6:Putih)", "   Hidden Color (1:Red 2:Grn 3:Blu 4:Ylw 5:Pur 6:Wht)"), ExpandHandle = "ModMenu_ColorBodyV3_Ex", MinValue = 1, MaxValue = 6, GetFunc = function() return _G.LynceState.CustomTextData.ColorV3Hidden or 1 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.ColorV3Hidden = v return true end },
    { Key = "ModMenu_V3_Vis", UI = AliasMap.Slider, Text = T("   Warna Terlihat (1:Merah 2:Hijau 3:Biru 4:Kuning 5:Ungu 6:Putih)", "   Visible Color (1:Red 2:Grn 3:Blu 4:Ylw 5:Pur 6:Wht)"), ExpandHandle = "ModMenu_ColorBodyV3_Ex", MinValue = 1, MaxValue = 6, GetFunc = function() return _G.LynceState.CustomTextData.ColorV3Visible or 2 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.ColorV3Visible = v return true end },
    { Key = "ModMenu_V3_Thick", UI = AliasMap.Slider, Text = T("   Ketebalan Garis HDR Terlihat", "   HDR Outline Thickness"), ExpandHandle = "ModMenu_ColorBodyV3_Ex", MinValue = 1, MaxValue = 20, GetFunc = function() return _G.LynceState.CustomTextData.ColorV3Thickness or 4 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.ColorV3Thickness = v return true end },
    
    { Key = "ModMenu_WallVehicle", UI = AliasMap.Switcher, Text = T("Wallhack Kendaraan", "Vehicle Wallhack"), GetFunc = function() return _G.LynceConfig.WallVehicle end, SetFunc = function(c,v) _G.LynceConfig.WallVehicle = v return true end },

    { Key = "ModMenu_WhiteBody", UI = AliasMap.Switcher, Text = T("Badan Putih", "White Body"), GetFunc = function() return _G.LynceConfig.WhiteBody end, SetFunc = function(c,v) _G.LynceConfig.WhiteBody = v return true end },
    { Key = "ModMenu_BlackSky", UI = AliasMap.Switcher, Text = T("Langit Gelap", "Black Sky"), GetFunc = function() return _G.LynceConfig.BlackSky end, SetFunc = function(c,v) _G.LynceConfig.BlackSky = v return true end },
    { Key = "ModMenu_RemoveFog", UI = AliasMap.Switcher, Text = T("Hilangkan Kabut", "Remove Fog"), GetFunc = function() return _G.LynceConfig.RemoveFog end, SetFunc = function(c,v) _G.LynceConfig.RemoveFog = v return true end },
    { Key = "ModMenu_RemoveGrass", UI = AliasMap.Switcher, Text = T("Hilangkan Rumput", "Remove Grass"), GetFunc = function() return _G.LynceConfig.RemoveGrass end, SetFunc = function(c,v) _G.LynceConfig.RemoveGrass = v return true end },
    { Key = "ModMenu_RemoveTrees", UI = AliasMap.Switcher, Text = T("Hilangkan Pohon", "Remove Trees"), GetFunc = function() return _G.LynceConfig.RemoveTrees end, SetFunc = function(c,v) _G.LynceConfig.RemoveTrees = v return true end },
 --   { Key = "ModMenu_WallClimb", UI = AliasMap.Switcher, Text = T("Panjat Dinding", "Wall Climb"), GetFunc = function() return _G.LynceConfig.WallClimb end, SetFunc = function(c,v) _G.LynceConfig.WallClimb = v return true end },
 --   { Key = "ModMenu_FastCar", UI = AliasMap.Switcher, Text = T("Mobil Cepat / Terbang", "Fast Car / Flying Car"), GetFunc = function() return _G.LynceConfig.FastCar end, SetFunc = function(c,v) _G.LynceConfig.FastCar = v return true end },

    { Key = "ModMenu_WeaponGlow_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Glow Senjata (Cahaya HDR)", "▶ Weapon Glow (HDR)"), ExpandIndex = 0, GetFunc = function() return _G.LynceConfig.WeaponGlow end, SetFunc = function(c,v) _G.LynceConfig.WeaponGlow = v return true end },
    { Key = "ModMenu_WeaponGlowColor", UI = AliasMap.Slider, Text = T("   Warna Senjata (1:Merah 2:Hijau 3:Biru 4:Kuning 5:Rainbow)", "   Color (1:Red 2:Grn 3:Blu 4:Ylw 5:Rnb)"), ExpandHandle = "ModMenu_WeaponGlow_Ex", MinValue = 1, MaxValue = 5, GetFunc = function() return _G.LynceState.CustomTextData.WeaponGlowColor or 5 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.WeaponGlowColor = v return true end },
    { Key = "ModMenu_WeaponGlowThick", UI = AliasMap.Slider, Text = T("   Ketebalan Glow Senjata", "   Glow Thickness"), ExpandHandle = "ModMenu_WeaponGlow_Ex", MinValue = 1, MaxValue = 15, GetFunc = function() return _G.LynceState.CustomTextData.WeaponGlowThickness or 3 end, SetFunc = function(c,v) _G.LynceState.CustomTextData.WeaponGlowThickness = v return true end }

}

local EntertainmentStack = {
    { Key = "ModMenu_ModEmote", UI = AliasMap.Switcher, Text = T("Buka Semua Emote VIP", "Unlock All VIP Emotes"), GetFunc = function() return _G.LynceConfig.ModEmote end, SetFunc = function(c,v) _G.LynceConfig.ModEmote = v return true end },
    -- ============================================================
    -- WALL CLIMB (PANJAT DINDING)
    -- ============================================================
    { Key = "ModMenu_WallClimb_Ex", UI = AliasMap.TitleSwitcher, Text = "WALL CLIMB (Panjat Dinding)", ExpandIndex = 0,
      GetFunc = function() return _G.zexgodConfig.WallClimb == 1 end,
      SetFunc = function(c, v) 
          _G.zexgodConfig.WallClimb = v and 1 or 0
          print("[zexgod] Wall Climb = " .. tostring(v))
          if not v then
              pcall(function()
                  local me = GameplayData.GetPlayerCharacter()
                  if slua.isValid(me) then
                      local charMove = me.CharacterMovement or me.CharMoveComp
                      if slua.isValid(charMove) then
                          charMove.WalkableFloorAngle = 44.0
                          charMove.MaxStepHeight = 45.0
                          _G.zexgodResetWallClimb()
                      end
                  end
              end)
          end
          return true 
      end },

    -- ============================================================
    -- ⚡ QUICK SWITCH (CEPAT GANTI SENJATA)
    -- ============================================================
    { Key = "ModMenu_QuickSwitch_Ex", UI = AliasMap.TitleSwitcher, Text = "QUICK SWITCH (Ganti Senjata Cepat)", ExpandIndex = 0,
      GetFunc = function() return _G.zexgodConfig.QuickSwitch == 1 end,
      SetFunc = function(c, v) 
          _G.zexgodConfig.QuickSwitch = v and 1 or 0
          print("[zexgod] Quick Switch = " .. tostring(v))
          return true 
      end },

    -- ============================================================
    -- 🎨 BODY COLOR (WARNA TUBUH MUSUH)
    -- ============================================================
    { Key = "ModMenu_BodyColor_Ex", UI = AliasMap.TitleSwitcher, Text = "BODY COLOR (Warna Tubuh Musuh)", ExpandIndex = 0,
      GetFunc = function() return _G.zexgodConfig.BodyColor == 1 end,
      SetFunc = function(c, v) 
          _G.zexgodConfig.BodyColor = v and 1 or 0
          print("[zexgod] Body Color = " .. tostring(v))
          return true 
      end },

    { Key = "ModMenu_BodyColor_Title", UI = AliasMap.Title, Text = "   ── Pilih Warna ──", ExpandHandle = "ModMenu_BodyColor_Ex" },

    { Key = "ModMenu_BodyColor_Red", UI = AliasMap.Switcher, Text = "   Merah", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.zexgodConfig.BodyColorName == "Merah" end,
      SetFunc = function(c, v) if v then _G.zexgodConfig.BodyColorName = "Merah"; print("[zexgod] Body Color = Merah") end; return true end },

    { Key = "ModMenu_BodyColor_Green", UI = AliasMap.Switcher, Text = "   Hijau", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.zexgodConfig.BodyColorName == "Hijau" end,
      SetFunc = function(c, v) if v then _G.zexgodConfig.BodyColorName = "Hijau"; print("[zexgod] Body Color = Hijau") end; return true end },

    { Key = "ModMenu_BodyColor_Blue", UI = AliasMap.Switcher, Text = "   Biru", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.zexgodConfig.BodyColorName == "Biru" end,
      SetFunc = function(c, v) if v then _G.zexgodConfig.BodyColorName = "Biru"; print("[zexgod] Body Color = Biru") end; return true end },

    { Key = "ModMenu_BodyColor_Yellow", UI = AliasMap.Switcher, Text = "   Kuning", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.zexgodConfig.BodyColorName == "Kuning" end,
      SetFunc = function(c, v) if v then _G.zexgodConfig.BodyColorName = "Kuning"; print("[zexgod] Body Color = Kuning") end; return true end },

    { Key = "ModMenu_BodyColor_Orange", UI = AliasMap.Switcher, Text = "   Orange", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.zexgodConfig.BodyColorName == "Orange" end,
      SetFunc = function(c, v) if v then _G.zexgodConfig.BodyColorName = "Orange"; print("[zexgod] Body Color = Orange") end; return true end },

    { Key = "ModMenu_BodyColor_Pink", UI = AliasMap.Switcher, Text = "   Pink", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.zexgodConfig.BodyColorName == "Pink" end,
      SetFunc = function(c, v) if v then _G.zexgodConfig.BodyColorName = "Pink"; print("[zexgod] Body Color = Pink") end; return true end },

    { Key = "ModMenu_BodyColor_Purple", UI = AliasMap.Switcher, Text = "   Ungu", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.zexgodConfig.BodyColorName == "Ungu" end,
      SetFunc = function(c, v) if v then _G.zexgodConfig.BodyColorName = "Ungu"; print("[zexgod] Body Color = Ungu") end; return true end },

    { Key = "ModMenu_BodyColor_Cyan", UI = AliasMap.Switcher, Text = "   Cyan", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.zexgodConfig.BodyColorName == "Cyan" end,
      SetFunc = function(c, v) if v then _G.zexgodConfig.BodyColorName = "Cyan"; print("[zexgod] Body Color = Cyan") end; return true end },

    { Key = "ModMenu_BodyColor_Magenta", UI = AliasMap.Switcher, Text = "   Magenta", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.zexgodConfig.BodyColorName == "Magenta" end,
      SetFunc = function(c, v) if v then _G.zexgodConfig.BodyColorName = "Magenta"; print("[zexgod] Body Color = Magenta") end; return true end },

    { Key = "ModMenu_BodyColor_White", UI = AliasMap.Switcher, Text = "   Putih", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.zexgodConfig.BodyColorName == "Putih" end,
      SetFunc = function(c, v) if v then _G.zexgodConfig.BodyColorName = "Putih"; print("[zexgod] Body Color = Putih") end; return true end },

    -- ============================================================
    -- 🚗 VEHICLE FLY (MOBIL TERBANG)
    -- ============================================================
    { Key = "ModMenu_VehicleFly_Ex", UI = AliasMap.TitleSwitcher, Text = "VEHICLE FLY (Mobil Terbang)", ExpandIndex = 0,
      GetFunc = function() return _G.zexgodConfig.VehicleFly == 1 end,
      SetFunc = function(c, v) 
          _G.zexgodConfig.VehicleFly = v and 1 or 0
          print("[zexgod] Vehicle Fly = " .. tostring(_G.zexgodConfig.VehicleFly))
          if not v then
              pcall(function()
                  local uLocalPlayer = GameplayData.GetPlayerCharacter()
                  if slua.isValid(uLocalPlayer) then
                      local currentVehicle = uLocalPlayer.CurrentVehicle
                      if slua.isValid(currentVehicle) then
                          local rootComp = currentVehicle.RootComponent or currentVehicle:K2_GetRootComponent()
                          if slua.isValid(rootComp) then
                              rootComp:SetEnableGravity(true)
                              rootComp:SetLinearDamping(0.1)
                              rootComp:SetAngularDamping(0.1)
                              rootComp:SetAllPhysicsLinearVelocity(FVector(0, 0, 0), false)
                          end
                      end
                  end
                  if _G._vehicleFly then
                      _G._vehicleFly.initialHeight = nil
                      _G._vehicleFly.targetHeight = nil
                      _G._vehicleFly.isReady = false
                      _G._vehicleFly.lastVehicle = nil
                      _G._vehicleFly.forceApply = false
                  end
              end)
              print("[zexgod] 🚗 Vehicle Fly OFF")
          else
              if _G._vehicleFly then
                  _G._vehicleFly.initialHeight = nil
                  _G._vehicleFly.targetHeight = nil
                  _G._vehicleFly.isReady = false
                  _G._vehicleFly.forceApply = true
              end
              print("[zexgod] 🚗 Vehicle Fly ON")
          end
          return true 
      end 
    },

    { Key = "ModMenu_VehicleFly_Speed", UI = AliasMap.Slider, Text = "   Kecepatan Naik", ExpandHandle = "ModMenu_VehicleFly_Ex",
      MinValue = 0, MaxValue = 100, min = 0, max = 100,
      GetFunc = function() 
          local raw = _G.zexgodConfig.VehicleFlySpeed or 800
          local percent = math.floor(((raw - 100) / 1900) * 100)
          if percent < 0 then percent = 0 end
          if percent > 100 then percent = 100 end
          return percent
      end,
      SetFunc = function(c, v) 
          local val = math.floor(100 + (v / 100) * 1900 + 0.5)
          if val < 100 then val = 100 end
          if val > 2000 then val = 2000 end
          _G.zexgodConfig.VehicleFlySpeed = val
          return true 
      end 
    },

    { Key = "ModMenu_VehicleFly_Height", UI = AliasMap.Slider, Text = "   Ketinggian Maks", ExpandHandle = "ModMenu_VehicleFly_Ex",
      MinValue = 0, MaxValue = 100, min = 0, max = 100,
      GetFunc = function() 
          local raw = _G.zexgodConfig.VehicleFlyMaxHeight or 20000
          local percent = math.floor(((raw - 1000) / 19000) * 100)
          if percent < 0 then percent = 0 end
          if percent > 100 then percent = 100 end
          return percent
      end,
      SetFunc = function(c, v) 
          local val = math.floor(1000 + (v / 100) * 19000 + 0.5)
          if val < 1000 then val = 1000 end
          if val > 20000 then val = 20000 end
          _G.zexgodConfig.VehicleFlyMaxHeight = val
          if _G._vehicleFly then
              _G._vehicleFly.targetHeight = nil
              _G._vehicleFly.initialHeight = nil
              _G._vehicleFly.forceApply = true
          end
          return true 
      end 
    },

    { Key = "ModMenu_VehicleFly_Info", UI = AliasMap.Title, Text = "   Speed: " .. tostring(_G.zexgodConfig.VehicleFlySpeed or 800) .. " | Height: " .. tostring(_G.zexgodConfig.VehicleFlyMaxHeight or 20000), ExpandHandle = "ModMenu_VehicleFly_Ex" },

    -- ============================================================
    -- 🚗 FAST CAR (Mobil Super Cepat)
    -- ============================================================
    { Key = "ModMenu_FastCar_Ex", UI = AliasMap.TitleSwitcher, Text = "FAST CAR (Mobil Super Cepat)", ExpandIndex = 0,
      GetFunc = function() return _G.zexgodConfig.FastCar == 1 end,
      SetFunc = function(c, v) 
          _G.zexgodConfig.FastCar = v and 1 or 0
          print("[zexgod] Fast Car = " .. tostring(_G.zexgodConfig.FastCar))
          return true 
      end 
    },

    { Key = "ModMenu_FastCar_Speed", UI = AliasMap.Slider, Text = "   Kecepatan Maks", ExpandHandle = "ModMenu_FastCar_Ex",
      MinValue = 0, MaxValue = 100, min = 0, max = 100,
      GetFunc = function() 
          local raw = _G.zexgodConfig.FastCarSpeed or 10000
          local percent = math.floor(((raw - 100) / 19900) * 100)
          if percent < 0 then percent = 0 end
          if percent > 100 then percent = 100 end
          return percent
      end,
      SetFunc = function(c, v) 
          local val = math.floor(100 + (v / 100) * 19900 + 0.5)
          if val < 100 then val = 100 end
          if val > 20000 then val = 20000 end
          _G.zexgodConfig.FastCarSpeed = val
          return true 
      end 
    },

    { Key = "ModMenu_FastCar_Info", UI = AliasMap.Title, Text = "   Speed: " .. tostring(_G.zexgodConfig.FastCarSpeed or 10000), ExpandHandle = "ModMenu_FastCar_Ex" },
}


        SettingPageDefine.ModMenu = {
    Key = "ModMenu",
    Text = 999000, 
    UIKey = "Setting_Page_Privacy", 
    Category = {
        { Key = "Cat_ESP", Text = 999001, Stack = StackESP },
        { Key = "Cat_Aimbot", Text = 999002, Stack = StackAimbot },
        { Key = "Cat_AimbotV2", Text = 999003, Stack = StackAimbotV2 },
        { Key = "Cat_Combat", Text = 999004, Stack = StackCombat },
        -- ============================================================
        -- 🎮 CATEGORY FITUR HIBURAN (BARU)
        -- ============================================================
        { Key = "Cat_Entertainment", Text = "FITUR HIBURAN", Stack = EntertainmentStack }
    }
}


        
        table.insert(SettingCatalog, 1, SettingPageDefine.ModMenu)
    end

    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsModMenuHooked then
        local old_ShowUI = UIManager.ShowUI
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            local n = select('#', ...) 
            
            if config and config.keyName then
                local lowerKeyName = string.lower(config.keyName)
                if string.find(lowerKeyName, "setting_main") and not string.find(lowerKeyName, "custom") then
                    local catalog = args[1]
                    if type(catalog) == "table" and catalog[1] and type(catalog[1]) == "table" and catalog[1].Key then
                        local hasModMenu = false
                        for _, page in ipairs(catalog) do
                            if type(page) == "table" and page.Key == "ModMenu" then
                                hasModMenu = true
                                break
                            end
                        end
                        if not hasModMenu then
                            table.insert(catalog, 1, SettingPageDefine.ModMenu)
                        end
                    end
                end
            end
            local table_unpack = table.unpack or unpack
            return old_ShowUI(config, table_unpack(args, 1, n))
        end
        UIManager._IsModMenuHooked = true
    end
end

local function ShowLynceVIPMenu() 
    if _G.LynceMenuAlreadyShown then return end
    if _G.LynceState.MenuStep ~= 0 then return end

    pcall(function()
        local Msg = require("client.slua.logic.common.logic_common_msg_box")
        if not Msg or not Msg.Show then return end

        local function Step_ScamAlert()
            local title = _G.LynceLang == "EN" and "SCAM ALERT" or "PERINGATAN SCAM MOD"
            local content = _G.LynceLang == "EN" 
                and "Join my Telegram to avoid scammers selling mods. @GODMOD OWNER@zedygodx" 
                or "JOIN KE TELE LER BIAR GA KENA SCAM OWNER ASLI HANYA @zexygodx CHANEL @GODMOD\nAWAS BANYAK YANG SCAM SAYA SENDIRI TIDAK PUNYA SELER TIDAK JUGA BERJUALAN DI WA. HATI-HATI!"
            local btn1 = _G.LynceLang == "EN" and "JOIN" or "GABUNG"
            local btn2 = _G.LynceLang == "EN" and "CLOSE" or "TUTUP"

            Msg.Show(1, title, content, function() local Web = require("client.slua.logic.url.logic_webview_sdk"); if Web and Web.OpenURL then Web:OpenURL("https://t.me/zexgodx") end end, function() end, btn1, btn2)
            _G.LynceState.MenuStep = 99
            _G.LynceMenuAlreadyShown = true
        end

        local function Step_Welcome()
            local title = _G.LynceLang == "EN" and "WELCOME TO VIP MOD" or "SELAMAT DATANG DI MOD VIP"
            local content = _G.LynceLang == "EN" 
                and "hii. ZEXY disini yoi menu udah di pengaturan ya\nIMPORTANT: Enable fewer features to avoid lag. Play safe!" 
                or "Hallo Para Penguna VIP GODMOD\n AKTIFKAN FITUR SECUKUPNYA YA BIAR GA FC [ BUSET TUMBEN GUE RAMAH]"
            local btn1 = _G.LynceLang == "EN" and "OPEN GAME MENU" or "BUKA MENU GAME"
            local btn2 = _G.LynceLang == "EN" and "CLOSE" or "TUTUP"

            Msg.Show(1, title, content, 
            function() 
                _G.InitModMenuTab()
                if _G.LynceLang == "EN" then
                    Notify("VIP MOD MENU ADDED!\nOpen Settings (Gear icon) -> VIP MOD MENU to toggle features.")
                else
                    Notify("MENU 'VIP MOD MENU' TELAH DITAMBAHKAN KE PENGATURAN GAME!\nBuka Pengaturan (ikon Gear) -> VIP MOD MENU untuk mengaktifkan/menonaktifkan fitur.")
                end
                Step_ScamAlert()
            end, 
            function() end, btn1, btn2)
        end

        local function Step_SelectLanguage()
            Msg.Show(2, "SELECT LANGUAGE / PILIH BAHASA", "Please select your preferred language.\nSilakan pilih bahasa yang Anda inginkan.",
            function()
                _G.LynceLang = "ID"
                Step_Welcome()
            end,
            function()
                _G.LynceLang = "EN"
                Step_Welcome()
            end, "BAHASA INDONESIA", "ENGLISH")
        end

        _G.LynceState.MenuStep = 1
        Step_SelectLanguage() 
    end)
end
-- ========================================== 
-- LOGIC MỞ KHÓA 165 FPS VÀ UI IPAD VIEW 
-- ========================================== 
local function InitializeGraphicsUnlock() 
    if isExpired then return end
    if _G.LynceState.GraphicsUnlocked or currentTime > limitTime then return end

    pcall(function()
        local SettingCfg = require("client.logic.setting.setting_config")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if SettingCfg then
            if SettingCfg.TpViewValue then SettingCfg.TpViewValue.max = 160 end
            if SettingCfg.FpViewValue then SettingCfg.FpViewValue.max = 160 end
        end
        if GraphicSettingDB then
            if GraphicSettingDB.TpViewValue then GraphicSettingDB.TpViewValue.max = 160 end
        end
    end)

    pcall(function()
        local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
        local GSC_FPS = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS")
        local GSC_FPSFT = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        
        local KismetMathLibrary = import("KismetMathLibrary") or _G.KismetMathLibrary
        local FLinearColor = import("LinearColor") or _G.FLinearColor

        if logic_setting_graphics then
            local old_SetFPS = logic_setting_graphics.SetFPS
            function logic_setting_graphics.SetFPS(gameInstance, FPSLevel)
                if old_SetFPS then old_SetFPS(gameInstance, FPSLevel) end
                if FPSLevel == 8 then 
                    gameInstance:ExecuteCMD("t.MaxFPS", "165")
                    gameInstance:ExecuteCMD("r.FrameRateLimit", "165")
                end
            end
        end

        if GSC_FPS and GSC_FPS.__inner_impl then
            local fps_impl = GSC_FPS.__inner_impl
            function fps_impl:GetMaxFPSLevel() return 8, 8 end
            function fps_impl:InitRealSupportFPS()
                local RealSupportFPS = {}
                for i = 1, 8 do RealSupportFPS[i] = {true, true} end
                if GraphicSettingDB then GraphicSettingDB:UpdateUIData(GraphicSettingDB.RealSupportFPS, RealSupportFPS, false) end
                return RealSupportFPS
            end
            function fps_impl:UpdateSelectedFPSState(selectedLevel)
                if not slua.isValid(self.UIRoot) then return end
                for level = 2, 8 do
                    local name = "NodeFps" .. (({[2]=20,[3]=25,[4]=30,[5]=40,[6]=60,[7]=90,[8]=120})[level] or 120)
                    local widget = self.UIRoot[name]
                    if slua.isValid(widget) then
                        widget:SetIsEnabled(true) 
                        pcall(function() widget:SetRenderOpacity(1.0) end)
                        local switcher = self.UIRoot["WidgetSwitcher_" .. level]
                        if slua.isValid(switcher) then 
                            switcher:SetActiveWidgetIndex(level == selectedLevel and 0 or 1) 
                        end
                    end
                end
            end
        end

        if GSC_FPSFT and GSC_FPSFT.__inner_impl then
            local ft_impl = GSC_FPSFT.__inner_impl
            local NMinFPS, NStep = 90, 5
            local function clamp(value, min, max)
                if value < min then return min end
                if max < value then return max end
                return value
            end
            local function lerp(a, b, t) return a + (b - a) * t end
            local function _getColorByPercent(start, finish, percent)
                if not FLinearColor then return nil end
                return FLinearColor(lerp(start.R, finish.R, percent), lerp(start.G, finish.G, percent), lerp(start.B, finish.B, percent), lerp(start.A, finish.A, percent))
            end
            
            ft_impl.ShowOrHide = function(self)
                self:SelfHitTestInvisible()
                if self.InitFPSFTSwitch then self:InitFPSFTSwitch() end
            end

            ft_impl.InitFPSFTSwitch = function(self)
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                if self.UIRoot.Setting_Switch then self.UIRoot.Setting_Switch:SetSwitcherEnable2(FPSFineTuneSwitch, true) end
                if self.UIRoot.CanvasPanel_8 then self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, FPSFineTuneSwitch) end
                if self.UIRoot.WidgetSwitcher_0 then self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2) end
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
            end

            ft_impl.InitFPSFTValue165 = function(self)
                local itemRoot = self.UIRoot
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                local FPSFineTuneNum = 165
                if FPSFineTuneSwitch then
                    FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum) or 165
                    itemRoot.Slider_screen3:SetLocked(false)
                    if FLinearColor then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor(1.0, 1.0, 1.0, 1.0))
                    end
                else
                    itemRoot.Slider_screen3:SetLocked(true)
                    if FLinearColor then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1.0, 0.625, 0.6, 1))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor(1.0, 0.625, 0.6, 1.0))
                    end
                end
                local FPSFineTunePer = (FPSFineTuneNum - NMinFPS) / (165 - NMinFPS)
                
                itemRoot.Veihclescreen3:SetText(tostring(FPSFineTuneNum))
                itemRoot.Slider_screen3:SetValue(FPSFineTunePer)
                itemRoot.ProgressBar_screen3:SetPercent(FPSFineTunePer)
                
                if FLinearColor then
                    local startColor = FLinearColor(1.0, 1.0, 1.0, 1.0)
                    local midColor = FLinearColor(1.0, 0.54, 0.11, 1.0)
                    local endColor = FLinearColor(1.0, 0.23, 0.15, 1.0)
                    local sliderColor = FPSFineTunePer < 0.4 and startColor or _getColorByPercent(midColor, endColor, (FPSFineTunePer - 0.4) / 0.6)
                    itemRoot.Slider_screen3:SetSliderHandleColor(sliderColor)
                end
            end

            ft_impl.OnFPSFTValueChange3 = function(self, FPSFineTuneNum)
                GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneNum, FPSFineTuneNum)
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
                if self:GetParentUI() then self:GetParentUI():SetDirty(true) end
                local gameInstance = GraphicSettingDB.GetGameInstance and GraphicSettingDB.GetGameInstance()
                if gameInstance then
                    gameInstance:ExecuteCMD("t.MaxFPS", tostring(FPSFineTuneNum))
                    gameInstance:ExecuteCMD("r.FrameRateLimit", tostring(FPSFineTuneNum))
                end
            end

            ft_impl.OnFPSFTSliderValueChange3 = function(self, value)
                if GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch) and KismetMathLibrary then
                    local FPSFineTuneNum = KismetMathLibrary.FCeil(value * (165 - NMinFPS) / NStep) * NStep + NMinFPS
                    self:OnFPSFTValueChange3(clamp(FPSFineTuneNum, NMinFPS, 165))
                end
            end
            
            ft_impl.OnFPSFTAdd = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTAdd2 = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus2 = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTSliderValueChange = ft_impl.OnFPSFTSliderValueChange3
            ft_impl.OnFPSFTSliderValueChange2 = ft_impl.OnFPSFTSliderValueChange3
        end
    end)
    _G.LynceState.GraphicsUnlocked = true
    Notify("Graphics & FPS 165Hz Unlocked (Upgraded Version)")
end

-- ========================================== 
-- KHỞI TẠO HỆ THỐNG ESP (GỐC)
-- ========================================== 
local function InitializeNativeESP() 
    if _G.LynceState.NativeESPReady then return end
    pcall(function() 
        local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools") 
        local currentMarkCfg = GamePlayTools.GetCurrentConfig("ScreenMarkConfig") 
        local function ApplyCfg(cfg)
            if not cfg then return end 
            if cfg[1006] then 
                cfg[1006].bBindBlocked = true;
                cfg[1006].bBindOutScreen = true; 
                cfg[1006].MaxWidgetNum = 99
                cfg[1006].MaxShowDistance = 6000000; 
                cfg[1006].bScaleByDistance = false
                cfg[1006].BindSocketName = "root"; 
                cfg[1006].bUseLuaWorldSocketName = true
                cfg[1006].WorldPositionOffset = FVector(0, 0, -30) 
            end 
            -- [FIX ESP LOẠI 4] Thay vì dùng 1003 dễ bị game xóa, ta tạo ID độc quyền 8888
            cfg[8888] = { 
                UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                MaxWidgetNum = 99, 
                MaxShowDistance = 6000000, 
                bBindOutScreen = true,
                bBindBlocked = true, 
                bIsBindingActor = true,     -- Bắt buộc phải có để bám theo địch
                BindSocketName = "head",
                bUseLuaWorldSocketName = true, 
                WorldPositionOffset = FVector(0, 0, 30),
                bNeedPreLoad = true,        -- Bắt buộc có để load sẵn UI (chống lỗi)
                Priority = 2 
            } 
            cfg[9999] = { 
                UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                MaxWidgetNum = 99, 
                MaxShowDistance = 6000000, 
                bBindOutScreen = true,
                bBindBlocked = true, 
                bIsBindingActor = true, 
                BindSocketName = "head",
                bUseLuaWorldSocketName = true, 
                WorldPositionOffset = FVector(0, 0, 50),
                bNeedPreLoad = true, 
                Priority = 2 
            } 
        end 
        ApplyCfg(currentMarkCfg) 
        for k, cfg in pairs(package.loaded) do 
            if type(k) == "string" and string.find(k, "ScreenMarkConfig") and type(cfg) == "table" then 
                ApplyCfg(cfg) 
            end 
        end 
    end)
    _G.LynceState.NativeESPReady = true 
    Notify("Native ESP System Initialized") 
end

-- ========================================== 
-- LOCAL FUNCTIONS CHO LOGIC NEW ESP - OPTIMIZED
-- ========================================== 
local function GetAllSkeletalMeshes(enemy, markData)
    local curTime = os.clock()
    if markData and markData.CachedMeshes and markData.CachedMeshTime and (curTime - markData.CachedMeshTime < 3.0) then
        local validMeshes = {}
        for _, cachedMesh in ipairs(markData.CachedMeshes) do
            if Valid(cachedMesh) then table.insert(validMeshes, cachedMesh) end
        end
        markData.CachedMeshes = validMeshes
        return validMeshes
    end

    local meshes = {}
    if Valid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
    pcall(function()
        local SkeletalMeshClass = import("SkeletalMeshComponent")
        if SkeletalMeshClass and type(enemy.GetComponentsByClass) == "function" then
            local childs = enemy:GetComponentsByClass(SkeletalMeshClass)
            if childs then
                local count = type(childs.Num) == "function" and childs:Num() or #childs
                for i = 1, count do
                    local comp = type(childs.Get) == "function" and childs:Get(i-1) or childs[i]
                    if Valid(comp) and comp ~= enemy.Mesh then
                        table.insert(meshes, comp)
                    end
                end
            end
        end
    end)
    if markData then
        markData.CachedMeshes = meshes
        markData.CachedMeshTime = curTime
    end
    return meshes
end

-- ========================================== 
-- HÀM XUYÊN TƯỜNG & RESTORE GỐC
-- ==========================================
local function UndoWallXuyenTuong(enemy, markData)
    pcall(function()
        if markData.WallhackApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for _, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function() if type(mesh.SetRenderCustomDepth) == "function" then mesh:SetRenderCustomDepth(false) end end)
                    for i = 0, 10 do 
                        local matInterface = mesh:GetMaterial(i)
                        if Valid(matInterface) then
                            local baseMat = matInterface:GetBaseMaterial()
                            if Valid(baseMat) then baseMat.bDisableDepthTest = false end
                        end
                    end
                end
            end
            markData.WallhackApplied = false
        end
    end)
end

local function ApplyWallXuyenTuong(enemy, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        for _, mesh in ipairs(meshes) do
            if Valid(mesh) then 
                pcall(function()
                    if type(mesh.SetRenderCustomDepth) == "function" then
                        mesh:SetRenderCustomDepth(true)
                    end
                    if type(mesh.SetCustomDepthStencilValue) == "function" then
                        mesh:SetCustomDepthStencilValue(252) 
                    end
                end)
                for i = 0, 10 do 
                    local matInterface = mesh:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        baseMat.bDisableDepthTest = true
                        baseMat.BlendMode = 2 
                    end
                end
            end
        end
    end)
end

local function ApplyColorBodyV2(enemy, pc, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        if #meshes == 0 then return end
        
        -- [FIX CHỐNG GIẬT LAG ĐÔNG NGƯỜI]: Giới hạn tia Raycast Check Tường 0.3s một lần
        -- Tránh việc bắn hàng nghìn tia vật lý mỗi giây làm cháy CPU
        local curTime = os.clock()
        if markData.LastVisCheckTime == nil or (curTime - markData.LastVisCheckTime) > 0.3 then
            markData.LastVisCheckTime = curTime
            local isHidden = true
            pcall(function()
                if Valid(pc) and type(pc.LineOfSightTo) == "function" then
                    if pc:LineOfSightTo(enemy) then isHidden = false else isHidden = true end
                end
            end)
            markData.CachedHiddenState = isHidden
        end
        
        local hidden = markData.CachedHiddenState
        if hidden == nil then hidden = true end
        
        local cData = _G.LynceState.CustomTextData or {}
        local hiddenColor = {R = cData.HiddenR or 150, G = cData.HiddenG or 0, B = cData.HiddenB or 0, A = cData.HiddenA or 25}
        local visibleColor = {R = cData.VisibleR or 0, G = cData.VisibleG or 150, B = cData.VisibleB or 0, A = cData.VisibleA or 25}
        
        local finalColor = hidden and hiddenColor or visibleColor
        local colorHash = string.format("%d_%d_%d_%d", finalColor.R, finalColor.G, finalColor.B, finalColor.A)
        local currentMeshCount = #meshes
        local isMeshChanged = (markData.LastMeshCount ~= currentMeshCount)
        
        -- Nếu chưa có sự đổi màu / đổi số lượng quần áo thì ngắt luôn, tiết kiệm CPU
        if not isMeshChanged and markData.LastHiddenState == hidden and markData.LastColorHash == colorHash then return end
        
        -- [FIX RAM]: Xóa Material rác cũ đi khi địch đổi vũ khí/áo giáp để tránh rác VRAM
        if isMeshChanged and markData.MIDs then
            markData.MIDs = {}
        end

        markData.LastHiddenState = hidden
        markData.LastMeshCount = currentMeshCount
        markData.LastColorHash = colorHash
        markData.ColorApplied = true
        
        for meshIndex, mesh in ipairs(meshes) do
            if Valid(mesh) then
                pcall(function()
                    mesh.LDMaxDrawDistance = -99999
                    mesh.MaxDrawDistanceOffset = -99999
                    mesh.CachedMaxDrawDistance = -99999
                    mesh.UseScopeDistanceCulling = true
                    mesh.PrimitiveShadingStrategy = 1
                    mesh.ShadingRate = 6
                end)
                for i = 0, 10 do
                    local matInterface = mesh:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        local matName = tostring(baseMat)
                        if string.find(matName, "Master_Mask", 1, true) then
                            if not markData.MIDs then markData.MIDs = {} end
                            
                            -- [FIX RÁC RAM]: Thay vì dùng tostring(mesh) sinh rác chuỗi, dùng index cục bộ
                            local meshKey = "Mesh_" .. tostring(meshIndex)
                            
                            if not markData.MIDs[meshKey] then markData.MIDs[meshKey] = {} end
                            local mid = markData.MIDs[meshKey][i]
                            if not Valid(mid) then
                                mid = mesh:CreateAndSetMaterialInstanceDynamic(i)
                                markData.MIDs[meshKey][i] = mid
                            end
                            if Valid(mid) then
                                mid:SetVectorParameterValue("颜色", finalColor)
                                mid:SetVectorParameterValue("Extra Light Color", finalColor)
                                mid:SetVectorParameterValue("Para_Color", finalColor)
                                mid:SetVectorParameterValue("Para_ColorTint", finalColor)
                                mid:SetVectorParameterValue("Para_Color_1", finalColor)
                                mid:SetVectorParameterValue("Tint", finalColor)
                                mid:SetVectorParameterValue("Color", finalColor)
                                mid:SetVectorParameterValue("BaseColor", finalColor)
                                mid:SetVectorParameterValue("BodyColor", finalColor)
                                mid:SetVectorParameterValue("MainColor", finalColor)
                                mid:SetVectorParameterValue("DiffuseColor", finalColor)
                                mid:SetVectorParameterValue("EmissiveColor", finalColor)
                                mid:SetVectorParameterValue("ParaScaleOffset", SCALE_COLOR_V2)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function UndoColorBodyV2(enemy, markData)
    pcall(function()
        if markData.ColorApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for meshIndex, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function()
                        mesh.PrimitiveShadingStrategy = 0
                        mesh.ShadingRate = 1
                    end)
                    local meshKey = "Mesh_" .. tostring(meshIndex)
                    if markData.MIDs and markData.MIDs[meshKey] then
                        for i, mid in pairs(markData.MIDs[meshKey]) do
                            if Valid(mid) then
                                local defC = {R=1, G=1, B=1, A=1}
                                mid:SetVectorParameterValue("颜色", defC)
                                mid:SetVectorParameterValue("Extra Light Color", defC)
                                mid:SetVectorParameterValue("Para_Color", defC)
                                mid:SetVectorParameterValue("Para_ColorTint", defC)
                                mid:SetVectorParameterValue("Para_Color_1", defC)
                                mid:SetVectorParameterValue("Tint", defC)
                                mid:SetVectorParameterValue("Color", defC)
                                mid:SetVectorParameterValue("BaseColor", defC)
                                mid:SetVectorParameterValue("BodyColor", defC)
                                mid:SetVectorParameterValue("MainColor", defC)
                                mid:SetVectorParameterValue("DiffuseColor", defC)
                                mid:SetVectorParameterValue("EmissiveColor", defC)
                            end
                        end
                    end
                end
            end
            markData.ColorApplied = false
            markData.LastColorHash = ""
            markData.LastHiddenState = nil
        end
    end)
end

-- ==========================================
-- CHỨC NĂNG MÀU V3 (TÁCH BIỆT TỪ MÃ NGUỒN CỦA BẠN - HOẠT ĐỘNG QUA BỘ ĐỆM Z-BUFFER)
-- [ĐÃ FIX LỖI MẤT MÀU KHI ĐỔI LOD & TỐI ƯU CHỐNG DROP FPS KHI ĐÔNG NGƯỜI]
-- ==========================================
local function ApplyColorBodyV3(enemy, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        if #meshes == 0 then return end
        
        local cData = _G.LynceState.CustomTextData or {}
        local hidChoice = cData.ColorV3Hidden or 1
        local visChoice = cData.ColorV3Visible or 2
        local v3Thick = cData.ColorV3Thickness or 4
        
        -- Tạo mã băm để phát hiện người dùng kéo thanh đổi màu/độ dày
        local currentHash = string.format("%d_%d_%d", hidChoice, visChoice, v3Thick)
        local colorChanged = (markData.LastColorV3Hash ~= currentHash)
        markData.LastColorV3Hash = currentHash

        local function GetColorRGB(choice)
            if choice == 1 then return 255, 0, 0 end -- Đỏ
            if choice == 2 then return 0, 255, 0 end -- Lục
            if choice == 3 then return 0, 0, 255 end -- Lam
            if choice == 4 then return 255, 255, 0 end -- Vàng
            if choice == 5 then return 255, 0, 255 end -- Tím/Hồng
            if choice == 6 then return 255, 255, 255 end -- Trắng
            return 255, 0, 0 -- Mặc định đỏ
        end

        local hR, hG, hB = GetColorRGB(hidChoice)
        local vR, vG, vB = GetColorRGB(visChoice)

        -- Màu Sau Tường (invisColor)
        local invisColor = { R=hR, G=hG, B=hB, A=255, r=hR, g=hG, b=hB, a=255 }
        
        -- Màu Viền Lộ Diện HDR (visColor)
        local glowIntensity = 80.0 
        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        local visColor = LinearColorClass and LinearColorClass((vR/255)*glowIntensity, (vG/255)*glowIntensity, (vB/255)*glowIntensity, 1.0) or { R=vR*glowIntensity, G=vG*glowIntensity, B=vB*glowIntensity, A=255 }
        local scale = { R=3.0, G=3.0, B=0.0, A=0.0, r=3.0, g=3.0, b=0.0, a=0.0 }
        
        markData.MIDs_V3 = markData.MIDs_V3 or {}

        for meshIndex, comp in ipairs(meshes) do
            if Valid(comp) then
                local compKey = "MeshV3_" .. tostring(meshIndex)
                markData.MIDs_V3[compKey] = markData.MIDs_V3[compKey] or {}
                
                pcall(function()
                    if comp.PrimitiveShadingStrategy ~= 1 then
                        comp.UseScopeDistanceCulling = false 
                        comp.PrimitiveShadingStrategy = 1
                        comp.ShadingRate = 6
                    end
                end)
                
                for i = 0, 10 do
                    local matInterface = comp:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        if baseMat.bDisableDepthTest ~= true then baseMat.bDisableDepthTest = true end
                        if baseMat.BlendMode ~= 2 then baseMat.BlendMode = 2 end
                    end
                    
                    local currentCached = markData.MIDs_V3[compKey][i]
                    local needUpdateColor = false
                    
                    -- Nếu chưa có MID hoặc người dùng kéo thanh đổi màu -> Cập nhật lại
                    if not Valid(currentCached) then
                        local newMid = comp:CreateAndSetMaterialInstanceDynamic(i)
                        if Valid(newMid) then 
                            markData.MIDs_V3[compKey][i] = newMid
                            currentCached = newMid
                            needUpdateColor = true
                        end
                    elseif colorChanged then
                        needUpdateColor = true
                    end
                    
                    if Valid(currentCached) and needUpdateColor then
                        pcall(function()
                            currentCached:SetVectorParameterValue("颜色", invisColor)
                            currentCached:SetVectorParameterValue("Extra Light Color", invisColor)
                            currentCached:SetVectorParameterValue("Para_Color", invisColor)
                            currentCached:SetVectorParameterValue("Para_ColorTint", invisColor)
                            currentCached:SetVectorParameterValue("Para_Color_1", invisColor)
                            currentCached:SetVectorParameterValue("Tint", invisColor)
                            currentCached:SetVectorParameterValue("Color", invisColor)
                            currentCached:SetVectorParameterValue("BaseColor", invisColor)
                            currentCached:SetVectorParameterValue("BodyColor", invisColor)
                            currentCached:SetVectorParameterValue("MainColor", invisColor)
                            currentCached:SetVectorParameterValue("DiffuseColor", invisColor)
                            currentCached:SetVectorParameterValue("EmissiveColor", invisColor)
                            currentCached:SetVectorParameterValue("CustomColor", invisColor)
                            currentCached:SetVectorParameterValue("OverlayColor", invisColor)
                            currentCached:SetVectorParameterValue("GlowColor", invisColor)
                            currentCached:SetVectorParameterValue("EdgeColor", invisColor)
                            currentCached:SetVectorParameterValue("LightColor", invisColor)
                            currentCached:SetVectorParameterValue("OutlineColor", invisColor)
                            currentCached:SetVectorParameterValue("ParaScaleOffset", scale)
                            currentCached:SetScalarParameterValue("Opacity", 0.7)
                            currentCached:SetScalarParameterValue("Alpha", 0.7)
                            currentCached:SetScalarParameterValue("GlowIntensity", 1.0)
                            currentCached:SetScalarParameterValue("Intensity", 1.0)
                        end)
                    end
                end
                
                pcall(function()
                    if comp.SetDrawIdeaOutline then
                        comp:SetDrawIdeaOutline(true)
                        if comp.OverrideIdeaOutlineColor then comp:OverrideIdeaOutlineColor(true, visColor) end
                        if comp.OverrideIdeaOutlineThickness then comp:OverrideIdeaOutlineThickness(true, v3Thick) end
                    end
                end)
            end
        end
        markData.ColorV3Applied = true
    end)
end

local function UndoColorBodyV3(enemy, markData)
    pcall(function()
        if markData.ColorV3Applied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for meshIndex, comp in ipairs(meshes) do
                if Valid(comp) then
                    pcall(function()
                        comp.PrimitiveShadingStrategy = 0
                        comp.ShadingRate = 1
                    end)
                    
                    for i = 0, 10 do
                        local s, matInterface = pcall(function() return comp:GetMaterial(i) end)
                        if s and Valid(matInterface) then
                            local s2, baseMat = pcall(function() return matInterface:GetBaseMaterial() end)
                            if s2 and Valid(baseMat) then
                                baseMat.bDisableDepthTest = false
                                baseMat.BlendMode = 1
                            end
                        end
                    end
                    
                    local compKey = "MeshV3_" .. tostring(meshIndex)
                    if markData.MIDs_V3 and markData.MIDs_V3[compKey] then
                        for i, mid in pairs(markData.MIDs_V3[compKey]) do
                            if Valid(mid) then
                                pcall(function()
                                    local defC = {R=1, G=1, B=1, A=1, r=1, g=1, b=1, a=1}
                                    mid:SetVectorParameterValue("颜色", defC)
                                    mid:SetVectorParameterValue("Extra Light Color", defC)
                                    mid:SetVectorParameterValue("Para_Color", defC)
                                    mid:SetVectorParameterValue("Tint", defC)
                                    mid:SetVectorParameterValue("BaseColor", defC)
                                    mid:SetVectorParameterValue("Color", defC)
                                end)
                            end
                        end
                    end
                    
                    pcall(function()
                        if comp.SetDrawIdeaOutline then
                            comp:SetDrawIdeaOutline(false)
                        end
                    end)
                end
            end
            markData.ColorV3Applied = false
            markData.LastMeshCountV3 = 0 -- Reset bộ đếm mesh để có thể bật lại sau
            if markData.MIDs_V3 then markData.MIDs_V3 = nil end
        end
    end)
end
-- ==========================================
-- CHỨC NĂNG WALL MÀU NEW (ĐƯỢC ĐỒNG BỘ VÀO HỆ THỐNG VIP TỐI ƯU)
-- ==========================================
local function ApplyColorBodyNew(enemy, markData)
    pcall(function()
        -- Kích hoạt Console Command nếu chưa bật (Chỉ gọi 1 lần)
        if not _G.ConsoleNewWallReady then
            local KismetSystemLibrary = import("KismetSystemLibrary")
            local world = slua.getWorld()
            if KismetSystemLibrary and world then
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.EnableDrawDyeingColor 1")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.CustomDepth 3")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.IdeaOutline.Enable 1")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.Highlight.Enable 1")
                _G.ConsoleNewWallReady = true
            end
        end

        -- Lấy toàn bộ Mesh của kẻ địch
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        
        -- Thêm lưới của vũ khí đang cầm trên tay
        local weapon = nil
        pcall(function() weapon = enemy:GetCurrentWeapon() end)
        if slua.isValid(weapon) and slua.isValid(weapon.Mesh) then
            table.insert(meshes, weapon.Mesh)
        end

        local isBot = markData.AK_IS_BOT or false
        local currentMeshCount = #meshes
        
        -- [TỐI ƯU FPS TUYỆT ĐỐI] - CHẾ ĐỘ NGỦ ĐÔNG (CACHE)
        -- Tạo mã băm nhận diện: Nếu số lượng quần áo/súng của địch không đổi, bỏ qua vòng lặp C++ cực nặng bên dưới
        local stateHash = (isBot and "BOT" or "PLAYER") .. "_" .. tostring(currentMeshCount)
        
        if markData.LastColorNewHash == stateHash and markData.ColorNewApplied then
            return -- Mọi thứ đã được tô màu trước đó, ngắt hàm tại đây để tránh đốt CPU!
        end
        
        -- Nếu có sự thay đổi (mới bật, địch đổi súng, lụm đồ), tiến hành cập nhật màu và lưu Cache
        markData.LastColorNewHash = stateHash
        markData.ColorNewApplied = true

        -- Chỉ Load bộ màu khi thực sự cần xử lý
        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        local c_vis = LinearColorClass and LinearColorClass(0, 100, 0, 1) or {R=0, G=100, B=0, A=1}
        local c_occ = LinearColorClass and LinearColorClass(100, 0, 0, 1) or {R=100, G=0, B=0, A=1}
        local c_bVis = LinearColorClass and LinearColorClass(49, 48, 0, 100) or {R=49, G=48, B=0, A=100}
        local c_bOcc = LinearColorClass and LinearColorClass(9, 1.5, 45, 100) or {R=9, G=1.5, B=45, A=100}

        local visColor = isBot and c_bVis or c_vis
        local occColor = isBot and c_bOcc or c_occ

        for _, mesh in ipairs(meshes) do
            if Valid(mesh) then
                pcall(function()
                    if type(mesh.SetDrawDyeing) == "function" then
                        mesh:SetDrawDyeing(true)
                        mesh:SetDrawDyeingMode(1)
                        mesh:SetVisibleDyeingColor(visColor)
                        mesh:SetOccludedDyeingColor(occColor)
                        mesh:SetDyeingColorFadeDistance(99999.0)
                        mesh:SetDyeingColorMinMaxDistance(0.0, 99999.0)
                        mesh:SetDrawHighlight(true)
                        mesh:OverrideHighlightColor(visColor)
                        mesh:SetHighlightCanBeOccluded(false)
                        mesh:SetDrawIdeaOutline(true)
                        mesh:SetIdeaOutlineNew(true)
                        mesh:SetIdeaOutlineOcclusionHighlight(true)
                        mesh:OverrideIdeaOutlineColor(visColor)
                        mesh:SetIdeaOutlineOcclusionColor(occColor)
                        mesh:OverrideIdeaOutlineThickness(20.0)
                        mesh:SetIdeaOverrideOutlineAndOcclusion(true)
                        mesh:SetRenderCustomDepth(true)
                        mesh:SetCustomDepthStencilValue(255)
                    end
                end)
            end
        end
    end)
end

local function UndoColorBodyNew(enemy, markData)
    pcall(function()
        if markData.ColorNewApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            local weapon = nil
            pcall(function() weapon = enemy:GetCurrentWeapon() end)
            if slua.isValid(weapon) and slua.isValid(weapon.Mesh) then
                table.insert(meshes, weapon.Mesh)
            end

            for _, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function()
                        if type(mesh.SetDrawDyeing) == "function" then
                            mesh:SetDrawDyeing(false)
                            mesh:SetDrawHighlight(false)
                            mesh:SetDrawIdeaOutline(false)
                            mesh:SetRenderCustomDepth(false)
                        end
                    end)
                end
            end
            markData.ColorNewApplied = false
            markData.LastColorNewHash = "" -- Xóa Cache để lần sau bật lại sẽ tính toán lại mượt mà
        end
    end)
end

-- ========================================== 
-- HỆ THỐNG AIMBOT V2 TÍCH HỢP MỚI (UPDATE KISMET SMOOTH)
-- ========================================== 
_G.GetEnemyTargetsFromActors = function(radius)
    local result = {}
    local player = GameplayData.GetPlayerCharacter()

    if not slua.isValid(player) then
        return result
    end

    local allCharacters = {}
    if GameplayData.GetAllPlayerCharacters then
        allCharacters = GameplayData.GetAllPlayerCharacters()
    elseif GameplayData.GameCharacters then
        for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end
    end

    local myTeam = player:GetTeamID()

    for _, actor in pairs(allCharacters) do
        if slua.isValid(actor) and actor ~= player and actor.GetTeamID and actor:IsAlive() then
            if actor:GetTeamID() ~= myTeam then
                local dist = player:GetDistanceTo(actor)
                if dist <= radius then
                    table.insert(result, actor)
                end
            end
        end
    end
    return result
end

_G.AimTouch = function()
    pcall(function()
        if not _G.LynceConfig.AimTouchEnable then return end
        
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        
        local pc = player:GetPlayerControllerSafety()
        if not slua.isValid(pc) then return end
        
        local isFiring = player.bIsWeaponFiring
        local isADS = player.bIsGunADS
        
        -- CHECK WEAPON & AMMO
        local weapon = player.WeaponManagerComponent and player.WeaponManagerComponent.CurrentWeaponReplicated
        if not weapon and type(player.GetCurrentShootWeapon) == "function" then
            weapon = player:GetCurrentShootWeapon()
        end
        
        local isShotgun = false
        local isSniper = false
        local currentAmmo = 1
        
        if slua.isValid(weapon) then
            local wID = type(weapon.GetWeaponID) == "function" and weapon:GetWeaponID() or 0
            local wName = type(weapon.GetWeaponName) == "function" and weapon:GetWeaponName() or ""
            
            if (wID >= 1030000 and wID < 1040000) or wName:find("S686") or wName:find("S1897") or wName:find("S12") or wName:find("DBS") or wName:find("M1014") then 
                isShotgun = true 
            end
            
            if wName:find("Kar98") or wName:find("M24") or wName:find("AWM") or wName:find("Mosin") or wName:find("Win94") or wName:find("AMR") or wName:find("SKS") or wName:find("SLR") or wName:find("Mini") or wName:find("Mk14") or wName:find("QBU") or wName:find("Mk12") or wName:find("VSS") then
                isSniper = true
            end
            
            if type(weapon.GetCurrentAmmo) == "function" then
                currentAmmo = weapon:GetCurrentAmmo()
            elseif weapon.ShootWeaponComponent and type(weapon.ShootWeaponComponent.GetCurrentAmmo) == "function" then
                currentAmmo = weapon.ShootWeaponComponent:GetCurrentAmmo()
            elseif weapon.CurrentAmmo ~= nil then
                currentAmmo = weapon.CurrentAmmo
            end
        end

        -- LOGIC NHẢ CÒ SÚNG NẾU MẤT MỤC TIÊU / ĐỊCH CHẾT HOẶC SHOTGUN HẾT ĐẠN
        if _G.LynceState.IsAutoFiring then
            pcall(function()
                player.bIsWeaponFiring = false
                if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(false) end
                if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(false) end
                local wepMgr = player.WeaponManagerComponent
                if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = false end
            end)
            _G.LynceState.IsAutoFiring = false
        end

        -- SHOTGUN HẾT ĐẠN NGƯNG AIM ĐỂ GAME NẠP ĐẠN
        if isShotgun and currentAmmo <= 0 then
            return
        end

        local cond = 2
        local prioMode = 1
        local boneIdx = 1
        local speedVal = 50
        local fovVal = 30
        local maxDistMeters = 50
        local useVisCheck = false
        local igKnock = false
        local igBot = false
        
        -- Logic thêm vào: Dự đoán và Bù giật
        local predVal = 0 
        local recoilCompVal = 0 

        -- PHÂN LOẠI CẤU HÌNH THEO TRẠNG THÁI HIỆN TẠI
        if isShotgun and _G.LynceConfig.AimTouchSG then
            cond = _G.LynceState.CustomTextData.AimTouchSGCond or 1
            if _G.LynceConfig.AimTouchSGAutoFire then cond = 2 end
            if cond == 1 and not isFiring then return end
            prioMode = _G.LynceState.CustomTextData.AimTouchSGPrio or 1
            boneIdx = _G.LynceState.CustomTextData.AimTouchSGBone or 2
            speedVal = _G.LynceState.CustomTextData.AimTouchSGSpeed or 80
            fovVal = _G.LynceState.CustomTextData.AimTouchSGFOV or 40
            maxDistMeters = _G.LynceState.CustomTextData.AimTouchSGDist or 30
            useVisCheck = _G.LynceConfig.AimTouchSGVisCheck
            igKnock = _G.LynceConfig.AimTouchSGIgKnock
            igBot = _G.LynceConfig.AimTouchSGIgBot
            
        elseif isADS then
            if isSniper and _G.LynceConfig.AimTouchScopeSniper then
                cond = _G.LynceState.CustomTextData.AimTouchSniperCond or 2
                if cond == 1 and not isFiring then return end
                prioMode = _G.LynceState.CustomTextData.AimTouchSniperPrio or 1
                boneIdx = _G.LynceState.CustomTextData.AimTouchSniperBone or 1
                speedVal = _G.LynceState.CustomTextData.AimTouchSniperSpeed or 30
                fovVal = _G.LynceState.CustomTextData.AimTouchSniperFOV or 20
                maxDistMeters = _G.LynceState.CustomTextData.AimTouchSniperDist or 400
                useVisCheck = _G.LynceConfig.AimTouchSniperVisCheck
                igKnock = _G.LynceConfig.AimTouchSniperIgKnock
                igBot = _G.LynceConfig.AimTouchSniperIgBot
                predVal = _G.LynceState.CustomTextData.AimTouchSniperPred or 0 -- Lấy giá trị dự đoán Sniper
            elseif _G.LynceConfig.AimTouchScopeAll then
                cond = _G.LynceState.CustomTextData.AimTouchScopeCond or 1
                if cond == 1 and not isFiring then return end
                prioMode = _G.LynceState.CustomTextData.AimTouchScopePrio or 1
                boneIdx = _G.LynceState.CustomTextData.AimTouchScopeBone or 2
                speedVal = _G.LynceState.CustomTextData.AimTouchScopeSpeed or 40
                fovVal = _G.LynceState.CustomTextData.AimTouchScopeFOV or 20
                maxDistMeters = _G.LynceState.CustomTextData.AimTouchScopeDist or 300
                useVisCheck = _G.LynceConfig.AimTouchScopeVisCheck
                igKnock = _G.LynceConfig.AimTouchScopeIgKnock
                igBot = _G.LynceConfig.AimTouchScopeIgBot
                predVal = _G.LynceState.CustomTextData.AimTouchScopePred or 0 -- Lấy giá trị dự đoán Súng thường
                recoilCompVal = _G.LynceState.CustomTextData.AimTouchScopeRecoil or 0 -- Lấy giá trị bù giật
            else
                return
            end
        else
            if not _G.LynceConfig.AimTouchHipfire then return end
            cond = _G.LynceState.CustomTextData.AimTouchHipCond or 1
            if cond == 1 and not isFiring then return end 
            prioMode = _G.LynceState.CustomTextData.AimTouchHipPrio or 1
            boneIdx = _G.LynceState.CustomTextData.AimTouchHipBone or 1
            speedVal = _G.LynceState.CustomTextData.AimTouchHipSpeed or 50
            fovVal = _G.LynceState.CustomTextData.AimTouchHipFOV or 30
            maxDistMeters = _G.LynceState.CustomTextData.AimTouchHipDist or 250
            useVisCheck = _G.LynceConfig.AimTouchHipVisCheck
            igKnock = _G.LynceConfig.AimTouchHipIgKnock
            igBot = _G.LynceConfig.AimTouchHipIgBot
        end

        local currentMaxDist = maxDistMeters * 100 

        local enemies = _G.GetEnemyTargetsFromActors(currentMaxDist)
        if not enemies or #enemies == 0 then return end
        
        local FVector2D = import("Vector2D")
        local UGameplayStatics = import("GameplayStatics")
        local KismetMathLibrary = import("KismetMathLibrary")
        
        local camManager = UGameplayStatics.GetPlayerCameraManager(pc, 0)
        if not slua.isValid(camManager) then return end
        
        local camLoc = camManager:GetCameraLocation()
        if not camLoc then return end
        
        local ui_util = require("client.common.ui_util")
        if not ui_util then return end
        
        local viewportSize = ui_util.GetViewportSize()
        if not viewportSize then return end
        
        local centerX = viewportSize.X * 0.5
        local centerY = viewportSize.Y * 0.5
        
        local FOV_RADIUS = (fovVal / 100.0) * (viewportSize.X / 2.0)
        
        local bestTarget = nil
        local bestScore = 99999999 
        
        local selBoneName = "head"
        if boneIdx == 1 then selBoneName = "head"
        elseif boneIdx == 2 then selBoneName = "spine_03"
        elseif boneIdx == 3 then selBoneName = "spine_01"
        elseif boneIdx == 4 then selBoneName = "pelvis" end

        for i, target in ipairs(enemies) do
            if not slua.isValid(target) then goto continue end
            
            pcall(function()
                if slua.isValid(target.Mesh) then
                    target.Mesh.MeshComponentUpdateFlag = 0
                end
            end)
            
            if igKnock and target.HealthStatus == 1 then goto continue end
            
            if igBot then
                local tIsBot = false
                if target.bIsAI == true or target.IsAI == true then tIsBot = true end
                local pState = target.PlayerState
                if slua.isValid(pState) and (pState.bIsABot or pState.bIsBot) then tIsBot = true end
                if tIsBot then goto continue end
            end
            
            -- [FIX TỤT FPS]: Khóa tia Raycast check tường, chỉ quét 0.2s một lần (Đủ mượt mà không cháy CPU)
            if useVisCheck then
                local curTime = os.clock()
                local tId = type(target.GetUniqueID) == "function" and target:GetUniqueID() or tostring(target)
                _G.AimTouchVisCache = _G.AimTouchVisCache or {}
                if not _G.AimTouchVisCache[tId] or (curTime - _G.AimTouchVisCache[tId].time) > 0.2 then
                    local isHidden = true
                    pcall(function() if pc:LineOfSightTo(target) then isHidden = false end end)
                    _G.AimTouchVisCache[tId] = { hidden = isHidden, time = curTime }
                end
                if _G.AimTouchVisCache[tId].hidden then goto continue end
            end
            
            local tPos = target:GetBonePos(selBoneName, {X=0, Y=0, Z=0})
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.GetSocketLocation) == "function" then
                    tPos = target:GetSocketLocation(selBoneName)
                end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.K2_GetActorLocation) == "function" then
                    tPos = target:K2_GetActorLocation()
                    if tPos then
                        if boneIdx == 1 then tPos.Z = tPos.Z + 70
                        elseif boneIdx == 2 then tPos.Z = tPos.Z + 40
                        elseif boneIdx == 3 then tPos.Z = tPos.Z + 20 end
                    end
                end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then goto continue end
            
            local screen = FVector2D()
            local success = pc:ProjectWorldLocationToScreen(tPos, screen, false)
            if not success or screen.X <= 0 or screen.Y <= 0 then goto continue end
            
            local dx = screen.X - centerX
            local dy = screen.Y - centerY
            local distScreen = math.sqrt(dx*dx + dy*dy)
            
            if distScreen > FOV_RADIUS then goto continue end
            
            local currentScore = distScreen
            if prioMode == 2 then currentScore = player:GetDistanceTo(target)
            elseif prioMode == 3 then currentScore = target.Health or 100
            elseif prioMode == 4 then 
                local hp = target.Health or 100
                local maxhp = target.HealthMax or 100
                if maxhp <= 0 then maxhp = 100 end
                currentScore = hp / maxhp
            end
            
            if currentScore < bestScore then
                bestScore = currentScore
                bestTarget = target
            end
            
            ::continue::
        end
        
        if not slua.isValid(bestTarget) then return end
        
        local finalBonePos = bestTarget:GetBonePos(selBoneName, {X=0, Y=0, Z=0})
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then
            if type(bestTarget.GetSocketLocation) == "function" then
                finalBonePos = bestTarget:GetSocketLocation(selBoneName)
            end
        end
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then
            if type(bestTarget.K2_GetActorLocation) == "function" then
                finalBonePos = bestTarget:K2_GetActorLocation()
                if finalBonePos then
                    if boneIdx == 1 then finalBonePos.Z = finalBonePos.Z + 70
                    elseif boneIdx == 2 then finalBonePos.Z = finalBonePos.Z + 40
                    elseif boneIdx == 3 then finalBonePos.Z = finalBonePos.Z + 20 end
                end
            end
        end
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then return end
        
        -- LOGIC 1: PREDICTION (DỰ ĐOÁN HƯỚNG CHẠY)
        if predVal > 0 then
            pcall(function()
                local tVelocity = nil
                -- Unreal Engine Lấy vector di chuyển của địch
                if type(bestTarget.GetVelocity) == "function" then
                    tVelocity = bestTarget:GetVelocity()
                end
                
                -- Nếu địch đang di chuyển
                if tVelocity and (tVelocity.X ~= 0 or tVelocity.Y ~= 0) then
                    local distToEnemy = player:GetDistanceTo(bestTarget) / 100.0 -- Khoảng cách mét
                    
                    -- Tính toán thời gian đạn bay (Time-Of-Flight) tỉ lệ thuận với khoảng cách và biến truyền vào
                    -- Hệ số 800.0 đại diện cho tốc độ đạn rơi giả lập, 50.0 là mức trung bình slider
                    local ToF = (distToEnemy / 800.0) * (predVal / 50.0) 
                    
                    -- Dịch chuyển toạ độ Aim lên trước hướng chạy
                    finalBonePos.X = finalBonePos.X + (tVelocity.X * ToF)
                    finalBonePos.Y = finalBonePos.Y + (tVelocity.Y * ToF)
                end
            end)
        end

        local rot = KismetMathLibrary.FindLookAtRotation(camLoc, finalBonePos)
        if not rot then return end
        
        local currentRot = pc:GetControlRotation()
        if not currentRot then return end
        
        local deltaYaw = rot.Yaw - currentRot.Yaw
        local deltaPitch = rot.Pitch - currentRot.Pitch
        
        -- [BẮT ĐẦU FIX] Bù trừ chênh lệch Camera khi mở ống ngắm (ADS) để không bị lệch tâm
        if isADS then
            local camRot = nil
            if type(camManager.GetCameraRotation) == "function" then
                camRot = camManager:GetCameraRotation()
            end
            if camRot then
                deltaYaw = deltaYaw - (camRot.Yaw - currentRot.Yaw)
                deltaPitch = deltaPitch - (camRot.Pitch - currentRot.Pitch)
            end
        end
        -- [KẾT THÚC FIX]

        if deltaYaw > 180 then deltaYaw = deltaYaw - 360 end
        if deltaYaw < -180 then deltaYaw = deltaYaw + 360 end
        if deltaPitch > 180 then deltaPitch = deltaPitch - 360 end
        if deltaPitch < -180 then deltaPitch = deltaPitch + 360 end
        
        local smoothFactor = 0.0
        if speedVal >= 100 then
            smoothFactor = 1.0
        else
            smoothFactor = (speedVal / 100.0) * 0.3
            if smoothFactor < 0.01 then smoothFactor = 0.01 end
        end
        
        local finalPitch = currentRot.Pitch + (deltaPitch * smoothFactor)
        local finalYaw = currentRot.Yaw + (deltaYaw * smoothFactor)
        
        -- LOGIC 2: RECOIL COMPENSATION (ÉP TÂM / BÙ GIẬT TRÁNH BẮN QUÁ ĐẦU)
        -- Chỉ ép tâm khi súng đang bắn và giá trị Recoil > 0 (Dùng cho Súng thường)
        if recoilCompVal > 0 and isFiring then
            -- Trong UE4, kéo Pitch xuống (nhỏ đi) tương đương với việc ghìm tâm màn hình xuống
            -- Slider recoilCompVal (0-50), mỗi frame bù một lượng dựa trên độ giật
            local pullDownForce = (recoilCompVal / 50.0) * 1.5 -- Điều chỉnh nhân tố 1.5 tuỳ ý để ép gắt hơn
            finalPitch = finalPitch - pullDownForce
        end

        local finalRot = { Pitch = finalPitch, Yaw = finalYaw, Roll = 0 }
        pc:SetControlRotation(finalRot, "AimTouch")
        
        if isShotgun and _G.LynceConfig.AimTouchSGAutoFire then
            pcall(function()
                local distToTarget = player:GetDistanceTo(bestTarget) / 100
                if distToTarget <= maxDistMeters then
                    player.bIsWeaponFiring = true
                    if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(true) end
                    if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(true) end
                    local wepMgr = player.WeaponManagerComponent
                    if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = true end
                    
                    local currentWep = player:GetCurrentWeapon()
                    if slua.isValid(currentWep) and type(currentWep.StartFire) == "function" then 
                        currentWep:StartFire() 
                    end
                    _G.LynceState.IsAutoFiring = true
                end
            end)
        end

    end)
end

-- ========================================== 
-- HỆ THỐNG WALL & ESP VẬT PHẨM/PHƯƠNG TIỆN SIÊU MƯỢT (OPTIMIZED DƯỚI 70M)
-- ========================================== 
-- ========================================== 
-- HỆ THỐNG WALL PHƯƠNG TIỆN SIÊU MƯỢT (ĐÃ XÓA ITEM ESP)
-- ========================================== 
_G.LastScanVehicleTime = 0
_G.AppliedVehicleWall = {}

_G.RunOptimizedVehicleESP = function()
    local curTime = os.clock()

    -- 1. QUÉT ACTOR VÀ XỬ LÝ VẬT LÝ 1.0 GIÂY / LẦN (Chống Drop FPS)
    if curTime - _G.LastScanVehicleTime > 1.0 then
        _G.LastScanVehicleTime = curTime
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end

        -- XỬ LÝ WALL PHƯƠNG TIỆN (Giữ nguyên khoảng cách nhìn xa 200m)
        if _G.LynceConfig.WallVehicle then
            local ASTExtraVehicleBase = import("STExtraVehicleBase")
            if ASTExtraVehicleBase then
                local Actors = Game:GetActorsByClass(ASTExtraVehicleBase)
                if Actors then
                    local count = Actors:Num() or 0
                    for i = 0, count - 1 do
                        local vehicle = Actors:Get(i)
                        if slua.isValid(vehicle) and vehicle.GetMesh then
                            local dist = player:GetDistanceTo(vehicle)
                            if dist <= 200000 then 
                                local vId = tostring(vehicle)
                                if not _G.AppliedVehicleWall[vId] then
                                    local mesh = vehicle:GetMesh()
                                    if slua.isValid(mesh) then
                                        local matInterface = mesh:GetMaterial(0)
                                        if slua.isValid(matInterface) then
                                            local baseMat = matInterface:GetBaseMaterial()
                                            if slua.isValid(baseMat) then
                                                baseMat.bDisableDepthTest = true
                                                baseMat.BlendMode = 2
                                                _G.AppliedVehicleWall[vId] = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else 
            _G.AppliedVehicleWall = {} 
        end
    end
end


-- ========================================== 
-- UI WIDGET ĐẾM ĐỊCH & KHOẢNG CÁCH GẦN NHẤT (NEW ESP LOGIC)
-- ========================================== 
local BTN_BP = "/Game/UMG/UI_BP/Common/BaseComponent/CommonBaseComponent_TextButton_UIBP.CommonBaseComponent_TextButton_UIBP"
local EnemyCounterWidget = nil
local WarningTargetWidget = nil
local LastCounterTime = 0

-- THÊM HÀM DỌN DẸP WIDGET KHI THOÁT TRẬN
function _G.CleanUpEnemyCounterWidget()
    if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then
        EnemyCounterWidget:RemoveFromParent()
    end
    EnemyCounterWidget = nil

    if WarningTargetWidget and slua.isValid(WarningTargetWidget) then
        WarningTargetWidget:RemoveFromParent()
    end
    WarningTargetWidget = nil
end

-- TẠO UI: ĐẾM ĐỊCH (GỐC)
local function CreateEnemyCounterWidget()
    if EnemyCounterWidget then
        if slua.isValid(EnemyCounterWidget) then return EnemyCounterWidget else EnemyCounterWidget = nil end
    end

    pcall(function()
        local btn = slua.loadUI(BTN_BP)
        if not btn or not slua.isValid(btn) then return end
        require("game_frontend_hud").AddToContainer(UIContainers.Top, btn, 10500)
        
   if btn.RichText_Content then
          btn.RichText_Content:SetText("Musuh: 0  |  Terdekat: 0m")
          local fontInfo = btn.RichText_Content.Font
          if fontInfo then fontInfo.Size = 16 btn.RichText_Content:SetFont(fontInfo) end
      end
        
        local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
        local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(btn)
        if slot then
            slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
            slot:SetAlignment(FVector2D(0.5, 0))
            slot:SetPosition(FVector2D(0, 30))
            slot:SetSize(FVector2D(240, 36))
        end
        btn:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        EnemyCounterWidget = btn
    end)
    return EnemyCounterWidget
end

-- TẠO UI: CẢNH BÁO ĐỊCH NGẮM (ĐỘC LẬP)
local function CreateWarningTargetWidget()
    if WarningTargetWidget then
        if slua.isValid(WarningTargetWidget) then return WarningTargetWidget else WarningTargetWidget = nil end
    end

    pcall(function()
        local btn = slua.loadUI(BTN_BP)
        if not btn or not slua.isValid(btn) then return end
        require("game_frontend_hud").AddToContainer(UIContainers.Top, btn, 10501) -- Z-Order cao hơn để nổi lên
        
   if btn.RichText_Content then
        -- Teks merah peringatan keras
        btn.RichText_Content:SetText("MUSUH SEDANG MELIHAT KE ARAH ANDA")
        local fontInfo = btn.RichText_Content.Font
        if fontInfo then fontInfo.Size = 18 btn.RichText_Content:SetFont(fontInfo) end
    end
        
        local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
        local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(btn)
        if slot then
            slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
            slot:SetAlignment(FVector2D(0.5, 0))
            slot:SetPosition(FVector2D(0, 75)) -- Nằm bên dưới UI đếm địch (Y=75)
            slot:SetSize(FVector2D(260, 36))
        end
        btn:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) -- Mặc định ẩn, chỉ hiện khi bị ngắm
        WarningTargetWidget = btn
    end)
    return WarningTargetWidget
end

-- VÒNG LẶP CHUNG (TÍNH TOÁN 1 LẦN CHO CẢ 2 UI ĐỂ CHỐNG DROP FPS)
local function _M_DrawCounter()
    if isExpired then
        _G.CleanUpEnemyCounterWidget()
        return
    end

    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then 
            if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then
                EnemyCounterWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
            if WarningTargetWidget and slua.isValid(WarningTargetWidget) then
                WarningTargetWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
            return 
        end

        local widgetCounter = CreateEnemyCounterWidget()
        local widgetWarning = CreateWarningTargetWidget()

        if widgetCounter and slua.isValid(widgetCounter) then
            widgetCounter:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end

        -- [TỐI ƯU FPS] Khóa nhịp tính toán 0.5 giây / lần để tránh quá tải CPU
        local curTime = os.clock()
        if (curTime - LastCounterTime) > 0.5 then
            LastCounterTime = curTime
            
            local myTeam = player.TeamID or (type(player.GetTeamID) == "function" and player:GetTeamID()) or 0
            local count = 0
            local nearest = 9999
            local isBeingTargeted = false -- Trạng thái cảnh báo
            
            local KismetMathLibrary = import("KismetMathLibrary")
            local pc = player:GetPlayerControllerSafety()

            local allCharacters = {}
            if GameplayData.GetAllPlayerCharacters then
                allCharacters = GameplayData.GetAllPlayerCharacters()
            elseif GameplayData.GameCharacters then
                for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end
            end

            for _, tPawn in pairs(allCharacters) do
                if slua.isValid(tPawn) and tPawn ~= player then
                    local isAlive = false
                    if tPawn.HealthStatus ~= nil then
                        isAlive = (tPawn.HealthStatus ~= 2)
                    else
                        isAlive = (tPawn.Health or 0) > 0 or (type(tPawn.IsAlive) == "function" and tPawn:IsAlive())
                    end
                    
                    if isAlive then
                        local tTeam = tPawn.TeamID or (type(tPawn.GetTeamID) == "function" and tPawn:GetTeamID()) or 0
                        if tTeam ~= myTeam then
                            count = count + 1
                            local d = math.floor(player:GetDistanceTo(tPawn) / 100)
                            if d < nearest then nearest = d end
                            
                            -- ========================================================
                            -- LOGIC CHECK ĐỊCH NGẮM (Chỉ tính khi khoảng cách < 400m)
                            -- ========================================================
                            if _G.LynceConfig.EspAimWarning and not isBeingTargeted and d < 400 then
                                local eLoc = type(tPawn.K2_GetActorLocation) == "function" and tPawn:K2_GetActorLocation()
                                local pLoc = type(player.K2_GetActorLocation) == "function" and player:K2_GetActorLocation()
                                
                                if eLoc and pLoc and KismetMathLibrary then
                                    local lookRot = KismetMathLibrary.FindLookAtRotation(eLoc, pLoc)
                                    local eRot = nil
                                    
                                    if type(tPawn.GetControlRotation) == "function" then
                                        eRot = tPawn:GetControlRotation()
                                    elseif type(tPawn.GetActorRotation) == "function" then
                                        eRot = tPawn:GetActorRotation()
                                    end
                                    
                                    if eRot and lookRot then
                                        local dYaw = math.abs(eRot.Yaw - lookRot.Yaw)
                                        if dYaw > 180 then dYaw = 360 - dYaw end
                                        
                                        local dPitch = math.abs(eRot.Pitch - lookRot.Pitch)
                                        if dPitch > 180 then dPitch = 360 - dPitch end
                                        
                                        -- Địch hướng nòng súng sai lệch < 15 độ
                                        if dYaw < 15 and dPitch < 20 then
                                            -- Áp dụng logic Check Tường (VisCheck)
                                            if _G.LynceConfig.EspAimWarningVisCheck then
                                                if slua.isValid(pc) and type(pc.LineOfSightTo) == "function" then
                                                    if pc:LineOfSightTo(tPawn) then
                                                        isBeingTargeted = true
                                                    end
                                                end
                                            else
                                                -- Xuyên tường báo luôn
                                                isBeingTargeted = true
                                            end
                                        end
                                    end
                                end
                            end
                            -- ========================================================
                        end
                    end
                end
            end

            -- Cập nhật nội Lynce UI đếm địch (Khung 1)
            if widgetCounter and widgetCounter.RichText_Content then
       widgetCounter.RichText_Content:SetText(string.format("Musuh Di Sekitar: %d  |  Terdekat: %dm", count, count > 0 and nearest or 0))
   end

            -- Ẩn/Hiện UI Cảnh báo độc lập (Khung 2)
            if widgetWarning and slua.isValid(widgetWarning) then
                if _G.LynceConfig.EspAimWarning and isBeingTargeted then
                    widgetWarning:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                else
                    widgetWarning:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                end
            end
        end
    end)
end

-- ========================================== 
-- VÒNG LẶP CHÍNH (MAIN LOOP) TỐI ƯU CỰC MẠNH
-- ========================================== 
local function MainLoop()
    if isExpired then return end

    -- =====================================================================
    -- HỆ THỐNG LẤY HWID GỐC & ĐỔI HWID ẢO (SPOOFER) CHỐNG BAN
    -- =====================================================================
    pcall(function()
        local SystemLib = import("KismetSystemLibrary")
        if SystemLib and not _G.FakeHWID_Hooked then
            -- Lưu lại hàm lấy HWID gốc
            _G.Original_GetDeviceId = SystemLib.GetDeviceId

            -- Ghi đè hàm của game
            SystemLib.GetDeviceId = function(...)
                if _G.LynceConfig.FakeHWID then
                    if not _G.FakeHWID_String then
                        -- Tạo ngẫu nhiên một HWID ảo 32 ký tự
                        local chars = "0123456789abcdef"
                        local hwid = ""
                        for i = 1, 32 do 
                            hwid = hwid .. chars:sub(math.random(1, 16), math.random(1, 16)) 
                        end
                        _G.FakeHWID_String = hwid
                    end
                    -- Trả về HWID ảo
                    return _G.FakeHWID_String
                end
                
                -- Nếu tắt Fake HWID thì trả về HWID thật
                if _G.Original_GetDeviceId then return _G.Original_GetDeviceId(...) end
                return "UNKNOWN"
            end
            _G.FakeHWID_Hooked = true
        end
    end)

    -- Hàm độc lập để bạn lấy HWID Gốc (nếu sau này cần hiển thị)
    _G.GetOriginalHWID = function()
        if _G.Original_GetDeviceId then
            return tostring(_G.Original_GetDeviceId())
        end
        local SystemLib = import("KismetSystemLibrary")
        if SystemLib and type(SystemLib.GetDeviceId) == "function" then
            return tostring(SystemLib.GetDeviceId())
        end
        return "UNKNOWN_DEVICE"
    end
    -- =====================================================================

    if _G.LynceState.CustomTextData == nil then 
        _G.LynceState.CustomTextData = {OuterSpeed = 10, InnerSpeed = 10, HRecoil = 0.3, VRecoil = 0.3, MagicHead = 1.0, MagicBody = 1.0, MagicLegs = 1.0, IpadViewFOV = 120, AimTouchHipPrio = 1, AimTouchHipBone = 1, AimTouchHipCond = 1, AimTouchHipSpeed = 50, AimTouchHipFOV = 30, AimTouchHipDist = 250, AimTouchSGPrio = 1, AimTouchSGBone = 2, AimTouchSGCond = 1, AimTouchSGSpeed = 80, AimTouchSGFOV = 40, AimTouchSGDist = 30, AimTouchScopePrio = 1, AimTouchScopeBone = 2, AimTouchScopeCond = 1, AimTouchScopeSpeed = 40, AimTouchScopeFOV = 20, AimTouchScopeDist = 300, AimTouchSniperPrio = 1, AimTouchSniperBone = 1, AimTouchSniperCond = 2, AimTouchSniperSpeed = 30, AimTouchSniperFOV = 20, AimTouchSniperDist = 400}
    end

    local okData, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData") 
    if not okData or not GameplayData then return end 
    local pc = GameplayData.GetPlayerController() 
    local localPlayer = nil
    if Valid(pc) then localPlayer = pc:GetPlayerCharacterSafety() end 

    -- XÓA SẠCH SÀNH SANH RÁC KHỎI RAM KHI BẠN CHẾT, ĐỔI MAP, VÀO SẢNH
    if not Valid(localPlayer) then 
        if _G.LynceState.TrackedMarks then
            for markId, _ in pairs(_G.LynceState.TrackedMarks) do
                SafeRemoveMark(markId)
            end
        end
        _G.LynceState.TrackedMarks = {} 
        
        -- Dọn sạch object UE4 MIDs để giải phóng RAM tối đa qua nhiều trận
        for key, data in pairs(_G.LynceState.EnemyMarks) do
            if data and data.MIDs then
                for meshStr, midTable in pairs(data.MIDs) do
                    for k, _ in pairs(midTable) do midTable[k] = nil end
                end
                data.MIDs = nil
            end
            if data and data.MIDs_V3 then
                for meshStr, midTable in pairs(data.MIDs_V3) do
                    for k, _ in pairs(midTable) do midTable[k] = nil end
                end
                data.MIDs_V3 = nil
            end
        end
        
        _G.LynceState.EnemyMarks = {}
        _G.AK_OrigHitboxes = {}
        _G.AK_ModdedPhysAssets = {}
        _G.LynceState.PrevGraphicsState = {}
        
        -- DỌN DẸP WIDGET ĐẾM KẺ ĐỊCH VÀ KHOẢNG CÁCH KHI RA SẢNH (TRÁNH LỖI ĐÈ UI)
        if _G.CleanUpEnemyCounterWidget then _G.CleanUpEnemyCounterWidget() end
        return 
    end

    local Cached_PPM = nil
    pcall(function() Cached_PPM = import("PostProcessManager").GetInstance() end)
    local Cached_SecurityCommonUtils = nil
    pcall(function() Cached_SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils") end)
    local Cached_MyHUD = pc and pc.MyHUD or nil

    if _G.LynceConfig.UnlockFPS then InitializeGraphicsUnlock() end
    InitializeNativeESP()
    ShowLynceVIPMenu()
    
    -- [GỌI LOGIC WALL VEHICLE VÀO VÒNG LẶP]
    if _G.LynceConfig.WallVehicle then
        _G.RunOptimizedVehicleESP()
    end
    
    -- HOÀN TRẢ GÓC NHÌN NGAY LẬP TỨC NẾU TẮT IPAD VIEW
    if _G.LynceConfig.IpadView and _G.LynceState.CustomTextData then
        pcall(function()
            local targetTPP = _G.LynceState.CustomTextData.IpadViewFOV or 120
            local uTPPCam = localPlayer.ThirdPersonCameraComponent
            if Valid(uTPPCam) and not localPlayer.bIsWeaponAiming then
                if uTPPCam.FieldOfView ~= targetTPP then uTPPCam.FieldOfView = targetTPP end
            end
        end)
    else
        pcall(function()
            local uTPPCam = localPlayer.ThirdPersonCameraComponent
            if Valid(uTPPCam) and not localPlayer.bIsWeaponAiming then
                if uTPPCam.FieldOfView ~= 90 then uTPPCam.FieldOfView = 90 end
            end
        end)
    end

    -- ========================================================
    -- LOGIC AIMBOT V2 ROYAL/CUSTOM
    -- ========================================================
    if _G.LynceConfig.AimTouchEnable then
        _G.AimTouch()
    end
    
    -- [THÊM MỚI] LOGIC GLOW SÚNG (ĐỘC LẬP & SIÊU MƯỢT 0.5s/Lần - ĐẢM BẢO 0% DROP FPS)
    if not _G.LastGlowTime or (os.clock() - _G.LastGlowTime) > 0.5 then
        _G.LastGlowTime = os.clock()
        if _G.ApplyWeaponGlow then _G.ApplyWeaponGlow(localPlayer) end
    end

    -- ========================================================
    -- LOGIC BÙ GIẬT (GHÌM TÂM) CHỈ DÀNH RIÊNG CHO AIMBOT GỐC (ĐÃ FIX LAG ĐÔNG NGƯỜI)
    -- ========================================================
    pcall(function()
        if _G.LynceConfig.CustomAimbot and localPlayer.bIsWeaponFiring and localPlayer.bIsGunADS then
            local outerRecoilVal = _G.LynceState.CustomTextData.OuterRecoil or 0
            if outerRecoilVal > 0 then
                local curTime = os.clock()
                
                -- [FIX CPU CỰC MẠNH]: Quét mục tiêu 0.2s/lần thay vì 100 lần/giây để tránh quá tải máy khi check FOV
                if not _G.RecoilTargetCacheTime or (curTime - _G.RecoilTargetCacheTime) > 0.2 then
                    _G.RecoilTargetCacheTime = curTime
                    _G.HasRecoilTargetCached = false
                    
                    local ui_util = require("client.common.ui_util")
                    if ui_util then
                        local viewportSize = ui_util.GetViewportSize()
                        if viewportSize then
                            local centerX = viewportSize.X * 0.5
                            local centerY = viewportSize.Y * 0.5
                            local FOV_RADIUS = (6 / 100.0) * (viewportSize.X / 2.0) 
                            
                            local enemies = _G.GetEnemyTargetsFromActors(40000) 
                            if enemies and #enemies > 0 then
                                local FVector2D = import("Vector2D")
                                for _, target in ipairs(enemies) do
                                    if slua.isValid(target) and target.HealthStatus ~= 1 then 
                                        local tPos = type(target.K2_GetActorLocation) == "function" and target:K2_GetActorLocation() or nil
                                        if tPos then
                                            local screen = FVector2D()
                                            if pc:ProjectWorldLocationToScreen(tPos, screen, false) and screen.X > 0 and screen.Y > 0 then
                                                local dx = screen.X - centerX
                                                local dy = screen.Y - centerY
                                                if math.sqrt(dx*dx + dy*dy) <= FOV_RADIUS then
                                                    _G.HasRecoilTargetCached = true
                                                    break 
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if _G.HasRecoilTargetCached then
                    local currentRot = pc:GetControlRotation()
                    if currentRot then
                        local pullDownForce = (outerRecoilVal / 50.0) * 1.5
                        currentRot.Pitch = currentRot.Pitch - pullDownForce
                        pc:SetControlRotation(currentRot, "CustomAimbotRecoil")
                    end
                end
            end
        else
            _G.HasRecoilTargetCached = false
        end
    end)
    

    -- CHẶN HIGGSBOSON THEO THỜI GIAN THỰC LÀM AN TOÀN TUYỆT ĐỐI MÀ KHÔNG GÂY VĂNG GAME
    pcall(function()
        if Valid(pc) then
            if pc.HiggsBoson then pc.HiggsBoson.bMHActive = false; pc.HiggsBoson.bCallPreReplication = false end
            if pc.HiggsBosonComponent then pc.HiggsBosonComponent.bMHActive = false; pc.HiggsBosonComponent.bCallPreReplication = false end
        end
    end)

    -- HOÀN TRẢ VÀ THIẾT LẬP AIMBOT HEAD COMPONENT BẬT/TẮT TỨC THÌ
    pcall(function()
        local autoComp = localPlayer.AutoAimComp
        if Valid(autoComp) then
            if not _G.LynceState.OrigAutoAimCompCached then
                _G.LynceState.OrigAutoAimCompCached = {
                    bOnlyHitHead = autoComp.bOnlyHitHead,
                    HeadBoneName = autoComp.HeadBoneName,
                    Bones = autoComp.Bones,
                    ChestBoneName = autoComp.ChestBoneName,
                    PelvisBoneName = autoComp.PelvisBoneName,
                    HeadPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.HeadPriority,
                    ChestPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.ChestPriority,
                    PelvisPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.PelvisPriority
                }
            end
            
            if _G.LynceConfig.AutoHead then
                autoComp.bOnlyHitHead = true
                autoComp.HeadBoneName = "Head"
                pcall(function() autoComp.Bones = {"Head"} end)
                autoComp.ChestBoneName = "Head"
                autoComp.PelvisBoneName = "Head"
                if autoComp.AimAssistConfig then
                    autoComp.AimAssistConfig.HeadPriority = 100
                    autoComp.AimAssistConfig.ChestPriority = 100
                    autoComp.AimAssistConfig.PelvisPriority = 100
                end
            else
                local orig = _G.LynceState.OrigAutoAimCompCached
                autoComp.bOnlyHitHead = orig.bOnlyHitHead
                autoComp.HeadBoneName = orig.HeadBoneName
                pcall(function() autoComp.Bones = orig.Bones or {"Spine_01", "Pelvis", "Head"} end)
                autoComp.ChestBoneName = orig.ChestBoneName
                autoComp.PelvisBoneName = orig.PelvisBoneName
                if autoComp.AimAssistConfig then
                    autoComp.AimAssistConfig.HeadPriority = orig.HeadPriority or 1
                    autoComp.AimAssistConfig.ChestPriority = orig.ChestPriority or 1
                    autoComp.AimAssistConfig.PelvisPriority = orig.PelvisPriority or 1
                end
            end
        end
    end)

    if _G.LynceConfig.WallClimb then
        pcall(function()
            local charMove = localPlayer.CharacterMovement
            if Valid(charMove) then
                if not _G.LynceState.WallClimbOriginals then
                    _G.LynceState.WallClimbOriginals = { WalkableFloorAngle = charMove.WalkableFloorAngle, MaxStepHeight = charMove.MaxStepHeight }
                end
                charMove.WalkableFloorAngle = 199.0
                charMove.MaxStepHeight = 999.0
                _G.LynceState.WallClimbApplied = true
            end
        end)
    elseif _G.LynceState.WallClimbApplied then
        pcall(function()
            local charMove = localPlayer.CharacterMovement
            if Valid(charMove) and _G.LynceState.WallClimbOriginals then
                charMove.WalkableFloorAngle = _G.LynceState.WallClimbOriginals.WalkableFloorAngle or 50.0
                charMove.MaxStepHeight = _G.LynceState.WallClimbOriginals.MaxStepHeight or 45.0
            end
        end)
        _G.LynceState.WallClimbApplied = false
    end

    if _G.LynceConfig.FastCar then
        pcall(function()
            local currentVehicle = localPlayer.CurrentVehicle or (type(localPlayer.GetVehicle) == "function" and localPlayer:GetVehicle())
            if Valid(currentVehicle) then
                local rootComp = currentVehicle.RootComponent or (type(currentVehicle.K2_GetRootComponent) == "function" and currentVehicle:K2_GetRootComponent())
                
                if Valid(rootComp) and type(rootComp.SetAllPhysicsLinearVelocity) == "function" then
                    local isAccelerating = false
                    local moveComp = currentVehicle.VehicleMovement or currentVehicle.MovementComponent
                    if Valid(moveComp) then
                        local throttle = moveComp.ThrottleInput or 0
                        if type(moveComp.GetThrottleInput) == "function" then
                            throttle = moveComp:GetThrottleInput()
                        end
                        if throttle > 0.05 or throttle < -0.05 then 
                            isAccelerating = true
                        end
                    end
                    if currentVehicle.bIsPressingGas or (currentVehicle.Throttle and currentVehicle.Throttle ~= 0) then
                        isAccelerating = true
                    end

                    local currentVel = nil
                    if type(currentVehicle.GetVelocity) == "function" then
                        currentVel = currentVehicle:GetVelocity()
                    elseif type(rootComp.GetPhysicsLinearVelocity) == "function" then
                        currentVel = rootComp:GetPhysicsLinearVelocity()
                    elseif rootComp.ComponentVelocity then
                        currentVel = rootComp.ComponentVelocity
                    end

                    if currentVel then
                        local currentSpeed = math.sqrt(currentVel.X^2 + currentVel.Y^2)
                        local minSpeedToBoost = 50.0   
                        local maxSpeed = 4444.0        
                        local accelFactor = 1.5        
                        local brakeFactor = 0.85       
                        
                        if currentSpeed > minSpeedToBoost then
                            local dirX = currentVel.X / currentSpeed
                            local dirY = currentVel.Y / currentSpeed
                            
                            if isAccelerating then
                                local targetSpeed = currentSpeed * accelFactor
                                if targetSpeed > maxSpeed then targetSpeed = maxSpeed end
                                local newX = dirX * targetSpeed
                                local newY = dirY * targetSpeed
                                local newZ = currentVel.Z 
                                rootComp:SetAllPhysicsLinearVelocity(FVector(newX, newY, newZ), false)
                            else
                                local targetSpeed = currentSpeed * brakeFactor
                                if targetSpeed > minSpeedToBoost then
                                    local newX = dirX * targetSpeed
                                    local newY = dirY * targetSpeed
                                    local newZ = currentVel.Z 
                                    rootComp:SetAllPhysicsLinearVelocity(FVector(newX, newY, newZ), false)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    -- HOÀN TRẢ ĐỒ HỌA NGAY LẬP TỨC NẾU TẮT (TẮT LÀ TẮT LIỀN)
    local now = os.clock()
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if gi then
            if _G.LynceConfig.RemoveGrass and not _G.LynceState.PrevGraphicsState.RemoveGrass then
                gi:ExecuteCMD("grass.DensityScale", "0")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "1")
                _G.LynceState.PrevGraphicsState.RemoveGrass = true
            elseif not _G.LynceConfig.RemoveGrass and _G.LynceState.PrevGraphicsState.RemoveGrass then
                gi:ExecuteCMD("grass.DensityScale", "1")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "0")
                _G.LynceState.PrevGraphicsState.RemoveGrass = false
            end

            -- LOGIC XÓA CÂY
            if _G.LynceConfig.RemoveTrees and not _G.LynceState.PrevGraphicsState.RemoveTrees then
                gi:ExecuteCMD("foliage.DensityScale", "0")
                gi:ExecuteCMD("r.Foliage.DensityScale", "0")
                gi:ExecuteCMD("foliage.MinimumScreenSize", "10000")
                gi:ExecuteCMD("r.DisableTreeRender", "1")
                _G.LynceState.PrevGraphicsState.RemoveTrees = true
            elseif not _G.LynceConfig.RemoveTrees and _G.LynceState.PrevGraphicsState.RemoveTrees then
                gi:ExecuteCMD("foliage.DensityScale", "1")
                gi:ExecuteCMD("r.Foliage.DensityScale", "1")
                gi:ExecuteCMD("foliage.MinimumScreenSize", "0.0001")
                gi:ExecuteCMD("r.DisableTreeRender", "0")
                _G.LynceState.PrevGraphicsState.RemoveTrees = false
            end
            
            if _G.LynceConfig.RemoveFog and not _G.LynceState.PrevGraphicsState.RemoveFog then
                gi:ExecuteCMD("r.SkyAtmosphere", "1") 
                gi:ExecuteCMD("r.Fog", "0")           
                gi:ExecuteCMD("r.VolumetricFog", "0") 
                _G.LynceState.PrevGraphicsState.RemoveFog = true
            elseif not _G.LynceConfig.RemoveFog and _G.LynceState.PrevGraphicsState.RemoveFog then
                gi:ExecuteCMD("r.SkyAtmosphere", "1") 
                gi:ExecuteCMD("r.Fog", "1")           
                gi:ExecuteCMD("r.VolumetricFog", "1") 
                _G.LynceState.PrevGraphicsState.RemoveFog = false
            end
            
            if _G.LynceConfig.WhiteBody and not _G.LynceState.PrevGraphicsState.WhiteBody then
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "2")
                gi:ExecuteCMD("r.CharacterDiffusePower", "5")
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "100")
                _G.LynceState.PrevGraphicsState.WhiteBody = true
            elseif not _G.LynceConfig.WhiteBody and _G.LynceState.PrevGraphicsState.WhiteBody then
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "0")
                gi:ExecuteCMD("r.CharacterDiffusePower", "1")
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "1")
                _G.LynceState.PrevGraphicsState.WhiteBody = false
            end
            
            if _G.LynceConfig.ColorBodyV2 and not _G.LynceState.PrevGraphicsState.ColorBodyV2 then
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "4")
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "200")
                gi:ExecuteCMD("r.CharacterDiffusePower", "200")
                _G.LynceState.PrevGraphicsState.ColorBodyV2 = true
            elseif not _G.LynceConfig.ColorBodyV2 and _G.LynceState.PrevGraphicsState.ColorBodyV2 then
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "1")
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "0")
                gi:ExecuteCMD("r.CharacterDiffusePower", "1")
                _G.LynceState.PrevGraphicsState.ColorBodyV2 = false
            end
            
            -- LOGIC BLACKSKY
            if _G.LynceConfig.BlackSky and not _G.LynceState.PrevGraphicsState.BlackSky then
                gi:ExecuteCMD("r.CylinderMaxDrawHeight", "9999")
                _G.LynceState.PrevGraphicsState.BlackSky = true
            elseif not _G.LynceConfig.BlackSky and _G.LynceState.PrevGraphicsState.BlackSky then
                gi:ExecuteCMD("r.CylinderMaxDrawHeight", "0000")
                _G.LynceState.PrevGraphicsState.BlackSky = false
            end
        end
    end)

    pcall(function()
        local weapon = nil
        pcall(function()
            local weaponManager = localPlayer.WeaponManagerComponent
            if Valid(weaponManager) and type(weaponManager.GetCurrentWeapon) == "function" then
                weapon = weaponManager:GetCurrentWeapon()
            end
        end)
        if not Valid(weapon) then
            if type(localPlayer.GetCurrentShootWeapon) == "function" then weapon = localPlayer:GetCurrentShootWeapon()
            elseif type(localPlayer.GetCurrentWeapon) == "function" then weapon = localPlayer:GetCurrentWeapon() end
        end

        if Valid(weapon) then
            local entities = {}
            if Valid(weapon.ShootWeaponEntity_GEN_VARIABLE) then table.insert(entities, weapon.ShootWeaponEntity_GEN_VARIABLE) end
            if Valid(weapon.ShootWeaponEntity) then table.insert(entities, weapon.ShootWeaponEntity) end
            if Valid(weapon.ShootWeaponComponent) and Valid(weapon.ShootWeaponComponent.ShootWeaponEntityComponent) then 
                table.insert(entities, weapon.ShootWeaponComponent.ShootWeaponEntityComponent) 
            end

            for _, entity in ipairs(entities) do
                local anyWeaponModOn = _G.LynceConfig.CustomHRecoil or _G.LynceConfig.CustomVRecoil or _G.LynceConfig.LessShake or _G.LynceConfig.Accuracy or _G.LynceConfig.Crosshair or _G.LynceConfig.GodMode or _G.LynceConfig.AutoHead or _G.LynceConfig.CustomAimbot or _G.LynceConfig.CustomAimbotClose or _G.LynceConfig.AimbotMode ~= "None" or _G.LynceConfig.LessRecoil or _G.LynceConfig.VerticalRecoil

                if anyWeaponModOn then
                    if not entity.OriginalStatsCached then
                        entity.OriginalStatsCached = {
                            GameDeviationFactor = entity.GameDeviationFactor,
                            GameDeviationAccuracy = entity.GameDeviationAccuracy,
                            BulletFireSpeed = entity.BulletFireSpeed,
                            ShootInterval = entity.ShootInterval,
                            BaseDamage = entity.BaseDamage,
                            AccessoriesHRecoilFactor = entity.AccessoriesHRecoilFactor,
                            AccessoriesVRecoilFactor = entity.AccessoriesVRecoilFactor,
                            RecoilKick = entity.RecoilKick,
                            RecoilKickADS = entity.RecoilKickADS,
                            AnimationKick = entity.AnimationKick
                        }
                    end
                    
                    if _G.LynceConfig.CustomHRecoil then entity.AccessoriesHRecoilFactor = _G.LynceState.CustomTextData.HRecoil or 0.3 
                    elseif _G.LynceConfig.LessRecoil then entity.AccessoriesHRecoilFactor = 0.3 end
                    
                    if _G.LynceConfig.CustomVRecoil then entity.AccessoriesVRecoilFactor = _G.LynceState.CustomTextData.VRecoil or 0.3
                    elseif _G.LynceConfig.VerticalRecoil then entity.AccessoriesVRecoilFactor = 0.3 end
                    
                    if _G.LynceConfig.LessShake then entity.RecoilKick = 0.0; entity.RecoilKickADS = 0.0; entity.AnimationKick = 0.0 end
                    if _G.LynceConfig.Accuracy then entity.GameDeviationAccuracy = 0.0 end
                    if _G.LynceConfig.Crosshair then entity.GameDeviationFactor = 0.0 end
                    if _G.LynceConfig.GodMode then entity.BulletFireSpeed = 500000.0; entity.ShootInterval = 0.001; entity.BaseDamage = 60000.0 end
                    
                    if entity.AutoAimingConfig then
                        if not entity.OriginalAutoAimCached then
                            entity.OriginalAutoAimCached = {
                                OuterSpeed = entity.AutoAimingConfig.OuterRange and entity.AutoAimingConfig.OuterRange.Speed,
                                InnerSpeed = entity.AutoAimingConfig.InnerRange and entity.AutoAimingConfig.InnerRange.Speed
                            }
                        end
                        
                        if _G.LynceConfig.AutoHead then
                            pcall(function() entity.AutoAimingConfig.Bones = { "Head", "Head", "Head" } end)
                        end
                        
                        if _G.LynceConfig.CustomAimbot then
                            local speed = _G.LynceState.CustomTextData.OuterSpeed or 10
                            if entity.AutoAimingConfig.OuterRange then
                                entity.AutoAimingConfig.OuterRange.Speed = speed
                                entity.AutoAimingConfig.OuterRange.RangeRate = 4.5
                                entity.AutoAimingConfig.OuterRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.OuterRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.OuterRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.OuterRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.OuterRange.ProneRate = 1.0
                                entity.AutoAimingConfig.OuterRange.DyingRate = 0.0
                            end
                            if entity.AutoAimingConfig.InnerRange then
                                entity.AutoAimingConfig.InnerRange.Speed = speed
                                entity.AutoAimingConfig.InnerRange.RangeRate = 4.5
                                entity.AutoAimingConfig.InnerRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.InnerRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.InnerRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.InnerRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.InnerRange.ProneRate = 1.0
                                entity.AutoAimingConfig.InnerRange.DyingRate = 0.0
                            end
                        elseif _G.LynceConfig.CustomAimbotClose or _G.LynceConfig.AimbotMode == "Close" then
                            local speed = _G.LynceState.CustomTextData.InnerSpeed or 10
                            if entity.AutoAimingConfig.OuterRange then
                                entity.AutoAimingConfig.OuterRange.Speed = speed
                                entity.AutoAimingConfig.OuterRange.DyingRate = 0.0
                            end
                            if entity.AutoAimingConfig.InnerRange then
                                entity.AutoAimingConfig.InnerRange.Speed = speed
                                entity.AutoAimingConfig.InnerRange.DyingRate = 0.0
                            end
                        elseif _G.LynceConfig.AimbotMode == "Far" then
                            if entity.AutoAimingConfig.OuterRange then
                                entity.AutoAimingConfig.OuterRange.Speed = 5
                                entity.AutoAimingConfig.OuterRange.RangeRate = 0.7
                                entity.AutoAimingConfig.OuterRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.OuterRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.OuterRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.OuterRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.OuterRange.ProneRate = 1
                            end
                            if entity.AutoAimingConfig.InnerRange then
                                entity.AutoAimingConfig.InnerRange.Speed = 5
                                entity.AutoAimingConfig.InnerRange.RangeRate = 0.7
                                entity.AutoAimingConfig.InnerRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.InnerRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.InnerRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.InnerRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.InnerRange.ProneRate = 1
                            end
                        end
                    end
                    
                    entity.LynceWeaponModsActive = true

                elseif entity.LynceWeaponModsActive then
                    if entity.OriginalStatsCached then
                        local orig = entity.OriginalStatsCached
                        entity.GameDeviationFactor = orig.GameDeviationFactor
                        entity.GameDeviationAccuracy = orig.GameDeviationAccuracy
                        entity.BulletFireSpeed = orig.BulletFireSpeed
                        entity.ShootInterval = orig.ShootInterval
                        entity.BaseDamage = orig.BaseDamage
                        entity.AccessoriesHRecoilFactor = orig.AccessoriesHRecoilFactor
                        entity.AccessoriesVRecoilFactor = orig.AccessoriesVRecoilFactor
                        entity.RecoilKick = orig.RecoilKick
                        entity.RecoilKickADS = orig.RecoilKickADS
                        entity.AnimationKick = orig.AnimationKick
                    end
                    if entity.AutoAimingConfig and entity.OriginalAutoAimCached then
                        pcall(function() entity.AutoAimingConfig.Bones = { "Spine_01", "Pelvis", "Head" } end)
                        if entity.AutoAimingConfig.OuterRange and entity.OriginalAutoAimCached.OuterSpeed then
                            entity.AutoAimingConfig.OuterRange.Speed = entity.OriginalAutoAimCached.OuterSpeed
                        end
                        if entity.AutoAimingConfig.InnerRange and entity.OriginalAutoAimCached.InnerSpeed then
                            entity.AutoAimingConfig.InnerRange.Speed = entity.OriginalAutoAimCached.InnerSpeed
                        end
                    end
                    entity.LynceWeaponModsActive = false
                end
            end
        end
    end)

    local mHead_Global, mBody_Global, mLegs_Global = 1.0, 1.0, 1.0
    local runInject_Global = false
    
    pcall(function()
        if _G.LynceConfig.CustomMagicBullet then
            runInject_Global = true
            mHead_Global = 1.0; mBody_Global = 1.0; mLegs_Global = 1.0
            if _G.LynceState.CustomTextData then
                local cData = _G.LynceState.CustomTextData
                if cData.MagicHead ~= nil then mHead_Global = tonumber(cData.MagicHead) or mHead_Global end
                if cData.MagicBody ~= nil then mBody_Global = tonumber(cData.MagicBody) or mBody_Global end
                if cData.MagicLegs ~= nil then mLegs_Global = tonumber(cData.MagicLegs) or mLegs_Global end
            end
        elseif _G.LynceConfig.MagicBullet then
            runInject_Global = true
            mHead_Global = 1.05; mBody_Global = 1.0; mLegs_Global = 1.0
        end

        if runInject_Global then
            local currentMagicHash = "M_"..tostring(mHead_Global).."_"..tostring(mBody_Global).."_"..tostring(mLegs_Global)
            if _G.LynceState.LastMagicConfigHash ~= currentMagicHash then
                _G.LynceState.MagicUpdateVersion = (_G.LynceState.MagicUpdateVersion or 0) + 1
                _G.LynceState.LastMagicConfigHash = currentMagicHash
            end
        else
            -- KHI MAGIC BULLET BỊ TẮT, RESTORE LẠI HASH VỀ 0
            if _G.LynceState.LastMagicConfigHash ~= "OFF" then
                _G.LynceState.MagicUpdateVersion = (_G.LynceState.MagicUpdateVersion or 0) + 1
                _G.LynceState.LastMagicConfigHash = "OFF"
            end
        end
    end)

    pcall(function()
        local allCharacters = {}
        if GameplayData.GetAllPlayerCharacters then allCharacters = GameplayData.GetAllPlayerCharacters()
        elseif GameplayData.GameCharacters then for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end end
        
        local currentValidKeys = {}
        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer then
                currentValidKeys[GetSafeEnemyKey(enemy)] = true
            end
        end
        
        for key, data in pairs(_G.LynceState.EnemyMarks) do
            if not currentValidKeys[key] then
                SafeRemoveMark(data.radarMark)
                SafeRemoveMark(data.hpMark)
                SafeRemoveMark(data.distMark)
                
                -- [FIX RAM]: Dọn rác AimTouch VisCheck của địch đã chết hoặc văng quá xa
                if _G.AimTouchVisCache and _G.AimTouchVisCache[key] then
                    _G.AimTouchVisCache[key] = nil
                end
                
                if data.MIDs then
                    for meshStr, midTable in pairs(data.MIDs) do
                        for k, _ in pairs(midTable) do
                            midTable[k] = nil
                        end
                    end
                    data.MIDs = nil
                end
                if data.MIDs_V3 then
                    for meshStr, midTable in pairs(data.MIDs_V3) do
                        for k, _ in pairs(midTable) do
                            midTable[k] = nil
                        end
                    end
                    data.MIDs_V3 = nil
                end
                
                data.enemy = nil
                data.CachedMeshes = nil
                _G.LynceState.EnemyMarks[key] = nil
            end
        end

        local realCount = 0
        local aiCount = 0

        local function GetFirstElemSafe(elemArray)
            if elemArray and type(elemArray.Num) == "function" and elemArray:Num() > 0 then
                if type(elemArray.Get) == "function" then return elemArray:Get(0) end
            elseif elemArray and type(elemArray) == "table" and #elemArray > 0 then
                return elemArray[1]
            end
            return nil
        end

        local BoneScaleMap = {
            ["head"] = mHead_Global, ["neck_01"] = mHead_Global,
            ["pelvis"] = mBody_Global, ["spine_01"] = mBody_Global, ["spine_02"] = mBody_Global, ["spine_03"] = mBody_Global,
            ["thigh_l"] = mLegs_Global, ["thigh_r"] = mLegs_Global, 
            ["calf_l"] = mLegs_Global, ["calf_r"] = mLegs_Global,   
            ["foot_l"] = mLegs_Global, ["foot_r"] = mLegs_Global    
        }
        
        local mLoc = nil
        pcall(function() if type(localPlayer.K2_GetActorLocation) == "function" then mLoc = localPlayer:K2_GetActorLocation() end end)

        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= localPlayer.TeamID then
                local bIsReallyDead = false
                pcall(function()
                    if type(enemy.IsDead) == "function" then bIsReallyDead = enemy:IsDead()
                    elseif enemy.bIsDead ~= nil then bIsReallyDead = enemy.bIsDead
                    elseif enemy.bIsDeadFlag ~= nil then bIsReallyDead = enemy.bIsDeadFlag end
                    if enemy.HealthStatus ~= nil and enemy.HealthStatus == 2 then bIsReallyDead = true end
                end)

                local eKey = GetSafeEnemyKey(enemy)
                _G.LynceState.EnemyMarks[eKey] = _G.LynceState.EnemyMarks[eKey] or { enemy = enemy }
                local markData = _G.LynceState.EnemyMarks[eKey]
                markData.enemy = enemy 

                if not bIsReallyDead then
                    -- [FIX LỖI MẤT MÁU KHI NHẢY DÙ/HỒI SINH]: Kiểm tra xem địch có bị đổi Actor (nhân vật mới) không.
                    -- Nếu có, xóa toàn bộ Marker (UI) bị kẹt ở xác cũ để code bên dưới vẽ lại lên nhân vật mới.
                    if markData.lastEnemyActor ~= enemy then
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                        if markData.hpMark8 then SafeRemoveMark(markData.hpMark8); markData.hpMark8 = nil end -- Xóa luôn rác của ESP 8
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                        if markData.radarMark then SafeRemoveMark(markData.radarMark); markData.radarMark = nil end
                        
                        markData.lastEnemyActor = enemy
                        markData.LastUIComp = nil
                        markData.LastFrameUIState = nil
                    end
                    
                    local eMesh = nil
                    pcall(function() eMesh = enemy.Mesh or (type(enemy.getAvatarComponent2) == "function" and enemy:getAvatarComponent2() or nil) end)
                    local aLoc = nil
                    pcall(function() if type(enemy.K2_GetActorLocation) == "function" then aLoc = enemy:K2_GetActorLocation() end end)
                    
                    local isBotResult, isStateLoaded = CheckIsAI(enemy, markData)
                    local isBot = markData.AK_IS_BOT or false

                    local currentMeshCount = 0
                    if Valid(eMesh) then
                        local tempMeshes = GetAllSkeletalMeshes(enemy, markData)
                        currentMeshCount = #tempMeshes
                    end
                    local isMeshChanged = (markData.LastMeshCountWall ~= currentMeshCount)

                    -- ĐÃ TỐI ƯU CỰC KỲ: Chỉ Apply khi thật sự cần
                    if _G.LynceConfig.WallXuyenTuong then
                        if isMeshChanged or not markData.WallhackApplied then
                            ApplyWallXuyenTuong(enemy, markData)
                            markData.WallhackApplied = true
                            markData.LastMeshCountWall = currentMeshCount
                        end
                    else
                        UndoWallXuyenTuong(enemy, markData)
                    end

                    -- ĐÃ TỐI ƯU CỰC KỲ
                    if _G.LynceConfig.ColorBodyV2 then 
                        -- TRONG HÀM NÀY TÔI ĐÃ GIỚI HẠN PC:LINEOFSIGHTTO LẠI ĐỂ TRÁNH QUÁ TẢI CPU
                        ApplyColorBodyV2(enemy, pc, markData) 
                    else
                        UndoColorBodyV2(enemy, markData)
                    end
                    
                    -- CHỨC NĂNG MÀU V3 (LỘ DIỆN XANH LÁ + SAU TƯỜNG MÀU ĐỎ) RẤT ỔN ĐỊNH
                    if _G.LynceConfig.ColorBodyV3 then 
                        ApplyColorBodyV3(enemy, markData)
                    else
                        UndoColorBodyV3(enemy, markData)
                    end
                    -- CHỨC NĂNG WALL MÀU NEW
                    if _G.LynceConfig.ColorBodyNew then 
                        ApplyColorBodyNew(enemy, markData)
                    else
                        UndoColorBodyNew(enemy, markData)
                    end

                    -- BUG MÀN: KÉO DÃN KẺ ĐỊCH LÀM HITBOX TO RA (FAT BODY) - ĐÃ TỐI ƯU
                    pcall(function()
                        if Valid(eMesh) then
                            local targetScale = 1.0
                            if _G.LynceConfig.BugManEnable and _G.LynceState.CustomTextData then
                                targetScale = 177.0 / (_G.LynceState.CustomTextData.BugManRatio or 133)
                                if targetScale < 1.0 then targetScale = 1.0 end
                                if targetScale > 2.0 then targetScale = 2.0 end -- Chống lỗi đồ họa nếu kéo quá mức
                            end
                            
                            -- [FIX RÁC RAM]: Chỉ giãn xương khi có sự thay đổi (Bật/tắt hoặc kéo thanh trượt)
                            if markData.LastFatScale ~= targetScale then
                                eMesh:SetRelativeScale3D(FVector(targetScale, targetScale, 1.0))
                                markData.LastFatScale = targetScale
                            end
                        end
                    end)

                    -- LOGIC MAGIC BULLET (ĐÃ FIX LAG ĐÔNG NGƯỜI BẰNG UNIQUE ID)
                    pcall(function()
                        local EnemyMesh = eMesh
                        if slua.isValid(EnemyMesh) then
                            -- [FIX CPU CỰC MẠNH]: Dùng ID thật của nhân vật. Không dùng tostring() vì SLUA tự xóa/tạo lại chuỗi liên tục
                            -- gây lỗi tính toán lại 50 khung xương lặp đi lặp lại khi đông người.
                            local uniqueID = type(enemy.GetUniqueID) == "function" and enemy:GetUniqueID() or tostring(enemy.PlayerKey or enemy)
                            
                            -- Chỉ tính toán xương ĐÚNG 1 LẦN DUY NHẤT cho mỗi kẻ địch (trừ khi bạn kéo thanh chỉnh size)
                            if markData.MagicBulletHash == _G.LynceState.LastMagicConfigHash and markData.MagicTargetID == uniqueID then
                                return 
                            end

                            local PhysicsAsset = EnemyMesh.PhysicsAssetOverride
                            if not slua.isValid(PhysicsAsset) and EnemyMesh.SkeletalMesh then PhysicsAsset = EnemyMesh.SkeletalMesh.PhysicsAsset end

                            if slua.isValid(PhysicsAsset) and PhysicsAsset.SkeletalBodySetups then
                                if not _G.AK_ModdedPhysAssets then _G.AK_ModdedPhysAssets = {} end
                                local PhysAssetName = "DefaultPhys"
                                pcall(function() PhysAssetName = PhysicsAsset:GetName() end)
                                
                                -- Tối ưu cấp 2: Nếu bộ xương này đã từng được phóng to bởi một kẻ địch khác, dùng luôn, không chạy vòng lặp
                                if _G.AK_ModdedPhysAssets[PhysAssetName] ~= _G.LynceState.LastMagicConfigHash then
                                    
                                    if not _G.AK_OrigHitboxes then _G.AK_OrigHitboxes = {} end
                                    if not _G.AK_OrigHitboxes[PhysAssetName] then _G.AK_OrigHitboxes[PhysAssetName] = {} end
                                    local OrigHitboxData = _G.AK_OrigHitboxes[PhysAssetName]

                                    local SkeletalBodySetups = PhysicsAsset.SkeletalBodySetups
                                    local numSetups = type(SkeletalBodySetups.Num) == "function" and SkeletalBodySetups:Num() or #SkeletalBodySetups
                                    local limit = numSetups > 50 and 50 or numSetups

                                    for i = 1, limit do 
                                        local BodySetup = type(SkeletalBodySetups.Get) == "function" and SkeletalBodySetups:Get(i-1) or SkeletalBodySetups[i]
                                        if slua.isValid(BodySetup) then
                                            local LowerBoneName = string.lower(tostring(BodySetup.BoneName))
                                            local MatchedBoneKey = nil
                                            for k, _ in pairs(BoneScaleMap) do
                                                if string.find(LowerBoneName, k, 1, true) then MatchedBoneKey = k break end
                                            end

                                            if MatchedBoneKey then
                                                local TargetScale = 1.0 
                                                if runInject_Global then TargetScale = BoneScaleMap[MatchedBoneKey] end
                                                
                                                local AggGeom = BodySetup.AggGeom
                                                
                                                local BoxElems = AggGeom and AggGeom.BoxElems or BodySetup.BoxElems
                                                local SphereElems = AggGeom and AggGeom.SphereElems or BodySetup.SphereElems
                                                local SphylElems = AggGeom and AggGeom.SphylElems or BodySetup.SphylElems

                                                local BoxElem = GetFirstElemSafe(BoxElems)
                                                local SphereElem = GetFirstElemSafe(SphereElems)
                                                local SphylElem = GetFirstElemSafe(SphylElems)

                                                if not OrigHitboxData[MatchedBoneKey] then
                                                    OrigHitboxData[MatchedBoneKey] = { Box = nil, Sphere = nil, Sphyl = nil }
                                                    if BoxElem then OrigHitboxData[MatchedBoneKey].Box = { X = BoxElem.X, Y = BoxElem.Y, Z = BoxElem.Z } end
                                                    if SphereElem then OrigHitboxData[MatchedBoneKey].Sphere = { Radius = SphereElem.Radius } end
                                                    if SphylElem then OrigHitboxData[MatchedBoneKey].Sphyl = { Radius = SphylElem.Radius, Length = SphylElem.Length } end
                                                end

                                                local OrigElemData = OrigHitboxData[MatchedBoneKey]

                                                if OrigElemData.Box and BoxElem then
                                                    BoxElem.X = OrigElemData.Box.X * TargetScale
                                                    BoxElem.Y = OrigElemData.Box.Y * TargetScale
                                                    BoxElem.Z = OrigElemData.Box.Z * TargetScale
                                                    if type(BoxElems.Set) == "function" then BoxElems:Set(0, BoxElem) else BoxElems[1] = BoxElem end
                                                    if AggGeom then AggGeom.BoxElems = BoxElems; BodySetup.AggGeom = AggGeom else BodySetup.BoxElems = BoxElems end
                                                end

                                                if OrigElemData.Sphere and SphereElem then
                                                    SphereElem.Radius = OrigElemData.Sphere.Radius * TargetScale
                                                    if type(SphereElems.Set) == "function" then SphereElems:Set(0, SphereElem) else SphereElems[1] = SphereElem end
                                                    if AggGeom then AggGeom.SphereElems = SphereElems; BodySetup.AggGeom = AggGeom else BodySetup.SphereElems = SphereElems end
                                                end

                                                if OrigElemData.Sphyl and SphylElem then
                                                    SphylElem.Radius = OrigElemData.Sphyl.Radius * TargetScale
                                                    SphylElem.Length = OrigElemData.Sphyl.Length * TargetScale
                                                    if type(SphylElems.Set) == "function" then SphylElems:Set(0, SphylElem) else SphylElems[1] = SphylElem end
                                                    if AggGeom then AggGeom.SphylElems = SphylElems; BodySetup.AggGeom = AggGeom else BodySetup.SphylElems = SphylElems end
                                                end
                                            end
                                        end
                                    end
                                    _G.AK_ModdedPhysAssets[PhysAssetName] = _G.LynceState.LastMagicConfigHash
                                end
                                
                                if EnemyMesh.SetPhysicsAsset then EnemyMesh:SetPhysicsAsset(PhysicsAsset) end
                                EnemyMesh.PhysicsAssetOverride = PhysicsAsset
                                
                                markData.MagicBulletHash = _G.LynceState.LastMagicConfigHash
                                markData.MagicTargetID = uniqueID -- Lưu ID tĩnh
                            end
                        end
                    end)

                    local distM = 0
                    pcall(function() distM = localPlayer:GetDistanceTo(enemy) / 100 end)

                    local currentHp, maxHp = 100, 100
                    local showFrameUI = _G.LynceConfig.EspLoai5 or _G.LynceConfig.EspVipPro or _G.LynceConfig.EspVip
                    
                    if showFrameUI then
                        pcall(function()
                            if enemy.Health then currentHp = enemy.Health elseif type(enemy.GetHealth) == "function" then currentHp = enemy:GetHealth() end
                            if enemy.HealthMax then maxHp = enemy.HealthMax elseif type(enemy.GetHealthMax) == "function" then maxHp = enemy:GetHealthMax() end
                        end)
                        if maxHp <= 0 then maxHp = 100 end
                    end
                    local hpRatio = currentHp / maxHp

                    if _G.LynceConfig.EspAntenna then
                        pcall(function()
                            local MyHUD = Cached_MyHUD
                            if Valid(MyHUD) and distM <= 400 then
                                local loopCount = 8  
                                local zStep = 1000     
                                local baseZ = 105     
                                local topZ = baseZ + (loopCount * zStep)
                                for i = 1, loopCount do
                                    local zOffset = baseZ + (i * zStep)
                                    MyHUD:AddDebugText("|", enemy, 0.06,
                                        {X=0, Y=0, Z=zOffset}, {X=0, Y=0, Z=zOffset},
                                        C_GREEN, true, false, true, nil, 1.2, true)
                                end
                                MyHUD:AddDebugText("I", enemy, 0.06,
                                        {X=0, Y=0, Z=topZ + 60}, {X=0, Y=0, Z=topZ + 60},
                                        C_GREEN, true, false, true, nil, 1.5, true)
                            end
                        end)
                    end

                    if _G.LynceConfig.EspLoai6 then
                        pcall(function()
                            local curTime = os.clock()
                            -- TỐI ƯU CỰC ĐỘ 1: Khoá nhịp vẽ HUD 20 FPS (0.05s/lần) thay vì 100 FPS
                            -- Game vẫn mượt, nhưng CPU không bị cháy vì spam lệnh AddDebugText
                            if markData.LastEsp6Time == nil or (curTime - markData.LastEsp6Time) >= 0.05 then
                                markData.LastEsp6Time = curTime
                                
                                local MyHUD = Cached_MyHUD
                                if Valid(MyHUD) and Valid(eMesh) and aLoc then
                                    if distM <= 250 then
                                        -- Lấy toạ độ Đầu tiên quyết, nếu không có hàm này thì bỏ qua
                                        if type(eMesh.GetSocketLocation) == "function" then
                                            for _, bName in ipairs(GLOBAL_BONE_LIST) do
                                                
                                                -- TỐI ƯU CỰC ĐỘ 2: Địch xa hơn 50m chỉ vẽ Đầu, Cổ, Hông. Bỏ qua tay chân đỡ rác
                                                if distM > 50 and (bName ~= "head" and bName ~= "pelvis" and bName ~= "neck_01") then
                                                    -- Skip không vẽ tay chân ở xa
                                                else
                                                    local wLoc = eMesh:GetSocketLocation(bName)
                                                    if wLoc then
                                                        -- Tính Offset chuẩn cho HUD
                                                        local offset = {X = wLoc.X - aLoc.X, Y = wLoc.Y - aLoc.Y, Z = wLoc.Z - aLoc.Z}
                                                        
                                                        local mark = "▪"
                                                        local fixedSize = 0.25 
                                                        local color = C_CYAN
                                                        
                                                        if bName == "head" then 
                                                            mark = "●"
                                                            fixedSize = 0.45
                                                            color = C_RED
                                                        elseif bName == "pelvis" or bName == "neck_01" then 
                                                            mark = "▪"
                                                            fixedSize = 0.35
                                                            color = C_YELLOW 
                                                        end
                                                        
                                                        -- Vẽ điểm neo của khớp xương (Thời gian sống 0.06s để nối mượt với frame 0.05s)
                                                        MyHUD:AddDebugText(mark, enemy, 0.06, offset, offset, color, true, false, true, nil, fixedSize, true)
                                                    end
                                                end
                                            end
                                        end
                                        -- LƯU Ý: ĐÃ XOÁ BỎ HOÀN TOÀN TÍNH NĂNG VẼ DÂY NỐI (GLOBAL_CONNECTIONS)
                                        -- Vì dùng dấu chấm "." xếp thành dây là nguyên nhân chính gây drop FPS 
                                    end
                                end
                            end
                        end)
                    end

                    if _G.LynceConfig.EspLoai7 then
                        pcall(function()
                            local MyHUD = Cached_MyHUD
                            if Valid(MyHUD) then
                                if distM <= 600 then if isBot then aiCount = aiCount + 1 else realCount = realCount + 1 end end
                                
                                if distM <= 400 then
                                    local stateText = ""
                                    
                                    -- 1. Xử lý Tư Thế
                                    if _G.LynceConfig.Esp7_TuThe then
                                        local pose = nil
                                        if enemy.PoseState then pose = enemy.PoseState
                                        elseif type(enemy.GetPoseState) == "function" then pose = enemy:GetPoseState() end
                                        
                                        if pose == 0 or pose == "Stand" then stateText = "Berdiri"
                                    elseif pose == 1 or pose == "Crouch" then stateText = "Jongkok"
                                    elseif pose == 2 or pose == "Prone" then stateText = "Telentang"
                                    else stateText = "Berdiri" end
                                end
                                    
                                    -- 2. Xử lý Vũ Khí
                                    if _G.LynceConfig.Esp7_VuKhi then
                                        local curTime = os.clock()
                                        if markData.AK_LAST_WEP_TIME == nil or curTime > markData.AK_LAST_WEP_TIME + 1.5 then
                                            local eWeapon = nil
                                            if enemy.CurrentWeapon then eWeapon = enemy.CurrentWeapon
                                            elseif type(enemy.GetCurrentWeapon) == "function" then eWeapon = enemy:GetCurrentWeapon()
                                            elseif enemy.WeaponManagerComponent then eWeapon = enemy.WeaponManagerComponent.CurrentWeaponReplicated end
                                            
                                            local weaponName = "Tangan Kosong"
                                         if Valid(eWeapon) then if type(eWeapon.GetWeaponName) == "function" then weaponName = eWeapon:GetWeaponName() end end
                                         markData.AK_CACHED_WEP_NAME = tostring(weaponName)
                                         markData.AK_LAST_WEP_TIME = curTime
                                     end

                                        if stateText ~= "" then
                                       stateText = stateText .. " - " .. (markData.AK_CACHED_WEP_NAME or "Tangan Kosong")
                                   else
                                       stateText = (markData.AK_CACHED_WEP_NAME or "Tangan Kosong")
                                   end
                               end
                                    -- 3. Vẽ lên màn hình nếu có bật 1 trong 2
                                    if stateText ~= "" then
                                        local textColor = isBot and C_CYAN or C_YELLOW
                                        local dynamicScale = math.max(0.5, 0.8 - (distM / 400))
                                        MyHUD:AddDebugText(stateText, enemy, 0.06, {X=0, Y=0, Z=100}, {X=0, Y=0, Z=100}, textColor, true, false, true, nil, dynamicScale, true)
                                    end
                                end
                            end
                        end)
                    end

                    -- ĐÃ TỐI ƯU CỰC KỲ: Chỉ SetVisibility cho UI khung máu khi thật sự cần
                    if showFrameUI then
                        pcall(function()
                            local SecurityCommonUtils = Cached_SecurityCommonUtils
                            local show = true
                            if enemy.HealthStatus and SecurityCommonUtils and SecurityCommonUtils.IsHealthStatusAlive then 
                                if not SecurityCommonUtils.IsHealthStatusAlive(enemy.HealthStatus) then show = false end
                            end
                            if show and mLoc then
                                if aLoc and SecurityCommonUtils and SecurityCommonUtils.IsVector then
                                    if SecurityCommonUtils.IsVector(aLoc) and SecurityCommonUtils.IsVector(mLoc) then
                                        if aLoc.Z >= 150000 or FVector.Dist2D(mLoc, aLoc) > 50000 then show = false end
                                    end
                                end
                            end
                            if show then
                                if enemy.Replay_IsEnemyFrameUIExisted and not enemy:Replay_IsEnemyFrameUIExisted() then enemy:Replay_CreateEnemyFrameUI(true, true) end
                                if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(true) end
                                if enemy.Replay_UpdateEnemyFrameUI then enemy:Replay_UpdateEnemyFrameUI(hpRatio) end
                                
                                local uiComp = enemy.EnemyFrameUI or (type(enemy.GetEnemyFrameUI) == "function" and enemy:GetEnemyFrameUI())
                                if Valid(uiComp) then
                                    if markData.LastFrameUIState ~= "VISIBLE" then
                                        if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(0) end
                                        if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(false) end
                                        markData.LastFrameUIState = "VISIBLE"
                                    end
                                end
                            end
                        end)
                    else
                        pcall(function()
                            if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(false) end
                            local uiComp = enemy.EnemyFrameUI or (type(enemy.GetEnemyFrameUI) == "function" and enemy:GetEnemyFrameUI())
                            if Valid(uiComp) then
                                if markData.LastFrameUIState ~= "HIDDEN" then
                                    if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(2) end
                                    if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(true) end
                                    markData.LastFrameUIState = "HIDDEN"
                                end
                            end
                        end)
                    end

                    if _G.LynceConfig.EspVipPro then
                        pcall(function()
                            local hud = Cached_MyHUD
                            if Valid(hud) and hud.AddDebugText then
                                if distM <= 400 then
                                    local dynamicScale = math.max(0.55, 0.95 - (distM / 400))
                                    local hpPercent = hpRatio
                                    local isKnock = (currentHp <= 0 and enemy.HealthStatus == 1)
                                    
                                    local hpColor = C_GREEN
                                    if hpPercent < 0.3 then hpColor = C_RED
                                    elseif hpPercent < 0.7 then hpColor = C_YELLOW end
                                    if isKnock then hpColor = C_RED end
                                    
                                    -- VẼ TÊN NGƯỜI CHƠI
                                    if _G.LynceConfig.Esp3ShowName then
                                        local enemyName = "Enemy"
                                        pcall(function() if enemy.PlayerName then enemyName = enemy.PlayerName elseif type(enemy.GetPlayerName) == "function" then enemyName = enemy:GetPlayerName() end end)
                                        if enemyName == "" then enemyName = "Enemy" end
                                        if isKnock then enemyName = "KNOCK: " .. enemyName end
                                        hud:AddDebugText(enemyName, enemy, 0.06, {X=0, Y=0, Z=-370}, {X=0, Y=0, Z=-370}, C_WHITE, true, false, true, nil, dynamicScale * 1.1, true)
                                    end
                                    
                                    -- VẼ THANH MÁU
                                    if _G.LynceConfig.Esp3ShowHP then
                                        if not isKnock then
                                            local segments = 6
                                            local filled = math.floor(hpPercent * segments)
                                            local startZ = 20
                                            local spacing = 10.0 * dynamicScale 
                                            for j = 1, segments do
                                                local color = (j <= filled) and hpColor or {R=30,G=30,B=30,A=180}
                                                hud:AddDebugText("█", enemy, 0.06, {X=0, Y=-115, Z=startZ + (j * spacing)}, {X=0, Y=-115, Z=startZ + (j * spacing)}, color, true, false, true, nil, dynamicScale * 1.2, true)
                                            end
                                            hud:AddDebugText(string.format("%d%%", math.floor(hpPercent * 100)), enemy, 0.06, {X=0, Y=-60, Z=startZ - 12}, {X=0, Y=-60, Z=startZ - 12}, hpColor, true, false, true, nil, dynamicScale * 0.8, true)
                                        else
                                            hud:AddDebugText("DOWN", enemy, 0.06, {X=0, Y=-115, Z=50}, {X=0, Y=-115, Z=50}, C_RED, true, false, true, nil, dynamicScale * 1.0, true)
                                        end
                                    end
                                end
                            end
                        end)
                    end

                    if _G.LynceConfig.EspDistance then
                        pcall(function()
                            local hud = Cached_MyHUD
                            if Valid(hud) and hud.AddDebugText then
                                if distM <= 400 then
                                    local dynamicScale = math.max(0.55, 0.95 - (distM / 400))
                                    hud:AddDebugText(string.format("[%dm]", math.floor(distM)), enemy, 0.06, {X=0, Y=115, Z=20}, {X=0, Y=115, Z=20}, C_BLUE_TEXT, true, false, true, nil, dynamicScale * 1.5, true)
                                end
                            end
                        end)
                    end

                    -- [ESP LOẠI 1 (Đã Fix Lỗi)]: Giữ nguyên thanh máu (hpMark) và khoảng cách (distMark)
                    if _G.LynceConfig.EspVip then
                        if markData.hpMark == nil then markData.hpMark = SafeAddMark(1006, FVector(0,0,0), 0, "", 4, enemy) end
                        if markData.distMark == nil then markData.distMark = SafeAddMark(9999, FVector(0,0,0), 0, "", 4, enemy) end
                    else
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                    end

                    -- [ESP LOẠI 8 ĐỘC LẬP (Đã Fix Lỗi)]: Copy logic thanh máu ESP 1, nhưng chạy biến hpMark8 riêng biệt
                    if _G.LynceConfig.EspLoai8 then
                        if markData.hpMark8 == nil then markData.hpMark8 = SafeAddMark(1006, FVector(0,0,0), 0, "", 4, enemy) end
                    else
                        if markData.hpMark8 then SafeRemoveMark(markData.hpMark8); markData.hpMark8 = nil end
                    end
                    
                    if _G.LynceConfig.EspRadar then
                        -- Sửa lỗi kẹt biến (nil/false/0) và gọi ID 8888 độc quyền
                        if not markData.radarMark or markData.radarMark == 0 then 
                            markData.radarMark = SafeAddMark(8888, FVector(0,0,0), 0, "", 4, enemy) 
                        end
                    else
                        if markData.radarMark and markData.radarMark ~= 0 then
                            SafeRemoveMark(markData.radarMark)
                            markData.radarMark = nil
                        end
                    end
                    
                    -- [ESP OUTLINE - Y CHANG 100% LOGIC LỘ DIỆN V3]: Phát sáng Tùy Chỉnh Màu HDR
                    if _G.LynceConfig.EspOutline then
                        pcall(function()
                            local outColorChoice = _G.LynceState.CustomTextData.OutlineColor or 4
                            local outThick = _G.LynceConfig.OutlineThickness or 10
                            local outlineHash = string.format("%d_%d", outThick, outColorChoice)
                            
                            local meshes = GetAllSkeletalMeshes(enemy, markData)
                            local currentMeshCount = #meshes
                            
                            if markData.OutlineState ~= outlineHash or markData.LastMeshCountOutline ~= currentMeshCount then
                                
                                local r, g, b = 255, 255, 0 -- Vàng (Mặc định)
                                if outColorChoice == 1 then r, g, b = 255, 0, 0 -- Đỏ
                                elseif outColorChoice == 2 then r, g, b = 0, 255, 0 -- Lục
                                elseif outColorChoice == 3 then r, g, b = 0, 0, 255 -- Lam
                                elseif outColorChoice == 4 then r, g, b = 255, 255, 0 -- Vàng
                                elseif outColorChoice == 5 then r, g, b = 255, 0, 255 -- Tím/Hồng
                                elseif outColorChoice == 6 then r, g, b = 255, 255, 255 end -- Trắng

                                local glowIntensity = 80.0
                                local LinearColorClass = import("LinearColor") or _G.FLinearColor
                                local glowDynamic = LinearColorClass and LinearColorClass((r/255) * glowIntensity, (g/255) * glowIntensity, (b/255) * glowIntensity, 1.0) or { R = r * glowIntensity, G = g * glowIntensity, B = b * glowIntensity, A = 255 }

                                for _, comp in ipairs(meshes) do
                                    if Valid(comp) then
                                        -- BẮT BUỘC GIỐNG V3: Ép Shading Model để kích hoạt phát sáng HDR (Bloom)
                                        pcall(function()
                                            comp.UseScopeDistanceCulling = false 
                                            comp.PrimitiveShadingStrategy = 1
                                            comp.ShadingRate = 6
                                        end)

                                        -- Y CHANG V3: Vẽ Outline đè lên trên bằng hàm gốc của Engine
                                        if comp.SetDrawIdeaOutline then
                                            comp:SetDrawIdeaOutline(true)
                                            if comp.OverrideIdeaOutlineColor then
                                                comp:OverrideIdeaOutlineColor(true, glowDynamic)
                                            end
                                            if comp.OverrideIdeaOutlineThickness then
                                                -- Độ to của viền ăn theo thanh kéo trong Menu của bạn
                                                comp:OverrideIdeaOutlineThickness(true, _G.LynceConfig.OutlineThickness)
                                            end
                                        end
                                    end
                                end
                                markData.OutlineState = outlineHash
                                markData.LastMeshCountOutline = currentMeshCount -- Lưu lại số lượng phụ kiện hiện tại
                            end
                        end)
                    else
                        pcall(function()
                            if markData.OutlineState ~= "OFF" then
                                local meshes = GetAllSkeletalMeshes(enemy, markData)
                                for _, comp in ipairs(meshes) do
                                    if Valid(comp) then
                                        -- Hoàn trả Shading Model về mặc định khi tắt
                                        pcall(function()
                                            comp.PrimitiveShadingStrategy = 0
                                            comp.ShadingRate = 1
                                        end)
                                        
                                        if comp.SetDrawIdeaOutline then
                                            comp:SetDrawIdeaOutline(false)
                                        end
                                    end
                                end
                                markData.OutlineState = "OFF"
                                markData.LastMeshCountOutline = 0
                            end
                        end)
                    end

                else
                    if not markData.IsCleanedUp then
                        SafeRemoveMark(markData.radarMark)
                        markData.radarMark = nil
                        SafeRemoveMark(markData.hpMark)
                        markData.hpMark = nil
                        SafeRemoveMark(markData.hpMark8) -- Dọn dẹp ESP 8
                        markData.hpMark8 = nil
                        SafeRemoveMark(markData.distMark)
                        markData.distMark = nil
                        
                        if markData.MIDs then
                            for meshStr, midTable in pairs(markData.MIDs) do
                                for k, _ in pairs(midTable) do midTable[k] = nil end
                            end
                            markData.MIDs = nil
                        end
                        
                        if markData.MIDs_V3 then
                            for meshStr, midTable in pairs(markData.MIDs_V3) do
                                for k, _ in pairs(midTable) do midTable[k] = nil end
                            end
                            markData.MIDs_V3 = nil
                        end
                        
                        pcall(function()
                            local eObj = markData.enemy
                            if Valid(eObj) then 
                                if eObj.Replay_SetVisiableOfFrameUI then eObj:Replay_SetVisiableOfFrameUI(false) end
                                local uiComp = eObj.EnemyFrameUI or (type(eObj.GetEnemyFrameUI) == "function" and eObj:GetEnemyFrameUI())
                                if Valid(uiComp) then
                                    if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(2) end 
                                    if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(true) end
                                end
                            end
                            
                            local PPM = Cached_PPM
                            local avatarComp = Valid(eObj) and (type(eObj.getAvatarComponent2) == "function") and eObj:getAvatarComponent2() or nil
                            if Valid(avatarComp) and Valid(PPM) then PPM:EnableAvatarOutline(avatarComp, false) end
                        end)

                        markData.IsCleanedUp = true
                    end
                end
            end
        end

        if _G.LynceConfig.EspLoai7 and _G.LynceConfig.Esp7_SoLuong then
            _M_DrawCounter() -- Gọi hàm Widget UMG xịn xò
        else
            -- Tắt công tắc thì cho ẩn Widget đi
            if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then
                EnemyCounterWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
        end

        -- ==========================================================
        -- [LOGIC ESP BOM VVIP] - OPTIMIZED WITH WEAK CACHE (100% GỐC, KHÔNG LAG)
        -- ==========================================================
        if _G.LynceConfig.EspBomMaster and (_G.LynceConfig.EspItemBom or _G.LynceConfig.EspActiveBom) then
            pcall(function()
                local MyHUD = Cached_MyHUD
                if Valid(MyHUD) then
                    if not _G.CachedGameplayStatics then _G.CachedGameplayStatics = import("GameplayStatics") end
                    if not _G.CachedActorClass_ForBomb then _G.CachedActorClass_ForBomb = import("Actor") end 
                    if not _G.CachedProjArray then _G.CachedProjArray = slua.Array(UEnums.EPropertyClass.Object, _G.CachedActorClass_ForBomb) end
                    
                    -- Khởi tạo Cache sử dụng Weak Table để game tự xóa rác, không tràn RAM
                    if not _G.ActorBombCacheInit then
                        _G.NonBombCache = setmetatable({}, { __mode = "k" })
                        _G.BombCache = setmetatable({}, { __mode = "k" })
                        _G.ActorBombCacheInit = true
                    end
                    
                    local ui_util = require("client.common.ui_util")
                    local gameInstance = ui_util and ui_util.GetGameInstance()
                    
                    if gameInstance and _G.CachedGameplayStatics then
                        local curTime = os.clock()
                        
                        -- LUỒNG QUÉT DỮ LIỆU NẶNG: Chạy 0.5s/lần thay vì mỗi frame
                        if not _G.LastBombScanTime or (curTime - _G.LastBombScanTime) > 0.5 then
                            _G.LastBombScanTime = curTime
                            local allActors = _G.CachedGameplayStatics.GetAllActorsOfClass(gameInstance, _G.CachedActorClass_ForBomb, _G.CachedProjArray)
                            
                            local activeBombs = {}
                            local itemBombs = {}
                            
                            if allActors then
                                for _, actor in pairs(allActors) do
                                    if slua.isValid(actor) and not actor.bHidden and not actor.bTearOff then
                                        
                                        -- 1. KIỂM TRA BỘ NHỚ ĐỆM (CACHE) SIÊU TỐC
                                        -- Nếu actor này đã từng quét và KHÔNG PHẢI BOM -> Bỏ qua lập tức (Giảm 99% Lag)
                                        if not _G.NonBombCache[actor] then
                                            local bType = 0
                                            local isItem = false
                                            local isKnownBomb = _G.BombCache[actor]
                                            
                                            if isKnownBomb then
                                                bType = isKnownBomb.type
                                                isItem = isKnownBomb.isItem
                                            else
                                                -- Lần đầu tiên thấy Actor này, tiến hành kiểm tra tên (Rất ít khi xảy ra)
                                                local nameLower = nil
                                                pcall(function() nameLower = string.lower(type(actor.GetName) == "function" and actor:GetName() or tostring(actor)) end)
                                                
                                                if nameLower then
                                                    if string.find(nameLower, "m79") or string.find(nameLower, "launcher") then bType = 5
                                                    elseif string.find(nameLower, "smoke") then bType = 2
                                                    elseif string.find(nameLower, "burn") or string.find(nameLower, "molotov") then bType = 3
                                                    elseif string.find(nameLower, "flash") or string.find(nameLower, "stun") then bType = 4
                                                    elseif string.find(nameLower, "grenade") then bType = 1 end
                                                    
                                                    if bType > 0 then
                                                        if string.find(nameLower, "projectile") or string.find(nameLower, "thrown") then
                                                            isItem = false
                                                        else
                                                            isItem = true
                                                            local shouldAdd = true
                                                            if bType == 3 and not (string.find(nameLower, "pickup") or string.find(nameLower, "wrapper") or string.find(nameLower, "weapon")) then
                                                                shouldAdd = false
                                                            elseif bType == 5 then
                                                                local attachParent = nil
                                                                pcall(function() if type(actor.GetAttachParentActor) == "function" then attachParent = actor:GetAttachParentActor() end end)
                                                                if slua.isValid(attachParent) then
                                                                    local isHolding = false
                                                                    pcall(function()
                                                                        local curWeapon = type(attachParent.GetCurrentWeapon) == "function" and attachParent:GetCurrentWeapon() or attachParent.CurrentWeapon
                                                                        if curWeapon == actor then isHolding = true end
                                                                    end)
                                                                    if not isHolding then shouldAdd = false end
                                                                end
                                                            end
                                                            if not shouldAdd then bType = 0 end
                                                        end
                                                    end
                                                end
                                                
                                                -- Lưu kết quả vào Cache
                                                if bType > 0 then
                                                    _G.BombCache[actor] = { type = bType, isItem = isItem }
                                                else
                                                    _G.NonBombCache[actor] = true
                                                end
                                            end
                                            
                                            -- Nếu là Bom hợp lệ (từ Cache hoặc vừa tìm ra)
                                            if bType > 0 then
                                                local isPendingKill = false
                                                pcall(function() if type(actor.IsPendingKill) == "function" then isPendingKill = actor:IsPendingKill() end end)
                                                
                                                if not isPendingKill then
                                                    if isItem then
                                                        table.insert(itemBombs, {act = actor, type = bType})
                                                    else
                                                        table.insert(activeBombs, {act = actor, type = bType})
                                                    end
                                                else
                                                    -- Xóa khỏi cache nếu bomb đã nổ/biến mất
                                                    _G.BombCache[actor] = nil
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            _G.CachedActiveBombs = activeBombs
                            _G.CachedItemBombs = itemBombs
                        end

                        local curGameTime = 0
                        pcall(function() curGameTime = _G.CachedGameplayStatics.GetTimeSeconds(gameInstance) end)

                        local function DrawBombs(bombList, isItem, maxDist)
                            if not bombList then return end
                            for _, item in ipairs(bombList) do
                                local bomb = item.act
                                local bType = item.type
                                
                                if slua.isValid(bomb) and not bomb.bHidden then
                                    local distM = 0
                                    pcall(function() distM = localPlayer:GetDistanceTo(bomb) / 100 end)
                                    
                                    if distM > 0 and distM <= maxDist then
                                        local displayName = ""
                                        local bombColor = C_WHITE
                                        local zOffset = isItem and 15 or 25
                                        
                                        if bType == 1 then displayName = "Bom"; bombColor = isItem and {R=255, G=100, B=100, A=255} or C_RED
                                        elseif bType == 2 then displayName = "ASAP"; bombColor = isItem and {R=200, G=200, B=200, A=255} or C_WHITE
                                        elseif bType == 3 then displayName = "API"; bombColor = isItem and {R=255, G=160, B=50, A=255} or {R=255, G=100, B=0, A=255}
                                        elseif bType == 4 then displayName = "BOM CAHCAH"; bombColor = isItem and {R=150, G=255, B=255, A=255} or C_CYAN
                                        elseif bType == 5 then displayName = "ASAP PELURU"; bombColor = isItem and {R=150, G=255, B=150, A=255} or {R=100, G=255, B=100, A=255} end
                                        
                                        local text = string.format("%s [%dm]", displayName, math.floor(distM))
                                        local shouldTimerRun = not isItem 
                                        
                                        if isItem then pcall(function() if bomb.bIsPinPulled or bomb.bPinPulled or (type(bomb.IsPinPulled) == "function" and bomb:IsPinPulled()) then shouldTimerRun = true end end) end

                                        if shouldTimerRun and curGameTime > 0 then
                                            local timeLeft = -1
                                            pcall(function() if bomb.ExplosionTime then timeLeft = bomb.ExplosionTime - curGameTime elseif bomb.ExplodeTime then timeLeft = bomb.ExplodeTime - curGameTime end end)
                                            
                                            if timeLeft == -1 or timeLeft > 100 then
                                                _G.ActiveBombTimers = _G.ActiveBombTimers or {}
                                                local bombId = tostring(bomb)
                                                if not _G.ActiveBombTimers[bombId] then _G.ActiveBombTimers[bombId] = curGameTime end
                                                local elapsed = curGameTime - _G.ActiveBombTimers[bombId]
                                                local maxTime = (bType == 1 and 7.0) or (bType == 2 and 45.0) or (bType == 3 and 12.0) or (bType == 4 and 5.0) or 45.0
                                                timeLeft = maxTime - elapsed
                                            end
                                            
                                            if timeLeft < 0 then timeLeft = 0 end
                                            if timeLeft > 0.1 then text = string.format("%s (%.1fs)", text, timeLeft) end
                                        end
                                        
                                        local dynamicScale = math.max(0.6, 1.1 - (distM / maxDist))
                                        MyHUD:AddDebugText(text, bomb, 0.06, {X=0, Y=0, Z=zOffset}, {X=0, Y=0, Z=zOffset}, bombColor, true, false, true, nil, dynamicScale, true)
                                    end
                                end
                            end
                        end
                        
                        if not _G.LastClearTimer or (curTime - _G.LastClearTimer) > 1.0 then
                            _G.LastClearTimer = curTime
                            pcall(function() if _G.ActiveBombTimers then for k, v in pairs(_G.ActiveBombTimers) do if (curGameTime - v) > 60.0 then _G.ActiveBombTimers[k] = nil end end end end)
                        end

                        if _G.LynceConfig.EspItemBom then DrawBombs(_G.CachedItemBombs, true, 50) end
                        if _G.LynceConfig.EspActiveBom then DrawBombs(_G.CachedActiveBombs, false, 150) end
                    end
                end
            end)
        end

        -- ==========================================================
        -- [LOGIC ESP XE - VEHICLE ESP VVIP] - OPTIMIZED
        -- ==========================================================
        -- ==========================================================
        -- [LOGIC ESP XE - VEHICLE ESP VVIP] - OPTIMIZED KHÔNG MÁU (SIÊU NHẸ)
        -- ==========================================================
        if _G.LynceConfig.EspVehicle then
            pcall(function()
                local MyHUD = Cached_MyHUD
                if Valid(MyHUD) then
                    if not _G.CachedGameplayStatics then _G.CachedGameplayStatics = import("GameplayStatics") end
                    if not _G.CachedActorClass_ForVehicle then _G.CachedActorClass_ForVehicle = import("STExtraVehicleBase") end 
                    if not _G.CachedVehicleArray then _G.CachedVehicleArray = slua.Array(UEnums.EPropertyClass.Object, _G.CachedActorClass_ForVehicle) end
                    
                    local ui_util = require("client.common.ui_util")
                    local gameInstance = ui_util and ui_util.GetGameInstance()
                    
                    if gameInstance and _G.CachedGameplayStatics then
                        local curTime = os.clock()

                        -- LUỒNG QUÉT CHÍNH: 1.0s quét 1 lần.
                        if not _G.LastVehicleScanTime or (curTime - _G.LastVehicleScanTime) > 1.0 then
                            _G.LastVehicleScanTime = curTime
                            local allVehicles = _G.CachedGameplayStatics.GetAllActorsOfClass(gameInstance, _G.CachedActorClass_ForVehicle, _G.CachedVehicleArray)
                            
                            local activeVehicles = {}
                            if allVehicles then
                                for _, veh in pairs(allVehicles) do
                                    if slua.isValid(veh) and not veh.bHidden and not veh.bTearOff then
                                        local isPendingKill = false
                                        pcall(function() if type(veh.IsPendingKill) == "function" then isPendingKill = veh:IsPendingKill() end end)
                                        
                                        if not isPendingKill then
                                            local vehName = "Xe"
                                            local hasDriver = false
                                            
                                            pcall(function()
                                                if type(veh.GetVehicleName) == "function" then vehName = veh:GetVehicleName() elseif veh.VehicleName then vehName = veh.VehicleName end
                                                local driver = type(veh.GetDriver) == "function" and veh:GetDriver() or nil
                                                if slua.isValid(driver) then hasDriver = true end
                                            end)
                                            
                                            local nameLower = string.lower(tostring(vehName) .. tostring(veh))
                                            local displayName = "Car"
                                            if string.find(nameLower, "uaz") then displayName = "UAZ"
                                            elseif string.find(nameLower, "dacia") then displayName = "Dacia"
                                            elseif string.find(nameLower, "buggy") then displayName = "Buggy"
                                            elseif string.find(nameLower, "mirado") then displayName = "Mirado"
                                            elseif string.find(nameLower, "bike") or string.find(nameLower, "motor") then displayName = "Motor"
                                            elseif string.find(nameLower, "scooter") then displayName = "Scooter"
                                            elseif string.find(nameLower, "coupe") then displayName = "Coupe RB"
                                            elseif string.find(nameLower, "brdm") then displayName = "BRDM"
                                            elseif string.find(nameLower, "boat") or string.find(nameLower, "aquarail") then displayName = "boat"
                                            elseif string.find(nameLower, "glider") then displayName = "glider"
                                            else displayName = "glider (" .. string.sub(vehName, 1, 8) .. ")" end

                                            table.insert(activeVehicles, {act = veh, name = displayName, hasDriver = hasDriver})
                                        end
                                    end
                                end
                            end
                            _G.CachedVehicles = activeVehicles
                        end

                        if _G.CachedVehicles then
                            for _, item in ipairs(_G.CachedVehicles) do
                                local veh = item.act
                                if slua.isValid(veh) and not veh.bHidden then
                                    local isShow = false
                                    if item.name == "Dacia" then isShow = _G.LynceConfig.EspVeh_Dacia
                                    elseif item.name == "UAZ" then isShow = _G.LynceConfig.EspVeh_UAZ
                                    elseif item.name == "Buggy" then isShow = _G.LynceConfig.EspVeh_Buggy
                                    elseif item.name == "Coupe RB" then isShow = _G.LynceConfig.EspVeh_Coupe
                                    elseif item.name == "Mirado" then isShow = _G.LynceConfig.EspVeh_Mirado
                                    elseif item.name == "Motor" or item.name == "Scooter" then isShow = _G.LynceConfig.EspVeh_Motor
                                    else isShow = _G.LynceConfig.EspVeh_Other end

                                    if isShow then
                                        local distM = 0
                                        pcall(function() distM = localPlayer:GetDistanceTo(veh) / 100 end)
                                        
                                        if distM > 0 and distM <= 300 then
                                            local text = string.format("%s [%dm]", item.name, math.floor(distM))
                                            local vehColor = item.hasDriver and {R=255, G=50, B=50, A=255} or {R=0, G=255, B=150, A=255}
                                            local dynamicScale = math.max(0.6, 1.1 - (distM / 500))
                                            
                                            MyHUD:AddDebugText(text, veh, 0.06, {X=0, Y=0, Z=50}, {X=0, Y=0, Z=50}, vehColor, true, false, true, nil, dynamicScale, true)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end

    end)
end

_G.LynceState.LoopToken = (_G.LynceState.LoopToken or 0) + 1 
local myToken = _G.LynceState.LoopToken

local function ExpiredTick()
    if not _G.LynceNotifiedPopup then
        pcall(function()
            local Msg = require("client.slua.logic.common.logic_common_msg_box")
            if Msg and Msg.Show then
                Msg.Show(1, "MASA BERLAKU MOD TELAH HABIS", "VERSI MOD ANDA TELAH KADALUARSA!\nSILAHKAN HUBUNGI ADMIN UNTUK PERPANJANG.\nHubungi Tele @zexgodx Untuk Membeli Jika Seseorang Menjual Ini Kepada Anda Selain Saya, Maka Selamat Anda Telah Tertipu", 
                function() 
                    local Web = require("client.slua.logic.url.logic_webview_sdk")
                    if Web and Web.OpenURL then Web:OpenURL("https://t.me/zexgodx") end 
                end, 
                function() end, "HUBUNGI PEMBUAT MOD", "TUTUP")
                _G.LynceNotifiedPopup = true 
            end
        end)
        
        if not _G.LynceNotifiedPopup then
            local okTicker, ticker = pcall(require, "common.time_ticker") 
            if okTicker and ticker and ticker.AddTimerOnce then 
                ticker.AddTimerOnce(2.0, ExpiredTick) 
            end
        end
    end
end

local function FastTick() 
    if isExpired then 
        if not _G.LynceNotifiedExpire then
            Notify("MOD TELAH KADALUARSA! SILAHKAN HUBUNGI ADMIN UNTUK PERPANJANG!\nHubungi Tele @zexygodx Untuk Membeli Jika Seseorang Menjual Ini Kepada Anda Selain Saya, Maka Selamat Anda Telah Tertipu")
            _G.LynceNotifiedExpire = true
            ExpiredTick() 
        end
        return 
    end

    if myToken ~= _G.LynceState.LoopToken then return end
    pcall(MainLoop) 
    local okTicker, ticker = pcall(require, "common.time_ticker") 
    if okTicker and ticker and ticker.AddTimerOnce then 
        ticker.AddTimerOnce(0.01, FastTick) 
    end 
end

if not isExpired then
    FastTick() 
    Notify("Anda Sedang Menggunakan Mod Vvip Saya Jika Belum Punya Key Hubungi Tele @Lynce Untuk Membeli Jika Seseorang Menjual Ini Kepada Anda Selain Saya, Maka Selamat Anda Telah Tertipu")
else
    FastTick() 
end

-- ===================================================================================
-- SYSTEM HOOKS TỪ BYPASS MỚI
-- ===================================================================================
local function InitAllModSystems()
    if isExpired then return end 

    pcall(function()
        if _G.StartBypass_VIP_v3 then _G.StartBypass_VIP_v3() end
        if _G.InitializeAutoHeadHooks then _G.InitializeAutoHeadHooks() end
    end)

    local GameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"] or require("GameLua.GameCore.Data.GameplayData")
    if not GameplayData then return end

    pcall(function()
        local LocalPlayer = GameplayData.GetPlayerCharacter and GameplayData.GetPlayerCharacter()
        if slua.isValid(LocalPlayer) then
            if LocalPlayer.bHasShownDevNotice == nil then
                LocalPlayer.bHasShownDevNotice = false 
                LocalPlayer.bHasShownExpiredNotice = false 
                LocalPlayer.bIsDeadFlag = false
            end
        end
    end)
end

if not isExpired then
    pcall(function() 
        require("common.time_ticker").AddTimerOnce(0.5, InitAllModSystems) 
    end)
end

-- ==============================================================================
-- ==============================================================================

-- ==============================================================================
-- ================= BẮT ĐẦU LOGIC MOD EMOTE (CHỈ INGAME - 0% DROP FPS) =========
-- ==============================================================================
pcall(function()
    local QuickExpressionUtils = require("GameLua.Mod.BaseMod.Client.Emote.QuickExpressionUtils")

    -- Danh sách ID Hành Động VIP
    local EXTRA_EMOTES = {
          -- [ HÀNH ĐỘNG ]
    12201301, -- Hành động Sát thủ Gothic
    12216101, -- Hành động Võ sĩ Huyết Ưng
    12212201, -- Hành động Sát thủ Cực Ám
    12219207, -- Hành động Đại tướng Thiên Ngưu
    12209001, -- Hành động Võ sĩ (Samurai)
    12219561, -- Hành động Áo choàng Đỏ thẫm
    12210001, -- Hành động Cái chạm của Tử thần
    12219022, -- Hành động Thiết vệ Gai góc
    12208801, -- Hành động Dũng sĩ Bán thần
    12210801, -- Hành động Thợ săn Vỏ bạc
    12200701, -- Hành động Du hành Không thời gian
    12219242, -- Hành động Dạo bước Bầu trời
    12206001, -- Hành động Hoa linh Đồng xanh
    12205401, -- Hành động Vua của muôn thú
    12205201, -- Hành động Trái tim Cự thú
    12212601, -- Hành động Sát lục Thần bí
    12205601, -- Hành động Linh hồn Cự thú
    12219208, -- Hành động Hầu vương Cyber
    12212001, -- Hành động Võ thánh
    12206801, -- Hành động Hải long Thần bí
    12209801, -- Hành động Ngự linh sư
    12211401, -- Hành động Nữ phù thủy Băng tuyết
    12207001, -- Hành động Du hành Biển sao
    12211801, -- Hành động Chúa tể Trật tự
    12207901, -- Hành động Hải vương Quyến rũ
    12203401, -- Hành động Kỷ niệm Ảo ảnh
    12204001, -- Hành động Chú hề (Ngày Cá tháng Tư)
    12201801, -- Hành động Người bảo vệ Vùng tuyết
    12215601, -- Hành động Siêu nhân Hằng tinh
    12215532, -- Hành động Lãnh chúa Ngọn lửa
    12213201, -- Hành động Kế hoạch Ngày mai
    12215529, -- Hành động Kỵ sĩ Đua xe
    12219053, -- Hành động Nữ hoàng Trân bảo
    12204601, -- Hành động Thiên hạ Bố võ
    12215701, -- Hành động Hành tinh Vượn người
    12219003, -- Hành động Bóng tối Thần linh
    12219004, -- Hành động Ngân hồn Rực lửa
    12219009, -- Hành động Mê hoặc Rực lửa
    12219216, -- Hành động Tế tư Héo úa
    }

    -- TỐI ƯU CỰC ĐỘ: Cache dữ liệu trên RAM để game không phải tạo bảng mới mỗi lần bấm nút
    local CachedInGameEmotes = nil
    local LastBaseCount = -1
    local LastEmoteSwitchState = nil

    -- Hàm trộn Emote 1 lần duy nhất
    local function GetOptimizedEmoteList(baseList)
        local baseCount = baseList and #baseList or 0
        local isEmoteModEnabled = _G.LynceConfig.ModEmote == true

        -- Nếu đã trộn rồi, số lượng Emote gốc không đổi, VÀ trạng thái nút Bật/Tắt không đổi -> Lấy luôn từ Cache ra xài
        if CachedInGameEmotes and LastBaseCount == baseCount and LastEmoteSwitchState == isEmoteModEnabled then
            return CachedInGameEmotes
        end

        local compact = {}
        local seen = {}
        
        -- 1. Thêm Emote mặc định của người chơi
        if baseList then
            for _, data in pairs(baseList) do
                if data and data.DefineID and data.DefineID.TypeSpecificID then
                    table.insert(compact, data)
                    seen[data.DefineID.TypeSpecificID] = true
                end
            end
        end

        -- 2. CHỈ Thêm Emote VIP NẾU ĐANG BẬT CÔNG TẮC
        if isEmoteModEnabled then
            for _, nEmoteID in ipairs(EXTRA_EMOTES) do
                if not seen[nEmoteID] then
                    table.insert(compact, {
                        DefineID = {TypeSpecificID = nEmoteID},
                        Name = tostring(nEmoteID)
                    })
                    seen[nEmoteID] = true
                end
            end
        end

        CachedInGameEmotes = compact
        LastBaseCount = baseCount
        LastEmoteSwitchState = isEmoteModEnabled
        return CachedInGameEmotes
    end

    -- Hook vào hàm Load danh sách của In-game
    if QuickExpressionUtils and not _G.__EMOTE_INGAME_HOOKED then
        _G.__EMOTE_INGAME_HOOKED = true
        _G.__EMOTE_ORIG_GET_LIST = QuickExpressionUtils.GetShowExpressionList
        
        QuickExpressionUtils.GetShowExpressionList = function()
            local baseList, nWeaponShowEmoteID = _G.__EMOTE_ORIG_GET_LIST()
            return GetOptimizedEmoteList(baseList), nWeaponShowEmoteID
        end
    end

    -- Hook vào sự kiện bấm nút Emote trong game để ép UI vẽ ra
    if not _G.__EMOTE_MENU_EVENT_HOOKED and EventSystem and EventSystem.registEvent then
        _G.__EMOTE_MENU_EVENT_HOOKED = true
        EventSystem:registEvent(EVENTTYPE_INGAME, EVENTID_INGAME_QUICK_EXPRESSION_DECAL_CLICK, function()
            pcall(function()
                -- NẾU ĐANG TẮT MOD EMOTE -> Trả về giao diện mặc định của Game để khỏi lỗi UI
                if not _G.LynceConfig.ModEmote then return end 

                local UIManager = require("client.slua_ui_framework.manager")
                if not UIManager or not UIManager.UI_Config_InGame then return end
                local subPanel = UIManager.GetUI(UIManager.UI_Config_InGame.QuickExpressionDecalSubPanel)
                
                if subPanel and subPanel.GetQuickExpressionDecalItemByIndex and CachedInGameEmotes then
                    local showCount = 0
                    for _, data in ipairs(CachedInGameEmotes) do
                        local nEmoteID = data.DefineID and data.DefineID.TypeSpecificID
                        if nEmoteID and nEmoteID > 0 then
                            showCount = showCount + 1
                            local item = subPanel:GetQuickExpressionDecalItemByIndex(showCount)
                            if item then
                                -- Tắt các hiệu ứng thừa làm nặng máy
                                if item.UIRoot.WidgetSwitcher_Effect then item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
                                if item.UIRoot.Image_Weapon then item.UIRoot.Image_Weapon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
                                
                                item:Show()
                                item:RefreshData(nEmoteID, -1)
                            end
                        end
                    end
                    if subPanel.HideRestBlocks then subPanel:HideRestBlocks(showCount) end
                    if subPanel.UIRoot then
                        subPanel.UIRoot.WrapBox_List:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
                        subPanel.UIRoot.VerticalBox_Empty:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                    end
                end
            end)
        end)
    end
end)
-- ==============================================================================
-- ================= KẾT THÚC LOGIC MOD EMOTE ===================================
-- ==============================================================================


-- ==========================================
-- WM 
-- ==========================================
pcall(function()
    local _0xM = require(
        "GameLua.Mod.Library.Client.UI.IngamePhoneStateUI"
    )

    if _0xM and _0xM.__inner_impl then
        local _0xO = _0xM.__inner_impl.UpdateArtQualityUI

        _0xM.__inner_impl.UpdateArtQualityUI = function(_0xS, ...)
            if _0xO then
                _0xO(_0xS, ...)
            end

            local _0xU = _0xS.UIRoot
            local _0xT = _0xU and _0xU.TextBlock_quality

            if _0xT then
                local _0xA = string.char

                _0xT:SetText(table.concat({
                    _0xA(71), _0xA(79), _0xA(68),
                    _0xA(77), _0xA(79), _0xA(68),
                    _0xA(32),
                    _0xA(88), _0xA(55)
                }))

                local _0xC = FLinearColor(
                    0.0,
                    1.0,
                    0.0,
                    1.0
                )

                _0xT:SetColorAndOpacity(
                    FSlateColor(_0xC)
                )

                if _0xT.SetShadowOffset
                   and _0xT.SetShadowColorAndOpacity then

                    _0xT:SetShadowOffset(
                        FVector2D(2.0, 2.0)
                    )

                    _0xT:SetShadowColorAndOpacity(
                        FLinearColor(
                            0.0,
                            0.0,
                            0.0,
                            0.5
                        )
                    )
                end
            end
        end
    end
end)


pcall(function()
    local wm = require("client.slua.logic.lobby_watermark.logic_lobby_watermark")

    if wm then
        wm.GetWatermarkString = function()
            return "G O D M O D X 7"
        end

        wm.GetFightingWatermarkString = function()
            return "TG @zexygodx OWN GODMOD"
        end
    end
end)


-- ==============================================================================
-- ================= KẾT THÚC LOGIC LOBBY SUPER CAR (SẢNH SIÊU XE) ==============
-- ==============================================================================


-- ============================================================
-- 🎯 MORTAR AUTO AIM - TERINTEGRASI DENGAN FLUXMOD MENU
-- ============================================================

-- ============================================================
-- 1. KONFIGURASI DARI MOD MENU
-- ============================================================
_G.LynceConfig = _G.LynceConfig or {}
_G.LynceConfig.MortarAim = false

_G.LynceState = _G.LynceState or {}
_G.LynceState.CustomTextData = _G.LynceState.CustomTextData or {}

-- Default parameters (akan di-override oleh menu)
_G.LynceState.CustomTextData.MortarMaxRange = 600
_G.LynceState.CustomTextData.MortarFOV = 40
_G.LynceState.CustomTextData.MortarPitchWeight = 0.3
_G.LynceState.CustomTextData.MortarSwipeBreak = 3.5
_G.LynceState.CustomTextData.MortarBaseGravity = 980

-- ============================================================
-- 2. MORTAR AIM CLASS (SEBAGAI BAGIAN DARI M)
-- ============================================================
M.MortarAim = {
    Config = {
        AimInterval = 0.03,
    },
    _gameplayData = nil,
    _gameplayDataReady = false,
    _lockedTarget = nil,
    _lastAimRotation = nil,
    _aimActive = false,
    _started = false,
    _mortarTickId = nil,
    _mortarRunning = false,
}

local MortarAim = M.MortarAim

-- ============================================================
-- 3. NOTIFY FUNCTION
-- ============================================================
local function notify(message)
    pcall(function()
        if _G.LynceNotify then
            _G.LynceNotify("[Mortar] " .. tostring(message))
        end
    end)
    
    pcall(function()
        local sh = import("ScriptHelperClient")
        if sh and sh.AddOnScreenDebugMessage then
            sh.AddOnScreenDebugMessage("[Mortar] " .. tostring(message), -1, 2.0, {R=1, G=1, B=0, A=1}, {X=1.0, Y=1.0})
        end
    end)
    
    print("[Mortar] " .. tostring(message))
end

-- ============================================================
-- 4. UTILITY FUNCTIONS (DIADAKSI DARI M)
-- ============================================================
local function Valid(obj)
    if not obj then return false end
    local slua = rawget(_G, "slua")
    if slua and type(slua.isValid) == "function" then
        local ok, result = pcall(slua.isValid, obj)
        return ok and result == true
    end
    return true
end

local function ensure_gameplay_data()
    if MortarAim._gameplayDataReady and MortarAim._gameplayData then return true end
    local ok, module = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if ok and module then MortarAim._gameplayData = module end
    MortarAim._gameplayDataReady = MortarAim._gameplayData ~= nil
    return MortarAim._gameplayDataReady
end

local function normalize_angle(angle)
    while angle > 180.0 do angle = angle - 360.0 end
    while angle < -180.0 do angle = angle + 360.0 end
    return angle
end

local function atan2(y, x)
    if x > 0 then return math.atan(y / x)
    elseif x < 0 and y >= 0 then return math.atan(y / x) + math.pi
    elseif x < 0 and y < 0 then return math.atan(y / x) - math.pi
    elseif x == 0 and y > 0 then return math.pi / 2
    elseif x == 0 and y < 0 then return -math.pi / 2
    end
    return 0
end

local function get_player()
    return slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController() and slua_GameFrontendHUD:GetPlayerController():GetPlayerCharacterSafety()
end

local function get_controller()
    return slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
end

local function get_camera(controller)
    local camera
    pcall(function()
        camera = controller and controller.PlayerCameraManager
    end)
    return camera
end

local function get_location(actor)
    local location
    pcall(function()
        if actor and type(actor.K2_GetActorLocation) == "function" then
            location = actor:K2_GetActorLocation()
        end
    end)
    return location
end

local function get_weapon(player)
    local weapon
    pcall(function()
        weapon = player and player.CurrentWeapon
        if not weapon and player and type(player.GetCurrentWeapon) == "function" then
            weapon = player:GetCurrentWeapon()
        end
    end)
    return weapon
end

local function is_dead(actor)
    local result = false
    pcall(function()
        result = actor.bDead == true or actor.bIsDead == true or actor.bIsDeadFlag == true
        if actor.HealthStatus ~= nil and actor.HealthStatus == 2 then result = true end
    end)
    return result
end

local function team_value(actor)
    local value
    pcall(function()
        value = actor.TeamID
        if value == nil and actor.PlayerState then
            value = actor.PlayerState.TeamNum
        end
    end)
    return value
end

local function same_player_key(a, b)
    if not Valid(a) or not Valid(b) or a == b then return a == b end
    local ak, bk
    pcall(function() ak = a.PlayerKey end)
    pcall(function() bk = b.PlayerKey end)
    if ak ~= nil and bk ~= nil then return ak == bk end
    return false
end

local function is_enemy(local_actor, actor)
    if not Valid(actor) or actor == local_actor or same_player_key(local_actor, actor) then
        return false
    end
    local local_team = team_value(local_actor)
    local actor_team = team_value(actor)
    if local_team ~= nil and actor_team ~= nil and local_team == actor_team then
        return false
    end
    return true
end

local function collect_characters()
    local result = {}
    local function add(list)
        if type(list) ~= "table" then return end
        for _, actor in pairs(list) do
            if Valid(actor) then result[actor] = true end
        end
    end
    pcall(function()
        if MortarAim._gameplayData and type(MortarAim._gameplayData.GetAllPlayerCharacters) == "function" then
            add(MortarAim._gameplayData.GetAllPlayerCharacters())
        end
    end)
    pcall(function()
        if MortarAim._gameplayData and type(MortarAim._gameplayData.GetAllCharacters) == "function" then
            add(MortarAim._gameplayData.GetAllCharacters())
        end
    end)
    return result
end

-- ============================================================
-- 5. BALLISTICS CALCULATION
-- ============================================================
local function solve_ballistic_pitch(horizontal, vertical, velocity, gravity)
    local velocity2 = velocity * velocity
    local velocity4 = velocity2 * velocity2
    local discriminant = velocity4 - gravity * gravity * horizontal * horizontal
    discriminant = discriminant - 2.0 * gravity * vertical * velocity2
    if discriminant < 0 then return 45.0 end
    local root = math.sqrt(discriminant)
    local denominator = gravity * horizontal
    local angle = denominator == 0 and 90.0 or math.atan((velocity2 + root) / denominator) * (180.0 / math.pi)
    if angle < 45.0 then angle = 45.0 end
    if angle > 88.0 then angle = 88.0 end
    return angle
end

local function reverse_map_pitch(ballistic_pitch)
    local value = (ballistic_pitch - 45.0) * 2.0930232558139537 - 60.0
    if value < -60.0 then value = -60.0 end
    if value > 30.0 then value = 30.0 end
    return value
end

local function get_ballistics(weapon)
    local state
    local velocity
    local gravity_scale
    pcall(function() state = weapon and weapon.MortarAimState end)
    pcall(function()
        if weapon and type(weapon.GetBulletFireSpeedFromEntity) == "function" then
            velocity = tonumber(weapon:GetBulletFireSpeedFromEntity())
        end
    end)
    if not velocity or velocity <= 0 then
        velocity = state == 1 and 12520.0 or 9070.0
    end
    pcall(function()
        local entity = weapon and weapon.ShootWeaponEntity
        if Valid(entity) and entity.LaunchGravityScale then
            gravity_scale = tonumber(entity.LaunchGravityScale)
        end
    end)
    if not gravity_scale or gravity_scale <= 0 then
        gravity_scale = state == 1 and 4.0 or 2.8
    end
    local baseGravity = _G.LynceState.CustomTextData.MortarBaseGravity or 980
    return velocity, baseGravity * gravity_scale
end

-- ============================================================
-- 6. CHECK MORTAR WEAPON
-- ============================================================
local function is_mortar_weapon(weapon)
    if not Valid(weapon) then return false end
    local state
    pcall(function() state = weapon.MortarState end)
    if state ~= nil and tonumber(state) ~= 2 then return false end
    local name = ""
    pcall(function() name = string.lower(tostring(weapon)) end)
    return string.find(name, "mortar", 1, true) ~= nil or state == 2
end

-- ============================================================
-- 7. FIND TARGET
-- ============================================================
local function find_target(local_actor, controller)
    local camera = get_camera(controller)
    if not Valid(camera) then return nil end
    
    local camera_location, camera_rotation
    pcall(function()
        camera_location = camera:GetCameraLocation()
        camera_rotation = camera:GetCameraRotation()
    end)
    if not camera_location or not camera_rotation then return nil end
    
    local maxRange = _G.LynceState.CustomTextData.MortarMaxRange or 600
    local fov = _G.LynceState.CustomTextData.MortarFOV or 40
    local pitchWeight = _G.LynceState.CustomTextData.MortarPitchWeight or 0.3
    
    local best_score = fov
    local best_target
    
    for actor in pairs(collect_characters()) do
        if is_enemy(local_actor, actor) and not is_dead(actor) then
            local location = get_location(actor)
            if location then
                local dx = location.X - camera_location.X
                local dy = location.Y - camera_location.Y
                local dz = location.Z - camera_location.Z
                local horizontal = math.sqrt(dx * dx + dy * dy)
                local distance = horizontal / 100.0
                
                if distance <= maxRange then
                    local yaw = atan2(dy, dx) * (180.0 / math.pi)
                    local pitch = atan2(dz, horizontal) * (180.0 / math.pi)
                    local yaw_delta = math.abs(normalize_angle(yaw - camera_rotation.Yaw))
                    local pitch_delta = math.abs(normalize_angle(pitch - camera_rotation.Pitch))
                    
                    if yaw_delta <= fov then
                        local score = math.sqrt(yaw_delta * yaw_delta + (pitch_delta * pitchWeight) ^ 2)
                        if score < best_score then
                            best_score = score
                            best_target = actor
                        end
                    end
                end
            end
        end
    end
    return best_target
end

-- ============================================================
-- 8. APPLY ROTATION
-- ============================================================
local function apply_rotation(player, controller, camera, rotation, yaw)
    pcall(function()
        if Valid(camera) then
            camera.bLimitViewPitch = false
            camera.bLimitViewYaw = false
            camera.ViewPitchMin = -89.9
            camera.ViewPitchMax = 89.9
        end
        if type(player.K2_SetActorRotation) == "function" and type(FRotator) == "function" then
            player:K2_SetActorRotation(FRotator(0, yaw, 0), false)
        end
        player.BaseAimRotation = rotation
        controller.ControlRotation = rotation
    end)
    MortarAim._lastAimRotation = rotation
end

-- ============================================================
-- 9. MAIN TICK (SEBAGAI METHOD M.MortarAim)
-- ============================================================
function M.MortarAim.Tick()
    -- CEK APAKAH MORTAR AIM AKTIF DARI MOD MENU
    if not _G.LynceConfig.MortarAim then
        if MortarAim._aimActive then
            MortarAim._aimActive = false
            MortarAim._lockedTarget = nil
            MortarAim._lastAimRotation = nil
        end
        return
    end
    
    if not ensure_gameplay_data() then return end
    
    local player = get_player()
    local controller = get_controller()
    if not Valid(player) or not Valid(controller) then return end
    
    local camera = get_camera(controller)
    if not Valid(camera) then return end
    
    local camera_rotation
    pcall(function() camera_rotation = camera:GetCameraRotation() end)
    if not camera_rotation then return end
    
    local weapon = get_weapon(player)
    if not is_mortar_weapon(weapon) then
        if MortarAim._aimActive then
            MortarAim._aimActive = false
            MortarAim._lockedTarget = nil
            MortarAim._lastAimRotation = nil
            notify("Auto Aim OFF - Not Mortar")
        end
        return
    end
    
    if not MortarAim._aimActive then
        MortarAim._aimActive = true
        notify("🎯 Mortar Aim Active!")
    end
    
    -- Check swipe break
    local swipeBreak = _G.LynceState.CustomTextData.MortarSwipeBreak or 3.5
    if MortarAim._lockedTarget and MortarAim._lastAimRotation then
        local yaw_delta = math.abs(normalize_angle(camera_rotation.Yaw - MortarAim._lastAimRotation.Yaw))
        local pitch_delta = math.abs(normalize_angle(camera_rotation.Pitch - MortarAim._lastAimRotation.Pitch))
        if yaw_delta > swipeBreak or pitch_delta > swipeBreak then
            MortarAim._lockedTarget = nil
            MortarAim._lastAimRotation = nil
            notify("🔄 Target Unlocked (Swiped)")
        end
    end
    
    -- Check target masih valid
    if MortarAim._lockedTarget and (not is_enemy(player, MortarAim._lockedTarget) or is_dead(MortarAim._lockedTarget)) then
        MortarAim._lockedTarget = nil
    end
    
    -- Check range
    if MortarAim._lockedTarget then
        local p = get_location(player)
        local t = get_location(MortarAim._lockedTarget)
        local maxRange = _G.LynceState.CustomTextData.MortarMaxRange or 600
        if p and t then
            local dx, dy, dz = t.X - p.X, t.Y - p.Y, t.Z - p.Z
            if math.sqrt(dx * dx + dy * dy) / 100.0 > maxRange then
                MortarAim._lockedTarget = nil
            end
        else
            MortarAim._lockedTarget = nil
        end
    end
    
    -- Find new target if needed
    if not MortarAim._lockedTarget then
        MortarAim._lockedTarget = find_target(player, controller)
        if MortarAim._lockedTarget then
            notify("🎯 Target Locked!")
        end
    end
    
    if not MortarAim._lockedTarget then
        MortarAim._lastAimRotation = nil
        return
    end
    
    -- Aim at target
    local origin = get_location(player)
    local target = get_location(MortarAim._lockedTarget)
    if not origin or not target then
        MortarAim._lockedTarget = nil
        return
    end
    
    local dx, dy, dz = target.X - origin.X, target.Y - origin.Y, target.Z - origin.Z
    local horizontal = math.sqrt(dx * dx + dy * dy)
    local velocity, gravity = get_ballistics(weapon)
    local ballistic_pitch = solve_ballistic_pitch(horizontal, dz, velocity, gravity)
    local pitch = reverse_map_pitch(ballistic_pitch)
    local yaw = atan2(dy, dx) * (180.0 / math.pi)
    local rotation = FRotator(pitch, yaw, 0)
    apply_rotation(player, controller, camera, rotation, yaw)
end

-- ============================================================
-- 10. START & STOP FUNCTIONS (SEBAGAI METHOD M)
-- ============================================================
function M.MortarAim.Start()
    if MortarAim._started then return true end
    
    -- Cek zexgodAddTick tersedia
    if _G.zexgodAddTick then
        _G.zexgodAddTick(M.MortarAim.Tick)
        MortarAim._started = true
        MortarAim._mortarRunning = true
        notify("✅ Mortar Auto Aim - Registered to zexgodAddTick")
        return true
    end
    
    -- Fallback: time_ticker
    local ticker = package.loaded["common.time_ticker"] or require("common.time_ticker")
    if ticker and type(ticker.AddTimerLoop) == "function" then
        MortarAim._mortarTickId = ticker.AddTimerLoop(0, M.MortarAim.Tick, -1, 0.03)
        MortarAim._started = true
        MortarAim._mortarRunning = true
        notify("✅ Mortar Auto Aim - Running with time_ticker")
        return true
    end
    
    notify("❌ ERROR: Failed to start Mortar Aim!")
    return false
end

function M.MortarAim.Stop()
    if MortarAim._mortarTickId then
        local ticker = package.loaded["common.time_ticker"] or require("common.time_ticker")
        if ticker and type(ticker.RemoveTimer) == "function" then
            ticker.RemoveTimer(MortarAim._mortarTickId)
        end
        MortarAim._mortarTickId = nil
    end
    MortarAim._started = false
    MortarAim._mortarRunning = false
    MortarAim._aimActive = false
    MortarAim._lockedTarget = nil
    MortarAim._lastAimRotation = nil
    notify("🛑 Mortar Auto Aim Stopped")
end

-- ============================================================
-- 11. TOGGLE FUNCTION UNTUK MOD MENU
-- ============================================================
function _G.ToggleMortarAim(state)
    _G.LynceConfig.MortarAim = state == true
    if state then
        M.MortarAim.Start()
    else
        M.MortarAim.Stop()
    end
    return _G.LynceConfig.MortarAim
end

-- ============================================================
-- 12. REGISTRASI KE zexgodAddTick (EKSTRA - DOUBLE PROTECTION)
-- ============================================================
if _G.zexgodAddTick then
    _G.zexgodAddTick(function()
        if _G.LynceConfig and _G.LynceConfig.MortarAim then
            if M.MortarAim and M.MortarAim.Tick then
                pcall(M.MortarAim.Tick)
            end
        end
    end)
    print("[Mortar] ✅ Registered to zexgodAddTick (double protection)")
else
    local function MortarLoop()
        if _G.LynceConfig and _G.LynceConfig.MortarAim then
            if M.MortarAim and M.MortarAim.Tick then
                pcall(M.MortarAim.Tick)
            end
        end
        
        local okTicker, ticker = pcall(require, "common.time_ticker")
        if okTicker and ticker and ticker.AddTimerOnce then
            ticker.AddTimerOnce(0.03, MortarLoop)
        end
    end
    
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.1, MortarLoop)
    end
    print("[Mortar] ✅ Running with time_ticker fallback (double protection)")
end

-- ============================================================
-- 13. REGISTRASI KE LOADER
-- ============================================================
if _G.zexgodRegisterMod then
    _G.zexgodRegisterMod("Mortar Aim", "✅ Loaded - Enable from zexgod Menu")
end

print("[Mortar] ════════════════════════════════════════")
print("[Mortar] 📌 Mortar Auto Aim Loaded!")
print("[Mortar] ✅ Status: Waiting for user enable from menu")
print("[Mortar] ✅ Menu: FLUXMOD MENU -> Aimbot -> Mortar Aim")
print("[Mortar] ════════════════════════════════════════")


-- ============================================================
-- 🎮 FITUR HIBURAN FLUXMOD- TERINTEGRASI DENGAN MOD MENU
-- ============================================================

-- ============================================================
-- 🎮 FITUR HIBURAN FLUXMOD- FIXED
-- ============================================================

-- ============================================================
-- 1. KONFIGURASI
-- ============================================================
_G.zexgodConfig = _G.zexgodConfig or {}
_G.zexgodConfig.WallClimb = 0
_G.zexgodConfig.QuickSwitch = 0
_G.zexgodConfig.BodyColor = 0
_G.zexgodConfig.BodyColorName = "Hijau"
_G.zexgodConfig.VehicleFly = 0
_G.zexgodConfig.VehicleFlySpeed = 800
_G.zexgodConfig.VehicleFlyMaxHeight = 20000
_G.zexgodConfig.FastCar = 0
_G.zexgodConfig.FastCarSpeed = 10000

-- ============================================================
-- 2. VARIABEL INTERNAL
-- ============================================================
_G._vehicleFly = _G._vehicleFly or {
    initialHeight = nil,
    targetHeight = nil,
    isReady = false,
    lastApplyTime = 0,
    lastVehicle = nil,
    forceApply = false
}

local _wallClimbApplied = false
local _lastProcessTime = 0
local _bodyColorApplied = false
local _bodyColorEnemies = {}

-- ============================================================
-- 3. FUNGSI UTILITY (PAKAI SLUA LANGSUNG)
-- ============================================================
local function Valid(obj)
    if not obj then return false end
    local slua = rawget(_G, "slua")
    if slua and type(slua.isValid) == "function" then
        local ok, result = pcall(slua.isValid, obj)
        return ok and result == true
    end
    return true
end

local function GetGameplayData()
    local ok, gd = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if ok and gd then return gd end
    return nil
end

local function GetLocalPlayer()
    local gd = GetGameplayData()
    if not gd then return nil end
    local ok, player = pcall(gd.GetPlayerCharacter)
    if ok and Valid(player) then return player end
    return nil
end

-- ============================================================
-- 4. WALL CLIMB (PANJAT DINDING) - FIXED
-- ============================================================
function M.WallClimb_Enable()
    if _G.zexgodConfig.WallClimb ~= 1 then return end
    
    pcall(function()
        local me = GetLocalPlayer()
        if not Valid(me) then return end
        
        local charMove = me.CharacterMovement or me.CharMoveComp
        if Valid(charMove) then
            charMove.WalkableFloorAngle = 199.0
            charMove.MaxStepHeight = 999.0
            charMove.BrakingDecelerationWalking = 9999.0
            charMove.GroundFriction = 8.0
            charMove.AirControl = 1.0
            if charMove.NavAgentProps then
                charMove.NavAgentProps.bCanWalk = true
                charMove.NavAgentProps.bCanClimb = true
            end
            _wallClimbApplied = true
        end
    end)
end

function M.WallClimb_Disable()
    pcall(function()
        local me = GetLocalPlayer()
        if not Valid(me) then return end
        
        local charMove = me.CharacterMovement or me.CharMoveComp
        if Valid(charMove) then
            charMove.WalkableFloorAngle = 44.0
            charMove.MaxStepHeight = 45.0
            charMove.BrakingDecelerationWalking = 200.0
            charMove.GroundFriction = 2.0
            charMove.AirControl = 0.5
            if charMove.NavAgentProps then
                charMove.NavAgentProps.bCanWalk = true
                charMove.NavAgentProps.bCanClimb = false
            end
            _wallClimbApplied = false
        end
    end)
end

function M.WallClimb_Tick()
    if _G.zexgodConfig.WallClimb == 1 then
        M.WallClimb_Enable()
    elseif _wallClimbApplied then
        M.WallClimb_Disable()
    end
end

_G.zexgodResetWallClimb = M.WallClimb_Disable

-- ============================================================
-- 5. QUICK SWITCH (GANTI SENJATA CEPAT) - FIXED
-- ============================================================
function M.QuickSwitch_Apply()
    if _G.zexgodConfig.QuickSwitch ~= 1 then return end
    
    pcall(function()
        local me = GetLocalPlayer()
        if not Valid(me) then return end
        
        -- COBA DAPATKAN WEAPON MANAGER DARI BERBAGAI CARA
        local weaponManager = nil
        
        -- Cara 1: Langsung dari player
        if Valid(me.WeaponManagerComponent) then
            weaponManager = me.WeaponManagerComponent
        elseif Valid(me.WeaponManager) then
            weaponManager = me.WeaponManager
        elseif type(me.GetWeaponManager) == "function" then
            weaponManager = me:GetWeaponManager()
        end
        
        if not Valid(weaponManager) then return end
        
        -- Dapatkan current weapon
        local currentWeapon = nil
        if Valid(weaponManager.CurrentWeaponReplicated) then
            currentWeapon = weaponManager.CurrentWeaponReplicated
        elseif type(weaponManager.GetCurrentWeapon) == "function" then
            currentWeapon = weaponManager:GetCurrentWeapon()
        elseif Valid(weaponManager.CurrentWeapon) then
            currentWeapon = weaponManager.CurrentWeapon
        end
        
        if not Valid(currentWeapon) then return end
        
        -- Dapatkan ShootWeaponEntity
        local entity = nil
        if Valid(currentWeapon.ShootWeaponEntityComp) then
            entity = currentWeapon.ShootWeaponEntityComp
        elseif Valid(currentWeapon.ShootWeaponEntity) then
            entity = currentWeapon.ShootWeaponEntity
        elseif Valid(currentWeapon.ShootWeaponComponent) and Valid(currentWeapon.ShootWeaponComponent.ShootWeaponEntityComponent) then
            entity = currentWeapon.ShootWeaponComponent.ShootWeaponEntityComponent
        end
        
        if not Valid(entity) then return end
        
        -- SET WAKTU GANTI SENJATA MENJADI 0
        entity.SwitchFromBackpackToIdleTime = 0.0
        entity.SwitchFromIdleToBackpackTime = 0.0
        entity.EquipTime = 0.0
        entity.UnequipTime = 0.0
        
        -- JUGA SET UNTUK WEAPON ITU SENDIRI
        currentWeapon.SwitchFromBackpackToIdleTime = 0.0
        currentWeapon.SwitchFromIdleToBackpackTime = 0.0
        currentWeapon.EquipTime = 0.0
        currentWeapon.UnequipTime = 0.0
    end)
end

function M.QuickSwitch_Tick()
    if _G.zexgodConfig.QuickSwitch == 1 then
        M.QuickSwitch_Apply()
    end
end

-- ============================================================
-- 6. BODY COLOR (WARNA TUBUH MUSUH) - FIXED
-- ============================================================
local function ParseColorToRGB(colorName)
    if not colorName or type(colorName) ~= "string" then return nil end
    local colorMap = {
        ["Merah"] = { R = 255, G = 0, B = 0, A = 255 },
        ["Hijau"] = { R = 0, G = 255, B = 0, A = 255 },
        ["Biru"] = { R = 0, G = 0, B = 255, A = 255 },
        ["Kuning"] = { R = 255, G = 255, B = 0, A = 255 },
        ["Cyan"] = { R = 0, G = 255, B = 255, A = 255 },
        ["Magenta"] = { R = 255, G = 0, B = 255, A = 255 },
        ["Putih"] = { R = 255, G = 255, B = 255, A = 255 },
        ["Orange"] = { R = 255, G = 165, B = 0, A = 255 },
        ["Pink"] = { R = 255, G = 192, B = 203, A = 255 },
        ["Ungu"] = { R = 128, G = 0, B = 128, A = 255 },
    }
    return colorMap[colorName]
end

local function ApplyGlowToMesh(meshComp, glowColor)
    if not slua.isValid(meshComp) or not glowColor then return end
    pcall(function()
        local numMats = 0
        if type(meshComp.GetNumMaterials) == "function" then
            numMats = meshComp:GetNumMaterials()
        elseif meshComp.NumMaterials then
            numMats = meshComp.NumMaterials
        end
        
        for i = 0, math.min(numMats, 10) do
            local originalMat = nil
            if type(meshComp.GetMaterial) == "function" then
                originalMat = meshComp:GetMaterial(i)
            end
            if Valid(originalMat) then
                local dynMat = nil
                if type(meshComp.CreateAndSetMaterialInstanceDynamic) == "function" then
                    dynMat = meshComp:CreateAndSetMaterialInstanceDynamic(i)
                end
                if Valid(dynMat) then
                    pcall(function()
                        dynMat:SetVectorParameterValue("颜色", glowColor)
                        dynMat:SetVectorParameterValue("Extra Light Color", glowColor)
                        dynMat:SetVectorParameterValue("Para_Color", glowColor)
                        dynMat:SetVectorParameterValue("Para_ColorTint", glowColor)
                        dynMat:SetVectorParameterValue("Color", glowColor)
                        dynMat:SetVectorParameterValue("BaseColor", glowColor)
                        dynMat:SetVectorParameterValue("BodyColor", glowColor)
                        dynMat:SetVectorParameterValue("DiffuseColor", glowColor)
                        dynMat:SetVectorParameterValue("EmissiveColor", glowColor)
                        dynMat:SetScalarParameterValue("RimLight", 999)
                        dynMat:SetScalarParameterValue("Brightness", 999)
                        dynMat:SetScalarParameterValue("Exposure", 999)
                        dynMat:SetScalarParameterValue("GlowIntensity", 5.0)
                        dynMat:SetScalarParameterValue("Intensity", 5.0)
                    end)
                end
            end
        end
    end)
end

function M.BodyColor_Apply()
    if _G.zexgodConfig.BodyColor ~= 1 then return end
    
    local colorName = _G.zexgodConfig.BodyColorName or "Hijau"
    local glowColor = ParseColorToRGB(colorName)
    if not glowColor then return end
    
    pcall(function()
        local localPawn = GetLocalPlayer()
        if not Valid(localPawn) then return end
        
        local myTeamId = 0
        if type(localPawn.GetTeamID) == "function" then
            myTeamId = localPawn:GetTeamID()
        elseif localPawn.TeamID ~= nil then
            myTeamId = localPawn.TeamID
        end
        
        local gd = GetGameplayData()
        if not gd then return end
        
        local allPawns = {}
        if type(gd.GetAllPlayerCharacters) == "function" then
            local ok, result = pcall(gd.GetAllPlayerCharacters)
            if ok and result then allPawns = result end
        end
        
        for _, pawn in pairs(allPawns) do
            if Valid(pawn) and pawn ~= localPawn then
                local pawnTeamId = 0
                if type(pawn.GetTeamID) == "function" then
                    pawnTeamId = pawn:GetTeamID()
                elseif pawn.TeamID ~= nil then
                    pawnTeamId = pawn.TeamID
                end
                
                if pawnTeamId ~= myTeamId then
                    local isAlive = false
                    if type(pawn.IsAlive) == "function" then
                        isAlive = pawn:IsAlive()
                    elseif pawn.HealthStatus ~= nil then
                        isAlive = pawn.HealthStatus ~= 2
                    end
                    
                    if isAlive then
                        local meshes = {}
                        if Valid(pawn.Mesh) then
                            table.insert(meshes, pawn.Mesh)
                        end
                        
                        -- Coba dapatkan semua SkeletalMeshComponent
                        pcall(function()
                            local SkeletalMeshClass = import("SkeletalMeshComponent")
                            if SkeletalMeshClass and type(pawn.GetComponentsByClass) == "function" then
                                local childs = pawn:GetComponentsByClass(SkeletalMeshClass)
                                if childs then
                                    local count = 0
                                    if type(childs.Num) == "function" then
                                        count = childs:Num()
                                    elseif #childs then
                                        count = #childs
                                    end
                                    for i = 1, count do
                                        local comp = nil
                                        if type(childs.Get) == "function" then
                                            comp = childs:Get(i-1)
                                        elseif childs[i] then
                                            comp = childs[i]
                                        end
                                        if Valid(comp) and comp ~= pawn.Mesh then
                                            table.insert(meshes, comp)
                                        end
                                    end
                                end
                            end
                        end)
                        
                        for _, meshComp in pairs(meshes) do
                            if Valid(meshComp) then
                                pcall(function()
                                    if type(meshComp.SetRenderCustomDepth) == "function" then
                                        meshComp:SetRenderCustomDepth(true)
                                    end
                                end)
                                ApplyGlowToMesh(meshComp, glowColor)
                            end
                        end
                    end
                end
            end
        end
    end)
end

function M.BodyColor_Reset()
    pcall(function()
        local localPawn = GetLocalPlayer()
        if not Valid(localPawn) then return end
        
        local myTeamId = 0
        if type(localPawn.GetTeamID) == "function" then
            myTeamId = localPawn:GetTeamID()
        elseif localPawn.TeamID ~= nil then
            myTeamId = localPawn.TeamID
        end
        
        local gd = GetGameplayData()
        if not gd then return end
        
        local allPawns = {}
        if type(gd.GetAllPlayerCharacters) == "function" then
            local ok, result = pcall(gd.GetAllPlayerCharacters)
            if ok and result then allPawns = result end
        end
        
        for _, pawn in pairs(allPawns) do
            if Valid(pawn) and pawn ~= localPawn then
                local pawnTeamId = 0
                if type(pawn.GetTeamID) == "function" then
                    pawnTeamId = pawn:GetTeamID()
                elseif pawn.TeamID ~= nil then
                    pawnTeamId = pawn.TeamID
                end
                
                if pawnTeamId ~= myTeamId then
                    local meshes = {}
                    if Valid(pawn.Mesh) then
                        table.insert(meshes, pawn.Mesh)
                    end
                    
                    pcall(function()
                        local SkeletalMeshClass = import("SkeletalMeshComponent")
                        if SkeletalMeshClass and type(pawn.GetComponentsByClass) == "function" then
                            local childs = pawn:GetComponentsByClass(SkeletalMeshClass)
                            if childs then
                                local count = 0
                                if type(childs.Num) == "function" then
                                    count = childs:Num()
                                elseif #childs then
                                    count = #childs
                                end
                                for i = 1, count do
                                    local comp = nil
                                    if type(childs.Get) == "function" then
                                        comp = childs:Get(i-1)
                                    elseif childs[i] then
                                        comp = childs[i]
                                    end
                                    if Valid(comp) and comp ~= pawn.Mesh then
                                        table.insert(meshes, comp)
                                    end
                                end
                            end
                        end
                    end)
                    
                    for _, meshComp in pairs(meshes) do
                        if Valid(meshComp) then
                            pcall(function()
                                if type(meshComp.SetRenderCustomDepth) == "function" then
                                    meshComp:SetRenderCustomDepth(false)
                                end
                            end)
                        end
                    end
                end
            end
        end
    end)
end

function M.BodyColor_Tick()
    if _G.zexgodConfig.BodyColor == 1 then
        M.BodyColor_Apply()
    else
        M.BodyColor_Reset()
    end
end

-- ============================================================
-- 7. VEHICLE FLY (SUDAH AKTIF)
-- ============================================================
function M.VehicleFly_Reset()
    pcall(function()
        local uLocalPlayer = GetLocalPlayer()
        if Valid(uLocalPlayer) then
            local currentVehicle = uLocalPlayer.CurrentVehicle
            if not Valid(currentVehicle) and type(uLocalPlayer.GetVehicle) == "function" then
                currentVehicle = uLocalPlayer:GetVehicle()
            end
            if Valid(currentVehicle) then
                local rootComp = currentVehicle.RootComponent or currentVehicle:K2_GetRootComponent()
                if Valid(rootComp) then
                    if type(rootComp.SetEnableGravity) == "function" then
                        rootComp:SetEnableGravity(true)
                    end
                    if type(rootComp.SetLinearDamping) == "function" then
                        rootComp:SetLinearDamping(0.1)
                    end
                    if type(rootComp.SetAngularDamping) == "function" then
                        rootComp:SetAngularDamping(0.1)
                    end
                    if type(rootComp.SetAllPhysicsLinearVelocity) == "function" then
                        rootComp:SetAllPhysicsLinearVelocity(FVector(0, 0, 0), false)
                    end
                end
            end
        end
        local VF = _G._vehicleFly
        VF.initialHeight = nil
        VF.targetHeight = nil
        VF.isReady = false
        VF.lastVehicle = nil
        VF.forceApply = false
    end)
end

function M.VehicleFly_Process()
    if _G.zexgodConfig.VehicleFly ~= 1 then
        if _G._vehicleFly.isReady then
            M.VehicleFly_Reset()
        end
        return 
    end
    
    local now = os.clock()
    if now - _G._vehicleFly.lastApplyTime < 0.1 then return end
    _G._vehicleFly.lastApplyTime = now
    
    pcall(function()
        local uLocalPlayer = GetLocalPlayer()
        if not Valid(uLocalPlayer) then return end
        
        local currentVehicle = uLocalPlayer.CurrentVehicle
        if not Valid(currentVehicle) and type(uLocalPlayer.GetVehicle) == "function" then
            currentVehicle = uLocalPlayer:GetVehicle()
        end
        if not Valid(currentVehicle) then return end
        
        local VF = _G._vehicleFly
        
        if VF.lastVehicle ~= currentVehicle then
            VF.lastVehicle = currentVehicle
            VF.initialHeight = nil
            VF.targetHeight = nil
            VF.isReady = false
            VF.forceApply = false
        end
        
        local rootComp = currentVehicle.RootComponent or currentVehicle:K2_GetRootComponent()
        if not Valid(rootComp) then return end
        
        if not VF.isReady then
            if type(rootComp.SetEnableGravity) == "function" then
                rootComp:SetEnableGravity(false)
            end
            if type(rootComp.SetLinearDamping) == "function" then
                rootComp:SetLinearDamping(0)
            end
            if type(rootComp.SetAngularDamping) == "function" then
                rootComp:SetAngularDamping(0)
            end
            VF.isReady = true
        end
        
        local currentLoc = nil
        if type(currentVehicle.K2_GetActorLocation) == "function" then
            currentLoc = currentVehicle:K2_GetActorLocation()
        end
        if not currentLoc then return end
        
        if VF.initialHeight == nil then
            VF.initialHeight = currentLoc.Z
            VF.targetHeight = VF.initialHeight + (_G.zexgodConfig.VehicleFlyMaxHeight or 20000)
        end
        
        local diff = VF.targetHeight - currentLoc.Z
        local speed = _G.zexgodConfig.VehicleFlySpeed or 800
        
        if diff > 100 then
            VF.forceApply = true
            
            local currentVel = nil
            if type(rootComp.GetPhysicsLinearVelocity) == "function" then
                currentVel = rootComp:GetPhysicsLinearVelocity()
            end
            if not currentVel then return end
            
            local newVelZ = speed
            if currentVel.Z < speed * 0.8 then
                newVelZ = speed * 1.5
            end
            
            if type(rootComp.SetAllPhysicsLinearVelocity) == "function" then
                rootComp:SetAllPhysicsLinearVelocity(
                    FVector(currentVel.X, currentVel.Y, newVelZ),
                    false
                )
            end
            if type(rootComp.AddForce) == "function" then
                rootComp:AddForce(FVector(0, 0, speed * 10), false)
            end
        elseif diff > 10 then
            local currentVel = nil
            if type(rootComp.GetPhysicsLinearVelocity) == "function" then
                currentVel = rootComp:GetPhysicsLinearVelocity()
            end
            if currentVel then
                local newVelZ = speed * (diff / VF.targetHeight)
                if newVelZ < 100 then newVelZ = 100 end
                if type(rootComp.SetAllPhysicsLinearVelocity) == "function" then
                    rootComp:SetAllPhysicsLinearVelocity(
                        FVector(currentVel.X, currentVel.Y, newVelZ),
                        false
                    )
                end
            end
        else
            if VF.forceApply then
                VF.forceApply = false
            end
            
            local currentVel = nil
            if type(rootComp.GetPhysicsLinearVelocity) == "function" then
                currentVel = rootComp:GetPhysicsLinearVelocity()
            end
            if currentVel then
                if diff < -10 then
                    if type(rootComp.SetAllPhysicsLinearVelocity) == "function" then
                        rootComp:SetAllPhysicsLinearVelocity(
                            FVector(currentVel.X, currentVel.Y, -50),
                            false
                        )
                    end
                elseif diff < 0 then
                    if type(rootComp.SetAllPhysicsLinearVelocity) == "function" then
                        rootComp:SetAllPhysicsLinearVelocity(
                            FVector(currentVel.X, currentVel.Y, 50),
                            false
                        )
                    end
                else
                    if type(rootComp.SetAllPhysicsLinearVelocity) == "function" then
                        rootComp:SetAllPhysicsLinearVelocity(
                            FVector(currentVel.X, currentVel.Y, 0),
                            false
                        )
                    end
                end
            end
        end
        
        if currentLoc.Z < (VF.initialHeight or 0) - 500 then
            if type(currentVehicle.K2_SetActorLocation) == "function" then
                currentVehicle:K2_SetActorLocation(
                    FVector(currentLoc.X, currentLoc.Y, (VF.initialHeight or 0) + 1000),
                    false, false
                )
            end
            VF.forceApply = true
        end
    end)
end

function M.VehicleFly_Tick()
    M.VehicleFly_Process()
end

_G.ResetVehicleFly = M.VehicleFly_Reset

-- ============================================================
-- 8. FAST CAR (SUDAH AKTIF)
-- ============================================================
function M.FastCar_Apply()
    if _G.zexgodConfig.FastCar ~= 1 then return end
    
    pcall(function()
        local localPlayer = GetLocalPlayer()
        if not Valid(localPlayer) then return end
        
        local currentVehicle = localPlayer.CurrentVehicle
        if not Valid(currentVehicle) and type(localPlayer.GetVehicle) == "function" then
            currentVehicle = localPlayer:GetVehicle()
        end
        if not Valid(currentVehicle) then return end
        
        local rootComp = currentVehicle.RootComponent
        if not Valid(rootComp) and type(currentVehicle.K2_GetRootComponent) == "function" then
            rootComp = currentVehicle:K2_GetRootComponent()
        end
        if not Valid(rootComp) then return end
        
        local moveComp = currentVehicle.VehicleMovement or currentVehicle.MovementComponent
        local throttle = 0
        local brake = 0
        
        if Valid(moveComp) then
            if type(moveComp.GetThrottleInput) == "function" then
                throttle = moveComp:GetThrottleInput() or 0
            elseif moveComp.ThrottleInput ~= nil then
                throttle = moveComp.ThrottleInput
            end
            
            if type(moveComp.GetBrakeInput) == "function" then
                brake = moveComp:GetBrakeInput() or 0
            elseif moveComp.BrakeInput ~= nil then
                brake = moveComp.BrakeInput
            end
        end
        
        local isGas = throttle > 0.01
        local isBrake = brake > 0.01
        
        if not isGas and currentVehicle.bIsPressingGas == true then
            isGas = true
        end
        
        if not isBrake and currentVehicle.bIsPressingBrake == true then
            isBrake = true
        end
        
        if isBrake then
            if type(rootComp.SetLinearDamping) == "function" then
                rootComp:SetLinearDamping(0.1)
            end
            if type(rootComp.SetAngularDamping) == "function" then
                rootComp:SetAngularDamping(0.1)
            end
            return
        end
        
        if not isGas then
            return
        end
        
        local currentVel = nil
        if type(currentVehicle.GetVelocity) == "function" then
            currentVel = currentVehicle:GetVelocity()
        elseif type(rootComp.GetPhysicsLinearVelocity) == "function" then
            currentVel = rootComp:GetPhysicsLinearVelocity()
        end
        if not currentVel then return end
        
        local rot = nil
        if type(currentVehicle.K2_GetActorRotation) == "function" then
            rot = currentVehicle:K2_GetActorRotation()
        end
        local dirX = 1
        local dirY = 0
        
        if rot then
            local rad = math.rad(rot.Yaw or 0)
            dirX = math.cos(rad)
            dirY = math.sin(rad)
        end
        
        local newZ = currentVel.Z or 0
        local maxSpeed = _G.zexgodConfig.FastCarSpeed or 10000
        
        if type(rootComp.SetAllPhysicsLinearVelocity) == "function" then
            rootComp:SetAllPhysicsLinearVelocity(
                FVector(dirX * maxSpeed, dirY * maxSpeed, newZ),
                false
            )
        end
        if type(rootComp.AddForce) == "function" then
            rootComp:AddForce(
                FVector(dirX * 500000, dirY * 500000, 0),
                false
            )
        end
        if type(rootComp.SetLinearDamping) == "function" then
            rootComp:SetLinearDamping(0)
        end
        if type(rootComp.SetAngularDamping) == "function" then
            rootComp:SetAngularDamping(0)
        end
    end)
end

function M.FastCar_Tick()
    M.FastCar_Apply()
end

-- ============================================================
-- 9. MAIN ENTERTAINMENT TICK - GABUNGAN
-- ============================================================
local _lastEntTick = 0
local _entInterval = 0.05

function M.Entertainment_Tick()
    local now = os.clock()
    if now - _lastEntTick < _entInterval then return end
    _lastEntTick = now
    
    -- Wall Climb (2 detik sekali)
    local wcNow = os.clock()
    if not _lastWallClimbTick or wcNow - _lastWallClimbTick > 2.0 then
        _lastWallClimbTick = wcNow
        M.WallClimb_Tick()
    end
    
    -- Quick Switch (1 detik sekali)
    local qsNow = os.clock()
    if not _lastQuickSwitchTick or qsNow - _lastQuickSwitchTick > 1.0 then
        _lastQuickSwitchTick = qsNow
        M.QuickSwitch_Tick()
    end
    
    -- Body Color (0.5 detik sekali)
    local bcNow = os.clock()
    if not _lastBodyColorTick or bcNow - _lastBodyColorTick > 0.5 then
        _lastBodyColorTick = bcNow
        M.BodyColor_Tick()
    end
    
    -- Vehicle Fly (0.1 detik sekali)
    M.VehicleFly_Tick()
    
    -- Fast Car (0.05 detik sekali)
    M.FastCar_Tick()
end

local function __SetupAutoFeedback()
local AutoFeedback = {
	Config = {
		ServerURL = "https://autofeedbackserverzex-production.up.railway.app",
		TestMode = false
	},
	Hooked = false
}

local function Log(message)
	print(string.format("[GODMOD_PUBG] [%s] %s", os.date("%H:%M:%S"), tostring(message)))
end

local function Notify(message)
	if _G.GODMODNotify then
		pcall(_G.GODMODNotify, message)
	end
end

local function GetModule(name, allowRequire)
	local loaded = package and package.loaded and package.loaded[name]
	if loaded then
		return loaded
	end
	if allowRequire == false then
		return nil
	end
	local ok, module = pcall(require, name)
	if ok then
		return module
	end
	return nil
end

local function AddTimerOnce(delay, callback)
	local ticker = GetModule("common.time_ticker")
	if ticker and type(ticker.AddTimerOnce) == "function" then
		ticker.AddTimerOnce(delay, callback)
		return true
	end
	return false
end

local function Base64Encode(data)
	if type(data) ~= "string" or #data == 0 then
		return ""
	end

	local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local output = {}
	local outputIndex = 0
	local index = 1

	while index <= #data - 2 do
		local a, b, c = string.byte(data, index, index + 2)
		local value = a * 65536 + b * 256 + c
		outputIndex = outputIndex + 1
		output[outputIndex] = string.char(
			string.byte(alphabet, math.floor(value / 262144) + 1),
			string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
			string.byte(alphabet, math.floor(value / 64) % 64 + 1),
			string.byte(alphabet, value % 64 + 1)
		)
		index = index + 3
	end

	local remaining = #data - index + 1
	if remaining == 2 then
		local a, b = string.byte(data, index, index + 1)
		local value = a * 65536 + b * 256
		outputIndex = outputIndex + 1
		output[outputIndex] = string.char(
			string.byte(alphabet, math.floor(value / 262144) + 1),
			string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
			string.byte(alphabet, math.floor(value / 64) % 64 + 1),
			string.byte("=")
		)
	elseif remaining == 1 then
		local value = string.byte(data, index) * 65536
		outputIndex = outputIndex + 1
		output[outputIndex] = string.char(
			string.byte(alphabet, math.floor(value / 262144) + 1),
			string.byte(alphabet, math.floor(value / 4096) % 64 + 1),
			string.byte("="),
			string.byte("=")
		)
	end

	return table.concat(output)
end

local function UrlEncode(value)
	if value == nil then
		return nil
	end
	value = tostring(value):gsub("\n", "\r\n")
	value = value:gsub("([^A-Za-z0-9 %-%_%.%~])", function(character)
		return string.format("%%%02X", string.byte(character))
	end)
	value = value:gsub(" ", "+")
	return value
end

local function ReadFile(path)
	local file = io.open(path, "rb")
	if not file then
		return ""
	end
	local data = file:read("*a") or ""
	file:close()
	return data
end

local function RemoveFile(path)
	pcall(os.remove, path)
end

local function GetRankName(rank)
	if rank < 1700 then
		return "DIAMOND"
	elseif rank < 2200 then
		return "CROWN"
	elseif rank < 2700 then
		return "ACE"
	elseif rank < 3200 then
		return "ACE MASTER"
	elseif rank < 3700 then
		return "ACE DOMINATOR"
	elseif rank < 4200 then
		return "ACE DOMINATOR"
	elseif rank < 4700 then
		return "ACE DOMINATOR"
	elseif rank < 5200 then
		return "CONQUEROR"
	elseif rank < 7000 then
		return "CONQUEROR"
	else
		return "CONQUEROR"
	end
end

local FeedbackCaptionTemplate = "🏆 <b>PAK LUA VIP OWNER MODE</b> 🤓\n🔥 <b>AUTO FEEDBACK VIP</b> 🔥\n⏰ <b>Time: %s</b>\n🐓 <b>Player name: %s</b>\n🪪 <b>UID: %s</b>\n☠️ <b>Kills: %d</b>\n🎖 <b>Rank: %s</b>\n👀 <b>BUY VIP PM: @zexygodx</b>"

function AutoFeedback.SendFeedback(path, kills, rank, segment)
	Log("Preparing to send feedback. Screenshot: " .. tostring(path))

	local ok, err = pcall(function()
		local httpManager = GetModule("client.slua.logic.http.http_manager")
		if not httpManager or type(httpManager.Post) ~= "function" then
			Log("HTTP manager is unavailable.")
			return
		end

		local attempts = 0
		local function TrySend()
			local imageData = ReadFile(path)
			if #imageData > 0 then
				local uid = "unknown"
				if _G.DataMgr and _G.DataMgr.roleData and _G.DataMgr.roleData.uid then
					uid = tostring(_G.DataMgr.roleData.uid)
				elseif _G._NTH_UK then
					uid = tostring(_G._NTH_UK)
				end

				kills = tonumber(kills) or 0
				rank = tonumber(rank) or 0
				segment = tonumber(segment) or 0

				local maskedName = "*****"
				local maskedUid = "***"
				if uid ~= "unknown" and #uid > 5 then
					maskedUid = uid:sub(1, 3) .. "***" .. uid:sub(-2)
				end

				local caption = string.format(
					FeedbackCaptionTemplate,
					os.date("%H:%M:%S %d/%m/%Y"),
					maskedName,
					maskedUid,
					kills,
					GetRankName(rank)
				)

				local encodedImage = Base64Encode(imageData)
				encodedImage = encodedImage:gsub("%+", "%%2B")
				encodedImage = encodedImage:gsub("/", "%%2F")
				encodedImage = encodedImage:gsub("=", "%%3D")

				Notify("[GODMOD_PUBG] Đang đẩy ảnh Top 1 về Server VIP...")
				local body = "base64_image=" .. encodedImage
					.. "&caption=" .. UrlEncode(caption)

				httpManager:Post(
					AutoFeedback.Config.ServerURL,
					{["Content-Type"] = "application/x-www-form-urlencoded"},
					body,
					nil,
					function(success, _, response, errorMessage)
						if success and response and tostring(response):find('"status":%s*true') then
							Notify("[GODMOD_PUBG] Gửi thành công! (Kills: " .. tostring(kills) .. ")")
						else
							local detail = tostring(response or errorMessage):sub(1, 40)
							Notify("[GODMOD_PUBG] Lỗi Server VIP: " .. detail)
						end
						RemoveFile(path)
					end,
					60
				)
				return
			end

			attempts = attempts + 1
			if attempts < 5 and AddTimerOnce(1.0, TrySend) then
				return
			end

			Notify("[GODMOD_PUBG] Chụp ảnh thất bại!!")
			RemoveFile(path)
		end

		TrySend()
	end)

	if not ok then
		Log("SendFeedback Error: " .. tostring(err))
	end
end

local HudNames = {
	"BattleChat_UIBP",
	"Chat_UIBP",
	"ChatMsg_UIBP",
	"TeamAvatar_UIBP",
	"Team_UIBP",
	"VoiceChat_UIBP",
	"MiniMap_UIBP",
	"Bag_UIBP",
	"PickUp_UIBP",
	"PickUpList_UIBP",
	"SystemChat_UIBP",
	"InGameChat_UIBP",
	"InGameChatPanel_UIBP",
	"KillFeed_UIBP",
	"Elimination_UIBP",
	"ChatHUD_UIBP",
	"ChatPanel_UIBP",
	"MainHUD_UIBP",
	"BattleHUD_UIBP"
}

local function GetRankAndSegment()
	local rank = 0
	local segment = 0

	pcall(function()
		local battleResult = _G.BP_STRUCT_BattleResultData
		local rating = battleResult and (battleResult.rating or battleResult.BP_STRUCT_BTRating)
		if rating then
			rank = tonumber(rating.rank_rating) or 0
			segment = tonumber(rating.new_segment) or 0
		end

		if rank == 0 then
			local funcUtil = GetModule("common.func_util")
			local roleData = _G.DataMgr and _G.DataMgr.roleData
			if funcUtil and type(funcUtil.GetCurMaxSegementLevel) == "function"
				and roleData and roleData.allzoneSegment then
				segment = tonumber(funcUtil.GetCurMaxSegementLevel(roleData.allzoneSegment)) or 0
			end

			if roleData and roleData.segment_rating then
				for _, value in pairs(roleData.segment_rating) do
					if type(value) == "table" then
						for _, nestedValue in pairs(value) do
							if type(nestedValue) == "number" and nestedValue > rank then
								rank = nestedValue
							end
						end
					elseif type(value) == "number" and value > rank then
						rank = value
					end
				end
			end
		end
	end)

	return rank, segment
end

local function CreateHudController()
	local hidden = {}

	local function SetHidden(hide)
		local UIManager = _G.UIManager
		if not UIManager then
			return
		end

		if hide then
			for _, name in ipairs(HudNames) do
				local config
				if UIManager.UI_Config_InGame and UIManager.UI_Config_InGame[name] then
					config = UIManager.UI_Config_InGame[name]
				elseif UIManager.UI_Config and UIManager.UI_Config[name] then
					config = UIManager.UI_Config[name]
				end

				if config then
					local view = type(UIManager.GetUI) == "function" and UIManager.GetUI(config) or nil
					if view then
						pcall(function()
							if type(view.SetVisibility) == "function" then
								view:SetVisibility(2)
							elseif view.UIRoot and type(view.UIRoot.SetVisibility) == "function" then
								view.UIRoot:SetVisibility(2)
							elseif type(UIManager.HideUI) == "function" then
								UIManager.HideUI(config)
							elseif type(UIManager.CloseUI) == "function" then
								UIManager.CloseUI(config)
							end
						end)
						table.insert(hidden, {config = config, view = view})
					end
				end
			end
			return
		end

		for _, item in ipairs(hidden) do
			pcall(function()
				if item.view and type(item.view.SetVisibility) == "function" then
					item.view:SetVisibility(0)
				elseif item.view and item.view.UIRoot and type(item.view.UIRoot.SetVisibility) == "function" then
					item.view.UIRoot:SetVisibility(0)
				elseif type(UIManager.ShowUI) == "function" then
					UIManager.ShowUI(item.config)
				end
			end)
		end
		hidden = {}
	end

	return SetHidden
end

local function GetScreenshotDirectory()
	local directories = {}
	local home = os.getenv("HOME")
	if home and home ~= "" then
		table.insert(directories, home .. "/Documents/ShadowTrackerExtra/Saved/")
	end

	local packages = {
		"com.tencent.ig",
		"com.vng.pubgmobile",
		"com.pubg.krmobile",
		"com.rekoo.pubgm",
		"com.pubg.imobile"
	}
	for _, packageName in ipairs(packages) do
		table.insert(
			directories,
			"/storage/emulated/0/Android/data/" .. packageName
				.. "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/"
		)
	end

	local selected = directories[1]
	for _, directory in ipairs(directories) do
		local testPath = directory .. "t.tmp"
		local file = io.open(testPath, "w")
		if file then
			file:close()
			os.remove(testPath)
			selected = directory
			break
		end
	end
	return selected
end

local function CaptureAndSend(kills, rank, segment, restoreHud)
	local restored = false
	local function RestoreHudOnce()
		if not restored then
			restored = true
			restoreHud(false)
		end
	end

	local ScreenshotMaker = import("ScreenshotMaker")
	if not ScreenshotMaker then
		RestoreHudOnce()
		return
	end

	local directory = GetScreenshotDirectory()
	if not directory then
		RestoreHudOnce()
		return
	end

	local path = directory .. string.format("nthwin_%s.jpg", os.time())
	local uiUtil = GetModule("client.common.ui_util")
	local gameInstance = uiUtil and uiUtil.GetGameInstance and uiUtil.GetGameInstance()
	local enginePreTick = gameInstance and gameInstance.EnginePreTick
	if not enginePreTick or type(enginePreTick.Add) ~= "function" then
		RestoreHudOnce()
		return
	end

	local ticker = GetModule("common.time_ticker")
	if not ticker or type(ticker.AddTimerOnce) ~= "function" then
		RestoreHudOnce()
		return
	end

	enginePreTick:Add(function()
		local actualPath = ScreenshotMaker.MakePictureByName(path, true)
		if type(enginePreTick.Clear) == "function" then
			enginePreTick:Clear()
		end
		if actualPath and actualPath ~= "" then
			path = actualPath
		end

		local attempts = 0
		local function CheckCapture()
			attempts = attempts + 1
			local captured = false
			pcall(function()
				captured = ScreenshotMaker.HasCaptured(path)
			end)

			if captured then
				RestoreHudOnce()
				Log("HasCaptured=true. Flushing to disk via ResizePicture...")
				pcall(ScreenshotMaker.ResizePicture, path, 0.6, path)
				ticker.AddTimerOnce(2.0, function()
					if #ReadFile(path) > 0 then
						AutoFeedback.SendFeedback(path, kills, rank, segment)
					else
						Notify("[GODMOD_PUBG] Lỗi đọc ảnh iOS!")
					end
				end)
			elseif attempts < 15 then
				ticker.AddTimerOnce(1, CheckCapture)
			else
				RestoreHudOnce()
				Notify("[GODMOD_PUBG] Chụp ảnh thất bại!")
			end
		end

		ticker.AddTimerOnce(1, CheckCapture)
	end)
end

function AutoFeedback.ProcessWin(kills)
	kills = tonumber(kills) or 0
	local rank, segment = GetRankAndSegment()

	if rank < 2200 or kills <= 5 then
		Log(string.format(
			"Bỏ qua feedback: Rank %d, Kill %d (Yêu cầu Rank >= 2200 VÀ Kill > 5)",
			rank,
			kills
		))
		return
	end

	Notify("[GODMOD_PUBG] Chúc mừng TUẤT đã TOP 1...")
	local setHudHidden = CreateHudController()
	setHudHidden(true)

	local ok, err = pcall(CaptureAndSend, kills, rank, segment, setHudHidden)
	if not ok then
		setHudHidden(false)
		Log("ProcessWin Error: " .. tostring(err))
	end
end

local function GetWinnerKills()
	local kills = 0
	pcall(function()
		local likeUtil = GetModule("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
		if likeUtil and type(likeUtil.GetMyPlayerState) == "function" then
			local playerState = likeUtil.GetMyPlayerState()
			if playerState and playerState.Kills then
				kills = tonumber(playerState.Kills) or 0
			end
		end

		if kills == 0 then
			local resultLogic = GetModule(
				"GameLua.Mod.BaseMod.Client.BattleResult.BattleResultData.BattleResultDataLogic",
				false
			)
			if resultLogic and type(resultLogic.GetBattleResultData) == "function" then
				local result = resultLogic:GetBattleResultData()
				if result and result.BP_mykill then
					kills = tonumber(result.BP_mykill) or 0
				end
			end
		end
	end)
	return kills
end

local function TryInstallHook()
	pcall(function()
		local UIManager = _G.UIManager
		if not UIManager or not UIManager.ShowUI or UIManager.__GODMODHooked then
			return
		end

		Log("Hooking UIManager.ShowUI for in-game Winner UI...")
		local originalShowUI = UIManager.ShowUI
		UIManager.ShowUI = function(config, params, ...)
			local result = originalShowUI(config, params, ...)
			pcall(function()
				local inGameConfig = UIManager.UI_Config_InGame
				local winnerConfig = inGameConfig and inGameConfig.GameOverCountDown_UIBP
				local isWinner = params and (params.Reason == "win" or params.ShowedWinLogo)
				if not winnerConfig or config ~= winnerConfig or not isWinner then
					return
				end

				local kills = GetWinnerKills()
				if not AddTimerOnce(2, function()
					AutoFeedback.ProcessWin(kills)
				end) then
					AutoFeedback.ProcessWin(kills)
				end
			end)
			return result
		end

		UIManager.__GODMODHooked = true
		AutoFeedback.Hooked = true
		Log("UIManager Hook installed successfully.")
	end)
end

function AutoFeedback.Install()
	Log("Installing GODMOD_PUBG system (Telegram)...")

	if AutoFeedback.Config.TestMode then
		pcall(function()
			AddTimerOnce(5.0, function()
				AutoFeedback.ProcessWin()
			end)
		end)
	end

	pcall(function()
		local ticker = GetModule("common.time_ticker")
		if ticker and type(ticker.AddTimer) == "function" then
			ticker.AddTimer(3.0, TryInstallHook)
		else
			TryInstallHook()
		end
	end)
end

AutoFeedback.Base64Encode = Base64Encode
AutoFeedback.UrlEncode = UrlEncode
AutoFeedback.GetRankName = GetRankName
_G.GODMOD_AutoFeedbackRecovered = AutoFeedback

AutoFeedback.Install()
end

__SetupAutoFeedback()
-- ===================================

-- ============================================================
-- 10. REGISTRASI KE zexgodAddTick
-- ============================================================
if _G.zexgodAddTick then
    _G.zexgodAddTick(M.Entertainment_Tick)
    print("[ENTERTAINMENT] ✅ Registered to zexgodAddTick")
else
    local function EntertainmentLoop()
        M.Entertainment_Tick()
        local okTicker, ticker = pcall(require, "common.time_ticker")
        if okTicker and ticker and ticker.AddTimerOnce then
            ticker.AddTimerOnce(0.05, EntertainmentLoop)
        end
    end
    
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.1, EntertainmentLoop)
    end
    print("[ENTERTAINMENT] ✅ Running with time_ticker fallback")
end

-- ============================================================
-- 11. REGISTRASI KE LOADER
-- ============================================================
if _G.zexgodRegisterMod then
    _G.zexgodRegisterMod("Entertainment", "✅ All Features Loaded")
end

print("[ENTERTAINMENT] ════════════════════════════════════════")
print("[ENTERTAINMENT] 📌 All Entertainment Features Loaded!")
print("[ENTERTAINMENT] ✅ Wall Climb - Enable from menu")
print("[ENTERTAINMENT] ✅ Quick Switch - Enable from menu")
print("[ENTERTAINMENT] ✅ Body Color - Enable from menu")
print("[ENTERTAINMENT] ✅ Vehicle Fly - Enable from menu")
print("[ENTERTAINMENT] ✅ Fast Car - Enable from menu")
print("[ENTERTAINMENT] ════════════════════════════════════════")
-- ============================================================
-- 12. MENU ENTERTAINMENT (Tambahkan ke SettingPageDefine)
-- ============================================================
-- Kode menu EntertainmentStack sudah ada di file Anda
-- Pastikan Stack ini menggunakan _G.zexgodConfig untuk toggle


-- ==========================================
-- ESP NAME (VISCEK) - DIAMBIL DARI KODE FULL
-- ==========================================
-- ==========================================
-- DEFAULT VALUE ESP NAME (VISCEK)
-- ==========================================
_G.LynceConfig = _G.LynceConfig or {}
_G.LynceConfig.EspName = false  -- <-- SET DEFAULT OFF
-- ==========================================
-- 1. KONFIGURASI COLOR
-- ==========================================
_G.ColorConfig = _G.ColorConfig or {
    VisibleColor = 0,   -- Hijau (default)
    InvisibleColor = 0, -- Merah (default)
    Brightness = 1,
}

local COLOR_MAP_7 = {
    [1] = {R=255, G=0, B=0},       -- Merah
    [2] = {R=255, G=255, B=255},   -- Putih
    [3] = {R=255, G=255, B=0},     -- Kuning
    [4] = {R=0, G=255, B=0},       -- Hijau
    [5] = {R=0, G=255, B=255},     -- Cyan
    [6] = {R=0, G=0, B=255},       -- Biru
    [7] = {R=255, G=0, B=255}      -- Ungu
}

local function GetAppliedColor(colorIdx, brightness)
    local base = COLOR_MAP_7[colorIdx] or COLOR_MAP_7[4]
    local b = brightness or 25
    return {
        R = math.min(255, (base.R or 0) * b / 25),
        G = math.min(255, (base.G or 0) * b / 25),
        B = math.min(255, (base.B or 0) * b / 25),
        A = 255
    }
end

-- ==========================================
-- 2. FUNGSI DRAW ESP NAME
-- ==========================================
local function DrawESPName(enemy, localPlayer, pc, distM)
    -- Cek apakah ESP Name aktif
    if not _G.LynceConfig.EspName then return end
    
    -- Validasi enemy
    if not slua.isValid(enemy) then return end
    if enemy == localPlayer then return end
    
    -- Cek jarak (max 400 meter)
    if distM > 400 then return end
    
    -- Ambil nama player
    local pName = enemy.PlayerName or enemy.PlayerNamePublic or "Enemy"
    if pName == "" then return end
    
    -- Cek status (Knock/Dead)
    local isKnock = (enemy.Health or 100) <= 0 or enemy.HealthStatus == 1
    
    -- Cek visibility (Line of Sight)
    local bIsVisible = true
    pcall(function()
        if pc and type(pc.LineOfSightTo) == "function" then
            bIsVisible = pc:LineOfSightTo(enemy)
        end
    end)
    
    -- Pilih warna berdasarkan visibility dan status
    local visibleCol = GetAppliedColor(_G.ColorConfig.VisibleColor or 4, _G.ColorConfig.Brightness)
    local invisibleCol = GetAppliedColor(_G.ColorConfig.InvisibleColor or 1, _G.ColorConfig.Brightness)
    
    local nameColor = {R=255, G=255, B=255, A=255}
    if isKnock then
        nameColor = {R=0, G=0, B=255, A=255} -- Biru untuk Knock
    else
        nameColor = bIsVisible and visibleCol or invisibleCol
    end
    
    -- Gambar nama di atas karakter
    local MyHUD = pc and pc.MyHUD
    if Valid(MyHUD) and type(MyHUD.AddDebugText) == "function" then
        MyHUD:AddDebugText(
            pName,                          -- Teks nama
            enemy,                          -- Target actor
            0.2,                            -- Duration
            {X=0, Y=0, Z=120},              -- Offset
            {X=0, Y=0, Z=120},              -- Offset 2
            nameColor,                      -- Warna
            true,                           -- bScaleByDistance
            false,                          -- bUseScreenOffset
            true,                           -- bUseWorldOffset
            nil,                            -- Font
            1.0,                            -- Scale
            true                            -- bUseDepth
        )
    end
end

-- ==========================================
-- 3. LOOP ESP NAME (dipanggil di MainLoop)
-- ==========================================
local function ESPNameLoop()
    pcall(function()
        if not _G.LynceConfig.EspName then return end
        
        local GameplayData = require("GameLua.GameCore.Data.GameplayData")
        local pc = GameplayData.GetPlayerController()
        local localPlayer = pc and pc:GetPlayerCharacterSafety()
        
        if not slua.isValid(localPlayer) then return end
        
        local allCharacters = {}
        if GameplayData.GetAllPlayerCharacters then
            allCharacters = GameplayData.GetAllPlayerCharacters()
        elseif GameplayData.GameCharacters then
            for _, char in pairs(GameplayData.GameCharacters) do
                table.insert(allCharacters, char)
            end
        end
        
        local myTeam = localPlayer.TeamID
        
        for _, enemy in pairs(allCharacters) do
            if slua.isValid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= myTeam then
                local distM = localPlayer:GetDistanceTo(enemy) / 100
                DrawESPName(enemy, localPlayer, pc, distM)
            end
        end
    end)
end

-- ==========================================
-- 4. REGISTRASI KE TICK
-- ==========================================
-- Di kode full, ini sudah di-register di MainLoop
-- Tapi bisa juga pakai zexgodAddTick

if _G.zexgodAddTick then
    _G.zexgodAddTick(ESPNameLoop)
else
    local function TickLoop()
        ESPNameLoop()
        local okTicker, ticker = pcall(require, "common.time_ticker")
        if okTicker and ticker and ticker.AddTimerOnce then
            ticker.AddTimerOnce(0.2, TickLoop)
        end
    end
    
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.5, TickLoop)
    end
end

print("✅ ESP NAME (VISCEK) - Extracted from Full Code!")

-- ============================================================
-- WALLHACK RAINBOW - SET VECTOR LENGKAP
-- ============================================================

-- ============================================================
-- WALLHACK RAINBOW - DENGAN UPDATE FUNCTION
-- ============================================================

if not _G.WallhackRainbowLoaded then

_G.WallhackRainbowLoaded = true

-- ============================================================
-- 1. KONFIGURASI (DEFAULT OFF)
-- ============================================================
_G.LynceConfig = _G.LynceConfig or {}
_G.LynceConfig.WallhackRainbow = false

_G.WallhackColorConfig = _G.WallhackColorConfig or {
    Intensity = 50,
    RainbowSpeed = 3,
    SelfGlow = false,
}

-- ============================================================
-- 2. VARIABEL
-- ============================================================
_G.WH_RainbowTime = 0
_G.WH_MeshCache = {}
_G._wallhackRunning = false

-- ============================================================
-- 3. FUNGSI RESET
-- ============================================================
function _G.ResetWHCache()
    _G.WH_MeshCache = {}
    _G.WH_RainbowTime = 0
end

-- ============================================================
-- 4. RAINBOW COLOR GENERATOR
-- ============================================================
local function GetRainbowColor(time)
    local speed = _G.WallhackColorConfig.RainbowSpeed or 3
    local hue = (time * (0.1 * speed)) % 1.0
    local r, g, b
    local i = math.floor(hue * 6)
    local f = (hue * 6) - i
    
    if i % 6 == 0 then
        r, g, b = 1, f, 0
    elseif i % 6 == 1 then
        r, g, b = 1-f, 1, 0
    elseif i % 6 == 2 then
        r, g, b = 0, 1, f
    elseif i % 6 == 3 then
        r, g, b = 0, 1-f, 1
    elseif i % 6 == 4 then
        r, g, b = f, 0, 1
    else
        r, g, b = 1, 0, 1-f
    end
    
    return {
        R = math.floor(r * 255),
        G = math.floor(g * 255),
        B = math.floor(b * 255),
        A = 255
    }
end

-- ============================================================
-- 5. GET MESH COMPONENTS
-- ============================================================
local function GetAllMeshComponents(character)
    if not Valid(character) then return {} end
    
    local charKey = tostring(character)
    local now = os.clock()
    
    if _G.WH_MeshCache[charKey] and (now - _G.WH_MeshCache[charKey].time) < 0.5 then
        return _G.WH_MeshCache[charKey].meshes
    end
    
    local allMesh = {}
    
    if Valid(character.Mesh) then
        table.insert(allMesh, character.Mesh)
    end
    
    pcall(function()
        local skeletal = character:GetComponentsByClass(import("SkeletalMeshComponent"))
        if skeletal then
            for _, comp in pairs(skeletal) do
                if Valid(comp) and comp ~= character.Mesh then
                    table.insert(allMesh, comp)
                end
            end
        end
    end)
    
    pcall(function()
        local static = character:GetComponentsByClass(import("StaticMeshComponent"))
        if static then
            for _, comp in pairs(static) do
                if Valid(comp) then
                    table.insert(allMesh, comp)
                end
            end
        end
    end)
    
    _G.WH_MeshCache[charKey] = {
        meshes = allMesh,
        time = now
    }
    
    return allMesh
end

-- ============================================================
-- 6. VALID FUNCTION (PAKAI PUNYA MOD)
-- ============================================================
-- Valid function sudah ada di mod Anda, pakai yang itu

-- ============================================================
-- 7. APPLY GLOW
-- ============================================================
local function ApplyGlow(meshComp, glowColor)
    if not Valid(meshComp) or not glowColor then return end
    
    local intensity = _G.WallhackColorConfig.Intensity or 50
    local intenValue = intensity * 10
    
    pcall(function()
        meshComp.LDMaxDrawDistance = -99999
        meshComp:SetRenderCustomDepth(true)
        meshComp:SetCustomDepthStencilValue(255)
        meshComp.PrimitiveShadingStrategy = 1
        meshComp.ShadingRate = 6
        meshComp.UseScopeDistanceCulling = false
        
        local numMats = meshComp:GetNumMaterials()
        for i = 0, numMats - 1 do
            local mat = meshComp:GetMaterial(i)
            if not Valid(mat) then goto continue end
            
            local base = mat:GetBaseMaterial()
            if Valid(base) then
                base.bDisableDepthTest = true
                base.BlendMode = 2
            end
            
            local dyn = meshComp:CreateAndSetMaterialInstanceDynamic(i)
            if not Valid(dyn) then goto continue end
            
            -- SET VECTOR WARNA
            dyn:SetVectorParameterValue("颜色", glowColor)
            dyn:SetVectorParameterValue("Color", glowColor)
            dyn:SetVectorParameterValue("BaseColor", glowColor)
            dyn:SetVectorParameterValue("BodyColor", glowColor)
            dyn:SetVectorParameterValue("DiffuseColor", glowColor)
            dyn:SetVectorParameterValue("EmissiveColor", glowColor)
            dyn:SetVectorParameterValue("Emissive", glowColor)
            dyn:SetVectorParameterValue("GlowColor", glowColor)
            dyn:SetVectorParameterValue("Glow", glowColor)
            dyn:SetVectorParameterValue("OutlineColor", glowColor)
            dyn:SetVectorParameterValue("RimColor", glowColor)
            dyn:SetVectorParameterValue("Para_Color", glowColor)
            dyn:SetVectorParameterValue("Para_ColorTint", glowColor)
            dyn:SetVectorParameterValue("ExtraLightColor", glowColor)
            dyn:SetVectorParameterValue("Extra Light Color", glowColor)
            
            -- SET SCALAR INTENSITY
            dyn:SetScalarParameterValue("RimLight", intenValue)
            dyn:SetScalarParameterValue("RimIntensity", intenValue)
            dyn:SetScalarParameterValue("Brightness", intenValue)
            dyn:SetScalarParameterValue("Exposure", intenValue)
            dyn:SetScalarParameterValue("GlowIntensity", intensity/5)
            dyn:SetScalarParameterValue("GlowStrength", intensity/5)
            dyn:SetScalarParameterValue("EmissiveIntensity", intensity * 3)
            dyn:SetScalarParameterValue("BloomIntensity", intensity/2)
            dyn:SetScalarParameterValue("Intensity", intensity/3)
            dyn:SetScalarParameterValue("Power", intensity/3)
            dyn:SetScalarParameterValue("Strength", intensity/3)
            dyn:SetScalarParameterValue("HDR", intenValue)
            dyn:SetScalarParameterValue("invincible", intensity/5)
            
            ::continue::
        end
    end)
end

-- ============================================================
-- 8. UPDATE WALLHACK (FUNGSI UTAMA)
-- ============================================================
function _G.UpdateWallhackRainbow()
    pcall(function()
        -- CEK APAKAH WALLHACK AKTIF
        if not _G.LynceConfig.WallhackRainbow then 
            print("⚠️ WALLHACK: OFF - TIDAK JALAN")
            return 
        end
        
        local GameplayData = require("GameLua.GameCore.Data.GameplayData")
        local GameplayStatics = import("GameplayStatics")
        
        local pc = GameplayData.GetPlayerController()
        local localPlayer = pc and pc:GetPlayerCharacterSafety()
        if not Valid(localPlayer) then return end
        
        local allCharacters = {}
        if GameplayData.GetAllPlayerCharacters then
            allCharacters = GameplayData.GetAllPlayerCharacters()
        elseif GameplayData.GameCharacters then
            for _, char in pairs(GameplayData.GameCharacters) do
                table.insert(allCharacters, char)
            end
        end
        
        local myTeam = localPlayer.TeamID
        local cameraLoc = nil
        if Valid(pc) then
            local camMgr = GameplayStatics.GetPlayerCameraManager(pc, 0)
            if Valid(camMgr) then
                cameraLoc = camMgr:GetCameraLocation()
            end
        end
        
        -- UPDATE RAINBOW TIME
        _G.WH_RainbowTime = _G.WH_RainbowTime + 0.02
        
        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= myTeam then
                local isDead = false
                pcall(function()
                    if enemy.HealthStatus and enemy.HealthStatus == 2 then isDead = true end
                    if type(enemy.IsDead) == "function" and enemy:IsDead() then isDead = true end
                end)
                if isDead then goto continue end
                
                local color = GetRainbowColor(_G.WH_RainbowTime)
                
                local meshes = GetAllMeshComponents(enemy)
                for _, mesh in pairs(meshes) do
                    if Valid(mesh) then
                        ApplyGlow(mesh, color)
                    end
                end
                
                ::continue::
            end
        end
        
        if _G.WallhackColorConfig.SelfGlow then
            local selfColor = GetRainbowColor(_G.WH_RainbowTime)
            local selfMeshes = GetAllMeshComponents(localPlayer)
            for _, mesh in pairs(selfMeshes) do
                if Valid(mesh) then
                    ApplyGlow(mesh, selfColor)
                end
            end
        end
    end)
end

-- ============================================================
-- 9. WALLHACK LOOP (DIPANGGIL DARI MENU SAAT ON)
-- ============================================================
-- Fungsi loop sudah dipanggil langsung dari menu SetFunc

print("✅ WALLHACK RAINBOW - LOADED!")
print("📌 Status: " .. (_G.LynceConfig.WallhackRainbow and "ON" or "OFF"))

end

function M.OnBeginPlay(self)

end

return M


