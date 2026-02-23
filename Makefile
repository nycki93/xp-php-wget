DIR_IN = src
DIR_OUT = site
ENTRYPOINTS = / /unlisted/

SERVER = 0.0.0.0
PORT = 8000
TEMP_LOG = temp.log

.PHONY: site clean

# run php website on localhost, in a background process.
# watch the logfile for "Development Server started".
# then, use wget to download a static copy of the website.
# finally, kill the background process.
# TODO: is it possible to do this without generating a separate log file?
site:
	php -S $(SERVER):$(PORT) -t $(DIR_IN) > $(TEMP_LOG) 2>&1 & export SERVER_PID=$$!; \
	tail -f $(TEMP_LOG) | grep -qe 'started' && \
	wget \
		--mirror \
		--page-requisites \
		--adjust-extension \
		--no-host-directories \
		--directory-prefix=$(DIR_OUT) \
		--accept-regex='/unlisted/' \
		--reject-regex='/\.' \
		$(foreach PATH,$(ENTRYPOINTS),$(SERVER):$(PORT)$(PATH)); \
	kill $$SERVER_PID; rm $(TEMP_LOG)

clean:
	rm -r $(DIR_OUT)
