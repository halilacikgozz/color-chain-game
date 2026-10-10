import {readFileSync} from 'node:fs';
import {strict as assert} from 'node:assert';
import {replay,hasMove} from '../supabase/functions/competition/replay.ts';
const fixture=JSON.parse(readFileSync('tests/daily_fixture.json','utf8'));
assert.equal(replay(fixture.day,fixture.moves),fixture.score,'Server and Godot score agree for twenty moves');
assert.throws(()=>replay(fixture.day,fixture.moves.slice(1)));
assert.throws(()=>replay(fixture.day,[[0,0,0],...fixture.moves.slice(1)]));
assert.throws(()=>replay(fixture.day,[[0,8,16],...fixture.moves.slice(1)]));
console.log('Competition replay verification passed');

const board=Array.from({length:49},(_,i)=>(i%7+Math.floor(i/7))%4), specials=Array(49).fill(0);
assert.equal(hasMove(board,specials),false);
board[0]=board[2]=0; specials[1]=3; assert.equal(hasMove(board,specials),true);
assert.equal(replay(fixture.day,fixture.moves,2),fixture.score);
assert.throws(()=>replay(fixture.day,fixture.moves.slice(0,1),2));

import {validateProgress} from '../supabase/functions/competition/progress.ts';
const progress={version:1,xp:123,stars:3,quests_done:2,quest_progress:0,best:400,timed_best:0,crystals:80,daily_best:0,daily_attempts:0,theme:1,cosmetic:0,owned:[0],level_stars:Array(30).fill(0),level_bests:Array(30).fill(0),daily_day:'',daily_rewarded:''};
assert.equal(validateProgress(progress).xp,123);
assert.throws(()=>validateProgress({...progress,level_stars:[4]}));
assert.throws(()=>validateProgress({...progress,crystals:-1}));
assert.throws(()=>validateProgress({...progress,cosmetic:3}));
