require 'gnup/version'
require 'haml'

# draw gnuplot
module Gnup
  # gnuplot process runner
  def self.open
    cmd = 'gnuplot --persist'
    data = IO.popen(cmd, 'w+') do |io|
      yield io
      io.close_write
      return io.read
    end
    data
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
        @settings.xrange = xrange
        @settings.yrange = yrange

        template = File.read(@template)
        haml_engine = Haml::Engine.new(template)
        haml_engine.render(self)
      end

      def add_dataset
        dataset = Dataset.new
        @datasets << dataset
        dataset
      end

      def xrange
        x_values = @datasets.map { |dataset| dataset.data[0] }.flatten
        [x_values.min, x_values.max]
      end

      def yrange
        y_values = @datasets.map { |dataset| dataset.data[1] }.flatten
        errors = @datasets.map { |dataset| dataset.data[2] }.flatten
        Gnup.calculate_yrange y_values, errors, @settings.is_log
      end

      # plot area settings
      class Settings
        attr_accessor :is_log, :eps_path, :ylabel, :xrange, :yrange, :xtics
        def initialize
          @is_log = false
          @eps_path = @xtics = nil
          @ylabel = 'tetetete'
          @xrange = @yrange = []
        end
      end

      # plot datasets
      class Dataset
        attr_accessor :data, :plot, :errorbar, :legend, :line, :title, :color
        def initialize
          @data = nil
          @plot = @errorbar = @legend = @line = true
          @title = ''
        end
      end
    end
  end

  class <<self
    def calculate_yrange(y_values, errors, is_log)
      y_values = y_values.map.with_index { |v, i|
        [v.to_f + errors[i].to_f, v.to_f - errors[i].to_f] if v != '?'
      }.flatten.compact
      return [] if y_values.empty?

      ymax = y_values.max
      ymin = y_values.min

      return [min_in_log(ymin), max_in_log(ymax)] if is_log
      [min_in_liner(ymin), max_in_liner(ymax)]
    end

    def max_in_log(value)
      digit = (Math.log10 value).floor + 1
      (10**(digit)).to_f
    end

    def min_in_log(value)
      digit = (Math.log10 value).floor
      (10**(digit)).to_f
    end

    def max_in_liner(value)
      digit = 10**(Math.log10(value).floor)
      (value.to_f / digit.to_f).ceil.to_i * digit
    end

    def min_in_liner(value)
      value
    end
  end
end
