import async/core
import std/time
import std/time/timestamp

/// Maps the future `Resolved` value.
pub fun map( fut : future<r,s>, f : r -> async b ) : async future<b,s> {
    val mapped_fn = fn(stt) {
        match (fut.poll_stt()(stt)) {
            Resolved(value) -> Resolved(f(value))
            Pending(state) -> Pending(state)
        }
    }

    val r = fut.state
    match (!r) {
        Resolved(value) -> Future(ref(Resolved(f(value))), mapped_fn)
        Pending(state) -> Future(ref(Pending(state)), mapped_fn)
    }
}

/// Creates a future that will "sleep" for an amount of time.
pub fun sleep(dur : duration) {
    future(now(), fn<e>(since : instant) : (<async|e>) future-state<(),instant> {
        if (now() - since > dur)
        then Resolved(())
        else Pending(since)
    })
}

/// Creates a future that never resolves.
pub fun never() {
    future((), fn(_) { Pending(()) })
}

/// Creates a future that is resolved on creation.
pub fun resolved(value : r) : _ future<r, ()> {
    Future(ref(Resolved(value)), fn(_) { Pending(()) })
}

/*
alias select_result<r,s,z,x> = (either<future<r,s>, future<z,x>>, either<future<r,s>, future<z,x>>)
alias select_state<r,s,z,x> = (future<r,s>, future<z,x>)

pub fun select(fut1 : future<r,s>, fut2 : future<z,x>)
    : _ future<select_result<r,s,z,x>, select_state<r,s,z,x>>
{
    future(
        (fut1,fut2),
        fn<e>(stt) : <async|e> future-state<select_result<r,s,z,x>, select_state<r,s,z,x>> {
            stt.fut1.poll
            if (stt.fut1.try-await.is-just)
            then Resolved((Left(stt.fut1), Right(stt.fut2)))
            else {
                stt.fut2.poll
                if (stt.fut2.try-await.is-just)
                then Resolved((Left(stt.fut2), Right(stt.fut1)))
                else Pending(stt)
            }
        }
    )
}

pub fun join(fut1 : future<a,b>, fut2 : future<c,d>) : _ future<select_state<a,b,c,d>, select_state<a,b,c,d>> {
    future(
        (fut1, fut2),
        fn<e>(stt) : <async|e> future-state<select_state<a,b,c,d>, select_state<a,b,c,d>> {
            stt.fut1.poll; stt.fut2.poll
            if (stt.fut1.try-await.is-just && stt.fut2.try-await.is-just)
            then Resolved(stt)
            else Pending(stt)
        }
    )
}*/