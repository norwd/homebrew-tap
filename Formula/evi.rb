class EVi < Formula
  desc "Vi 'workalike' with many additional features"
  homepage "https://evi-editor.codeberg.page"
  url "https://codeberg.org/evi-editor/evi/archive/a881f66bfa3a151a28eb546b1392c2cbf62d3e92.tar.gz"
  sha256 "a881f66bfa3a151a28eb546b1392c2cbf62d3e92"
  license "Vim"
  compatibility_version 1
  head "ssh://git@codeberg.org/evi-editor/evi.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "gettext" => :build
  depends_on "lua" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]
  depends_on "ruby" => [:build, :test]
  depends_on "libsodium"
  depends_on "ncurses"

  uses_from_macos "perl" => [:build, :test]

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "acl"
  end

  conflicts_with "ex-vi", because: "EVi and ex-vi both install ex, vi, and view binaries"
  conflicts_with "macvim", because: "EVi and macvim both install ex, vi, and view binaries"
  conflicts_with "vim-classic", because: "EVi and vim-classic both install ex, vi, and view binaries"

  def extra_deps = deps.select { |dep| dep.build? && dep.test? }

  def install
    ENV.prepend_path "PATH", formula_opt_libexec("python@3.14")/"bin"

    # Allow dynamically loading formulae libraries when not linked
    extra_deps.each do |dep|
      extra_rpath = dep.to_formula.opt_lib
      extra_rpath = rpath(target: extra_rpath) if OS.mac? # cannot use $ORIGIN
      ENV.append "LDFLAGS", "-Wl,-rpath,#{extra_rpath}"
    end

    # We specify HOMEBREW_PREFIX as the prefix to make vim look in the
    # the right place (HOMEBREW_PREFIX/share/vim/{vimrc,vimfiles}) for
    # system vimscript files. We specify the normal installation prefix
    # when calling "make install".
    system "./configure", "--prefix=#{HOMEBREW_PREFIX}",
                          "--mandir=#{man}",
                          "--enable-multibyte",
                          "--with-tlib=ncurses",
                          "--with-compiledby=Homebrew",
                          "--enable-cscope",
                          "--enable-terminal",
                          "--enable-perlinterp#{"=dynamic" unless OS.mac?}",
                          "--enable-python3interp=dynamic",
                          "--enable-rubyinterp=dynamic",
                          "--disable-gui",
                          "--without-x",
                          "--enable-luainterp=dynamic",
                          "--with-lua-prefix=#{formula_opt_prefix("lua")}"
    system "make"
    # Parallel install could miss some symlinks
    # https://github.com/vim/vim/issues/1031 (predates forking, still applies to EVi)
    ENV.deparallelize
    system "make", "install", "prefix=#{prefix}"
    bin.install_symlink "evi" => "vi"
  end

  def caveats
    "Additional features can be enabled by installing: #{extra_deps.map(&:name).join(", ")}"
  end

  test do
    (testpath/"commands.evi").write <<~EVI
      :python3 import evi; evi.current.buffer[0] = 'hello python3'
      :ruby EVi::Buffer.current.append(0, 'hello ruby')
      :perl $curbuf->Append(0, "hello perl")
      :lua EVi.buffer():insert("hello lua")
      :wq
    EVI
    system bin/"evi", "-T", "dumb", "-s", "commands.evi", "test.txt"
    assert_equal "hello perl\nhello ruby\nhello python3\nhello lua", File.read("test.txt").chomp
    assert_match "+gettext", shell_output("#{bin}/evi --version")
    assert_match "+sodium", shell_output("#{bin}/evi --version")
  end
end
