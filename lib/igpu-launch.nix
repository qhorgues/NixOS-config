{ writeShellScriptBin
, igpuId
, igpuNumber
}:

writeShellScriptBin "igpu-launch" ''
  export MESA_VK_DEVICE_SELECT="${igpuId}!"
  export DRI_PRIME=0
  export MANGOHUD_CONFIG="$(echo "$MANGOHUD_CONFIG" | sed 's/gpu_list=[^,]*/gpu_list=${toString igpuNumber}/' || echo "$MANGOHUD_CONFIG")"

  exec "$@"
''
