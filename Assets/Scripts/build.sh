#!/bin/bash

###############
# CONFIGURATION
###############

# Your AdMob unit id. You need to sign up with AdMob.
#
# See: https://developers.google.com/mobile-ads-sdk/docs/admob/fundamentals#defineadview
# Modifies: NodeViewController.m in Classes/ViewControllers/
AD_UNIT_ID=""

# If you are going to install this on a physical device (a real phone as
# opposed to an emulator), you need to place your physical device id here
# so you don't get served real ads.
#
# See: https://developers.google.com/mobile-ads-sdk/docs/admob/best-practices#testmode
# Modifies: NodeViewController.m in Classes/ViewControllers/
PHYSICAL_DEVICE_ID=""

######################
# SYSTEM CONFIGURATION
######################

# Don't modify this unless you are moving this file.
PROJECT_DIR="."
# Extension sed uses for backups during substitution.
BACKUP_EXT=".bu"

###########
# FUNCTIONS
###########

function validate_user {
    printf "
    DO NOT PROCEED IF YOU HAVE NOT SET UP THIS SCRIPT'S CONFIG VARIABLES!

    This script is meant to be executed only once, right after a git clone
    (of the master AND submodule repositories). Run this script from the
    root of the project directory.

    It will customize the repository so that the application can compile
    properly, using your own IDs for various components. If you do not set
    up these components (either by running this script or through manual
    configuration of the necessary files), the application will NOT
    run properly. It may not even compile.

    To setup the necessary config variables, open build.sh in a text editor
    and only modify the CONFIGURATION section. Do not modify \$PROJECT_DIR,
    unless you are moving the build.sh file.
    "

  input=""
  printf "Are you ready to run the build (y/n)? "
  read input
  printf "\n"
  if [ "$input" != "y" ]; then
    message="Build aborted!"
    printf "\e[31m$message\e[0m\n"
    exit 1
  fi
}

function check_sanity {
  isInvalid=false
  if [ -z "$AD_UNIT_ID" ]; then
    isInvalid=true
    message="Error: You must set the \$AD_UNIT_ID variable"
    printf "\e[31m$message\e[0m\n"
  fi
  if [ -z "$PHYSICAL_DEVICE_ID" ]; then
    isInvalid=true
    message="Error: You must set the \$PHYSICAL_DEVICE_ID variable"
    printf "\e[31m$message\e[0m\n"
  fi
  if $isInvalid; then
    message="Build aborted due to errors!"
    printf "\e[31m$message\e[0m\n"
    exit 2
  fi
}

function prepare_NodeViewController_Ads {
  target="$PROJECT_DIR/Classes/ViewControllers/NodeViewController.m"
  sub_string="s|_adBannerView.adUnitID = @\"YOUR_UNIT_ID_HERE\";|_adBannerView.adUnitID = @\"$AD_UNIT_ID\";|g"
  sed_file "$target" "$sub_string"
}

function prepare_NodeViewController_Devices {
  # Have the shell interpret the newline for cross-compatibility.
  # (Some versions of sed won't interpret it).
  lf=$'\n'
  target="$PROJECT_DIR/Classes/ViewControllers/NodeViewController.m"
  sub_string="s|GAD_SIMULATOR_ID,|GAD_SIMULATOR_ID,\\$lf                                 \"$PHYSICAL_DEVICE_ID\",|g"
  sed_file "$target" "$sub_string"
}

function build_database {
  target_db="$PROJECT_DIR/Assets/creepypasta_files.db"
  target_ddl="$PROJECT_DIR/Assets/creepypasta-files.sql"
  sqlite3 $target_db < $target_ddl
}

function sed_file {
  file=$1
  sub_string=$2

  sed -i$BACKUP_EXT "$sub_string" $file
  exit_code=$?

  if [ $exit_code != 0 ]; then
    message="Failed to run the build on file \"$file\"."
    printf "\e[31m$message\e[0m\n"
  else
    rm $file$BACKUP_EXT
  fi
}

######
# MAIN
######

case "$1" in
all)
  validate_user
  check_sanity
  prepare_NodeViewController_Ads
  prepare_NodeViewController_Devices
  build_database
  message="Build complete!"
  printf "\e[32m$message\e[0m\n"
  ;;
*)
  printf "Usage: `basename $0` [option]\n"
  printf "Available options:\n"
  for option in all
  do 
      printf "  - $option\n"
  done
  ;;
esac
