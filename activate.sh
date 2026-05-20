# Source this file to put safe-install wrappers before normal package managers.
#
# Usage:
#   source /path/to/safe-install/activate.sh

if [ -n "${ZSH_VERSION:-}" ]; then
  safe_install_activate_path="$(eval 'printf "%s" "${(%):-%x}"')"
elif [ -n "${BASH_VERSION:-}" ]; then
  safe_install_activate_path="${BASH_SOURCE[0]}"
else
  safe_install_activate_path="$0"
fi

safe_install_activate_dir="$(cd "$(dirname "$safe_install_activate_path")" && pwd)"

case ":$PATH:" in
  *":$safe_install_activate_dir/bin:"*) ;;
  *) export PATH="$safe_install_activate_dir/bin:$PATH" ;;
esac

export SAFE_INSTALL_ACTIVE=1
unset safe_install_activate_path
unset safe_install_activate_dir
