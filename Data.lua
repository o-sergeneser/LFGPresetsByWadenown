local _, A = ...
A.names = { dungeon = "Dungeon Presets", raid = "Raid Presets", application = "Application Presets" }
function A.Initialize()
    if type(LFGPresetsByWadenownDB) ~= "table" then LFGPresetsByWadenownDB = {} end
    A.db = LFGPresetsByWadenownDB
    if A.db.schemaVersion and A.db.schemaVersion > 4 then
        print(A.L("LFG Presets By Wadenown: newer saved data detected; addon disabled."))
        return false
    end
    A.db.schemaVersion = 4
    if A.db.language~='en' and A.db.language~='tr' then A.db.language='en' end
    if A.db.persistApplicationNote==nil then A.db.persistApplicationNote=true end
    A.db.nextSlotID=A.db.nextSlotID or {}
    A.db.settings = A.db.settings or {}
    A.db.appearance = A.db.appearance or { scale = 1, opacity = .98 }
    if A.db.appearance.theme~='classic' and A.db.appearance.theme~='modern' then
        A.db.appearance.theme='classic'
    end
    A.db.presets = A.db.presets or {}
    for kind in pairs(A.names) do
        A.db.settings[kind] = A.db.settings[kind] or { automatic = true, locked = false }
        if A.db.settings[kind].attached==nil then A.db.settings[kind].attached=false end
        if A.db.settings[kind].editorAttached==nil then A.db.settings[kind].editorAttached=true end
        if A.db.settings[kind].attached then A.db.settings[kind].locked=true end
        if A.db.position and not A.db.settings[kind].position then
            A.db.settings[kind].position={x=A.db.position.x,y=A.db.position.y}
        end
        local newList=A.db.presets[kind]==nil
        local list = A.db.presets[kind] or {}
        A.db.presets[kind] = list
        A.db.nextSlotID[kind]=math.max(A.db.nextSlotID[kind] or 6,#list+1)
        for i = 1, newList and 5 or 0 do
            if not list[i] then
                list[i] = { id = kind .. "-" .. i }
                if kind == "application" then list[i].note = ""
                else list[i].title, list[i].description = "", "" end
            end
        end
    end
    A.db.position=nil
    return true
end
function A.DeletePreset(kind,id)
    local list=A.db.presets[kind]
    for i,p in ipairs(list) do
        if p.id==id then table.remove(list,i); return true end
    end
    return false
end
function A.ResetPresets(kind)
    for i=1,#A.db.presets[kind] do A.Store(kind,i,"","") end
    if A.editor and A.editor.kind==kind then A.editor:Hide() end
    A.RefreshAll()
end
function A.Append(kind,title,body)
    local list=A.db.presets[kind]
    local id=A.db.nextSlotID[kind]
    A.db.nextSlotID[kind]=id+1
    list[#list+1]={id=kind..'-'..id}
    A.Store(kind,#list,title,body)
    return #list
end
function A.Get(kind, index) return A.db.presets[kind][index] end
function A.Store(kind, index, title, body)
    local p = A.Get(kind, index)
    if kind == "application" then p.note = body
    else p.title, p.description = title, body end
end
function A.InitialField(title, body, application)
    if application then return "body" end
    if title:find("%S") or not body:find("%S") then return "title" end
    return "body"
end
