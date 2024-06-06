# TODO
Base template for over all system
Response Type Binary/Image/Variables?
Response Sessions (Temporary sessions, e.g. login sessions/cookies)
~~Header Modification (custom headers on return)~~
Imports/Exports
Unit Testing
Validation
Identify if there is an issue with config saving on Android (might be a permission issue) and resolve if a problem is found.
~~Fix router when it gets query parameters~~
Ability to introduce delays at server (quick change)/route/response (change at edit) levels
   - Delays will be combined (server + route/response)
Application Logging (errors, warns, etc, not server logs)


# Logs TODO
- Record more data:
    - Received Data (Body, ~~Headers~~, ~~User-Agent~~, ~~Size~~, etc)
        - ~~Binary Data should be marked as "Binary Data"~~
        - Introduce a user definable size limit (default 500kb?) to avoid overflowing memory. (Don't record if over the size)
        
    - ~~Data that was sent (ID of Response)~~
    - ~~Response Time~~
- ~~Card System for displaying instead of plain text~~
- ~~A copy button for copying a JSON document of the log~~
- Filtering (Method, Endpoint, IP)
- ~~Scroll to bottom to auto follow, scroll up to break (unless not at bottom scroll)~~
  - Show indication of new logs if not auto scrolling at bottom
- Ability to view all server logs (and show the server a log is for and allow it to be clickable to go to the server from the log)
- Storage
  - ~~A daemon/cron that runs every few minutes to check servers marked with a dirty bit to dump their logs to disk~~
  - ~~Introduce a size limit that will wipe the logs after it is hit.~~
  - ~~Option to load previous logs~~
  - ~~How many logs on disk to keep?~~
  - Can logs be written to the disk before the application is closed?


### Future TODOS/Ideas
- Local Network Syncing
  - Between Devices/Installs
  - Team Syncing
- Cloud Syncing
- Metrics
