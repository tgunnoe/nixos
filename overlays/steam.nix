final: prev: {
  steam = prev.steam.override {
    extraPkgs = pkgs: with pkgs; [ pango harfbuzz libthai ];
    extraProfile = ''
      unset VK_ICD_FILENAMES
      export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.x86_64.json:/usr/share/vulkan/icd.d/intel_icd.i686.json
    '';
  };
}
