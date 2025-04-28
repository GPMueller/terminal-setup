# Starship initialization (official recommended method)
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
source ($nu.data-dir | path join "vendor/autoload/starship.nu")

# Environment variables for Bazel
$env.BAZELISK_HOME = ($nu.home-path | path join ".bazelisk")
$env.BAZEL_BUILD_OPTS = "--color=yes --curses=yes --experimental_ui_max_stdouterr_bytes=1048576"
