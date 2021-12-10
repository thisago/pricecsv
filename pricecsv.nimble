# Package

version       = "0.4.0"
author        = "Luciano Lorenzo"
description   = "Easily calculate the total of all products in csv"
license       = "GPL-3"
srcDir        = "src"

bin = @["pricecsv"]
binDir = "build"

# Dependencies

requires "nim >= 1.5.1"
requires "cligen"

task build_release, "Builds the release version":
  exec "nimble -d:release build"
task build_danger, "Builds the danger version":
  exec "nimble -d:danger build"
