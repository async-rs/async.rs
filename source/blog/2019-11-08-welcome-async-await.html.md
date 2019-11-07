---
title: async/.await is ready!
date: 2019-11-08
tags: release,announcement
author: "Florian Gilcher"
---

# async/.await is ready!

Today marks the release of Rust 1.39, with a finally ready `async/.await` feature.

In our [announcement blog post](https://async.rs/blog/announcing-async-std/), we communicated our intent to ship `async-std` on the release day of this feature. We will miss this deadline by a few days, but give you a short roadmap here.

The delay is caused by the `futures-rs` library, which we depend on, making their final release yesterday. We highly respect `futures-rs` timeline, the time was well spend in release polish and we congratulate the team to their release! Still, this means that we will release `async-std` a little later, to also give ourselves time for quality control and release polish. The current release date is `Monday, November 11th`.

Today, we will release `async-std` `0.9.12`, a final point release for you to play around with the new `async/.await` feature.

## The best way to try `futures-rs`

`async-std` is an easy to use, well-documented library that provides an interface very close to Rust’s standard library. It provides implementations of all important I/O types like `TcpListener`, `File` and others. It is compatible with all libraries that are using `futures-rs` as their library interface.

In practice, that means that `async_std::``stream::``Stream` can be used anywhere a `futures::``stream::``Stream` is expected and all I/O types can be used anywhere `AsyncRead` and `AsyncWrite` are expected.

`async-std` provides [a book to learn the finer details and background](https://book.async.rs), which we will keep continuously expanding. It supplements [the official async book](https://rust-lang.github.io/async-book/).

On top of that, `async-std` make spawning tasks as easy as possible. For example, `async-std` unifies blocking and non-blocking tasks in the `async``_``std::task` module under an interface similar to `std::thread``::``JoinHandle`.

```rust
use async_std::task;
use std::thread;
use std::time::Duration;

fn main() {
     task::block_on(async {
         let tasks: Vec<task::JoinHandle<()>> = vec![];
         let task = task::spawn(move {
             task::sleep(Duration::from_millis(1000)).await;
         });
         let blocking = task::spawn_blocking(move {
             thread::sleep(Duration::from_millis(1000));
         });
         tasks.push(task);
         tasks.push(blocking);
         for task in tasks {
             task.await
         }
     });
}
```

The `JoinHandle` makes it easy to spawn tasks and retrieve their results in a uniform fashion. Also, every spawned task is stored within a single allocation, making this process is quick and efficient.

See the `[task](https://docs.rs/async-std/latest/async_std/task/index.html)` module for more details.

## Current Status

`async-std` has been mainly focused on stabilising and trying out its interface over the last couple of months. We have used the time to gather confidence in out concept of the port of Rust’s `std` to the async world.

A lot of time has been spent in proper integration into the current futures library, so that you can use both the direct `async-std` interface and the `futures-rs` common traits to interact with `async-std`.

We have moved a number of newer features under the feature flag `unstable`, which acts as a stability gate similar to the `#![feature(…)]` attribute used in nightly versions of Rust’s standard library. One of those features is a very fast implementation of MPMC (Multiple Sender Multiple Receiver) channels, which will cover most usecases people might have. We’re still taking feedback on their interface.

We feel confident about the release and the stability promised it brings. The `1.0` version covers all important parts to build an async system.

## Meet us at RustFest!

Finally, meet us all at the [async/.await special edition of RustFest](https://twitter.com/RustFest/status/1192450042084376576)! We’ll be around the whole weekend, including the `impl Days`! We’re happy to assist you in making your library run on top of `async-std` or help you on your first contribution to `async-std` or related libraries.

