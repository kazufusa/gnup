require 'spec_helper'

describe Gnup do

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
        [1, 2, 3, 4, 5],
        [1, 2, 3, 4, 5],
        [1, 1, 1, 1, 1]
      ]
      Gnup::Plot.new do |gplot|
        gplot.settings do |settings|
          settings.eps_path = 'test1.eps'
        end
        datas.each do |data|
          gplot.add_dataset do |dataset|
            dataset.data = data
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

  describe 'generate gnuplots commands' do
    it 'render template' do
      commands = Gnup::Plot::Commands.new('spec/lib/templates/test.haml')
      expect(commands.gen).to include('plot')
    end
  end
end
