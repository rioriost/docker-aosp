# docker-aosp

A Dockerfile to build AOSP (Android Open Source Project) as branched docker images.
docker build --build-arg BASE_BRANCH=android-7.0.0_r1 --build-arg TGT_BRANCH=android-7.0.0_r1 -t gittestacr.azurecr.io/aosp-docker:android-7.0.0_r1 --cache-from gittestacr.azurecr.io/aosp-docker:android-7.0.0_r1 .
