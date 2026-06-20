{ writeShellScriptBin
, igpuId
, gpuNumber
}:

writeShellScriptBin "igpu-launch" ''
  export MESA_VK_DEVICE_SELECT="${igpuId}!"
  export DRI_PRIME=0
  export MANGOHUD_CONFIG="$(echo "$MANGOHUD_CONFIG" | sed 's/gpu_list=[^,]*/gpu_list=${toString gpuNumber}/' || echo "$MANGOHUD_CONFIG")"

  exec "$@"
''
