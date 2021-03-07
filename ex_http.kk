import log
import http/core
import async/core
import std/time

fun main() {
    with pretty-logger(Dbg, Dbg)

    val client = HttpClient()
    val req = Request("http://google.com").method(POST)
    println(client.execute(req).await)
}