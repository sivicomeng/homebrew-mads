# MADS V5 CLI Tool Homebrew Formula
# url/version/sha256 are updated by scripts/release.sh — do not edit by hand.
class Mads < Formula
  desc "Command-line tool for building modular MADS V5 applications"
  homepage "https://mads.sivicom.cat/"
  url "https://github.com/sivicomeng/homebrew-mads/releases/download/v5.1.0-b20261019/mads-5.1.0-b20261019.zip"
  version "5.1.0-b20261019"
  sha256 "bfd50027566cc85a46f036fe5d0f2ee3c54d1c6e581e013a4f92cb63249560ba"
  license "BSD-3-Clause"

  # The jars target Java 8 bytecode, so any current JDK runs them.
  depends_on "openjdk"

  def install
    libexec.install "bin"
    (bin/"mads").write_env_script libexec/"bin/mads",
      JAVA_HOME_MADS: formula_opt_prefix("openjdk")
  end

  test do
    # mads rewrites bin/internal/version.txt on every run, and fails if user.home does
    # not exist; the test sandbox forbids the former and breaks the latter.
    cp_r libexec/"bin", testpath
    ENV["JAVA_HOME_MADS"] = formula_opt_prefix("openjdk")
    ENV["_JAVA_OPTIONS"] = "-Duser.home=#{testpath}"
    assert_match "MADS V5 tool version", shell_output("#{testpath}/bin/mads --version")
  end
end
