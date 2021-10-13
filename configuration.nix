# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./symlinks/activation-script.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  
  networking = {
    networkmanager.enable = true;
    hostName = "tbagrel-tweag-lt";
    useDHCP = false;
    interfaces.enp0s13f0u3u2.useDHCP = true;
    interfaces.wlp0s20f3.useDHCP = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
  };

  nix = {
    autoOptimiseStore = true;
  };

  nixpkgs = {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
      pulseaudio = true;
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
    xserver = {
      enable = true;
      displayManager = {
        sddm.enable = true;
        defaultSession = "plasma5";
        sessionCommands = ''
          export PATH=/usr/bin:/usr/sbin:$HOME/.local/bin:$PATH
        '';
      };
      desktopManager.plasma5.enable = true;
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
    actkbd = {
      enable = true;
      bindings = [
        {
          keys = [ 99 ];
          events = [ "key" "rep" ];
          command = "${pkgs.xdotool}/bin/xdotool key less";
        }
        {
          keys = [ 54 99 ];
          events = [ "key" "rep" ];
          command = "${pkgs.xdotool}/bin/xdotool key greater";
        }
      ];
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
      packages = with pkgs; [
        alsaLib
        alsaOss
        alsaPlugins
        alsaTools
        alsaUtils
        darktable
        docker
        docker-compose
        fish
        gimp
        git
        git-lfs
        google-chrome
        hunspell
        hunspellDicts.en-us-large
        hunspellDicts.fr-moderne
        inkscape
        inotify-tools
        okular
        konsole
        openconnect
        openssl
        openvpn
        postgresql
        rustup
        shellcheck
        stack
        ghc
        cabal-install
        haskellPackages.ghcid
        haskellPackages.haskell-language-server
        haskellPackages.hasktags
        haskellPackages.hlint
        virtualbox
        vlc
        zoom-us
        enpass
        megasync
	spotify
	vscode
        desktop-file-utils
      ];
      shell = "${pkgs.fish}/bin/fish";
      symlinks = {
        ".gitconfig" = pkgs.gitconfig;
        ".nixpkgs/config.nix" = pkgs.nixconfig;
        ".stack/config.yaml" = pkgs.stackconfig;
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
      ${pkgs.starship}/bin/starship init fish | source
    '';
    shellAliases = {
      lsa = "ls -la --color=auto";
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
  environment.systemPackages = with pkgs; [
    autoconf
    automake
    binutils
    bzip2
    coreutils
    curl
    diffutils
    dosfstools
    e2fsprogs
    eject
    file
    findutils
    gcc
    gdb
    glibc
    gnugrep
    gnumake
    gnupg
    gnused
    gnutar
    gnutls
    groff
    htop
    inetutils
    less
    libtool
    man
    man-pages
    nano
    networkmanager
    nginxMainline
    ntfs3g
    patch
    sudo
    unzip
    vim
    wget
    which
    zip
    pavucontrol
    pulseaudioFull
    xdotool
    actkbd
    openssh
    starship
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

