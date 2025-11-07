{ pkgs, acceleration }:

if acceleration == "cuda" then
  pkgs.blender {
    cudaSupport = true;
  }
else if acceleration == "rocm" then
  pkgs.blender-hip
else
  pkgs.blender
