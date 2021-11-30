{ config, pkgs, ... }:

{
  # add home-manager to also manage user management
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos> 
    ];

  # add nixFlakes as a command to the environment
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Add neovim-nightly overlay so we can pull in version 6+
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # can change your kernel version here 
  # currently supports 5.15.4 as the latest
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "future"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Halifax";


  # fonts
  fonts.fonts = with pkgs; [
    nerdfonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    fira-code
    fira-code-symbols
  ];

  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  environment.pathsToLink = ["/libexec"]; # Needed for i3

  # hardware.opengl.driSupport32Bit = true;
  services.xserver = {
    enable = true;
    desktopManager = { xterm.enable = false; };
    displayManager = { defaultSession = "none+i3"; 
      lightdm.enable = true;
      autoLogin.enable = true;
      autoLogin.user = "j";
    };
    # Qemu driver
    videoDrivers = [ "qxl" ];

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        rofi
        i3status
        i3lock
        i3blocks
      ];
    };
};

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "us";

  # system wide neovim configuration so I can use it as root
  programs.neovim = { 
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    package = pkgs.neovim-nightly;
  };

  environment.systemPackages = with pkgs; [
     qemu-utils
     wget
     alacritty
     docker
     podman
     spice-vdagent # needed for monitor resizing in VM
    (pkgs.writeShellScriptBin "nixFlakes" ''
      exec ${pkgs.nixFlakes}/bin/nix --experimental-features "nix-command flakes" "$@"
    '')
  ];

  # List services that you want to enable:
  # Qemu agent
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "21.05"; # Did you read the comment?

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.j = {
     isNormalUser = true;
     extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ and docker for the user.
  };

  # Home-Manager Stuffz
  # this stuff is usually in a home.nix file but i've included it here
  home-manager.users.j = { pkgs, ... }: {

    home.sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      PAGER = "less -FirSwX";
    };

    # Start doing dotFiles
    xdg.enable = true;
    xdg.configFile."i3/config".text = builtins.readFile ./configs/i3-config;
    xdg.configFile."i3/i3status.conf".text = builtins.readFile ./configs/i3status.conf;
    xdg.configFile."rofi/config.rasi".text = builtins.readFile ./configs/rofi-config;
    xdg.configFile."nvim/init.vim".text = builtins.readFile ./configs/init.vim;
    xdg.dataFile."nvim/site/autoload/plug.vim".text = builtins.readFile ./configs/plug.vim;

    home.packages = with pkgs; [
     firefox
     thunderbird
     flameshot
     deluge
     neofetch
     exa
     ripgrep
     bat
     bat-extras.batdiff
     bat-extras.batgrep
     bat-extras.batman
     bat-extras.batwatch
     bat-extras.prettybat
     tmux
     python39Packages.py3status
     python39Full
     nodejs-17_x
    ];

    programs.git = {
      enable = true;
      userName = "mcgillij";
      userEmail = "mcgillivray.jason@gmail.com";

      extraConfig = {
        github.user = "mcgillij";
        core.editor = "nvim";
        color.ui = true;
        push.default = "simple";
        pull.ff = "only";
        init.defaultBranch = "main";
      };

      delta = {
        enable = true;
        options = {
          navigate = true;
          line-numbers = true;
          syntax-theme = "GitHub";
        };
      };
    };

    programs.bash = {
      enable = true;
      initExtra = "set -o vi; export PATH=$HOME/bin:$PATH";
      shellAliases = {
        ls = "exa --icons";
        ll = "exa --long --git --header --icons";
        lt = "exa --tree --icons";
        ag = "batgrep";
        cat = "bat";
        diff = "batdiff";
        grep = "batgrep";
        man = "batman";
        # these shouldn't be needed but nightly-nvim hoses stuff
        vi = "nvim -u ~/.config/nvim/init.vim";
        vim = "nvim -u ~/.config/nvim/init.vim";
        nvim = "nvim -u ~/.config/nvim/init.vim";
      };
    };
  };

}
