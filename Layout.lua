local _,A=...
function A.Activate(kind)
    A.kind=kind; A.panel=A.panels[kind]; A.rows=A.panel.rows
end
function A.RefreshAll()
    local previous=A.kind
    for kind in pairs(A.panels) do A.Activate(kind); A.RefreshCards() end
    if previous then A.Activate(previous) end
end
local function bounds(f)
    local s=f:GetEffectiveScale()/UIParent:GetEffectiveScale()
    return (f:GetLeft() or 0)*s,(f:GetTop() or 0)*s,f:GetWidth()*s,f:GetHeight()*s,s
end
function A.EditorFollows(kind) return A.db.settings[kind].editorAttached~=false end
function A.SaveEditorPosition()
    local e=A.editor
    if not e.kind then return end
    local x,y=bounds(e)
    A.db.settings[e.kind].editorPosition={x=x/UIParent:GetWidth(),y=y/UIParent:GetHeight()}
end
function A.SetEditorAttached(value)
    local e=A.editor
    A.StopDrag(e)
    A.db.settings[e.kind].editorAttached=not not value
    if value then A.Dock(e,e.owner)
    else
        A.SaveEditorPosition()
        A.Place(e,UIParent,A.db.settings[e.kind].editorPosition)
    end
    e.attachList:SetChecked(not not value)
    A.WatchDock()
end
function A.PinTo(frame,anchor)
    local x,y,_,_,s=bounds(frame)
    local ax,ay=bounds(anchor)
    frame:ClearAllPoints()
    frame:SetPoint('TOPLEFT',anchor,'TOPLEFT',(x-ax)/s,(y-ay)/s)
end
function A.PlaceAttached(frame,anchor,kind)
    local setting=A.db.settings[kind]
    if kind=='application' then
        A.Place(frame,anchor,nil,true)
        A.PinTo(frame,anchor)
        setting.attachOffset=nil
        setting.attachBesideNote=nil
        return
    end
    if not setting.attachOffset then
        if not frame:IsShown() then A.Place(frame,anchor,setting.position) end
        local x,y=bounds(frame)
        local ax,ay=bounds(anchor)
        setting.attachOffset={x=x-ax,y=y-ay}
    end
    local s=frame:GetEffectiveScale()/UIParent:GetEffectiveScale()
    frame:ClearAllPoints()
    frame:SetPoint('TOPLEFT',anchor,'TOPLEFT',setting.attachOffset.x/s,setting.attachOffset.y/s)
end
function A.Dock(follower,master)
    local x,y,w= bounds(master)
    local masterY=y
    local _,_,fw,fh,s=bounds(follower)
    local screenW,screenH=UIParent:GetWidth(),UIParent:GetHeight()
    local app=master.kind=='application'
    local gap=0
    local side=app and 'right' or (master.dockSide or 'right')
    if side=='right' and x+w+gap+fw>screenW then side='left'
    elseif side=='left' and x-gap-fw<0 then side='right' end
    master.dockSide=side
    local fx=side=='right' and x+w+gap or x-gap-fw
    fx=math.max(0,math.min(fx,screenW-fw))
    y=math.max(fh,math.min(y,screenH))
    follower:ClearAllPoints()
    if master.kind and A.db.settings[master.kind].attached then
        follower:SetPoint('TOPLEFT',master,'TOPLEFT',(fx-x)/s,(y-masterY)/s)
    else
        follower:SetPoint('TOPLEFT',UIParent,'BOTTOMLEFT',fx/s,y/s)
    end
end
function A.WatchDock()
    local e=A.editor
    local owner=e and e.owner
    local active=e and e:IsShown() and owner and owner:IsShown() and
        A.db.settings[e.kind] and A.db.settings[e.kind].attached and A.EditorFollows(e.kind)
    if not active then
        if A.dockWatcher then A.dockWatcher:SetScript('OnUpdate',nil) end
        A.dockWatching=false
        return
    end
    if A.dockWatching then return end
    A.dockWatcher=A.dockWatcher or CreateFrame('Frame')
    A.dockWatching=true
    local lastX,lastY,lastW,lastH,lastScale,lastSW,lastSH
    A.dockWatcher:SetScript('OnUpdate',function()
        local current=e.owner
        if not e:IsShown() or not current or not current:IsShown() or
            not A.db.settings[e.kind].attached or not A.EditorFollows(e.kind) then A.WatchDock(); return end
        if e.dragging or current.dragging then return end
        local x,y,w,h,s=bounds(current)
        local sw,sh=UIParent:GetWidth(),UIParent:GetHeight()
        if x~=lastX or y~=lastY or w~=lastW or h~=lastH or s~=lastScale or sw~=lastSW or sh~=lastSH then
            A.Dock(e,current)
            lastX,lastY,lastW,lastH,lastScale,lastSW,lastSH=x,y,w,h,s,sw,sh
        end
    end)
