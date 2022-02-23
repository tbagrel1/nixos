{ pkgs, mutate }:
mutate ./ltkb.conf {
  xdotool = "${pkgs.xdotool}/bin/xdotool";
}
