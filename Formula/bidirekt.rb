class Bidirekt < Formula
  desc "CLI for Bidirekt, bidirectional contract testing"
  homepage "https://bidirekt.com"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/bidirekt/cli/releases/download/v0.4.0/bidirekt_0.4.0_darwin_arm64.tar.gz"
      sha256 "537fdc546af194130f921e9d1fd66780a09c7ca7ee4a6d46422d44b5ae452976"
    end
    on_intel do
      url "https://github.com/bidirekt/cli/releases/download/v0.4.0/bidirekt_0.4.0_darwin_amd64.tar.gz"
      sha256 "99b27ff0fb8a66eb83686b2691dee262511fcb883c8b29f0ba50368acc1eb3be"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/bidirekt/cli/releases/download/v0.4.0/bidirekt_0.4.0_linux_arm64.tar.gz"
      sha256 "d185bcb7fabe984ea23d4b887c7387a44a82dca520cb4a4b540fc2b02b9db790"
    end
    on_intel do
      url "https://github.com/bidirekt/cli/releases/download/v0.4.0/bidirekt_0.4.0_linux_amd64.tar.gz"
      sha256 "033a427b0c2d5fc92926e5f8dea070e356bb902f7b6e9b764839eeb0d471d201"
    end
  end

  def install
    bin.install "bidirekt"
  end

  test do
    assert_match "bidirekt version #{version}", shell_output("#{bin}/bidirekt --version")
  end
end
