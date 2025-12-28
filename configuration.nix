# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel. _latest
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "nouveau.modeset=0"
    "nvidia-drm.fbdev=1"
    
  	"nowatchdog" # disable watchdog
  	"nmi_watchdog=0" # disable watchdog
  	"intel_idle.max_cstate=2" # less parking
  	"threadirqs"
  	"usbcore.autosuspend=-1" # no usb suspend
  ];

  # Load nvidia modules early (it's unstable, random bugs appear)
  # boot.initrd.kernelModules = [
  # 	"nvidia"
  # 	"nvidia_modeset"
  # 	"nvidia_uvm"
  # 	"nvidia_drm"
  # ];

  boot.blacklistedKernelModules = [
  	"iTCO_wdt" # watchdog
  	"watchdog"
  	"intel_pmc_bxt" # watchdog
  	"i915" # intel gpu

  	"nouveau" # conflicts with nvidia
  	"nova_core" # conflicts with nvidia
  	"nvidiafb" # deprecated
  ];

  boot.extraModprobeConfig = ''
  	options iwlwifi bt_coex_active=0 power_save=0 uapsd_disable=1 d0i3_disable=1
  '';
  # boot.extraModulePackages = with config.boot.kernelPackages; [
  # 	nullfs # It's like dev null but for directories
  # ];
  
  # Enable bluetooth
  hardware.bluetooth.enable = true;

  networking.hostName = "nixos";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Riga";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "lv_LV.UTF-8";
    LC_IDENTIFICATION = "lv_LV.UTF-8";
    LC_MEASUREMENT = "lv_LV.UTF-8";
    LC_MONETARY = "lv_LV.UTF-8";
    LC_NAME = "lv_LV.UTF-8";
    LC_NUMERIC = "lv_LV.UTF-8";
    LC_PAPER = "lv_LV.UTF-8";
    LC_TELEPHONE = "lv_LV.UTF-8";
    LC_TIME = "lv_LV.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.core-developer-tools.enable = false;
  
  # Remove GNOME bloatware.
  services.xserver.excludePackages = [ pkgs.xterm ];
  environment.gnome.excludePackages = with pkgs; [
  	baobab # Disk usage analyzer
  	geary  # Email client
  	epiphany # Web browser
  	gnome-characters
  	gnome-contacts
  	gnome-console # replaced by ptyxis
  	gnome-maps
  	gnome-music
  	gnome-weather
  	gnome-connections
  	gnome-tour
  	gnome-software
  	simple-scan # Document scanner
  	snapshot
  	showtime # Video player
  	yelp # Gnome help
  ];

  # NVIDIA hardware acceleration drivers for wayland
  hardware.graphics = {
    enable = true;
	  extraPackages = with pkgs; [
      	libva-vdpau-driver
      	libvdpau-va-gl
      	nvidia-vaapi-driver
      	egl-wayland
      	mesa
      ];
  };
  

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Disable CUPS
  services.printing.enable = false;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth extra configuration (Pipewire).
  # services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
  #   "monitor.bluez.properties" = {
  #     "bluez5.enable-sbc-xq" = true;
  #     "bluez5.enable-msbc" = false; # Disable mSBC codec (wideband speech codec for HFP/HSP).
  #     "bluez5.enable-hw-volume" = false; # Disable hardware volume control on headphones.
  #     "bluez5.roles" = [ "a2dp_sink" "a2dp_source" ];
  #     "bluez5.codecs" = [ "sbc_xq" ];
  #   };
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account.
  users.users.fox = {
    isNormalUser = true;
    createHome = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  security.sudo.enable = true; # Enable sudo
  
  programs.firefox.enable = false; # Disable firefox
  
  services.flatpak.enable = true; # Enable flatpak

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  	rustup
    bibata-cursors
    curl
    fish
    fastfetch
    freetype
    fontconfig
    flatpak
    gcc15 # make sure to check
    git
    go
    gopls
    gnome-tweaks
    gparted
    inxi
    jq
    jetbrains.goland
    micro
    nvd
    p7zip
    parted
    ptyxis # terminal
    pciutils
    polkit_gnome
    tree
    tldr
    unzip
    usbutils
    vlc
    vulkan-tools
    vulkan-validation-layers
    wget
    which
    wl-clipboard
    zip
    xdg-desktop-portal-gtk
    xdg-utils

    # codecs
    gst_all_1.gstreamer
    gst_all_1.gst-vaapi
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-base
    libva
    libva-utils
    ffmpeg-full
  ];

  # Fonts setup
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
  	noto-fonts
    noto-fonts-cjk-sans
    jetbrains-mono
    nerd-fonts.hack
    cantarell-fonts
    texlivePackages.opensans
  ]; # Font rendering setup
  fonts.fontconfig.subpixel.rgba = "rgb";
  fonts.fontconfig.subpixel.lcdfilter = "light";
  
  # Environment variables (Mostly for NVIDIA/Wayland)
  environment.variables = {
  	LIBVA_DRIVER_NAME = "nvidia";
  	GBM_BACKEND = "nvidia-drm";
  	__GLX_VENDOR_LIBRARY_NAME = "nvidia";
  	MOZ_ENABLE_WAYLAND = "1";
  	MOZ_DISABLE_RDD_SANDBOX = "1";
  	
  	NIXOS_OZONE_WL = "1";
  	MICRO_TRUECOLOR = "1";

  	__GL_VRR_ALLOWED = "0";
  	__GL_GSYNC_ALLOWED = "0";
  };

  # NVIDIA setup
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
  	powerManagement.enable = false;
  	powerManagement.finegrained = false;
  	open = true;
  	nvidiaSettings = true;
  	package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # Shell setup
  programs.fish.enable = true;
  programs.fish.interactiveShellInit = ''
    set fish_greeting # Disable greeting
  '';
  users.defaultUserShell = pkgs.fish; # Make fish the default shell

  programs.fish.shellAliases = {
  	nvd-system = ''ls -v1 /nix/var/nix/profiles | tail -n 2 | awk '{print "/nix/var/nix/profiles/" $0}' - | xargs nvd diff'';
  };
  
  # Disable the firewall altogether.
  networking.firewall.enable = false;
  networking.enableIPv6 = false;

  # Enable xdg desktop integration:
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
