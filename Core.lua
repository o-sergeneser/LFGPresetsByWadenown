local addonName, A = ...
local events=CreateFrame("Frame")
local attached, hooked = {}, {}
local function public(value) return not issecretvalue or not issecretvalue(value) end
function A.Update()
    if not A.uiReady then return end
    if InCombatLockdown() then
        A.editor:Hide(); for _,f in pairs(A.panels) do f:Hide() end
        return
    end
    local kind, anchor
    local dialog=_G.LFGListApplicationDialog
    local entry=_G.LFGListFrame and LFGListFrame.EntryCreation
    if dialog and dialog:IsVisible() then kind,anchor="application",dialog
    elseif entry and entry:IsVisible() then
        local category=entry.selectedCategory
        if public(category) then
            if category==2 then kind="dungeon" elseif category==3 then kind="raid" end
        end
        anchor=_G.PVEFrame or LFGListFrame
    end
    A.contextKind=kind
    if A.nativeKind~=kind then A.previewHidden={}; A.keepOpen={}; A.nativeKind=kind end
    for k,f in pairs(A.panels) do
        local preview=A.preview and A.preview[k]
        local allowed=A.db.settings[k].automatic or (A.keepOpen and A.keepOpen[k])
        local show=preview or (k==kind and allowed and not (A.previewHidden and A.previewHidden[k]))
        if show then
            local target=preview and A.options or anchor
            A.Activate(k); A.RefreshCards()
            if not f.dragging and not (A.editor.dragging and A.editor.kind==k) then
                local position=A.db.settings[k].position
                local linked=A.db.settings[k].attached and k==kind and anchor
                if linked then
                    A.PlaceAttached(f,anchor,k)
                else
                    if preview and not position then
                        local x=({application=.03,dungeon=.36,raid=.69})[k]
                        position={x=x,y=.8}
                    end
                    A.Place(f,target,position)
                end
            end
            A.StackAbove(f,target)
            f:Show()
            if A.editor:IsShown() and A.editor.owner==f then A.StackAbove(A.editor,f) end
            if A.editor:IsShown() and A.editor.owner==f and A.EditorFollows(k) and not f.dragging and not A.editor.dragging then A.Dock(A.editor,f) end
        else f:Hide() end
    end
    if kind then A.Activate(kind) else A.kind=nil end
    A.SyncLocks()
end
local function attach()
    if not A.uiReady then return end
    A.InstallNotePersistence()
    A.InstallPVELauncher()
    local entry=_G.LFGListFrame and LFGListFrame.EntryCreation
    for _, frame in pairs({entry=entry, dialog=_G.LFGListApplicationDialog, parent=_G.PVEFrame}) do
        if not attached[frame] then
            attached[frame]=true
            frame:HookScript("OnShow",function() A.previewHidden={}; A.Update() end)
            frame:HookScript("OnHide",function()
                if A.editor then A.editor:Hide() end
                A.Update()
            end)
        end
    end
    for _, name in ipairs({"LFGListEntryCreation_Select","LFGListEntryCreation_Show","LFGListFrame_SetActivePanel"}) do
        if type(_G[name])=="function" and not hooked[name] then
            hooked[name]=true; hooksecurefunc(name,A.Update)
        end
    end
    A.Update()
end
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("DISPLAY_SIZE_CHANGED")
events:RegisterEvent("UI_SCALE_CHANGED")
events:SetScript("OnEvent",function(_,event,name)
    if event=="ADDON_LOADED" and name==addonName then
        if not A.Initialize() then return end
        A.uiReady=false
        A.BuildUI()
        A.BuildOptions()
        A.uiReady=true
        SLASH_LFGPRESETSBYWADENOWN1="/lfgpresets"
        SLASH_LFGPRESETSBYWADENOWN2="/lfp"
        SlashCmdList.LFGPRESETSBYWADENOWN=function() A.OpenOptions() end
        attach()
    elseif event=="ADDON_LOADED" or event=="PLAYER_LOGIN" then attach()
    else
        if event=='PLAYER_REGEN_ENABLED' then A.InstallNotePersistence(); A.InstallPVELauncher() end
        A.Update()
    end
end)
