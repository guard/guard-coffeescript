# Changelog

## Master

- [#29](https://github.com/netzpirat/guard-coffeescript/issues/29) Add support for compiling literate coffeescript. ([@oychang][])

## 1.3.4 - September 25, 2013

- [#12](https://github.com/guard/guard-coffeescript/issues/12) Fix `:hide_success` after a failure. ([@whatcould][])

## 1.3.3 - September 9, 2013

- [#24](https://github.com/netzpirat/guard-coffeescript/issues/24) Fix selective `bare` option.

## 1.3.2 - Mai 30, 2013

- [#11](https://github.com/guard/guard-coffeescript/issues/11) Improve source map support. ([@jabbawookiees][])

## 1.3.1 - Mai 23, 2013

- [#22](https://github.com/netzpirat/guard-coffeescript/pull/22) Improve source map support. ([@rogueg][])

## 1.3.0 - March 5, 2013

- Add `:source_map` option for CoffeeScript.

## 1.2.1 - November 1, 2012

- Remove file creation notification.

## 1.2.0 - July 27, 2012

- [#10](https://github.com/guard/guard-coffeescript/pull/10) Adding a timestamp to the success message. ([@proc][])

## 1.1.0 - July 18, 2012

- [#9](https://github.com/guard/guard-coffeescript/pull/9) Fix file removal handling. ([@caldwell][])

## 1.0.0 - June 02, 2012

- Depend on Guard 1.1.0

## 0.6.0 - April 23, 2012

- [#14](https://github.com/netzpirat/guard-coffeescript/pull/14) Add option `:error_to_js`. ([@damin][])

## 0.5.7 - April 7, 2012

- Catch StandardError instead of ExecJS errors.
- Do not notify other Guards when changed files is empty.

## 0.5.6 - April 7, 2012

- [#12](https://github.com/netzpirat/guard-coffeescript/issues/12) Fix wrong output without `:output` option.

## 0.5.5 - March 13, 2012

- [#11](https://github.com/netzpirat/guard-coffeescript/issues/11) Fix compilation when using a simple watch expression.

## 0.5.4 - December 15, 2011

- Top level directories are empty, so make them simply absolute.

## 0.5.3 - December 13, 2011

- [#8](https://github.com/guard/guard-coffeescript/pull/8) Follow symlinks. ([@jtolds][])

## 0.5.2 - October 1, 2011

- Depend on Guard 0.8.3
- Enable `:task_has_failed`

## 0.5.0 - September 30, 2011

- Support #run_on_deletion to cleanup generated JavaScript.
- [#8](https://github.com/netzpirat/guard-coffeescript/pull/8) Added option to regenerate all files on startup. ([@jqr][])

## 0.4.2 - September 15, 2011

- Catch all exceptions from compiling.

## 0.4.1 - September 8, 2011

- Documentation update

## 0.4.0 - September 3, 2011

- Add `:noop` option for use with the Rails 3.1 asset pipeline.

## 0.3.3 - September 3, 2011

- [#4](https://github.com/guard/guard-coffeescript/pull/4) Add `:priority` option. ([@akahigeg][])

## 0.3.2 - July 25, 2011

- [#3](https://github.com/guard/guard-coffeescript/pull/3) Add `:bare` option. [@jraines][]

## 0.3.1 - July 23, 2011

- Make `:input` match more explicit.

## 0.3.0 - June 6, 2011

- Depend on Guard 0.4

## 0.2.4 - May 24, 2011

- Handle `*.js.coffee` files correct.
- When omitting the output option, it'll be taken from the input option.

## 0.2.3 - May 13, 2011

- [#5](https://github.com/netzpirat/guard-coffeescript/pull/5) Added formatter to colorize the success and error messages. ([@vizjerai][])

## 0.2.2 - May 11, 2011

- [#4](https://github.com/netzpirat/guard-coffeescript/pull/4) Added result messages to Guard::UI. ([@vizjerai][])

## 0.2.1 - May 8, 2011

- [#2](https://github.com/guard/guard-coffeescript/pull/2) Add `:hide_success` option. ([@hoverbird][])

## 0.2.0 - April 4, 2011

- [#2](https://github.com/netzpirat/guard-coffeescript/issues/2) Add a shortcut notation for the Guard configuration.

## 0.1.6 - January 9, 2010

- Case insensitive match of compilation error messages.

## 0.1.5 - November 12, 2010

- Support nested directories.
- Add `:shallow` option.

## 0.1.1 - October 28, 2010

- Better growl messages and print full CoffeeScript output to the console.

## 0.1.0 - October 26, 2010

- Inital release

[@MyD]: https://github.com/MyD
[@akahigeg]: https://github.com/akahigeg
[@caldwell]: https://github.com/caldwell
[@damin]: https://github.com/damin
[@hoverbird]: https://github.com/hoverbird
[@jabbawookiees]: https://github.com/jabbawookiees
[@jqr]: https://github.com/jqr
[@jraines]: https://github.com/jraines
[@jtolds]: https://github.com/jtolds
[@oychang]: https://github.com/oychang
[@proc]: https://github.com/proc
[@rogueg]: https://github.com/rogueg
[@vizjerai]: https://github.com/vizjerai
[@whatcould]: https://github.com/whatcould
