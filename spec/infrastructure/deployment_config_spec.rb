require "spec_helper"

RSpec.describe "Deployment configuration" do
  describe "GitHub Actions CI workflow" do
    let(:ci_yml_path) { File.expand_path("../../.github/workflows/ci.yml", __dir__) }
    let(:ci_content) { File.read(ci_yml_path) }

    it "CI workflow file exists" do
      expect(File.exist?(ci_yml_path)).to be true
    end

    it "uses PostgreSQL 16 service" do
      expect(ci_content).to include("postgres:16")
    end

    it "runs db:schema:load to set up the database schema" do
      expect(ci_content).to include("db:schema:load")
    end

    it "runs the full RSpec suite" do
      expect(ci_content).to include("rspec")
    end

    it "includes a deploy job that runs flyctl deploy" do
      expect(ci_content).to include("flyctl deploy")
    end

    it "restricts deploy job to master branch only" do
      expect(ci_content).to include("refs/heads/master")
    end

    it "requires test job to pass before deploying" do
      expect(ci_content).to match(/needs:.*test/m)
    end
  end

  describe "Fly.io configuration" do
    let(:fly_toml_path) { File.expand_path("../../fly.toml", __dir__) }
    let(:fly_content) { File.read(fly_toml_path) }

    it "fly.toml file exists" do
      expect(File.exist?(fly_toml_path)).to be true
    end

    it "configures internal port 3000" do
      expect(fly_content).to include("3000")
    end

    it "sets production RAILS_ENV" do
      expect(fly_content).to include("RAILS_ENV")
    end
  end

  describe "Dockerfile" do
    let(:dockerfile_path) { File.expand_path("../../Dockerfile", __dir__) }
    let(:dockerfile_content) { File.read(dockerfile_path) }

    it "Dockerfile exists" do
      expect(File.exist?(dockerfile_path)).to be true
    end

    it "uses Ruby 3.2" do
      expect(dockerfile_content).to match(/3\.2|RUBY_VERSION=3\.2/)
    end

    it "exposes port 3000" do
      expect(dockerfile_content).to include("3000")
    end
  end
end
