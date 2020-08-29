---
title: Announcing async-std
date: 2019-08-16
tags: release,announcement
author: "The async-std developers"
---

We are excited to announce a beta release of `async-std` with the intent to publish version `1.0` by *September 26th, 2019*.

`async-std` is a library that looks and feels like the Rust standard library, except everything in it is made to work with `async`/`await` exactly as you would expect it to.

The library comes with a [book][async-std-book] and polished [API documentation][async-std-api], and will soon provide a stable interface to base your async libraries and applications on. While we don't promise API stability before our `1.0` release, we also don't expect to make any breaking changes.

## Overview

Consider the following code using blocking filesystem APIs to read from a file:

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

To make `read_file` asynchronous, it would be great if we could just sprinkle the code with `async`/`await` keywords where appropriate. That kind of experience is exactly what `async-std` offers:

```rust
use async_std::fs::File;
use async_std::io::{self, Read};

async fn read_file(path: &str) -> io::Result<String> {
    let mut file = File::open(path).await?;
    let mut buffer = String::new();
    file.read_to_string(&mut buffer).await?;
    Ok(buffer)
}
```

Another interesting highlight is the [task][tasks-book] module, providing an interface that feels similar to the [`thread`][std-thread] module from the standard library. Running a concurrent task using `async-std` is as easy as spawning a thread:

```rust
use async_std::task;
use std::time::Duration;

fn main() {
    let task = task::spawn(async {
        task::sleep(Duration::from_millis(1000)).await;
        println!("done");
        "hello"
    });

    task::block_on(async {
        println!("waiting for the task");
        let res = task.await;
        println!("task ended with result {:?}", res);
    });
}
```

When run, this program prints the following:

```
waiting for the task
done
task ended with result "hello"
```

Spawned tasks can be awaited the same way spawned threads can be joined. It is also possible to declare task-local variables that work exactly like thread-local variables. You can really think of tasks as lightweight threads and treat them that way!

If you'd like a longer tour around the library, head over to our [chat tutorial][chat-tutorial].

## A fresh start for `async`/`await`

`async-std` is designed to support the new async programming model (to be stabilized in Rust 1.39), along with a set of coding practices derived from our previous experience in the field. To that end, `async-std` not only provides you with async versions of the I/O functionality found in `std`, but also with async versions of concurrency primitives like `Mutex` and `RwLock`.

`async-std` comes with a fresh codebase and carefully thought out semantics. It is a faithful port of Rust's standard library, sticking to its tried-and-true interface, with only minimal differences where absolutely necessary.

By mimicking standard library's well-understood APIs as closely as possible, we hope users will have an easy time learning how to use `async-std` and switching from thread-based blocking APIs to asynchronous ones. If you're familiar with Rust's standard library, very little should come as a surprise.

## Relationship to `futures` and other libraries

`async-std` is a standalone library based on the [`Future`][future-trait] trait and supporting set of traits from the [`futures`](https://github.com/rust-lang-nursery/futures-rs) library.

Since parts of the `futures` API is still in active development and we want to provide strong stability guarantees to our users, we're relying on a minimal and most stable set of traits from `futures`.

At the same time, we're serious about compatibility with the whole async ecosystem and therefore have put effort into designing the API in such a way that does not put our crate above other similar ones, or lock users into our ecosystem. We do not require compatibility layers or any extra setup to use `async-std` with other libraries like `futures`.

## Efficient single-allocation tasks

One of the promises of zero-cost futures in Rust has always been that every spawned task incurs the cost of a single allocation only. However, that has always been a white lie... or at least until today.

Most executors typically perform two allocations per spawn, one for the task state and one for the future. Additionally, in order to await the result of a task, a oneshot channel is typically used, which creates a third allocation.

In order to reduce the amount of allocation, we've implemented a library called [async-task][async-task] that performs a single allocation per spawned task, and is able to await the result of the task without creating an extra channel. That gets us from three allocations per spawn to just a single allocation!

We will follow up with more blog posts on interesting performance tidbits.

## Teaching, documentation, and help

`async-std` comes with a [fully documented API][async-std-api] and a [book][async-std-book], teaching you about both using the library and writing libraries or applications in it.

We treat documentation as a first-class feature, so if you find anything in it confusing, please [file an issue][file-bug] or ask questions in our [Discord channel][discord]. Documentation is at the core of our promise and we're always eager to improve it!

## The path towards 1.0

`async-std` is currently in beta. We're aiming for a stable release by _September 26th, 2019_, on the same day beta release of [Rust 1.39][forge] comes out.

The initial version number `0.99` expresses how close we are to `1.0`. `async-std` will remain in beta until `async`/`await` is on a committed track to stabilization.

During our beta period, we will release a new patch version for API extensions and backwards-compatible changes, and a new minor version for breaking changes. In the ideal scenario, we will manage without any breaking changes towards `1.0`.

## Security and reliability

`async-std` has documented [SemVer][semver] and [security practices][security].

We use a small number of well-vetted and checked dependencies, implementing all the core primitives `async-std` needs.

## Community involvement

`async-std` was developed by [Stjepan Glavina](https://github.com/stjepang) in collaboration with [Yoshua Wuyts](https://github.com/yoshuawuyts) and reuses many ideas from [`crossbeam`](https://github.com/crossbeam-rs/crossbeam) that have been successful in the area of concurrency throughout the Rust ecosystem.

It is designed and implemented with feedback from the industry and open source community. Now that the library is finally published, we'd like to welcome broader community of contributors. Over the next few weeks, we need work with testing, filling in remaining gaps in the API, and writing more documentation. Examples and experience reports are also very welcome!

See our [contribution][contribution] section for details. Want to help out? Feel free to grab one of the [good first issues][good-first-issues].

## Thanks and sponsoring

Thanks to all contributors and early users for providing us feedback during development!

Finally, thanks to [Ferrous Systems][ferrous-systems] for funding this project! If you'd like to help fund development on `async-std`, please get in contact with us.

[chat-tutorial]: https://github.com/async-rs/a-chat
[async-task-docs]: https://docs.rs/async-task
[tasks-book]: https://book.async.rs/concepts/tasks.html
[async-std-book]: https://book.async.rs
[async-std-api]: https://docs.rs/async-std
[file-bug]: https://github.com/async-rs/async-std/issues/new
[semver]: https://book.async.rs/overview/stability-guarantees.html
[security]: https://book.async.rs/security/policy.html
[contribution]: /contribute
[contributors]: https://github.com/async-rs/async-std/blob/master/CONTRIBUTORS.md
[forge]: https://forge.rust-lang.org/
[ferrous-systems]: https://ferrous-systems.com
[good-first-issues]: https://github.com/async-rs/async-std/issues?q=is%3Aopen+is%3Aissue+no%3Amilestone+label%3A%22good+first+issue%22
[discord]: https://discord.gg/JvZeVNe
[std-thread]: https://doc.rust-lang.org/std/thread/index.html
[future-trait]: https://doc.rust-lang.org/nightly/std/future/trait.Future.html
[futures-rs]: https://github.com/rust-lang-nursery/futures-rs
[async-task]: https://github.com/async-rs/async-task
