require 'spec_helper'
require 'cloudmux/scm/git'

describe CloudMux::SCM::Git do
  let(:repo) do 
    CloudMux::SCM::Git.new(
      url: File.expand_path("#{File.dirname(__FILE__)}/fixtures/sample_repo.git"),
      repo_name: 'sample_repo',
      scm_paths: %w{ cookbooks/profiles cookbooks/components }
      )
  end

  after(:each) do
    repo.cleanup
  end

  describe '#dir' do
    it 'returns directory string' do
      dir_string = repo.repo.dir.to_s
      expect(repo.dir).to eq(dir_string)
    end
  end

end