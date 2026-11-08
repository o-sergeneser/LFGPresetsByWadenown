const fs=require('fs');
const {lua,lauxlib,lualib,to_luastring,to_jsstring}=require('fengari');
const L=lauxlib.luaL_newstate(); lualib.luaL_openlibs(L);
function run(s){if(lauxlib.luaL_dostring(L,to_luastring(s))!==lua.LUA_OK)throw Error(to_jsstring(lua.lua_tostring(L,-1)));}
run(fs.readFileSync('tests/mock.lua','utf8'));
for(const name of ['Locale.lua','Data.lua','Fonts.lua','Persistence.lua','Themes.lua','UI.lua','Layout.lua','Options.lua','Launcher.lua','Core.lua']){
 const s=fs.readFileSync(name,'utf8');
 run(`assert(load(${JSON.stringify(s)},${JSON.stringify(name)}))('LFGPresetsByWadenown', A)`);
}
run(`A.testNativeShowSource=${JSON.stringify(fs.readFileSync('tests/fixtures/application-show.lua','utf8'))}`);
run(fs.readFileSync('tests/scenarios.lua','utf8'));
