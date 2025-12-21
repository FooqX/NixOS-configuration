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
  	"nvidia-drm.fbdev=1"
  	
  	"nowatchdog" # disable watchdog
  	"nmi_watchdog=0" # disable watchdog
  	"intel_idle.max_cstate=2" # less parking
  	"threadirqs"
  	"usbcore.autosuspend=-1" # no usb suspend
  ];

  # Blacklist watchdog kernel modules
  boot.blacklistedKernelModules = [
  	"iTCO_wdt"
  	"watchdog"
  	"intel_pmc_bxt"
  ];
  
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
    	    # Libva, nvidia-vaapi packages for hardware acceleration
    		libva-vdpau-driver
    		libvdpau-va-gl
    		nvidia-vaapi-driver
    		egl-wayland
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

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Bluetooth extra configuration (Pipewire).
  # Only A2DP, no hands free functionality, and only SBC-XQ codec.
  services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = false; # Disable mSBC codec (wideband speech codec for HFP/HSP).
      "bluez5.enable-hw-volume" = false; # Disable hardware volume control on headphones.
      "bluez5.roles" = [ "a2dp_sink" "a2dp_source" ];
      "bluez5.codecs" = [ "sbc_xq" ];
      "bluez5.hfphsp-backend" = "none";
    };
  };

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
    bibata-cursors
    curl
    #firefox # not needed
    #librewolf # installed from flatpak
    fish
    fastfetch
    freetype
    fontconfig
    flatpak
    gcc15 # make sure to check
    git
    gnome-tweaks
    gparted
    inxi
    jq
    micro
    p7zip
    parted
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
  };

  # NVIDIA setup
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
  	# Nvidia power management. Experimental, and can cause sleep/suspend to fail.
  	# Enable this if you have graphical corruption issues or application crashes after waking
  	# up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
  	# of just the bare essentials.
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
  
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
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
