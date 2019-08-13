---
title: Announcing async-std
date: 2019-08-13
tags: release,announcement
author: "Stjepan Glavina"
---

We are happy to announce the immediate release of `async-std` `0.99.0` into beta with intent to release by end of September.

`async-std` is a library making asynchronous programming in Rust accessible to everyone.
It comes with extensive documentation in both in API and in book form, is easy to use, and provides a stable interface to base your applications on.

## Built by experts

`async-std` is created and built by [Stjepan Glavina](https://github.com/stjepang) and reuses many ideas from [`crossbeam`](https://crates.io/crates/crossbeam) that have been successful in high-performance contexts throughout the Rust ecosystem.

## Reliable interfaces

`async-std` is a faithful port of Rust's `libstd` interface to the `async/await` world. The standard library's interfaces are well-understood and well-learned by many Rust programmers. `async-std` ports many of them over, making its blocking functions asynchronous.

This API strategy allows for quick iteration on the core: setting up a fresh and clean foundation for a small and focused async library with clear semantics. If you're familiar with Rust's standard library, very little should come as a surprise.

## `async/await` ready

`async-std` is built from the ground up to support the new async programming model coming up in Rust 1.38, along with an extensive set of coding practices derived from our previous work in the field. To that end, `async-std` does not only provide you with asynchronous versions of the io functionality found in `libstd`, but also with `async/await`-ready versions of `Mutex` and `RwLock`.

`async-std` serves as a new start for the async ecosystem, with a fresh codebase and clearly considered semantics. We also believe that `async-std` serves as the best way to port existing single-threaded applications over to the asynchronous world.

## A powerful, single-allocation task model

Among the core `async-std` is the `async_std::task` module. Its interface resembles Rusts `std::thread` module, by automatically providing a `JoinHandle` type and a backchannel. `async-std`s task philosophy follows those of the Rust std API: It gives you a useful, featureful abstraction that is at the same time powerful and close to the metal. [Read the book for more on the thinking behind][tasks-book].

When a new task is constructed, it happens in a _single_ allocation. This includes allocation of all communication channels. You can read up more about how tasks work internally in the [async-task library documentation][async-task-docs].

## Teaching and Documentation

`async-std` comes with a [fully documented API][async-std-api] and a [book][async-std-book], teaching you about both using the library and writing applications in it. We see documentation as a first class feature, so if something is confusing, please [file an issue][file-bug]!.

`async-std`s documentation is written by experienced Rust trainers.

## A community project

`async-std` is written with the help of the community and wants to actively onboard contributors.

Over the next few weeks, we need work with testing, some outstanding documentation and optimizations of the core library. Examples and experience reports about doing so are also very welcome!

See our [contribution][contribution] section for details.

We'd like to take this moment to thank [all our contributors][contributors] up to now.

## Additional libraries

`async-std` also provides a currently unstable library for Transport Layer Security (TLS), called `async-tls`, with the intent to ship a minimal stable version together with the first stable release. `async-tls` does not depend on `async-std`.

## Security and reliability

`async-std` has documented [SemVer][semver] and [security practices][security].

## Trusted dependencies

`async-std` is based on a small number of well-vetted and checked libraries, implementing all the core primitives `async-std` needs.

## Timeline

`async-std` is currently in Beta. We're aiming for a full release by _September 26th, 2019_, with the stable release of [Rust 1.38][forge].

TODO: more timeline and github milestones

## Thanks and Sponsoring

Thanks for all contributors, users and people giving us feedback in the time coming up the release.

Also thanks to [Ferrous Systems][ferrous-systems] for funding this effort.

[async-task-docs]: TODO
[tasks-book]: TODO
[async-std-book]: TODO
[async-std-api]: TODO
[file-bug]: TODO
[semver]: TODO
[security]: TODO
[contribution]: /contribute
[contributors]: TODO
[forge]: https://forge.rust-lang.org/
[ferrous-systems]: https://ferrous-systems.com
