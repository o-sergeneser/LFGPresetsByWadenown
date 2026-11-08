local _,A=...
A.fontPath='Interface\\AddOns\\LFGPresetsByWadenown\\Media\\Fonts\\PTSansNarrow-Bold.ttf'
A.fontMetrics={}
function A.ApplyFont(object,adjustment,resetBase)
    local metrics=A.fontMetrics[object]
    if not metrics or resetBase then
        local _,size,flags=object:GetFont()
        metrics={size=size or 12,flags=flags or ''}
        A.fontMetrics[object]=metrics
    end
    local targetSize=metrics.size+(adjustment==nil and 2 or adjustment)
    local path,size,flags=object:GetFont()
    if path==A.fontPath and size==targetSize and (flags or '')==metrics.flags then return end
    local success=object:SetFont(A.fontPath,targetSize,metrics.flags)
    if success==false and not A.fontWarningShown then
        A.fontWarningShown=true
        print(A.L('LFG Presets By Wadenown: PT Sans Narrow Bold could not be loaded. Using the existing font; restart WoW and try again.'))
    end
end
function A.GetTooltip()
    if not A.tooltip then
        A.tooltip=CreateFrame('GameTooltip','LFGPresetsByWadenownTooltip',UIParent,'GameTooltipTemplate')
    end
    return A.tooltip
end
function A.ShowTooltip(reference,owner)
    local tooltip=A.GetTooltip()
    local size
    if reference then
        local _,referenceSize=reference:GetFont()
        size=referenceSize
    end
    if not size then
        local base=_G.GameFontHighlightSmall
        local baseSize=base and select(2,base:GetFont()) or 10
        size=baseSize+2
    end
    local scale=owner and owner:GetEffectiveScale()/UIParent:GetEffectiveScale() or 1
    tooltip:SetScale(scale); tooltip:SetClampedToScreen(true)
    local maxWidth=math.max(80,math.min(360,UIParent:GetWidth()/scale-24))
    local function apply(font,wrap)
        if not font then return end
        local _,current=font:GetFont()
        local base=A.fontMetrics[font] and A.fontMetrics[font].size or current or 12
        A.ApplyFont(font,size-base)
        if wrap then
            font:SetWordWrap(true); font:SetNonSpaceWrap(true)
            font:SetMaxLines(0); font:SetHeight(0); font:SetWidth(0)
            font:SetWidth(math.min(maxWidth,font:GetStringWidth()))
        end
    end
    for i=1,tooltip:NumLines() do
        local left=_G['LFGPresetsByWadenownTooltipTextLeft'..i]
        local right=_G['LFGPresetsByWadenownTooltipTextRight'..i]
        apply(left,true); apply(right,false)
    end
    tooltip:Show()
end
