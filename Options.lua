local _,A=...
local usage1='Panels appear beside group creation and applications.'
local usage2='Open a preset, edit, then Ctrl+C to copy, save and close. Paste manually.'
local order={'application','dungeon','raid'}
local titles={application='Application Notes',dungeon='Dungeon Presets',raid='Raid Presets'}
local descriptions={application='Shared across all applications.',dungeon='Dungeon group creation.',raid='Raid group creation.'}
local function checkbox(parent,text,x,y,callback)
    local b=CreateFrame('CheckButton',nil,parent,'UICheckButtonTemplate')
    b:SetSize(26,26); b:SetPoint('TOPLEFT',x,y)
    local t=A.Label(b,text,30,-7,'GameFontHighlightSmall')
    if text=='Attach To Blizzard Note' then t:SetWidth(96); t:SetWordWrap(true) end
    b:SetScript('OnClick',function() callback(b:GetChecked()) end)
    return b
end
function A.OpenOptions()
    A.StackAbove(A.options,_G.LFGListApplicationDialog or _G.PVEFrame)
    A.options:Show(); A.SyncOptions(); A.SyncLocks()
end
function A.SyncOptions()
    A.SyncPersistNote()
    for _,kind in ipairs(order) do
        local row=A.optionRows[kind]
        row.auto:SetChecked(A.db.settings[kind].automatic)
        row.preview:SetChecked(A.preview[kind] or false)
        row.attach:SetChecked(A.db.settings[kind].attached or false)
    end
