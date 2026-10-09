import {readFileSync} from 'node:fs';
import {strict as assert} from 'node:assert';
import {replay} from '../supabase/functions/competition/replay.ts';
const fixture=JSON.parse(readFileSync('tests/daily_fixture.json','utf8'));
assert.equal(replay(fixture.day,fixture.moves),fixture.score,'Server and Godot score agree for twenty moves');
assert.throws(()=>replay(fixture.day,fixture.moves.slice(1)));
assert.throws(()=>replay(fixture.day,[[0,0,0],...fixture.moves.slice(1)]));
assert.throws(()=>replay(fixture.day,[[0,8,16],...fixture.moves.slice(1)]));
console.log('Competition replay verification passed');
