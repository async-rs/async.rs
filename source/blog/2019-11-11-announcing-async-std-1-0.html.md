---
title: "Announcing async-std 1.0"
date: 2019-11-11
tags: release,announcement,party
author: "Florian Gilcher"
published: true
---

`async-std` is a port of Rust’s standard library to the async world. It comes with a fast runtime and is a pleasure to use.

We’re happy to finally announce `async-std` 1.0. As promised in our first [announcement blog post](https://async.rs/blog/announcing-async-std/), the stable release coincides with the release of Rust 1.39, the release adding `async/.await`. We would like to thank the active community around `async-std` for helping get the release through the door.

The 1.0 release of `async-std` indicates that all relevant API is in place. Future additions will be made on these stable foundations.


## Why async-std?

There are five core values behind building `async-std`:

### Stability

The Rust async ecosystem has been in flux and has seen a lot of churn during the last three years. `async-std` takes the experiences gained during that time, especially out of building `crossbeam` and `tokio` and wraps them into a package with strong stability guarantees. We are committed to lowering churn in the fundamental parts of the ecosystem.

### Ergonomics

`async-std` should be easy to use and understandable, providing a clear path to solve problems at hand. `async-std` does so by relying on familiar and proven interfaces from the standard library, combined with an API surface that solves all concerns related to `async/.await` with one dependency.

### Accessibility

`async-std` is an accessible project. As a start, it comes with full documentation of all functions, along with a book. We welcome contribution and especially like to assist people in writing additional supporting libraries.

### Integration

`async-std` wants to integrate well into the wider ecosystem and is compatible with all libraries based on `futures-rs`. We believe `futures-rs` is the cornerstone of async Rust ecosystem because it allows implementation of libraries independent of executors.

### Speed

`async-std` does not compromise on speed by shipping a fast executor that will be constantly improving over time and tweaked with incoming production  feedback. `async-std`'s goal is to ship an executor that gives great performance out of the box without the need for tuning.

## Stability guarantees

What does 1.0 mean? It means that all API that is not feature gated is now publicly committed and documented. Users are encouraged to use it liberally. We will continue to add features in additional releases over the coming week.

These improvements will follow familiar patterns: a period of being feature gated through the `unstable` feature and then stabilisation.

Due to language changes coming down the line (mostly async closures and async streams), there is a high likeliness of a 2.0 release in the future. In this case, the 1.0 line will continue being maintained for security and bug fixes and porting documents and guidelines will be provided.

## Highlights of async-std

### Easy to get started

The `async-std` interface makes it easy to start writing async programs because it uses a familiar API. This is the classic file-reading example from the stdlib:

```rust
use std::fs::File;
use std::io::{self, Read};

fn read_file(path: &str) -> io::Result<String> {
    let mut file = File::open(path)?;
    let mut buffer = String::new();
    file.read_to_string(&mut buffer)?;
    Ok(buffer)
}
```

With async-std​, all that’s needed is replace std​ with async_std​, add the prelude​, and sprinkle in a few .await​s:

```rust
use async_std::prelude::*;
use async_std::fs::File;
use async_std::io;

async fn read_file(path: &str) -> io::Result<String> {
    let mut file = File::open(path).await?;
    let mut buffer = String::new();
    file.read_to_string(&mut buffer).await?;
    Ok(buffer)
}
```

The only other addition is the prelude import.

### The task system

`async-std` comes with an innovative task system found in the [`async_std::task`](https://docs.rs/async-std/latest/async_std/task/index.html) module, shipping with an interface similar to `std::thread`.

```rust
use async_std::task::{self, JoinHandle};
use std::time::Duration;

fn main() -> io::Result<()> {
        task::block_on(async {
            let checking: JoinHandle<()> = task::spawn(async {
                task::sleep(Duration::from_millis(1000)).await;
            });

            checking.await?;
        });
}
```

The `JoinHandle` makes it easy to spawn tasks and retrieve their results in a uniform fashion. Also, it every task allocates in one go, this process is quick and efficient. `JoinHandle`s themselves are future-based, so you can use the for directly waiting for task completion.

### Futures-aware sync module

`async-std` ships with a number of futures-aware types in the `[async_std::sync](https://docs.rs/async-std/latest/async_std/sync/index.html)` module. An example:

```rust
use async_std::sync::{Arc, Mutex};
use async_std::task;

let m1 = Arc::new(Mutex::new(10));
let m2 = m1.clone();

task::spawn(async move {
    *m1.lock().await = 20;
}).await;

assert_eq!(*m2.lock().await, 20);
```

Note the `await` after `lock`. The main difference between the futures-aware `Mutex` and the `std` one is that locking becomes an `await`able operation - the task will be descheduled until the lock is available.

### A fully documented API surface

`async-std` comes with complete documentation of [all available modules](https://docs.rs/async-std/latest/async_std/index.html). We invite you to take a close look around and learn the finer details! With `async/.await` stable now, we want to make sure that you are fully informed on how to use it.

We also offer a [book](https://book.async.rs), which we will continuously expand.

### The best way to use futures-rs

`async-std` relies on `futures-rs` for interfacing with other libraries and components. `async-std` re-exports traits `Stream`, `AsyncRead`, `AsyncWrite`, `AsyncSeek` in its standard interface. It fully relies on `futures-rs` to define its types.

All `async-std` types can be used both directly as well as through the generic interfaces, making it play well with the general ecosystem. For an example of how library development on `async-std` could look like, have a look at [`async-tls`](https://github.com/async-rs/async-tls), a TLS library that works with any `futures-rs`-compatible library.

## Benchmarks

Over the last weeks, we got a lot of requests for comparative benchmarks. We believe there is currently a hyperfocus on benchmarks over ergonomics and integration in some Rust spaces and don’t want to enter the benchmark game. Still, we think it is useful for people to know where we currently stand, which is why we wanted to publish some rough comparative numbers. Posting benchmarks usually leads to other projects improving theirs, so see those numbers as the ballpark we are playing in.

**File reading**

This benchmark is based on [jebrosen’s file benchmark](https://github.com/jebrosen/async-file-benchmark). We ran it on a 256k file:

```
- tokio: 0.136 sec
- async_std: 0.086 sec
```

`async-std` is roughly 1.6x faster than `tokio` on this particular benchmark.



### Mutex benchmarks

The speed of our concurrent structures can be tested against against a number of implementations. Please note that especially `futures-intrusive` gives some options, so we tested against a similarly tuned Mutex.

`async_std::sync::Mutex`:

```
contention    ... bench:     893,650 ns/iter (+/- 44,336)
create        ... bench:           4 ns/iter (+/- 0)
no_contention ... bench:     386,525 ns/iter (+/- 368,903)
```

`futures_intrusive::sync::Mutex` with default Cargo options and with `is_fair` set to `false`:

```
contention    ... bench:   1,968,689 ns/iter (+/- 303,900)
create        ... bench:           8 ns/iter (+/- 0)
no_contention ... bench:     431,264 ns/iter (+/- 423,020)
```

`tokio::sync::Mutex`:

```
contention    ... bench:   2,614,997 ns/iter (+/- 167,533)
create        ... bench:          24 ns/iter (+/- 6)
no_contention ... bench:     516,801 ns/iter (+/- 139,907)
```

`futures::lock::Mutex`:

```
contention    ... bench:   1,747,920 ns/iter (+/- 149,184)
create        ... bench:          38 ns/iter (+/- 1)
no_contention ... bench:     315,463 ns/iter (+/- 280,223)
```

`async_std::sync::Mutex` is much faster under contention - at least 2x faster than all other implementations -  while keeping a similar performance to all competitors under no contention.

### Task benchmarks

The benchmarks test the speed of:

- Tasks spawning other tasks
- Tasks sending a message back and forth
- Spawning many tasks
- Spawning a number of tasks and frequently waking them up and shutting them down

```
name           tokio.txt ns/iter  async_std.txt ns/iter speedup

chained_spawn  123,921            119,706              x 1.04
ping_pong      401,712            289,069              x 1.39
spawn_many     5,326,354          3,149,276            x 1.69
yield_many     7,640,958          3,919,748            x 1.95
```

`async-std` is up to twice as fast as `tokio` when spawning tasks.

You can find the benchmark sources here: https://github.com/stjepang/tokio/

Run them using:

```
$ cargo run --release --bin tokio
$ cargo run --release --bin async-std
```

### Summary

We present these benchmarks to illustrate that `async-std` does not compromise in performance. When it comes to the core primitives, `async-std` performance is as good or better than its competitors.

Note that these are microbenchmarks and should always be checked against behaviour in your actual application. For example, an application with low contention on mutexes will not benefit from their performance.

## Recognition

Since our release, we had 59 people contributing code, documentation fixes and examples to `async-std`. We want to specifically highlight some of them:


- [taiki-e](https://github.com/taiki-e)  for keeping dependencies up to date, setting up continuous integration, and writing amazing crates like pin-project that make writing async libraries so much easier
- [k-nasa](https://github.com/taiki-e) for work contributing stream combinators and a lot of other pull requests
- [montekki](https://github.com/montekki) for implementing stream combinators and bringing `Stream` close to parity with `Iterator`
- [zkat](https://github.com/zkat) for early testing, benchmarks, advice, and `cacache`, the first library written on top of `async-std`
- [sunjay](https://github.com/sunjay) for authoring almost 60 `FromStream` implementations, making our `collect` method as easy to use as `std`'s.
- [Wassasin](https://github.com/wassasin) for work on streams and implementing the `path` module.
- [dignifiedquire](https://github.com/dignifiedquire/) for early testing, continuous feedback, implementing some async trait methods, as well as core async primitives such as `Barrier`.
- [felipesere](http://github.com/felipesere) for their work on stream adapters.
- [yjhmelody](http://yjhmelody) for their work on stream adapters.

Thank you! ❤

## Upcoming Features

Many teasing new features are currently behind the `unstable` feature gate. They are mainly there for final API review, and can be used in production.

### Fast channels

`async-std` implements fast async MPMC (Multiple Producer, Multiple Consumer) channels based on the experience gained in `crossbeam`.

```rust
use std::time::Duration;

use async_std::sync::channel;
use async_std::task;

let (s, r) = channel(1);

// This call returns immediately because there is enough space in the channel.
s.send(1).await;

task::spawn(async move {
    // This call will have to wait because the channel is full.
    // It will be able to complete only after the first message is received.
    s.send(2).await;
});

task::sleep(Duration::from_secs(1)).await;
assert_eq!(r.recv().await, Some(1));
assert_eq!(r.recv().await, Some(2));
```

MPMC channels solve all important use cases naturally, particularly also multiple producer, single consumer use-cases.

All `async-std` channels are *bounded*, which means the sender has to wait with sending if the channel is over capacity, leading to natural backpressure handling.

### More task spawning APIs

The task module is currently gaining the `spawn_blocking` and `yield_now` functions.

[`spawn_blocking`](https://docs.rs/async-std/latest/async_std/task/fn.spawn_blocking.html) allows you to spawn tasks which are known to be blocking the currently running thread (which is the current executor thread).

[`yield_now`](https://docs.rs/async-std/latest/async_std/task/fn.yield_now.html) allows long running computations to actively interrupt themselves during execution, giving up time to other concurrent tasks cooperatively.

## Conclusion

In this post, we have presented the ergonomics and performance characteristics of `async-std`, as well as its stability guarantees. We want to spend the next few weeks with the following tasks:

- Holidays
- Stabilizing unstable APIs at a regular cadence
- Fill remaining API gaps
- Extending the book, especially around general usage patterns
- Starting to work on additional ecosystem libraries, for example `async-tls`

`async-std` is funded by [Ferrous Systems](https://ferrous-systems.com) and [Yoshua Wuyts](https://blog.yoshuawuyts.com) personally. To allow for further growth and sustainability, we have an offer out on [OpenCollective](https://opencollective.com/async-rs/).

We're incredibly happy to bring `async-std` to stability. We hope you enjoy building on top of it as much as we enjoyed building it! `async-std` is a step forward for `async/.await` ergonomics in Rust and enables you to build both fast and maintainable asynchronous Rust programs.
