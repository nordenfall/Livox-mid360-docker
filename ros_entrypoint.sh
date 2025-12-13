#!/usr/bin/env bash
# Note: don't use `set -u` here; ROS setup scripts may reference unset vars.
set -e -o pipefail

# Allow overrides via environment.
: "${ROS_DISTRO:=humble}"
: "${WORKSPACE:=/root/livox_ws}"

# Source ROS2.
if [[ -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]]; then
  # shellcheck disable=SC1090
  source "/opt/ros/${ROS_DISTRO}/setup.bash"
else
  echo "ERROR: ROS2 setup not found at /opt/ros/${ROS_DISTRO}/setup.bash" >&2
  exit 1
fi

# Source workspace overlays if they exist (different builds place these in different paths).
if [[ -f "${WORKSPACE}/install/setup.bash" ]]; then
  # shellcheck disable=SC1090
  source "${WORKSPACE}/install/setup.bash"
fi

if [[ -f "${WORKSPACE}/src/livox_ros_driver2/install/setup.bash" ]]; then
  # shellcheck disable=SC1090
  source "${WORKSPACE}/src/livox_ros_driver2/install/setup.bash"
fi

# If the user passed a command, run it (with ROS env already sourced).
if [[ $# -gt 0 ]]; then
  exec "$@"
fi

# Default behavior: launch the driver.
: "${LAUNCH_FILE:=${WORKSPACE}/launch/livox_driver.launch.py}"
: "${LIVOX_CONFIG_FILE:=${WORKSPACE}/config/MID360_config.json}"

exec ros2 launch "${LAUNCH_FILE}" "config_file:=${LIVOX_CONFIG_FILE}"


