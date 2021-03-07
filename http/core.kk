import log
import async/utils
import std/time
import std/time/timestamp

pub type request-method {
    GET
    POST
}

pub struct request {
    host : string
    method : request-method = GET
}

pub fun host(req : request, new_host : string) : _ request {
    req(host = new_host)
}

pub fun method(req : request, new_method : request-method) : _ request {
    req(method = new_method)
}

pub struct httpClient {
    // TODO: what to put here?
}

pub fun execute(client: httpClient, req: request) {
    match (req.method) {
        GET -> log("GET-ing request", Dbg)
        POST -> log("POST-ing request", Dbg)
    }

    sleep(duration(1)).map(fn(_) { "response" })
}