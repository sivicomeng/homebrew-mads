# MADS V5 CLI Tool Homebrew Formula
# url/version/sha256 are updated by scripts/release.sh — do not edit by hand.
class Mads < Formula
  desc "Command-line tool for building modular MADS V5 applications"
  homepage "https://mads.sivicom.cat/"
  url "https://github.com/sivicomeng/homebrew-mads/releases/download/v5.1.0-b20261014/mads-5.1.0-b20261014.zip"
  version "5.1.0-b20261014"
  sha256 "c19c8dc1392b78c55afdde21d0b1b5b70608f8c45a3ca2968b05e67305292996"
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
