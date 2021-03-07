import std/time
import std/time/timestamp

pub alias async = <alloc<global>,div,exn,ndet,utc,read<global>,write<global>>

pub struct future<r,s> {
    state : ref<global,future-state<r,s>>
    poll_stt : (s) -> async future-state<r,s>
}

pub type future-state<r,s> {
    Resolved(value : r)
    Pending(state : s)
}

/// Creates a new pending future with the given state and poll function.
pub fun future(state : s, poll_stt : forall<e> (s) -> (<async|e>) future-state<r,s>) : _ future<r,s> {
    Future(ref(Pending(state)), poll_stt)
} 

/// Tries to "await" the future and returns the value if it's resolved.
pub fun try-await(fut : future<r,s>) : _ maybe<r> {
    val r = fut.state
    match (!r) {
        Resolved(value) -> Just(value)
        _ -> Nothing
    }
}

/// Blocks the current thread and runs the future to completion.
pub fun await(fut : future<r,s>) : _ r {
    fut.poll
    match (fut.try-await) {
        Just(value) -> value
        Nothing -> fut.await
    }
}

/// Polls the future. Does nothing if future is already resolved. 
pub fun poll(fut : future<r,s>) {
    val r = fut.state
    match (!r) {
        Pending(state) -> r := fut.poll_stt()(state)
        _ -> ()
    }
}