# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fepfile}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Forest Carlisle"]
  s.date = %q{2010-09-08}
  s.description = %q{FEP-formatted file library. Makes ACHing easier.}
  s.email = %q{forestcarlisle@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "Gemfile",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "doc/FEP_File_Specification.pdf",
     "fepfile.gemspec",
     "lib/fepfile.rb",
     "lib/fepfile/file_comment_record.rb",
     "lib/fepfile/file_header_record.rb",
     "lib/fepfile/transaction_addenda_record.rb",
     "lib/fepfile/transaction_detail_record.rb",
     "lib/fepfile/transaction_summary_record.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/specs/fepfile_spec.rb",
     "spec/specs/file_comment_record_spec.rb",
     "spec/specs/file_header_record_spec.rb",
     "spec/specs/transaction_detail_record_spec.rb",
     "spec/specs/transaction_summary_record_spec.rb",
     "spec/support/extensions/array.rb",
     "specs.watchr"
  ]
  s.homepage = %q{http://github.com/forest/fepfile}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{FEP-formatted file library}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/specs/fepfile_spec.rb",
     "spec/specs/file_comment_record_spec.rb",
     "spec/specs/file_header_record_spec.rb",
     "spec/specs/transaction_detail_record_spec.rb",
     "spec/specs/transaction_summary_record_spec.rb",
     "spec/support/extensions/array.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<money>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<money>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<money>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
