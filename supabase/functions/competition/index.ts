import { createClient } from 'npm:@supabase/supabase-js@2';
import { replay } from './replay.ts';
const headers={'Access-Control-Allow-Origin':'https://halilacikgozz.github.io','Access-Control-Allow-Headers':'authorization, apikey, content-type','Access-Control-Allow-Methods':'POST, OPTIONS'};
Deno.serve(async req=>{
 if(req.method==='OPTIONS')return new Response('ok',{headers});
 const response=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers:{...headers,'Content-Type':'application/json'}});
 try{
  if(req.method!=='POST')return response({error:'POST gerekli'},405);
  if(Number(req.headers.get('content-length')??0)>15000)return response({error:'İstek büyük'},413);
  const url=Deno.env.get('SUPABASE_URL')!,key=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const admin=createClient(url,key,{auth:{persistSession:false}});
  const token=req.headers.get('Authorization')?.replace(/^Bearer /,'')??'';
  const {data:{user},error}=await admin.auth.getUser(token);
  if(error||!user)return response({error:'Giriş gerekli'},401);
  const input=await req.json();const day=new Date().toISOString().slice(0,10);
  const date=new Date(day);date.setUTCDate(date.getUTCDate()-((date.getUTCDay()+6)%7));const week=date.toISOString().slice(0,10);
  const nickname='Oyuncu '+user.id.slice(0,6);
  const saved=await admin.from('cc_players').upsert({id:user.id,nickname},{onConflict:'id',ignoreDuplicates:true});if(saved.error)throw saved.error;
  if(!['submit','leaderboard','profile'].includes(input.action))return response({error:'Geçersiz işlem'},400);
  if(input.action==='profile'){
   const name=typeof input.nickname==='string'?input.nickname.normalize('NFKC'):'';
   if(!/^[\p{L}\p{N}_-]{3,16}$/u.test(name))return response({error:'3–16 harf, rakam, _ veya - kullan.'},400);
   const result=await admin.from('cc_players').update({nickname:name}).eq('id',user.id);
   if(result.error?.code==='23505')return response({error:'Bu oyuncu adı kullanılıyor; başka bir ad seç.'},409);
   if(result.error)throw result.error;
  }
  if(input.action==='submit'){
   if(input.day!==day)return response({error:'Günün tarihi değişti; yeni yarış başlat'},400);
   const score=replay(day,input.moves,input.ruleset??1);
   const {data:old}=await admin.from('cc_scores').select('score').eq('player_id',user.id).eq('day',day).maybeSingle();
   if(!old||score>old.score){const result=await admin.from('cc_scores').upsert({player_id:user.id,day,score});if(result.error)throw result.error;}
  }
  const joined=await admin.rpc('cc_join',{p_id:user.id,p_week:week});if(joined.error)throw joined.error;
  const {data:member,error:memberError}=await admin.from('cc_members').select('tier,cohort').eq('player_id',user.id).eq('week',week).single();if(memberError)throw memberError;
  const {data:members}=await admin.from('cc_members').select('player_id').eq('week',week).eq('tier',member.tier).eq('cohort',member.cohort);
  const ids=(members??[]).map(m=>m.player_id);
  const {data:scores}=await admin.from('cc_scores').select('player_id,score').in('player_id',ids).gte('day',week).lte('day',day);
  const {data:players}=await admin.from('cc_players').select('id,nickname').in('id',ids);
  const rows=(players??[]).map(p=>({id:p.id,name:p.nickname,score:(scores??[]).filter(s=>s.player_id===p.id).reduce((a,s)=>a+s.score,0)})).sort((a,b)=>b.score-a.score||a.id.localeCompare(b.id));
  return response({profile_saved:input.action==='profile',nickname:(players??[]).find(p=>p.id===user.id)?.nickname??nickname,tier:member.tier,week,rows:rows.map((r,i)=>({name:r.name,score:r.score,rank:i+1,self:r.id===user.id})),promotion:'İlk 5 sonraki hafta yükselir'});
 }catch(e){return response({error:e instanceof Error?e.message:'İşlem tamamlanamadı'},400);}
});
