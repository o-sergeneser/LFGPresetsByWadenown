local _,A=...
A.roles={}; A.accents={}
A.buttons={}
A.surfaceGrain={}
A.scrollbars={}
function A.SelectionActive(button)
    if A.roles[button]=='theme' then return button.theme==A.db.appearance.theme end
    if A.roles[button]=='language' then return button.language==A.db.language end
    return false
end
local white='Interface\\Buttons\\WHITE8X8'
local modern={bgFile=white,edgeFile=white,edgeSize=1}
local classic={bgFile=white,
    edgeFile='Interface\\Tooltips\\UI-Tooltip-Border',tile=true,tileSize=32,edgeSize=12,
    insets={left=3,right=3,top=3,bottom=3}}
local classicWindow={bgFile=white,
    edgeFile='Interface\\DialogFrame\\UI-DialogBox-Border',tile=true,tileSize=32,edgeSize=24,
    insets={left=6,right=6,top=6,bottom=6}}
local classicButton={bgFile=white,edgeFile='Interface\\Tooltips\\UI-Tooltip-Border',edgeSize=10,
    insets={left=3,right=3,top=3,bottom=3}}
local palettes={
    classic={
        normal={bg={.30,.025,.025},edge={.70,.57,.30},text={1,.82,0}},
        primary={bg={.43,.018,.025},edge={1,.73,.20},text={1,.86,.13}},
        secondary={bg={.25,.17,.075},edge={.70,.48,.24},text={1,.85,.55}},
        tertiary={bg={.13,.13,.14},edge={.61,.62,.63},text={.96,.96,.94}},
        destructive={bg={.22,.035,.045},edge={.70,.31,.18},text={1,.80,.64}},
        theme={bg={.19,.21,.22},edge={.67,.70,.70},text={.96,.94,.85}},
    },
    modern={
        normal={bg={.055,.10,.14},edge={.30,.43,.52},text={.90,.95,1}},
        primary={bg={.055,.19,.27},edge={.29,.68,.85},text={.88,.97,1}},
        secondary={bg={.085,.13,.17},edge={.37,.52,.61},text={.83,.92,.98}},
        tertiary={bg={.09,.095,.10},edge={.48,.50,.52},text={.92,.94,.95}},
        destructive={bg={.13,.075,.12},edge={.57,.32,.45},text={.94,.78,.84}},
        theme={bg={.075,.12,.16},edge={.36,.49,.58},text={.84,.92,.98}},
    },
}
function A.StyleScrollBar(bar)
    local state=A.scrollbars[bar]
    if not state then return end
    local c=A.db.appearance.theme=='classic'
    local inset=state.pressed
    local p=c and palettes.classic.tertiary or palettes.modern.secondary
    local glow=state.hover and .06 or 0
    local factor=inset and .65 or 1
    state.face:SetBackdropColor(p.bg[1]*factor+glow,p.bg[2]*factor+glow,p.bg[3]*factor+glow,1)
    state.face:SetBackdropBorderColor(p.edge[1],p.edge[2],p.edge[3],1)
    state.grain:SetVertexColor(c and .7 or .45,c and .65 or .6,c and .55 or .7)
    state.grain:SetAlpha(c and .24 or .09)
    for side,t in pairs(state.bevel) do
        local light=(side=='top' or side=='left')~=not not inset
        t:SetVertexColor(light and p.edge[1] or 0,light and p.edge[2] or 0,light and p.edge[3] or 0,light and .9 or .85)
    end
    for _,t in ipairs(state.grip) do t:SetVertexColor(p.edge[1],p.edge[2],p.edge[3],.9) end
    bar:GetThumbTexture():SetVertexColor(p.bg[1],p.bg[2],p.bg[3],1)
