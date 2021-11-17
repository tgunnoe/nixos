final: prev: {
  steam = prev.steam.override {
    extraPkgs = pkgs: with pkgs; [ pango harfbuzz libthai ];
    extraProfile = ''
      unset VK_ICD_FILENAMES
      export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.x86_64.json:/usr/share/vulkan/icd.d/intel_icd.i686.json:${prev.pkgs.amdvlk}/share/vulkan/icd.d/amd_icd64.json:${prev.pkgs.driversi686Linux.amdvlk}/share/vulkan/icd.d/amd_icd32.json
    '';
  };
}
