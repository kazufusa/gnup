require 'gnup/version'
require 'haml'

# draw gnuplot
module Gnup
  # gnuplot process runner
  def self.open
    cmd = 'gnuplot --persist'
    IO.popen(cmd, 'w+') do |io|
      yield io
      io.close_write
      puts io.read
    end
  end

  # plot executor
  class Plot
    def initialize
      @commands = Commands.new
      yield self
      draw
    end

    def draw
      Gnup.open do |gnup|
        gnup << @commands.gen
      end
    end

    def settings
      yield @commands.settings
    end

    def add_dataset
      yield @commands.add_dataset
    end

    # gnuplot command generator
    class Commands
      attr_accessor :settings, :datasets
      def initialize(template = 'lib/templates/gnup.haml')
        @datasets = []
        @settings = Settings.new
        @template = template
      end

      def gen
        template = File.read(@template)
        haml_engine = Haml::Engine.new(template)
        haml_engine.render(self)
      end

      def add_dataset
        dataset = Dataset.new
        @datasets << dataset
        dataset
      end

      # plot area settings
      class Settings
        attr_accessor :is_log, :eps_path, :ylabel
        def initialize
          @is_log = false
          @eps_path = ''
          @ylabel = 'tetetete'
        end
      end

      # plot datasets
      class Dataset
        attr_accessor :data, :plot, :errorbar, :legend, :line, :title
        def initialize
          @data = nil
          @plot = @errorbar = @legend = @line = true
          @title = ''
        end
      end
    end
  end
end
