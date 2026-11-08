local _, A = ...
local border = { edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
    bgFile = "Interface\\Buttons\\WHITE8X8" }
local function skin(f, input)
    A.skins = A.skins or {}; A.skins[f] = input and true or false
    f:SetBackdrop(border)
    f:SetBackdropColor(input and .025 or .045, input and .04 or .075, input and .055 or .10, .98)
    f:SetBackdropBorderColor(.30, .43, .52, 1)
end
A.Skin=skin
local function label(f, text, x, y, font)
    local s = f:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
    A.ApplyFont(s)
    s:SetPoint("TOPLEFT", x, y); s:SetJustifyH("LEFT")
    if text~='' then A.SetText(s,text) else s:SetText('') end
    return s
end
A.Label=label
function A.BlockMouseThrough(frame)
    frame:EnableMouse(true)
    frame:SetPropagateMouseClicks(false)
    frame:SetPropagateMouseMotion(false)
end
function A.StackAbove(frame,anchor)
    frame:SetFrameLevel((anchor and anchor:GetFrameLevel() or 0)+10)
end
local function button(f, text, w, h)
    local b = CreateFrame("Button", nil, f, "BackdropTemplate")
    b:SetSize(w, h); skin(b)
    A.BlockMouseThrough(b)
    b.text = label(b, text, 0, 0); b.text:ClearAllPoints(); b.text:SetPoint("CENTER")
    A.roles[b]=text~='' and 'button' or 'icon'
    if text~='' then
        A.RegisterButton(b)
        b:SetScript('OnMouseDown',function() A.ButtonInteraction(b,'down') end)
        b:SetScript('OnMouseUp',function() A.ButtonInteraction(b,'up') end)
        b:SetScript('OnHide',function() A.ButtonInteraction(b,'hide') end)
    end
    b:SetScript("OnEnter", function()
        if A.buttons[b] then A.ButtonInteraction(b,'enter') else A.PaintBorder(b,true) end
    end)
    b:SetScript("OnLeave", function()
        if A.buttons[b] then A.ButtonInteraction(b,'leave') else A.PaintBorder(b,false) end
    end)
    return b
end
A.Button=button
local function window(name, w, h)
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    f:SetSize(w,h); skin(f); f:SetFrameStrata("FULLSCREEN_DIALOG"); f:EnableMouse(true)
    A.BlockMouseThrough(f); f:SetToplevel(true)
    A.roles[f]='window'
    f:SetClampedToScreen(true); f:Hide()
    f.heading = label(f, "", 14, -15, "GameFontNormalLarge")
    A.Accent(f.heading)
    local close = button(f, "X", 24,24); close:SetPoint("TOPRIGHT", -8,-8)
    close.text:SetPoint("CENTER",0,0)
    close.text:SetFontObject(GameFontHighlightLarge)
    A.ApplyFont(close.text,0,true)
    close:SetScript("OnClick", function() f:Hide() end)
    return f
end
A.Window=window
function A.Place(frame, anchor, position, adjacentOnly)
    frame:ClearAllPoints()
    local ratio=frame:GetEffectiveScale()/UIParent:GetEffectiveScale()
    local w, h = UIParent:GetWidth()/ratio, UIParent:GetHeight()/ratio
    if position then
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT",
            math.max(0, math.min(position.x * w, w-frame:GetWidth())),
            math.max(frame:GetHeight(), math.min(position.y * h, h)))
        return
    end
    local scale = anchor:GetEffectiveScale() / frame:GetEffectiveScale()
    local left, right, top = (anchor:GetLeft() or 0)*scale,
        (anchor:GetRight() or 0)*scale, (anchor:GetTop() or h)*scale
    local gap=adjacentOnly and 0 or 12
    local x = right + gap
    local rio = _G.RaiderIO_ProfileTooltip
    if not adjacentOnly and rio and rio:IsShown() and rio:GetRight() then
        local rs = rio:GetEffectiveScale()/frame:GetEffectiveScale()
        x = math.max(x, rio:GetRight()*rs+12)
    end
    if x + frame:GetWidth() > w then x = left-frame:GetWidth()-gap end
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT",
        math.max(0,math.min(x,w-frame:GetWidth())), math.max(frame:GetHeight(),math.min(top,h)))
