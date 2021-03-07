import std/os/file
import std/os/env
import std/os/path

fun main() {
    var stack : list<int> := list(vector())

    val code = match (get-argv()[1]) {
        Just(v) -> read-text-file(path(v))
        Nothing -> ""
    }
    val words = code.split(" ").map(trim)

    for(0,words.length) fn(i) {
        match (words[i]) {
            Nothing -> ()
            Just(word) -> {
                stack := (match (word) {
                    "." -> {
                        stack.last().do-just(fn(num){ print([show(num), " "].join()) })
                        stack
                    }
                    "+" -> do-op(stack,fn(f,s){f + s})
                    "-" -> do-op(stack,fn(f,s){f - s})
                    "*" -> do-op(stack,fn(f,s){f * s})
                    "/" -> do-op(stack,fn(f,s){f / s})
                    _ -> {
                        match (word.parse-int) {
                            Just(num) -> stack.push(num)
                            Nothing -> stack
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
    val (rest, v) = stack.split(stack.length - 2)
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