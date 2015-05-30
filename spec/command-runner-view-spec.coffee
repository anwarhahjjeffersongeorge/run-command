{Editor} = require 'atom'
CommandRunner = require '../lib/command-runner'
CommandRunnerView = require '../lib/command-runner-view'
RunCommand = require '../lib/run-command'

describe "CommandRunnerView", ->
  beforeEach ->
    @runner = new CommandRunner()

  describe "running a command", ->
    it "shows itself", ->
      commandHandler = null
      spyOn(@runner, 'onCommand').andCallFake (handler) ->
        commandHandler = handler

      view = new CommandRunnerView(@runner)
      spyOn(view, 'show')

      commandHandler('echo "foo"')

      expect(view.show).toHaveBeenCalled()

    it "displays the command", ->
      commandHandler = null
      spyOn(@runner, 'onCommand').andCallFake (handler) ->
        commandHandler = handler

      view = new CommandRunnerView(@runner)
      commandHandler('echo "foo"')

      expect(view.header.text()).toEqual('echo "foo"')

    it "displays the command's output", ->
      [stdoutHandler, stderrHandler] = [null, null]

      spyOn(@runner, 'onStdout').andCallFake (handler) ->
        stdoutHandler = handler
      spyOn(@runner, 'onStderr').andCallFake (handler) ->
        stderrHandler = handler

      view = new CommandRunnerView(@runner)

      stdoutHandler('foo\n')
      stderrHandler('bar\n')

      expect(view.output.text()).toEqual('foo\nbar\n')

    it "clears the last command's output", ->
      [commandHandler, stdoutHandler, stderrHandler] = [null, null, null]

      spyOn(@runner, 'onCommand').andCallFake (handler) ->
        commandHandler = handler
      spyOn(@runner, 'onStdout').andCallFake (handler) ->
        stdoutHandler = handler

      view = new CommandRunnerView(@runner)

      commandHandler('echo "foo"; echo "bar"')
      stdoutHandler('foo\nbar\n')
      expect(view.output.text()).toEqual('foo\nbar\n')

      commandHandler('echo "baz"')
      stdoutHandler('baz\n')
      expect(view.output.text()).toEqual('baz\n')

  describe "displaying a command's output", ->
    it "stays locked to the bottom of the output area", ->
      view = new CommandRunnerView(@runner)

      spyOn(view, 'atBottomOfOutput').andReturn(true)
      spyOn(view, 'scrollToBottomOfOutput')

      view.addOutput('foo')
      expect(view.scrollToBottomOfOutput).toHaveBeenCalled()

    it "unlocks from the bottom of the output area when scrolling up", ->
      view = new CommandRunnerView(@runner)

      spyOn(view, 'atBottomOfOutput').andReturn(false)
      spyOn(view, 'scrollToBottomOfOutput')

      view.addOutput('foo')
      expect(view.scrollToBottomOfOutput).not.toHaveBeenCalled()
