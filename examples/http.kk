import log
import http

fun main() {
    with pretty-logger(Dbg, Dbg)

    val client = HttpClient()
    val req = Request("http://google.com").method(POST)
    client.execute(req)
}