end
local function fitPreview(text,font,fits)
    local function display(value) font:SetText((value:gsub('|','||'))) end
    display(text)
    if fits() then return end
    local ends={}
    for i=1,#text do
        local byte=text:byte(i)
        if byte<128 or byte>=192 then ends[#ends+1]=i-1 end
    end
    ends[#ends+1]=#text
    local low,high,best=1,#ends,0
    while low<=high do
        local mid=math.floor((low+high)/2)
        display(text:sub(1,ends[mid])..'...')
        if fits() then best=ends[mid]; low=mid+1 else high=mid-1 end
    end
    display(text:sub(1,best)..'...')
end
local function preview(text,font,width)
    fitPreview(text:gsub('[\r\n]+',' '),font,function() return font:GetStringWidth()<=width end)
end
local function descriptionPreview(text,font,width)
    text=text:gsub('[\r\n]+',' ')
    font:SetWordWrap(true); font:SetNonSpaceWrap(true)
    font:SetWidth(width); font:SetHeight(0); font:SetMaxLines(0)
    fitPreview(text,font,function() return font:GetStringHeight()<=30 end)
    local oneLine=font:GetNumLines()==1
    font:SetMaxLines(2); font:SetHeight(30)
    font:SetJustifyV(oneLine and 'MIDDLE' or 'TOP')
end
function A.SizeListThumb(f)
    local bar=f.scroll.ScrollBar
    local thumb=bar:GetThumbTexture()
    if not thumb then return end
    local viewport=f.scroll:GetHeight()
    local content=f.content:GetHeight()
    local track=bar:GetHeight()
    if track<=0 or content<=0 then return end
    local ratio=math.min(1,viewport/content)
    thumb:SetTexture('Interface\\Buttons\\WHITE8X8')
    thumb:SetTexCoord(0,1,0,1)
    thumb:SetWidth(14)
    thumb:SetHeight(math.min(track,math.max(18,track*ratio)))
    thumb:SetAlpha(0)
    A.LayoutListThumb(f)
    A.StyleScrollBar(bar)
end
function A.LayoutListThumb(f)
    local bar=f.scroll.ScrollBar
    local state=A.scrollbars[bar]
    if not state then return end
    local height=bar:GetThumbTexture():GetHeight()
    local low,high=bar:GetMinMaxValues()
    local range=high-low
    local travel=math.max(0,bar:GetHeight()-height)
    local fraction=range>0 and math.max(0,math.min(1,(bar:GetValue()-low)/range)) or 0
    state.face:ClearAllPoints()
    state.face:SetSize(14,height)
    state.face:SetPoint('TOP',bar,'TOP',0,-fraction*travel)
end
function A.ScrollDragValue(startValue,startY,cursorY,scale,range,travel)
    if travel<=0 or range<=0 then return startValue end
    return startValue+(startY-cursorY)/scale*range/travel
end
function A.SetupListScrollInput(f)
    local bar=f.scroll.ScrollBar
    local state=A.scrollbars[bar]
    bar:EnableMouse(false); bar.scrollStep=40
    local face=state.face
    face:EnableMouse(true)
    face:SetFrameLevel(bar:GetFrameLevel()+3)
    local track=CreateFrame('Frame',nil,bar)
    track:SetAllPoints(bar); track:SetFrameLevel(bar:GetFrameLevel()+2)
    track:EnableMouse(true); track:EnableMouseWheel(true)
    state.track=track
    local function stop()
        face:SetScript('OnUpdate',nil); state.pressed=false; A.StyleScrollBar(bar)
    end
    face:SetScript('OnMouseDown',function(_,button)
        if button~='LeftButton' then return end
        local _,startY=GetCursorPosition()
        local startValue=bar:GetValue()
        local low,high=bar:GetMinMaxValues()
        local travel=bar:GetHeight()-face:GetHeight()
        state.pressed=true; A.StyleScrollBar(bar)
        face:SetScript('OnUpdate',function()
            if not IsMouseButtonDown('LeftButton') then stop(); return end
            local _,y=GetCursorPosition()
            bar:SetValue(A.ScrollDragValue(startValue,startY,y,bar:GetEffectiveScale(),high-low,travel))
        end)
    end)
    face:SetScript('OnMouseUp',stop); face:SetScript('OnHide',stop)
    bar:HookScript('OnHide',stop)
    face:SetScript('OnEnter',function() state.hover=true; A.StyleScrollBar(bar) end)
    face:SetScript('OnLeave',function() state.hover=false; A.StyleScrollBar(bar) end)
    track:SetScript('OnMouseDown',function(_,button)
        if button~='LeftButton' then return end
        local _,y=GetCursorPosition(); y=y/bar:GetEffectiveScale()
        local direction=y>face:GetTop() and -1 or 1
        bar:SetValue(bar:GetValue()+direction*f.scroll:GetHeight())
    end)
    local function wheel(_,delta) bar:SetValue(bar:GetValue()-delta*40) end
    track:SetScript('OnMouseWheel',wheel)
    face:EnableMouseWheel(true); face:SetScript('OnMouseWheel',wheel)
    f.scroll:SetScript('OnMouseWheel',wheel)
    bar:HookScript('OnValueChanged',function() A.LayoutListThumb(f) end)
end
A.previewCaches={}
function A.RefreshCards()
    if not A.kind then return end
    local f=A.panel
    local count=#A.db.presets[A.kind]
    local overflow=count>5
    local viewport=overflow and 366 or 330
    local width=overflow and 300 or 320
    A.SetText(f.heading,A.names[A.kind])
    f:SetHeight(viewport+118)
    f.scroll:SetSize(width,viewport)
    f.content:SetSize(width,math.max(1,count*67-5))
    f.scroll.ScrollBar:SetShown(overflow)
    A.SizeListThumb(f)
    local addedRows=false
    while #A.rows<count do
        f.makeRow(#A.rows+1)
        addedRows=true
    end
    if addedRows then A.ApplyTheme() end
    local maxScroll=math.max(0,count*67-5-viewport)
    local offset=math.min(f.scroll:GetVerticalScroll(),maxScroll)
    f.scroll.ScrollBar:SetMinMaxValues(0,maxScroll)
    f.scroll.ScrollBar:SetValue(offset)
    f.scroll:SetVerticalScroll(offset)
    for i, row in ipairs(A.rows) do
        row:SetShown(i<=count)
        if i<=count then
            local p = A.Get(A.kind,i)
            local app = A.kind == "application"
            local body = app and (p.note or "") or (p.description or "")
            local title = p.title or ""
            local _,fontSize=row.body:GetFont()
            local cache=A.previewCaches[row]
            if not cache or cache.title~=title or cache.body~=body or cache.width~=width or cache.language~=A.db.language or cache.fontSize~=fontSize then
                row:SetWidth(width)
                local titleEmpty=not title:find('%S')
                local bodyEmpty=not body:find('%S')
                row.title:SetShown(not app)
                if not app then preview(not titleEmpty and title or (bodyEmpty and A.L("Empty Preset") or ""),row.title,width-66) end
                row.body:ClearAllPoints(); row.body:SetPoint("TOPLEFT",12,app and -16 or -28)
                descriptionPreview(not bodyEmpty and body or (app and A.L('Empty Preset') or ''),row.body,width-66)
                A.previewCaches[row]={title=title,body=body,width=width,language=A.db.language,fontSize=fontSize}
            end
        end
    end
end
function A.SaveEditor()
    local e = A.editor
    if not e or not e.session then return end
    if A.deleteDialog and A.deleteDialog:IsShown() then return end
    if e.isNew then
        e.index=A.Append(e.kind,e.titleBox:GetText(),e.bodyBox:GetText())
    else A.Store(e.kind,e.index,e.titleBox:GetText(),e.bodyBox:GetText()) end
    A.Activate(e.kind); A.RefreshCards(); e:Hide()
    if e.isNew then
        local f=A.panels[e.kind]
        f.scroll:SetVerticalScroll(math.max(0,#A.db.presets[e.kind]*67-5-f.scroll:GetHeight()))
    end
end
local function field(e, multiline)
    local holder = CreateFrame("Frame",nil,e,"BackdropTemplate"); skin(holder,true)
    local scroll
    if multiline then
        scroll=CreateFrame("ScrollFrame",nil,holder,"UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT",8,-8); scroll:SetPoint("BOTTOMRIGHT",-28,8)
        A.BlockMouseThrough(scroll)
    end
    local box = CreateFrame("EditBox",nil,scroll or holder)
    A.BlockMouseThrough(box)
    box:SetFontObject(ChatFontNormal); A.ApplyFont(box)
    box:SetMultiLine(multiline); box:SetAutoFocus(false)
    box:SetWidth(e:GetWidth()-(multiline and 76 or 48)); box:SetHeight(multiline and 126 or 22)
    box:SetTextInsets(0,0,0,0)
    if multiline then scroll:SetScrollChild(box)
    else box:SetPoint('TOPLEFT',8,-8); box:SetMaxLetters(31) end
    box:SetScript("OnEscapePressed",function() e:Hide() end)
    box:SetScript('OnEnterPressed',function() end)
    box:SetScript('OnEditFocusLost',function(self) self.returnHeld=false end)
    box:SetScript("OnEditFocusGained",function(self)
        for _, other in ipairs({e.titleBox,e.bodyBox}) do
            if other ~= self then other:HighlightText(0,0) end
        end
    end)
    box:SetScript("OnKeyDown",function(self,key)
        if key=='ENTER' or key=='NUMPADENTER' then self.returnHeld=true end
        if key == "C" and IsControlKeyDown() and self:HasFocus() then
            local session = e.session
            C_Timer.After(0,function()
                if session and e.session == session and e:IsShown() then A.SaveEditor() end
            end)
        end
    end)
    box:SetScript('OnKeyUp',function(self,key)
        if key=='ENTER' or key=='NUMPADENTER' then self.returnHeld=false end
    end)
    A.BlockMouseThrough(holder)
    holder:SetScript("OnMouseDown",function() box:SetFocus() end)
    if scroll then scroll:SetScript('OnMouseDown',function() box:SetFocus() end) end
    box:SetScript("OnCursorChanged",function(_,_,y,_,height)
        if not multiline then return end
        local offset = scroll:GetVerticalScroll()
        local pos = -y
        if pos < offset then scroll:SetVerticalScroll(pos)
        elseif pos+height > offset+scroll:GetHeight() then
            scroll:SetVerticalScroll(pos+height-scroll:GetHeight())
        end
    end)
    return holder, box
end
function A.OpenEditor(index,isNew)
    if InCombatLockdown() then return end
    local e = A.editor
    if e:IsShown() and e.kind==A.kind and e.index==index and e.isNew==not not isNew then
        e:Hide()
        return
    end
    e:Hide(); e.kind, e.index, e.isNew = A.kind,index,not not isNew
    local app = e.kind == "application"
    local p = isNew and {} or A.Get(e.kind,index)
    e.delete:SetShown(not isNew)
    A.SetText(e.heading,app and "Application Preset" or (e.kind == "raid" and "Edit Raid Preset" or "Edit Dungeon Preset"))
    e.titleLabel:SetShown(not app); e.titleHolder:SetShown(not app)
    A.SetText(e.bodyLabel,app and "Note" or "Description")
    e.bodyLabel:ClearAllPoints(); e.bodyLabel:SetPoint("TOPLEFT",16,app and -55 or -128)
    e.bodyHolder:ClearAllPoints(); e.bodyHolder:SetPoint("TOPLEFT",16,app and -77 or -150)
    e:SetHeight(app and 326 or 399)
    e.bodyBox:SetMaxLetters(app and 63 or 255)
    e.titleBox:SetText(app and "" or (p.title or ""))
    e.bodyBox:SetText(app and (p.note or "") or (p.description or ""))
    e.owner=A.panel
    A.StackAbove(e,e.owner)
    e.session = {}; e:Show()
    local follows=A.EditorFollows(e.kind)
    e.attachList:SetChecked(follows)
    if follows then
        if app then A.panel.dockSide='right' end
        A.Dock(e,A.panel)
    else A.Place(e,A.panel,A.db.settings[e.kind].editorPosition) end
    A.SyncLocks()
    e.titleBox:HighlightText(0,0); e.bodyBox:HighlightText(0,0)
    local target = A.InitialField(e.titleBox:GetText(),e.bodyBox:GetText(),app)
    local box = target == "title" and e.titleBox or e.bodyBox
    box:SetFocus(); box:HighlightText()
    e.bodyBox:GetParent():SetVerticalScroll(0)
end
local function buildPanel(kind)
    A.panel = window("LFGPresetsByWadenownPanel"..kind,344,448)
    local f = A.panel
    label(f,"LFG Presets By Wadenown",14,-39,"GameFontDisableSmall")
    f.kind=kind
    f:SetScript("OnHide",function()
        if A.keepOpen then A.keepOpen[kind]=nil end
        if A.editor and A.editor.owner==f then A.editor:Hide() end
    end)
    f.scroll=CreateFrame('ScrollFrame',nil,f,'UIPanelScrollFrameTemplate')
    f.scroll:SetPoint('TOPLEFT',12,-84); f.scroll:SetSize(320,330)
    f.scroll.ScrollBar:Hide()
    f.content=CreateFrame('Frame',nil,f.scroll); f.content:SetSize(320,330)
    f.scroll:SetScrollChild(f.content)
    A.RegisterListScrollbar(f.scroll.ScrollBar)
    A.SetupListScrollInput(f)
    f.scroll.ScrollBar:HookScript('OnSizeChanged',function() A.SizeListThumb(f) end)
    f.scroll:HookScript('OnScrollRangeChanged',function() A.SizeListThumb(f) end)
    A.rows = {}; f.rows=A.rows
    f.makeRow=function(i)
        local row = CreateFrame("Frame",nil,f.content,"BackdropTemplate")
        row:SetSize(320,62); row:SetPoint("TOPLEFT",0,-(i-1)*67); skin(row)
        row.title = A.Accent(label(row,"",12,-12))
        row.body = label(row,"",12,-34,"GameFontHighlightSmall")
        row:EnableMouse(true)
        row:SetScript("OnEnter",function()
            local p = A.Get(kind,i)
            local tooltip=A.GetTooltip()
            tooltip:SetOwner(row,"ANCHOR_LEFT")
            if kind ~= "application" then tooltip:AddLine((p.title or ""):gsub("|","||"),.65,.85,1,true) end
            tooltip:AddLine((p.note or p.description or ""):gsub("|","||"),1,1,1,true)
            A.ShowTooltip(row.body,row)
        end)
        row:SetScript("OnLeave",function() A.GetTooltip():Hide() end)
        local b = button(row,"",36,34); b:SetPoint("BOTTOMRIGHT",-7,8)
        row.action=b
        for n=1,2 do
            local square=CreateFrame("Frame",nil,b,"BackdropTemplate")
            square:SetSize(16,18); square:SetPoint("BOTTOMLEFT",7+(n-1)*5,5+(n-1)*5)
            skin(square,true); A.roles[square]='copyGlyph'
            square:SetBackdropBorderColor(1,.82,0,1)
        end
        local gear=b:CreateTexture(nil,"OVERLAY")
        gear:SetTexture("Interface\\Buttons\\UI-OptionsButton"); gear:SetSize(16,16); gear:SetPoint("TOPRIGHT",3,3)
        b:HookScript("OnEnter",function()
            local tooltip=A.GetTooltip()
            tooltip:SetOwner(b,"ANCHOR_RIGHT"); tooltip:SetText(A.L("Copy / Edit Preset")); A.ShowTooltip()
        end)
        b:HookScript("OnLeave",function() A.GetTooltip():Hide() end)
        b:SetScript("OnClick",function() A.Activate(kind); A.OpenEditor(i) end)
        f.rows[i]=row
    end
    for i=1,5 do f.makeRow(i) end
    f.addSlot=button(f,'+ Slot',72,22); f.addSlot:SetPoint('BOTTOMRIGHT',-12,10)
    A.buttons[f.addSlot].textOffsetY=-1
    f.footer=label(f,"",0,0,"GameFontDisableSmall")
    f.footer:ClearAllPoints(); f.footer:SetPoint('LEFT',f,'BOTTOMLEFT',14,21)
    f.footer:SetWidth(230); f.footer:SetWordWrap(true); f.footer:SetJustifyV('MIDDLE')
    f.addSlot:SetScript('OnClick',function()
        A.Activate(kind); A.OpenEditor(#A.db.presets[kind]+1,true)
    end)
    A.panels[kind]=f
    A.AddDrag(f,kind)
    A.AddLock(f,kind)
    A.AddAttach(f,kind)
    A.AddAutomatic(f,kind)
    f.persistNote=A.AddPersistCheckbox(f,12,-55)
end
function A.BuildUI()
    A.panels={}
    for _,kind in ipairs({'application','dungeon','raid'}) do buildPanel(kind) end
    local e = window("LFGPresetsByWadenownEditor",280,399); A.editor=e
    e:SetFrameStrata('FULLSCREEN_DIALOG')
    A.AddDrag(e)
    A.AddLock(e)
    e.attachList=CreateFrame('CheckButton',nil,e,'UICheckButtonTemplate')
    e.attachList:SetSize(22,22); e.attachList:SetPoint('TOPRIGHT',-12,-33)
    local attachText=label(e.attachList,'Attach to List',0,0,'GameFontHighlightSmall')
    attachText:ClearAllPoints(); attachText:SetPoint('RIGHT',e.attachList,'LEFT',-5,0)
    e.attachList:SetScript('OnClick',function() A.SetEditorAttached(e.attachList:GetChecked()) end)
    table.insert(UISpecialFrames,"LFGPresetsByWadenownEditor")
    e.titleLabel=label(e,"Title",16,-55)
    e.titleHolder,e.titleBox=field(e,false); e.titleHolder:SetSize(e:GetWidth()-32,38); e.titleHolder:SetPoint("TOPLEFT",16,-77)
    e.bodyLabel=label(e,"Description",16,-128)
    e.bodyHolder,e.bodyBox=field(e,true); e.bodyHolder:SetSize(e:GetWidth()-32,148)
    e.titleBox:SetScript("OnTabPressed",function() e.bodyBox:SetFocus() end)
    e.bodyBox:SetScript("OnTabPressed",function() if e.kind~="application" then e.titleBox:SetFocus() end end)
    local hint=label(e,"Ctrl+C to copy, save and close.",16,0,"GameFontHighlightSmall")
    hint:ClearAllPoints(); hint:SetPoint("BOTTOM",0,64)
    e.counter=label(e,"",16,0,"GameFontDisableSmall"); e.counter:ClearAllPoints(); e.counter:SetPoint("BOTTOM",0,81)
    local function count()
        local app=e.kind=="application"
        local titleLength,bodyLength=strlenutf8(e.titleBox:GetText()),strlenutf8(e.bodyBox:GetText())
        local atLimit=bodyLength>=(app and 63 or 255) or (not app and titleLength>=31)
        e.counter:SetTextColor(atLimit and 1 or .6,atLimit and .2 or .65,atLimit and .2 or .7)
        if app then A.SetText(e.counter,'%d / 63 note characters',bodyLength)
        else A.SetText(e.counter,'%d / 31 title  |  %d / 255 description',titleLength,bodyLength) end
    end
    local function textChanged(box)
        local text=box:GetText()
        local replacement=box.returnHeld and '' or ' '
        local clean=text:gsub('[\r\n]+',replacement)
        if clean~=text then
            local cursor=box:GetCursorPosition() or #text
            local prefix=text:sub(1,cursor):gsub('[\r\n]+',replacement)
            box:SetText(clean); box:SetCursorPosition(#prefix)
            return
        end
        count()
    end
    e.titleBox:SetScript("OnTextChanged",textChanged); e.bodyBox:SetScript("OnTextChanged",textChanged)
    e.updateCounter=count
    local save=button(e,"Save",100,28); save:SetPoint("BOTTOMRIGHT",-25,18); save:SetScript("OnClick",A.SaveEditor)
    A.SetButtonStyle(save,'primary'); e.save=save
    local delete=button(e,'Delete',100,28); delete:SetPoint('BOTTOMLEFT',25,18)
    A.SetButtonStyle(delete,'tertiary'); e.delete=delete
    local dialog=window('LFGPresetsByWadenownDeleteDialog',310,170); A.deleteDialog=dialog
    dialog:SetFrameStrata('FULLSCREEN_DIALOG'); dialog:SetPoint('CENTER')
    A.SetText(dialog.heading,'Delete Preset?')
    table.insert(UISpecialFrames,'LFGPresetsByWadenownDeleteDialog')
    local question=label(dialog,'Are you sure you want to permanently delete this slot?',18,-53)
    question:SetWidth(274); question:SetWordWrap(true)
    local yes=button(dialog,'Yes, Delete',125,28); yes:SetPoint('BOTTOMLEFT',18,18)
    local no=button(dialog,'No, Keep',125,28); no:SetPoint('BOTTOMRIGHT',-18,18)
    A.SetButtonStyle(yes,'tertiary'); A.SetButtonStyle(no,'primary')
    dialog.yes,dialog.no=yes,no
    delete:SetScript('OnClick',function()
        if e.isNew or not e.session then return end
        local p=A.Get(e.kind,e.index)
        dialog.kind,dialog.id,dialog.session=e.kind,p.id,e.session
        e.titleBox:ClearFocus(); e.bodyBox:ClearFocus()
        A.StackAbove(dialog,e)
        dialog:Show()
    end)
    yes:SetScript('OnClick',function()
        if not dialog:IsShown() or not dialog.session or e.session~=dialog.session then dialog:Hide(); return end
        local kind=dialog.kind
        A.DeletePreset(kind,dialog.id)
        e:Hide(); A.RefreshAll(); A.Update()
    end)
    no:SetScript('OnClick',function() dialog:Hide() end)
    dialog:SetScript('OnHide',function()
        if e:IsShown() and e.session==dialog.session then
            if e.kind=='application' then e.bodyBox:SetFocus() else e.titleBox:SetFocus() end
        end
        dialog.session=nil
    end)
    e:SetScript("OnHide",function()
        dialog:Hide()
        A.StopDrag(e)
        if e.session and not A.EditorFollows(e.kind) then A.SaveEditorPosition() end
        e.session=nil
        A.WatchDock()
        e.titleBox:ClearFocus(); e.bodyBox:ClearFocus()
    end)
    A.ApplyAppearance()
end
