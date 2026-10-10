// Cloud progression is separate from the server-verified competitive score.
export function validateProgress(value: unknown): Record<string, unknown> {
 if(!value || typeof value !== 'object' || Array.isArray(value)) throw Error('Geçersiz kayıt');
 const p=value as Record<string,unknown>, out: Record<string,unknown>={version:1};
 if(p.version!==1)throw Error('Kayıt sürümü desteklenmiyor');
 for(const key of ['xp','stars','quests_done','quest_progress','best','timed_best','crystals','daily_best','daily_attempts']){
  const n=p[key];if(!Number.isInteger(n)||Number(n)<0||Number(n)>100000000)throw Error('Geçersiz ilerleme');out[key]=n;
 }
 for(const key of ['theme','cosmetic']){if(!Number.isInteger(p[key])||Number(p[key])<0||Number(p[key])>3)throw Error('Geçersiz görünüm');out[key]=p[key];}
 for(const key of ['level_stars','level_bests']){
  const a=p[key];if(!Array.isArray(a)||a.length!==30||a.some(n=>!Number.isInteger(n)||n<0||n>(key==='level_stars'?3:100000000)))throw Error('Geçersiz bölüm kaydı');out[key]=a;
 }
 if(!Array.isArray(p.owned)||p.owned.length>4||!p.owned.includes(0)||p.owned.some(n=>!Number.isInteger(n)||n<0||n>3)||!p.owned.includes(p.cosmetic))throw Error('Geçersiz koleksiyon');
 out.owned=[...new Set(p.owned)];
 for(const key of ['daily_day','daily_rewarded']){if(typeof p[key]!=='string'||(p[key]!==''&&!/^\d{4}-\d{2}-\d{2}$/.test(p[key] as string)))throw Error('Geçersiz gün');out[key]=p[key];}
 return out;
}
