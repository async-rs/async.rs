---
title: Announcing async-std
date: 2019-08-13
tags: release,announcement
author: "Stjepan Glavina"
---

We are happy to announce the immediate release of `async-std` `0.99.0` into beta with intent to release by end of September.

`async-std` is a library making asynchronous programming in Rust accessible to everyone.
It comes with extensive documentation, both in API and in book form, runs is easy to use and provides a stable interface to base your applications on.

## Built by experts

`async-std` is created and built by Stjepan Glavina and reuses many ideas built into the `crossbeam` crate.

## Reliable interfaces

`async-std` is a faithful port of Rusts `libstd` interface to the `async/await` world. The standard libraries interfaces are well understood and well learned by many Rust programmers. `async-std` ports many of them over, making blocking functions asynchronous.

This API strategy allowed us to quickly iterate on the core: set up a fresh and clean foundation
for a small and focused async library with clear semantics.


## `async/await` ready

`async-std` is build from the ground up to support the new programming async model coming up in Rust 1.38, along with an extensive set of coding practices derived from our previous work in the field. To that end, `async-std` does not only provide you with asynchronous versions of the io functionality found in `libstd`, but also with `async/await`-ready versions of `Mutex`.

`async-std` serves as a new start for the async ecosystem, with a fresh codebase and clearly considered semantics. We also believe that `async-std` serves as the best way to port existing single-threaded applications over to the asynchronous world.

## A powerful, single-allocation task model

Among the core `async-std` is the `async_std::task` module. Its interface resembles Rusts `std::thread` module, by automatically providing a `JoinHandle` type and a backchannel. `async-std`s tasks philosophy follows those of the Rust std API: It gives you a useful, featureful abstraction that is at the same time powerful and close to the metal. [Read the book for more on the thinking behind][tasks-book].

When a new task is constructed, it happens in a _single_ allocation. This includes allocation of all communication channels. You can read up more about how tasks work internally in the [async-task library documentation][async-task-docs].

## Teaching and Documentation

`async-std` comes with a [fully documented API][async-std-api] and a [book][async-std-book], teaching you about both using the library and writing applications in it. It should not leave any questions unanswered. This isn't true? [Please file a bug][file-bug].

`async-std`s documentation is written by experienced Rust trainers.

## A community project

`async-std` is written with the help of the community and wants to actively onboard contributors.

Over the next few weeks, we need work with testing, some outstanding documentation and optimizations of the core library. Examples and experience reports about doing so are also very welcome!

See our [contribution][contribution] section for details.

We'd like to take this moment to thank [all our contributors][contributors] up to now.

## Additional libraries

`async-std` also provides a currently unstable library for Transport Layer Security (TLS), with the intent to ship a minimal stable version together with the end release.

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