end
function A.SavePosition(kind)
    local f=A.panels[kind]; local x,y=bounds(f)
    A.db.settings[kind].position={x=x/UIParent:GetWidth(),y=y/UIParent:GetHeight()}
end
function A.StopDrag(f)
    if not f.dragging then return end
    local kind=f.dragging
    f.dragging=nil; f:SetScript('OnUpdate',nil); f:StopMovingOrSizing()
    if f==A.editor and not A.EditorFollows(kind) then A.SaveEditorPosition()
    else A.SavePosition(kind) end
end
function A.AddDrag(f,kind)
    f:SetMovable(true)
    local header=CreateFrame('Frame',nil,f)
    header:SetPoint('TOPLEFT',0,0); header:SetPoint('TOPRIGHT',-68,0); header:SetHeight(36)
    header:EnableMouse(true); header:RegisterForDrag('LeftButton')
    A.BlockMouseThrough(header)
    header:SetScript('OnDragStart',function()
        local k=kind or f.kind
        if not k or InCombatLockdown() then return end
        local independentEditor=f==A.editor and not A.EditorFollows(k)
        if A.db.settings[k].locked and not independentEditor then return end
        f.dragging=k; f:StartMoving()
        local function follow()
            local other=f==A.editor and A.panels[k] or A.editor
            if A.EditorFollows(k) and other:IsShown() and (f==A.editor or other.owner==f) then A.Dock(other,f) end
        end
        follow(); f:SetScript('OnUpdate',follow)
    end)
    header:SetScript('OnDragStop',function() A.StopDrag(f) end)
    f:HookScript('OnHide',function() A.StopDrag(f) end)
    f.dragHeader=header
end
function A.SetLocked(kind,locked)
    A.StopDrag(A.panels[kind]); if A.editor.kind==kind then A.StopDrag(A.editor) end
    A.db.settings[kind].locked=not not locked
    if not locked and A.db.settings[kind].attached then
        A.db.settings[kind].attached=false
        A.db.settings[kind].attachOffset=nil
        A.db.settings[kind].attachBesideNote=nil
        A.SavePosition(kind)
        A.Place(A.panels[kind],UIParent,A.db.settings[kind].position)
    end
    A.SyncLocks()
end
function A.SetAttached(kind,attached)
    local setting=A.db.settings[kind]
    if kind=='application' then setting.attachBesideNote=attached and true or nil end
    if setting.attached~=not not attached then
        if A.panels[kind]:IsShown() then A.SavePosition(kind) end
        setting.attachOffset=nil
    end
    A.db.settings[kind].attached=not not attached
    A.SetLocked(kind,attached)
    A.Update()
end
function A.AddAttach(f,kind)
    local check=CreateFrame('CheckButton',nil,f,'UICheckButtonTemplate')
    check:SetSize(22,22); check:SetPoint('TOPRIGHT',-12,-33)
    local text=A.Label(check,kind=='application' and 'Attach To Blizzard Note' or 'Attach to LFG',0,0,'GameFontHighlightSmall')
    text:ClearAllPoints(); text:SetPoint('RIGHT',check,'LEFT',-5,0)
    check:SetScript('OnClick',function() A.SetAttached(kind,check:GetChecked()) end)
    f.attach=check
end
function A.SetAutomatic(kind,value)
    A.keepOpen=A.keepOpen or {}
    if not value and A.panels[kind]:IsShown() and A.contextKind==kind and not (A.preview and A.preview[kind]) then
        A.keepOpen[kind]=true
    end
    A.db.settings[kind].automatic=not not value
    A.previewHidden=A.previewHidden or {}; A.previewHidden[kind]=nil
    A.SyncLocks()
    A.Update()
