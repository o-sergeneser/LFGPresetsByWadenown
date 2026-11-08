A={}; UISpecialFrames={}; SlashCmdList={}; mockFrames={}; mockMetrics={measurements=0}; local focus
local methods={}
local nilFields={kind=true,owner=true,dragging=true,dockSide=true,Low=true,High=true,returnHeld=true}
local mt={__index=function(_,k) if nilFields[k] then return nil end; return methods[k] or function() end end}
function CreateFrame(_,name,parent,template)
 local f=setmetatable({scripts={},parent=parent,shown=true,text='',w=430,h=383},mt)
 table.insert(mockFrames,f)
 if template=='UIPanelScrollFrameTemplate' then
  f.ScrollBar=CreateFrame('Slider',nil,f)
  f.ScrollBar.thumb=CreateFrame('Texture',nil,f.ScrollBar)
  f.ScrollBar.scripts.OnValueChanged=function(_,value) f:SetVerticalScroll(value) end
 end
 if template=='PanelTabButtonTemplate' then
  f.Text=CreateFrame('Font',nil,f)
  parent.Tabs=rawget(parent,'Tabs') or {}; table.insert(parent.Tabs,f)
 end
 if name then _G[name]=f end
 return f
end
function methods:SetScript(k,v) self.scripts[k]=v end
function methods:HookScript(k,v)
 local old=self.scripts[k]; self.scripts[k]=function(...) if old then old(...) end; v(...) end
end
function methods:Show() local old=self.shown; self.shown=true; if not old and self.scripts.OnShow then self.scripts.OnShow(self) end end
function methods:Hide() local old=self.shown; self.shown=false; if old and self.scripts.OnHide then self.scripts.OnHide(self) end end
function methods:SetShown(b) if b then self:Show() else self:Hide() end end
function methods:IsShown() return self.shown end
methods.IsVisible=methods.IsShown
function methods:SetSize(w,h) self.w,self.h=w,h end
function methods:SetWidth(w) self.w=w end
function methods:SetHeight(h) self.h=h end
function methods:SetBackdrop(value) self.backdrop=value end
function methods:SetBackdropColor(r,g,b,a) self.background={r,g,b,a} end
function methods:GetWidth() return self.w end
function methods:GetHeight() return self.h end
function methods:GetThumbTexture() return rawget(self,'thumb') end
function methods:GetEffectiveScale() return 1 end
function methods:GetFrameLevel() return rawget(self,'level') or 1 end
function methods:SetFrameLevel(value) self.level=value end
function methods:SetFrameStrata(value) self.strata=value end
function methods:SetPropagateMouseClicks(value) self.propagateClicks=value end
function methods:SetPropagateMouseMotion(value) self.propagateMotion=value end
function methods:EnableMouse(value) self.mouseEnabled=value end
function methods:SetObeyStepOnDrag(value) self.obeyStep=value end
function methods:SetValueStep(value) self.valueStep=value end
function methods:SetMinMaxValues(min,max) self.minValue,self.maxValue=min,max end
function methods:GetMinMaxValues() return rawget(self,'minValue') or 0,rawget(self,'maxValue') or 0 end
function methods:SetValue(value)
 value=math.max(rawget(self,'minValue') or -math.huge,math.min(value,rawget(self,'maxValue') or math.huge))
 if rawget(self,'value')~=value then
  self.value=value
  if self.scripts.OnValueChanged then self.scripts.OnValueChanged(self,value) end
 end
end
function methods:GetValue() return rawget(self,'value') or 0 end
function methods:GetLeft() return 100 end
function methods:GetRight() return 500 end
function methods:GetTop() return 700 end
function methods:GetParent() return self.parent end
function methods:GetVerticalScroll() return rawget(self,'scrollOffset') or 0 end
function methods:SetVerticalScroll(value) self.scrollOffset=value end
function methods:StartMoving() self.moving=true end
function methods:StopMovingOrSizing() self.moving=false end
function methods:CreateFontString() return CreateFrame('Font',nil,self) end
methods.CreateTexture=methods.CreateFontString
function methods:SetText(t) self.text=t; if self.scripts.OnTextChanged then self.scripts.OnTextChanged(self) end end
function methods:GetText() return self.text end
function methods:GetFontString() return rawget(self,'Text') end
function methods:SetMaxLetters(value) self.maxLetters=value end
function methods:SetTextColor(r,g,b) self.color={r,g,b} end
function methods:GetFont() return rawget(self,'fontPath') or 'Fonts\\FRIZQT__.TTF',rawget(self,'fontSize') or 12,rawget(self,'fontFlags') or '' end
function methods:SetFont(path,size,flags) self.fontPath,self.fontSize,self.fontFlags=path,size,flags; return true end
function methods:NumLines() return 0 end
function methods:SetChecked(value) self.checked=not not value end
function methods:GetChecked() return self.checked or false end
function methods:GetStringWidth() mockMetrics.measurements=mockMetrics.measurements+1; return #self.text*7 end
function methods:GetStringHeight() mockMetrics.measurements=mockMetrics.measurements+1; return math.max(1,math.ceil(#self.text*7/self.w))*12 end
function methods:SetFocus() focus=self; if self.scripts.OnEditFocusGained then self.scripts.OnEditFocusGained(self) end end
function methods:ClearFocus() if focus==self then focus=nil end end
function methods:HasFocus() return focus==self end
function methods:HighlightText(a,b) self.selection={a,b}; self.all=a==nil end
UIParent=CreateFrame('Frame'); UIParent:SetSize(1920,1080)
GameTooltip=CreateFrame('Frame')
A.tooltip=GameTooltip
function InCombatLockdown() return combat or false end
function IsControlKeyDown() return true end
function strlenutf8(t) return utf8.len(t) end
C_Timer={queue={},After=function(_,fn) table.insert(C_Timer.queue,fn) end}
function flush() local q=C_Timer.queue; C_Timer.queue={}; for _,fn in ipairs(q) do fn() end end
function hooksecurefunc() end
function PanelTemplates_DeselectTab(tab) tab.selected=false end
