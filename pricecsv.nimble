# Package

version       = "0.6.1"
author        = "Thiago Navarro"
description   = "Easily calculate the total of all products in csv"
license       = "gpl-3.0"
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
