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
# kill the server background process.
# we also use a hacky bit of string replacing to get rid of extra /index.html added by wget when converting links that end in a directory.
# TODO: is it possible to do this without generating a separate log file?
site:
	php -S $(SERVER):$(PORT) -t $(DIR_IN) > $(TEMP_LOG) 2>&1 & export SERVER_PID=$$!; \
	tail -f $(TEMP_LOG) | grep -qe 'started' && \
	wget \
		--mirror \
		--page-requisites \
		--adjust-extension \
		--convert-links \
		--no-host-directories \
		--directory-prefix=$(DIR_OUT) \
		--reject-regex='/\.' \
		$(foreach PATH,$(ENTRYPOINTS),$(SERVER):$(PORT)$(PATH)); \
	kill $$SERVER_PID; rm $(TEMP_LOG); \
	find site -name "*.html" -exec sed -ri 's/href="([^"]*)\/index\.html"/href="\1\/"/gi' {} \;

clean:
	rm -r $(DIR_OUT)
