## ROADMAP

* in_order
* doesnt_send (and figure out how it relates to ordering message expectations)
  * doesnt_send vs never_sends
  * doesnt_sent.here vs doesnt_send.at_all
* add color to failure message diffs
* make failure message diff colors configurable via env vars for acessibility

## RELEASE 0.2.0

* FEATURE: `in_any_order` lets you declare a subset of protocol messages that you don't care about the order of, just that they are sent & received with the correct arguments (if any).
* ENHANCEMENT: `ObjectProtocol#bind` now provides a helpful error message if you try to bind the wrong participant names.

## RELEASE 0.1.0

* FEATURE: ObjectProtocols can be instantiated and used in tests
* FEATURE: We provide a `be_satisfied_by` matcher as a convenience in tests. It's failure messages are really helpful.
