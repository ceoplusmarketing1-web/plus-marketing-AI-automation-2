# Plus Marketing AI – social automation

Creates one branded image post per day and publishes it to your Facebook Page and Instagram account through Buffer
(immediate `shareNow` mode, never the Buffer queue). Your app runs the schedule: prepare at 5:30 PM, publish at 6:30 PM
**Asia/Karachi**.

## Start (beginner)
1. Install Python 3.11+ from python.org (Windows: tick "Add Python to PATH").
2. Windows: double-click `start.bat`. Mac/Linux: run `./start.sh`.
3. Open **http://127.0.0.1:8000** in your browser and keep the black window open.
4. Create your admin password. Then go to **API Setup & Settings** and:
   - Step 1: paste Gemini key, Buffer key, Cloudinary Cloud Name / API Key / API Secret → **Save Settings**.
     The app creates the protected `.env` file itself. Keys are hidden afterwards.
   - Step 2: press **Test Gemini**, **Test Buffer**, **Test Cloudinary**. Continue only when each says Passed.
   - Step 3: enter your WhatsApp number (and optional website) → save.
5. **Brand Studio**: upload your character photo (required), 8–10 reference posts, optional logo.
6. **Connected Platforms**: Refresh from Buffer, pick one Facebook and one Instagram channel, Save.
7. **AI Content Studio**: Generate post → check the face, text and WhatsApp number → *Upload to Cloudinary* →
   *Publish test post now* (asks for confirmation; it is a real public post). Wait until both show **published**.
8. **Automation Settings**: press "I verified my first live test…", then choose **Automatic Mode**
   (it is locked until every check passes). Use *Approval Mode* if you want to approve each day.
9. Verify: Automation Settings shows "Next publish … 18:30" in Pakistan time; after the first run check Activity Logs
   and Posts Library.

## How a day works
17:30 research (Gemini + Google Search grounding) → concept + captions → image (Gemini image model) → exact text
drawn by Pillow (headline, support, CTA, WhatsApp) → validated → Cloudinary upload + public-URL check.
18:30 re-validate → one Buffer `createPost` per platform (`mode: shareNow`, `schedulingType: automatic`) → real Buffer
status tracked (submitted ≠ published) → analytics synced every 15 minutes.
If preparation failed or the app was off, nothing is published and the reason is logged. Old posts are never reused.

## Safety built in
Captions never contain the WhatsApp number (stripped and re-checked). A job row is saved *before* each Buffer call;
timeouts/restarts mark it `unknown` and the retry button first looks for the post in Buffer. One platform failing does not
affect the other. Emergency pause button. Keys: `.env` with owner-only permission, never returned by the API, never logged;
saving keys only works from the same computer, with login + CSRF token.

## Honest limits
- Face identity is requested from Gemini with your photo as reference and an AI check is shown, but it is advisory;
  some images will drift. Review each image (Approval Mode) until you trust the results.
- Buffer analytics: per-post metrics only, refreshed by Buffer about daily; Buffer returns 0 for unreported metrics, so a
  0 cannot always be proven real. Account-level follower history is not used. Metrics for posts not yet ingested show
  "not yet available".
- Buffer field names (`ShareMode.shareNow`, `PostInputMetaData` for Facebook/Instagram) follow Buffer's published
  reference. **Test Buffer** also asks Buffer's own schema whether `shareNow` exists. The Instagram/Facebook metadata shape
  could not be verified against your live account from the build environment; if the first test post is rejected,
  the exact Buffer message is shown in Studio and Activity Logs.
- The default image model name `gemini-2.5-flash-image` is configurable; **Test Gemini** lists the image models your
  key can see. Pick one in Automation Settings if the default is not available.

## Deploying
The in-app scheduler needs the process to be running at 17:30 and 18:30 PKT. A home PC that is on, or a paid always-on
host, works. Free hosts sleep: use an external cron (cron-job.org etc.) to call, with header `X-Cron-Token: <CRON_TOKEN>`:
`POST /api/cron/prepare` at 17:30 PKT, `POST /api/cron/publish` at 18:30 PKT, `POST /api/cron/sync` every few hours.
Repeated calls are safe (duplicate protection).
- Put the five API values, `APP_SECRET`, `CRON_TOKEN` in the host's secret/environment settings. Do not rely on a
  writable `.env` on a cloud disk; the browser key-saving is deliberately disabled off-localhost.
- Use managed PostgreSQL via `DATABASE_URL`; container disks are wiped on redeploy (uploads and generated images live in
  `data/` – attach a persistent disk or accept regenerating).
- `Dockerfile` and `render.yaml` are included. Set `PMA_ALLOW_REMOTE_SETUP=1` only for the minute needed to create the
  admin password, then remove it.
- Never upload `.env` or `data/` (see `.gitignore`).

## Tests
`cd backend && pip install -r requirements.txt && pytest` (external APIs mocked; nothing is ever published).
`cd frontend && npm run build` type-checks and builds the dashboard.