end
function A.BuildOptions()
    A.preview={}; A.optionRows={}
    local f=A.Window('LFGPresetsByWadenownOptions',660,616); A.options=f
    f:SetPoint('CENTER'); A.SetText(f.heading,'LFG Presets By Wadenown - Options')
    f:SetFrameStrata('FULLSCREEN_DIALOG')
    f:SetMovable(true)
    local header=CreateFrame('Frame',nil,f)
    header:SetPoint('TOPLEFT',0,0); header:SetPoint('TOPRIGHT',-38,0); header:SetHeight(38)
    header:EnableMouse(true); header:RegisterForDrag('LeftButton')
    header:SetScript('OnDragStart',function() f:StartMoving() end)
    header:SetScript('OnDragStop',function() f:StopMovingOrSizing() end)
    f.dragHeader=header
    table.insert(UISpecialFrames,'LFGPresetsByWadenownOptions')
    A.Label(f,usage1,18,-53,'GameFontHighlightSmall')
    local helpText=A.Label(f,usage2,18,-74,'GameFontHighlightSmall')
    helpText:SetWidth(420); helpText:SetWordWrap(true)
    f.persistNote=A.AddPersistCheckbox(f,453,-106)
    local themeLabel=A.Label(f,'Theme:',0,0,'GameFontHighlightSmall')
    themeLabel:ClearAllPoints(); themeLabel:SetPoint('TOPRIGHT',-160,-45)
    A.themeButtons={}
    for i,theme in ipairs({'classic','modern'}) do
        local b=A.Button(f,theme=='classic' and 'Classic' or 'Modern',68,24)
        b:SetPoint('TOPRIGHT',i==1 and -86 or -14,-38)
        b.theme=theme; A.roles[b]='theme'; A.themeButtons[theme]=b
        b:SetScript('OnClick',function() A.SetTheme(theme) end)
    end
    local languageLabel=A.Label(f,'Language:',0,0,'GameFontHighlightSmall')
    languageLabel:ClearAllPoints(); languageLabel:SetPoint('TOPRIGHT',-160,-71)
    A.languageButtons={}
    for i,language in ipairs({'en','tr'}) do
        local b=A.Button(f,language=='en' and 'English' or 'Turkish',68,24)
        b:SetPoint('TOPRIGHT',i==1 and -86 or -14,-64)
        b.language=language; A.roles[b]='language'; A.languageButtons[language]=b
        b:SetScript('OnClick',function() A.SetLanguage(language) end)
    end
    local confirm=A.Window('LFGPresetsByWadenownConfirm',410,165)
    confirm:SetFrameStrata('FULLSCREEN_DIALOG'); confirm:SetPoint('CENTER')
    table.insert(UISpecialFrames,'LFGPresetsByWadenownConfirm')
    local message=A.Label(confirm,'',16,-53,'GameFontHighlight')
    message:SetWidth(375); message:SetWordWrap(true)
    local yes=A.Button(confirm,'Reset',130,28); yes:SetPoint('BOTTOMLEFT',45,18)
    A.SetButtonStyle(yes,'destructive')
    local no=A.Button(confirm,'Cancel',130,28); no:SetPoint('BOTTOMRIGHT',-45,18)
    yes:SetScript('OnClick',function() A.ResetPresets(confirm.kind); confirm:Hide() end)
    no:SetScript('OnClick',function() confirm:Hide() end)
    for i,kind in ipairs(order) do
        local row=CreateFrame('Frame',nil,f,'BackdropTemplate'); A.Skin(row)
        row:SetSize(628,94); row:SetPoint('TOPLEFT',16,-136-(i-1)*102)
        A.Accent(A.Label(row,titles[kind],14,-13,'GameFontNormalLarge'))
        local description=A.Label(row,descriptions[kind],14,-49,'GameFontHighlightSmall')
        description:ClearAllPoints(); description:SetPoint('LEFT',row,'TOPLEFT',14,-63)
        row.auto=checkbox(row,'Open automatically',234,-7,function(value)
            A.SetAutomatic(kind,value)
        end)
        row.attach=checkbox(row,kind=='application' and 'Attach To Blizzard Note' or 'Attach to LFG',367,-7,function(value)
            A.SetAttached(kind,value)
        end)
        row.preview=checkbox(row,'Preview Panel',500,-7,function(value)
            A.preview[kind]=value or nil
            A.previewHidden=A.previewHidden or {}; A.previewHidden[kind]=not value
            A.Update()
        end)
        row.lock=A.Button(row,'Lock Panel',116,28); row.lock:SetPoint('TOPLEFT',239,-49)
        A.SetButtonStyle(row.lock,'secondary')
        row.lock:SetScript('OnClick',function() A.ToggleLock(kind) end)
        local reset=A.Button(row,'Reset Position',122,28); reset:SetPoint('TOPLEFT',363,-49)
        A.SetButtonStyle(reset,'tertiary'); row.resetPosition=reset
        reset:SetScript('OnClick',function() A.ResetPosition(kind) end)
        local clear=A.Button(row,'Reset Presets',122,28); clear:SetPoint('TOPLEFT',493,-49)
        A.SetButtonStyle(clear,'destructive'); row.resetPresets=clear
        clear:SetScript('OnClick',function()
            confirm.kind=kind
            A.refreshResetDialog()
            A.StackAbove(confirm,f); confirm:Show()
        end)
        A.optionRows[kind]=row
    end
    A.refreshResetDialog=function()
        if not confirm.kind then return end
        A.SetText(confirm.heading,'Reset %s?',A.L(titles[confirm.kind]))
        A.SetText(message,'This clears all %d presets in this section.',#A.db.presets[confirm.kind])
    end
    local appearance=CreateFrame('Frame',nil,f,'BackdropTemplate'); A.Skin(appearance)
    appearance:SetSize(628,112); appearance:SetPoint('TOPLEFT',16,-442)
    A.Accent(A.Label(appearance,'Appearance',14,-12,'GameFontNormalLarge'))
    local function slider(text,key,y,min,max)
        A.Label(appearance,text,14,y,'GameFontHighlightSmall')
        local s=CreateFrame('Slider',nil,appearance,'OptionsSliderTemplate')
        s:SetPoint('TOPLEFT',245,y); s:SetSize(280,16); s:SetMinMaxValues(min,max)
        s:SetValueStep(.05); s:SetObeyStepOnDrag(true)
        if s.Low then s.Low:Hide() end; if s.High then s.High:Hide() end
        local value=A.Label(appearance,'',550,y,'GameFontHighlightSmall')
        s:SetScript('OnValueChanged',function(_,v)
            A.db.appearance[key]=v; value:SetText(math.floor(v*100+.5)..'%')
            A.ApplyAppearance(); A.Update()
        end)
        s:SetValue(A.db.appearance[key])
        value:SetText(math.floor(A.db.appearance[key]*100+.5)..'%')
    end
    slider('Panel scale','scale',-43,.65,1.4)
    slider('Background opacity','opacity',-78,.1,1)
    local done=A.Button(f,'Done',130,30); done:SetPoint('BOTTOMRIGHT',-16,16)
    A.SetButtonStyle(done,'primary'); f.done=done
    done:SetScript('OnClick',function() f:Hide() end)
    f:SetScript('OnHide',function()
        f:StopMovingOrSizing()
        confirm:Hide()
        A.previewHidden=A.previewHidden or {}
        for kind in pairs(A.preview) do A.previewHidden[kind]=true end
        A.preview={}; A.SyncOptions(); A.Update()
    end)
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local page=CreateFrame('Frame')
        page:Hide()
        A.Label(page,'LFG Presets By Wadenown',16,-16,'GameFontNormalLarge')
        A.Label(page,usage1,16,-60,'GameFontHighlight')
        local help=A.Label(page,usage2,16,-85,'GameFontHighlight')
        help:SetWidth(560); help:SetWordWrap(true)
        local open=A.Button(page,'Open Options',180,30); open:SetPoint('TOPLEFT',16,-140)
        open:SetScript('OnClick',A.OpenOptions)
        local category=Settings.RegisterCanvasLayoutCategory(page,'LFG Presets By Wadenown')
        Settings.RegisterAddOnCategory(category)
        A.settingsCategory=category
    end
    A.SyncOptions(); A.SyncLocks(); A.ApplyAppearance()
end
