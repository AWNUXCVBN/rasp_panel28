print_help()
{
echo "Usage: sudo ./install_disp_only.sh [0/90/180/270]"
echo "0: rotate 0 degrees"
echo "90: rotate 90 degrees"
echo "180: rotate 180 degrees"
echo "270: rotate 270 degrees"
echo "default(no param): rotate 270 degrees"
}

rotation=270

if [ $# -eq 0 ]; then
  echo "default rotate 270 degree"
elif [ $# -eq 1 ]; then
  if [ $1 -ne 0 ] && [ $1 -ne 90 ] && [ $1 -ne 180 ] && [ $1 -ne 270 ]; then
    echo "Invalid parameter"
    print_help
    exit
  else
    rotation=$1
  fi
else
  echo "Too many parameters"
  print_help
  exit
fi

# install display
fbtft_option="./conf/fbtft_option_"$rotation".conf"

sudo cp -rf ./conf/fbtft.conf /etc/modules-load.d/fbtft.conf
sudo cp -rf $fbtft_option /etc/modprobe.d/fbtft_option.conf
sudo cp -rf ./conf/99-fbdev.conf /usr/share/X11/xorg.conf.d/99-fbdev.conf

read pi_model < /proc/device-tree/model
pi_model=${pi_model#*Pi }
if [ ${pi_model:0:1} != 4 ]; then
  echo "not raspberry pi 4, install fbcp"
  sudo install fbcp /usr/local/bin/fbcp
fi

# install touch
sudo apt-get install -y xserver-xorg-input-evdev

if [ -f /etc/X11/xorg.conf.d/40-libinput.conf ]; then
sudo rm -rf /etc/X11/xorg.conf.d/40-libinput.conf
fi
if [ ! -d /etc/X11/xorg.conf.d ]; then
sudo mkdir -p /etc/X11/xorg.conf.d
fi

calibration="./conf/calibration_"$rotation".conf"
sudo cp -rf $calibration /etc/X11/xorg.conf.d/99-calibration.conf

echo "Install display and touch complete, rebooting now..."
sleep 1
sudo reboot