end
function A.AddAutomatic(f,kind)
    local check=CreateFrame('CheckButton',nil,f,'UICheckButtonTemplate')
    check:SetSize(22,22); check:SetPoint('TOPRIGHT',-12,-55)
    local text=A.Label(check,'Automatically Open',0,0,'GameFontHighlightSmall')
    text:ClearAllPoints(); text:SetPoint('RIGHT',check,'LEFT',-5,0)
    check:SetScript('OnClick',function() A.SetAutomatic(kind,check:GetChecked()) end)
    f.autoCheck=check
end
function A.ToggleLock(kind)
    A.SetLocked(kind,not A.db.settings[kind].locked)
end
local function renderLock(button,locked)
    if button.locked==locked then return end
    button.locked=locked
    button.openShackle:SetShown(not locked)
    button.closedShackle:SetShown(locked)
    for _,line in ipairs(button.lockLines) do
        line:SetVertexColor(locked and 1 or .65,locked and .72 or .85,locked and .3 or 1,1)
    end
end
function A.AddLock(f,kind)
    local b=A.Button(f,'',24,24); b:SetPoint('TOPRIGHT',-36,-8)
    b.lockLines={}
    local function line(x,y,w,h)
        local t=b:CreateTexture(nil,'OVERLAY')
        t:SetTexture('Interface\\Buttons\\WHITE8X8')
        t:SetPoint('TOPLEFT',12+(x-12)*.6,-12+(y+12)*.6); t:SetSize(w*.6,h*.6)
        table.insert(b.lockLines,t); return t
    end
    line(6,-11,12,2); line(6,-20,12,2); line(6,-11,2,11); line(16,-11,2,11)
    line(11,-15,2,4)
    line(8,-5,2,6); line(8,-4,8,2)
    b.closedShackle=line(14,-5,2,6)
    b.openShackle=line(14,-3,2,3)
    renderLock(b,false)
    b:SetScript('OnClick',function() local k=kind or f.kind; if k then A.ToggleLock(k) end end)
    b:HookScript('OnEnter',function()
        local tooltip=A.GetTooltip()
        tooltip:SetOwner(b,'ANCHOR_RIGHT')
        tooltip:SetText(A.L(b.locked and 'Unlock Panel' or 'Lock Panel')); A.ShowTooltip()
    end)
    b:HookScript('OnLeave',function() A.GetTooltip():Hide() end)
    f.lock=b
end
function A.SyncLocks()
    for kind,f in pairs(A.panels) do
        local locked=A.db.settings[kind].locked
        renderLock(f.lock,locked)
        f.attach:SetChecked(A.db.settings[kind].attached or false)
        f.autoCheck:SetChecked(A.db.settings[kind].automatic)
        A.SetText(f.footer,locked and 'Position locked. Type /lfp for more options.' or 'Drag header to move. Type /lfp for more options.')
        if A.optionRows and A.optionRows[kind] then
            A.optionRows[kind].lock.locked=locked
            A.SetText(A.optionRows[kind].lock.text,locked and 'Unlock Panel' or 'Lock Panel')
            A.optionRows[kind].attach:SetChecked(A.db.settings[kind].attached or false)
            A.optionRows[kind].auto:SetChecked(A.db.settings[kind].automatic)
        end
    end
    if A.editor.kind then
        renderLock(A.editor.lock,A.db.settings[A.editor.kind].locked)
    end
    A.WatchDock()
end
function A.ApplyAppearance()
    local appearance=A.db.appearance
    A.ApplyTheme()
    for _,f in pairs(A.panels) do f:SetScale(appearance.scale) end
    A.editor:SetScale(appearance.scale)
end
function A.ResetPosition(kind)
    local f=A.panels[kind]
    A.StopDrag(f)
    if A.editor.kind==kind then A.StopDrag(A.editor) end
    A.db.settings[kind].attached=false
    A.db.settings[kind].attachOffset=nil
    A.db.settings[kind].attachBesideNote=nil
    local _,_,w,h=bounds(f)
    local sw,sh=UIParent:GetWidth(),UIParent:GetHeight()
    A.db.settings[kind].position={
        x=math.max(0,math.min(sw/2+200-w/2,sw-w))/sw,
        y=math.max(h,math.min(sh/2+h/2,sh))/sh,
    }
    A.Update()
end
