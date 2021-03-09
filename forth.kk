import std/os/file;import std/os/env;import std/os/path
fun main() {
    var stack:=[];var dict:=[];var defining:=Nothing
    val code = read-text-file(path(get-argv()[1].expect("no file provided")))
    val words = code.split(" ").map(trim)
    foreach-indexed (words) fn(i,word) {
        match (defining) {
            Just(def-index) -> {
                val def-word = words[def-index + 1].expect("no def word name")
                val fd = fn(tup){val (k,_) = tup; k == def-word}
                if (i != def-index + 1)
                then if (word == ";")
                    then defining := Nothing
                    else dict := (match (dict.find(fd)) {
                            Just((_,v)) -> dict.remove(fd).push((def-word,v.push(word)))
                            Nothing -> dict.push((def-word,[word]))
                        })
            }
            Nothing -> {
                stack := do-word(stack,word)
                match (word) {
                    ":" -> if (defining.is-nothing) then defining := Just(i)
                    _   -> match (dict.find(fn(tup){val (w,_) = tup; w == word})) {
                            Just((_,ws)) -> foreach(ws) fn(w){ stack := do-word(stack,w) }
                            Nothing -> ()
                        }
                }
            }
        }
    }
}
fun do-word(stack : list<int>, word : string) {
    match (word) {
        "." -> {print([stack.last.su.show," "].join); stack.reverse.drop(1).reverse}
        "emit" -> {print(stack.last.su.char); stack.reverse.drop(1).reverse}
        "cr" -> {println(""); stack}
        "<" -> do-op(stack,fn(f,s){[if (f < s) then -1 else 0]})
        ">" -> do-op(stack,fn(f,s){[if (f > s) then -1 else 0]})
        "=" -> do-op(stack,fn(f,s){[if (f == s) then -1 else 0]})
        "+" -> do-op(stack,fn(f,s){[f + s]})
        "-" -> do-op(stack,fn(f,s){[f - s]})
        "*" -> do-op(stack,fn(f,s){[f * s]})
        "/" -> do-op(stack,fn(f,s){[f / s]})
        "dup" -> stack.push(stack.last.su)
        "drop" -> stack.reverse.drop(1).reverse
        "swap" -> do-op(stack,fn(f,s){[f,s]})
        "over" -> do-op(stack,fn(f,s){[s,f,s]})
        "rot" -> {val (rest,v)=stack.split(stack.length - 3);rest.append(v.drop(1).append(v.take(1)))}
        _ -> match(word.parse-int){Just(num) -> stack.push(num);Nothing -> stack}
    }
}
fun do-op(stack:list<int>,op:(int,int) -> list<int>){val (rest,v)=stack.split(stack.length - 2);rest.append(op(v[1].su, v[0].su))}
fun push(l:list<a>,v:a): _ list<a>{ l.append([v]) }
fun pop-do(l:list<a>,f:(a) -> <exn|e> ()): <exn|e> list<a>{val (rest, last)=l.split(l.length - 1);f(last.head.su);rest}
fun expect(v:maybe<a>,msg:string): _ a{match(v){Just(vv) -> vv;Nothing -> throw(msg)}}
fun su(v:maybe<a>): _ a{v.expect("stack underflow")}