#!/usr/bin/env bash

sbt assembly
cp target/scala-2.12/client.jar .
