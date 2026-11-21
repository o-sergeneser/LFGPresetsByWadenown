local _,A=...
local hookedTabs={}
local function lastVisibleTab(parent)
    local last,rightmost
    local seen={}
    local function consider(tab)
        local kind=type(tab)
        if (kind~='table' and kind~='userdata') or seen[tab] or tab==A.pveLauncher then return end
        seen[tab]=true
        if not hookedTabs[tab] then
            hookedTabs[tab]=true
            tab:HookScript('OnShow',A.RefreshPVELauncher)
            tab:HookScript('OnHide',A.RefreshPVELauncher)
            tab:HookScript('OnSizeChanged',A.RefreshPVELauncher)
        end
        if not tab:IsShown() then return end
        local right=tab:GetRight()
        right=right and right*tab:GetEffectiveScale() or -math.huge
        if not last or right>=rightmost then last,rightmost=tab,right end
    end
    for _,tab in ipairs(parent.Tabs or {}) do consider(tab) end
    for _,child in ipairs({parent:GetChildren()}) do
        local name=child:GetName()
        if name and name:match('^PVEFrameTab%d+$') then consider(child) end
    end
    return last
end
local function syncFont(tab,source)
    local normal,highlight,disabled=source:GetNormalFontObject(),source:GetHighlightFontObject(),source:GetDisabledFontObject()
    if normal then tab:SetNormalFontObject(normal) end
    if highlight then tab:SetHighlightFontObject(highlight) end
    if disabled then tab:SetDisabledFontObject(disabled) end
    local text=source:GetFontString()
    if text then
        local path,size,flags=text:GetFont()
        if path and size then tab:GetFontString():SetFont(path,size,flags or '') end
    end
    tab:SetWidth(math.ceil(tab:GetFontString():GetStringWidth())+22)
end
function A.RefreshPVELauncher()
    if InCombatLockdown() or not A.pveLauncher then return end
    local tab=A.pveLauncher
    local source=lastVisibleTab(_G.PVEFrame)
    if not source then tab:Hide(); return end
    tab:ClearAllPoints()
    tab:SetPoint('BOTTOMLEFT',source,'BOTTOMRIGHT',3,0)
    syncFont(tab,source)
    tab:Show()
end
function A.InstallPVELauncher()
    if not A.uiReady or InCombatLockdown() then return end
    if A.pveLauncher then A.RefreshPVELauncher(); return end
    local parent=_G.PVEFrame
    if not parent then return end
    local host=CreateFrame('Frame',nil,parent)
    host:SetAllPoints(parent); host:EnableMouse(false)
    local tab=CreateFrame('Button','LFGPresetsByWadenownPVETab',host,'PanelTabButtonTemplate')
    tab:SetText('|TInterface\\AddOns\\LFGPresetsByWadenown\\Media\\Icon.tga:16:16:0:0|t LFG Templates')
    tab:SetSize(136,32)
    A.BlockMouseThrough(tab)
    PanelTemplates_DeselectTab(tab)
    tab:HookScript('OnEnter',A.RefreshPVELauncher)
    tab:SetScript('OnClick',function() A.OpenOptions() end)
    A.pveLauncher=tab
    parent:HookScript('OnShow',A.RefreshPVELauncher)
    parent:HookScript('OnSizeChanged',A.RefreshPVELauncher)
    A.RefreshPVELauncher()
end
