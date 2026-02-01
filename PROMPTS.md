# Prompts

## First Pass: AGENTS + PLAN

While running `gradleDebug`, the process got stuck for a while and then the Claude Code process was killed by SIGKILL, somehow. This is a new thread. Please pick up where you left off. You don't need to build and test on physical devices if running on emulators is easier. Here is the previous prompt:

Read [@AGENTS.md](file:///Users/steven/work/deobald/kaya-flutter/AGENTS.md) and [@PLAN.md](file:///Users/steven/work/deobald/kaya-flutter/PLAN.md) , then implement the Kaya Flutter app according to the plan. Be sure to use Flutter from mise so it's up to date (3.38.5). There is a Samsung Galaxy A12 and an iPhone 11 SE attached by USB-C to this computer, if you want to do a native build to a real device.

## Change color scheme to GNOME guidelines

Follow the [GNOME Brand Guidelines](https://brand.gnome.org/) for the application's color scheme, though not for fonts.

Bug: The primary buttons are now hard to see. "Save", "Test Connection", and "Force Sync" do not contrast with the background.