end
function A.RegisterListScrollbar(bar)
    bar:EnableMouse(true); bar:SetObeyStepOnDrag(false); bar:SetValueStep(1)
    local thumb=bar:GetThumbTexture()
    local face=CreateFrame('Frame',nil,bar,'BackdropTemplate')
    face:SetFrameLevel(bar:GetFrameLevel()+1)
    face:EnableMouse(false)
    face:SetBackdrop({bgFile=white,edgeFile=white,edgeSize=1})
    local state={face=face,hover=false,pressed=false,bevel={},grip={}}
    A.scrollbars[bar]=state
    local grain=face:CreateTexture(nil,'BACKGROUND',nil,1)
    grain:SetTexture('Interface\\DialogFrame\\UI-DialogBox-Background')
    grain:SetPoint('TOPLEFT',2,-2); grain:SetPoint('BOTTOMRIGHT',-2,2); state.grain=grain
    for _,side in ipairs({'top','left','bottom','right'}) do
        local t=face:CreateTexture(nil,'OVERLAY'); t:SetTexture(white)
        if side=='top' or side=='bottom' then
            local top=side=='top'
            t:SetPoint(top and 'TOPLEFT' or 'BOTTOMLEFT',0,0)
            t:SetPoint(top and 'TOPRIGHT' or 'BOTTOMRIGHT',0,0); t:SetHeight(1)
        else
            local left=side=='left'
            t:SetPoint(left and 'TOPLEFT' or 'TOPRIGHT',0,0)
            t:SetPoint(left and 'BOTTOMLEFT' or 'BOTTOMRIGHT',0,0); t:SetWidth(1)
        end
        state.bevel[side]=t
    end
    for i=-1,1 do
        local t=face:CreateTexture(nil,'OVERLAY'); t:SetTexture(white)
        t:SetSize(6,1); t:SetPoint('CENTER',0,i*3); table.insert(state.grip,t)
    end
    bar:HookScript('OnEnter',function() state.hover=true; A.StyleScrollBar(bar) end)
    bar:HookScript('OnLeave',function() state.hover=false; A.StyleScrollBar(bar) end)
    bar:HookScript('OnMouseDown',function() state.pressed=true; A.StyleScrollBar(bar) end)
    bar:HookScript('OnMouseUp',function() state.pressed=false; A.StyleScrollBar(bar) end)
    bar:HookScript('OnHide',function() state.hover=false; state.pressed=false; A.StyleScrollBar(bar) end)
    A.StyleScrollBar(bar)
end
function A.RegisterButton(b)
    local state={variant='normal',hover=false,pressed=false,lines={}}
    A.buttons[b]=state
    local grain=b:CreateTexture(nil,'BACKGROUND',nil,1)
    grain:SetTexture('Interface\\DialogFrame\\UI-DialogBox-Background')
    grain:SetPoint('TOPLEFT',4,-4); grain:SetPoint('BOTTOMRIGHT',-4,4)
    state.grain=grain
    for _,side in ipairs({'top','left','bottom','right'}) do
        local t=b:CreateTexture(nil,'BORDER')
        t:SetTexture(white)
        if side=='top' or side=='bottom' then
            local top=side=='top'
            t:SetPoint(top and 'TOPLEFT' or 'BOTTOMLEFT',3,top and -3 or 3)
            t:SetPoint(top and 'TOPRIGHT' or 'BOTTOMRIGHT',-3,top and -3 or 3)
            t:SetHeight(2)
        else
            local left=side=='left'
            t:SetPoint(left and 'TOPLEFT' or 'TOPRIGHT',left and 3 or -3,-3)
            t:SetPoint(left and 'BOTTOMLEFT' or 'BOTTOMRIGHT',left and 3 or -3,3)
            t:SetWidth(2)
        end
        state.lines[side]=t
    end
end
function A.SetButtonStyle(b,variant)
    A.buttons[b].variant=variant
end
function A.PaintButton(b)
    local state=A.buttons[b]
    local theme=A.db.appearance.theme
    local isClassic=theme=='classic'
    local selected=A.SelectionActive(b)
    local inset=selected or state.pressed
    local selector=A.roles[b]=='theme' or A.roles[b]=='language'
    local variant=selector and 'theme' or state.variant
    local p=palettes[theme][variant] or palettes[theme].normal
    local opacity=A.db.appearance.opacity
    local factor=inset and .42 or 1
    local glow=state.hover and .035 or 0
    b:SetBackdropColor(p.bg[1]*factor+glow,p.bg[2]*factor+glow,p.bg[3]*factor+glow,opacity)
    local edge=selected and (isClassic and {1,.76,.19} or {.28,.61,.76}) or p.edge
    local boost=state.hover and .12 or 0
    local edgeAlpha=isClassic and 1 or (selected and .9 or (state.hover and .75 or .4))
    b:SetBackdropBorderColor(math.min(1,edge[1]+boost),math.min(1,edge[2]+boost),math.min(1,edge[3]+boost),edgeAlpha)
    if selected then
        if isClassic then b.text:SetTextColor(1,.83,.25) else b.text:SetTextColor(.65,.90,1) end
    else b.text:SetTextColor(p.text[1],p.text[2],p.text[3]) end
    local yellow=isClassic and (selected or variant=='normal' or variant=='primary')
    A.ApplyFont(b.text,yellow and 0 or 2)
    local shift=inset and not selector
    b.text:ClearAllPoints(); b.text:SetPoint('CENTER',shift and 1 or 0,(shift and -1 or 0)+(state.textOffsetY or 0))
    state.grain:SetVertexColor(isClassic and .65 or .55,isClassic and .50 or .70,isClassic and .30 or .80)
    if variant=='tertiary' then state.grain:SetVertexColor(.55,.55,.55) end
    state.grain:SetAlpha((isClassic and .26 or .07)*opacity)
    state.grain:SetShown(isClassic)
    for side,t in pairs(state.lines) do
        t:SetShown(isClassic)
        local upper=side=='top' or side=='left'
        local light=upper~=inset
        t:SetVertexColor(light and edge[1] or 0,light and edge[2] or 0,light and edge[3] or 0)
        t:SetAlpha((light and (isClassic and .70 or .35) or .80)*opacity)
        if side=='top' or side=='bottom' then t:SetHeight(isClassic and 2 or 1)
        else t:SetWidth(isClassic and 2 or 1) end
    end
    state.inset=inset
