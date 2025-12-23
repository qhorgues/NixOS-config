{ pkgs, acceleration ? null }:

if acceleration == "cuda" then
  pkgs.blender.override {
    cudaSupport = true;
  }
else if acceleration == "rocm" then
  pkgs.blender-hip
else
  pkgs.blender
