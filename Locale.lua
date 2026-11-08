local _,A=...
local tr={
 ['LFG Presets By Wadenown: PT Sans Narrow Bold could not be loaded. Using the existing font; restart WoW and try again.']='LFG Presets By Wadenown: PT Sans Narrow Bold yüklenemedi. Mevcut font kullanılıyor; WoW’u yeniden başlatıp tekrar dene.',
 ['LFG Presets By Wadenown - Options']='LFG Presets By Wadenown - Ayarlar',
 ['Theme:']='Tema:', ['Language:']='Dil:', ['Classic']='Klasik', ['Modern']='Modern',
 ['English']='İngilizce', ['Turkish']='Türkçe',
 ['Dungeon Presets']='Zindan Şablonları', ['Raid Presets']='Baskın Şablonları',
 ['Application Presets']='Başvuru Şablonları', ['Application Notes']='Başvuru Notları',
 ['Application Preset']='Başvuru Şablonu', ['Edit Dungeon Preset']='Zindan Şablonu', ['Edit Raid Preset']='Baskın Şablonu',
 ['Empty Preset']='Boş Şablon', ['Title']='Başlık', ['Description']='Açıklama', ['Note']='Not',
 ['Save']='Kaydet', ['Delete']='Sil', ['Cancel']='İptal', ['Done']='Tamam', ['Reset']='Sıfırla',
 ['Yes, Delete']='Evet, Sil', ['No, Keep']='Hayır, Kalsın', ['Delete Preset?']='Şablon Silinsin mi?',
 ['Are you sure you want to permanently delete this slot?']='Bu yuvayı kalıcı olarak silmek istediğine emin misin?',
 ['Copy / Edit Preset']='Şablonu Kopyala / Düzenle', ['+ Slot']='+ Slot',
 ['Attach to List']='Listeye Tuttur', ['Attach to LFG']='LFG’ye Tuttur',
 ['Attach To Blizzard Note']='Blizzard Notuna Tuttur',
 ['Automatically Open']='Otomatik Aç', ['Open automatically']='Otomatik aç',
 ['Preview Panel']='Önizleme', ['Lock Panel']='Paneli Kilitle', ['Unlock Panel']='Kilidi Aç',
 ['Reset Position']='Konumu Sıfırla', ['Reset Presets']='Şablonları Sıfırla',
 ['Appearance']='Görünüm', ['Panel scale']='Panel ölçeği', ['Background opacity']='Zemin opaklığı',
 ['Open Options']='Ayarları Aç', ['Shared across all applications.']='Tüm başvurularda ortaktır.',
 ['Dungeon group creation.']='Zindan grubu oluşturma.', ['Raid group creation.']='Baskın grubu oluşturma.',
 ['Panels appear beside group creation and applications.']='Paneller, grup oluşturma ve başvuru pencerelerinin yanında açılır.',
 ['Open a preset, edit, then Ctrl+C to copy, save and close. Paste manually.']='Bir şablonu açıp düzenle. Ctrl+C ile kopyala, kaydet ve kapat. Metni kendin yapıştır.',
 ['Ctrl+C to copy, save and close.']='Ctrl+C: Kopyala, kaydet ve kapat.',
 ['Position locked. Type /lfp for more options.']='Konum kilitli. Diğer ayarlar için /lfp yaz.',
 ['Drag header to move. Type /lfp for more options.']='Başlıktan sürükle. Diğer ayarlar için /lfp yaz.',
 ['Persist Application Note']='Başvuru Notunu Koru',
 ["Keep the current application note in Blizzard's UI between applications."]='Blizzard UI’ındaki mevcut başvuru notunu sonraki başvurularda korur.',
 ['Does not autofill presets or retain the note across reloads.']='Şablonları otomatik doldurmaz; notu arayüz yeniden yüklendiğinde saklamaz.',
 ['Other addons may also retain application notes. If you turn this off, make sure persistence is disabled in those addons too.']='Diğer addonlar da başvuru notunu koruyabilir. Buradan kapatırsan diğer addonlardaki not koruma ayarlarının da kapalı olduğundan emin ol.',
 ['Reset %s?']='%s sıfırlansın mı?',
 ['This clears all %d presets in this section.']='Bu bölümdeki %d şablonun tamamının içeriği temizlenir.',
 ['%d / 63 note characters']='%d / 63 not karakteri',
 ['%d / 31 title  |  %d / 255 description']='%d / 31 başlık  |  %d / 255 açıklama',
 ['LFG Presets By Wadenown: newer saved data detected; addon disabled.']='LFG Presets By Wadenown: Daha yeni kayıt verisi bulundu; addon devre dışı bırakıldı.',
}
A.localizedTexts={}
function A.L(key,...)
    local text=A.db and A.db.language=='tr' and tr[key] or key
    if select('#',...)>0 then return string.format(text,...) end
    return text
end
function A.SetText(font,key,...)
    local language=A.db and A.db.language or 'en'
    local count=select('#',...)
    local previous=A.localizedTexts[font]
    if previous and previous.key==key and previous.language==language and #previous.args==count then
        local same=true
        for i=1,count do if previous.args[i]~=select(i,...) then same=false; break end end
        if same then return end
    end
    A.localizedTexts[font]={key=key,args={...},language=language}
    font:SetText(A.L(key,...))
end
function A.SetLanguage(language)
    if language~='en' and language~='tr' then return end
    A.db.language=language
    for font,item in pairs(A.localizedTexts) do A.SetText(font,item.key,(unpack or table.unpack)(item.args)) end
    if A.panels then A.RefreshAll(); A.SyncLocks() end
    if A.editor and A.editor:IsShown() and A.editor.updateCounter then A.editor.updateCounter() end
    if A.refreshResetDialog then A.refreshResetDialog() end
    if A.RefreshPersistHitRects then A.RefreshPersistHitRects() end
    A.ApplyTheme()
end
