# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
# let
#   # https://nixos.wiki/wiki/Accelerated_Video_Playback
#   vaapiOverlay = self: super: {
#     vaapiIntel = super.vaapiIntel.override { enableHybridCodec = true; };
#   };
# in
{
  imports =
    [
      # https://github.com/NixOS/nixos-hardware
      <nixos-hardware/lenovo/thinkpad/x1/9th-gen>
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./symlinks/activation-script.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    networkmanager.enable = true;
    hostName = "tbagrel-tweag-lt";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ ];
    };
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
    binaryCaches = [
      "https://cache.nixos.org"
      "https://hydra.iohk.io"
      "https://iohk.cachix.org"
    ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
    ];
  };


  nixpkgs = {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
      pulseaudio = true;
    };
    overlays = [
      (import ./overlay.nix)
      # vaapiOverlay
      (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; })
      (self: super: {
        discord = super.discord.overrideAttrs (_: {
          src = builtins.fetchTarball https://discord.com/api/download?platform=linux&format=tar.gz;
        });
      })
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
    xserver = {
      enable = true;
      displayManager = {
        gdm.enable = true;
        sessionCommands = ''
          export PATH=/usr/bin:/usr/sbin:$HOME/.local/bin:$PATH
        '';
      };
      desktopManager.gnome.enable = true;
      layout = "fr";
      xkbVariant = "oss";
      xkbOptions = "eurosign:e";
      libinput.enable = true;
    };
    redshift = {
      enable = true;
      temperature.day = 5500;
      temperature.night = 3700;
    };
    printing.enable = true;
    openssh.enable = true;
    chrony.enable = true;
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  virtualisation.docker.enable = true;
  programs.gnupg.agent.enable = true;

  # environment.etc = {
  #   actkbd.source = ./actkbdconfig;
  # };

  # sudo actkbd -c /home/tbagrel/.actkbd/ltkb.conf -d /dev/input/event1 -D

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users.root = {
      initialHashedPassword = "$6$naSvilpkkG$E6syGdsWSDMrChEbECwItlRbGAV3M/pOwfNhG5pLVXo3TAa7F1xUJm.H793XUGoI2Ev39G3gAIgMSZkVpyMD20";
    };
    users.tbagrel = {
      isNormalUser = true;
      createHome = true;
      description = "Thomas BAGREL";
      uid = 1000;
      extraGroups = [
        "audio"
        "docker"
        "networkmanager"
        "video"
        "wheel"
      ];
      hashedPassword = "$6$naSvilpkkG$E6syGdsWSDMrChEbECwItlRbGAV3M/pOwfNhG5pLVXo3TAa7F1xUJm.H793XUGoI2Ev39G3gAIgMSZkVpyMD20";
      packages = with pkgs;
        [
        ];
      shell = "${pkgs.fish}/bin/fish";
      symlinks = {
        ".gitconfig" = pkgs.gitconfig;
        ".nixpkgs/config.nix" = pkgs.nixconfig;
        ".stack/config.yaml" = pkgs.stackconfig;
        ".actkbd/ltkb.conf" = pkgs.actkbdconfig;
      };
    };
    mutableUsers = false;
    defaultUserShell = pkgs.bash;
  };
  security.sudo.enable = true;

  programs.fish = {
    enable = true;
    shellInit = ''
      set -U fish_greeting ""
      set -U fish_user_paths $fish_user_paths ~/.local/bin
      ${pkgs.direnv}/bin/direnv hook fish | source
      ${pkgs.starship}/bin/starship init fish | source
    '';
    shellAliases = {
      lsa = "ls -la --color=auto";
      es = "${pkgs.emacs}/bin/emacs --daemon";
      e = "${pkgs.emacs}/bin/emacsclient -n --create-frame --alternate-editor=\"\"";
      et = "${pkgs.emacs}/bin/emacsclient -t --alternate-editor=\"\"";
      magit = "${pkgs.emacs}/bin/emacsclient -t --alternate-editor=\"\" --eval '(magit-status \"'(pwd)'\")'";
      setactkbd = "sudo ${pkgs.actkbd}/bin/actkbd -c /home/tbagrel/.actkbd/ltkb.conf -d /dev/input/event1 -D";
    };
  };

  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Merriweather" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Fira Code" ];
      };
    };
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      google-fonts
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.pathsToLink = [
    "/share/nix-direnv"
  ];
  environment.variables = {
    EDITOR = "${pkgs.emacs}/bin/emacsclient -t --alternate-editor=\"\"";
  };
  environment.systemPackages = with pkgs;
    let
      unstable = import
        # latest master commit on 2/02/2022
        (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/efeefb2af1469a5d1f0ae7ca8f0dfd9bb87d5cfb)
        # reuse the current configuration
        { config = config.nixpkgs.config; };
      my-python-packages = python-packages: with python-packages; [
        autoflake
        beautifulsoup4
        click
        epc
        flake8
        importmagic
        ipython
        isort
        lxml
        matplotlib
        numpy
        pygments
        scipy
        # other python packages you want
      ];
      python-with-my-packages = python3.withPackages my-python-packages;
    in
    [
      # unstable.cabal-install
      # unstable.haskell-language-server
      # unstable.haskellPackages.apply-refact
      # unstable.haskellPackages.ghc
      # unstable.haskellPackages.hasktags
      # unstable.haskellPackages.hindent
      # unstable.haskellPackages.hlint
      # unstable.haskellPackages.hoogle
      # unstable.haskellPackages.ormolu
      # unstable.stack
      python-with-my-packages
      # Sorted regular packages under this line
      actkbd
      alsaLib
      alsaOss
      alsaPlugins
      alsaTools
      alsaUtils
      arc-kde-theme
      autoconf
      automake
      bash
      binutils
      bzip2
      clang
      coreutils
      ctags
      curl
      darktable
      desktop-file-utils
      diffutils
      direnv
      discord
      docker
      docker-compose
      dosfstools
      e2fsprogs
      eject
      emacs
      enpass
      file
      findutils
      fish
      gcc
      gdb
      gimp
      git
      git-lfs
      github-changelog-generator
      glibc
      global
      gnome.gnome-tweaks
      gnomeExtensions.appindicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.dash-to-panel
      gnomeExtensions.maxi
      gnomeExtensions.tweaks-in-system-menu
      gnomeExtensions.user-themes
      gnugrep
      gnumake
      gnupg
      gnused
      gnutar
      gnutls
      google-chrome
      htop
      hunspell
      hunspell
      hunspellDicts.en-us-large
      hunspellDicts.fr-moderne
      inetutils
      inkscape
      inotify-tools
      iperf
      jdk
      jdk11
      konsole
      less
      libreoffice
      libtool
      libtool
      libvterm
      man
      man-pages
      megasync
      nano
      networkmanager
      nginxMainline
      niv
      nix-direnv
      nixpkgs-fmt
      nodePackages.eslint
      nodePackages.prettier
      nodePackages.pyright
      nodePackages.typescript
      ntfs3g
      okular
      openconnect
      openssh
      openssl
      openvpn
      pandoc
      patch
      pavucontrol
      pdftk
      postgresql
      pulseaudioFull
      racer
      ripgrep
      rnix-lsp
      rust-analyzer
      rustup
      shellcheck
      spotify
      starship
      sudo
      tmate
      universal-ctags
      unzip
      virtualbox
      vlc
      vscode
      wget
      which
      xdotool
      xsel
      zip
      zoom-us
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
