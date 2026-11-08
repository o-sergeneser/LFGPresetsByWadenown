local _,A=...
local function syncFont(tab)
    local source=_G.PVEFrameTab3 or _G.PVEFrameTab1
    if not source then return end
    local normal,highlight,disabled=source:GetNormalFontObject(),source:GetHighlightFontObject(),source:GetDisabledFontObject()
    if normal then tab:SetNormalFontObject(normal) end
    if highlight then tab:SetHighlightFontObject(highlight) end
    if disabled then tab:SetDisabledFontObject(disabled) end
    local text=source:GetFontString()
    if text then
        local path,size,flags=text:GetFont()
        if path and size then tab:GetFontString():SetFont(path,size,flags or '') end
    end
end
function A.InstallPVELauncher()
    if not A.uiReady or InCombatLockdown() or A.pveLauncher then return end
    local parent=_G.PVEFrame
    if not parent then return end
    local host=CreateFrame('Frame',nil,parent)
    host:SetAllPoints(parent); host:EnableMouse(false)
    local tab=CreateFrame('Button','LFGPresetsByWadenownPVETab',host,'PanelTabButtonTemplate')
    tab:SetText('LFG Presets'); tab:SetSize(136,32)
    tab:SetPoint('BOTTOMRIGHT',parent,'BOTTOMRIGHT',-10,-30)
    A.BlockMouseThrough(tab)
    PanelTemplates_DeselectTab(tab)
    syncFont(tab)
    tab:HookScript('OnShow',syncFont)
    tab:HookScript('OnEnter',syncFont)
    tab:SetScript('OnClick',function() A.OpenOptions() end)
    A.pveLauncher=tab
end
