import std/os/file
import std/os/env
import std/os/path

fun main() {
    var stack : list<int> := []
    var dict  : list<(string,list<string>)> := []
    var defining : maybe<(int,string)> := Nothing

    val code = match (get-argv()[1]) {
        Just(v) -> read-text-file(path(v))
        Nothing -> ""
    }
    var words := code.split(" ").map(trim)

    for (0,words.length) fn(i) {
        match (words[i]) {
            Nothing -> ()
            Just(word) -> {
                match (defining) {
                    Just(dw) -> {
                        val (def-index,def-word) = dw
                        val fd = fn(tup){val (k,_) = tup; k == def-word}
                        if (def-index + 1 != i)
                        then {
                            if (word == ";")
                            then defining := Nothing
                            else dict := (match (dict.find(fd)) {
                                    Just(tup) -> {
                                        val (_,v) = tup
                                        dict.remove(fd).push((def-word,v.push(word)))
                                    }
                                    Nothing -> {
                                        dict.push((def-word,[word]))
                                    }
                                })
                        }
                    }
                    Nothing -> {
                        stack := (match (word) {
                            "." -> {
                                val (left,last) = stack.pop
                                match (last) {
                                    Just(num) -> print([show(num), " "].join())
                                    Nothing -> throw("stack underflow")
                                }
                                left
                            }
                            "emit" -> {
                                val (left,last) = stack.pop
                                match (last) {
                                    Just(num) -> print(num.char)
                                    Nothing -> throw("stack underflow")
                                }
                                left
                            }
                            "cr" -> {println(""); stack}
                            "<" -> do-op(stack,fn(f,s){[if (f < s) then -1 else 0]})
                            ">" -> do-op(stack,fn(f,s){[if (f > s) then -1 else 0]})
                            "=" -> do-op(stack,fn(f,s){[if (f == s) then -1 else 0]})
                            "+" -> do-op(stack,fn(f,s){[f + s]})
                            "-" -> do-op(stack,fn(f,s){[f - s]})
                            "*" -> do-op(stack,fn(f,s){[f * s]})
                            "/" -> do-op(stack,fn(f,s){[f / s]})
                            "dup" -> do-op(stack,fn(f,s){[s,f,f]})
                            "drop" -> do-op(stack,fn(_,s){[s]})
                            "swap" -> do-op(stack,fn(f,s){[f,s]})
                            "over" -> do-op(stack,fn(f,s){[s,f,s]})
                            "rot" -> {
                                if (stack.length >= 3)
                                then {
                                    val (rest,v) = stack.split(stack.length - 3)
                                    rest.append(v.drop(1).append(v.take(1)))
                                } else throw("stack underflow")
                            }
                            ":" -> {
                                match (words[i + 1]) {
                                    Just(word-name) -> defining := Just((i,word-name))
                                    Nothing -> ()
                                }
                                stack
                            }
                            _ -> {
                                match (word.parse-int) {
                                    Just(num) -> stack.push(num)
                                    Nothing -> {
                                        dict.find(fn(tup){val (w,_) = tup; w == word})
                                            .do-just(fn(tup){val (_,new-words) = tup; words := words.append(new-words)})
                                        stack
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }

    println("")
    println(show(stack))
}

fun do-op(stack : list<int>, op : (int,int) -> list<int>) : _ list<int> {
    val (rest,v) = stack.split(stack.length - 2)
    match (v[1]) {
        Just(first) -> match (v[0]) {
            Just(second) -> {
                rest.append(op(first,second))
            }
            Nothing -> throw("stack underflow")
        }
        Nothing -> throw("stack underflow")
    }
}

fun push(l : list<a>, v : a) : _ list<a> {
    l.append([v])
}

fun pop(l : list<a>) : _ (list<a>, maybe<a>) {
    val (rest, last) = l.split(l.length - 1)
    (rest, last.head)
}

fun do-just(v : maybe<a>, f : (a) -> e ()) : e () {
    match (v) {
        Just(value) -> f(value)
        Nothing -> ()
    }
}