end
function A.ButtonInteraction(b,event)
    local state=A.buttons[b]
    if not state then return end
    if event=='enter' then state.hover=true
    elseif event=='leave' then state.hover=false; state.pressed=false
    elseif event=='down' then state.pressed=true
    elseif event=='up' then state.pressed=false
    elseif event=='hide' then state.hover=false; state.pressed=false end
    A.PaintButton(b)
end
function A.Accent(font,role)
    A.accents[font]=role or 'title'
    A.ApplyFont(font,0)
    return font
end
function A.PaintBorder(f,hover)
    if A.roles[f]=='copyGlyph' then f:SetBackdropBorderColor(1,.82,0,1); return end
    if A.buttons[f] then A.buttons[f].hover=not not hover; A.PaintButton(f); return end
    local classicTheme=A.db.appearance.theme=='classic'
    local selected=A.SelectionActive(f)
    if selected then f:SetBackdropBorderColor(1,.8,.25,1)
    elseif classicTheme then
        f:SetBackdropBorderColor(hover and 1 or .65,hover and .85 or .65,hover and .4 or .65,1)
    else f:SetBackdropBorderColor(hover and .25 or .30,hover and .75 or .43,hover and 1 or .52,1) end
end
function A.PaintSkin(f,input)
    local role=A.roles[f]
    local c=A.db.appearance.theme=='classic'
    local isButton=role=='button' or role=='theme' or role=='language'
    f:SetBackdrop(c and (role=='window' and classicWindow or (isButton and classicButton or classic)) or modern)
    if A.buttons[f] then A.PaintButton(f); return end
    local opacity=A.db.appearance.opacity
    if c and not A.surfaceGrain[f] then
        local grain=f:CreateTexture(nil,'BACKGROUND',nil,1)
        grain:SetTexture('Interface\\DialogFrame\\UI-DialogBox-Background')
        local inset=role=='window' and 6 or 3
        grain:SetPoint('TOPLEFT',inset,-inset); grain:SetPoint('BOTTOMRIGHT',-inset,inset)
        A.surfaceGrain[f]=grain
    end
    local grain=A.surfaceGrain[f]
    if grain then
        grain:SetShown(c)
        grain:SetVertexColor(.45,.42,.36)
        grain:SetAlpha(.18*opacity)
    end
    if c then
        f:SetBackdropColor(isButton and .32 or .12,isButton and .025 or .12,isButton and .025 or .12,opacity)
    else
        f:SetBackdropColor(input and .025 or .045,input and .04 or .075,input and .055 or .10,opacity)
    end
    A.PaintBorder(f,false)
    if isButton then
        if c then f.text:SetTextColor(1,.82,0) else f.text:SetTextColor(.93,.96,1) end
    end
end
function A.ApplyTheme()
    for f,input in pairs(A.skins or {}) do A.PaintSkin(f,input) end
    local c=A.db.appearance.theme=='classic'
    for font in pairs(A.accents) do
        if c then font:SetTextColor(1,.82,0) else font:SetTextColor(.65,.85,1) end
    end
    for theme,b in pairs(A.themeButtons or {}) do
        local selected=theme==A.db.appearance.theme
        b.selected=selected
        A.SetText(b.text,theme=='classic' and 'Classic' or 'Modern')
    end
    for bar in pairs(A.scrollbars) do A.StyleScrollBar(bar) end
    for language,b in pairs(A.languageButtons or {}) do b.selected=language==A.db.language end
end
function A.SetTheme(theme)
    if theme~='classic' and theme~='modern' then return end
    A.db.appearance.theme=theme
    A.ApplyTheme()
end
