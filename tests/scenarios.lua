local eventFrame
for _,frame in ipairs(mockFrames) do if frame.scripts.OnEvent then eventFrame=frame end end
assert(eventFrame)
A.db={}; A.panel=CreateFrame('Frame'); A.editor=nil; A.uiReady=false
LFGListApplicationDialog=CreateFrame('Frame')
A.Update(); eventFrame.scripts.OnEvent(eventFrame,'PLAYER_LOGIN')
assert(not LFGListApplicationDialog.scripts.OnHide)
assert(A.Initialize()); A.BuildUI(); A.BuildOptions()
A.uiReady=true
assert(A.db.appearance.theme=='classic')
for kind in pairs(A.names) do assert(#A.db.presets[kind]==5) end
local e=A.editor
local function open(kind,title,body)
 A.editor:Hide()
 A.Activate(kind); A.Store(kind,1,title,body); A.RefreshCards(); A.panel:Show(); A.OpenEditor(1)
end
for _,s in ipairs({{'a','','title'},{'','b','body'},{'a','b','title'},{'','','title'}}) do
 open('dungeon',s[1],s[2]); assert((s[3]=='title' and e.titleBox or e.bodyBox):HasFocus())
end
for _,body in ipairs({'note',''}) do
 open('application','',body); assert(e.bodyBox:HasFocus()); assert(not e.titleHolder:IsShown()); assert(not A.rows[1].title:IsShown())
end
for _,which in ipairs({'titleBox','bodyBox'}) do
 open('raid','old','old body'); e.titleBox:SetText('Türkçe'); e.bodyBox:SetText('full\nnew description')
 local b=e[which]; b:SetFocus(); b:HighlightText(1,2); b.scripts.OnKeyDown(b,'C')
 assert(e:IsShown()); assert(A.Get('raid',1).title=='old'); flush()
 assert(not e:IsShown()); assert(A.Get('raid',1).title=='Türkçe'); assert(A.Get('raid',1).description=='full new description')
 A.Initialize(); assert(A.Get('raid',1).title=='Türkçe')
end
open('application','',''); e.bodyBox.scripts.OnKeyDown(e.bodyBox,'C'); flush(); assert(not e:IsShown())
open('dungeon','keep','body'); e.titleBox:SetText('discard'); e:Hide(); assert(A.Get('dungeon',1).title=='keep')
open('dungeon','keep','body'); e.titleBox:SetText('discard'); e.titleBox.scripts.OnKeyDown(e.titleBox,'C'); e:Hide(); flush(); assert(A.Get('dungeon',1).title=='keep')
open('dungeon','keep','body'); e.titleBox:SetText('saved'); A.SaveEditor(); assert(A.Get('dungeon',1).title=='saved')
LFGListFrame=CreateFrame('Frame'); LFGListFrame.EntryCreation=CreateFrame('Frame'); local entry=LFGListFrame.EntryCreation
LFGListApplicationDialog=CreateFrame('Frame'); LFGListApplicationDialog:Hide()
for cat,expected in pairs({[2]='dungeon',[3]='raid',[4]='none'}) do
 entry.selectedCategory=cat; A.Update(); assert(A.kind==(expected~='none' and expected or nil))
end
LFGListApplicationDialog:Show(); A.Update(); assert(A.kind=='application')
combat=true; A.Update(); assert(not A.panel:IsShown()); combat=false
A.ToggleLock('raid'); assert(A.db.settings.raid.locked); assert(not A.db.settings.dungeon.locked)
A.db.settings.raid.position={x=.3,y=.8}; A.ResetPosition('dungeon'); assert(A.db.settings.raid.position.x==.3)
A.Store('raid',1,'retain','retain'); A.ResetPresets('application'); assert(A.Get('raid',1).title=='retain')
for i=1,5 do assert(A.Get('application',i).note=='') end
A.db.settings.application.automatic=false; A.Update(); assert(not A.panels.application:IsShown())
A.OpenOptions(); A.preview.application=true; A.preview.raid=true; A.Update()
assert(A.panels.application:IsShown() and A.panels.raid:IsShown())
A.options:Hide(); assert(not next(A.preview)); assert(not A.panels.application:IsShown())
A.Activate('raid'); A.OpenEditor(1)
A.editor.dragHeader.scripts.OnDragStart(); assert(not A.editor.dragging)
A.ToggleLock('raid'); A.editor.dragHeader.scripts.OnDragStart(); assert(A.editor.dragging=='raid')
assert(A.editor.scripts.OnUpdate); A.editor.scripts.OnUpdate(); A.editor.dragHeader.scripts.OnDragStop(); assert(not A.editor.scripts.OnUpdate)
print('PASS: phase 2 independent lock/position/reset, preview lifecycle, linked drag lifecycle')
local master=CreateFrame('Frame'); master:SetSize(344,414)
local follower=CreateFrame('Frame'); follower:SetSize(430,383)
local mx,my,ratio=1450,800,1
master.GetLeft=function() return mx/ratio end
master.GetTop=function() return my/ratio end
master.GetEffectiveScale=function() return ratio end
follower.GetEffectiveScale=function() return ratio end
local fx,fy
follower.SetPoint=function(_,_,_,_,x,y) fx,fy=x*ratio,y*ratio end
A.Dock(follower,master); assert(master.dockSide=='left'); assert(fx>=0 and fx+430<=1920)
mx=30; A.Dock(follower,master); assert(master.dockSide=='right'); assert(fx>=0 and fx+430<=1920)
ratio=1.4; mx=1400; my=100; master.dockSide='right'
A.Dock(follower,master); assert(master.dockSide=='left'); assert(fx>=0 and fx+430*ratio<=1920)
assert(fy>=383*ratio and fy<=1080)
print('PASS: docking flips at both screen edges and clamps scaled windows vertically')
for _,kind in ipairs({'application','dungeon','raid'}) do
 A.OpenOptions(); A.preview[kind]=true; A.Update()
 A.Activate(kind); A.OpenEditor(1); A.SetLocked(kind,false)
 local panel=A.panels[kind]; local option=A.optionRows[kind].lock
 panel.lock.scripts.OnClick()
 assert(A.db.settings[kind].locked and panel.lock.locked and A.editor.lock.locked)
 assert(option.locked and option.text:GetText()=='Unlock Panel')
 option.scripts.OnClick()
 assert(not A.db.settings[kind].locked and not panel.lock.locked and not A.editor.lock.locked)
 assert(not option.locked and option.text:GetText()=='Lock Panel')
 option.scripts.OnClick(); A.editor.lock.scripts.OnClick()
 assert(not panel.lock.locked and option.text:GetText()=='Lock Panel')
 A.ResetPosition(kind)
 local p=A.db.settings[kind].position
 assert(math.abs(p.x*1920+panel:GetWidth()/2-(1920/2+200))<.001)
 assert(math.abs(p.y*1080-panel:GetHeight()/2-1080/2)<.001)
 A.options:Hide()
end
A.OpenOptions(); A.options.dragHeader.scripts.OnDragStart(); assert(A.options.moving)
A.options.dragHeader.scripts.OnDragStop(); assert(not A.options.moving)
A.options.dragHeader.scripts.OnDragStart(); A.options:Hide(); assert(not A.options.moving)
print('PASS: Options header drag/close, three-way lock button synchronization, center +200 position reset')
for _,kind in ipairs({'application','dungeon','raid'}) do
 A.OpenOptions(); A.preview[kind]=true; A.Update()
 local panel=A.panels[kind]; local row=A.optionRows[kind]
 panel.attach:SetChecked(true); panel.attach.scripts.OnClick()
 assert(A.db.settings[kind].attached and A.db.settings[kind].locked)
 assert(row.attach:GetChecked() and panel.lock.locked)
 row.attach:SetChecked(false); row.attach.scripts.OnClick()
 assert(not panel.attach:GetChecked() and not panel.lock.locked)
 row.attach:SetChecked(true); row.attach.scripts.OnClick()
 panel.lock.scripts.OnClick()
 assert(not row.attach:GetChecked() and not panel.attach:GetChecked())
 assert(not A.db.settings[kind].locked)
 A.SetAttached(kind,true); A.ResetPosition(kind)
 assert(not A.db.settings[kind].attached)
 A.options:Hide()
end
print('PASS: per-type Attach to LFG callbacks, checkbox synchronization, automatic lock, unlock detachment, reset detachment')
local savedTitle=A.Get('raid',1).title
A.Activate('raid'); A.OpenEditor(1); A.editor.titleBox:SetText('unsaved theme draft')
local session=A.editor.session
A.themeButtons.modern.scripts.OnClick()
assert(A.db.appearance.theme=='modern' and A.themeButtons.modern.selected and not A.themeButtons.classic.selected)
assert(A.panels.raid.backdrop.edgeSize==1)
assert(A.editor.session==session and A.editor.titleBox:GetText()=='unsaved theme draft' and A.editor.titleBox:HasFocus())
assert(A.Get('raid',1).title==savedTitle)
A.Initialize(); assert(A.db.appearance.theme=='modern')
A.themeButtons.classic.scripts.OnClick()
assert(A.db.appearance.theme=='classic' and A.themeButtons.classic.selected and not A.themeButtons.modern.selected)
assert(A.panels.raid.backdrop.edgeFile=='Interface\\DialogFrame\\UI-DialogBox-Border')
assert(A.optionRows.raid.lock.backdrop.bgFile=='Interface\\Buttons\\WHITE8X8')
A.db.appearance.opacity=.55; A.ApplyAppearance(); assert(A.editor.background[4]==.55)
assert(A.editor.session==session and A.editor.titleBox:GetText()=='unsaved theme draft')
print('PASS: default Classic, theme buttons, persistence, existing drafts/focus preserved, Classic assets, background opacity')
local pinned=CreateFrame('Frame'); local native=CreateFrame('Frame')
local nativeX,nativeY=100,600
pinned.GetEffectiveScale=function() return 1.25 end
pinned.GetLeft=function() return 560/1.25 end
pinned.GetTop=function() return 720/1.25 end
native.GetLeft=function() return nativeX end
native.GetTop=function() return nativeY end
local relative,dx,dy
pinned.SetPoint=function(_,_,anchor,_,x,y) relative,dx,dy=anchor,x,y end
A.db.settings.raid.attachOffset=nil
A.PlaceAttached(pinned,native,'raid')
assert(relative==native and dx==460/1.25 and dy==120/1.25)
assert(A.db.settings.raid.attachOffset.x==460 and A.db.settings.raid.attachOffset.y==120)
nativeX,nativeY=300,500
A.PlaceAttached(pinned,native,'raid')
assert(relative==native and dx==460/1.25 and dy==120/1.25)
A.Initialize(); assert(A.db.settings.raid.attachOffset.x==460)
print('PASS: attachment preserves current scaled offset and reuses it after native movement/reinitialization')
A.Activate('dungeon'); local list=A.panel; list:Show(); A.OpenEditor(1)
A.editor.titleBox:SetText('draft survives native dragging')
A.db.settings.dungeon.attached=true
local movingX=200; local placements=0; local detailX
local oldLeft,oldTop,oldPoint=list.GetLeft,list.GetTop,A.editor.SetPoint
list.GetLeft=function() return movingX end
list.GetTop=function() return 850 end
A.editor.SetPoint=function(_,_,anchor,_,x)
 placements=placements+1
 detailX=anchor==list and movingX+x or x
end
list.dockSide='right'; A.WatchDock()
A.dockWatcher.scripts.OnUpdate(); assert(list.dockSide=='right' and detailX>movingX)
local count=placements; A.dockWatcher.scripts.OnUpdate(); assert(placements==count)
movingX=1300; A.dockWatcher.scripts.OnUpdate()
assert(list.dockSide=='left' and detailX+A.editor:GetWidth()<=movingX)
assert(detailX>=0 and detailX+A.editor:GetWidth()<=1920)
movingX=20; A.dockWatcher.scripts.OnUpdate(); assert(list.dockSide=='right')
assert(A.editor.titleBox:GetText()=='draft survives native dragging' and A.editor.titleBox:HasFocus())
A.editor:Hide(); assert(not A.dockWatcher.scripts.OnUpdate and not A.dockWatching)
list.GetLeft,list.GetTop,A.editor.SetPoint=oldLeft,oldTop,oldPoint
print('PASS: native movement flips attached detail live without overlap, skips unchanged geometry, preserves draft/focus, stops on close')
A.db.settings.application.automatic=true; A.previewHidden={}; A.Update()
A.Activate('application'); A.panel:Show(); A.OpenEditor(1)
assert(A.editor.attachList:GetChecked() and A.EditorFollows('application'))
A.SetAttached('application',true); assert(A.dockWatching)
A.editor.bodyBox:SetText('keep detached draft')
A.editor.attachList:SetChecked(false); A.editor.attachList.scripts.OnClick()
assert(not A.EditorFollows('application') and not A.dockWatching)
assert(A.db.settings.application.editorPosition)
assert(A.db.settings.application.locked and A.db.settings.application.attached)
local lockedListPosition=A.db.settings.application.position
A.editor.dragHeader.scripts.OnDragStart()
assert(A.editor.dragging=='application' and A.editor.moving)
A.editor.dragHeader.scripts.OnDragStop()
assert(not A.editor.dragging and not A.editor.moving)
assert(A.db.settings.application.locked and A.db.settings.application.attached)
assert(A.db.settings.application.position==lockedListPosition)
local originalDock=A.Dock; local dockCalls=0
A.Dock=function(...) dockCalls=dockCalls+1; return originalDock(...) end
A.Update(); assert(dockCalls==0 and A.editor:IsShown())
A.SetLocked('application',false)
A.panels.application.dragHeader.scripts.OnDragStart()
A.panels.application.scripts.OnUpdate()
A.panels.application.dragHeader.scripts.OnDragStop()
assert(dockCalls==0)
local listPosition=A.db.settings.application.position
A.editor.dragHeader.scripts.OnDragStart(); A.editor.scripts.OnUpdate(); A.editor.dragHeader.scripts.OnDragStop()
assert(dockCalls==0 and A.db.settings.application.position==listPosition)
A.Initialize(); assert(not A.EditorFollows('application'))
A.editor.attachList:SetChecked(true); A.editor.attachList.scripts.OnClick()
assert(A.EditorFollows('application') and dockCalls==1)
assert(A.editor.bodyBox:GetText()=='keep detached draft')
A.Dock=originalDock
print('PASS: Attach to List default, detachment stops native/list following, independent drag/persistence, reattach preserves draft')
for _,kind in ipairs({'application','dungeon','raid'}) do
 A.editor:Hide(); A.Activate(kind); A.panel:Show()
 local original=A.Get(kind,1).note or A.Get(kind,1).description
 A.OpenEditor(1); assert(A.editor:IsShown())
 A.editor.bodyBox:SetText('unsaved toggle draft')
 A.OpenEditor(1); assert(not A.editor:IsShown())
 assert((A.Get(kind,1).note or A.Get(kind,1).description)==original)
 A.OpenEditor(1); assert(A.editor:IsShown())
 A.OpenEditor(2); assert(A.editor:IsShown() and A.editor.index==2)
end
print('PASS: same preset toggles editor closed without saving; repeated click reopens; another preset switches editor')
for _,kind in ipairs({'application','dungeon','raid'}) do
 A.editor:Hide(); A.Activate(kind); A.RefreshCards(); A.panel:Show()
 local panel=A.panel
 assert(#A.db.presets[kind]==5 and panel:GetHeight()==448 and not panel.scroll.ScrollBar:IsShown())
 panel.addSlot.scripts.OnClick()
 assert(A.editor:IsShown() and A.editor.isNew and #A.db.presets[kind]==5)
 assert(A.editor.bodyBox:GetText()=='' and A.editor.titleBox:GetText()=='')
 assert(A.editor.titleHolder:IsShown()==(kind~='application'))
 A.editor.bodyBox:SetText('cancelled extra slot'); A.editor:Hide()
 assert(#A.db.presets[kind]==5)
 local previousID=A.db.nextSlotID[kind]
 panel.addSlot.scripts.OnClick(); A.editor.titleBox:SetText('six'); A.editor.bodyBox:SetText('six body'); A.SaveEditor()
 assert(#A.db.presets[kind]==6 and #panel.rows==6 and panel:GetHeight()==484)
 assert(panel.scroll:GetHeight()==366 and panel.scroll.ScrollBar:IsShown())
 assert(panel.scroll:GetVerticalScroll()>0 and A.Get(kind,6).id==kind..'-'..previousID)
 assert((A.Get(kind,6).note or A.Get(kind,6).description)=='six body')
 for i=7,20 do
  panel.addSlot.scripts.OnClick(); A.editor.bodyBox:SetText('slot '..i); A.SaveEditor()
 end
 assert(#A.db.presets[kind]==20 and #panel.rows==20 and panel:GetHeight()==484)
 local ids={}; for _,p in ipairs(A.db.presets[kind]) do assert(not ids[p.id]); ids[p.id]=true end
 A.Initialize(); assert(#A.db.presets[kind]==20 and (A.Get(kind,20).note or A.Get(kind,20).description)=='slot 20')
 panel.rows[20].action.scripts.OnClick(); assert(A.editor.index==20 and not A.editor.isNew)
 A.editor.bodyBox:SetText('updated 20'); A.SaveEditor(); assert(#A.db.presets[kind]==20)
 assert((A.Get(kind,20).note or A.Get(kind,20).description)=='updated 20')
 panel.addSlot.scripts.OnClick(); A.editor.bodyBox:SetFocus()
 A.editor.bodyBox.scripts.OnKeyDown(A.editor.bodyBox,'C'); A.editor:Hide(); flush()
 assert(#A.db.presets[kind]==20)
 A.ResetPresets(kind); assert(#A.db.presets[kind]==20)
 for i=1,20 do assert((A.Get(kind,i).note or A.Get(kind,i).description)=='') end
end
print('PASS: + Slot drafts/cancellation, 6–20 dynamic slots, 5/5.5-card viewport, scrolling, stable IDs, reload, editing/resetting added slots')
A.editor:Hide(); A.Activate('dungeon'); A.OpenEditor(1)
assert(A.editor.titleBox:GetParent()==A.editor.titleHolder)
assert(A.editor.titleBox.maxLetters==31 and A.editor.bodyBox.maxLetters==255)
A.editor.titleBox:SetText(string.rep('a',31)); assert(A.editor.counter.color[1]==1 and A.editor.counter.color[2]==.2)
A.editor.titleBox:SetText('short'); assert(A.editor.counter.color[1]==.6)
A.editor.bodyBox:SetText(string.rep('b',255)); assert(A.editor.counter.color[1]==1)
A.editor:Hide(); A.Activate('application'); A.OpenEditor(1)
assert(A.editor.bodyBox.maxLetters==63)
A.editor.bodyBox:SetText(string.rep('ç',63)); assert(A.editor.counter.color[1]==1)
A.editor.bodyBox:SetText('short'); assert(A.editor.counter.color[1]==.6)
print('PASS: title without scroll frame, native 31/255/63 character limits configured, red counter at exact limit including UTF-8')
assert(A.options.heading:GetText()=='LFG Presets By Wadenown - Options')
A.SetTheme('classic')
local done=A.options.done; local lock=A.optionRows.dungeon.lock
local reset=A.optionRows.dungeon.resetPosition; local clear=A.optionRows.dungeon.resetPresets
assert(A.buttons[done].variant=='primary' and A.buttons[lock].variant=='secondary')
assert(A.buttons[reset].variant=='tertiary' and A.buttons[clear].variant=='destructive')
assert(done.background[1]>lock.background[1] and clear.background[1]>clear.background[2])
assert(lock.background[1]>lock.background[2] and reset.background[3]>reset.background[1])
assert(A.themeButtons.classic.text:GetText()=='Classic' and A.themeButtons.modern.text:GetText()=='Modern')
assert(A.buttons[A.themeButtons.classic].inset and not A.buttons[A.themeButtons.modern].inset)
local initial=done.background[1]
done.scripts.OnEnter(); assert(done.background[1]>initial)
done.scripts.OnMouseDown(); assert(A.buttons[done].inset and done.background[1]<initial)
done.scripts.OnMouseUp(); assert(not A.buttons[done].inset)
done.scripts.OnMouseDown(); done.scripts.OnLeave(); assert(not A.buttons[done].inset)
A.themeButtons.classic.scripts.OnMouseDown(); A.themeButtons.classic.scripts.OnMouseUp()
assert(A.buttons[A.themeButtons.classic].inset)
A.SetTheme('modern')
assert(A.buttons[A.themeButtons.modern].inset and not A.buttons[A.themeButtons.classic].inset)
assert(done.background[3]>done.background[1] and done:GetWidth()==130 and done:GetHeight()==30)
A.themeButtons.modern.scripts.OnEnter(); A.themeButtons.modern.scripts.OnLeave()
assert(A.buttons[A.themeButtons.modern].inset)
print('PASS: heading separator, shared button variants, Classic/Modern palettes, hover/press/release, persistent inset theme selection without arrows')
for _,theme in ipairs({'classic','modern'}) do
 A.db.appearance.opacity=1; A.SetTheme(theme)
 for _,frame in ipairs({A.options,A.panels.dungeon,A.editor,A.editor.bodyHolder}) do
  assert(frame.backdrop.bgFile=='Interface\\Buttons\\WHITE8X8' and frame.background[4]==1)
  if theme=='classic' then assert(A.surfaceGrain[frame]:IsShown())
  else assert(not A.surfaceGrain[frame]:IsShown()) end
 end
 A.db.appearance.opacity=.4; A.ApplyAppearance(); assert(A.options.background[4]==.4)
end
print('PASS: opaque base at 100 percent in both themes, separate Classic grain layer, opacity slider preserved')
for _,theme in ipairs({'classic','modern'}) do
 A.SetTheme(theme)
 A.Activate('dungeon')
 local index=A.Append('dungeon','restored extra','body')
 assert(not A.rows[index])
 A.RefreshCards()
 local row=A.rows[index]
 assert(row.backdrop.edgeSize==(theme=='classic' and 12 or 1))
 assert(row.action.backdrop.edgeSize==(theme=='classic' and 12 or 1))
 assert(row.title.color[1]==(theme=='classic' and 1 or .65))
 assert(row.background[4]==A.db.appearance.opacity)
 A.SetTheme(theme=='classic' and 'modern' or 'classic')
 assert(row.backdrop.edgeSize==(theme=='classic' and 1 or 12))
end
print('PASS: dynamically restored extra cards inherit current theme, accent, opacity and subsequent theme switches')
local scroller=A.panels.dungeon
scroller.scroll:SetHeight(366); scroller.scroll.ScrollBar:SetHeight(334)
scroller.content:SetHeight(6*67-5); A.SizeListThumb(scroller)
local largeThumb=scroller.scroll.ScrollBar:GetThumbTexture():GetHeight()
assert(math.abs(largeThumb-334*366/397)<.001 and largeThumb>300)
scroller.content:SetHeight(20*67-5); A.SizeListThumb(scroller)
local smallThumb=scroller.scroll.ScrollBar:GetThumbTexture():GetHeight()
assert(smallThumb<largeThumb and smallThumb>18)
scroller.content:SetHeight(1000*67-5); A.SizeListThumb(scroller)
assert(scroller.scroll.ScrollBar:GetThumbTexture():GetHeight()==18)
print('PASS: list scrollbar thumb reflects visible fraction, shrinks with more presets, retains usable minimum')
for _,theme in ipairs({'classic','modern'}) do
 A.SetTheme(theme); A.editor:Hide(); A.Activate('raid'); A.panel:Show(); A.OpenEditor(1)
 local list=A.db.presets.raid; local count=#list; local target=list[1].id; local survivor=list[2].id
 A.editor.bodyBox:SetText('unsaved delete draft')
 A.editor.delete.scripts.OnClick(); assert(A.deleteDialog:IsShown() and #list==count)
 assert(A.buttons[A.deleteDialog.yes].variant=='tertiary' and A.buttons[A.deleteDialog.no].variant=='primary')
 A.SaveEditor(); assert(#list==count and A.editor:IsShown())
 A.deleteDialog.no.scripts.OnClick()
 assert(#list==count and A.editor.bodyBox:GetText()=='unsaved delete draft')
 A.editor.delete.scripts.OnClick(); A.deleteDialog.yes.scripts.OnClick()
 assert(#list==count-1 and list[1].id==survivor and list[1].id~=target)
 assert(not A.editor:IsShown() and not A.deleteDialog:IsShown())
 A.Initialize(); assert(#A.db.presets.raid==count-1)
end
while #A.db.presets.raid>0 do A.DeletePreset('raid',A.db.presets.raid[1].id) end
A.Initialize(); assert(#A.db.presets.raid==0)
A.Activate('raid'); A.RefreshCards(); assert(A.panel:GetHeight()==448 and not A.panel.scroll.ScrollBar:IsShown())
for _,row in ipairs(A.rows) do assert(not row:IsShown()) end
A.panel:Show(); A.panel.addSlot.scripts.OnClick(); assert(not A.editor.delete:IsShown())
A.editor.bodyBox:SetText('fresh after delete all'); A.SaveEditor(); assert(#A.db.presets.raid==1)
local id=A.db.presets.raid[1].id
A.Initialize(); assert(#A.db.presets.raid==1 and A.db.presets.raid[1].id==id)
print('PASS: themed delete confirmation, No preserves draft, Yes removes correct stable ID, no deleted slots return, zero-slot recovery')
A.Activate('dungeon'); A.RefreshCards()
local bar=A.panel.scroll.ScrollBar; local chrome=A.scrollbars[bar]
assert(not bar.mouseEnabled and chrome.face.mouseEnabled and chrome.track.mouseEnabled and bar.obeyStep==false)
local lo,hi=bar:GetMinMaxValues(); assert(lo==0 and hi>0)
bar:SetValue(hi); assert(A.panel.scroll:GetVerticalScroll()==hi)
bar:SetValue(0); assert(A.panel.scroll:GetVerticalScroll()==0)
A.SetTheme('classic'); local classicFace=chrome.face.background[1]
A.SetTheme('modern'); assert(chrome.face.background[1]~=classicFace)
bar.scripts.OnEnter(); assert(chrome.hover)
bar.scripts.OnMouseDown(); assert(chrome.pressed)
bar.scripts.OnMouseUp(); assert(not chrome.pressed)
bar.scripts.OnHide(); assert(not chrome.hover)
print('PASS: custom thumb/track mouse input, native Slider values scroll content, themed raised/pressed feedback')
local mouseY,held=1000,true
GetCursorPosition=function() return 0,mouseY end
IsMouseButtonDown=function() return held end
local originalScale=bar.GetEffectiveScale
bar.GetEffectiveScale=function() return 1.25 end
bar:SetHeight(334); bar:GetThumbTexture():SetHeight(80)
bar:SetMinMaxValues(0,1000); bar:SetValue(200); A.LayoutListThumb(A.panel)
local face=chrome.face
face.scripts.OnMouseDown(face,'LeftButton')
face.scripts.OnUpdate(); assert(bar:GetValue()==200)
mouseY=950; face.scripts.OnUpdate()
assert(math.abs(bar:GetValue()-(200+50/1.25*1000/254))<.001)
mouseY=1025; face.scripts.OnUpdate(); assert(bar:GetValue()<200)
mouseY=1000-254*1.25; face.scripts.OnUpdate(); assert(bar:GetValue()==1000)
held=false; face.scripts.OnUpdate(); assert(not face.scripts.OnUpdate and not chrome.pressed)
bar:SetValue(500); face.scripts.OnMouseWheel(face,1); assert(bar:GetValue()==460)
chrome.track.scripts.OnMouseWheel(chrome.track,-1); assert(bar:GetValue()==500)
held=true; mouseY=1000; face.scripts.OnMouseDown(face,'LeftButton')
face.scripts.OnHide(); assert(not face.scripts.OnUpdate)
bar.GetEffectiveScale=originalScale
print('PASS: actual drag callbacks retain grab point, down/up directions, linear scaled mouse distance, range endpoints, wheel step, release/hide cleanup')
for _,kind in ipairs({'application','dungeon','raid'}) do
 A.OpenOptions(); A.preview[kind]=true; A.Update()
 local panel=A.panels[kind]; local option=A.optionRows[kind].auto
 local other=kind=='raid' and 'dungeon' or 'raid'
 local otherValue=A.db.settings[other].automatic
 panel.autoCheck:SetChecked(false); panel.autoCheck.scripts.OnClick()
 assert(not A.db.settings[kind].automatic and not option:GetChecked())
 assert(panel:IsShown())
 option:SetChecked(true); option.scripts.OnClick()
 assert(A.db.settings[kind].automatic and panel.autoCheck:GetChecked())
 assert(A.db.settings[other].automatic==otherValue)
 A.Initialize(); assert(A.db.settings[kind].automatic)
 A.options:Hide()
end
print('PASS: panel Automatically Open synchronizes both ways with Options for all types, preserves preview and other types, persists')
A.options:Hide(); A.preview={}; A.previewHidden={}
for _,kind in ipairs({'application','dungeon','raid'}) do
 if kind=='application' then LFGListApplicationDialog:Show()
 else LFGListApplicationDialog:Hide(); LFGListFrame.EntryCreation:Show(); LFGListFrame.EntryCreation.selectedCategory=kind=='dungeon' and 2 or 3 end
 A.SetAutomatic(kind,true); A.Update(); A.Activate(kind)
 local panel=A.panel; assert(panel:IsShown())
 A.OpenEditor(1); A.editor.bodyBox:SetText('keep this draft')
 panel.autoCheck:SetChecked(false); panel.autoCheck.scripts.OnClick()
 assert(panel:IsShown() and A.editor:IsShown() and not A.optionRows[kind].auto:GetChecked())
 A.Update(); assert(panel:IsShown() and A.editor.bodyBox:GetText()=='keep this draft')
 panel:Hide(); A.Update(); assert(not panel:IsShown())
 A.SetAutomatic(kind,true); assert(panel:IsShown())
 A.optionRows[kind].auto:SetChecked(false); A.optionRows[kind].auto.scripts.OnClick()
 assert(panel:IsShown())
 if kind=='application' then LFGListApplicationDialog:Hide() else LFGListFrame.EntryCreation:Hide() end
 A.Update(); assert(not panel:IsShown())
 if kind=='application' then LFGListApplicationDialog:Show() else LFGListFrame.EntryCreation:Show() end
 A.Update(); assert(not panel:IsShown())
end
print('PASS: unchecking auto from panel or Options retains open panel/draft, closing ends retention, next native opening stays disabled')
assert(A.db.persistApplicationNote==true and #A.persistChecks==4)
local currentNote='my current note'; local clears,roles,shows=0,0,0
C_LFGList={
 GetSearchResultInfo=function(id) return {activityIDs={id}} end,
 ClearApplicationTextFields=function() clears=clears+1; currentNote='' end,
}
LFGListApplicationDialog_UpdateRoles=function() roles=roles+1 end
StaticPopupSpecial_Show=function() shows=shows+1 end
assert(load(A.testNativeShowSource))()
A.InstallNotePersistence(); local wrapper=LFGListApplicationDialog_Show
A.InstallNotePersistence(); assert(wrapper==LFGListApplicationDialog_Show)
local dialog={activityID=1}
LFGListApplicationDialog_Show(dialog,2)
assert(currentNote=='my current note' and clears==0 and roles==1 and shows==1 and dialog.resultID==2 and dialog.activityID==2)
currentNote='manually revised note'; LFGListApplicationDialog_Show(dialog,99)
assert(currentNote=='manually revised note' and clears==0)
for _,kind in ipairs({'application','dungeon','raid'}) do
 local check=A.panels[kind].persistNote
 check:SetChecked(false); check.scripts.OnClick()
 assert(not A.db.persistApplicationNote)
 for _,other in ipairs(A.persistChecks) do assert(not other:GetChecked()) end
 A.options.persistNote:SetChecked(true); A.options.persistNote.scripts.OnClick()
 for _,other in ipairs(A.persistChecks) do assert(other:GetChecked()) end
end
A.SetPersistNote(false); A.Initialize(); assert(A.db.persistApplicationNote==false)
LFGListApplicationDialog_Show(dialog,100)
assert(clears==1 and currentNote=='' and roles==3 and shows==3)
currentNote='same activity native behavior'; LFGListApplicationDialog_Show(dialog,100)
assert(currentNote=='same activity native behavior' and clears==1)
local previous=LFGListApplicationDialog_Show; local thirdParty=0
LFGListApplicationDialog_Show=function(...) thirdParty=thirdParty+1; return previous(...) end
A.SetPersistNote(true); LFGListApplicationDialog_Show(dialog,101)
assert(thirdParty==1 and currentNote=='same activity native behavior' and clears==1)
print('PASS: shared persistence default/sync across four checkboxes, exact pinned native Show flow, activity changes, manual edits, toggle off/native behavior, saved preference, wrapper coexistence')
A.editor:Hide(); A.preview={}; A.previewHidden={}
LFGListApplicationDialog:SetFrameLevel(100); LFGListApplicationDialog:Show()
A.SetAutomatic('application',true); A.Update(); A.Activate('application'); A.OpenEditor(1)
assert(A.panel.strata=='FULLSCREEN_DIALOG' and A.editor.strata=='FULLSCREEN_DIALOG')
assert(A.panel:GetFrameLevel()>LFGListApplicationDialog:GetFrameLevel())
assert(A.editor:GetFrameLevel()>A.panel:GetFrameLevel())
for _,f in ipairs({A.options,A.editor,A.panel,A.deleteDialog,A.editor.bodyHolder,A.editor.bodyBox,A.editor.bodyBox:GetParent()}) do
 assert(f.mouseEnabled and f.propagateClicks==false and f.propagateMotion==false)
end
A.editor.bodyHolder.scripts.OnMouseDown(); assert(A.editor.bodyBox:HasFocus())
A.editor.bodyBox:ClearFocus(); A.editor.bodyBox:GetParent().scripts.OnMouseDown()
assert(A.editor.bodyBox:HasFocus())
A.editor.delete.scripts.OnClick()
assert(A.deleteDialog:GetFrameLevel()>A.editor:GetFrameLevel())
A.deleteDialog.no.scripts.OnClick()
assert(A.editor:IsShown() and A.editor.bodyBox:HasFocus())
print('PASS: addon windows above native dialog, confirmation above editor, backgrounds/fields block mouse propagation, blank field click focuses own EditBox')
local oldSetText,oldAddLine,oldClearLines=GameTooltip.SetText,GameTooltip.AddLine,GameTooltip.ClearLines
local lines={}
GameTooltip.SetText=function() error('Persist tooltip must use wrapped AddLine, not the invalid SetText overload') end
GameTooltip.ClearLines=function() lines={} end
GameTooltip.AddLine=function(_,text,r,g,b,wrap)
 assert(type(text)=='string')
 if r then assert(type(r)=='number' and type(g)=='number' and type(b)=='number') end
 if wrap~=nil then assert(type(wrap)=='boolean') end
 table.insert(lines,text)
end
for _,check in ipairs(A.persistChecks) do
 check.scripts.OnEnter()
 assert(#lines==4 and lines[1]:find('Keep the current application note',1,true))
 assert(lines[4]:find('Other addons',1,true))
 check.scripts.OnLeave()
end
GameTooltip.SetText,GameTooltip.AddLine,GameTooltip.ClearLines=oldSetText,oldAddLine,oldClearLines
print('PASS: all four Persist checkbox hover tooltips use valid wrapped AddLine arguments')
assert(A.db.language=='en' and A.languageButtons.en.selected and not A.languageButtons.tr.selected)
A.Store('dungeon',1,'Save','Description')
local sessionBeforeLanguage=A.editor.session
local draftBeforeLanguage=A.editor.bodyBox:GetText()
local focusedBeforeLanguage=A.editor.bodyBox:HasFocus()
A.languageButtons.tr.scripts.OnClick()
assert(A.db.language=='tr' and A.languageButtons.tr.selected and not A.languageButtons.en.selected)
assert(A.buttons[A.languageButtons.tr].inset and not A.buttons[A.languageButtons.en].inset)
assert(A.options.heading:GetText()=='LFG Presets By Wadenown - Ayarlar')
assert(A.options.done.text:GetText()=='Tamam')
assert(A.editor.save.text:GetText()=='Kaydet' and A.editor.delete.text:GetText()=='Sil')
assert(A.editor.titleLabel:GetText()=='Başlık' and A.editor.bodyLabel:GetText()=='Not')
assert(A.deleteDialog.heading:GetText()=='Şablon Silinsin mi?')
assert(A.deleteDialog.yes.text:GetText()=='Evet, Sil' and A.deleteDialog.no.text:GetText()=='Hayır, Kalsın')
assert(A.panels.dungeon.heading:GetText()=='Zindan Şablonları')
assert(A.panels.dungeon.rows[1].title:GetText()=='Save' and A.panels.dungeon.rows[1].body:GetText()=='Description')
assert(A.Get('dungeon',1).title=='Save' and A.Get('dungeon',1).description=='Description')
assert(A.editor.session==sessionBeforeLanguage and A.editor.bodyBox:GetText()==draftBeforeLanguage)
assert(A.editor.bodyBox:HasFocus()==focusedBeforeLanguage)
assert(A.L('%d / 63 note characters',12)=='12 / 63 not karakteri')
A.optionRows.dungeon.resetPresets.scripts.OnClick()
A.refreshResetDialog()
A.Initialize(); assert(A.db.language=='tr')
A.languageButtons.en.scripts.OnClick()
assert(A.options.heading:GetText()=='LFG Presets By Wadenown - Options')
assert(A.editor.save.text:GetText()=='Save' and A.languageButtons.en.selected)
assert(A.Get('dungeon',1).title=='Save')
print('PASS: default English, instant complete Turkish interface, selected language buttons, saved preference, switch back, user content/draft/focus unchanged')
for font in pairs(A.localizedTexts) do assert(font.fontPath==A.fontPath) end
assert(A.editor.titleBox.fontPath==A.fontPath and A.editor.bodyBox.fontPath==A.fontPath)
local sample=CreateFrame('Font'); sample:SetFont('original',17,'')
A.ApplyFont(sample); assert(sample.fontPath==A.fontPath and sample.fontSize==19)
A.ApplyFont(sample); assert(sample.fontSize==19)
A.Accent(sample); assert(sample.fontSize==17)
print('PASS: bundled font applied to addon labels/buttons and editor fields, body fonts larger without accumulating, accent sizes preserved')
eventFrame.scripts.OnEvent(eventFrame,'PLAYER_LOGIN')
assert(LFGListApplicationDialog.scripts.OnHide)
local savedEditor=A.editor
A.uiReady=false; A.editor=nil
LFGListApplicationDialog:Show(); LFGListApplicationDialog:Hide(); A.Update()
A.editor=savedEditor; A.uiReady=true
local savedPrint=print; local warnings=0
print=function() warnings=warnings+1 end
A.fontWarningShown=nil
local failedFont=CreateFrame('Font'); failedFont.SetFont=function() return false end
A.ApplyFont(failedFont); A.ApplyFont(failedFont)
assert(warnings==1)
local noResultFont=CreateFrame('Font'); noResultFont.SetFont=function() end
A.ApplyFont(noResultFont); assert(warnings==1)
print=savedPrint
print('PASS: incomplete UI never attaches hooks or updates; existing close hook tolerates missing editor; font failure warns once without aborting startup')
A.SetTheme('classic'); A.SetLanguage('tr')
local panel=A.panels.dungeon
assert(panel.addSlot.text:GetText()=='+ Slot' and A.buttons[panel.addSlot].textOffsetY==-1)
assert(panel.heading.fontSize==A.fontMetrics[panel.heading].size)
assert(panel.rows[1].title.fontSize==A.fontMetrics[panel.rows[1].title].size)
assert(panel.rows[1].body.fontSize==A.fontMetrics[panel.rows[1].body].size+2)
assert(A.editor.bodyBox.fontSize==A.fontMetrics[A.editor.bodyBox].size+2)
A.ApplyTheme(); assert(panel.rows[1].body.fontSize==A.fontMetrics[panel.rows[1].body].size+2)
print('PASS: Turkish + Slot label/offset, yellow heading/card sizes unchanged, white previews and input text enlarged')
PVEFrame=CreateFrame('Frame'); PVEFrame.Tabs={1,2,3}; PVEFrame.activeTabIndex=1
LFGListApplicationDialog:Show(); LFGListFrame.EntryCreation:Show()
A.editor:Hide(); A.Activate('dungeon'); A.panel:Show(); A.OpenEditor(1)
local sessionBeforeLauncher=A.editor.session
A.preview.dungeon=true
A.InstallPVELauncher(); local launcher=A.pveLauncher
assert(launcher and launcher:GetText()=='LFG Presets')
assert(#PVEFrame.Tabs==3 and #launcher:GetParent().Tabs==1)
launcher.scripts.OnClick()
assert(A.options:IsShown() and PVEFrame:IsShown() and LFGListApplicationDialog:IsShown() and LFGListFrame.EntryCreation:IsShown())
assert(A.editor:IsShown() and A.editor.session==sessionBeforeLauncher and A.preview.dungeon)
assert(PVEFrame.activeTabIndex==1)
A.InstallPVELauncher(); assert(A.pveLauncher==launcher)
print('PASS: isolated LFG Presets launcher tab opens Options without hiding native/addon windows, changing tabs or clearing previews/drafts; installs once')
PVEFrameTab3=CreateFrame('Button',nil,CreateFrame('Frame'),'PanelTabButtonTemplate')
PVEFrameTab3:GetFontString():SetFont('UserInterfaceFont.ttf',13,'OUTLINE')
launcher.scripts.OnShow(launcher)
assert(launcher:GetFontString().fontPath=='UserInterfaceFont.ttf' and launcher:GetFontString().fontSize==13)
assert(launcher:GetFontString().fontFlags=='OUTLINE')
PVEFrameTab3:GetFontString():SetFont('UpdatedUserFont.ttf',14,'')
launcher.scripts.OnEnter(launcher)
assert(launcher:GetFontString().fontPath=='UpdatedUserFont.ttf')
print('PASS: LFG Presets launcher follows native neighboring tab font, size, flags and later UI font changes')
local previousPlace=A.Place; local snaps=0
A.Place=function(frame,anchor,position,adjacentOnly)
 if adjacentOnly then snaps=snaps+1; assert(position==nil) end
 return previousPlace(frame,anchor,position,adjacentOnly)
end
local noteList=A.panels.application; noteList:Show()
A.db.settings.application.attachBesideNote=true
A.PlaceAttached(noteList,LFGListApplicationDialog,'application')
assert(snaps==1 and not A.db.settings.application.attachBesideNote)
A.PlaceAttached(noteList,LFGListApplicationDialog,'application'); assert(snaps==2)
A.Place=previousPlace
print('PASS: Attach To Blizzard Note stays directly beside native dialog on every placement')
local noteAnchor=CreateFrame('Frame'); noteAnchor.GetLeft=function() return 100 end
noteAnchor.GetRight=function() return 406 end; noteAnchor.GetTop=function() return 700 end
local positioned=CreateFrame('Frame'); positioned:SetSize(344,448)
local placedX
positioned.SetPoint=function(_,_,_,_,x) placedX=x end
A.Place(positioned,noteAnchor,nil,true); assert(placedX==406)
A.Place(positioned,noteAnchor); assert(placedX==418)
local applicationMaster=CreateFrame('Frame'); applicationMaster.kind='application'
applicationMaster:SetSize(344,448); applicationMaster.GetLeft=function() return 500 end
local detail=CreateFrame('Frame'); detail:SetSize(280,399)
detail.SetPoint=function(_,_,anchor,_,x) placedX=anchor==applicationMaster and 500+x or x end
applicationMaster.dockSide='left'; A.Dock(detail,applicationMaster)
assert(applicationMaster.dockSide=='right' and placedX==844)
print('PASS: zero gap beside Blizzard note and application detail; right preferred when available; dungeon/raid gap unchanged')
local tooltip=A.GetTooltip(); local oldNumLines=tooltip.NumLines
local line=CreateFrame('Font'); line:SetFont('OriginalTooltipFont.ttf',18,''); line:SetText(string.rep('x',255))
_G.LFGPresetsByWadenownTooltipTextLeft1=line
tooltip.NumLines=function() return 1 end
local ref=A.panels.dungeon.rows[1].body
A.ShowTooltip(ref,A.panels.dungeon)
local _,referenceSize=ref:GetFont()
assert(line.fontSize==referenceSize and line:GetWidth()<=360)
A.ShowTooltip(ref,A.panels.dungeon); assert(line.fontSize==referenceSize)
tooltip.NumLines=oldNumLines; _G.LFGPresetsByWadenownTooltipTextLeft1=nil
print('PASS: preset tooltip uses exact preview font size without accumulation and bounds long descriptions to a wrapping column')
A.editor:Hide(); A.Activate('dungeon'); A.panel:Show(); A.OpenEditor(1)
for _,box in ipairs({A.editor.titleBox,A.editor.bodyBox}) do
 for _,key in ipairs({'ENTER','NUMPADENTER'}) do
  box:SetText('ab'); box:SetFocus()
  box.scripts.OnKeyDown(box,key); box.scripts.OnEnterPressed(box)
  box:SetText('a\nb')
  assert(box:GetText()=='ab' and A.editor:IsShown())
  box.scripts.OnKeyUp(box,key)
 end
 box:SetText('a\r\nb\nc'); assert(box:GetText()=='a b c')
end
print('PASS: Enter/numpad Enter never saves/closes or inserts line breaks, pasted newlines become spaces, visual multiline wrapping remains')
A.editor:Hide(); A.SetLanguage('en')
for _,kind in ipairs({'dungeon','raid','application'}) do
 for _,blank in ipairs({'','   ',' \t '}) do
  A.Activate(kind); A.panel:Show(); A.OpenEditor(1)
  A.editor.titleBox:SetText(blank); A.editor.bodyBox:SetText(blank); A.SaveEditor()
  local row=A.panels[kind].rows[1]
  assert((kind=='application' and row.body or row.title):GetText()=='Empty Preset')
  local p=A.Get(kind,1); assert((p.note or p.description)==blank)
 end
end
A.SetLanguage('tr')
assert(A.panels.dungeon.rows[1].title:GetText()=='Boş Şablon')
assert(A.panels.application.rows[1].body:GetText()=='Boş Şablon')
print('PASS: clearing/saving empty or whitespace-only slots always shows localized Empty Preset in all three lists')
A.editor:Hide(); A.Activate('dungeon')
while #A.db.presets.dungeon<200 do A.Append('dungeon',string.rep('a',31),string.rep('ç',255)) end
local before=mockMetrics.measurements
A.RefreshCards()
local cold=mockMetrics.measurements-before
before=mockMetrics.measurements
for i=1,20 do A.RefreshCards() end
local warm=mockMetrics.measurements-before
assert(warm==0)
A.db.presets.dungeon[200].description=string.rep('ğ',255)
before=mockMetrics.measurements; A.RefreshCards()
local changed=mockMetrics.measurements-before
assert(changed>0 and changed<=14)
assert(utf8.len(A.rows[200].body:GetText()))
assert(not A.dockWatching and not A.editor.scripts.OnUpdate)
print('PERF: 200 slots; cold width/height measurements='..cold..'; 20 unchanged refreshes='..warm..'; one changed long UTF-8 row='..changed)
print('PASS: syntax, 15 slots, focus matrix, application field visibility, deferred full-draft save, cancellation, reload initialization, categories, priority, combat hiding')
