import log

fun do-something() {
    log("doing something")
    val x = 2 + 2
    println(x)
    log("oops, error", Err)
}

fun main() {
    with pretty-logger(Dbg, Dbg)
    do-something()
}