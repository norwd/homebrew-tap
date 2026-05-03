class HomeUtils < Formula
  desc "HomeUtils, aka ~/bin, aka CoreUtils but better"
  homepage "https://github.com/norwd/homebrew-tap"
  license "Hippocratic-2.1+" # Strictly speaking, this should be "Hippocratic License HL3-CL-ECO-LAW-MIL-SV"

  depends_on "btop" # top(1) / htop(1)
  depends_on "bat" # cat(1)
  depends_on "ugrep" # grep(1)
  depends_on "git" # git(1), obviously
end
