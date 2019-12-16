---
title: "Stop worrying about blocking: the new async-std runtime, inspired by Go"
date: 2019-12-16
tags: release,announcement,christmas
author: "Stjepan Glavina"
---

`async-std` is a mature and stable port of the Rust standard library to its new `async/await` world, designed to make async programming easy, efficient, worry- and error-free.

We announced [async-std](https://async.rs/) on August 16th - exactly 4 month ago. Our focus for the initial release was providing a stable and reliable API for users to build async applications on, modelled after Rust standard library. It came with a number of innovative implementations: The first implementation of a `JoinHandle` based task API and single-allocation tasks.

Today, we’re introducing the new [async-std](https://async.rs/) runtime. It features a lot of improvements, but the main news is that it eliminates a major source of bugs and performance issues in concurrent programs: accidental blocking.

In summary:

- The new runtime is **really fast** and outperforms the old one.
- The new runtime is **universal** in the sense that it adapts to different workloads automatically, becoming single-threaded or multi-threaded on demand. If a single thread can handle all the work, we don’t pay the price of work-stealing.
- The new runtime is **conceptually simpler**, by removing the split between the non-blocking and the blocking threadpool.
- The new runtime **detects blocking** automatically. We don’t need `[spawn_blocking](https://docs.rs/async-std/1.2.0/async_std/task/fn.spawn_blocking.html)` anymore and can simply deprecate it.
- The new runtime makes **blocking efficient**. Rather than always paying the cost of `spawn_blocking`, we only offload blocking work to a separate thread if the work really blocks.

The new task scheduling algorithm and the blocking strategy are adaptations of ideas used by the Go runtime to Rust.


## The problem of blocking

Until today, a constant source of frustration when writing async programs in Rust was the possibility of *accidentally* *blocking* the executor thread when running a task. To avoid that problem, `async-std` used to provide the unstable `spawn_blocking` function that moves potentially blocking work onto a special thread pool so that the executor thread can keep making progress.

However, `spawn_blocking` is not a bulletproof solution because we have to remember to invoke it manually every time we expect to block. But it’s very difficult to even reliably predict what kind of code *can* block. Programmers have to carefully separate async and blocking code, which is an infamous problem discussed by the blog post titled [*What Color Is Your Function*](https://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/).

Separation of code gets even harder when you consider that operations that may block *the current executor thread* include plain expensive computations, such as transforming an image or sorting lots of data. Conversely, sometimes we’ll pessimistically assume some code blocks while in practice it may be very quick, which means we’re paying the price of `spawn_blocking` even when don’t have to.

With the new `async-std` runtime, such difficulties become a thing of the past: should a task execute for too long, the runtime will automatically react by spawning a new executor thread taking over the current thread’s work. This strategy eliminates the need for separating async and blocking code.

## A concrete example

To illustrate what all this means in practice, let’s use `std::fs::read_to_string` as an example of a blocking operation. The [async version](https://docs.rs/async-std/1.3.0/async_std/fs/fn.read_to_string.html) of it used to be implemented as follows:

```rust
async fn read_to_string<P: AsRef<Path>>(path: P) -> io::Result<String> {
    let path = path.as_ref().to_owned();
    spawn_blocking(move || std::fs::read_to_string(path)).await
}
```

Note two crucial things:

- We call `spawn_blocking` to isolate the blocking operation.
- We always clone the path and execute the blocking operation on a separate threadpool, even if the file is cached and will be read in an instant.

The new runtime relieves you of these concerns and allows you to do the blocking operation directly inside the async function:

```rust
async fn read_to_string(path: impl AsRef<Path>) -> io::Result<String> {
    std::fs::read_to_string(path)
}
```

The runtime measures the time it takes to perform the blocking operation and if it takes a while, a new thread is automatically spawned and replaces the old executor thread. That way, only the current task is blocked on the operation rather than the whole executor thread or the whole runtime. If the blocking operation is quick, we don’t spawn a new thread and therefore no additional cost is inflicted.

If you still want to make sure the operation runs in the background and doesn’t block the current task either, you can *still* simply spawn a regular task and do the blocking work inside it:

```rust
async fn read_to_string(path: impl AsRef<Path>) -> io::Result<String> {
    let path = path.as_ref().to_owned();
    spawn(async move { std::fs::read_to_string(path) }).await
}
```

Note the use of `spawn` instead of `spawn_blocking`.

Web frameworks commonly need asynchronous I/O while performing substantial work per request. The new runtime enables you to fearlessly use synchronous libraries like `diesel` or `rayon` in any `async-std` application.

## Benchmarks

In our initial tests, the new scheduler performs better then our old one, while still staying small and well understandable.

The following benchmark was run on two EC2 instances . A [minihttp](https://github.com/stjepang/minihttp) server based on the old runtime (`master` branch) and the new runtime (`new-scheduler` branch) runs on an m5a.8xlarge instance, while [wrk](https://github.com/wg/wrk) (a benchmark tool) runs on a separate m5a.16xlarge instance.

The benchmark has three different scenarios with different arguments passed to wrk. Option `-t` configures the number of threads, `-c` configures the number of TCP connections, and `-d` configures the duration of benchmark in seconds. See the [readme](https://github.com/stjepang/minihttp/blob/master/README.md) for more details on how to run the benchmark.


![Graph of different benchmarks. wrk -t1 -c50 -d10: new scheduler is 2 times faster. wrk -t10 -c50 -d10: new scheduler is 5 times faster. wrk -t1 -c500 -d10: new scheduler is 15 times faster](/images/async-std-http-benchmark-new-vs-old-scheduler.svg)


The new runtime is faster in general and scales way better to take available resources.

## Small and well-documented

The new runtime is small, uses no `unsafe` and is documented. Please take a look at [the source](https://github.com/stjepang/async-std/tree/new-scheduler/src/rt) to see how it works. Feel free to ask questions on the [pull request]( https://github.com/async-rs/async-std/pull/631)! There are still plenty of optimization opportunities and we will continue to blog about those details!

## Trying it out

To try out the new scheduler before release, modify your `Cargo.toml` this way:

```toml
async-std = { git = 'https://github.com/async-rs/async-std', branch = 'new-scheduler' }
```

Please report on your experiences - and report potential bugs!


## Summary

The new `async-std` runtime relieves programmers of the burden of isolating blocking code from async code. You simply don’t have to worry about it any more.

The adaptive nature of the new runtime allows it to use *less* resources when multithreading does not bring any benefit. This improves performance in CLI tools and lowers the latency in web servers. At the same time, the runtime will scale up to use all available resources during intense workloads.

All these changes make it easier to write async programs while *also* making them more efficient and reliable!

We would like to thank [_all contributors to async-std_](https://github.com/async-rs/async-std/graphs/contributors), big and small, new and long-term and all the library authors building great stuff for the Rust async ecosystem!
