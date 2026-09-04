# Agent Exchange policy

`Agent Exchange` is a small, deliberate hand-off boundary between Apple-native
personal/archive storage and cross-platform agent-managed work. It is not a
general sync folder, a project repository root, a secrets store, or permission
to scan personal iCloud contents.

## Layout

On macOS, the intended user-visible folder is:

`BT`text
iCloud Drive/Agent Exchange/
├── Inbox/
├── Outbox/
├── Manifests/
└── README.md
`BT`

On Linux, the local staging root is private machine state:

`BT`text
~/.local/share/workstation/agent-exchange/
├── inbox/
├── outbox/
├── manifests/
└── README.md
`BT`

The Linux root is not an iCloud mount and must not claim to be synchronized.
A future private file service may bridge declared Exchange items after explicit
design and approval.

## Transfer contract

- Copy only specifically selected material into Exchange; never sweep Desktop,
  Downloads, Documents, iCloud, or project trees.
- Repositories remain under `~/Projects`; Exchange may hold an export, archive,
  manifest, or review artifact, never an active repository's canonical clone.
- Do not place credentials, private keys, raw transcripts, browser profiles,
  provider configuration, or personal-account material in Exchange.
- A manifest must identify the source, intended destination, owner, reason,
  and content classification without embedding secret values.
- Before moving a durable item, preview the change, inspect Git/reference
  state, choose a recovery path, and obtain approval.
- Deletion, replacement, conflict resolution, remote transfer, and automatic
  synchronization are outside this initial foundation.

## Machine roles

- **Mac:** owns the iCloud Drive projection and may create the visible Exchange
  folder only after the operating system grants the calling surface access.
- **Omarchy:** owns only its private local staging directory. It may prepare
  declared outbound artifacts and inspect local manifests, but it has no direct
  access to personal iCloud storage.
- **Future private file service:** may receive only explicit agent-managed
  roots and declared Exchange artifacts. It is not authorized to index or read
  arbitrary personal iCloud content.
