require 'yaml'

module Site
  def self.projects
    @projects ||= YAML.load_file(data_path.join('projects.yaml')).map(&Project.method(:new))
  end

  def self.data_path
    root.join('data')
  end

  def self.root
    @root ||= Pathname(__dir__).join('..')
  end

  def self.development?
    ENV['BUILD'] != 'true'
  end

  class Project
    attr_reader :attrs

    def initialize(attrs)
      @attrs = attrs
    end

    def name
      attrs['name']
    end
    alias_method :to_s, :name

    def github_url
      "https://github.com/async-std/#{name}"
    end

    def docsrs_url
      "https://docs.rs/#{name}"
    end

    def crates_io_url
      "https://crates.io/crates/#{name}"
    end

    def version_badge
      "https://img.shields.io/crates/v/#{name}.svg?style=flat"
    end

    def ci_badge
      "https://img.shields.io/travis/async-std/#{name}/master.svg?style=flat"
    end

    def api_url
      "#{api_host_url}/#{name}"
    end

    def api_host_url
      "https://docs.rs"
    end
  end
end
