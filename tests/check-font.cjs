const fs=require('fs'),assert=require('assert'),crypto=require('crypto');
const b=fs.readFileSync('Media/Fonts/PTSansNarrow-Bold.ttf');
assert.equal(crypto.createHash('sha256').update(b).digest('hex'),'efc8710f9eb3e41405a7efaf9aba701e41dc0e9bcabd3aa0b08f111441fb247d');
const tables={};
for(let i=0;i<b.readUInt16BE(4);i++){const p=12+i*16;tables[b.toString('ascii',p,p+4)]=b.readUInt32BE(p+8);}
const cmap=tables.cmap,maps=[];
for(let i=0;i<b.readUInt16BE(cmap+2);i++){
 const p=cmap+4+i*8,platform=b.readUInt16BE(p),encoding=b.readUInt16BE(p+2);
 if(platform===0||(platform===3&&(encoding===1||encoding===10))) maps.push(cmap+b.readUInt32BE(p+4));
}
function hasGlyph(cp){return maps.some(p=>{
 const format=b.readUInt16BE(p);
 if(format===12){for(let i=0;i<b.readUInt32BE(p+12);i++){const g=p+16+i*12;if(cp>=b.readUInt32BE(g)&&cp<=b.readUInt32BE(g+4))return b.readUInt32BE(g+8)+cp-b.readUInt32BE(g)!==0;}}
 if(format===4&&cp<=65535){const n=b.readUInt16BE(p+6)/2,end=p+14,start=end+2*n+2,delta=start+2*n,range=delta+2*n;
  for(let i=0;i<n;i++)if(cp>=b.readUInt16BE(start+2*i)&&cp<=b.readUInt16BE(end+2*i)){
   const d=b.readInt16BE(delta+2*i),r=b.readUInt16BE(range+2*i);
   if(!r)return ((cp+d)&65535)!==0;
   const g=b.readUInt16BE(range+2*i+r+2*(cp-b.readUInt16BE(start+2*i)));return g!==0&&((g+d)&65535)!==0;
  }
 }
 return false;
});}
for(const ch of 'AaZz0123456789ÇçĞğİıÖöŞşÜü')assert(hasGlyph(ch.codePointAt(0)),`Missing glyph: ${ch}`);
const license=fs.readFileSync('Media/Fonts/PTSansNarrow-Bold-LICENSE.txt','utf8');
assert(license.includes('SIL OPEN FONT LICENSE Version 1.1')&&license.includes('ParaType'));
console.log('PASS: bundled font hash matches source, English/Turkish glyph coverage, OFL notice included');
