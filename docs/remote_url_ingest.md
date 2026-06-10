# Remote URL CLI Ingest

This task runs from the MIRA app home directory on a MIRA host. Use `bundle exec`.

## Connect To A Host

Development:

```bash
ssh tdrmira-dev-02.it.tufts.edu
```

Production:

```bash
ssh tdrmira-prod-02.it.tufts.edu
```

## Become `rubyadm`

```bash
sudo -u rubyadm -i
```

## Go To The Rails Root

```bash
cd /usr/local/samvera/epigaea
```

## Run The Ingest

```bash
bundle exec rake import:remote_url \
  XML=/absolute/path/to/import.xml \
  MANIFEST=/absolute/path/to/manifest.csv \
  USER=cli_user \
  BATCH_SIZE=25 \
  DOWNLOAD_RETRIES=3
```

If you are not using the dedicated CLI account, replace `USER=cli_user` with the depositor username you want on the created works.

`XML=` and `MANIFEST=` may each be either:

- A local filesystem path on the MIRA host
- A public `http://` or `https://` URL reachable from the MIRA host

Example with remote sources:

```bash
bundle exec rake import:remote_url \
  XML=https://example.org/import.xml \
  MANIFEST=https://example.org/manifest.csv \
  USER=cli_user
```

## Resume An Existing Import

```bash
bundle exec rake import:remote_url \
  IMPORT_ID=123 \
  MANIFEST=/absolute/path/to/manifest.csv \
  USER=cli_user
```

Resume mode is useful if a large ingest stops partway through because of a validation problem, a download failure, a deploy, a shell disconnect, or any other interruption. Re-running with `IMPORT_ID` lets the task continue using the existing `XmlImport` record instead of starting over from scratch.

## Optional Settings

`BATCH_SIZE` controls how many downloaded files are collected before the task saves them onto the import and tries to enqueue ready records.

- Smaller values are safer for a first run and persist progress more often.
- Larger values reduce save/enqueue overhead, but more work is still in-flight if the process stops unexpectedly.
- `25` is a reasonable default.

`DOWNLOAD_RETRIES` controls how many times the task retries a remote download before marking that CSV row as failed.

- Use a higher value if you expect transient network issues or temporary upstream URL failures.
- `3` is a reasonable default.
- If a row still fails after retries, it will be logged in the results file and you can fix the issue and resume the import.

## Notes

- The manifest CSV should have `filename,remote_url` columns.
- Each `filename` in the CSV must match a `<tufts:filename>` value in the XML exactly.
- The XML must include a non-empty `<tufts:visibility>` value for each record.
- Remote `XML` and `MANIFEST` URLs must be publicly accessible from the MIRA host.
- Logs and per-row results are written under `tmp/remote_url_ingest/xml_import_<id>/`.
