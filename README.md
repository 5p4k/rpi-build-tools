RPi Build Tools
===

**Official repo: ** [https://git.mittelab.org/5p4k/rpi-build-tools][repo_url]
**Build status: ** [![pipeline status][pipeline_svg]][pipeline]

This is an attempt at providing more up-to-date build tools on the Raspberry Pi. At the moment of
writing, compiling C++17 is absolutely off limits on the Raspberry Pi, as it requires to manually
build (or to do quite some tweaking) a recent compiler. The tools I'd like to use are

- CMake 3.12
- Clang 7
- Gcc 8

These are at the moment the most recent versions, and if we need to build them from scratch, let's
go big.

Automated building via CI
===
Shout-out at Hypriot and Stefan for their [great post][1] which I totally recommend as a starting
point. The highlights are

1. Of course start from an appropriate `arm6hf` image, `resin/rpi-raspbian` in your Dockerfile.
2. Add QEMU as build agent in your CI file.

The latter can be done with

```
docker run --rm --privileged multiarch/qemu-user-static:register --reset
```

The key point is that the Docker builder running in the CI pipeline, will most likely run on x86_64
and won't normally be able to build an ARM image, not even if we start from an ARM image. You will
get plenty of errors, at the first ARM binary that is run.

```
standard_init_linux.go:190: exec user process caused "exec format error"
```

So there you go, the `.gitlab-ci.yml` file is a working example; since the QEMU emulation makes
building the ARM images really slow (hey but we are **actually** cross-building so no complaints
here), we use [Gitlab's recipe][2] for caching in the Container Registry the images.

[repo_url]: https://git.mittelab.org/5p4k/rpi-build-tools
[pipeline]: https://git.mittelab.org/5p4k/rpi-build-tools/commits/master
[pipeline_svg]: https://git.mittelab.org/5p4k/rpi-build-tools/badges/master/pipeline.svg
[1]: https://blog.hypriot.com/post/setup-simple-ci-pipeline-for-arm-images/
[2]: https://about.gitlab.com/2016/05/23/gitlab-container-registry/