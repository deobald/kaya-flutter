# ADR 0004: Full Text Search

## Context

Because Kaya aims to be local-first, local search needs to be possible on edge devices, such as phones.

## Decision

Kaya Server will keep a plaintext copy of bookmarks, PDFs, and other anga which are difficult to search directly. The Flutter app must download these plaintext copies to `/kaya/words/` (inside `getApplicationSupportDirectory()`) according to the following layout:

* `/kaya/words/` = root
* `/kaya/words/{bookmark}` = bookmark root
* `/kaya/words/{bookmark}/{filename}` = plaintext bookmark contents
* `/kaya/words/{pdf}` = pdf root
* `/kaya/words/{pdf}/{filename}` = plaintext pdf contents
* etc.

These three patterns are symmetrical to the 3 routes Kaya Server exposes:

* `/api/v1/:user_email/words` = root index
* `/api/v1/:user_email/words/:anga` = anga index
* `/api/v1/:user_email/words/:anga/:filename` = file to download

When the user creates a new anga, whether directly through Kaya Server or indirectly via sync, Kaya Server enqueues a background job to transform it into a plaintext copy, which the Flutter app can download when it appears in the index.

**API Mapping:**

* `/kaya/words/` <=> `/api/v1/:user_email/words`
* `/kaya/words/{anga}` <=> `/api/v1/:user_email/words/:anga`
* `/kaya/words/{anga}/{filename}` <=> `/api/v1/:user_email/words/:anga/:filename`

## Status

Accepted.

## Consequences

Cached contents for Full Text Search over both bookmarks and PDFs will allow both local search and server-side search to be much faster. These text files are also human-readable, which means they are useful directly to the user and can also be consumed by other tools.
