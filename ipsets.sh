#!/bin/bash
#
# ipsets.sh - manage multiple ipsets
#

set -e

default_ipset_config_dir="/etc/ipsets"
export IPSETS_CONFIG_DIR="${IPSETS_CONFIG_DIR:-$default_ipset_config_dir}"

# the set_name will be set by script itself
# config file cannot override it
set_name=""

# the following variables should be set by the /etc/ipsets/*.conf file
set_type="hash:net"
set_family="inet"
list_files=()

ipset() {
  echo "[#]" ipset "$@"
  command ipset "$@"
}

show_usage_and_exit() {
  echo "$0 - manage multiple ipsets"
  echo
  echo "Usage: $0 COMMAND"
  echo
  echo "Commands:"
  echo "load SETNAME"
  echo -e "\tLoad ipsets from config file"
  echo "reload SETNAME"
  echo -e "\tReload ipsets from config file"
  echo "unload SETNAME"
  echo -e "\tAlias for 'ipset destroy SETNAME'"
  echo "help"
  echo -e "\tShow this help"
  echo
  echo "Environment variables:"
  echo "IPSETS_CONFIG_DIR=$IPSETS_CONFIG_DIR"
  echo -e "\tDirectory containing ipset config files"

  exit 0
}

show_error_and_exit() {
  echo "$0:" "$@" >&2
  echo "Try \`$0 help\` for more information."
  exit 22
}

parse_config() {
  set_name="$1"

  cd "$IPSETS_CONFIG_DIR"

  if [ -z "$set_name" ]; then
    show_error_and_exit "Missing SETNAME in the argument."
  fi

  if [ ! -f "$set_name.conf" ]; then
    show_error_and_exit "Config file $IPSETS_CONFIG_DIR/$1.conf is not a regular file."
  fi

  source "$set_name.conf"

  if [[ "$set_name" != "$1" ]]; then
    show_error_and_exit "Reset set_name in the $IPSETS_CONFIG_DIR/$1.conf is forbbiden, please remove it."
  fi
}

load_ipset() {
  ipset create "$set_name" "$set_type" family "$set_family"
  reload_ipset
}

reload_ipset() {
  local _tmpfile="$(mktemp -t "ipsets.$set_name.XXXXXX")"

  echo "flush $set_name" > "$_tmpfile"

  for list_file in "${list_files[@]}"; do
    echo "$set_name: adding list file $list_file"
    sed -e 's/^/add '"$set_name"' /' "$list_file" >> "$_tmpfile"
  done

  ipset -f "$_tmpfile" restore

  rm -f "$_tmpfile"
}

unload_ipset() {
  ipset destroy "$set_name"
}


case "$1" in
  load)
    parse_config "$2"
    load_ipset
    ;;
  reload)
    parse_config "$2"
    reload_ipset
    ;;
  unload)
    parse_config "$2"
    unload_ipset
    ;;
  help)
    show_usage_and_exit
    ;;
  *)
    show_error_and_exit "Unknown command: $1"
    ;;
esac

# vim:set ts=2 sw=2 sts=2 et:
