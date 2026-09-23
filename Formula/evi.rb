class Evi < Formula
  desc "Vi 'workalike' with many additional features"
  homepage "https://evi-editor.codeberg.page"
  url "https://codeberg.org/norwd-forks/evi/archive/v10.0.0.tar.gz"
  sha256 "a5d4c10b29d1f933d8d2f889fca25334372a231be8612add872ecc8ac017b578"
  license "GPL-3.0-or-later"
  version_scheme 1
  compatibility_version 1
  head "https://codeberg.org/norwd-forks/evi.git", branch: "master"

  livecheck do
    url "https://codeberg.org/api/v1/repos/norwd-forks/evi/releases/latest"
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :json do |json|
      json["tag_name"]&.[](regex, 1)
    end
  end

  depends_on "lua" => [:build, :test]
  depends_on "python@3.12" => [:build, :test]
  depends_on "ruby@3.2" => [:build, :test]
  depends_on "acl"
  depends_on "gettext"
  depends_on "libsodium"
  depends_on "ncurses"

  uses_from_macos "perl" => [:build, :test]

  conflicts_with "ex-vi", because: "EVi and ex-vi both install ex, vi, and view binaries"
  conflicts_with "macvim", because: "EVi and macvim both install ex, vi, and view binaries"
  conflicts_with "vim-classic", because: "EVi and vim-classic both install ex, vi, and view binaries"

  def extra_deps = deps.select { |dep| dep.build? && dep.test? }

  def install
    ENV.prepend_path "PATH", formula_opt_libexec("python@3.12")/"bin"

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
                          "--enable-perlinterp",
                          "--enable-rubyinterp",
                          "--enable-python3interp",
                          "--disable-gui",
                          "--without-x",
                          "--enable-luainterp",
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
    (testpath/"commands.vim").write <<~VIMSCRIPT
      :python3 import vim; vim.current.buffer[0] = 'hello python3'
      :wq
    VIMSCRIPT
    #  :ruby Vim::Buffer.current.append(0, 'hello ruby')
    #  :perl $curbuf->Append(0, "hello perl")
    #  :lua Vim.buffer():insert("hello lua")
    system bin/"evi", "-T", "dumb", "-s", "commands.vim", "test.txt"
    assert_equal "hello perl\nhello ruby\nhello python3\nhello lua", File.read("test.txt").chomp
    assert_match "+gettext", shell_output("#{bin}/evi --version")
    assert_match "+sodium", shell_output("#{bin}/evi --version")
  end
end
