class Homeutils < Formula
  desc "Core Utils but better! (Drop-in replacements for standard Unix commands)"
  homepage "https://github.com/norwd/homebrew-tap"
  url "https://github.com/norwd/homebrew-tap/archive/refs/tags/0.0.0.tar.gz"
  sha256 "617dbbb7cfedc917787034f5606e2fc6c6fe5c359cb0759a178e8093543fa017"
  license "Hippocratic-2.1+" # Strictly speaking, this should be "Hippocratic License HL3-CL-ECO-LAW-MIL-SV"

  depends_on "bat" # cat(1)
  depends_on "btop" # top(1) / htop(1)
  depends_on "git" # git(1), obviously
  depends_on "ugrep" # grep(1)
end
