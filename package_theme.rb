#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

DARK_THEME = ARGV.include?('dark')

THEME_NAME = if DARK_THEME then 'podAmp-dark' else 'podAmp' end

DEST_DIR = File.join(__dir__, 'dist', THEME_NAME)
DEST_ZIP = File.join(__dir__, 'dist', "#{THEME_NAME}.zip")

if ARGV.include?("clean")
  puts "===> Removing dest dir"
  FileUtils.rm_f(DEST_DIR)
end
FileUtils.mkdir_p(DEST_DIR)

COPIED_FILES = Array.new

File.join(DEST_DIR, 'wps', "#{THEME_NAME}.wps").tap do |dest_file|
  puts "===> Copying WPS theme"
  FileUtils.mkdir_p(File.dirname(dest_file))
  COPIED_FILES << dest_file
  puts dest_file
  FileUtils.cp(File.join(__dir__, 'wps', 'podAmp.wps'), dest_file)
end

def copy(kind, pattern, dest_dir)
  source_files = Dir[*pattern]
  return if source_files.empty?

  puts "===> Copying #{kind}"
  FileUtils.mkdir_p(dest_dir)
  source_files.each do |source_file|
    dest_file = File.join(dest_dir, File.basename(source_file))
    COPIED_FILES << dest_file
    puts dest_file
    FileUtils.cp(source_file, dest_file)
  end
end

copy :fonts, File.join(__dir__, 'fonts', '*.fnt'), File.join(DEST_DIR, 'fonts')
copy :images, File.join(__dir__, 'wps', THEME_NAME, '*.bmp'), File.join(DEST_DIR, 'wps', THEME_NAME)

puts "===> Creating zip archive for distribution ..."
FileUtils.rm_f DEST_ZIP
rootdir = __dir__
dirs = COPIED_FILES.map { |x| File.dirname(x.sub("#{rootdir}/dist/#{THEME_NAME}", '.rockbox')) }.uniq

Dir.mktmpdir do |tmpdir|
  Dir.chdir(tmpdir) do
    dirs.each do |d|
      puts "mkdir\t#{d}"
      FileUtils.mkdir_p(d)
    end
    COPIED_FILES.each do |source_file|
      dest_file = source_file.sub("#{rootdir}/dist/#{THEME_NAME}", '.rockbox')
      puts "cp\t#{source_file} -> #{dest_file}"
      FileUtils.cp(source_file, dest_file)
    end
    zip_command = ["zip", DEST_ZIP, "-r", ".rockbox"]
    puts zip_command.join(' ')
    system *zip_command
  end
end
