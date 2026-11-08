const fs=require('fs'),assert=require('assert');
const toc=fs.readFileSync('LFGPresetsByWadenown.toc','utf8');
const modules=toc.split(/\r?\n/).map(line=>line.trim()).filter(line=>line&&!line.startsWith('#'));
assert(modules.length>0);
for(const file of modules){
 assert(fs.existsSync(file),`Missing TOC module: ${file}`);
 assert(!/^\s*--/m.test(fs.readFileSync(file,'utf8')),`Unexpected source comment in ${file}`);
}
assert(toc.includes('## SavedVariables: LFGPresetsByWadenownDB'));
assert(toc.includes('## IconTexture: Interface\\AddOns\\LFGPresetsByWadenown\\Media\\Icon.tga'));
const icon=fs.readFileSync('Media/Icon.tga');
assert(icon[2]===2&&icon.readUInt16LE(12)===256&&icon.readUInt16LE(14)===256&&icon[16]===32);
assert(icon.length===18+256*256*4);
const meta=fs.readFileSync('.pkgmeta','utf8');
for(const path of ['tests','docs','.github','Media/Icon.png'])assert(meta.includes(`  - ${path}`));
if(process.env.GITHUB_REF_TYPE==='tag'){
 const version=toc.match(/^## Version:\s*(.+)$/m)[1].trim();
 assert(process.env.GITHUB_REF_NAME===`v${version}`,`Release tag must match TOC version v${version}`);
}
console.log('PASS: TOC modules, comment-free runtime sources, SavedVariables, icon, package exclusions and release version');
