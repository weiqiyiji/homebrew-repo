class ThriftAT092 < Formula
    desc "Framework for scalable cross-language services development"
    homepage "https://thrift.apache.org"
    url "https://codeload.github.com/apache/thrift/tar.gz/0.9.2"
    sha256 "1eacc3d65b910fadf7969326285170d33cbe9fe30cc7bf421916f753edb3dabb"
  
    bottle do
      cellar :any
    end
  
    keg_only :versioned_formula
  
    option "with-haskell", "Install Haskell binding"
    option "with-erlang", "Install Erlang binding"
    option "with-java", "Install Java binding"
    option "with-perl", "Install Perl binding"
    option "with-php", "Install Php binding"
  
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bison" => :build
    depends_on "libtool" => :build
    depends_on "pkg-config" => :build
    depends_on "boost"
    depends_on "openssl"
    depends_on "python" => :optional
  
    if build.with? "java"
      depends_on "ant" => :build
      depends_on :java => "1.8"
    end
  
    def install
      args = ["--without-ruby", "--without-tests", "--without-php_extension"]
  
      args << "--without-python" if build.without? "python"
      args << "--without-haskell" if build.without? "haskell"
      args << "--without-java" if build.without? "java"
      args << "--without-perl" if build.without? "perl"
      args << "--without-php" if build.without? "php"
      args << "--without-erlang" if build.without? "erlang"
  
      ENV.cxx11 if MacOS.version >= :mavericks && ENV.compiler == :clang
  
      # Don't install extensions to /usr
      ENV["PY_PREFIX"] = prefix
      ENV["PHP_PREFIX"] = prefix
      ENV["JAVA_PREFIX"] = pkgshare/"java"
  
      # configure's version check breaks on ant >1.10 so just override it. This
      # doesn't need guarding because of the --without-java flag used above.
      inreplace "configure", 'ANT=""', "ANT=\"#{Formula["ant"].opt_bin}/ant\""
  
      system "./bootstrap.sh"
      system "./configure", "--disable-debug",
                            "--prefix=#{prefix}",
                            "--libdir=#{lib}",
                            *args
      ENV.deparallelize
      system "make", "install"
    end
  
    test do
      assert_match "Thrift", shell_output("#{bin}/thrift --version")
    end
  end
  