#!/bin/bash
# =============================================================================
# PALIO — PUBLISH ON CHANGE
# =============================================================================
# launchd starts this whenever a file in this folder changes, which is how a
# refresh written from Claude reaches GitHub without anyone pressing anything.
#
# The only thing it adds over publish-auto.command is a pause. A refresh writes
# index.html and sw.js as two separate operations; without the wait, launchd can
# fire after the first one and publish a half-finished pair. Twenty seconds is
# comfortably longer than the gap between them.
#
# Run publish-auto.command directly if you are doing it by hand — no wait.
# =============================================================================

sleep 20
exec "$(dirname "$0")/publish-auto.command"
