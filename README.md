# docker-aosp

A Dockerfile to build AOSP (Android Open Source Project) as branched and incremental docker images.

## How to build

You need to prepare an updated ubuntu image at first.
```
docker build -f Dockerfile_make_base -t gittestacr.azurecr.io/aosp-docker:ubuntu-updated .
```

Next, you can create first branch of android.
```
docker build --build-arg BASE_BRANCH=gittestacr.azurecr.io/aosp-docker:ubuntu-updated --build-arg TGT_BRANCH=android-7.0.0_r1 -t gittestacr.azurecr.io/aosp-docker:android-7.0.0_r1 --cache-from gittestacr.azurecr.io/aosp-docker:ubuntu-updated .
```

OK. Now, you can create incremental images with tags.
```
docker build --build-arg BASE_BRANCH=gittestacr.azurecr.io/aosp-docker:android-7.0.0_r1 --build-arg TGT_BRANCH=android-7.0.0_r5 -t gittestacr.azurecr.io/aosp-docker:android-7.0.0_r5 --cache-from gittestacr.azurecr.io/aosp-docker:android-7.0.0_r3 .
docker build --build-arg BASE_BRANCH=gittestacr.azurecr.io/aosp-docker:android-7.0.0_r1 --build-arg TGT_BRANCH=android-7.0.0_r7 -t gittestacr.azurecr.io/aosp-docker:android-7.0.0_r7 --cache-from gittestacr.azurecr.io/aosp-docker:android-7.0.0_r5 .
...
```
