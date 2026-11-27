class BidirektBroker < Formula
  desc "Self-hosted broker for bidirectional contract testing"
  homepage "https://bidirekt.com"
  license "BUSL-1.1"

  on_macos do
    on_arm do
      url "https://github.com/bidirekt/broker/releases/download/v0.4.1/bidirekt-broker_0.4.1_darwin_arm64.tar.gz"
      sha256 "f885d851d2956f9ae59abccbece763beb718f96db056337412372e1076b5f914"
    end
    on_intel do
      url "https://github.com/bidirekt/broker/releases/download/v0.4.1/bidirekt-broker_0.4.1_darwin_amd64.tar.gz"
      sha256 "2e689850a7167e100d81ea37dd72e29e79f0c84965eda3a74af044b01ff29fef"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/bidirekt/broker/releases/download/v0.4.1/bidirekt-broker_0.4.1_linux_arm64.tar.gz"
      sha256 "fa7c6955ee76f1f2b77effc5d107828e8e215b7791dd587694c29b572803a403"
    end
    on_intel do
      url "https://github.com/bidirekt/broker/releases/download/v0.4.1/bidirekt-broker_0.4.1_linux_amd64.tar.gz"
      sha256 "09f38260b6788380bb3b059aa043a094fba6ef1a3c284e698d9a50b680cc8b22"
    end
  end

  def install
    bin.install "bidirekt-broker"
    (libexec/"bidirekt-broker-service").write <<~SH
      #!/bin/sh
      # Runs the broker as a Homebrew service. On the first start it writes a
      # default config, with a generated token signing key, if there is none.
      set -eu
      config="#{etc}/bidirekt/broker.env"
      if [ ! -f "$config" ]; then
        mkdir -p "$(dirname "$config")"
        umask 077
        cat >"$config" <<EOF
      BIDIREKT_DATABASE_URL=postgres://localhost:5432/bidirekt?sslmode=disable
      BIDIREKT_PUBLIC_URL=http://localhost:8080
      BIDIREKT_LISTEN_ADDR=127.0.0.1:8080
      BIDIREKT_TOKEN_SIGNING_KEY=$(openssl rand -base64 32)
      EOF
      fi
      set -a
      . "$config"
      set +a
      exec "#{opt_bin}/bidirekt-broker"
    SH
    chmod 0755, libexec/"bidirekt-broker-service"
  end

  def caveats
    <<~EOS
      The broker needs a Postgres database, which it migrates on start:
        createdb bidirekt

      To start it now and at login:
        brew services start bidirekt-broker

      The first start writes its settings, with a generated signing key, to
        #{etc}/bidirekt/broker.env
      Edit that file and restart to change the database or the port.

      Then open http://localhost:8080 to create the admin.
      After `brew upgrade bidirekt-broker`, restart it:
        brew services restart bidirekt-broker
    EOS
  end

  service do
    run opt_libexec/"bidirekt-broker-service"
    keep_alive true
    log_path var/"log/bidirekt-broker.log"
    error_log_path var/"log/bidirekt-broker.log"
  end

  test do
    assert_match "BIDIREKT_PUBLIC_URL is required", shell_output("#{bin}/bidirekt-broker 2>&1", 1)
  end
end
