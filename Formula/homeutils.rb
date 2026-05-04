class Homeutils < Formula
  desc "Core Utils but better! (Drop-in replacements for standard Unix commands)"
  homepage "https://github.com/norwd/homebrew-tap"
  url "https://github.com/norwd/homebrew-tap/archive/refs/tags/0.0.0.tar.gz"
  sha256 "ac26105860b64c67c88de2297127494fd214743ef52f8fdc8bb0bdbc6c102340"
  license "Hippocratic-2.1+" # Strictly speaking, this should be "Hippocratic License HL3-CL-ECO-LAW-MIL-SV"

  depends_on "bat" # cat(1)
  depends_on "bfs" # find(1)
  depends_on "btop" # top(1) / htop(1)
  depends_on "eth-p/software/bat-extras-batman" # man(1)
  depends_on "hexyl" # hd(1) / hexdump(1)
  depends_on "ugrep" # grep(1)

  def install
    (prefix/"etc/profile.d/999-homeutils.sh").write("HOME_UTILS_VERSION='#{version}'\n")
  end

  test do
    assert_match "#{version}\n", shell_output("sh -c '. #{prefix}/etc/profile.d/999-homeutils.sh && echo \"$HOME_UTILS_VERSION\"'")
  end
end
