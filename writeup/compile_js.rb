#!/usr/bin/env ruby
#lil' script to concatenate and minify JavaScript

require 'rubygems'
require 'closure-compiler'

Header = "// Kevin Lynagh
// December 2010
// Check out the source on my Github page;
//     http://github.com/lynaghk/prote.cs/
// This is commit: #{`git rev-parse HEAD`}\n\n"


def compile_js(input_filenames, output_filename)
  sources = input_filenames.collect{|filename|
    File.read(filename)
  }
  min = Closure::Compiler.new.compress sources*"\n"
  File.open(output_filename, 'w') do |f|
    f.puts Header
    f.puts min
  end
end


#compile overview js
compile_js(['mvp.js',
            'Three.js',
            'models.js',
            'views.js',
            'overview_data.js',
            'overview_main.js'],
           'prote_cs.js')


#compile results js
compile_js(['mvp.js',
            'results/results_data.js',
            'results/charts.js',
            'results/results_main.js'],
           'results/results.js')
           
