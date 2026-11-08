function LFGListApplicationDialog_Show(self, resultID)
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    if searchResultInfo.activityIDs[1] ~= self.activityID then
        C_LFGList.ClearApplicationTextFields()
    end
    self.resultID = resultID
    self.activityID = searchResultInfo.activityIDs[1]
    LFGListApplicationDialog_UpdateRoles(self)
    StaticPopupSpecial_Show(self)
end
