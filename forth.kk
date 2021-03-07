import std/os/file
import std/os/env
import std/os/path

fun main() {
    var stack : list<int> := list(vector())
    var dict  : list<(string, vector<string>)> := list(vector())

    val code = match (get-argv()[1]) {
        Just(v) -> read-text-file(path(v))
        Nothing -> ""
    }
    var words := code.split(" ").map(trim)

    for(0,words.length) fn(i) {
        match (words[i]) {
            Nothing -> ()
            Just(word) -> {
                stack := (match (word) {
                    "." -> {
                        stack.last().do-just(fn(num){ print([show(num), " "].join()) })
                        stack.reverse.drop(1).reverse
                    }
                    "emit" -> {
                        stack.last().do-just(fn(num){ print(num.char) })
                        stack.reverse.drop(1).reverse
                    }
                    "cr" -> {println(""); stack}
                    "<" -> do-op(stack,fn(f,s){if (f < s) then -1 else 0})
                    ">" -> do-op(stack,fn(f,s){if (f > s) then -1 else 0})
                    "=" -> do-op(stack,fn(f,s){if (f == s) then -1 else 0})
                    "+" -> do-op(stack,fn(f,s){f + s})
                    "-" -> do-op(stack,fn(f,s){f - s})
                    "*" -> do-op(stack,fn(f,s){f * s})
                    "/" -> do-op(stack,fn(f,s){f / s})
                    "dup" -> {stack.last().do-just(fn(num){stack := stack.push(num)}); stack}
                    "drop" -> stack.reverse.drop(1).reverse
                    "swap" -> {
                        if (stack.length >= 2)
                        then {
                            val (rest,v) = stack.split(stack.length - 2)
                            rest.append(v.reverse)
                        } else throw("no value left on stack to swap")
                    }
                    "over" -> {
                        if (stack.length >= 2)
                        then {
                            stack[stack.length - 2].do-just(fn(num){stack := stack.push(num)})
                            stack
                        } else throw("no value left on stack to over")
                    }
                    "rot" -> {
                        if (stack.length >= 3)
                        then {
                            val (rest,v) = stack.split(stack.length - 3)
                            val to-top = v.take(1)
                            rest.append(v.drop(1).append(to-top))
                        } else throw("no value left on stack to rot")
                    }
                    _ -> {
                        match (word.parse-int) {
                            Just(num) -> stack.push(num)
                            Nothing -> {
                                dict.find(fn(tup){val (w,_) = tup; w == word})
                                    .do-just(fn(tup){val (_,new-words) = tup; words := words.append(new-words.list)})
                                stack
                            }
                        }
                    }
                })
            }
        }
    }

    println("")
    println(show(stack))
}

fun do-op(stack : list<int>, op : (int,int) -> int) : _ list<int> {
    val (rest,v) = stack.split(stack.length - 2)
    match (v[1]) {
        Just(first) -> match (v[0]) {
            Just(second) -> {
                rest.push(op(first,second))
            }
            Nothing -> throw("no value on stack left to op")
        }
        Nothing -> throw("no value on stack left to op")
    }
}

fun push(l : list<a>, v : a) : _ list<a> {
    l.append([v])
}

fun do-just(v : maybe<a>, f : (a) -> e ()) : e () {
    match (v) {
        Just(value) -> f(value)
        Nothing -> ()
    }
}