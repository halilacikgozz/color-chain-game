// Replay the daily board on the server; clients never submit a trusted score.
export function replay(day: string, moves: number[][]): number {
 if (!/^\d{4}-\d{2}-\d{2}$/.test(day) || moves.length !== 20) throw Error('20 hamle gerekli');
 let seed = (Number(day.replaceAll('-', '')) * 71 + 501) & 0x7fffffff;
 const random = () => {seed = (Math.imul(seed,1103515245) + 12345) & 0x7fffffff; return (seed >>> 16) % 4;};
 let board = Array.from({length:49},random), specials = Array(49).fill(0), score = 0;
 const adjacent = (a:number,b:number) => Math.abs(a%7-b%7)+Math.abs(Math.floor(a/7)-Math.floor(b/7))===1;
 const ensure = () => {
  const seen = new Set<number>();
  for(let start=0;start<49;start++) {
   if(seen.has(start)) continue;
   const queue=[start]; seen.add(start); let size=0;
   while(queue.length) {const current=queue.pop()!; if(++size>=3)return;
    for(const next of [current-7,current+7,current-1,current+1]) if(next>=0&&next<49&&adjacent(current,next)&&board[next]===board[start]&&!seen.has(next)){seen.add(next);queue.push(next);}
   }
  }
  board=Array.from({length:49},random);board[1]=board[2]=board[0];
 };
 board[1]=board[2]=board[0];specials[1]=1;ensure();
 for(const path of moves) {
  if(!Array.isArray(path)||path.length<3||path.length>49||new Set(path).size!==path.length||path.some(i=>!Number.isInteger(i)||i<0||i>=49))throw Error('Geçersiz zincir');
  let color=-1;
  for(let n=0;n<path.length;n++) {const i=path[n];if(n&&!adjacent(path[n-1],i))throw Error('Komşu değil');if(specials[i]!==3){if(color!==-1&&board[i]!==color)throw Error('Renk uyuşmuyor');color=board[i];}}
  if(color<0)color=board[path[0]];
  const cleared=new Set(path), paired=path.map(i=>specials[i]);
  if(paired.includes(1)&&paired.includes(2))for(const i of path)if(specials[i]===2)for(let j=0;j<49;j++)if(Math.abs(Math.floor(j/7)-Math.floor(i/7))<=1||j%7===i%7)cleared.add(j);
  if(paired.includes(3)&&(paired.includes(1)||paired.includes(2)))for(let j=0;j<49;j++)if(board[j]===color&&specials[j]===0)specials[j]=paired.includes(1)?1:2;
  const activated=new Set<number>();
  const queue=[...cleared];
  for(let cursor=0;cursor<queue.length;cursor++) {const i=queue[cursor],kind=specials[i];if(!kind||activated.has(i))continue;activated.add(i);
   for(let j=0;j<49;j++) {const affected=kind===1?Math.abs(j%7-i%7)<=1&&Math.abs(Math.floor(j/7)-Math.floor(i/7))<=1:kind===2?Math.floor(j/7)===Math.floor(i/7):board[j]===color||specials[j]===3;
    if(affected&&!cleared.has(j)){cleared.add(j);queue.push(j);}
   }
  }
  const anchor=path.length>=5?path[path.length-1]:-1, reward=path.length>=9?3:path.length>=7?2:path.length>=5?1:0;
  const extra=Math.max(0,cleared.size-path.length);
  score+=path.length*10+Math.max(0,path.length-3)*5+extra*10;
  if(anchor>=0){cleared.delete(anchor);board[anchor]=color;}
  for(let x=0;x<7;x++){let target=6;for(let y=6;y>=0;y--){const source=y*7+x;if(!cleared.has(source)){board[target*7+x]=board[source];specials[target*7+x]=source===anchor?reward:specials[source];target--;}}
   while(target>=0){board[target*7+x]=random();specials[target*7+x]=0;target--;}
  }
  ensure();
 }
 return score;
}
