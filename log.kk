pub effect fun log(msg: string, level : ?log-level) : ()

pub type log-level {
    Err
    Dbg
    Inf
}

fun prio(level : log-level) : _ int {
    match(level) {
        Err -> 0
        Inf -> 1
        Dbg -> 2
    }
}

pub fun pretty-logger(max-lvl : log-level, def-lvl : log-level, action) {
    with fun log(msg, level) {
        val lvl = match(level) {
            Optional(value) -> value
            None -> def-lvl
        }
        if (lvl.prio() > max-lvl.prio())
        then return ()
        val text = match(lvl) {
            Err -> "ERROR"
            Dbg -> "DEBUG"
            Inf -> "INFO"
        }
        print("[")
        print(text)
        print("] ")
        println(msg)
    }
    action()
}