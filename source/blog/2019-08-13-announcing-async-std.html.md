---
title: Announcing async-std
date: 2019-08-13
tags: release,announcement
author: "Stjepan Glavina"
---

We are happy to announce the immediate release of `async-std` `0.99.0` into beta with intent to release by end of September.

`async-std` is a library making asynchronous programming in Rust accessible to everyone.
It comes with extensive documentation in both in API and in book form, is easy to use, and provides a stable interface to base your applications on.

## Overview

Have you ever wondered what it would be like if async version of this code:

```rust
use std::{
    io,
    io::Read,
    fs,
};

fn read_file(path: &str) -> io::Result<String> {
    let mut file = fs::File::open(path)?;
    let mut buffer = String::new();
    file.read_to_string(&mut buffer)?;
    Ok(buffer)
}
```

was just this?

```rust
use async_std::{
    io,
    io::Read,
    fs,
};

async fn read_file(path: &str) -> io::Result<String> {
    let mut file = fs::File::open(path).await?;
    let mut buffer = String::new();
    file.read_to_string(&mut buffer).await?;
    Ok(buffer)
}
```

That's exactly what `async-std` gives you! But this is just the start of it. `async-std` is a small, stable, and familiar foundation for your application. Another highlight the [task][task-module] module. Running a concurrent task in `async_std` is as easy as spawning a thread.

```rust
use async_std::task;
use std::time::Duration;

fn main() {
    let task = task::spawn(async {
        task::sleep(Duration::from_millis(1000));
        println!("done");
    });

    // we are free to do stuff here

    task::block(async {
        println!("starting to wait for task");
        task.await;
        println!("task ended");
    });
}
```

Does this spark your interest? Then go read through our [documentation][async-std-api], the [book][async-std-book] and especially the great [chat tutorial][chat-tutorial]!

## `async/await` ready

`async-std` is built from the ground up to support the new async programming model coming up in Rust 1.39, along with an extensive set of coding practices derived from our previous work in the field. To that end, `async-std` does not only provide you with asynchronous versions of the io functionality found in `libstd`, but also with `async/await`-ready versions of concurrency primitives like `Mutex` and `RwLock`.

`async-std` serves as a new start for the async ecosystem, with a fresh codebase and clearly considered semantics. We also believe that `async-std` serves as the best way to port existing single-threaded applications over to the asynchronous world.

## Teaching and Documentation

`async-std` comes with a [fully documented API][async-std-api] and a [book][async-std-book], teaching you about both using the library and writing applications in it. We see documentation as a first class feature, so if something is confusing, please [file an issue][file-bug]!.

Documentation is at the core of our promise and we're happy about any help!

## Built by experts

`async-std` is created and built by [Stjepan Glavina](https://github.com/stjepang) and reuses many ideas from [`crossbeam`](https://crates.io/crates/crossbeam) that have been successful in high-performance contexts throughout the Rust ecosystem. It is designed and implemented with the feedback of industry and open source professionals.
We'd like to give everyone a big thanks for their help in figuring out requirements.

## Reliable interfaces

`async-std` is a faithful port of Rust's `libstd` interface to the `async/await` world. The standard library's interfaces are well-understood and well-learned by many Rust programmers. `async-std` ports many of them over, making its blocking functions asynchronous.

This API strategy allows for quick iteration on the core: setting up a fresh and clean foundation for a small and focused async library with clear semantics. If you're familiar with Rust's standard library, very little should come as a surprise.

## A powerful, single-allocation task model

Among the core `async-std` is the `async_std::task` module. Its interface resembles Rusts `std::thread` module, by automatically providing a `JoinHandle` type and a backchannel. `async-std`s task philosophy follows those of the Rust std API: It gives you a useful, featureful abstraction that is at the same time powerful and close to the metal. [Read the book for more on the thinking behind][tasks-book].

When a new task is constructed, it happens in a _single_ allocation. This includes allocation of all communication channels. You can read up more about how tasks work internally in the [async-task library documentation][async-task-docs].

## Relationship to `futures-rs`

`async-std` is a standalone library based on `std::futures::Future` that can be used with and without `futures-rs`. It integrates with `futures-rs` and enables you to pick the stability guarantee you want and need.

## A community project

`async-std` is written with the help of the community and wants to actively onboard contributors. Over the next few weeks, we need work with testing, some outstanding documentation and optimizations of the core library. Examples and experience reports about doing so are also very welcome! We're also interested in larger software pieces to use and trace.

See our [contribution][contribution] section for details. Want to help out? Feel free to grab one of the [good first issues][good-first-issues].

We'd like to take this moment to thank [all our contributors][contributors] up to now.

## Security and reliability

`async-std` has documented [SemVer][semver] and [security practices][security].

## Trusted dependencies

`async-std` is based on a small number of well-vetted and checked libraries, implementing all the core primitives `async-std` needs.

## Timeline

`async-std` is currently in Beta. We're aiming for a full release by _September 26th, 2019_, with the beta release of [Rust 1.39][forge].

TODO: more timeline and github milestones

## Why 0.99?

The version number `0.99` expresses how close we are to `1.0`. `async-std` will remain in beta until we feel `async/await` is finally on the track to stabilisation. During the beta period, we will relase a new PATCH version for API extensions and backwards-compatible changes, and a new MINOR version for breaking changes. Ideally, we can manage without a breaking change towards `1.0`.

Using a version number below `1.0` instead of a `beta` suffix also avoids accidental upgrades with breaking changes.

## Thanks and Sponsoring

Thanks for all contributors, users and people giving us feedback in the time coming up the release.

Also thanks to [Ferrous Systems][ferrous-systems] for funding this effort.

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
