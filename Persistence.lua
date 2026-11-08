local _,A=...
A.persistChecks={}
function A.SyncPersistNote()
    for _,check in ipairs(A.persistChecks) do check:SetChecked(A.db.persistApplicationNote) end
end
function A.RefreshPersistHitRects()
    for _,check in ipairs(A.persistChecks) do
        check:SetHitRectInsets(0,-(check.persistLabel:GetStringWidth()+25),0,0)
    end
end
function A.InstallNotePersistence()
    if not A.db or InCombatLockdown() then return end
    local original=_G.LFGListApplicationDialog_Show
    if type(original)~='function' or original==A.noteShowWrapper then return end
    local wrapper=function(self,resultID,...)
        if A.db.persistApplicationNote and resultID then
            local info=C_LFGList.GetSearchResultInfo(resultID)
            local activityID=info and info.activityIDs and info.activityIDs[1]
            if activityID then self.activityID=activityID end
        end
        return original(self,resultID,...)
    end
    A.noteShowWrapper=wrapper
    _G.LFGListApplicationDialog_Show=wrapper
end
function A.SetPersistNote(value)
    A.db.persistApplicationNote=not not value
    A.InstallNotePersistence()
    A.SyncPersistNote()
end
function A.AddPersistCheckbox(parent,x,y)
    local check=CreateFrame('CheckButton',nil,parent,'UICheckButtonTemplate')
    check:SetSize(22,22); check:SetPoint('TOPLEFT',x,y)
    local label=A.Label(check,'Persist Application Note',25,-5,'GameFontHighlightSmall')
    check.persistLabel=label
    check:SetHitRectInsets(0,-(label:GetStringWidth()+25),0,0)
    check:SetChecked(A.db.persistApplicationNote)
    check:SetScript('OnClick',function() A.SetPersistNote(check:GetChecked()) end)
    check:SetScript('OnEnter',function()
        local tooltip=A.GetTooltip()
        tooltip:SetOwner(check,'ANCHOR_RIGHT')
        tooltip:ClearLines()
        tooltip:AddLine(A.L("Keep the current application note in Blizzard's UI between applications."),1,1,1,true)
        tooltip:AddLine(A.L('Does not autofill presets or retain the note across reloads.'),.7,.7,.7,true)
        tooltip:AddLine(' ')
        tooltip:AddLine(A.L('Other addons may also retain application notes. If you turn this off, make sure persistence is disabled in those addons too.'),1,.82,.45,true)
        A.ShowTooltip()
    end)
    check:SetScript('OnLeave',function() A.GetTooltip():Hide() end)
    table.insert(A.persistChecks,check)
    return check
end
