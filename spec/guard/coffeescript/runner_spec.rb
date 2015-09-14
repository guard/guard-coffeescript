RSpec.describe Guard::CoffeeScript::Runner do
  let(:runner) { Guard::CoffeeScript::Runner }
  let(:pattern) { /^(.+)\.(?:coffee|coffee\.md|litcoffee)$/ }
  let(:formatter) { Guard::CoffeeScript::Formatter }

  before do
    allow(runner).to receive(:compile).and_return ''
    allow(formatter).to receive(:notify)

    allow(FileUtils).to receive(:mkdir_p)
    allow(FileUtils).to receive(:remove_file)
    allow(File).to receive(:open)
    Guard::CoffeeScript::Runner.last_run_failed = false
  end

  describe '#run' do
    context 'without the :noop option' do
      it 'shows a start notification' do
        expect(formatter).to receive(:info).once.with('Compile a.coffee, b.coffee.md, c.litcoffee',  reset: true)
        expect(formatter).to receive(:success).once.with('Successfully generated ')
        runner.run(['a.coffee', 'b.coffee.md', 'c.litcoffee'], [])
      end
    end

    context 'with the :noop option' do
      it 'shows a start notification' do
        expect(formatter).to receive(:info).once.with('Verify a.coffee, b.coffee.md, c.litcoffee',  reset: true)
        expect(formatter).to receive(:success).once.with('Successfully verified ')
        runner.run(['a.coffee', 'b.coffee.md', 'c.litcoffee'], [],  noop: true)
      end
    end

    context 'without a nested directory' do
      let(:pattern) { %r{src/.+\.(?:coffee|coffee\.md|litcoffee)$} }

      context 'without the :noop option' do
        it 'compiles the CoffeeScripts to the output and replace .{coffee,coffee.md,litcoffee} with .js' do
          expect(FileUtils).to receive(:mkdir_p).with("#{ @project_path }/target")
          expect(File).to receive(:open).with("#{ @project_path }/target/a.js", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/target/b.js", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/target/c.js", 'w')
          runner.run(['src/a.coffee', 'src/b.coffee.md', 'src/c.litcoffee'], [pattern],  output: 'target')
        end

        it 'compiles the CoffeeScripts to the output and replace .js.{coffee,coffee.md,litcoffee} with .js' do
          expect(FileUtils).to receive(:mkdir_p).with("#{ @project_path }/target")
          expect(File).to receive(:open).with("#{ @project_path }/target/a.js", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/target/b.js", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/target/c.js", 'w')
          runner.run(['src/a.js.coffee', 'src/b.js.coffee.md', 'src/c.litcoffee'], [pattern],  output: 'target')
        end
      end

      context 'without the :output option' do
        it 'compiles the CoffeeScripts to the same dir like the file and replace .{coffee,coffee.md,litcoffee} with .js' do
          expect(FileUtils).to receive(:mkdir_p).with("#{ @project_path }/src")
          expect(File).to receive(:open).with("#{ @project_path }/src/a.js", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/src/b.js", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/src/c.js", 'w')
          runner.run(['src/a.coffee', 'src/b.coffee.md', 'src/c.litcoffee'], [pattern])
        end

        it 'compiles the CoffeeScripts to the same dir like the file and replace .js.{coffee,coffee.md,litcoffee} with .js' do
          expect(FileUtils).to receive(:mkdir_p).with("#{ @project_path }/src")
          expect(File).to receive(:open).with("#{ @project_path }/src/a.js", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/src/b.js", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/src/c.js", 'w')
          runner.run(['src/a.js.coffee', 'src/b.js.coffee.md', 'src/c.js.litcoffee'], [pattern])
        end
      end

      context 'with the :noop option' do
        it 'does not write the output file' do
          expect(FileUtils).not_to receive(:mkdir_p).with("#{ @project_path }/target")
          expect(File).not_to receive(:open).with("#{ @project_path }/target/a.js", 'w')
          expect(File).not_to receive(:open).with("#{ @project_path }/target/b.js", 'w')
          expect(File).not_to receive(:open).with("#{ @project_path }/target/c.js", 'w')
          runner.run(['src/a.js.coffee', 'src/b.js.coffee.md', 'src/c.js.litcoffee'], [pattern],  output: 'target', noop: true)
        end
      end

      context 'with the :source_map option' do
        it 'compiles the source map to the same dir like the file and replace .{coffee,coffee.md,litcoffee} with .js.map' do
          expect(FileUtils).to receive(:mkdir_p).with("#{ @project_path }/src")
          expect(File).to receive(:open).with("#{ @project_path }/src/a.js.map", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/src/b.js.map", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/src/c.js.map", 'w')
          runner.run(['src/a.coffee', 'src/b.coffee.md', 'src/c.litcoffee'], [pattern], source_map: true)
        end

        it 'compiles the source map to the same dir like the file and replace .js.{coffee,coffee.md,litcoffee} with .js.map' do
          expect(FileUtils).to receive(:mkdir_p).with("#{ @project_path }/src")
          expect(File).to receive(:open).with("#{ @project_path }/src/a.js.map", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/src/b.js.map", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/src/c.js.map", 'w')
          runner.run(['src/a.js.coffee', 'src/b.js.coffee.md', 'src/c.js.litcoffee'], [pattern], source_map: true)
        end
      end
    end

    context 'with the :bare option set to an array of filenames' do
      let(:pattern) { %r{src/.+\.(?:coffee|coffee\.md|litcoffee)$} }

      before do
        allow(runner).to receive(:compile).and_call_original
        allow(::CoffeeScript).to receive(:compile)
        expect(File).to receive(:read).with('src/a.coffee').and_return 'a = -> 1'
        expect(File).to receive(:read).with('src/b.coffee').and_return 'b = -> 2'
      end

      it 'should compile files in the list without the outer function wrapper' do
        expect(::CoffeeScript).to receive(:compile).with 'a = -> 1', hash_including(bare: true)
        runner.run(['src/a.coffee', 'src/b.coffee'], [pattern],  output: 'target', bare: ['a.coffee'])
      end

      it 'should compile files not in the list with the outer function wrapper' do
        expect(::CoffeeScript).to receive(:compile).with 'b = -> 2', hash_including(bare: false)
        runner.run(['src/a.coffee', 'src/b.coffee'], [pattern],  output: 'target', bare: ['a.coffee'])
      end
    end

    context 'with the :shallow option set to false' do
      let(:pattern) { /^app\/coffeescripts\/(.+)\.(?:coffee|coffee\.md|litcoffee)$/ }

      it 'compiles the CoffeeScripts to the output and creates nested directories' do
        expect(FileUtils).to receive(:mkdir_p).with("#{ @project_path }/javascripts/x/y")
        expect(File).to receive(:open).with("#{ @project_path }/javascripts/x/y/a.js", 'w')
        expect(File).to receive(:open).with("#{ @project_path }/javascripts/x/y/b.js", 'w')
        expect(File).to receive(:open).with("#{ @project_path }/javascripts/x/y/c.js", 'w')
        runner.run(['app/coffeescripts/x/y/a.coffee', 'app/coffeescripts/x/y/b.coffee.md', 'app/coffeescripts/x/y/c.litcoffee'],
                   [pattern],  output: 'javascripts', shallow: false)
      end

      context 'with no folders in the input path' do
        it 'fails silently because there are no patterns and no output paths' do
          expect(File).not_to receive(:open)
          runner.run(['application.coffee'], [], output: 'javascripts', shallow: false)
        end
      end

      context 'with the :source_map option' do
        it 'generates the source map to the output and creates nested directories' do
          expect(FileUtils).to receive(:mkdir_p).with("#{ @project_path }/javascripts/x/y")
          expect(File).to receive(:open).with("#{ @project_path }/javascripts/x/y/a.js.map", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/javascripts/x/y/b.js.map", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/javascripts/x/y/c.js.map", 'w')
          runner.run(['app/coffeescripts/x/y/a.coffee', 'app/coffeescripts/x/y/b.coffee.md', 'app/coffeescripts/x/y/c.litcoffee'],
                     [pattern],  output: 'javascripts', shallow: false, source_map: true)
        end
      end
    end

    context 'with the :shallow option set to true' do
      let(:pattern) { /^app\/coffeescripts\/(.+)\.(?:coffee|coffee\.md|litcoffee)$/ }

      it 'compiles the CoffeeScripts to the output without creating nested directories' do
        expect(FileUtils).to receive(:mkdir_p).with("#{ @project_path }/javascripts")
        expect(File).to receive(:open).with("#{ @project_path }/javascripts/a.js", 'w')
        expect(File).to receive(:open).with("#{ @project_path }/javascripts/b.js", 'w')
        expect(File).to receive(:open).with("#{ @project_path }/javascripts/c.js", 'w')
        runner.run(['app/coffeescripts/x/y/a.coffee', 'app/coffeescripts/x/y/b.coffee.md', 'app/coffeescripts/x/y/c.litcoffee'],
                   [pattern],  output: 'javascripts', shallow: true)
      end

      context 'with the :source_map option' do
        it 'generates the source map to the output without creating nested directories' do
          expect(FileUtils).to receive(:mkdir_p).with("#{ @project_path }/javascripts")
          expect(File).to receive(:open).with("#{ @project_path }/javascripts/a.js.map", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/javascripts/b.js.map", 'w')
          expect(File).to receive(:open).with("#{ @project_path }/javascripts/c.js.map", 'w')
          runner.run(['app/coffeescripts/x/y/a.coffee', 'app/coffeescripts/x/y/b.coffee.md', 'app/coffeescripts/x/y/c.litcoffee'],
                     [pattern],  output: 'javascripts', shallow: true, source_map: true)
        end
      end
    end

    context 'with the :source_map option' do
      before do
        allow(runner).to receive(:compile).and_call_original
        allow(::CoffeeScript).to receive(:compile)
        allow(File).to receive(:read) { |file| file }
      end

      after do
        allow(runner).to receive(:compile).and_return ''
        allow(::CoffeeScript).to receive(:compile).and_call_original
      end

      it 'compiles with source map file options set' do
        expect(::CoffeeScript).to receive(:compile).with 'src/a.coffee', hash_including(
          sourceMap: true,
          generatedFile: 'a.js',
          sourceFiles: ['a.coffee'],
          sourceRoot: 'src'
        )
        runner.run(['src/a.coffee'], [pattern],  output: 'target', source_map: true, input: 'src')
      end

      it 'accepts a different source_root' do
        expect(::CoffeeScript).to receive(:compile).with 'src/a.coffee', hash_including(sourceRoot: 'foo')
        runner.run(['src/a.coffee'], [pattern],  output: 'target', source_map: true, source_root: 'foo')
      end
    end

    context 'with literate coffeescript' do
      before do
        allow(runner).to receive(:compile).and_call_original
        allow(::CoffeeScript).to receive(:compile)
        allow(File).to receive(:read) { |file| file }
      end

      after do
        allow(runner).to receive(:compile).and_return ''
        allow(::CoffeeScript).to receive(:compile).and_call_original
      end

      it 'compiles with the :literate option set' do
        expect(::CoffeeScript).to receive(:compile).with 'a.coffee', hash_not_including(literate: true)
        expect(::CoffeeScript).to receive(:compile).with 'b.coffee.md', hash_including(literate: true)
        expect(::CoffeeScript).to receive(:compile).with 'c.litcoffee', hash_including(literate: true)
        runner.run(['a.coffee', 'b.coffee.md', 'c.litcoffee'], [pattern],  output: 'javascripts')
      end
    end

    context 'with compilation errors' do
      context 'without the :noop option' do
        it 'shows the error messages' do
          expect(runner).to receive(:compile).and_raise ::CoffeeScript::CompilationError.new("Parse error on line 2: Unexpected 'UNARY'")
          expect(formatter).to receive(:error).once.with("a.coffee: Parse error on line 2: Unexpected 'UNARY'")
          expect(formatter).to receive(:notify).with("a.coffee: Parse error on line 2: Unexpected 'UNARY'",
                                                     title: 'CoffeeScript results',
                                                     image: :failed,
                                                     priority: 2)
          runner.run(['a.coffee'], [pattern],  output: 'javascripts')
        end
      end

      context 'with the :noop option' do
        it 'shows the error messages' do
          expect(runner).to receive(:compile).and_raise ::CoffeeScript::CompilationError.new("Parse error on line 2: Unexpected 'UNARY'")
          expect(formatter).to receive(:error).once.with("a.coffee: Parse error on line 2: Unexpected 'UNARY'")
          expect(formatter).to receive(:notify).with("a.coffee: Parse error on line 2: Unexpected 'UNARY'",
                                                     title: 'CoffeeScript results',
                                                     image: :failed,
                                                     priority: 2)
          runner.run(['a.coffee'], [pattern],  output: 'javascripts', noop: true)
        end
      end

      context 'with the :error_to_js option' do
        it 'write the error message as javascript file' do
          expect(runner).to receive(:compile).and_raise ::CoffeeScript::CompilationError.new("Parse error on line 2: Unexpected 'UNARY'")
          expect(runner).to receive(:write_javascript_file).once.with("throw \"a.coffee: Parse error on line 2: Unexpected 'UNARY'\";", nil, 'a.coffee', 'javascripts', kind_of(Hash))
          runner.run(['a.coffee'], [pattern],  output: 'javascripts', error_to_js: true)
        end
      end
    end

    context 'with engine errors' do
      context 'without the :noop option' do
        it 'shows the error messages' do
          expect(runner).to receive(:compile).and_raise ::CoffeeScript::EngineError.new("SyntaxError: [stdin]:1:5: reserved word \"true\" can't be assigned")
          expect(formatter).to receive(:error).once.with("a.coffee: SyntaxError: [stdin]:1:5: reserved word \"true\" can't be assigned")
          expect(formatter).to receive(:notify).with("a.coffee: SyntaxError: [stdin]:1:5: reserved word \"true\" can't be assigned",
                                                     title: 'CoffeeScript results',
                                                     image: :failed,
                                                     priority: 2)
          runner.run(['a.coffee'], [pattern],  output: 'javascripts')
        end
      end
    end

    context 'without compilation errors' do
      context 'without the :noop option' do
        it 'shows a success messages' do
          expect(formatter).to receive(:success).once.with('Successfully generated javascripts/a.js')
          expect(formatter).to receive(:notify).with('Successfully generated javascripts/a.js',
                                                     title: 'CoffeeScript results')
          runner.run(['a.coffee'], [pattern],  output: 'javascripts')
        end
      end

      context 'with the :noop option' do
        it 'shows a success messages' do
          expect(formatter).to receive(:success).once.with('Successfully verified javascripts/a.js')
          expect(formatter).to receive(:notify).with('Successfully verified javascripts/a.js',
                                                     title: 'CoffeeScript results')
          runner.run(['a.coffee'], [pattern],  output: 'javascripts',
                                               noop: true)
        end
      end

      context 'with the :hide_success option set to true' do
        let(:pattern) { /^app\/coffeescripts\/.+\.(?:coffee|coffee\.md|litcoffee)$/ }

        it 'does not show the success message' do
          expect(formatter).not_to receive(:success).with('Successfully generated javascripts/a.js')
          expect(formatter).not_to receive(:notify).with('Successfully generated javascripts/a.js',
                                                         title: 'CoffeeScript results')
          runner.run(['app/coffeescripts/x/y/a.coffee'], [pattern],  output: 'javascripts',
                                                                     hide_success: true)
        end
      end
    end

    context 'with :hide_success over multiple runs' do
      it 'shows the failure message every time' do
        expect(runner).to receive(:compile).twice.and_raise ::CoffeeScript::CompilationError.new("Parse error on line 2: Unexpected 'UNARY'")
        expect(formatter).to receive(:error).twice.with("a.coffee: Parse error on line 2: Unexpected 'UNARY'")
        expect(formatter).to receive(:notify).twice.with("a.coffee: Parse error on line 2: Unexpected 'UNARY'",
                                                         title: 'CoffeeScript results',
                                                         image: :failed,
                                                         priority: 2)

        2.times { runner.run(['a.coffee'], [pattern],  output: 'javascripts') }
      end

      it 'shows the success message only when previous attempt was failure' do
        expect(runner).to receive(:compile).and_raise ::CoffeeScript::CompilationError.new("Parse error on line 2: Unexpected 'UNARY'")
        runner.run(['a.coffee'], [pattern],  output: 'javascripts',
                                             hide_success: true)

        allow(runner).to receive(:compile).and_return ''
        expect(formatter).to receive(:success).with('Successfully generated javascripts/a.js')
        expect(formatter).to receive(:notify).with('Successfully generated javascripts/a.js',
                                                   title: 'CoffeeScript results')
        runner.run(['a.coffee'], [pattern],  output: 'javascripts',
                                             hide_success: true)
      end
    end
  end

  describe '#remove' do
    let(:pattern) { %r{src/.+\.(?:coffee|coffee\.md|litcoffee)$} }

    before do
      expect(File).to receive(:exist?).with('target/a.js').and_return true
      expect(File).to receive(:exist?).with('target/b.js').and_return true
      expect(File).to receive(:exist?).with('target/c.js').and_return true
    end

    it 'removes the files' do
      expect(FileUtils).to receive(:remove_file).with('target/a.js')
      expect(FileUtils).to receive(:remove_file).with('target/b.js')
      expect(FileUtils).to receive(:remove_file).with('target/c.js')
      runner.remove(['src/a.coffee', 'src/b.coffee.md', 'src/c.litcoffee'], [pattern],  output: 'target')
    end

    it 'shows a notification' do
      expect(formatter).to receive(:success).once.with('Removed target/a.js, target/b.js, target/c.js')
      expect(formatter).to receive(:notify).with('Removed target/a.js, target/b.js, target/c.js',
                                                 title: 'CoffeeScript results')

      runner.remove(['src/a.coffee', 'src/b.coffee.md', 'src/c.litcoffee'], [pattern],  output: 'target')
    end
  end
end
