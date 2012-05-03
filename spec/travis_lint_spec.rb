require "spec_helper"

describe "A .travis.yml" do
  let(:language_key_is_mandatory) do
    { :key => :language, :issue => "The \"language\" key is mandatory" }
  end

  let(:rvm_key_is_recommended) do
    { :key => :rvm, :issue => "Specify Ruby versions/implementations you want to test against using the \"rvm\" key" }
  end

  let(:prefer_jruby18mode_over_jruby) do
    { :key => :rvm, :issue => "Prefer jruby-18mode RVM alias to jruby" }
  end

  let(:prefer_rbx18mode_over_rbx) do
    { :key => :rvm, :issue => "Prefer rbx-18mode RVM alias to rbx" }
  end

  let(:rbx20_is_no_longer_provided) do
    { :key => :rvm, :issue => "rbx-2.0 RVM alias is no longer provided. Please use rbx-18mode or rbx-19mode instead." }
  end

  let(:rbx200pre_is_no_longer_provided) do
    { :key => :rvm, :issue => "rbx-2.0.0pre RVM alias is no longer provided. Please use rbx-18mode or rbx-19mode instead." }
  end

  let(:otp_release_key_is_required) do
    { :key => :otp_release, :issue => "Specify OTP releases you want to test against using the \"otp_release\" key" }
  end

  let(:docs) { "Travis CI documentation at http://bit.ly/travis-ci-environment" }



  def content_of_sample_file(name)
    path = Pathname.new(File.join("spec", "files", name)).expand_path

    YAML.load_file(path.to_s)
  end

  context "that is blank" do
    it "is valid" do
      Travis::Lint::Linter.validate({}).should_not include(language_key_is_mandatory)

      Travis::Lint::Linter.valid?(content_of_sample_file("no_language_key.yml")).should be_true
    end
  end

  context "using String keys" do
    it "is validates as with Symbol keys" do
      Travis::Lint::Linter.validate({ "language" => "ruby" }).should include(rvm_key_is_recommended)
    end
  end

  context "that has language set to Ruby" do
    context "but has no \"rvm\" key" do
      it "is invalid" do
        Travis::Lint::Linter.validate({ :language => "ruby" }).should include(rvm_key_is_recommended)
        Travis::Lint::Linter.valid?(content_of_sample_file("no_rvm_key.yml")).should be_false
      end
    end


    context "and uses jruby instead of jruby-18mode" do
      let(:travis_yml) do
        { :language => "ruby", :rvm => ["jruby"] }
      end

      it "is invalid" do
        Travis::Lint::Linter.validate(travis_yml).should include(prefer_jruby18mode_over_jruby)
        Travis::Lint::Linter.valid?(content_of_sample_file("uses_jruby_instead_of_jruby_in_specific_mode.yml")).should be_false
      end
    end


    context "and uses rbx instead of rbx-18mode" do
      let(:travis_yml) do
        { :language => "ruby", :rvm => ["rbx", "1.9.3"] }
      end

      it "is invalid" do
        Travis::Lint::Linter.validate(travis_yml).should include(prefer_rbx18mode_over_rbx)
      end
    end


    context "and uses rbx-2.0 instead of rbx-18mode" do
      let(:travis_yml) do
        { :language => "ruby", :rvm => ["rbx-2.0", "1.9.3"] }
      end

      it "is invalid" do
        Travis::Lint::Linter.validate(travis_yml).should include(rbx20_is_no_longer_provided)
        Travis::Lint::Linter.valid?(content_of_sample_file("uses_old_rbx_aliases.yml")).should be_false
      end
    end


    context "and uses rbx-2.0.0pre instead of rbx-18mode" do
      let(:travis_yml) do
        { :language => "ruby", :rvm => ["rbx-2.0.0pre", "1.9.3"] }
      end

      it "is invalid" do
        Travis::Lint::Linter.validate(travis_yml).should include(rbx200pre_is_no_longer_provided)
      end
    end



    context "and uses an unsupported Ruby version" do
      let(:unsupported_rubies) do
        { :key => :rvm, :issue => "Detected unsupported Ruby versions. For an up-to-date list of supported Rubies, see #{docs}" }
      end

      let(:travis_yml) do
        { :language => "ruby", :rvm => ["neoruby", "goruby", "bonanzaruby"] }
      end

      it "is invalid" do
        Travis::Lint::Linter.validate(travis_yml).should include(unsupported_rubies)
        Travis::Lint::Linter.valid?(content_of_sample_file("uses_unsupported_rubies.yml")).should be_false
      end
    end


    context "that specifies Ruby as the language but tries to set node_js version" do
      let(:travis_yml) do
        { :language => "ruby", :rvm => ["1.9.3"], :node_js => ["0.6"] }
      end

      it "is invalid" do
        Travis::Lint::Linter.validate(travis_yml).should include({ :key => :language, :issue => "Language is set to Ruby but node_js key is present. Ruby builder will ignore node_js key." })
      end
    end
  end



  context "that has language set to node_js" do
    context "and uses an unsupported Node.js version" do
      let(:unsupported_nodejs) do
        { :key => :node_js, :issue => "Detected unsupported Node.js versions. For an up-to-date list of supported Node.js versions, see #{docs}" }
      end

      let(:travis_yml) do
        { :language => "node_js", :node_js => ["100.0", "0.5"] }
      end

      it "is invalid" do
        Travis::Lint::Linter.validate(travis_yml).should include(unsupported_nodejs)
        Travis::Lint::Linter.valid?(content_of_sample_file("uses_unsupported_nodejs.yml")).should be_false
      end
    end
  end


  context "that has language set to PHP" do
    context "and uses an unsupported PHP version" do
      let(:unsupported_php) do
        { :key => :php, :issue => "Detected unsupported PHP versions. For an up-to-date list of supported PHP versions, see #{docs}" }
      end

      let(:travis_yml) do
        { :language => "php", :php => ["100.0", "0.5"] }
      end

      it "is invalid" do
        Travis::Lint::Linter.validate(travis_yml).should include(unsupported_php)
        Travis::Lint::Linter.valid?(content_of_sample_file("uses_unsupported_php.yml")).should be_false
      end
    end
  end



  context "that has language set to Python" do
    context "and uses an unsupported Python version" do
      let(:unsupported_python) do
        { :key => :python, :issue => "Detected unsupported Python versions. For an up-to-date list of supported Python versions, see #{docs}" }
      end

      let(:travis_yml) do
        { :language => "python", :python => ["stackless-py", "2.4", "2.3"] }
      end

      it "is invalid" do
        Travis::Lint::Linter.validate(travis_yml).should include(unsupported_python)
        Travis::Lint::Linter.valid?(content_of_sample_file("uses_unsupported_python.yml")).should be_false
      end
    end
  end



  context "that has language set to Perl" do
    context "and uses an unsupported Perl version" do
      let(:unsupported_perl) do
        { :key => :perl, :issue => "Detected unsupported Perl versions. For an up-to-date list of supported Perl versions, see #{docs}" }
      end

      let(:travis_yml) do
        { :language => "perl", :perl => ["5.6", "5.8"] }
      end

      it "is invalid" do
        Travis::Lint::Linter.validate(travis_yml).should include(unsupported_perl)
        Travis::Lint::Linter.valid?(content_of_sample_file("uses_unsupported_perl.yml")).should be_false
      end
    end
  end





  context "that has language set to erlang" do
    context "but has no \"otp_release\" key" do
      it "is invalid" do
        Travis::Lint::Linter.validate({ :language => "erlang" }).should include(otp_release_key_is_required)
        Travis::Lint::Linter.valid?({ :language => "erlang" }).should be_false
      end
    end
  end
end
