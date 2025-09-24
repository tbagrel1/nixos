# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
    ./symlinks/activation-script.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [

    # Add any missing dynamic libraries for unpackaged programs

    # here, NOT in environment.systemPackages

  ];

  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      trusted-users = root nixos
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
    settings.auto-optimise-store = true;
    settings.substituters = [
      "https://cache.nixos.org"
      "https://cache.iog.io"
      "https://iohk.cachix.org"
      "https://ghc-nix.cachix.org"
    ];
    settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
      "ghc-nix.cachix.org-1:ziC/I4BPqeA4VbtOFpFpu6D1t6ymFvRWke/lc2+qjcg="
    ];
  };

  nixpkgs = {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
    overlays = [
      (import ./overlay.nix)
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";
  location = {
    latitude = 48.692054;
    longitude = 6.184417;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";
  console = {
    earlySetup = true;
    keyMap = "fr";
  };

    # Enable the X11 windowing system.
  services = {
    gnome.gnome-keyring.enable = true;
    openssh.enable = true;
    printing.enable = true;
  };
  programs.gnupg.agent.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  users.users.nixos.symlinks = {
    ".gitconfig" = pkgs.gitconfig.default;
    ".gitconfig-tweag" = pkgs.gitconfig.tweag;
  };

  environment.systemPackages = with pkgs;
    let
      my-python-packages = python-packages: with python-packages; [
        beautifulsoup4
        click
        ipython
        matplotlib
        numpy
        pandas
        pillow
        pygments
        scikit-learn
        scipy
        # other python packages you want
      ];
      python-with-my-packages = python3.withPackages my-python-packages;
    in
    [
      haskellPackages.fourmolu

      python-with-my-packages
      # Sorted regular packages under this line
      autoconf
      automake
      bash
      binutils
      blesh
      bzip2
      clang
      cmake
      coreutils
      ctags
      curl
      diffutils
      evince
      fzf
      gcc
      gdb
      git
      git-lfs
      github-changelog-generator
      glibc
      global
      gnugrep
      gnumake
      gnupg
      gnused
      gnutar
      gnutls
      htop
      hunspell
      hunspellDicts.en-us-large
      hunspellDicts.fr-moderne
      inotify-tools
      jdk
      less
      man
      man-pages
      niv
      nixpkgs-fmt
      openssh
      openssl
      pandoc
      pdftk
      ripgrep
      rustup
      starship
      sudo
      tikzit
      universal-ctags
      unzip
      vim-full
      wget
      which
      zip
    ];
}
