const { chromium } = require('playwright-core');
const fs=require('fs'); const OUT=__dirname+'/out'; fs.mkdirSync(OUT,{recursive:true});
const dens={mdpi:1,hdpi:1.5,xhdpi:2,xxhdpi:3,xxxhdpi:4};
(async()=>{
  const b=await chromium.launch({executablePath:'/opt/pw-browsers/chromium-1194/chrome-linux/chrome',args:['--no-sandbox','--disable-gpu']});
  const page=await (await b.newContext({deviceScaleFactor:1,viewport:{width:600,height:600}})).newPage();
  page.setDefaultTimeout(15000);
  await page.goto('file://'+__dirname+'/icon.html'); await page.waitForTimeout(100);
  const svg=page.locator('#s');
  async function shot(mode,px,file,round){
    await page.evaluate(([m,s,r])=>{ setMode(m,s); const svg=document.getElementById('s'); const bg=document.getElementById('bg'), art=document.getElementById('art');
      if(r){ if(!document.getElementById('clipc')){ const cp=document.createElementNS('http://www.w3.org/2000/svg','clipPath'); cp.id='clipc'; const c=document.createElementNS('http://www.w3.org/2000/svg','circle'); c.setAttribute('cx',54); c.setAttribute('cy',54); c.setAttribute('r',53.5); cp.appendChild(c); svg.querySelector('defs').appendChild(cp);} bg.setAttribute('clip-path','url(#clipc)'); art.setAttribute('clip-path','url(#clipc)'); }
      else { bg.removeAttribute('clip-path'); art.removeAttribute('clip-path'); } },[mode,px,!!round]);
    await page.waitForTimeout(30);
    await svg.screenshot({path:file, omitBackground:true, animations:'disabled', timeout:15000});
  }
  for(const [d,m] of Object.entries(dens)){
    fs.mkdirSync(`${OUT}/mipmap-${d}`,{recursive:true});
    await shot('fg', Math.round(108*m), `${OUT}/mipmap-${d}/ic_launcher_foreground.png`);
    await shot('full', Math.round(48*m), `${OUT}/mipmap-${d}/ic_launcher.png`);
    await shot('round', Math.round(48*m), `${OUT}/mipmap-${d}/ic_launcher_round.png`, true);
  }
  await shot('full', 512, `${OUT}/preview_full.png`);
  await shot('fg', 432, `${OUT}/preview_fg.png`);
  await b.close(); console.log('rendered'); process.exit(0);
})().catch(e=>{console.error('FAIL',e.message);process.exit(2);});
