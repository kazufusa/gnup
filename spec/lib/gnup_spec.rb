require 'spec_helper'

describe Gnup do

  describe 'generate gnuplots commands' do
    it 'render template' do
      commands = Gnup::Plot::Commands.new('spec/lib/templates/test.haml')
      expect(commands.gen).to include('plot')
    end
  end

  describe 'Gnup plotting' do
    it 'use test plt file to plot' do
      Gnup.open do |gnup|
        open('spec/lib/test.plt') do |file|
          line = file.read
          gnup << line
        end
      end
      expect(FileTest.exist?('test.eps')).to eq true
      `convert test.eps test.png`
      File.delete('test.eps')
    end

    it 'use test rendered plt file to plot' do
      Gnup.open do |gnup|
        commands = Gnup::Plot::Commands.new('spec/lib/templates/test.haml')
        gnup << commands.gen
      end
      expect(FileTest.exist?('test.eps')).to eq true
      `convert test.eps test.png`
      File.delete('test.eps')
    end

  end

  describe 'Draw gnuplot with point data sets' do
    it 'single line plot' do
      datas = [
        [
          [1, 2, 3, 4, 5],
          [5, 4, 3, 2, 1],
          [1, 1, 1, 1, 1]
        ],
        [
          [1, 2, 3, 4, 5],
          [1, 2, 3, '?', 5],
          [1, 1, 1, '?', 1]
        ]
      ]
      Gnup::Plot.new do |gplot|
        gplot.settings do |settings|
          settings.eps_path = 'test1.eps'
          settings.xtics = %w(111 222 333 444 555444444444)
        end
        datas.each do |data|
          gplot.add_dataset do |dataset|
            dataset.data = data
            dataset.plot = true
            dataset.errorbar = true
            dataset.color = '#FF0000'
            dataset.title = 'test line'
            dataset.legend = true
            dataset.line = true
          end
        end
      end
      expect(FileTest.exist?('test1.eps')).to eq true
      if FileTest.exist?('test1.eps')
        `convert test1.eps test1.png`
        File.delete('test1.eps')
      end
    end
  end

  describe 'yrange calculation' do

    context 'y:670, error:100 in liner scale' do
      y = [670, '?']
      errors = [100, '?']
      it { expect(Gnup.calculate_yrange(y, errors, false)).to eq [570.0, 800.0] }
    end

    context 'y:670, error:100 in log scale' do
      y = [670]
      errors = Array.new(1, 100)
      it { expect(Gnup.calculate_yrange(y, errors, true)).to eq [100.0, 1000.0] }
    end

  end

end
